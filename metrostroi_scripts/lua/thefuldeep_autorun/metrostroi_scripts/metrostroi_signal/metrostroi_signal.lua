if SERVER then
	local function CustomozeSignal(ent)
		--не делаю это через sricped_ents.GetStored, потому что не уверен, что успею это сделать до спавна первого светофора
		local OldSayHook = ent.SayHook
		ent.SayHook = function(self,ply,comm)
			if type(ply) == "Player" and ply:GetUserGroup() == "user" and comm:upper():sub(9) == self.Name then return end
			if Metrostroi.ActiveDispatcher
				and Metrostroi.ActiveDispatcher ~= ply
				and Metrostroi.ActiveDSCP1 ~= ply
				and Metrostroi.ActiveDSCP2 ~= ply
				and Metrostroi.ActiveDSCP3 ~= ply 
				and Metrostroi.ActiveDSCP4 ~= ply 
				and Metrostroi.ActiveDSCP5 ~= ply 
				and ply:GetUserGroup() == "user" 
			then 
				return
			end
			OldSayHook(self,ply,comm)
		end
	end
	
	hook.Add("OnEntityCreated","Custom metrostroi signal sayhook",function(ent)
		timer.Simple(1,function()
			if not IsValid(ent) or ent:GetClass() ~= "gmod_track_signal" or not ent.SayHook then return end
			CustomozeSignal(ent)
		end)
	end)
end

if SERVER then return end

local signsls = {} -- сохраняю все сигналы в таблицу, чтобы не делать каждый раз ents.FindByClass("gmod_track_signal")
hook.Add("OnEntityCreated","save signals to local tbl for autostop sound",function(ent)
	timer.Simple(1,function()
		if not IsValid(ent) or ent:GetClass() ~= "gmod_track_signal" then return end
		signsls[#signsls+1] = ent
	end)
end)

local AutoStopSound = Sound("autostop.mp3")
timer.Create("Metrostroi signal Autostop sound",0.3,0,function()
	for _,v in pairs(signsls) do
		if not IsValid(v) then continue end
		if v.LastAutostopPos ~= v:GetNW2Bool("Autostop") and v.Models and v.Models[1] and v.Models[1]["autostop"] then
			v.LastAutostopPos = v:GetNW2Bool("Autostop")
			sound.Play( AutoStopSound, v.Models[1]["autostop"]:GetPos(), 55, 180, 1 )
		end
	end
end)


	--Metrostroi.UpdateSignalEntities()
	--Metrostroi.UpdateSwitchEntities()
	--Metrostroi.UpdateARSSections()