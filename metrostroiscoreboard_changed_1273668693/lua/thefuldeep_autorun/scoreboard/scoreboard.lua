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
		if not ent.ASNP then SPB = true end
		if not SPB then RouteNumber = RouteNumber / 10 end
		if RouteNumber < 10 then RouteNumber1 = "0"..RouteNumber else RouteNumber1 = RouteNumber end
		if SPB and RouteNumber < 100 then RouteNumber1 = "0"..RouteNumber1 else RouteNumber1 = RouteNumber1 end
		return " ("..RouteNumber1..")"
	end
	
	local function GetTrain(ply)
		local Owner
		local Speed
		if ply:InVehicle() then
			ent = ply:GetVehicle()
			if IsValid(ent) then ent = ent:GetNW2Entity("TrainEntity",nil) end
			if IsValid(ent) then
				Speed = ent.Speed
				if CPPI then Owner = ent:CPPIGetOwner():Nick() end
				return ent.SubwayTrain.Name..GetRouteNumber(ent) or "-", Owner or "",Speed
			end
		end
		return "-","",Speed
	end

	util.AddNetworkString("ScoreBoardAdditional")
	
	
	local PeregonsTbl = {}
	timer.Create("ScoreBoardAdditional", 5, 0, function()
		for k,v in pairs(PeregonsTbl) do
			if not IsValid(player.GetBySteamID(k)) then PeregonsTbl[k] = nil end
		end
		if not detectstation then print("detectstation is not avaliable") return end
		for k,v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end
			local SteamID = v:SteamID()
			if not PeregonsTbl[SteamID] then PeregonsTbl[SteamID] = {} PeregonsTbl[SteamID][1] = {} PeregonsTbl[SteamID][2] = {} end
			local pos,pos2,path,posx,pos2x,poscurx = detectstation(v:GetPos())
			--if not pos then return end				-- detectstation всегда возвращает pos, поэтому эта строка не нужна?
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
			
			local Train,Owner,Speed = GetTrain(v)
			local Time = ""
			if string.sub(result,1,15) == "перегон " then							--определяю направление движения по ближайшей стации и сохраняю до тех пор, пока человек в перегоне
				if pos2 and strsub1 == "(ближайшая по треку)" then
					local strsub3 = string.sub(pos,1,-38)
					if PeregonsTbl[SteamID][1][1] and PeregonsTbl[SteamID][2][1] then
						if PeregonsTbl[SteamID][1][1] == strsub3 or PeregonsTbl[SteamID][1][1] == pos2 and PeregonsTbl[SteamID][2][1] == strsub3 or PeregonsTbl[SteamID][2][1] == pos2 then
							result = "перегон "..PeregonsTbl[SteamID][1][1].." - "..PeregonsTbl[SteamID][2][1]
							if Train ~= "-" then
								if Speed and Speed > 5 and PeregonsTbl[SteamID][2][2] and poscurx then
									--Speed = Speed * 1000 / 60 / 60
									Time = "Примерное время прибытия через "..math.floor((math.abs(PeregonsTbl[SteamID][2][2] - poscurx) / (50 * 1000 / 60 / 60))).." сек."
								else
									Time = "Не удалось определить время прибытия."
								end
							end
						end
					else
						PeregonsTbl[SteamID][1][1] = strsub3
						PeregonsTbl[SteamID][2][1] = pos2
						--PeregonsTbl[SteamID][1][2] = posx			--мне не нужа позиция станции отправления
						PeregonsTbl[SteamID][2][2] = pos2x
					end
				else
					PeregonsTbl[SteamID][1] = {}
				end
			else
				PeregonsTbl[SteamID][2] = {}
			end
			
			net.Start("ScoreBoardAdditional")
				net.WriteString(result)
				net.WriteString(Train)
				net.WriteString(SteamID)
				net.WriteString(path and " (путь "..path..")" or "")
				net.WriteString(Owner)
				net.WriteString(Time)
			net.Broadcast()
		end
	end)
end