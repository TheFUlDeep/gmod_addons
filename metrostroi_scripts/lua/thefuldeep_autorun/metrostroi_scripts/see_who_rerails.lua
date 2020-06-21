if CLIENT then return end

hook.Add("PlayerInitialSpawn","custom metrostroi_rerail",function()
	hook.Remove("PlayerInitialSpawn","custom metrostroi_rerail")
	print("overriding metrostroi_rerail")
	local concommandsTbl = concommand.GetTable()
	if concommandsTbl.metrostroi_rerail then 
		local OldRerail = concommandsTbl.metrostroi_rerail
		local function Rerail(ply,cmd,args,fullstring)
			local ent = ply:GetEyeTrace().Entity
			if not IsValid(ent) or not ent:GetClass():find("gmod_subway") then return end
			OldRerail(ply,cmd,args,fullstring)
			local entOwner = CPPI and ent:CPPIGetOwner()
			if not IsValid(entOwner) or entOwner == ply then return end
			ulx.fancyLogAdmin(ply, true, "#A использовал rerail на вагоне игрока #T",entOwner)
		end
		concommand.Add("metrostroi_rerail",Rerail)
	end
end)