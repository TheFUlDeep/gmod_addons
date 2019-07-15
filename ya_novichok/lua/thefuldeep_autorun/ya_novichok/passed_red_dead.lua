
--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	for k,v in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(v)
		if ENT and ENT.t and ENT.t.Spawner then
			local cont = false
			for k,v in pairs(ENT.t.Spawner) do
				if istable(v) and v[1]=="PassedRedDead" then cont = true break end
			end
			if cont then continue end
		
			table.insert(ENT.t.Spawner,{"PassedRedDead","Я новичок","Boolean"})
		end
	end
end)

if CLIENT then return end

local Dead = Sound("thefuldeeps_sounds/passed_red_dead.mp3")

timer.Simple(0,function()
	if MetrostroiHooksOverrided then return end
	local HooksTbl = hook.GetTable()
	print("metrostroi hooks overriding")
	local PassedRed = HooksTbl.MetrostroiPassedRed and HooksTbl.MetrostroiPassedRed.MetrostroiPassedRed1 or function() end
	local PlombBroken = HooksTbl.MetrostroiPlombBroken and HooksTbl.MetrostroiPlombBroken.PerzostroiAPIPlomb1 or function() end
	hook.Add("MetrostroiPassedRed","MetrostroiPassedRed1",function(train,ply,mode,arsback)
		if train:GetNW2Bool("PassedRedDead",false) then
			sound.Play(Dead, ply:GetPos(), 179, 100, 1)
		end
		PassedRed(train,ply,mode,arsback)
		return true
	end)
	
	hook.Add("MetrostroiPlombBroken", "PerzostroiAPIPlomb1", function(train,but,ply)
		if train:GetNW2Bool("PassedRedDead",false) then
			sound.Play(Dead, ply:GetPos(), 179, 100, 1)
		end
		PlombBroken(train,but,ply)
		return true
	end)
	
	MetrostroiHooksOverrided = true		-- this is global value
end)