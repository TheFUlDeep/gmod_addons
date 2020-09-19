	if SERVER then AddCSLuaFile("lanes/lanes_main.lua")end
	local files = file.Find("lua/bin/*", "GAME")
	local found
	for _,name in pairs(files)do
		if (CLIENT and name:sub(1,5) == "gmcl_" or SERVER and name:sub(1,5) == "gmsv_") and name:sub(6,16) == "lanes.core_" and name:sub(-4,-1) == ".dll" then found = true break end
	end
	if not found then return end
	
	
	if not lanes then include("lanes/lanes_main.lua")end

	if lanes.configure then lanes.configure(--[[{track_lanes=true,nb_keepers=10}]])end
	
	lanes.LaneTasks = lanes.LaneTasks or {}
	local LaneTasks = lanes.LaneTasks
	
	lanes.TerminateAllTasks = function()
		for id,task in pairs(LaneTasks)do
			if task.res then res:cancel(0,true)end
		end
		LaneTasks[id] = nil
	end
	
	local function TerminateTask(id)
		if LaneTasks[id] and LaneTasks[id].res then
			LaneTasks[id].res:cancel(0,true)
		end
		LaneTasks[id] = nil
	end
	
	local calceled_strings = {["error"]=true,cancelled=true,killed=true}
	hook.Add("Think","LuaLanesCallbacks",function()
		local CurTime = CurTime()
		for id,task in pairs(LaneTasks)do
			local res = task.res
			if res then
				--print(tostring(res[1]))
				local status = res.status
				if status == "done" then
					task.callback(task.res[1])
					task.res = nil
					local delay = task.delay--начало куска 1
					if delay then
						if (CurTime - task.PrevStartTime) >= delay then
							task.PrevStartTime = task.PrevStartTime + delay
							local maxcount = task.maxcount
							if not maxcount or maxcount == 0 then
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
					end--конец куска 1
				elseif calceled_strings[status] then
					if not task.printerErr then
						task.printerErr = true
						print(task.res[1])
					end
					task.printerErr = nil
					task.res = nil
				end
			else
				local delay = task.delay--начало куска 1
				if delay then
					if (CurTime - task.PrevStartTime) >= delay then
						task.PrevStartTime = task.PrevStartTime + delay
						local maxcount = task.maxcount
						if not maxcount or maxcount == 0 then
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
					TerminateTask(id)--конец куска 1
				end
			end
		end
	end)
	
	lanes.CreateSingleTask = function(id,libs,opts,func,callback,inArgs)
		TerminateTask(id)
		LaneTasks[id] = {}
		LaneTasks[id].curcount = nil
		LaneTasks[id].maxcount = nil
		LaneTasks[id].delay = nil
		local task = LaneTasks[id]
		task.callback = callback
		local f = lanes.gen(libs,opts,func)
		task.f = f
		task.res = f(inArgs)
		task.inArgs = inArgs
	end
	local CreateSingleTask = lanes.CreateSingleTask
	
	lanes.CreateRepeatingTask = function(delay,count,id,...)
		CreateSingleTask(id,...)
		local task = LaneTasks[id]
		task.curcount = 0
		task.maxcount = count
		task.delay = delay
		task.PrevStartTime = CurTime()
	end
	
	--[[CreateRepeatingTask(
		0.1,
		5,
		"asd",
		"table",
		nil,
		function(args)
			return args
		end,
		function(args)
			LaneTasks.asd.inArgs = args + 1
		end,
		1
	)]]