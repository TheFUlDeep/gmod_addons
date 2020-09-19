--TODO проверить, правильно ли работает функция Terminate
--таблицы при перемещениями между луа стейтами вроде копируются, а не передаеются по ссылкe?
if SERVER then AddCSLuaFile("lanes/lanes_main.lua")end
local files = file.Find("lua/bin/*", "GAME")
local found
for _,name in pairs(files)do
	if (CLIENT and name:sub(1,5) == "gmcl_" or SERVER and name:sub(1,5) == "gmsv_") and name:sub(6,16) == "lanes.core_" and name:sub(-4,-1) == ".dll" then found = true break end
end
if not found then return end


if not lanes then include("lanes/lanes_main.lua")end

if lanes.configure then lanes.configure(--[[{track_lanes=true,nb_keepers=10}]])end

local LaneTasks = {}

lanes.TerminateAllTasks = function()
	for id,task in pairs(LaneTasks)do
		if task.res then res:cancel(0,true)end
	end
	LaneTasks = {}
end

lanes.TerminateTask = function(id)
	if LaneTasks[id] and LaneTasks[id].res then
		LaneTasks[id].res:cancel(0,true)
	end
	LaneTasks[id] = nil
end
local TerminateTask = lanes.TerminateTask


--Vector, Angle, color, --entity, table
local typesToconvert = {Vector=true,Angle=true}
local function IsNeedConvertTableToLanes(tbl)
	for k,v in pairs(tbl)do
		if typesToconvert[type(v)] or IsColor(v) or IsEntity(v) then
			return true
		elseif istable(v) then
			if IsNeedConvertTableToLanes(v) then return true end
		end
	end
end
local TableCopyToLanes = function(tbl)
		tbl = tbl or {}
		tbl = istable(tbl) and tbl or {tbl}
		
		if not IsNeedConvertTableToLanes(tbl) then return tbl end
		
		local res = {}
		for k,v in pairs(tbl)do
			if IsColor(v) then
				res[k] = {lanesTableType="color",v.r,v.g,v.b,v.a}
			elseif istable(v) then
				res[k] = lanes.TableCopyToLanes(v)
			elseif isvector(v) then
				res[k] = {lanesTableType="Vector",v[1],v[2],v[3]}
			elseif isangle(v) then
				res[k] = {lanesTableType="Angle",v[1],v[2],v[3]}
			elseif IsEntity(v) then
				continue
				--res[k] = lanes.TableCopyToLanes(v:GetTable())
				--res[k].lanesTableType = "entity"
			else
				res[k] = v
			end
		end
		return res
end
lanes.TableCopyToLanes = TableCopyToLanes
	
local function IsNeedConvertTableToNormal(tbl)
	for k,v in pairs(tbl)do
		if istable(v) and v.lanesTableType then return true end
	end
end
local TableCopyToNormal = function(tbl)
		tbl = tbl or {}
		tbl = istable(tbl) and tbl or {tbl}
		
		if not IsNeedConvertTableToNormal(tbl) then return tbl end
		
		local res = {}
		for k,v in pairs(tbl)do
			if type(v) == "table" then
				local type = v.lanesTableType
				if type == "Vector" then
					res[k] = Vector(v[1],v[2],v[3])
				elseif type == "Angle" then
					res[k] = Angle(v[1],v[2],v[3])
				elseif type == "color" then
					res[k] = Color(v[1],v[2],v[3],v[4])
				--[[elseif type == "entity" then
					res[k] = ]]
				else
					res[k] = lanes.TableCopyToNormal(v)
				end
			else
				res[k] = v
			end
		end
		return res
end
lanes.TableCopyToNormal = TableCopyToNormal
	
	
	
local function CheckDelay(id,task)
	local delay = task.delay
	if delay then
		if (CurTime() - task.PrevStartTime) >= delay then
			task.PrevStartTime = task.PrevStartTime + delay--благодаря этому, если программа будет опаздывать, в следующий раз запустится мгновенно
			local maxcount = task.maxcount
			if not maxcount or maxcount == 0 then--чтобы не считать task.curcount при отсутствии лимита
				task.res = task.f(task.inArgs)
			else
				task.curcount = task.curcount + 1
				if task.curcount < maxcount then
					task.res = task.f(task.inArgs)
				else
					TerminateTask(id)
				end
			end
		end
	else
		TerminateTask(id)
	end
end

local calceled_strings = {["error"]=true,cancelled=true,killed=true}
hook.Add("Think","LuaLanesCallbacks",function()
	for id,task in pairs(LaneTasks)do
		local res = task.res
		if res then
			--print(tostring(res[1]))
			local status = res.status
			if status == "done" then
				task.callback(task.dontConvertArgs and task.res[1] or TableCopyToNormal(task.res[1]))
				task.res = nil
				CheckDelay(id,task)
			elseif calceled_strings[status] then
				if not task.printerErr then
					task.printerErr = true
					print(task.res[1])
				end
				--task.res = nil
				if task.dont_die then
					task.printerErr = nil
					task.res = nil
				else
					TerminateTask(id)
				end
			end
		else
			CheckDelay(id,task)
		end
	end
end)

lanes.CreateSingleTask = function(id,libs,opts,dontConvertArgs,func,callback,inArgs)
	inArgs = dontConvertArgs and inArgs or TableCopyToLanes(inArgs)
	TerminateTask(id)
	LaneTasks[id] = {}
	--LaneTasks[id].curcount = nil
	--LaneTasks[id].maxcount = nil
	--LaneTasks[id].delay = nil
	--LaneTasks[id].dont_die = nil
	local task = LaneTasks[id]
	task.dontConvertArgs = dontConvertArgs
	task.callback = callback
	local f = lanes.gen(libs,opts,func)
	task.f = f
	task.res = f(inArgs)
	task.inArgs = inArgs
end
local CreateSingleTask = lanes.CreateSingleTask

lanes.CreateRepeatingTask = function(delay,count,dont_die,id,...)
	CreateSingleTask(id,...)
	local task = LaneTasks[id]
	task.curcount = 0
	task.maxcount = count
	task.delay = delay
	task.dont_die = dont_die
	task.PrevStartTime = CurTime()
end

lanes.SetInputArgs = function(id,args)
	local task = LaneTasks[id]
	if task then
		task.inArgs = task.dontConvertArgs and args or TableCopyToLanes(args)
	end
end

lanes.GetTasks = function()
	return LaneTasks
end

--[[
	EXAMPLES
	
	accept input arg types:
		string,bool,nil,number,vector,color,angle,some functions,table with all this types

	lanes.CreateRepeatingTask(--terminates by conditions
		1,--delay
		0,--repetitions limiit
		nil,--if true it will not terminate on error.
		"example",--id
		nil,--libs (see lua lanes documentation)
		nil,--opts (see lua lanes documentation)
		true,--if true it will not convert args to table (for performance)
		function(args)--function that will run parallel
			return args[1] and args[1] + 1 or 0
		end,
		function(args)--callback with output argument
			print(args[1])
			lanes.SetInputArgs("example",args) -- changing input argument. it will push table
			lanes.GetTasks().example.inArgs = args -- another variant of changing input argument (without converting to table if it needed). I dont recommend to use this method.
		end,
		nil -- input arument. It will convert to table
	)	
	
	lanes.CreateSingleTask(--terminates after one usage
		"asd",--id
		nil,--libs (see lua lanes documentation)
		nil,--opts (see lua lanes documentation)
		nil,--if true it will not convert args to table (for performance)
		function(args)--function that will run parallel
			return args[1] + 1
		end,
		function(args)--callback with output argument
			print(args[1])
		end,
		0 -- input arument. It will convert to table
	)
	
	
	timer.Simple(5,function()
		lanes.TerminateTask("example")--terminating task by id
	end)
	
	--lanes.TerminateAllTasks()--terminating all tasks
]]