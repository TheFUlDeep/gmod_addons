if CLIENT then return end
--include("detectstation.lua")

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

local function GetStationIndexByName(str)
	if not str or not Metrostroi or not Metrostroi.StationConfigurations then return end
	
	for index,v in pairs(Metrostroi.StationConfigurations) do
		if not tonumber(index) or not v.names or not istable(v.names) or table.Count(v.names) < 1 then continue end
		local index = tonumber(index)
		for _,name in pairs(v.names) do
			if bigrustosmall(name) == str then return index end
		end
	end
end

local function GetPlatformByIndex(index,path)
	if not index or not tonumber(index) then return end
	index = tonumber(index)
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do 
		if Platform.TrackPos and Platform.StationIndex == index and tonumber(Platform.PlatformIndex) == path then return Platform end
	end
end

local function GetPlatformByStationName(str,path)
	return GetPlatformByIndex(GetStationIndexByName(str),path)
end

local function GetStationTrackNodeByName(str,path)
	str = bigrustosmall(str)
	path = tonumber(path)
	if not path then return end
	local stationent = GetPlatformByStationName(str,path)
	if not stationent then return end
	return Metrostroi.GetPositionOnTrack(LerpVector(0.5, stationent.PlatformEnd, stationent.PlatformStart))[1]
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
		if not IsValid(ent) then print("CANT SPAWN CLOCKS") continue end
		ent:SetPos(v:GetPos() - Vector(0,0,v:OBBMaxs().z * 2))
		ent:SetAngles(v:GetAngles())
		ent:SetModel(v:GetModel())
		ent:Spawn()
		local Station,Station2,Path,Posx,StationPosx,Station2Posx = detectstation(ent:GetPos())
		if not Path then Path = FindTrackInSquare(v:GetPos(),nil,200,200,50)
			if Path and Path.trackid then 
				Path = Path.trackid		
			else
				print("cant detect path for arrive clock")
				ent:Remove()
				continue
			end
		end
		if not Station or Station == "" then ent:Remove() print("cant detect station for arrive clock") continue end
		local DontNeed = stringfind(Station, " ( ближайшая ")
		if DontNeed then Station = Station:sub(1,DontNeed - 1) end
		ent.Station = Station
		
		ent.Path = Path--TODO вообще тут лучше сохранять айди трека
		
		ent.TrackNode = GetStationTrackNodeByName(Station,Path)
	end
end

hook.Add("PlayerInitialSpawn","Clock_arrive spawn ents",function()
	for _,ent in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do ent:Remove() end

	hook.Remove("PlayerInitialSpawn","Clock_arrive spawn ents")
	timer.Simple(5,SpawnClocks)
end)

--for _,ent in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do ent:Remove() end
--SpawnClocks()

timer.Create("Update ArriveClocks",5,0,function()
	if not THEFULDEEP or not THEFULDEEP.GETSERVERINFOGLOBAL then return end
	THEFULDEEP.GETSERVERINFOGLOBAL()
	if not THEFULDEEP.SERVERINFO then return end
	local changetime = os.time()
	for _,clockent in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
		if not IsValid(clockent) or not clockent.Station or not clockent.Path or not clockent.TrackNode then continue end
		local ArrTimes = {}
		for _,v1 in pairs(THEFULDEEP.SERVERINFO) do
			if type(v1) ~= "table" then continue end
			if v1.Map and v1.Map == THEFULDEEP.MAP and v1.Trains then
				for _,train in pairs(v1.Trains) do
					if not train.Direction or train.Direction == 0 or not train.PosVector --[[or not train.Speed or train.Speed < 5]] then continue end
					
					train.TrackNode = train.TrackNode or Metrostroi.GetPositionOnTrack(train.PosVector)[1]
					
					if not train.TrackNode or train.TrackNode.path.id ~= clockent.TrackNode.path.id then continue end
					
					local dir = train.Direction < 0
					local clockpos = clockent.TrackNode.x
					local trainposx = train.TrackNode.x
					
					--если состав движется в сторону часов (в независимости от расстояния, но по тому же треку, на котором стоят часы)
					if (dir and clockpos < trainposx) or (not dir and clockpos > trainposx) then
						local arrtime =  Metrostroi.GetTravelTime(train.TrackNode.node1,clockent.TrackNode.node1)
						
						--если на пути от паравоза до часов есть еще станции (часы), то прибавить ко времени 30 сек на каждую станцию
						if trainposx < clockpos then trainposx,clockpos = clockpos,trainposx end--так trainposx всегда будет >= clockpos. Это для упрощения дальнейшего сравнения
						local additional_time = 0
						for _,clock2 in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
							if clock2 == clockent or not IsValid(clock2) or not clock2.TrackNode or clock2.TrackNode.path.id ~= clockent.TrackNode.path.id then continue end
							local posx = clock2.TrackNode.x
							if posx > clockpos and posx < trainposx then additional_time = additional_time + 30 end
						end
						
						arrtime = math.floor(arrtime) + additional_time
						table.insert(ArrTimes,arrtime)
					end
					--local start = string.sub(train.Position,1,15):find("перегон ") and string.find(train.Position," - ",1,true) or nil
					--if not start then continue end
					--if string.sub(train.Position,start + 3) == clockent.Station then
						--table.insert(ArrTimes,1,train.ArrTime)
					--end
				end
			end
		end
		if #ArrTimes < 1 then
			clockent:SetNW2Int("ArrTime",-1) 
		else
			local Min
			for k1,v1 in pairs(ArrTimes) do
				if not Min or v1 < Min then Min = v1 end
			end
			clockent:SetNW2Int("ChangeTime",changetime) 
			clockent:SetNW2Int("ArrTime",Min) 
		end
	end
end)