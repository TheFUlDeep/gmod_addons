--[[============================= АВТООБОРОТ ==========================]]
 
if SERVER then 
	local Map = game.GetMap()
	util.AddNetworkString("Avtooborot")
	AvtooborotEnabled = -1
	function SendAvtooborot(int)
		net.Start("Avtooborot")
			net.WriteInt(int,2)
			AvtooborotEnabled = int
		net.Broadcast()
	end
	
	SendAvtooborot(-1)

	local AvtooborotTBL = {}
	
	local function createTrigger(name, StationName,fun, vector)
		SendAvtooborot(1)
		local ent = ents.Create( "avtooborot" )
		ent.name = name
		ent.zanyat = nil
		ent:SetPos(vector)
		--ent:SetSolid(SOLID_BBOX)
		--ent:SetCollisionBounds(vector + Vector(10,10,10), vector - Vector(100,100,100))
		ent:UseTriggerBounds(true, 10)
		ent:Spawn()
		--[[local scale = 0.1												-- for debug
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
		button:Spawn()]]
	if not AvtooborotTBL[fun] then AvtooborotTBL[fun] = {} end
	if not AvtooborotTBL[fun][StationName] then AvtooborotTBL[fun][StationName] = {} end
	AvtooborotTBL[fun][StationName][name] = ent
	--PrintTable(AvtooborotTBL)
	
	end

	
	function deleteavtooborot()
		SendAvtooborot(0)
		for k,v in pairs(ents.FindByClass("avtooborot")) do v:Remove() end 
		for k,v in pairs(ents.FindByClass("gmod_button")) do if v:GetModel() == "models/metrostroi_train/81-717.6/6000.mdl" then v:Remove() end end
		AvtooborotTBL = {}
	end

	function createavtooborot()
	local StationName
	local fun
		if Map:find("neocrims") then
			StationName = "Сталинская"
			fun = "6"
			createTrigger("TPeredStation1",StationName,fun,Vector(-4136.666504, -6264.695313, -3950))
			createTrigger("TPeredStation2",StationName,fun,Vector(-4136.666504-200, -6264.695313, -3950))
			createTrigger("TStationReika",StationName,fun,Vector(-774.843201, -6267.464844, -3950))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(-774.843201+500, -6267.464844, -3950))
			
			createTrigger("TNearDeadSvetofor",StationName,fun,Vector(-774.843201+3150, -6267.464844, -3950))
			createTrigger("TNearDead1",StationName,fun,Vector(-774.843201+3150+1900*1, -6267.464844, -3950))
			createTrigger("TNearDead2",StationName,fun,Vector(-774.843201+3150+1900*2, -6267.464844, -3950))
			createTrigger("TNearDead3",StationName,fun,Vector(-774.843201+3150+1900*3, -6267.464844, -3950))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(-774.843201+6300, -6267+380+260, -3950))
			createTrigger("TFar1",StationName,fun,Vector(-774.843201+6300+1900*1, -6267+380+260, -3950))
			createTrigger("TFar2",StationName,fun,Vector(-774.843201+6300+1900*2, -6267+380+260, -3950))
			createTrigger("TFar3",StationName,fun,Vector(-774.843201+6300+1900*3-600, -6267+380+260, -3950))
			
			createTrigger("TNearSvetofor",StationName,fun,Vector(-774.843201+6300, -6267+380, -3950))
			createTrigger("TNear1",StationName,fun,Vector(-774.843201+6300+1900*1, -6267+380, -3950))
			createTrigger("TNear2",StationName,fun,Vector(-774.843201+6300+1900*2, -6267+380, -3950))
			createTrigger("TNear3",StationName,fun,Vector(-774.843201+6300+1900*3-600, -6267+380, -3950))
			
			createTrigger("TFarDeadSvetofor",StationName,fun,Vector(-774.843201+3150, -6267+1010, -3950))
			createTrigger("TFarDead1",StationName,fun,Vector(-774.843201+3150+1900*1, -6267+1010, -3950))
			createTrigger("TFarDead2",StationName,fun,Vector(-774.843201+3150+1900*2, -6267+1010, -3950))
			createTrigger("TFarDead3",StationName,fun,Vector(-774.843201+3150+1900*3, -6267+1010, -3950))

			createTrigger("TEnd1",StationName,fun,Vector(-774.843201+700, -6267+1010, -3950))
			createTrigger("TEnd2",StationName,fun,Vector(-774.843201+700-200, -6267+1010, -3950))
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "ST1-4"
			AvtooborotTBL[fun][StationName]["RouteToNear"] = "ST1-3"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "ST4-2"
			AvtooborotTBL[fun][StationName]["RouteFromNear"] = "ST3-2"
			AvtooborotTBL[fun][StationName]["RouteFromNearDead"] = "STE-1"
			AvtooborotTBL[fun][StationName]["RouteFromFarDead"] = "STG-2"
			
			
			StationName = "Братеево"
			createTrigger("TPeredStation1",StationName,fun,Vector(-14578+10, 1506+200, -1442))
			createTrigger("TPeredStation2",StationName,fun,Vector(-14578+20, 1506+200+200, -1442))
			createTrigger("TStationReika",StationName,fun,Vector(-14578+10, 1506, -1442))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(-14578-160, 1506-5950, -1442))
			
			createTrigger("TNearSvetofor",StationName,fun,Vector(-14578-160, 1506-5950-5000, -1442))
			createTrigger("TNear1",StationName,fun,Vector(-14578-160, 1506-5950-5000-1900*1, -1442))
			createTrigger("TNear2",StationName,fun,Vector(-14578-160, 1506-5950-5000-1900*2, -1442))
			createTrigger("TNear3",StationName,fun,Vector(-14578-160, 1506-5950-5000-1900*3, -1442))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(-14578+450, 1506-5950-5400, -1442))
			createTrigger("TFar1",StationName,fun,Vector(-14578+450, 1506-5950-5400-1900*1, -1442))
			createTrigger("TFar2",StationName,fun,Vector(-14578+450, 1506-5950-5400-1900*2, -1442))
			createTrigger("TFar3",StationName,fun,Vector(-14578+450, 1506-5950-5400-1900*3, -1442))
			
			createTrigger("TEnd1",StationName,fun,Vector(-14578+450, 1506-6700, -1442))
			createTrigger("TEnd2",StationName,fun,Vector(-14578+450, 1506-6700+200, -1442))
			
			AvtooborotTBL[fun][StationName]["TNearDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead1"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead2"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead3"] = {}
			AvtooborotTBL[fun][StationName]["TFarDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead1"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead2"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead3"] = {}
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "BR2-1"
			AvtooborotTBL[fun][StationName]["RouteToNear"] = "BR2-2"
			AvtooborotTBL[fun][StationName]["RouteFromNear"] = "BR1-2"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "BR1-1"
		end
		
		if Map:find("surface") then
			StationName = "Площадь Восстания"
			fun = "6"
			
			createTrigger("TPeredStation1",StationName,fun,Vector(12780, 2998-500, -1090))
			createTrigger("TPeredStation2",StationName,fun,Vector(12780, 2998-500-200, -1090))
			createTrigger("TStationReika",StationName,fun,Vector(12780, 2998, -1090))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(12780, 2998+400, -1090))
			
			createTrigger("TNearSvetofor",StationName,fun,Vector(12780-60, 2998+7600, -1090))
			createTrigger("TNear1",StationName,fun,Vector(12780-60, 2998+7600+1900*1, -1090))
			createTrigger("TNear2",StationName,fun,Vector(12780-60, 2998+7600+1900*2, -1090))
			createTrigger("TNear3",StationName,fun,Vector(12780-60, 2998+7600+1900*2.2, -1090))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(12780-60-270, 2998+7600, -1090))
			createTrigger("TFar1",StationName,fun,Vector(12780-60-270, 2998+7600+1900*1, -1090))
			createTrigger("TFar2",StationName,fun,Vector(12780-60-270, 2998+7600+1900*2, -1090))
			createTrigger("TFar3",StationName,fun,Vector(12780-60-270, 2998+7600+1900*2.2, -1090))
			
			createTrigger("TEnd1",StationName,fun,Vector(12780-60-270, 2998+7600-2090, -1090))
			createTrigger("TEnd2",StationName,fun,Vector(12780-60-270, 2998+7600-2090-200, -1090))
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "PR2-3"
			AvtooborotTBL[fun][StationName]["RouteToNear"] = "PR2-4"
			AvtooborotTBL[fun][StationName]["RouteFromNear"] = "PR4-1"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "PR3-1"
			
			AvtooborotTBL[fun][StationName]["TNearDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead1"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead2"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead3"] = {}
			AvtooborotTBL[fun][StationName]["TFarDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead1"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead2"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead3"] = {}
			
			--[[StationName = "Куровская"
			fun = "5"
			
			createTrigger("TVhod",StationName,fun,Vector(3281, -5230, -1700))
			AvtooborotTBL[fun][StationName]["Left"] = {}
			AvtooborotTBL[fun][StationName]["Vhod"] = {}
			AvtooborotTBL[fun][StationName]["Centre"] = {}
			AvtooborotTBL[fun][StationName]["Right"] = {}
			AvtooborotTBL[fun][StationName]["Vihod"] = {}
			AvtooborotTBL[fun][StationName]["VihodWrong"] = {}
			AvtooborotTBL[fun][StationName]["PeredVhod"] = {}
			createTrigger("TVihod1",StationName,fun,Vector(3281 - 275, -5230 + 500, -1700))
			createTrigger("TVihod2",StationName,fun,Vector(3281 - 275, -5230 - 200 + 500, -1700))
			createTrigger("TVihodWrong1",StationName,fun,Vector(3281, -5230 - 200, -1700))
			createTrigger("TVihodWrong2",StationName,fun,Vector(3281, -5230 - 200 - 200, -1700))
			createTrigger("TCentreSvetofor",StationName,fun,Vector(3281 + 80, -5230 + 8700, -1700))
			createTrigger("TCentre1",StationName,fun,Vector(3281 + 80, -5230 + 8700 + 1900 * 0.5, -1700))
			createTrigger("TCentre2",StationName,fun,Vector(3281 + 80, -5230 + 8700 + 1900 * 1, -1700))
			createTrigger("TCentre3",StationName,fun,Vector(3281 + 80, -5230 + 8700 + 1900 * 1.5, -1700))
			
			createTrigger("TLeftSvetofor",StationName,fun,Vector(3281 - 440, -5230 + 6000, -1700))
			createTrigger("TLeft1",StationName,fun,Vector(3281 - 440, -5230 + 6000 + 1900 * 1, -1700))
			createTrigger("TLeft2",StationName,fun,Vector(3281 - 440, -5230 + 6000 + 1900 * 2, -1700))
			createTrigger("TLeft3",StationName,fun,Vector(3281 - 440, -5230 + 6000 + 1900 * 3, -1700))
			
			createTrigger("TRightSvetofor",StationName,fun,Vector(3281 + 340, -5230 + 7000, -1700))
			createTrigger("TRight1",StationName,fun,Vector(3281 + 340, -5230 + 7000 + 1900 * 1, -1700))
			createTrigger("TRight2",StationName,fun,Vector(3281 + 340, -5230 + 7000 + 1900 * 2, -1700))
			createTrigger("TRight3",StationName,fun,Vector(3281 + 340, -5230 + 7000 + 1900 * 3, -1700))
			
			createTrigger("Obnovlenie",StationName,fun,Vector(12788-15, 2995, -1100))
			createTrigger("TPeredVhod",StationName,fun,Vector(-9042 + 40, -14005, -1704))
			
			AvtooborotTBL[fun][StationName]["RouteToLeft"] = "K1-2"
			AvtooborotTBL[fun][StationName]["RouteToCentre"] = "K1-1/2"
			AvtooborotTBL[fun][StationName]["RouteToRight"] = "K1-1"
			AvtooborotTBL[fun][StationName]["RouteFromLeft"] = "ST2-2"
			AvtooborotTBL[fun][StationName]["RouteFromRight"] = "ST1-2"
			AvtooborotTBL[fun][StationName]["RouteFromCentre"] = "ST1/2-2"]]
			
			
			fun = "6"
			StationName = "Советская"
			createTrigger("TPeredStation1",StationName,fun,Vector(-15507, 5707, 190))
			createTrigger("TPeredStation2",StationName,fun,Vector(-15507, 5707-200, 190))
			
			createTrigger("TStationReika",StationName,fun,Vector(-15507, 5707+1900, 190))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(-15507, 5707+1900+500, 190))
			
			createTrigger("TNearSvetofor",StationName,fun,Vector(-15507, 5707+1900+500+2900, 190))
			createTrigger("TNear1",StationName,fun,Vector(-15507, 5707+1900+500+2900+1900*1, 190))
			createTrigger("TNear2",StationName,fun,Vector(-15507, 5707+1900+500+2900+1900*2, 190))
			createTrigger("TNear3",StationName,fun,Vector(-15507, 5707+1900+500+2900+1900*2.2, 190))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(-15507-270, 5707+1900+500+2900, 190))
			createTrigger("TFar1",StationName,fun,Vector(-15507-270, 5707+1900+500+2900+1900*1, 190))
			createTrigger("TFar2",StationName,fun,Vector(-15507-270, 5707+1900+500+2900+1900*2, 190))
			createTrigger("TFar3",StationName,fun,Vector(-15507-270, 5707+1900+500+2900+1900*2.2, 190))
			
			createTrigger("TEnd1",StationName,fun,Vector(-15507-270, 5707+1900+1200, 190))
			createTrigger("TEnd2",StationName,fun,Vector(-15507-270, 5707+1900+1200-200, 190))
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "SV1-4"
			AvtooborotTBL[fun][StationName]["RouteToNear"] = "SV1-3"
			AvtooborotTBL[fun][StationName]["RouteFromNear"] = "SV3-2"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "SV4-2"
			
			AvtooborotTBL[fun][StationName]["TNearDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead1"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead2"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead3"] = {}
			AvtooborotTBL[fun][StationName]["TFarDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead1"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead2"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead3"] = {}
			
		end
		
		
		--im not sure about routes on ruralline. Need to check it
		--[[if Map:find("ruralline_v29") then
			StationName = "Фили"
			fun = "2"
			
			createTrigger("TObnovlenie",StationName,fun,Vector(-4807+500, -14238, -13830))
			
			createTrigger("TStationReika",StationName,fun,Vector(-4807-3800, -14238, -13830))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(-4807-3800-1800, -14238+185, -13830))
			
			createTrigger("TPeredStation1",StationName,fun,Vector(-4807-3800+200, -14238, -13830))
			createTrigger("TPeredStation2",StationName,fun,Vector(-4807-3800+200*2, -14238, -13830))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(-13119, -6869+50, -13811))
			createTrigger("TFar1",StationName,fun,Vector(-13119, -6869+50+1900*1, -13811))
			createTrigger("TFar2",StationName,fun,Vector(-13119, -6869+50+1900*1.5, -13811))
			createTrigger("TFar3",StationName,fun,Vector(-13119, -6869+50+1900*1.8, -13811))
			
			createTrigger("TEnd1",StationName,fun,Vector(-13119, -6869-1900, -13811))
			createTrigger("TEnd2",StationName,fun,Vector(-13119, -6869-1900-200, -13811))
			
			AvtooborotTBL[fun][StationName]["TNearDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead1"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead2"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead3"] = {}
			
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "RL1-2"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "RL2-2"
			
			StationName = "Сад"
			fun = "6"
			
			createTrigger("TStationReika",StationName,fun,Vector(-1769, 15216-20, -16186))
			createTrigger("TStationZaReikoi",StationName,fun,Vector(-1769-650, 15216-20, -16186))
			
			createTrigger("TPeredStation1",StationName,fun,Vector(-1769+200, 15216-20, -16186))
			createTrigger("TPeredStation2",StationName,fun,Vector(-1769+200*2, 15216-20, -16186))
			
			createTrigger("TNearSvetofor",StationName,fun,Vector(-1769-7900, 15216-20, -16186))
			createTrigger("TNear1",StationName,fun,Vector(-1769-7900-1900*0.5, 15216-20, -16186))
			createTrigger("TNear2",StationName,fun,Vector(-1769-7900-1900*1, 15216-20, -16186))
			createTrigger("TNear3",StationName,fun,Vector(-1769-7900-1900*1.5, 15216-20, -16186))
			
			createTrigger("TFarSvetofor",StationName,fun,Vector(-1769-7900, 15216-280, -16186))
			createTrigger("TFar1",StationName,fun,Vector(-1769-7900-1900*0.5, 15216-280, -16186))
			createTrigger("TFar2",StationName,fun,Vector(-1769-7900-1900*1, 15216-280, -16186))
			createTrigger("TFar3",StationName,fun,Vector(-1769-7900-1900*1.5, 15216-280, -16186))
			
			createTrigger("TEnd1",StationName,fun,Vector(-1769-5500, 15216-280, -16186))
			createTrigger("TEnd2",StationName,fun,Vector(-1769-5500+200, 15216-280, -16186))
			
			AvtooborotTBL[fun][StationName]["RouteToFar"] = "MS2-3"
			AvtooborotTBL[fun][StationName]["RouteToNear"] = "MS2-4"
			AvtooborotTBL[fun][StationName]["RouteFromNear"] = "MS4-1"
			AvtooborotTBL[fun][StationName]["RouteFromFar"] = "MS3-1"
			
			AvtooborotTBL[fun][StationName]["TNearDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead1"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead2"] = {}
			AvtooborotTBL[fun][StationName]["TNearDead3"] = {}
			AvtooborotTBL[fun][StationName]["TFarDeadSvetofor"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead1"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead2"] = {}
			AvtooborotTBL[fun][StationName]["TFarDead3"] = {}
			
		end]]
		
		PrintTable(AvtooborotTBL)
	end

	deleteavtooborot()
	SendAvtooborot(-1)
	timer.Simple(2, function() createavtooborot() end)

	local function chetire(chetiretbl)
		if IsEntity(chetiretbl["Station"]) and not IsValid(chetiretbl["Station"]) then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
		if IsEntity(chetiretbl["Near"]) and not IsValid(chetiretbl["Near"]) then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end
		if IsEntity(chetiretbl["Far"]) and not IsValid(chetiretbl["Far"]) then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
		if IsEntity(chetiretbl["FarDead"]) and not IsValid(chetiretbl["FarDead"]) then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end
		if IsEntity(chetiretbl["NearDead"]) and not IsValid(chetiretbl["NearDead"]) then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
		
		if chetiretbl["TEnd2"].zanyat and not chetiretbl["TEnd1"].zanyat and (chetiretbl["Near"] or chetiretbl["Far"] or chetiretbl["FarDead"]) then																												--если выехал из тупика
			if not chetiretbl["TEnd2"].zanyat.WagonList	then																							--если нет таблицы wagonlist
				if chetiretbl["TEnd2"].zanyat == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if chetiretbl["TEnd2"].zanyat == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end											
				if chetiretbl["TEnd2"].zanyat == chetiretbl["FarDead"] then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end	
				if chetiretbl["TEnd2"].zanyat == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end	
			else
				for k,v in pairs(chetiretbl["TEnd2"].zanyat.WagonList) do
					if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
					if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end											
					if v == chetiretbl["FarDead"] then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end											
					if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
				end
			end
		end
		
		if chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and (chetiretbl["Near"] or chetiretbl["Far"] or chetiretbl["NearDead"]) then																												--если выехал из тупика в неправильном
			if not chetiretbl["TStationReika"].zanyat.WagonList then 
				if chetiretbl["TStationReika"].zanyat == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if chetiretbl["TStationReika"].zanyat == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
				if chetiretbl["TStationReika"].zanyat == chetiretbl["NearDead"] then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
			else
				for k,v in pairs(chetiretbl["TStationReika"].zanyat.WagonList) do
					if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
					if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
					if v == chetiretbl["NearDead"] then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
				end
			end
		end
		
		if chetiretbl["TPeredStation2"].zanyat and not chetiretbl["TPeredStation1"].zanyat and chetiretbl["Station"] then
			if not chetiretbl["TPeredStation2"].zanyat.WagonList then
				if chetiretbl["TPeredStation2"].zanyat == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
			else
				for k,v in pairs(chetiretbl["TPeredStation2"].zanyat.WagonList) do
					if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
				end
			end
		end
		
		if chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat then													--если появился в ближайшем тупике (не оборотном)
			chetiretbl["NearDead"] = chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat
			if not chetiretbl["TNearDeadSvetofor"].zanyat then
				if chetiretbl["Station"] then
					if not chetiretbl["NearDead"].WagonList then
						if chetiretbl["NearDead"] == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
					else
						for k,v in pairs(chetiretbl["NearDead"].WagonList) do
							if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
						end
					end
				end
				if not chetiretbl["Station"] and not chetiretbl["OpenedFromFar"] and not chetiretbl["OpenedFromNear"] then
					if not chetiretbl["OpenedFromNearDead"] then ForAvtooborot(chetiretbl["RouteFromNearDead"]) chetiretbl["OpenedFromNearDead"] = true end
				end
			end
		end
		
		if chetiretbl["TFar1"].zanyat or chetiretbl["TFar2"].zanyat or chetiretbl["TFar3"].zanyat then																											--если состав появился в дальнем тупике
			chetiretbl["Far"] = chetiretbl["TFar1"].zanyat or chetiretbl["TFar2"].zanyat or chetiretbl["TFar3"].zanyat
			if not chetiretbl["TFarSvetofor"].zanyat then 
				if chetiretbl["Station"] then
					if not chetiretbl["Far"].WagonList then
						if chetiretbl["Far"] == chetiretbl["Station"] then 
							chetiretbl["Station"] = false 
							chetiretbl["OpenedFromStation"] = false 
							if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
								ForAvtooborot(chetiretbl["RouteFromNearDead"])
								chetiretbl["OpenedFromNearDead"] = true
							end
						end
					else
						for k,v in pairs(chetiretbl["Far"].WagonList) do
							if v == chetiretbl["Station"] then 
								chetiretbl["Station"] = false 
								chetiretbl["OpenedFromStation"] = false 
								if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
									ForAvtooborot(chetiretbl["RouteFromNearDead"])
									chetiretbl["OpenedFromNearDead"] = true
								end
							end
						end
					end
				end
				if not chetiretbl["Station"] and not chetiretbl["Near"] and not chetiretbl["OpenedFromFarDead"] then
					if not chetiretbl["OpenedFromFar"] then ForAvtooborot(chetiretbl["RouteFromFar"]) chetiretbl["OpenedFromFar"] = true end
				end
			end			
		end
			
		if chetiretbl["TNear1"].zanyat or chetiretbl["TNear2"].zanyat or chetiretbl["TNear3"].zanyat then																										--если состав появился в ближнеи тупике
			chetiretbl["Near"] = chetiretbl["TNear1"].zanyat or chetiretbl["TNear2"].zanyat or chetiretbl["TNear3"].zanyat
			if not chetiretbl["TNearSvetofor"].zanyat then 
				if chetiretbl["Station"] then
					if not chetiretbl["Near"].WagonList then
						if chetiretbl["Near"] == chetiretbl["Station"] then
							chetiretbl["Station"] = false 
							chetiretbl["OpenedFromStation"] = false 
							if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
								ForAvtooborot(chetiretbl["RouteFromNearDead"])
								chetiretbl["OpenedFromNearDead"] = true
							end
						end
					else
						for k,v in pairs(chetiretbl["Near"].WagonList) do
							if v == chetiretbl["Station"] then
								chetiretbl["Station"] = false 
								chetiretbl["OpenedFromStation"] = false 
								if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
									ForAvtooborot(chetiretbl["RouteFromNearDead"])
									chetiretbl["OpenedFromNearDead"] = true
								end
							end
						end
					end
				end
				if not chetiretbl["Station"] and not chetiretbl["Far"] and not chetiretbl["OpenedFromFarDead"] then
					if not chetiretbl["OpenedFromNear"] then ForAvtooborot(chetiretbl["RouteFromNear"]) chetiretbl["OpenedFromNear"] = true end
				end
			end	
		end
		
		if chetiretbl["TFarDead1"].zanyat or chetiretbl["TFarDead2"].zanyat or chetiretbl["TFarDead3"].zanyat then													--если появился в дальнем тупике (не оборотном)
			chetiretbl["FarDead"] = chetiretbl["TFarDead1"].zanyat or chetiretbl["TFarDead2"].zanyat or chetiretbl["TFarDead3"].zanyat
			if not chetiretbl["TFarDeadSvetofor"].zanyat then
				if not chetiretbl["OpenedFromFar"] and not chetiretbl["OpenedFromNear"] then
					if not chetiretbl["OpenedFromFarDead"] then ForAvtooborot(chetiretbl["RouteFromFarDead"]) chetiretbl["OpenedFromFarDead"] = true end
				end
			end
		end
		
		if chetiretbl["TStationReika"].zanyat and not chetiretbl["Station"] and not chetiretbl["TStationZaReikoi"].zanyat then																	--если приехал на станцию
			if not chetiretbl["Near"] and not chetiretbl["Far"] then				--если оба тупика свободны
				chetiretbl["Station"] = chetiretbl["TStationReika"].zanyat
				if not chetiretbl["OpenedFromStation"] then ForAvtooborot(chetiretbl["RouteToFar"]) chetiretbl["OpenedFromStation"] = true end
			elseif not chetiretbl["Near"] and chetiretbl["Far"] then																--если дальний занят и ближний свободен
				chetiretbl["Station"] = chetiretbl["TStationReika"].zanyat
				if not chetiretbl["OpenedFromStation"] then ForAvtooborot(chetiretbl["RouteToNear"]) chetiretbl["OpenedFromStation"] = true end
			end
		end
		
		--return chetiretbl
	end
	
	local function dva(chetiretbl)
		if IsEntity(chetiretbl["Station"]) and not IsValid(chetiretbl["Station"]) then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
		--if IsEntity(chetiretbl["Near"]) and not IsValid(chetiretbl["Near"]) then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end
		if IsEntity(chetiretbl["Far"]) and not IsValid(chetiretbl["Far"]) then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
		--if IsEntity(chetiretbl["FarDead"]) and not IsValid(chetiretbl["FarDead"]) then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end
		if IsEntity(chetiretbl["NearDead"]) and not IsValid(chetiretbl["NearDead"]) then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
		
		if chetiretbl["TEnd2"].zanyat and not chetiretbl["TEnd1"].zanyat and (chetiretbl["Far"]) then																										--если выехал из тупика
			if not chetiretbl["TEnd2"].zanyat.WagonList then
				--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if chetiretbl["TEnd2"].zanyat == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end											
				--if v == chetiretbl["FarDead"] then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end	
				if chetiretbl["TEnd2"].zanyat == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
			else
				for k,v in pairs(chetiretbl["TEnd2"].zanyat.WagonList) do
					--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
					if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end											
					--if v == chetiretbl["FarDead"] then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end	
					if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
				end
			end
		end
		
		if chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and (--[[chetiretbl["Near"] or]] chetiretbl["Far"] or chetiretbl["NearDead"]) then																												--если выехал из тупика в неправильном
			if not chetiretbl["TStationReika"].zanyat.WagonList then
				--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if chetiretbl["TStationReika"].zanyat == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
				if chetiretbl["TStationReika"].zanyat == chetiretbl["NearDead"] then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
			else
				for k,v in pairs(chetiretbl["TStationReika"].zanyat.WagonList) do
					--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
					if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
					if v == chetiretbl["NearDead"] then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
				end
			end
		end
		
		if chetiretbl["TPeredStation2"].zanyat and not chetiretbl["TPeredStation1"].zanyat and chetiretbl["Station"] then
			if not chetiretbl["TPeredStation2"].zanyat.WagonList then
				if chetiretbl["TPeredStation2"].zanyat == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
			else
				for k,v in pairs(chetiretbl["TPeredStation2"].zanyat.WagonList) do
					if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
				end
			end
		end
		
		if chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat then													--если появился в ближайшем тупике (не оборотном)
			chetiretbl["NearDead"] = chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat
			if not chetiretbl["TNearDeadSvetofor"].zanyat then
				if chetiretbl["Station"] then
					if not chetiretbl["NearDead"].WagonList then
						if chetiretbl["NearDead"] == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
					else
						for k,v in pairs(chetiretbl["NearDead"].WagonList) do
							if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
						end
					end
				end
				if not chetiretbl["Station"] and not chetiretbl["OpenedFromFar"] and --[[not chetiretbl["OpenedFromNear"] and]] not chetiretbl["OpenedFromNearDead"] then
					if not chetiretbl["OpenedFromNearDead"] then ForAvtooborot(chetiretbl["RouteFromNearDead"]) chetiretbl["OpenedFromNearDead"] = true end
				end
			end
		end
		
		if chetiretbl["TFar1"].zanyat or chetiretbl["TFar2"].zanyat or chetiretbl["TFar3"].zanyat then																											--если состав появился в дальнем тупике
			chetiretbl["Far"] = chetiretbl["TFar1"].zanyat or chetiretbl["TFar2"].zanyat or chetiretbl["TFar3"].zanyat
			if not chetiretbl["TFarSvetofor"].zanyat then 
				if chetiretbl["Station"] then
					if not chetiretbl["Far"].WagonList then
						if chetiretbl["Far"] == chetiretbl["Station"] then 
							chetiretbl["Station"] = false 
							chetiretbl["OpenedFromStation"] = false 
							if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
								ForAvtooborot(chetiretbl["RouteFromNearDead"])
								chetiretbl["OpenedFromNearDead"] = true
							end
						end
					else
						for k,v in pairs(chetiretbl["Far"].WagonList) do
							if v == chetiretbl["Station"] then 
								chetiretbl["Station"] = false 
								chetiretbl["OpenedFromStation"] = false 
								if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
									ForAvtooborot(chetiretbl["RouteFromNearDead"])
									chetiretbl["OpenedFromNearDead"] = true
								end
							end
						end
					end
				end
				if not chetiretbl["Station"] and --[[not chetiretbl["Near"] and]] not chetiretbl["OpenedFromFar"] and not chetiretbl["OpenedFromFarDead"] then
					if not chetiretbl["OpenedFromFar"] then ForAvtooborot(chetiretbl["RouteFromFar"]) chetiretbl["OpenedFromFar"] = true end
				end
			end			
		end
			
		--[[if chetiretbl["TNear1"].zanyat or chetiretbl["TNear2"].zanyat or chetiretbl["TNear3"].zanyat then																										--если состав появился в ближнеи тупике
			chetiretbl["Near"] = chetiretbl["TNear1"].zanyat or chetiretbl["TNear2"].zanyat or chetiretbl["TNear3"].zanyat
			if not chetiretbl["TNearSvetofor"].zanyat then 
				if chetiretbl["Station"] then
					for k,v in pairs(chetiretbl["Near"].WagonList) do
						if v == chetiretbl["Station"] then
							chetiretbl["Station"] = false 
							chetiretbl["OpenedFromStation"] = false 
							if chetiretbl["NearDead"] and not chetiretbl["TNearDeadSvetofor"].zanyat and not chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and not chetiretbl["TPeredStation1"].zanyat and not chetiretbl["TPeredStation2"].zanyat then
								ForAvtooborot(chetiretbl["RouteFromNearDead"])
								chetiretbl["OpenedFromNearDead"] = true
							end
						end
					end
				end
				if not chetiretbl["Station"] and not chetiretbl["Far"] and not chetiretbl["OpenedFromNear"]  and not chetiretbl["OpenedFromFarDead"] then
					ForAvtooborot(chetiretbl["RouteFromNear"])
					chetiretbl["OpenedFromNear"] = true
				end
			end	
		end
		
		if chetiretbl["TFarDead1"].zanyat or chetiretbl["TFarDead2"].zanyat or chetiretbl["TFarDead3"].zanyat then													--если появился в дальнем тупике (не оборотном)
			chetiretbl["FarDead"] = chetiretbl["TFarDead1"].zanyat or chetiretbl["TFarDead2"].zanyat or chetiretbl["TFarDead3"].zanyat
			if not chetiretbl["TFarDeadSvetofor"].zanyat then
				if not chetiretbl["OpenedFromFar"] and not chetiretbl["OpenedFromNear"] and not chetiretbl["OpenedFromFarDead"] then
					ForAvtooborot(chetiretbl["RouteFromFarDead"])
					chetiretbl["OpenedFromFarDead"] = true
				end
			end
		end]]
		
		if chetiretbl["TStationReika"].zanyat and not chetiretbl["Station"] and not chetiretbl["TStationZaReikoi"].zanyat then																	--если приехал на станцию
			if --[[not chetiretbl["Near"] and]] not chetiretbl["Far"] and not chetiretbl["OpenedFromStation"] then				--если оба тупика свободны
				chetiretbl["Station"] = chetiretbl["TStationReika"].zanyat
				if not chetiretbl["OpenedFromStation"] then ForAvtooborot(chetiretbl["RouteToFar"]) chetiretbl["OpenedFromStation"] = true end
			--[[elseif not chetiretbl["Near"] and chetiretbl["Far"] and not chetiretbl["OpenedFromStation"] then																--если дальний занят и ближний свободен
				chetiretbl["Station"] = chetiretbl["TStationReika"].zanyat
				ForAvtooborot(chetiretbl["RouteToNear"])
				chetiretbl["OpenedFromStation"] = true]]
			end
		end
		
		--return chetiretbl
	end
		
	local function TableInsert(tbl,value)
		if table.Count(tbl) > 0 then
			for k,v in pairs(tbl) do
				if v == value then return end
			end
		end
		table.insert(tbl,1,value)
	end
	
	local function ClearCheckTblTbl(tbltoclear,tbl2)
		if table.Count(tbltoclear) < 1 then return true end
		local cleared = false
		for k,v in pairs(tbl2) do
			for k1,v1 in pairs(tbltoclear) do
				if v == v1 then tbltoclear[k1] = nil cleared = true end
			end
		end
		return cleared
	end
	
	local function ValidateFieldTbl(tbl)
		local cleared = false
		if table.Count(tbl) > 0 then
			for k,v in pairs(tbl) do
				if not IsValid(v) then tbl[k] = nil cleared = true end
			end
		end
		return cleared
	end
	
	local function pyat(tbl)	-- возможно стоит добавить TVhod2 по неправильному направлению, чтобы по нему можно было заезжать
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["Centre"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["Right"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["Left"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["Vhod"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["PeredVhod"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["Vihod"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		-- НЕ ЗАБЫТЬ СОЗДАТЬ ТАБЛИЦУ tbl["VihodWrong"] = {}. Ну или добавить в самое начало проверку на создание этой таблицы
		local needsilent = false
		
		--занятость
		
		--записываю все уезжающие вагоны
		if tbl["TVihod1"].zanyat or tbl["TVihod2"].zanyat then TableInsert(tbl["Vihod"],tbl["TVihod1"].zanyat or tbl["TVihod2"].zanyat) end
		if tbl["TVihodWrong1"].zanyat or tbl["TVihodWrong2"].zanyat then TableInsert(tbl["VihodWrong"],tbl["TVihodWrong1"].zanyat or tbl["TVihodWrong2"].zanyat) end
		
		--есть ли подъезжающий паравоз
		if tbl["TPeredVhod"].zanyat then TableInsert(tbl["PeredVhod"],tbl["TPeredVhod"].zanyat) end
		
		--этот параметр не даст собрать маршрут со станции, если есть паравоз на стрелках
		--то есть, когда в tbl["Vhod"] есть ентити - это значит, что это ентити едет по стрелкам
		--а также он очищает таблицу паравозов, подъезжающих сюда
		if tbl.TVhod.zanyat --[[or tbl.TVhod2.zanyat]] then
			TableInsert(tbl.Vhod,tbl.TVhod.zanyat--[[or tbl.TVhod2.zanyat]])
			ClearCheckTblTbl(tbl["PeredVhod"],tbl["Vhod"])
		end
		
		--занятость станций
		if tbl["TCentre1"].zanyat or tbl["TCentre2"].zanyat or tbl["TCentre3"].zanyat or tbl["TCentreSvetofor"].zanyat then
			TableInsert(tbl["Centre"],tbl["TCentre1"].zanyat or tbl["TCentre2"].zanyat or tbl["TCentre3"].zanyat or tbl["TCentreSvetofor"].zanyat)
			ClearCheckTblTbl(tbl["VihodWrong"],tbl["Centre"])
			ClearCheckTblTbl(tbl["Vihod"],tbl["Centre"])
		end
		if tbl["TLeft1"].zanyat or tbl["TLeft2"].zanyat or tbl["TLeft3"].zanyat or tbl["TLeftSvetofor"].zanyat then
			TableInsert(tbl["Left"],tbl["TLeft1"].zanyat or tbl["TLeft2"].zanyat or tbl["TLeft3"].zanyat or tbl["TLeftSvetofor"].zanyat)
			ClearCheckTblTbl(tbl["VihodWrong"],tbl["Left"])
			ClearCheckTblTbl(tbl["Vihod"],tbl["Left"])
		end
		if tbl["TRight1"].zanyat or tbl["TRight2"].zanyat or tbl["TRight3"].zanyat or tbl["TRightSvetofor"].zanyat then
			TableInsert(tbl["Right"],tbl["TRight1"].zanyat or tbl["TRight2"].zanyat or tbl["TRight3"].zanyat or tbl["TRightSvetofor"].zanyat)
			ClearCheckTblTbl(tbl["VihodWrong"],tbl["Right"])
			ClearCheckTblTbl(tbl["Vihod"],tbl["Right"])
		end
		
		--очистка недоступных ентити
		ValidateFieldTbl(tbl["Centre"])
		ValidateFieldTbl(tbl["Left"])
		ValidateFieldTbl(tbl["Right"])
		ValidateFieldTbl(tbl["Vihod"])
		ValidateFieldTbl(tbl["VihodWrong"])
		ValidateFieldTbl(tbl["PeredVhod"])
		ValidateFieldTbl(tbl["Vhod"])
		
		--Проверка от казуса: без этого условия, если паравоз заедет на стрелки, и за ним сразу приедет новый и наедет на триггер TVihodWrong2 (или TVihod2), то вся таблца vhod обнулится, то есть автооборот забудет, что есть паравоз на стрелках, что не есть хорошо.
		if (not tbl["TVihodWrong1"].zanyat and not tbl["TVihodWrong2"].zanyat) or (not tbl["TVihodWrong1"].zanyat and tbl["TVihodWrong2"].zanyat and tbl["TVhod"].zanyat) then
			tbl["VihodWrong"] = {}
		end
		if (not tbl["TVihod1"].zanyat and not tbl["TVihod2"].zanyat) or (not tbl["TVihod1"].zanyat and tbl["TVihod2"].zanyat and tbl["TVhod"].zanyat) then
			tbl["Vihod"] = {}
		end
		
		--очистка уехавших ентити в правильном направлении
		if not tbl["TVihod1"].zanyat and tbl["TVihod2"].zanyat then
			if ClearCheckTblTbl(tbl["Centre"],tbl["Vihod"]) then --[[tbl["Centre"] = {}]] tbl["OpenedFromCentre"] = false end
			if ClearCheckTblTbl(tbl["Right"],tbl["Vihod"]) then --[[tbl["Right"] = {}]] tbl["OpenedFromRight"] = false end
			if ClearCheckTblTbl(tbl["Left"],tbl["Vihod"]) then --[[tbl["Left"] = {}]] tbl["OpenedFromLeft"] = false end
			--ClearCheckTblTbl(tbl["PeredVhod"],tbl["Vihod"])	--надеюсь, что это не нужно
			ClearCheckTblTbl(tbl["Vhod"],tbl["Vihod"])
			--ClearCheckTblTbl(tbl["VihodWrong"],tbl["Vihod"])		--наверное, это стало не нужно после добавления блока выше
			tbl["Vihod"] = {}
		end
		
		--очистка уехавших ентити в неправильном направлении
		if not tbl["TVihodWrong1"].zanyat and tbl["TVihodWrong2"].zanyat then
			if ClearCheckTblTbl(tbl["Centre"],tbl["VihodWrong"]) then --[[tbl["Centre"] = {}]] tbl["OpenedFromCentre"] = false end
			if ClearCheckTblTbl(tbl["Right"],tbl["VihodWrong"]) then --[[tbl["Right"] = {}]] tbl["OpenedFromRight"] = false end
			if ClearCheckTblTbl(tbl["Left"],tbl["VihodWrong"]) then --[[tbl["Left"] = {}]] tbl["OpenedFromLeft"] = false end
			--ClearCheckTblTbl(tbl["PeredVhod"],tbl["VihodWrong"])	-- надеюсь, что это не нужно
			ClearCheckTblTbl(tbl["Vhod"],tbl["VihodWrong"])
			--ClearCheckTblTbl(tbl,[Vihod"],tbl["VihodWrong"])		--наверное, это стало не нужно после добавления блока выше
			tbl["VihodWrong"] = {}
		end
		
		-- при полном заезде на станцию очистка состава со стрелок
		if table.Count(tbl["Right"]) > 0 and not tbl["TRightSvetofor"].zanyat then ClearCheckTblTbl(tbl["Vhod"],tbl["Right"]) end
		if table.Count(tbl["Left"]) > 0 and not tbl["TLeftSvetofor"].zanyat then ClearCheckTblTbl(tbl["Vhod"],tbl["Left"]) end
		if table.Count(tbl["Centre"]) > 0 and not tbl["TCentreSvetofor"].zanyat then ClearCheckTblTbl(tbl["Vhod"],tbl["Centre"]) end
		
		--если на станции никого нет, то разрешается открыть с нее маршрут
		if table.Count(tbl["Right"]) < 1 then tbl["OpenedFromRight"] = false end
		if table.Count(tbl["Left"]) < 1 then tbl["OpenedFromLeft"] = false end
		if table.Count(tbl["Centre"]) < 1 then tbl["OpenedFromCentre"] = false end
		
		
		--сбор мрашрута со станций
		if not tbl["OpenedFromCentre"] and not tbl["OpenedFromRight"] and not tbl["OpenedFromLeft"] and table.Count(tbl["Vhod"]) < 1 then
			--сбор с левого пути
			if table.Count(tbl["Left"]) > 0 and not tbl["TLeftSvetofor"].zanyat then
				tbl["OpenedFromVhod"] = false
				tbl["OpenedFromLeft"] = true
				ForAvtooborot(tbl["RouteFromLeft"])
			--сбор с центрального пути
			elseif table.Count(tbl["Centre"]) > 0 and not tbl["TCentreSvetofor"].zanyat then
				tbl["OpenedFromVhod"] = false
				tbl["OpenedFromCentre"] = true
				ForAvtooborot(tbl["RouteFromCentre"])
			--сбор с правого пути
			elseif table.Count(tbl["Right"]) > 0 and not tbl["TRightSvetofor"].zanyat then
				tbl["OpenedFromVhod"] = false
				tbl["OpenedFromRight"] = true
				ForAvtooborot(tbl["RouteFromRight"])
			end
		end
		
		--когда есть состав на станции, надо разрешать собирать маршрут на станцию
		if (table.Count(tbl["Left"]) > 0 or table.Count(tbl["Centre"]) > 0 or table.Count(tbl["Right"]) > 0) and tbl["OpenedFromVhod"] and table.Count(tbl["Vhod"]) < 1 then
			tbl["OpenedFromVhod"] = false
			needsilent = true
		end

		--автоматическое открытие стрелки, если никто не подъезжает и никого нет на стрелках и маршрут еще не открыт
		if table.Count(tbl["PeredVhod"]) < 1 and table.Count(tbl["Vhod"]) < 1 and tbl["OpenedFromVhod"] then tbl["OpenedFromVhod"] = false needsilent = true end
		
		
		--сбор маршрута на станции
		--сбор на левый путь
		if not tbl["OpenedFromVhod"] then
			if table.Count(tbl["Left"]) < 1 and table.Count(tbl["Right"]) < 1 and table.Count(tbl["Centre"]) < 1 then	--их надо собирать только если поезд заехал. Если он заспавнился,то переводить не нужно
				tbl["OpenedFromVhod"] = true
				ForAvtooborot(tbl["RouteToLeft"],needsilent)
			end
			--сбор на средний путь
			if table.Count(tbl["Left"]) > 0 and table.Count(tbl["Right"]) < 1 and table.Count(tbl["Centre"]) < 1 then
				tbl["OpenedFromVhod"] = true
				ForAvtooborot(tbl["RouteToCentre"],needsilent)
			end
			--сбор на правый путь
			if table.Count(tbl["Centre"]) > 0 and table.Count(tbl["Right"]) < 1 then
				tbl["OpenedFromVhod"] = true
				ForAvtooborot(tbl["RouteToRight"],needsilent)
			end
		end
		--[[for k,v in pairs(player.GetAll()) do
			v:ChatPrint("------------------------------------------------")
			for k1,v1 in pairs(tbl) do
				v:ChatPrint(k1..":"..tostring(v1))
			end
		end]]
	end
	
	function UpdateAvtooborot()
		if AvtooborotEnabled ~= 1 then return end
		
		if AvtooborotTBL["6"] then
			for k,v in pairs(AvtooborotTBL["6"]) do
				chetire(v)
			end
			
			if AvtooborotTBL["6"]["Братеево"] then			--дополнительное условие для братеево. Чтобы по умолчанию стрелка открывалась по отклюнению
				if not AvtooborotTBL["6"]["Братеево"]["Station"] and not AvtooborotTBL["6"]["Братеево"]["Near"] and not AvtooborotTBL["6"]["Братеево"]["Far"] --and not AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] 
				then
					ForAvtooborot(AvtooborotTBL["6"]["Братеево"]["RouteToFar"],true)
					AvtooborotTBL["6"]["Братеево"]["OpenedFromStation"] = true
				end	-- значение на братеево по умолчанию
				if not AvtooborotTBL["6"]["Братеево"]["Near"] and not AvtooborotTBL["6"]["Братеево"]["Station"] and AvtooborotTBL["6"]["Братеево"]["Far"] --and not AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] 
				then 
					ForAvtooborot(AvtooborotTBL["6"]["Братеево"]["RouteToNear"],true)
					AvtooborotTBL["6"]["Братеево"]["OpenedFromStation"] = true
				end
			end
		end
		
		if AvtooborotTBL["5"] then
			for k,v in pairs(AvtooborotTBL["5"]) do
				pyat(v)
			end
		end
		
		if AvtooborotTBL["2"] then
			for k,v in pairs(AvtooborotTBL["2"]) do
				dva(v)
			end
			
			if AvtooborotTBL["2"]["Фили"] then		--дополнительное условие для роклейка. Чтобы по умолчанию стрелка открывалась по отклюнению
				if not AvtooborotTBL["2"]["Фили"]["Station"] and not AvtooborotTBL["2"]["Фили"]["Far"] then
					ForAvtooborot(AvtooborotTBL["2"]["Фили"]["RouteToFar"],true)
				end
			end
		end

	end

	for k,v in pairs(player.GetAll()) do
		if v:Nick():find("TheFulDeep") then print(v:GetPos()) end
	end
	
	hook.Add("PlayerInitialSpawn","AvtooborotSpawn", function() 
		timer.Simple(2, function()
			SendAvtooborot(AvtooborotEnabled)
		end)
	end)
	
end

if CLIENT then
		--[[hook.Add("Think", "AvtooborotEnabled", function()
		end)]]
	local AvtooborotEnabled = -1
	net.Receive("Avtooborot", function()
		AvtooborotEnabled = net.ReadInt(2)
	end)
		
	hook.Add( "HUDPaint", "AvtooborotEnabled1", function()
		if AvtooborotEnabled < 0 then return end
		local text
		local w1
		local h1
		if AvtooborotEnabled == 1 then text = "Автооборот: включен" else text = "Автооборот: выключен" end
		w1,h1 = surface.GetTextSize(text)
		draw.RoundedBox(6, ScrW() - w1 - 32, ScrH()/2 - 250 - 4, w1 + 20, h1 + 10, Color(0, 0, 0, 150))
		draw.SimpleText(text, "ChatFont",ScrW() - 20, ScrH()/2 - 250, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	end)
end
