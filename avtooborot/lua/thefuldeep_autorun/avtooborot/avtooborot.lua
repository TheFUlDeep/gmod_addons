--[[============================= АВТООБОРОТ ==========================]]
 
if SERVER then 
	local Map
	local AvtooborotTBL = {} --основная таблица, в которой хранятся триггеры и вся нужная инфа
	local AvtooborotStatus = -1
	util.AddNetworkString("Avtooborot")
	local function SendAvtooborot()
		local i = 0
		for k,v in pairs(ents.FindByClass("avtooborot")) do
			i = i + 1
		end
		print("TriggersCount:",i)
		net.Start("Avtooborot")
			net.WriteInt(AvtooborotStatus,2) -- -2,-1,0,1	
			local str = ""
			for StationIndex,Tbl in pairs(AvtooborotTBL) do
				if not istable(Tbl) then continue end
				if Tbl.StationName and Tbl.Type then 
					str = str.."\n"..Tbl.StationName..": "..((not Tbl.Type or Tbl.Type == "none" and "выключен") or Tbl.Type == "near" and Tbl.Near and (Tbl.Far and "по ближнему пути" or "по одному пути") or Tbl.Type == "far" and Tbl.Far and (Tbl.Near and "по дальнему пути" or "по одному пути") or Tbl.Type == "all" and Tbl.Far and Tbl.Near and "по двум путям" or ((Tbl.Far or Tbl.Near) and "по одному пути") or "выключен")
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
		ent.dbg = dbg
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
		Map = game.GetMap()--так как  функция вызывается в начале Think'a, то карта всегда будет определена верно
		local dbg = nil
		local station
		if Map:find("surfacemetro") then
			station = "100"
		
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
			
			AvtooborotTBL[station].Type = "all"
			
			
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
			
			--createTrigger("Near",station,Vector(3269, 3247 + 5570, -1710),dbg)	--по этому пути нельзя обернуться
			--createTrigger("Near",station,Vector(3269, 3247 + 7000, -1710),dbg)
			--createTrigger("Near",station,Vector(3269 - 1500, 3247 + 9000, -1650),dbg)
			
			--AvtooborotTBL[station].Near = {} -- это число для того, чтобы можно было выбрать два пути
			
			createTrigger("Far",station,Vector(3269 - 270, 3247 + 5570, -1710),dbg)
			createTrigger("Far",station,Vector(3269 - 700, 3247 + 7000, -1710),dbg)
			createTrigger("Far",station,Vector(3269 - 1500, 3247 + 8000, -1710),dbg)
			
			--createTrigger("FarDead",station,Vector(3269 + 350, 3247 + 870, -1710),dbg) --TODO
			--createTrigger("FarDead",station,Vector(3269 + 350, 3247, -1710),dbg)
			
			AvtooborotTBL[station].RouteToFar = "KR2-3"
			AvtooborotTBL[station].RouteFromFar = "KR1531-1"
			--AvtooborotTBL[station].RouteFromFarDead = "KR3-1"
			
			
			station = "102"
			AvtooborotTBL[station] = {}
			AvtooborotTBL[station].StationName = "Антиколлаборанистическая"
			AvtooborotTBL[station].Type = "none"
			
			createTrigger("Station",station,Vector(15578, -1302-50, -430),dbg)
			createTrigger("Station",station,Vector(15578, -1302+1000, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578+270, -1302-50+4500, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578+270, -1302-50+4500+200, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578, -1302-550, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578, -1302-550+200, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578, -1302+4500, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578, -1302+4500+200, -430),dbg)
			
			createTrigger("Far",station,Vector(15578, -1302-6200, -430),dbg)
			createTrigger("Far",station,Vector(15578, -1302-6200-200, -430),dbg)
			createTrigger("Far",station,Vector(15578, -1302-6200-200-1900*0.6, -430),dbg)
			createTrigger("Far",station,Vector(15578, -1302-6200-200-1900*1.4, -430),dbg)
				
			AvtooborotTBL[station].Near = {}	--это чисто для того, чтобы можно было выбрать оборот по двум путям
			createTrigger("NearDead",station,Vector(15578+270, -1302-50, -430),dbg)
			createTrigger("NearDead",station,Vector(15578+270, -1302-50+200, -430),dbg)
			createTrigger("NearDead",station,Vector(15578+270, -1302-50+1500, -430),dbg)
			createTrigger("NearDead",station,Vector(15578+270, -1302-50+1500*2, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578-260, -1302-6200, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578-260, -1302-6200-200, -430),dbg)
			
			createTrigger("EndStart",station,Vector(15578+270, -1302-2800, -430),dbg)
			createTrigger("EndEnd",station,Vector(15578+270, -1302-2800-200, -430),dbg)
			
			createTrigger("FarDead",station,Vector(15578-5000, -1302-13660, -430),dbg) --не даст собрать мрашрут из тупика
			
			createTrigger("EndStart",station,Vector(15578-5000, -1302-13660, -430),dbg)--очистка на сякий случай
			createTrigger("EndEnd",station,Vector(15578-5000-200, -1302-13660, -430),dbg)
			
			AvtooborotTBL[station].RouteToFar = "KB2-3"
			AvtooborotTBL[station].RouteFromFar = "KBA-1"
			AvtooborotTBL[station].RouteFromNearDead = "KBD-2"
			
			
		elseif Map:find("gm_mustox_neocrimson_line_a") then
			station = "551"
			
			createTrigger("Station",station,Vector(-14105-100,5047,-1440),dbg)
			
			createTrigger("Far",station,Vector(-14122-10, -9735, -1450),dbg)
			createTrigger("Far",station,Vector(-14122-10, -9735-200, -1450),dbg)
			createTrigger("Far",station,Vector(-14122-10, -9735-200-1900*1, -1450),dbg)
			createTrigger("Far",station,Vector(-14122-10, -9735-200-1900*2, -1450),dbg)
			AvtooborotTBL[station].RouteFromFar = "BR1-1"
			
			AvtooborotTBL[station].StationName = "Братеево"
			AvtooborotTBL[station].Type = "all"
			
			createTrigger("EndStart",station,Vector(-14122-10, -9735+4500, -1450),dbg)
			createTrigger("EndEnd",station,Vector(-14122-10, -9735+4500+200, -1450),dbg)
			
			createTrigger("EndStart",station,Vector(-14122-620, -9735+4500, -1450),dbg)
			createTrigger("EndEnd",station,Vector(-14122-620, -9735+4500+200, -1450),dbg)
			
			createTrigger("Near",station,Vector(-14122-620, -9735+420, -1450),dbg)
			createTrigger("Near",station,Vector(-14122-620, -9735+420-200, -1450),dbg)
			createTrigger("Near",station,Vector(-14122-620, -9735+420-200-1900*1, -1450),dbg)
			createTrigger("Near",station,Vector(-14122-620, -9735+420-200-1900*2, -1450),dbg)
			createTrigger("Near",station,Vector(-14122-620, -9735+420-200-1900*3, -1450),dbg)
			AvtooborotTBL[station].RouteFromNear = "BR1-2"
			
			AvtooborotTBL[station].RouteToNear = "BR2-2"
			AvtooborotTBL[station].RouteToFar = "BR2-1"
			
			station = "557"
			
			createTrigger("Station",station,Vector(-1212+1000, -6270, -3940),dbg)
			createTrigger("Station",station,Vector(-1212, -6270, -3940),dbg)
			
			AvtooborotTBL[station].RouteToFar = "ST1-4"
			AvtooborotTBL[station].RouteToNear = "ST1-3"
			AvtooborotTBL[station].RouteFromNear = "ST3-2"
			AvtooborotTBL[station].RouteFromFar = "ST4-2"
			AvtooborotTBL[station].RouteFromFarDead = "STG-2"
			AvtooborotTBL[station].RouteFromNearDead = "STE-1"
			
			AvtooborotTBL[station].Type = "all"
			AvtooborotTBL[station].StationName = "Сталинская"
			
			createTrigger("EndStart",station,Vector(-1212+1150, -6270+1020, -3940),dbg)
			createTrigger("EndEnd",station,Vector(-1212+1150-200, -6270+1020, -3940),dbg)
			
			createTrigger("EndStart",station,Vector(-1212+1000, -6270, -3940),dbg)
			createTrigger("EndEnd",station,Vector(-1212+1000-200, -6270, -3940),dbg)
			
			createTrigger("EndStart",station,Vector(-1212-3500, -6270, -3940),dbg)
			createTrigger("EndEnd",station,Vector(-1212-3500-200, -6270, -3940),dbg)
			
			createTrigger("NearDead",station,Vector(-1212+3520, -6270, -3940),dbg)
			createTrigger("NearDead",station,Vector(-1212+3520+200, -6270, -3940),dbg)
			createTrigger("NearDead",station,Vector(-1212+3520+200+1900*1, -6270, -3940),dbg)
			createTrigger("NearDead",station,Vector(-1212+3520+200+1900*2, -6270, -3940),dbg)
			createTrigger("NearDead",station,Vector(-1212+3520+200+1900*3, -6270, -3940),dbg)
			createTrigger("NearDead",station,Vector(-1212+3520+200+1900*4, -6270, -3940),dbg)
			
			createTrigger("FarDead",station,Vector(-1212+3480, -6270+1020, -3940),dbg)
			createTrigger("FarDead",station,Vector(-1212+3480+200, -6270+1020, -3940),dbg)
			createTrigger("FarDead",station,Vector(-1212+3480+200+1900*1, -6270+1020, -3940),dbg)
			createTrigger("FarDead",station,Vector(-1212+3480+200+1900*2, -6270+1020, -3940),dbg)
			createTrigger("FarDead",station,Vector(-1212+3480+200+1900*3, -6270+1020, -3940),dbg)
			createTrigger("FarDead",station,Vector(-1212+3480+200+1900*4, -6270+1020, -3940),dbg)
			
			createTrigger("Near",station,Vector(-1212+4740+1900*1, -6270+380, -3940),dbg)
			createTrigger("Near",station,Vector(-1212+4740+1900*1+200, -6270+380, -3940),dbg)
			createTrigger("Near",station,Vector(-1212+4740+1900*1+200+1900*1, -6270+380, -3940),dbg)
			createTrigger("Near",station,Vector(-1212+4740+1900*1+200+1900*2, -6270+380, -3940),dbg)
			
			createTrigger("Far",station,Vector(-1212+4740+1900*1, -6270+650, -3940),dbg)
			createTrigger("Far",station,Vector(-1212+4740+1900*1+200, -6270+650, -3940),dbg)
			createTrigger("Far",station,Vector(-1212+4740+1900*1+200+1900*1, -6270+650, -3940),dbg)
			createTrigger("Far",station,Vector(-1212+4740+1900*1+200+1900*2, -6270+650, -3940),dbg)
			
			
			station = "556"
			
			createTrigger("Station",station,Vector(-1085+960, -14422, -3530),dbg)
			createTrigger("Station",station,Vector(-1085, -14422, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085+2050, -14422+760, -3530),dbg)
			createTrigger("EndEnd",station,Vector(-1085+2050-200, -14422+760, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085+2050, -14422, -3530),dbg)
			createTrigger("EndEnd",station,Vector(-1085+2050-200, -14422, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085+4300, -14422, -3530),dbg)
			createTrigger("EndEnd",station,Vector(-1085+4300+200, -14422, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085-3700, -14422, -3530),dbg)
			createTrigger("EndEnd",station,Vector(-1085-3700-200, -14422, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085, -14422+760, -3530),dbg)	--для заезда в неправильном со включеным автооборотом
			createTrigger("EndEnd",station,Vector(-1085-200, -14422+760, -3530),dbg)
			
			createTrigger("EndStart",station,Vector(-1085-1500, -14422+760, -3530),dbg)--для заезда в неправильном со включеным автооборотом
			createTrigger("EndEnd",station,Vector(-1085-1500-200, -14422+760, -3530),dbg)
			
			createTrigger("Near",station,Vector(-1085+5000, -14422+370, -3530),dbg)
			createTrigger("Near",station,Vector(-1085+5000+200, -14422+370, -3530),dbg)
			createTrigger("Near",station,Vector(-1085+5000+200+1900*1, -14422+370, -3530),dbg)
			createTrigger("Near",station,Vector(-1085+5000+200+1900*2, -14422+370, -3530),dbg)
			
			--TODO смотреть занятость перегона при открытии маршрута из тупика
			
			AvtooborotTBL[station].Type = "none"
			AvtooborotTBL[station].StationName = "Фауна"
			AvtooborotTBL[station].RouteToNear = "FN1-3"
			AvtooborotTBL[station].RouteFromNear = "FN3-2"
			
			station = "552"
			
			createTrigger("Near",station,Vector(11790+20, -3970-760, -1450),dbg)
			createTrigger("Near",station,Vector(11790+20, -3970-760+200, -1450),dbg)
			createTrigger("Near",station,Vector(11790+20, -3970-760+200+1900*1, -1450),dbg)
			createTrigger("Near",station,Vector(11790+20, -3970-760+200+1900*2, -1450),dbg)
			
			createTrigger("EndStart",station,Vector(11790+20, -3970-760+200+1900*2+600, -1450),dbg)
			createTrigger("EndEnd",station,Vector(11790+20, -3970-760+200+1900*2+600+200, -1450),dbg)
			
			createTrigger("EndStart",station,Vector(11790-270, -3970-3250, -1450),dbg)
			createTrigger("EndEnd",station,Vector(11790-290, -3970-3250-200, -1450),dbg)
			
			createTrigger("EndStart",station,Vector(11790-270, -3970-3250, -1450),dbg)
			createTrigger("EndEnd",station,Vector(11790-290, -3970-3250-200, -1450),dbg)
			
			createTrigger("EndStart",station,Vector(11790-3800, -3970-6700, -1450),dbg)
			createTrigger("EndEnd",station,Vector(11790-3800-200, -3970-6700, -1450),dbg)
			
			createTrigger("Station",station,Vector(11790-240, -3970-760+200+1900*1-1000, -1450),dbg)
			
			AvtooborotTBL[station].Type = "none"
			AvtooborotTBL[station].StationName = "Пионерская"
			AvtooborotTBL[station].RouteFromNear = "POD-1"
			
		end
		
		if TriggerCreated then print("Avtooborot created") end
		UpdateAvtooborot() --при установке автоооборота сразу аптейчу один раз
		SendAvtooborot()
		--PrintTable(AvtooborotTBL)
	end
	
	local function FindAndClearEntInTriggers(ent,exceptionsTbl,exceptionName,End)
		for StationIndex,Tbl1 in pairs(AvtooborotTBL) do
			if not istable(Tbl1) then continue end
			for name,Tbl in pairs(Tbl1) do
				if not End and (name == "EndStart" or name == "EndEnd") then continue end --игнорирую триггеры полной очистки только если это не сами триггеры
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
						if ent1 == ent then Tent.ents[i] = nil Tbl1["OpenedFrom"..name] = nil end
					end
				end
			end
		end
		--error("asd")
	end
	
	local function NotIfEntInOnlyOneTable(ent)
		for StationIndex,Tbl1 in pairs(AvtooborotTBL) do
			if not istable(Tbl1) then continue end
			local LastName
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				if name == "EndStart" or name == "EndEnd" then continue end --игнорирую триггеры полной очистки
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
	
	local function GetEntsFromTriggers(TriggersTbl)
		local OutputTbl = {}
		if TriggersTbl then
			for k,trig in ipairs(TriggersTbl) do
				--if not IsEntity(trig) then continue end --наверное не нужно
				if trig.ents then
					for k1,wag in ipairs(trig.ents) do
						if not IsValid(wag) then continue end --почему-то без проверки IsValid работает некорректно
						TableInsert(OutputTbl,wag)
					end
				end
				
				if trig.occupied and IsValid(trig.occupied) then--почему-то без проверки IsValid работает некорректно
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
	
	local function Kostil(comm)	--TODO это костыль. Надо сделать функцию для синхры, которая закрывает маршрут
		for k,signal in pairs(ents.FindByClass("gmod_track_signal")) do
			if IsValid(signal) and signal.SayHook then signal:SayHook(comm) end
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

			--очистка ентити поезда отовсюду с помозью триггеров EndStart и EndEndоставленных в нужном направлении
			if Tbl1.EndStart and #Tbl1.EndStart > 0 then
				for i = 1,#Tbl1.EndStart do
					if Tbl1.EndEnd[i].occupied and not Tbl1.EndStart[i].occupied then
						for n,wag in ipairs(Tbl1.EndEnd[i].ents) do
							if FindInTable(Tbl1.EndStart[i].ents,wag) then
								FindAndClearEntInTriggers(wag,nil,nil,true) 
								--print("cleared")
							end
						end
					end
				end
			end
			
			--если вагон появился в тупике, то удаляю его из всех триггеров, кроме тупика
			for name,Tbl in pairs(Tbl1) do
				if not istable(Tbl) then continue end
				if name:find("Far") or name:find("Near") then	
					if Tbl[1] and IsEntity(Tbl[1]) and Tbl[1].occupied then continue end
					for n,Tent in ipairs(Tbl) do
						if not IsEntity(Tent) then continue end
						if Tent.occupied then
							--FindAndClearEntInTriggers(Tent.occupied,nil,name) --не уверен, что это нужно
							for i,wag in ipairs(Tent.ents) do
								FindAndClearEntInTriggers(wag,nil,name)
							end
						end
					end	
				end
			end
			
			
			--открытие маршрута
			if Tbl1.Type == "all"--[[справа дополнительное условие для сюрфейса]] or Tbl1.Type == "far" and Map:find("surface") and StationIndex == "102" then
				if Tbl1.FarDead and istable(Tbl1.FarDead) then
					local Wagons = GetEntsFromTriggers(Tbl1.FarDead)
					if #Wagons > 0 and not Tbl1.FarDead[1].occupied and Tbl1["RouteFromFarDead"] and OneOfTriggersOccupied(Tbl1.FarDead) and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromFarDead"] and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromFarDead"] = true
						ForAvtooborot(Tbl1["RouteFromFarDead"])
					end
				end
			end
			
			if Tbl1.Type == "all" or Tbl1.Type == "far" then
				if Tbl1.Far and istable(Tbl1.Far) then
					local Wagons = GetEntsFromTriggers(Tbl1.Far)
					if #Wagons > 0 and not Tbl1.Far[1].occupied and Tbl1["RouteFromFar"] and OneOfTriggersOccupied(Tbl1.Far) and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromStation"] and IfTrainInOnlyOneTable(Wagons) and (Tbl1.Type == "all" and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromFarDead"] or Tbl1.Type == "far")
					--дополнительное условие сюрфейс антиколлаб
					and (Map:find("surface") and StationIndex == "102" and #GetEntsFromTriggers(Tbl1.FarDead) == 0 or not Map:find("surface") or StationIndex ~= "102")
					and (Map:find("surface") and StationIndex == "102" and Tbl1.Type == "all" and #GetEntsFromTriggers(Tbl1.NearDead) == 0 and not Tbl1["OpenedFromNearDead"] and not Tbl1.Station[1].occupied and not Tbl1.NearDead[1].occupied or not Map:find("surface") or StationIndex ~= "102" or Tbl1.Type ~= "all")
					then
						Tbl1["OpenedFromFar"] = true
						ForAvtooborot(Tbl1["RouteFromFar"])
					end
				end
			end
			
			if Tbl1.Type == "all" or Tbl1.Type == "near" then
				if Tbl1.Near and istable(Tbl1.Near) then
					local Wagons = GetEntsFromTriggers(Tbl1.Near)
					if #Wagons > 0 and not Tbl1.Near[1].occupied and Tbl1["RouteFromNear"] and OneOfTriggersOccupied(Tbl1.Near) and not Tbl1["OpenedFromNear"] and not Tbl1["OpenedFromStation"] and IfTrainInOnlyOneTable(Wagons) and (Tbl1.Type == "all" and not Tbl1["OpenedFromFar"] and not Tbl1["OpenedFromFarDead"] and #GetEntsFromTriggers(Tbl1.Far) == 0 or Tbl1.Type == "near") 
					--дополнительное условие неомалина пионерская
					and (Map:find("gm_mustox_neocrimson_line_a") and StationIndex == "552" and #GetEntsFromTriggers(Tbl1.Station) == 0 or not Map:find("gm_mustox_neocrimson_line_a") or StationIndex ~= "552")
					then
						Tbl1["OpenedFromNear"] = true
						ForAvtooborot(Tbl1["RouteFromNear"])
					end
				end
			end
			
			if Tbl1.Type == "all" --[[справа дополнительное условие для сюрфейса]] or Tbl1.Type == "near" and Map:find("surface") and StationIndex == "102" then
				if Tbl1.NearDead and istable(Tbl1.NearDead) then
					local Wagons = GetEntsFromTriggers(Tbl1.NearDead)
					if #Wagons > 0 and not Tbl1.NearDead[1].occupied and Tbl1["RouteFromNearDead"] and OneOfTriggersOccupied(Tbl1.NearDead) and not Tbl1["OpenedFromNearDead"] and not Tbl1["OpenedFromStation"] and #GetEntsFromTriggers(Tbl1.Station) == 0 and IfTrainInOnlyOneTable(Wagons) then
						Tbl1["OpenedFromNearDead"] = true
						ForAvtooborot(Tbl1["RouteFromNearDead"])
					end
				end
			end
			
			if Tbl1.Station and istable(Tbl1.Station) then
				local Wagons = GetEntsFromTriggers(Tbl1.Station)
				if #Wagons > 0 and not Tbl1.Station[1].occupied and OneOfTriggersOccupied(Tbl1.Station) and not Tbl1["OpenedFromNearDead"] and #GetEntsFromTriggers(Tbl1.Near) == 0 and not Tbl1["OpenedFromStation"] and not Tbl1["OpenedFromNear"] and IfTrainInOnlyOneTable(Wagons) then
					if not Tbl1["OpenedFromFar"] and Tbl1["RouteToFar"] and (Tbl1.Type == "all" or Tbl1.Type == "far") and #GetEntsFromTriggers(Tbl1.Far) == 0 and Tbl1.Far then
						Tbl1["OpenedFromStation"] = true
						ForAvtooborot(Tbl1["RouteToFar"])
					elseif (Tbl1.Type == "all" or Tbl1.Type == "near") and Tbl1["RouteToNear"] and Tbl1.Near then
						Tbl1["OpenedFromStation"] = true
						ForAvtooborot(Tbl1["RouteToNear"])
					end
				end
			end
			

			if Map:find("gm_mustox_neocrimson_line_a") and Tbl1.Type ~= "none" then 
				--дополнительное условие неомалина братеево
				if StationIndex == "551" then
					local FarEnts = GetEntsFromTriggers(Tbl1.Far)
					local NearEnts = GetEntsFromTriggers(Tbl1.Near)
					local StationEnts = GetEntsFromTriggers(Tbl1.Station)
					local FarOccupied = OneOfTriggersOccupied(Tbl1.Far)
					local NearOccupied = OneOfTriggersOccupied(Tbl1.Near)
					local StationOccupied = OneOfTriggersOccupied(Tbl1.Station)
					
					if Tbl1.Type == "all" and #FarEnts == 0 and #NearEnts == 0 and #StationEnts == 0 and not FarOccupied and not NearOccupied and not StationOccupied then ForAvtooborot(Tbl1.RouteToFar,true) end
					if Tbl1.Type == "far" and #FarEnts == 0 and #StationEnts == 0 and not FarOccupied and not StationOccupied then ForAvtooborot(Tbl1.RouteToFar,true) end
					if Tbl1.Type == "near" and #NearEnts == 0 and #StationEnts == 0 and not NearOccupied and not StationOccupied then ForAvtooborot(Tbl1.RouteToNear,true) end
				--дополнительное условие неомалина фауна
				elseif StationIndex == "556" then
					local NearEnts = GetEntsFromTriggers(Tbl1.Near)
					local StationEnts = GetEntsFromTriggers(Tbl1.Station)
					local EndStartEnts = GetEntsFromTriggers(Tbl1.EndStart)
					local EndEndEnts = GetEntsFromTriggers(Tbl1.EndEnd)
					
					if #StationEnts == 0 then ForAvtooborot("FN1-1",true) end

					if #NearEnts == 0 and #EndStartEnts == 0 and #EndEndEnts == 0 then Kostil("!sclose FN3-2") end
				--дополнительное условие неомалина пионерская
				elseif StationIndex == "552" then
					local NearEnts = GetEntsFromTriggers(Tbl1.Near)
					local EndStartEnts = GetEntsFromTriggers(Tbl1.EndStart)
					local EndEndEnts = GetEntsFromTriggers(Tbl1.EndEnd)
					if #NearEnts == 0 and #EndStartEnts == 0 and #EndEndEnts == 0 then Kostil("!sclose POD-1") end
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
	
	hook.Add("EntityRemoved","UpdateAvtooborot",function(ent)
		if not IsValid(ent) then return end
		if ent:GetClass():find("gmod_subway_") then timer.Simple(0.3, UpdateAvtooborot) end
	end)
	
	local function ClearTriggersEnts(TriggersTbl)
		for i,trig in ipairs(TriggersTbl) do
			if trig.ents then trig.ents = {} end
		end
	end
	
	function AvtooborotControl(ply,text)-- функция управления автоборотом текстовой командой
		text = string.lower(text)
		if not text:find("%a") then 
			if AvtooborotStatus == 1 then 
				AvtooborotStatus = 0 
				SendAvtooborot() 
				ulx.fancyLogAdmin(ply,false,"#A выключил автооборот")
			else 
				deleteavtooborot()
				createavtooborot() 
				ulx.fancyLogAdmin(ply,false,"#A включил автооборот")
			end
			return
		end
		
		
		local start = 0
		if AvtooborotStatus == 1 then
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
						end
					end
					if not AvtooborotTBL[StationIndex].Near and not AvtooborotTBL[StationIndex].Far then return end
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
								ent.dbg = trig.dbg
								trig:Remove()
								ent:Spawn()
								AvtooborotTBL[StationIndex][name][i] = ent
							end
						end
					end
				end
				AvtooborotTBL[StationIndex].Type = Type 
				UpdateAvtooborot()
				SendAvtooborot() 
			end
		end
	end
	
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
