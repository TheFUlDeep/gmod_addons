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
											--[[local scale = 0.1													-- for debug
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
		ent:Spawn()
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
		if Map:find("neocrims") then
			local StationName = "Сталинская"
			local fun = "4"
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
			local StationName = "Площадь Восстания"
			local fun = "4"
			
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
		
		if chetiretbl["TEnd2"].zanyat and not chetiretbl["TEnd1"].zanyat and (chetiretbl["Far"]) then																												--если выехал из тупика
			for k,v in pairs(chetiretbl["TEnd2"].zanyat.WagonList) do
				--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end											
				--if v == chetiretbl["FarDead"] then chetiretbl["FarDead"] = false chetiretbl["OpenedFromFarDead"] = false end											
			end
		end
		
		if chetiretbl["TStationReika"].zanyat and not chetiretbl["TStationZaReikoi"].zanyat and (--[[chetiretbl["Near"] or]] chetiretbl["Far"] or chetiretbl["NearDead"]) then																												--если выехал из тупика в неправильном
			for k,v in pairs(chetiretbl["TStationReika"].zanyat.WagonList) do
				--if v == chetiretbl["Near"] then chetiretbl["Near"] = false chetiretbl["OpenedFromNear"] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if v == chetiretbl["Far"] then chetiretbl["Far"] = false chetiretbl["OpenedFromFar"] = false end
				if v == chetiretbl["NearDead"] then chetiretbl["NearDead"] = false chetiretbl["OpenedFromNearDead"] = false end
			end
		end
		
		if chetiretbl["TPeredStation2"].zanyat and not chetiretbl["TPeredStation1"].zanyat and chetiretbl["Station"] then
			for k,v in pairs(chetiretbl["TPeredStation2"].zanyat.WagonList) do
				if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false print("alo") end
			end
		end
		
		if chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat then													--если появился в ближайшем тупике (не оборотном)
			chetiretbl["NearDead"] = chetiretbl["TNearDead1"].zanyat or chetiretbl["TNearDead2"].zanyat or chetiretbl["TNearDead3"].zanyat
			if not chetiretbl["TNearDeadSvetofor"].zanyat then
				if chetiretbl["Station"] then
					for k,v in pairs(chetiretbl["NearDead"].WagonList) do
						if v == chetiretbl["Station"] then chetiretbl["Station"] = false chetiretbl["OpenedFromStation"] = false end
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
	
	function UpdateAvtooborot()
		if AvtooborotEnabled ~= 1 then return end
		
		if AvtooborotTBL["4"] then
			for k,v in pairs(AvtooborotTBL["4"]) do
				--v = chetire(v)
				chetire(v)
			end
			
			if AvtooborotTBL["4"]["Братеево"] then			--дополнительное условие для братеево. Чтобы по умолчанию стрелка открывалась по отклюнению
				if not AvtooborotTBL["4"]["Братеево"]["Station"] and not AvtooborotTBL["4"]["Братеево"]["Near"] and not AvtooborotTBL["4"]["Братеево"]["Far"] --and not AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] 
				then
					ForAvtooborot(AvtooborotTBL["4"]["Братеево"]["RouteToFar"],true)
					AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] = true
				end	-- значение на братеево по умолчанию
				if not AvtooborotTBL["4"]["Братеево"]["Near"] and not AvtooborotTBL["4"]["Братеево"]["Station"] and AvtooborotTBL["4"]["Братеево"]["Far"] --and not AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] 
				then 
					ForAvtooborot(AvtooborotTBL["4"]["Братеево"]["RouteToNear"],true)
					AvtooborotTBL["4"]["Братеево"]["OpenedFromStation"] = true
				end
			end
		end
		
		if AvtooborotTBL["2"] then
			for k,v in pairs(AvtooborotTBL["2"]) do
				--v = dva(v)
				dva(v)
			end
			
			if AvtooborotTBL["2"]["Роклейк"] then		--дополнительное условие для роклейка. Чтобы по умолчанию стрелка открывалась по отклюнению
				if not AvtooborotTBL["2"]["Роклейк"][8] and not AvtooborotTBL["2"]["Роклейк"][9] then ForAvtooborot(AvtooborotTBL["2"]["Роклейк"][10]) end
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
