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

local function DetectStationForClock(clockent)
	local nearestplatform,mindist,isplatformstart
	local clockpos = clockent:GetPos()
	for _,platform in pairs(ents.FindByClass("gmod_track_platform")) do
		for i = 1,2 do
			local point = i == 1 and platform.PlatformStart or platform.PlatformEnd
			if point.z > clockpos.z then 
				if point.z - clockpos.z > 100 then continue end --если платформа выше часов больше чем на 100, то мне это не надо
			else
				if clockpos.z - point.z > 600 then continue end--если платформа ниже часов больше чем на 600, то мне это не надо
			end
			local curdist = clockpos:DistToSqr(point)
			if not mindist or curdist < mindist then
				mindist = curdist
				nearestplatform = platform
				isplatformstart = i == 1
			end
		end
	end
	
	if not nearestplatform then return end
	clockent.TrackNode = Metrostroi.GetPositionOnTrack(isplatformstart and nearestplatform.PlatformStart or nearestplatform.PlatformEnd)[1]
	clockent.StationIndex = nearestplatform.StationIndex
end

hook.Add("OnEntityCreated","Spawn clocks_arrive",function(v)
	timer.Simple(3,function()
		if not IsValid(v) then return end
		local entclass = v:GetClass()
		if entclass == "gmod_track_clock_interval" then
			local ent = ents.Create("gmod_metrostroi_clock_arrive")
			if not IsValid(ent) then print("CANT SPAWN CLOCKS") return end
			ent:SetPos(v:GetPos() - Vector(0,0,v:OBBMaxs().z * 2))
			ent:SetAngles(v:GetAngles())
			ent:SetModel(v:GetModel())
			ent:Spawn()
			DetectStationForClock(ent)
			
		--добавил это в хук, чтобты при спавне новых платформ часы переопределяли свое местоположение
		--(а то вдруг какие-то платформы заспавнятся позже)
		elseif entclass == "gmod_track_platform" then
			for _,clockent in pairs(ents.FindByClass("gmod_track_clock_interval")) do DetectStationForClock(clockent) end
		end
	end)
end)

--for _,ent in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do ent:Remove() end
--SpawnClocks()

timer.Create("Update ArriveClocks",5,0,function()
	if not THEFULDEEP or not THEFULDEEP.GETSERVERINFOGLOBAL then return end
	THEFULDEEP.GETSERVERINFOGLOBAL()
	local changetime = os.time()
	for _,clockent in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
		if not IsValid(clockent) or not clockent.TrackNode then continue end
		local ArrTimes = {}
		for _,v1 in pairs(THEFULDEEP.SERVERINFO or {}) do
			if not istable(v1) or not v1.Map or v1.Map ~= THEFULDEEP.MAP or not v1.Trains then continue end
			for _,train in pairs(v1.Trains) do
				if not train.Direction or train.Direction == 0 or not train.PosVector --[[or not train.Speed or train.Speed < 5]] then continue end
					
				train.TrackNode = train.TrackNode or Metrostroi.GetPositionOnTrack(train.PosVector)[1]
					
				if not train.TrackNode or train.TrackNode.path.id ~= clockent.TrackNode.path.id then continue end
					
				local dir = train.Direction < 0
				local clockpos = clockent.TrackNode.x
				local trainposx = train.TrackNode.x
				
				--эта проверка, чтобы при близком подъезде к часам не появлялись постоянно 2-1 секунды
				--if math.abs(clockpos-trainposx) < 20 then continue end
					
				--если состав движется в сторону часов (в независимости от расстояния, но по тому же треку, на котором стоят часы)
				if (dir and clockpos < trainposx) or (not dir and clockpos > trainposx) then
				
					--время надо считать от минимального ноуда к максимальному, поэтмоу вот так
					arrtime = clockpos < trainposx and Metrostroi.GetTravelTime(clockent.TrackNode.node1,train.TrackNode.node1) or Metrostroi.GetTravelTime(train.TrackNode.node1,clockent.TrackNode.node1)
						
					--если на пути от паравоза до часов есть еще станции , то прибавить ко времени 30 сек на каждую станцию
					local realtrainposx = trainposx
					if trainposx < clockpos then trainposx,clockpos = clockpos,trainposx end--так trainposx всегда будет >= clockpos. Это для упрощения дальнейшего сравнения
					local additional_time = 0--дополнительное время за промежуточные станции
					--поиск промежуточных станций по часам (legacy)
					--[[
					for _,clock2 in pairs(ents.FindByClass("gmod_metrostroi_clock_arrive")) do
						if clock2 == clockent or not IsValid(clock2) or not clock2.TrackNode or clock2.TrackNode.path.id ~= clockent.TrackNode.path.id then continue end
						local posx = clock2.TrackNode.x
						if posx > clockpos and posx < trainposx then additional_time = additional_time + 30 end
					end
					]]
					
					--поиск промежуточных станций по платформам
					for _,pltfrm in pairs(ents.FindByClass("gmod_track_platform")) do
						--если есть TrackID, значит есть и StartTrackNode и EndTrackNode
						if not IsValid(pltfrm) or pltfrm.TrackID ~= clockent.TrackNode.path.id then continue end
						
						--следующая проверка вместо проверки на 90й строке (если состав в пределах станции (+10 метров на всяк случай))
						if pltfrm.StationIndex == clockent.StationIndex and math.abs(realtrainposx - pltfrm.TrackPos) < pltfrm.PlatformLenX/2 + 10 then additional_time = 100500 break else continue end
						
						local startx = pltfrm.StartTrackNode.x
						local endx = pltfrm.EndTrackNode.x
						if (startx > clockpos or endx > clockpos) and (startx < trainposx or endx < trainposx) then additional_time = additional_time + 30 end
					end
						
					local arrtime = math.floor(arrtime) + additional_time
					table.insert(ArrTimes,arrtime)
				end
				--local start = string.sub(train.Position,1,15):find("перегон ") and string.find(train.Position," - ",1,true) or nil
				--if not start then continue end
				--if string.sub(train.Position,start + 3) == clockent.Station then
					--table.insert(ArrTimes,1,train.ArrTime)
				--end
			end
		end
		if #ArrTimes < 1 then
			clockent:SetNW2Int("ChangeTime",changetime)
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