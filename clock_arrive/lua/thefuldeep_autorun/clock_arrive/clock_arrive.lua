if CLIENT then return end

local function FindNearestStation(vector)
	if not Metrostroi.StationConfigurations then return nil end
	local MinDist,CurDist,Station
	for k,v in pairs(Metrostroi.StationConfigurations) do
		if v.positions and v.positions[1] and v.positions[1][1] then
			if math.abs(v.positions[1][1].y - vector.y) > 500 then continue end
			CurDist = vector:DistToSqr(v.positions[1][1])
			if not MinDist or CurDist < MinDist then MinDist = CurDist Station = v.names and v.names[1] or k end
		end
	end
	return Station
end

local function SpawnClocks()
	print("Spawning_arrive_clocks")
	if not detectstation then print('detectstation is not avaliable. Cant create arrive clocks') return end
	for k,v in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("gmod_track_clock_interval")) do
		if not IsValid(v) then continue end
		local ent = ents.Create("gmod_metrostroi_clock_arrive")
		if not IsValid(ent) then print("CANT SPAWN CLOCKS") return end
		ent:SetPos(v:GetPos() - Vector(0,0,v:OBBMaxs().z * 2))
		ent:SetAngles(v:GetAngles())
		ent:SetModel(v:GetModel())
		ent:Spawn()
		local Station,Station2,Path,Posx,StationPosx,Station2Posx = detectstation(ent:GetPos())
		if not Path then Path = FindTrackInSquare(v:GetPos(),nil,200,200,50) print(Path)
			if Path and Path.trackid then 
				Path = Path.trackid		
			else
				print("cant detect path for arrive clock")
				return
			end
		end
		if not Station or Station == "" then ent:Remove() print("cant detect station for arrive clock") return end
		local DontNeed = stringfind(Station, " ( ближайшая ")
		if DontNeed then Station = Station:sub(1,DontNeed - 1) end
		ent.Station = Station
		ent.Path = Path		
	end
end

hook.Add("PlayerInitialSpawn","Clock_arrive spawn ents",function()
	hook.Remove("PlayerInitialSpawn","Clock_arrive spawn ents")
	timer.Simple(5,SpawnClocks)
end)

--SpawnClocks()

timer.Create("Update ArriveClocks",10,0,function()
	if not THEFULDEEP or not THEFULDEEP.GETSERVERINFOGLOBAL then return end
	THEFULDEEP.GETSERVERINFOGLOBAL()
	if not THEFULDEEP.SERVERINFO then return end
	for k,v in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
		if not IsValid(v) or not v.Station or not v.Path then continue end
		local ArrTimes = {}
		for k1,v1 in pairs(THEFULDEEP.SERVERINFO) do
			if type(v1) ~= "table" then continue end
			if v1.Map and v1.Map == THEFULDEEP.MAP and v1.Trains then
				for k2,v2 in pairs(v1.Trains) do
					if v2.Path and v2.ArrTime and v2.Position then 
						if v.Path ~= v2.Path then continue end
						local start = string.sub(v2.Position,1,15):find("перегон ") and stringfind(v2.Position," - ") or nil
						if not start then continue end
						if string.sub(v2.Position,start + 3) == v.Station then
							table.insert(ArrTimes,1,v2.ArrTime)
						end
					end
				end
			end
		end
		if #ArrTimes < 1 then 
			v:SetNW2Int("ArrTime",-1) 
		else
			local Min
			for k1,v1 in pairs(ArrTimes) do
				if not Min or v1 < Min then Min = v1 end
			end
			v:SetNW2Int("ArrTime",Min) 
		end
	end
end)