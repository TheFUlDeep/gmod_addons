--TODO проверить, правильно ли работает функция Terminate
--таблицы при перемещениями между луа стейтами вроде копируются, а не передаеются по ссылкe?
if SERVER then AddCSLuaFile("lanes/lanes_main.lua")end
local files = file.Find("lua/bin/*", "GAME")
local found
for _,name in pairs(files)do
	if (CLIENT and name:sub(1,5) == "gmcl_" or SERVER and name:sub(1,5) == "gmsv_") and name:sub(6,16) == "lanes.core_" and name:sub(-4,-1) == ".dll" then found = true break end
end
if not found then return end

if not tfdTableCopy1 then include("thefuldeep_autorun/tfd_tablecopy.lua") end


if not lanes then include("lanes/lanes_main.lua")end

if lanes.configure then lanes.configure()end--demote_full_userdata

local LaneTasks = {}

lanes.TerminateAllTasks = function()
	for id,task in pairs(LaneTasks)do
		if task and task.res then task.res:cancel(0,true)end
	end
	LaneTasks = {}
end

lanes.TerminateTask = function(id)
	local task = LaneTasks[id]
	if task and task.res then
		task.res:cancel(0,true)
	end
	LaneTasks[id] = nil
end
local TerminateTask = lanes.TerminateTask
	
	
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
		if task.paused then continue end
		local res = task.res
		if res then
			--print(tostring(res[1]))
			local status = res.status
			if status == "done" then
				if task.convert then 
					task.callback(task.convert == 1 and tfdTableCopy1(task.res[1],true) or tfdTableCopy2(task.res[1],true)) 
				else
					task.callback(task.res[1])
				end
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

lanes.CreateSingleTask = function(id,libs,opts,convert,func,callback,inArgs)
	if convert then
		inArgs = convert == 1 and tfdTableCopy1(inArgs,false) or tfdTableCopy2(inArgs,false)
	end
	TerminateTask(id)
	LaneTasks[id] = {}
	--LaneTasks[id].curcount = nil
	--LaneTasks[id].maxcount = nil
	--LaneTasks[id].delay = nil
	--LaneTasks[id].dont_die = nil
	local task = LaneTasks[id]
	task.convert = convert
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
		if task.convert then 
			task.inArgs = task.convert == 1 and tfdTableCopy1(args,false)  or tfdTableCopy2(args,false)
		else
			task.inArgs = args 
		end
	end
end

lanes.GetTasks = function()
	return LaneTasks
end

lanes.PauseTask = function(id)
	local task = LaneTasks[id]
	if task then task.paused = true end
end

lanes.ResumeTask = function(id)
	local task = LaneTasks[id]
	if task then task.paused = nil end
end

--[[
	EXAMPLES
	
	accept input arg types (if convert argument):
		string,bool,nil,number,vector,color,angle,some functions,table with all this types
		--it also will transfer ents (and tables with it), but only indexes (without content) and if "dontConvertArgs" setted to false or nil
		
		if not converting, it accepts string,bool,nil,number,some functions,table with all this types

	lanes.CreateRepeatingTask(--terminates by conditions
		1,--delay
		0,--repetitions limiit
		nil,--if true it will not terminate on error.
		"example",--id
		nil,--libs (see lua lanes documentation)
		nil,--opts (see lua lanes documentation)
		nil,--if not false and not nil in will convert args (lower performance). 1 - for small tables, any else value for big tables
		function(args)--function that will run parallel
			return args[1] and args[1] + 1 or 0
		end,
		function(args)--callback with output argument
			print(args[1])
			lanes.SetInputArgs("example",args) -- changing input argument
			lanes.GetTasks().example.inArgs = args -- another variant of changing input argument (without converting to table if it needed). I dont recommend to use this method.
		end,
		nil -- input arument
	)	
	
	lanes.CreateSingleTask(--terminates after one usage
		"asd",--id
		nil,--libs (see lua lanes documentation)
		nil,--opts (see lua lanes documentation)
		nil,--if not false and not nil in will convert args (lower performance). 1 - for small tables, any else value for big tables
		function(args)--function that will run parallel
			return args + 1
		end,
		function(args)--callback with output argument
			print(args)
		end,
		0 -- input arument
	)
	
	if you want delay by ending, do it like this
	lanes.CreateRepeatingTask(--terminates by conditions
		0,--delay
		0,--repetitions limiit
		nil,--if true it will not terminate on error.
		"example3",--id
		nil,--libs (see lua lanes documentation)
		nil,--opts (see lua lanes documentation)
		1,--if not false and not nil in will convert args (lower performance). 1 - for small tables, any else value for big tables
		function(args)--function that will run parallel
			return args
		end,
		function(args)--callback with output argument
			print(args,CurTime())
			lanes.PauseTask("example3")
			timer.Simple(1,function()
				lanes.ResumeTask("example3")
			end)
		end,
		"asd" -- input arument. It will convert to table
	)
	
	
	timer.Simple(5,function()
		lanes.TerminateTask("example")--terminating task by id
	end)
	
	--lanes.TerminateAllTasks()--terminating all tasks
]]