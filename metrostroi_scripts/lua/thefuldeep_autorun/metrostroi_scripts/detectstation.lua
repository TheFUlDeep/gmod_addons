if CLIENT then return end
local mathabs = math.abs
local mathfloor = math.floor
local tableinsert = table.insert
local mathDistance = math.Distance
local tableCount = table.Count
--этот скрипт нельзя рестартить в рантайме, так как таблица заполняется хуком onentitycreated
--local TrackIDPath = {}

local function GetAnyValueFromTable2(tbl)
	for _,v in pairs(tbl) do
		return v
	end
end

local function UpgradeStationsPotitions()				--отцентровка точек телепорта для станций относительно ентити платформ
	local Platforms = {}
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
		--if not IsValid(Platform) then continue end
		if not Platform.StationIndex then continue end
		Platforms[Platform.StationIndex] = Platforms[Platform.StationIndex] or {}
		tableinsert(Platforms[Platform.StationIndex],Platform)
	end
	
	for k,v in pairs(Metrostroi.StationConfigurations or {}) do
		if not istable(v) or not tonumber(k) then continue end
		local StationPos
		
		if v.positions and istable(v.positions) and tableCount(v.positions) > 0 then--поиск точки телепортации
			StationPos = GetAnyValueFromTable2(v.positions)
			StationPos = istable(StationPos) and StationPos[1] and isvector(StationPos[1]) and StationPos[1]
		end
		if not StationPos then continue end
		
		local index = tonumber(k)
		if Platforms[index] and #Platforms[index] > 1 then
			local Centre
			for _,Platform in pairs(Platforms[index]) do
				local PlatformCentre = LerpVector(0.5, Platform.PlatformEnd, Platform.PlatformStart)
				Centre = Centre and LerpVector(0.5,Centre,PlatformCentre) or PlatformCentre
			end
			if Centre then
				Metrostroi.StationConfigurations[k].positions[1][1] = Centre
			end
		end
	end
	
end

local function UpgradePlatformEnt(ent)
	if not ent.PlatformStart or not ent.PlatformEnd or not ent.StationIndex or not ent.PlatformIndex then return end
	--тут определение трека, позиции на треке, установка треку номера пути
	local PlatformCentre = LerpVector(0.5, ent.PlatformEnd, ent.PlatformStart)
	
	ent.TrackNode = Metrostroi.GetPositionOnTrack(PlatformCentre)[1]
	ent.StartTrackNode = Metrostroi.GetPositionOnTrack(ent.PlatformStart)[1]
	ent.EndTrackNode = Metrostroi.GetPositionOnTrack(ent.PlatformEnd)[1]
	if not ent.TrackNode or not ent.StartTrackNode or not ent.EndTrackNode then return end
	
	--TrackIDPath[ent.TrackNode.path.id] = ent.PlatformIndex
	ent.TrackPos = ent.TrackNode.x
	ent.TrackID = ent.TrackNode.path.id
	ent.PlatformLen = ent.PlatformStart:DistToSqr(ent.PlatformEnd)
	ent.PlatformLenX = mathabs(ent.StartTrackNode.x - ent.EndTrackNode.x)
end



--[[timer.Simple(0,function()
	for _,ent in pairs(ents.FindByClass("gmod_track_platform")) do
		UpgradePlatformEnt(ent)
		-----------------------------DEBUG-------------------------------------------
		--print(math.sqrt(ent.PlatformLen))
		--local Track1 = Metrostroi.GetPositionOnTrack(ent.PlatformStart)
		--local Track2 = Metrostroi.GetPositionOnTrack(ent.PlatformEnd)
		--print("conver cof:",ent.PlatformStart:DistToSqr(ent.PlatformEnd)/mathabs(Track1[1].x - Track2[1].x))
		-----------------------------------------------------------------------------
	end
	UpgradeStationsPotitions()	
end)]]

hook.Add("OnEntityCreated","Save platforms for detectstation",function(ent)
	timer.Simple(2,function()
		if not IsValid(ent) or ent:GetClass() ~= "gmod_track_platform" then return end
		UpgradePlatformEnt(ent)
		UpgradeStationsPotitions()
	end)
end)

--[[hook.Add("PlayerInitialSpawn","DetectstationInitialize",function()
	timer.Simple(5,function()
		for _,ent in pairs(ents.FindByClass("gmod_track_platform")) do
			UpgradePlatformEnt(ent)
		end
		UpgradeStationsPotitions()
	end)
end)]]

local function GetAnyValueFromTable(tbl) --эту функцию можно заменить на получение имени станции на нужном языке
	for _,v in pairs(tbl) do
		return tostring(v)
	end
end

local function GetStationNameByIndex(index)
	if not Metrostroi or not Metrostroi.StationConfigurations then return end
	local StationName
	for k,v in pairs(Metrostroi.StationConfigurations) do
		local CurIndex = tonumber(k)
		if not CurIndex or not istable(v) or not v.names or not istable(v.names) or tableCount(v.names) < 1 then StationName = k else StationName = GetAnyValueFromTable(v.names) end
		if CurIndex == index then return StationName end
	end
	return
end

local function GetStationNameByPlatform(platform)
	return GetStationNameByIndex(platform.StationIndex)
end

local function GetPlatformLen(platform)
	return platform and platform.PlatformLen
end

local function GetHalfPlatformLen(platform)
	return platform and platform.PlatformLen/2
end

local function GetPlatformByIndex(index)
	if not index or not tonumber(index) then return end
	index = tonumber(index)
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do 
		if Platform.TrackPos and Platform.StationIndex == index then return Platform end
	end
end

local function SecondMethod(vector)
	if not Metrostroi or not Metrostroi.StationConfigurations then return end
	local NearestStation,MinDist,NotInRadius
	local hLimit = 300
	local Radius = 1700*1700
	for k,v in pairs(Metrostroi.StationConfigurations) do						--поиск ближайшей станции в плоскости и в ограниченной высоте
		if not istable(v) then continue end
		local StationPos,StationName
		
		if v.positions and istable(v.positions) and tableCount(v.positions) > 0 then--поиск точки телепортации
			StationPos = GetAnyValueFromTable2(v.positions)
			StationPos = istable(StationPos) and StationPos[1] and isvector(StationPos[1]) and StationPos[1]
		end
		if not StationPos then continue end
		
		StationName = v.names and istable(v.names) and tableCount(v.names) > 0 and GetAnyValueFromTable(v.names)--поиск имени
		if not StationName then continue end
		
		local dist = mathDistance(vector.x,vector.y,StationPos.x,StationPos.y)^2
		if (not MinDist or dist < MinDist) and mathabs(vector.z - StationPos.z) < hLimit and dist < (GetHalfPlatformLen(GetPlatformByIndex(k)) or Radius) then 
			MinDist = dist 
			NearestStation = StationName 
			--NotInRadius = dist > Radius 
		end
	end
	return NearestStation
	--return NearestStation and tostring(NearestStation)..(NotInRadius and " (ближайшая в плоскости)" or "")
end

local function GetNearestTrack(track)
end

local function detectstation(vec,try)
	local StationPosx,Station2Posx,Station,Station2,Path,Posx,nodecur,node1,node2

	local Track = Metrostroi.GetPositionOnTrack(vec)
	
	if Track[1] then
		nodecur = Track[1]
	
		local TrackID = Track[1].path.id
		
		--Path = TrackIDPath[TrackID]

		Posx = Track[1].x

		--сначала определение по платформам (по треку)
		local NearestPlatform1,NearestPlatform1Dist,NearestPlatform2,NotOnPlatform
		for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(Platform) or Platform.TrackID ~= TrackID --[[or Path ~= Platform.PlatformIndex]]then continue end--возможно проверка по TrackID не нужна, так как уже есть проверка по пути, но оставлю на всякий случай
			Path = Path or Platform.PlatformIndex
			
			local CurDist = mathabs(Posx - Platform.TrackPos)
			if not NearestPlatform1Dist or NearestPlatform1Dist > CurDist then 
				--NearestPlatform2 = NearestPlatform1
				NearestPlatform1Dist = CurDist 
				NearestPlatform1 = Platform
				
				--определяю, в пределах платформы ли vec
				NotOnPlatform = mathabs(Platform.TrackPos - Posx) > Platform.PlatformLenX/2 + 10-- +10 метров на всякий случай
			end
		end
		
		if NearestPlatform1 then
			StationPosx = NearestPlatform1.TrackPos
			node1 = NearestPlatform1.TrackNode
			Station = GetStationNameByPlatform(NearestPlatform1) or NearestPlatform1.StationIndex
			Station = Station and NotOnPlatform and Station.." (ближайшая по треку)" or Station
			
			local NearestPlatform1Dist
			for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do	--ищу вторую платформу по дальности от vec с противоположной стороны
				--if not IsValid(Platform) then continue end
				if not Platform.TrackPos or Platform == NearestPlatform1 or Platform.TrackID ~= TrackID --[[or Path ~= Platform.PlatformIndex]] or not Platform.StationIndex or StationPosx > Posx and Platform.TrackPos > Posx or StationPosx < Posx and Platform.TrackPos < Posx then continue end--возможно проверка по TrackID не нужна, так как уже есть проверка по пути, но оставлю на всякий случай   --если вторая станция c той же стороны, что и первая, до очистить вторую станцию
				
				local CurDist = mathabs(Posx - Platform.TrackPos)
				if not NearestPlatform1Dist or NearestPlatform1Dist > CurDist then 
					NearestPlatform2 = Platform
					NearestPlatform1Dist = CurDist 
				end
			end
			
			if NearestPlatform2 then
				Station2 = GetStationNameByPlatform(NearestPlatform2) or NearestPlatform2.StationIndex
				Station2Posx = NearestPlatform2.TrackPos
				node2 = NearestPlatform2.TrackNode
			end
		end
	end

	if not Station and not try then Station,Station2,Path,StationPosx,Station2Posx,Posx = detectstation(vec+Vector(0,0,200),true) end --если не нашел, то пробую найти чуть выше
	
	--потом определение по ближайшей в плоскости точке телепортации
	Station = not Station and SecondMethod(vec) or Station
	

	return Station or "", Station2,Path,StationPosx,Station2Posx,Posx,nodecur,node1,node2
end

THEFULDEEP = THEFULDEEP or {}
THEFULDEEP.DETECTSTATION = detectstation
--[[timer.Create("Debug detectstation",1,0,function()
	for _,ply in pairs(player.GetHumans()) do
		print(detectstation(ply:GetEyeTraceNoCursor().HitPos+vector_origin))
	end
end)]]
--timer.Remove("Debug detectstation")