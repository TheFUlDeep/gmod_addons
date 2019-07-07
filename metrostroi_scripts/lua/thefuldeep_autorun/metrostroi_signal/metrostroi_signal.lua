if SERVER then 
	local function CustomozeSignals()
		print("customizing signals")
		for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
			if not IsValid(v) then continue end
			local tbl = v:GetTable()
			if tbl.SayHook then
				local OldSayHook = tbl.SayHook
				tbl.SayHook = function(ply,comm)
					if  Metrostroi.ActiveDispatcher ~= ply
						and Metrostroi.ActiveDSCP1 ~= ply
						and Metrostroi.ActiveDSCP2 ~= ply
						and Metrostroi.ActiveDSCP3 ~= ply 
						and Metrostroi.ActiveDSCP4 ~= ply 
						and Metrostroi.ActiveDSCP5 ~= ply 
						and Metrostroi.ActiveDispatcher ~= nil 
						and ply:GetUserGroup() == "user" 
					then 
						return
					end
					OldSayHook(ply,comm)
				end
				v:SetTable(tbl)
			end
		end
	end
	
	local function CustomozeSignal(ent)
		--print("customizing signal "..ent.Name)
		local tbl = ent:GetTable()
		if tbl.SayHook then
			local OldSayHook = tbl.SayHook
			tbl.SayHook = function(ply,comm)
				if  Metrostroi.ActiveDispatcher ~= ply
					and Metrostroi.ActiveDSCP1 ~= ply
					and Metrostroi.ActiveDSCP2 ~= ply
					and Metrostroi.ActiveDSCP3 ~= ply 
					and Metrostroi.ActiveDSCP4 ~= ply 
					and Metrostroi.ActiveDSCP5 ~= ply 
					and Metrostroi.ActiveDispatcher ~= nil 
					and ply:GetUserGroup() == "user" 
				then 
					return
				end
				OldSayHook(ply,comm)
			end
			ent:SetTable(tbl)
		end
	end
	
	local SignalsCustomized
	
	hook.Add("PlayerInitialSpawn","Custom metrostroi signals",function()
		hook.Remove("PlayerInitialSpawn","Custom metrostroi signal")
		CustomozeSignals()
		SignalsCustomized = true
	end)
	
	
	--на всякий случай при спавне светофора обновлять его функции
	hook.Add("OnEntityCreated","Custom metrostroi signal",function(ent)
		timer.Simple(1,function()
			if not IsValid(ent) or not SignalsCustomized or ent:GetClass() ~= "gmod_track_signal" then return end
			CustomozeSignal(ent)
		end)
	end)
end

if SERVER then return end

local AutoStopSound = Sound("autostop.mp3")
timer.Create("Metrostroi signal Autostop sound",0.3,0,function()
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(v) then continue end
		if not v.LastAutostopPosLoaded then
			v.LastAutostopPosLoaded = true
			v.LastAutostopPos = v:GetNW2Bool("Autostop")
		end
		if v.LastAutostopPos ~= v:GetNW2Bool("Autostop") and v.Models and v.Models[1] and v.Models[1]["autostop"] then
			v.LastAutostopPos = v:GetNW2Bool("Autostop")
			sound.Play( AutoStopSound, v.Models[1]["autostop"]:GetPos(), 55, 180, 1 )
		end
	end
end)


	--Metrostroi.UpdateSignalEntities()
	--Metrostroi.UpdateSwitchEntities()
	--Metrostroi.UpdateARSSections()