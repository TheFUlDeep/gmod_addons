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
	timer.Create("ScoreBoardAdditional", 1, 0, function()
		if not detectstation then return end
		for k,v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end
			local pos,pos2,path = detectstation(v:GetPos())
			if not pos then return end
			local start = string.find(pos,"ближайшая")
			if start then
				if pos2 then pos = "перегон "..string.sub(pos,1,start - 2).." - "..pos2 else pos = "-" end
			end
			--if pos ~= "-" and path then pos = pos.." (путь "..path..")" end
			net.Start("ScoreBoardAdditional")
				net.WriteString(pos)
				net.WriteString(GetTrain(v))
				net.WriteString(v:SteamID())
				net.WriteString(path and " (путь "..path..")" or "")
			net.Broadcast()
		end
	end)
end