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
	timer.Create("ScoreBoardAdditional", 1, 0, function()
		if not detectstation then print("detectstation is not avaliable") return end
		for k,v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end
			local pos,pos2,path = detectstation(v:GetPos())
			if not pos then return end
			local result = pos
			local strsub1 = string.sub(pos,-36) --(ближайшая по треку)
			local strsub2 = string.sub(pos,-42)	--(ближайшая в плоскости)
			if strsub2 == "(ближайшая в плоскости)" then
				if path then
					result = "перегон"
				elseif stringfind(pos,"депо",true) then
					result = "депо"
				else
					result = "-"
				end
			end
			
			if strsub1 == "(ближайшая по треку)" then
				if pos2 then
					result = "перегон "..string.sub(pos,1,-38).." - "..pos2
				else
					result = "тупик "..string.sub(pos,1,-38)
				end
			end
			net.Start("ScoreBoardAdditional")
				net.WriteString(result)
				net.WriteString(GetTrain(v))
				net.WriteString(v:SteamID())
				net.WriteString(path and " (путь "..path..")" or "")
			net.Broadcast()
		end
	end)
end