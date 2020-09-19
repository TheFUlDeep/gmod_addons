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
	
	lanes.TerminateTask = function(id)
		if LaneTasks[id] and LaneTasks[id].res then
			LaneTasks[id].res:cancel(0,true)
		end
		LaneTasks[id] = nil
	end
	local TerminateTask = lanes.TerminateTask
	
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
					end--конец куска 1
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
		--LaneTasks[id].curcount = nil
		--LaneTasks[id].maxcount = nil
		--LaneTasks[id].delay = nil
		--LaneTasks[id].dont_die = nil
		local task = LaneTasks[id]
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
	
	--[[
		EXAMPLES
	
		lanes.CreateRepeatingTask(--terminates by conditions
			1,--delay
			0,--repetitions limiit
			nil,--if true it will not terminate on error.
			"example",--id
			nil,--libs (see lua lanes documentation)
			nil,--opts (see lua lanes documentation)
			function(args)--function that will run parallel
				return args and args + 1 or 0
			end,
			function(args)--callback with output argument
				print(args)
				lanes.LaneTasks.example.inArgs = args -- changing input argument
			end,
			nil -- input arument
		)	
		
		lanes.CreateSingleTask(--terminates after one usage
			"asd",--id
			nil,--libs (see lua lanes documentation)
			nil,--opts (see lua lanes documentation)
			function(args)--function that will run parallel
				return args + 1
			end,
			function(args)--callback with output argument
				print(args)
				lanes.LaneTasks.asd.inArgs = args -- changing input argument
			end,
			0 -- input arument
		)
		
		
		timer.Simple(5,function()
			lanes.TerminateTask("example")--terminating task by id
		end)
		
		--lanes.TerminateAllTasks()--terminating all tasks
	]]