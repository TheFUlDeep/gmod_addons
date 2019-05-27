if SERVER then
	local function GetRouteNumber(ent)
		local RouteNumber = ent:GetNW2Int("RouteNumber",0)
		if RouteNumber == 0 then
			if ent.WagonList then
				for k,v in pairs(ent.WagonList) do
					RouteNumber = RouteNumber == 0 and ent:GetNW2Int("RouteNumber",0)
				end
			end
		end
		if not RouteNumber then return "" end
		local RouteNumber1
		local SPB = false
		local Name = ent.SubwayTrain.Name
		if Name:find("722") or Name:find("Ema") or (Name:find("717") and not Name:find("5m")) or (ent.SubwayTrain.Manufacturer and ent.SubwayTrain.Manufacturer:find("LVZ")) then SPB = true end
		if not SPB then RouteNumber = RouteNumber / 10 end
		if RouteNumber < 10 then RouteNumber1 = "0"..RouteNumber else RouteNumber1 = RouteNumber end
		if SPB and RouteNumber < 100 then RouteNumber1 = "0"..RouteNumber1 else RouteNumber1 = RouteNumber1 end
		return " ("..RouteNumber1..")"
	end
	
	local function GetTrain(ply)
		if ply:InVehicle() then
			local ent = ply:GetVehicle()
			if IsValid(ent) then ent = ent:GetNW2Entity("TrainEntity",nil) end
			if IsValid(ent) then
				
				return ent.SubwayTrain.Name..GetRouteNumber(ent) or "-" 
			end
		end
		return "-"
	end

	util.AddNetworkString("ScoreBoardAdditional")
	timer.Create("ScoreBoardAdditional", 5, 0, function()
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