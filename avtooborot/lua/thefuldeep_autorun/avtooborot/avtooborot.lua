--[[============================= АВТООБОРОТ ==========================]]
 
if SERVER then 
	local AvtooborotTBL = {} --основная таблица, в которой хранятся триггеры и вся нужная инфа
	local AvtooborotStatus = -1
	util.AddNetworkString("Avtooborot")
	local function SendAvtooborot()
		net.Start("Avtooborot")
			net.WriteInt(AvtooborotStatus,2) -- -2,-1,0,1	
			local str = ""
			for StationIndex,Tbl in pairs(AvtooborotTBL) do
				if not istable(Tbl) then continue end
				if Tbl.StationName and Tbl.Type then 
					str = str.."\n"..Tbl.StationName..": "..((not Tbl.Type or Tbl.Type == "none" and "выключен") or Tbl.Type == "near" and Tbl.Near and "по ближнему пути" or Tbl.Type == "far" and Tbl.Far and "по дальнему пути" or Tbl.Type == "all" and Tbl.Far and Tbl.Near and "по двум путям" or ((Tbl.Far or Tbl.Near) and "по одному пути") or "выключен")
				end
			end
			local DataToSend = util.Compress(str)
			local DataToSendN = #DataToSend
			net.WriteUInt(DataToSendN,32)
			net.WriteData(DataToSend,DataToSendN)
		net.Broadcast()
	end
	
	local TriggerCreated
	
	local function createTrigger(name, StationIndex, pos, dbg)
		local ent = ents.Create( "avtooborot" )
		ent.name = name
		ent:SetPos(pos)
		ent:UseTriggerBounds(true)
		ent:Spawn()
		TriggerCreated = true
		
		if not AvtooborotTBL[StationIndex] then AvtooborotTBL[StationIndex] = {} end
		if not AvtooborotTBL[StationIndex][name] then AvtooborotTBL[StationIndex][name] = {} end
		table.insert(AvtooborotTBL[StationIndex][name],table.Count(AvtooborotTBL[StationIndex][name])+1,ent)		--триггеры хранятся в таблице с именем триггера (там может быть сколько угодно этих триггеров)

		if dbg then
			local scale = 0.1
			local button = ents.Create( "gmod_button" )
			button:SetModel( "models/metrostroi_train/81-717.6/6000.mdl" )
			button:SetCollisionGroup( COLLISION_GROUP_WORLD )
			button:SetPersistent( true )
			button:SetPos(ent:GetPos() )
			button:SetModelScale(scale)
			button:Spawn()
			local button = ents.Create( "gmod_button" )
			button:SetModel( "models/metrostroi_train/81-717.6/6000.mdl" )
			button:SetCollisionGroup( COLLISION_GROUP_WORLD )
			button:SetPersistent( true )
			button:SetPos(ent:GetPos() )
			button:SetAngles(Angle(0,90,0))
			button:SetModelScale(scale)
			button:Spawn()
			local button = ents.Create( "gmod_button" )
			button:SetModel( "models/metrostroi_train/81-717.6/6000.mdl" )
			button:SetCollisionGroup( COLLISION_GROUP_WORLD )
			button:SetPersistent( true )
			button:SetPos(ent:GetPos() )
			button:SetAngles(Angle(90,0,0))
			button:SetModelScale(scale)
			button:Spawn()
		end
		
		AvtooborotStatus = 1
		
	end
	
	local function deleteavtooborot()	--полное удаление триггеров и очистка таблицы автооборота
		AvtooborotStatus = -1
		SendAvtooborot()
		for k,v in pairs(ents.FindByClass("avtooborot")) do v:Remove() end 
		for k,v in pairs(ents.FindByClass("gmod_button")) do if v:GetModel() == "models/metrostroi_train/81-717.6/6000.mdl" then v:Remove() end end
		AvtooborotTBL = {}
		print("Avtooborot deleted")
	end

	local function createavtooborot()		-- эта функция создает нужные триггеры (может еще какие-то таблицы)
		local Map = game.GetMap()--так как  функция вызывается в начале Think'a, то карта всегда будет определена верно
		local dbg = true
		if Map:find("surfacemetro") then
			local station = "100"
		
			createTrigger("Station",station,Vector(-15507, 7509 + 500, 171),dbg)
			createTrigger("Station",station,Vector(-15507, 7509, 171),dbg)
			--createTrigger("Station",100,Vector(-15507, 7509 - 1000, 171),dbg)
			
			createTrigger("Near",station,Vector(-8094, 4124, 182),dbg)
			createTrigger("Near",station,Vector(-8094, 4124 - 200, 182),dbg)
			createTrigger("Near",station,Vector(-8094, 4124 - 1900, 182),dbg)
			createTrigger("Near",station,Vector(-8094, 4124 - 1900*2, 182),dbg)
			createTrigger("Near",station,Vector(-8094, 4124 - 1900*3, 182),dbg)
			createTrigger("Near",station,Vector(-8094, 4124 - 1900*4, 182),dbg)
			
			createTrigger("Far",station,Vector(-8094 + 250, 4124, 182),dbg)
			createTrigger("Far",station,Vector(-8094 + 250, 4124 - 200, 182),dbg)
			createTrigger("Far",station,Vector(-8094 + 250, 4124 - 1900*1, 182),dbg)
			createTrigger("Far",station,Vector(-8094 + 250, 4124 - 1900*2, 182),dbg)
			createTrigger("Far",station,Vector(-8094 + 250, 4124 - 1900*3, 182),dbg)
			createTrigger("Far",station,Vector(-8094 + 250, 4124 - 1900*4, 182),dbg)
			
			
			createTrigger("EndStart",station,Vector(-8094 + 250, 4124 + 2200, 182),dbg)
			createTrigger("EndEnd",station,Vector(-8094 + 250, 4124 + 2200 + 200, 182),dbg)
			
			createTrigger("EndStart",station,Vector(-8094, 4124 + 2200, 182),dbg)		--если будешь вызжать из тупика в неправильном направлении, состав очистится из тупика
			createTrigger("EndEnd",station,Vector(-8094, 4124 + 2200 + 200, 182),dbg)
			
			createTrigger("EndStart",station,Vector(-15507, 7509 - 4000, 171),dbg)
			createTrigger("EndEnd",station,Vector(-15507, 7509 - 4000 - 200, 171),dbg)
			
			AvtooborotTBL[station].RouteToFar = "SV1-4"
			AvtooborotTBL[station].RouteToNear = "SV1-3"
			AvtooborotTBL[station].RouteFromFar = "SV4-2"
			AvtooborotTBL[station].RouteFromNear = "SV3-2"
			
			AvtooborotTBL[station].Type = "all"
			
			AvtooborotTBL[station].StationName = "Советская"
			
			station = "106"
			local h = -2470
			
			createTrigger("Station",station,Vector(6583, 1187 + 1960, h),dbg)
			createTrigger("Station",station,Vector(6583, 1187, h),dbg)
			
			createTrigger("NearDead",station,Vector(6583 + 50, 1187 + 4640, h),dbg)
			createTrigger("NearDead",station,Vector(6583 + 50, 1187 + 4640 + 200, h),dbg)
			createTrigger("NearDead",station,Vector(6583 + 50, 1187 + 4640 + 200 + 1900*1, h),dbg)
			createTrigger("NearDead",station,Vector(6583 + 50, 1187 + 4640 + 200 + 1900*2, h),dbg)
			createTrigger("NearDead",station,Vector(6583 + 50, 1187 + 4640 + 200 + 1900*3, h),dbg)
			
			createTrigger("FarDead",station,Vector(6583 - 710, 1187 + 4640, h),dbg)
			createTrigger("FarDead",station,Vector(6583 - 710, 1187 + 4640 + 200, h),dbg)
			createTrigger("FarDead",station,Vector(6583 - 710, 1187 + 4640 + 200 + 1900*1, h),dbg)
			createTrigger("FarDead",station,Vector(6583 - 710, 1187 + 4640 + 200 + 1900*2, h),dbg)
			createTrigger("FarDead",station,Vector(6583 - 710, 1187 + 4640 + 200 + 1900*3, h),dbg)
			
			createTrigger("EndStart",station,Vector(6583 - 720, 1187 + 2500, h),dbg)	--в правильом
			createTrigger("EndEnd",station,Vector(6583 - 720, 1187 + 2500 - 200, h),dbg)
			
			createTrigger("EndStart",station,Vector(6583, 1187 + 2500, h),dbg)	--в неправильом
			createTrigger("EndEnd",station,Vector(6583, 1187 + 2500 - 200, h),dbg)
			
			createTrigger("EndStart",station,Vector(6583, 1187 - 3500, h),dbg)
			createTrigger("EndEnd",station,Vector(6583, 1187 - 3500 - 200, h),dbg)
			
			createTrigger("Near",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1, h),dbg)
			createTrigger("Near",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1 + 200, h),dbg)
			createTrigger("Near",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*1, h),dbg)
			createTrigger("Near",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2, h),dbg)
			
			createTrigger("Far",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1, h),dbg)
			createTrigger("Far",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1 + 200, h),dbg)
			createTrigger("Far",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*1, h),dbg)
			createTrigger("Far",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2, h),dbg)
			
			createTrigger("EndStart",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2 + 800, h),dbg)
			createTrigger("EndEnd",station,Vector(6583 - 190, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2 + 800 + 200, h),dbg)
			
			createTrigger("EndStart",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2 + 800, h),dbg)
			createTrigger("EndEnd",station,Vector(6583 - 450, 1187 + 4640 + 200 + 1900*1 + 200 + 1900*2 + 800 + 200, h),dbg)
			
			AvtooborotTBL[station].RouteToFar = "AK2-3"
			AvtooborotTBL[station].RouteToNear = "AK2-4"
			AvtooborotTBL[station].RouteFromFar = "AK3-1"
			AvtooborotTBL[station].RouteFromNear = "AK4-1"
			AvtooborotTBL[station].RouteFromNearDead = "AKE-2"
			AvtooborotTBL[station].RouteFromFarDead = "AKG-1"
			
			AvtooborotTBL[station].StationName = "Улица А. Кляйнера"
			
			AvtooborotTBL[station].Type = "near"
			
			
			station = "105"
			AvtooborotTBL[station] = {}
			AvtooborotTBL[station].StationName = "Куровская"
			AvtooborotTBL[station].Type = "none"
			
			createTrigger("Station",station,Vector(3269, 3247 + 870, -1710),dbg)
			createTrigger("Station",station,Vector(3269, 3247, -1710),dbg)
			
			createTrigger("EndStart",station,Vector(3269 - 560, 3247 + 1800, -1710),dbg)
			createTrigger("EndEnd",station,Vector(3269 - 580, 3247 + 1800 - 200, -1710),dbg)
			
			createTrigger("EndStart",station,Vector(3269, 3247 + 1800, -1710),dbg)
			createTrigger("EndEnd",station,Vector(3269, 3247 + 1800 - 200, -1710),dbg)
			
			createTrigger("EndStart",station,Vector(-745 + 200, 12522 - 270, -1696),dbg)
			createTrigger("EndEnd",station,Vector(-745, 12522 - 270, -1696),dbg)
			
			createTrigger("EndStart",station,Vector(3269, 3247 - 4000, -1710),dbg)
			createTrigger("EndEnd",station,Vector(3269, 3247 - 4000 - 200, -1710),dbg)
			
			createTrigger("EndStart",station,Vector(3269 + 350, 3247 + 1200, -1710),dbg)
			createTrigger("EndEnd",station,Vector(3269 + 350, 3247 + 1200 - 200, -1710),dbg)
			
			createTrigger("EndStart",station,Vector(3269, 3247 + 5570 - 200, -1710),dbg)
			createTrigger("EndEnd",station,Vector(3269, 3247 + 5570 + 200 - 200, -1710),dbg)
			
			--createTrigger("Near",station,Vector(3269, 3247 + 5570, -1710),dbg)
			--createTrigger("Near",station,Vector(3269, 3247 + 7000, -1710),dbg)
			--createTrigger("Near",station,Vector(3269 - 1500, 3247 + 9000, -1650),dbg)
			
			createTrigger("Far",station,Vector(3269 - 270, 3247 + 5570, -1710),dbg)
			createTrigger("Far",station,Vector(3269 - 700, 3247 + 7000, -1710),dbg)
			createTrigger("Far",station,Vector(3269 - 1500, 3247 + 8000, -1710),dbg)
			
			--createTrigger("FarDead",station,Vector(3269 + 350, 3247 + 870, -1710),dbg)
			--createTrigger("FarDead",station,Vector(3269 + 350, 3247, -1710),dbg)
			
			AvtooborotTBL[station].RouteToFar = "KR2-3"
			AvtooborotTBL[station].RouteFromFar = "KR1-1"
			--AvtooborotTBL[station].RouteFromFarDead = "KR3-1"
			
			
			station = "102"
			AvtooborotTBL[station] = {}
			AvtooborotTBL[station].StationName = "Антиколлаборанистическая"
			AvtooborotTBL[station].Type = "none"
			
			createTrigger("Station",station,Vector(15578, -1302-50, -430),dbg)
			createTrigger("Station",station,Vector(15578, -1302+1000, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578+270, -1302-700, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578+270, -1302-700+200, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578, -1302-550, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578, -1302-550+200, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578, -1302+4500, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578, -1302+4500+200, -430),dbg)
			
			createTrigger("Near",station,Vector(15578, -1302-6200, -430),dbg)
			createTrigger("Near",station,Vector(15578, -1302-6200-200, -430),dbg)
			createTrigger("Near",station,Vector(15578, -1302-6200-200-1900*0.6, -430),dbg)
			createTrigger("Near",station,Vector(15578, -1302-6200-200-1900*1.4, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578-260, -1302-6200, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578-260, -1302-6200-200, -430),dbg)
			
			AvtooborotTBL[station].RouteToNear = "KB2-3"
			AvtooborotTBL[station].RouteFromNear = "KBA-1"
			
			
		end
		
		if TriggerCreated then print("Avtooborot created") end
		SendAvtooborot()
		--PrintTable(AvtooborotTBL)
	end
	
	local function FindAndClearEntInTriggers(ent,exceptionsTbl,exceptionName)
		for StationIndex,Tbl1 in pairs(AvtooborotTBL) do
			if not istable(Tbl1) then continue end
			for name,Tbl in pairs(Tbl1) do
				if exceptionName and exceptionName == name then continue end
				if not istable(Tbl) then continue end
				for n,Tent in ipairs(Tbl) do
					if not IsEntity(Tent) --[[or Tent.occupied]] then continue end
					if exceptionsTbl and istable(exceptionsTbl) then
						local exception
						for i,Tent1 in ipairs(exceptionsTbl) do
							if Tent1 == Tent then exception = true break end
						end
						if exception then continue end
					end
					for i,ent1 in ipairs(Tent.ents) do
						if ent1 == ent then Tent.ents[i] = nil Tbl1["OpenedFrom"..name] = false end
					end
				end
			end
		end
	end
	
	local function NotIfEntInOnlyOneTable(ent)
		for StationIndex,Tbl1 in pairs(AvtooborotTBL) do
			if not istable(Tbl1) then continue end
			local LastName
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				LastName = name
				for n,Tent in ipairs(Tbl) do
					if not IsEntity(Tent) then continue end
					if Tent.ents and istable(Tent.ents) then
						for i,ent1 in ipairs(Tent.ents) do
							if ent1 == ent then
								if LastName and LastName ~= name then
									return true 
								else
									LastName = name
								end
							end
						end
					end
				end
			end
		end
	end
	
	local function IfTrainInOnlyOneTable(trainTbl)
		for k,v in pairs(trainTbl) do
			if NotIfEntInOnlyOneTable(v) then return false end
		end
		return true
	end
	
	local function GetMaxIndexFromTables(tbl)
		local Result,Cur
		for k,v in pairs(tbl) do
			if not istable(v) then continue end
			Cur = #v
			if not Result or Cur > Result then Result = Cur end
		end
		return Result or 0
	end
	
	local function TableInsert(tbl,value)
		for k,v in pairs(tbl) do
			if v == value then return end
		end
		table.insert(tbl,1,value)
	end
	
	local function GetEntsFomTriggers(TriggersTbl)
		local OutputTbl = {}
		if TriggersTbl then
			for k,trig in ipairs(TriggersTbl) do
				--if not IsEntity(trig) then continue end --наверное не нужно
				if trig.ents then
					for k1,wag in ipairs(trig.ents) do
						TableInsert(OutputTbl,wag)
					end
				end
				
				if trig.occupied then
					TableInsert(OutputTbl,trig.occupied)
				end
			end
		end
		return OutputTbl
	end
	
	local function OneOfTriggersOccupied(TriggersTbl)
		for k,trig in ipairs(TriggersTbl) do
			if k == 1 then continue end
			if trig.occupied then return true end
		end
	end
	
	local function FindInTable(tbl,value)
		if not tbl or not istable(tbl) then return end
		for k,v in pairs(tbl) do
			if v == value then return true end
		end
	end
	
	
	function UpdateAvtooborot()	-- эта функция вызывается при сработке триггера
		--ДЛЯ СПРАВКИ
		--первый триггер рейки - у светофора, второй - у рейки
		--первый триггер тупика - у светофора, остальные разброшены по длине всего тупика
		--триггеры TEndStart - начало очистки, TEndEnd - конец очистки
		
		if AvtooborotStatus < 1 then return end
		
		for StationIndex,Tbl1 in pairs(AvtooborotTBL) do
			if not istable(Tbl1) then continue end
			if not Tbl1.Type or Tbl1.Type == "none" then Tbl1.Type = "none" continue end
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				for n,Tent in ipairs(Tbl) do
					--проверяю недоступные паравозы и очищаю их
					if IsEntity(Tent) and Tent.ents then 
						for i,ent in ipairs(Tent.ents) do
							if not IsValid(ent) then Tent.ents[i] = nil Tbl1["OpenedFrom"..name] = nil end -- TODO тут можно добавить проверку на то, освободлись все триггеры, или не все. Если не все, то не обнулять OpenedFrom
						end
					end
				end
			end
			
			-- 1 - выезд из тупика в правильном направлении
			-- 2 - выезд из тупика в неправильном направлении
			if Tbl1.EndStart and #Tbl1.EndStart > 0 then
				for i = 1,#Tbl1.EndStart do
					if Tbl1.EndEnd[i].occupied and not Tbl1.EndStart[i].occupied then 
						for n,wag in ipairs(Tbl1.EndEnd[i].ents) do
							if FindInTable(Tbl1.EndStart[i].ents,wag) then
								FindAndClearEntInTriggers(wag--[[,{Tbl1.EndEnd[i]}]],nil,i == 2 and "Station") 
							end
						end
					end
				end
			end
			
			--если вагон появился в тупике, то удаляю его из всех триггеров, кроме тупика
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				if name:find("Far") or name:find("Near") then	
					for n,Tent in ipairs(Tbl) do
						if not IsEntity(Tent) then continue end
						if Tent.occupied then FindAndClearEntInTriggers(Tent.occupied,nil,name) end
					end	
				end
			end
			--[[ модифициорванный вариант блока выше
			--если вагон появился в тупике, то удаляю его из всех триггеров, кроме тупика
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				if name:find("Far") or name:find("Near") then	
					local NeedContinue
					for n,Tent in ipairs(Tbl) do
						if not IsEntity(Tent) then continue end
						if n == 1 and Tent.occupied then NeedContinue = true end
					end
					if NeedContinue then continue end
					for n,Tent in ipairs(Tbl) do
						if not IsEntity(Tent) then continue end
						if Tent.occupied then FindAndClearEntInTriggers(Tent.occupied,nil,name) end
					end	
				end
			end
			
			]]
			
			
			--открытие маршрута
			if Tbl1.Type == "all" then
				if Tbl1.FarDead and istable(Tbl1.FarDead) then
					local Wagons = GetEntsFomTriggers(Tbl1.FarDead)
					if #Wagons > 0 and not Tbl1.FarDead[1].occupied and OneOfTriggersOccupied(Tbl1.FarDead) and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromFarDead"] and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromFarDead"] = true
						ForAvtooborot(Tbl1["RouteFromFarDead"])
					end
				end
			end
			
			if Tbl1.Type == "all" or Tbl1.Type == "far" then
				if Tbl1.Far and istable(Tbl1.Far) then
					local Wagons = GetEntsFomTriggers(Tbl1.Far)
					if #Wagons > 0 and not Tbl1.Far[1].occupied and OneOfTriggersOccupied(Tbl1.Far) and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromFarDead"] and not Tbl1["OpenedFromStation"] and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromFar"] = true
						ForAvtooborot(Tbl1["RouteFromFar"])
					end
				end
			end
			
			if Tbl1.Type == "all" or Tbl1.Type == "near" then
				if Tbl1.Near and istable(Tbl1.Near) then
					local Wagons = GetEntsFomTriggers(Tbl1.Near)
					if #Wagons > 0 and not Tbl1.Near[1].occupied and OneOfTriggersOccupied(Tbl1.Near) and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromFarDead"] and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromStation"] and #GetEntsFomTriggers(Tbl1.Far) == 0 and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromNear"] = true
						ForAvtooborot(Tbl1["RouteFromNear"])
					end
				end
			end
			
			if Tbl1.Type == "all" then
				if Tbl1.NearDead and istable(Tbl1.NearDead) then
					local Wagons = GetEntsFomTriggers(Tbl1.NearDead)
					if #Wagons > 0 and not Tbl1.NearDead[1].occupied and OneOfTriggersOccupied(Tbl1.NearDead) and not Tbl1["OpenedFromNearDead"] and not Tbl1["OpenedFromStation"] and #GetEntsFomTriggers(Tbl1.Station) == 0 and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromNearDead"] = true
						ForAvtooborot(Tbl1["RouteFromNearDead"])
					end
				end
			end
			
			if Tbl1.Station and istable(Tbl1.Station) then
				local Wagons = GetEntsFomTriggers(Tbl1.Station)
				if #Wagons > 0 and not Tbl1.Station[1].occupied and OneOfTriggersOccupied(Tbl1.Station) and not Tbl1["OpenedFromNearDead"] and not Tbl1["OpenedFromStation"] and not Tbl1["OpenedFromNear"] and IfTrainInOnlyOneTable(Wagons) then
					if not Tbl1["OpenedFromFar"] and (Tbl1.Type == "all" or Tbl1.Type == "far") and #GetEntsFomTriggers(Tbl1.Far) == 0 and Tbl1.Far then
						Tbl1["OpenedFromStation"] = true
						ForAvtooborot(Tbl1["RouteToFar"])
					elseif (Tbl1.Type == "all" or Tbl1.Type == "near") and #GetEntsFomTriggers(Tbl1.Near) == 0 and Tbl1.Near then
						Tbl1["OpenedFromStation"] = true
						ForAvtooborot(Tbl1["RouteToNear"])
					end
				end
			end
			
		end
		
		--[[PrintTable(AvtooborotTBL)
		for k,v in pairs(AvtooborotTBL) do
			if not istable(v) then continue end
			for k1,v1 in pairs(v) do
				if not istable(v1) then continue end
				for k2,v2 in pairs(v1) do
					if not IsEntity(v2) then continue end
					PrintTable(v2.ents)
					print(v2.occupied)
				end
			end
		end]]
	end
	
	hook.Add("PlayerInitialSpawn","AvtooborotSpawn", function()-- отправление инфы об автообороте при спавне игрока
		SendAvtooborot()
	end)
	
	local function ClearTriggersEnts(TriggersTbl)
		for i,trig in ipairs(TriggersTbl) do
			if trig.ents then trig.ents = {} end
		end
	end
	
	hook.Add("PlayerSay","Avtooborot",function(ply,text)	--управление автоборотом. Делаю это через чат-триггер, потому что в ulx будет много кнопок и это будет некрасиво
		if text:sub(1,11) == "!avtooborot" then
			local Rank = ply:GetUserGroup()
			if Rank ~= "operator" and Rank ~= "admin" and Rank ~= "SuperVIP" and Rank ~= "superadmin" then return end
			local start = text:find(" ")
			if not start then 
				if AvtooborotStatus == 1 then 
					AvtooborotStatus = 0 
					SendAvtooborot() 
					ulx.fancyLogAdmin(ply,false,"#A выключил автооборот")
					return ""
				else 
					deleteavtooborot()
					createavtooborot() 
					ulx.fancyLogAdmin(ply,false,"#A включил автооборот")
					return ""
				end
			elseif AvtooborotStatus == 1 then
				local start2 = text:find(" ",start + 1)
				if not start2 then return end
				local StationIndex = text:sub(start + 1, start2 - 1)
				local start3 = text:find(" ",start2 + 1)
				local Type
				if not start3 then Type = text:sub(start2 + 1) else Type = text:sub(start2 + 1, start3 - 1) end
				if Type ~= "none" and Type ~= "near" and Type ~= "far" and Type ~= "all" then return end
				if AvtooborotTBL[StationIndex] and AvtooborotTBL[StationIndex].Type and AvtooborotTBL[StationIndex].Type ~= Type then
					if Type ~= "none" then
						if Type == "near" and not AvtooborotTBL[StationIndex].Near and AvtooborotTBL[StationIndex].Far then Type = "far"
						elseif Type == "far" and not AvtooborotTBL[StationIndex].Far and AvtooborotTBL[StationIndex].Near then Type = "near"
						elseif Type == "all" then
							if not AvtooborotTBL[StationIndex].Far and AvtooborotTBL[StationIndex].Near then Type = "near" 
							elseif not AvtooborotTBL[StationIndex].Near and AvtooborotTBL[StationIndex].Far then Type = "far" 
							else return
							end
						else return
						end
						--переспавн триггеров
						for name,Tbl in pairs(AvtooborotTBL[StationIndex]) do
							if not istable(Tbl) then
								if name:find("Opened") then AvtooborotTBL[StationIndex][name] = nil end
							else
								for i,trig in ipairs(Tbl) do
									--print(trig)
									if not IsEntity(trig) then continue end
									local ent = ents.Create( "avtooborot" )
									ent.name = trig.name
									ent:SetPos(trig:GetPos())
									ent:UseTriggerBounds(true)
									trig:Remove()
									ent:Spawn()
									AvtooborotTBL[StationIndex][name][i] = ent
								end
							end
						end
					end
					AvtooborotTBL[StationIndex].Type = Type 
					SendAvtooborot() 
				end
			end
		end
	end)
	
	for k,v in pairs(player.GetHumans()) do	--for debug
		if v:Nick():find("TheFulDeep") then print(v:GetPos()) end
	end
	
	deleteavtooborot()
	timer.Simple(2, function() createavtooborot() end)
	
end

if CLIENT then--отображение информации об автообороте
	local AvtooborotStatus = -1
	local stations = ""
	net.Receive( "Avtooborot", function()
		AvtooborotStatus = net.ReadInt(2)
		local Len = net.ReadUInt(32)
		stations = util.Decompress(net.ReadData(Len))
		print(stations)
	end)
	hook.Add( "HUDPaint", "AvtooborotStatus", function()
		if AvtooborotStatus < 0 then return end
		local text = "Автооборот: "..(AvtooborotStatus == 1 and "включен" or "выключен")
		text = AvtooborotStatus == 1 and text.."\n"..stations or text
		surface.SetFont("ChatFont")
		local w,h = surface.GetTextSize(text)
		draw.RoundedBox( 5, ScrW() - 20 - w - 4, ScrH()/2 - 100 - 3,w + 10,h + 5, Color(0, 0, 0, 150))
		draw.DrawText( text, "ChatFont", ScrW() - 20, ScrH()/2 - 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT)
	end)
end
