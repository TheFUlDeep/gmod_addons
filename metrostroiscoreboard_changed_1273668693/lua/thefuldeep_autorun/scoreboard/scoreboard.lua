if SERVER then
	local function GetTrain(ply)
		if ply:InVehicle() then
			local ent = ply:GetVehicle()
			if IsValid(ent) then ent = ent:GetNW2Entity("TrainEntity",nil) end
			if IsValid(ent) then return ent.SubwayTrain and ent.SubwayTrain.Name or "-" end
		end
		return "-"
	end

	util.AddNetworkString("ScoreBoardAdditional")
	
	timer.Create("ScoreBoardAdditional",5,0,function()
		if not detectstation then return end
		for k,v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end
			local pos = detectstation(v:GetPos())
			if pos:find("ближайшая ") then pos = "перегон" end
			net.Start("ScoreBoardAdditional")
				net.WriteString(pos)
				net.WriteString(GetTrain(v))
				net.WriteString(v:SteamID())
			net.Broadcast()
		end
	end)
end