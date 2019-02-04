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
											button:SetModel( "models/6000/6000.mdl" )
											button:SetCollisionGroup( COLLISION_GROUP_WORLD )
											button:SetPersistent( true )
											button:SetPos(ent:GetPos() )
											button:SetModelScale(scale)
											button:Spawn()
											local button = ents.Create( "gmod_button" )
											button:SetModel( "models/6000/6000.mdl" )
											button:SetCollisionGroup( COLLISION_GROUP_WORLD )
											button:SetPersistent( true )
											button:SetPos(ent:GetPos() )
											button:SetAngles(Angle(0,90,0))
											button:SetModelScale(scale)
											button:Spawn()
											local button = ents.Create( "gmod_button" )
											button:SetModel( "models/6000/6000.mdl" )
											button:SetCollisionGroup( COLLISION_GROUP_WORLD )
											button:SetPersistent( true )
											button:SetPos(ent:GetPos() )
											button:SetAngles(Angle(90,0,0))
											button:SetModelScale(scale)
											button:Spawn()]]
		ent:Spawn()
	if not AvtooborotTBL[fun] then AvtooborotTBL[fun] = {} end
	if not AvtooborotTBL[fun][StationName] then AvtooborotTBL[fun][StationName] = {} end
	AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = ent
	--PrintTable(AvtooborotTBL)
	
	end

	
	function deleteavtooborot()
		SendAvtooborot(0)
		for k,v in pairs(ents.FindByClass("avtooborot")) do v:Remove() end 
		for k,v in pairs(ents.FindByClass("gmod_button")) do if v:GetModel() == "models/6000/6000.mdl" then v:Remove() end end
		AvtooborotTBL = {}
	end
	
	local function RoutesAvtooborot(StationName,fun,str1,str2,str3,str4)
		if table.Count(AvtooborotTBL[fun][StationName]) ~= 11 and table.Count(AvtooborotTBL[fun][StationName]) ~= 7 then print("Я что-то сделал не так") deleteavtooborot() return end	-- TODO проверка для функции dva и вообще обороты для этой функции
		AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = false	--станция			12 или 8
		AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = false	--ближний			13 или 9
		if fun ~= "2" then
			AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = false	--дальний			14
		end
		AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = str1		--на дальний
		AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = str2		--на ближний
		if fun ~= "2" then
			AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = str3		--с дальнего
			AvtooborotTBL[fun][StationName][table.Count(AvtooborotTBL[fun][StationName])+1] = str4		--с ближнего
		end
	end

	function createavtooborot()	
		if Map:find("neocrims") then
			--[[=============================СТАЛИНСКАЯ ==========================]]
			createTrigger("st1","Сталинская","4", Vector(-799.596069, -6264.959961, -3994.191650 + 50))	--станция
			createTrigger("st30","Сталинская","4", Vector(6738.398926 - 1300, -5884.746582, -3982.595459))	--у ближнего светофора
			createTrigger("st40","Сталинская","4", Vector(6738.398926 - 1300, -5884.746582 +260 , -3982.595459))	--у дальнего светофора
			createTrigger("st31","Сталинская","4", Vector(6738.398926 - 350, -5884.746582, -3982.595459))		--ближний путь	--расстояние между двумя 1900
			createTrigger("st32","Сталинская","4", Vector(6738.398926 + 1600, -5884.746582, -3982.595459))
			createTrigger("st333","Сталинская","4", Vector(6738.398926 + 1600 + 1900, -5884.746582, -3982.595459))
			createTrigger("st41","Сталинская","4", Vector(6738.398926 - 350, -5884.746582 + 260, -3982.595459))
			createTrigger("st42","Сталинская","4", Vector(6738.398926 + 1600, -5884.746582 + 260, -3982.595459))
			createTrigger("st43","Сталинская","4", Vector(6738.398926 + 1600 + 1900, -5884.746582 + 260, -3982.595459))
			createTrigger("st2","Сталинская","4", Vector(2916.443115, -5629.077148, -4024.620117 +50))
			createTrigger("st22","Сталинская","4", Vector(2916.443115 - 400, -5629.077148 + 10, -4024.620117 +50))
			RoutesAvtooborot("Сталинская","4","ST1-4","ST1-3","ST4-2","ST3-2")
			
			--[[=============================БРАТЕЕВО ==========================]]
			createTrigger("br1","Братеево","4", Vector(-14735.519531, -9313.416016 +4800 + 1900, -1478.274414-20))	--станция
			createTrigger("br30", "Братеево","4",Vector(-14735.519531, -9313.416016, -1478.274414-20))	--у ближнего светофора
			createTrigger("br40","Братеево","4", Vector(-14735.519531 + 600, -9313.416016 - 400, -1478.274414-20))	--у дальнего светофора
			createTrigger("br3", "Братеево","4",Vector(-14735.519531, -9313.416016 - 1900, -1478.274414-20))		--ближний путь	--расстояние между двумя 1900
			createTrigger("br33","Братеево", "4",Vector(-14735.519531, -9313.416016 - 1900 - 1900, -1478.274414-20))
			createTrigger("br333","Братеево","4", Vector(-14735.519531, -9313.416016 - 1900 - 1900 - 1900, -1478.274414-20))
			createTrigger("br4", "Братеево","4",Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900, -1478.274414-20))
			createTrigger("br44","Братеево", "4",Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900 - 1900, -1478.274414-20))
			createTrigger("br444","Братеево", "4",Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900 - 1900 -1900, -1478.274414-20))
			createTrigger("br2","Братеево", "4",Vector(-14735.519531 + 600, -9313.416016 + 4100, -1478.274414-20))
			createTrigger("br22","Братеево", "4",Vector(-14735.519531 + 600, -9313.416016 + 4100 + 500, -1478.274414))
			RoutesAvtooborot("Братеево","4","BR2-1","BR2-2","BR1-1","BR1-2")
			createTrigger("obnovlenie","Братеево","4", Vector(11817.193359, -405.242218, -1466.181519 + 20-20))
		end
		
		if stringfind(Map,"rural") and stringfind(Map,"29") then
			createTrigger("st1","МаркетСтрит","4", Vector(-1901.142090, 15205.250000, -16247.982422 + 50))	--станция
			createTrigger("st30","МаркетСтрит", "4",Vector(-1901.142090 - 7550, 15205.250000, -16247.982422 + 50))	--у ближнего светофора
			createTrigger("st40","МаркетСтрит", "4",Vector(-1901.142090 - 7550, 15205.250000 - 270, -16247.982422 + 50))	--у дальнего светофора
			createTrigger("st31","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*1, 15205.250000, -16247.982422 + 50))		--ближний путь	--расстояние между двумя 1900
			createTrigger("st32","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*2, 15205.250000, -16247.982422 + 50))
			createTrigger("st33","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*3, 15205.250000, -16247.982422 + 50))
			createTrigger("st41","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*1, 15205.250000 - 270, -16247.982422 + 50))
			createTrigger("st42","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*2, 15205.250000 - 270, -16247.982422 + 50))
			createTrigger("st43","МаркетСтрит", "4",Vector(-1901.142090 - 7550 - 1000*3, 15205.250000 - 270, -16247.982422 + 50))
			createTrigger("st2","МаркетСтрит", "4",Vector(-1901.142090 - 7550 + 2100, 15205.250000 - 270, -16247.982422 + 50))
			createTrigger("st22","МаркетСтрит", "4",Vector(-1901.142090 - 7550 + 2300, 15205.250000 - 270, -16247.982422 + 50))
			RoutesAvtooborot("МаркетСтрит","4","MS2-3","MS2-4","MS3-1","MS4-1")
			
			createTrigger("Из депо","Роклейк", "2",Vector(-4435.384766, -14238.708008, -13842.546875)) -- на станции
			createTrigger("Светофор","Роклейк", "2",Vector(-13116.465820, -6903.582031, -13804.361328))
			createTrigger("Станция1","Роклейк", "2",Vector(-13116.465820, -6903.582031 + 900*1, -13804.361328))
			createTrigger("Станция2","Роклейк", "2",Vector(-13116.465820, -6903.582031 + 900*2, -13804.361328))
			createTrigger("Станция3","Роклейк", "2",Vector(-13116.465820, -6903.582031 + 900*3, -13804.361328))
			createTrigger("Со станции1","Роклейк", "2",Vector(-13116.465820, -6903.582031 - 1200, -13804.361328))
			createTrigger("Со станции2","Роклейк", "2",Vector(-13116.465820, -6903.582031 - 1200 - 200, -13804.361328))
			RoutesAvtooborot("Роклейк", "2","RL1-2","RL2-2")
		end
		PrintTable(AvtooborotTBL)
	end

	deleteavtooborot()
	SendAvtooborot(-1)
	timer.Simple(2, function() createavtooborot() end)

	local function dva(chetiretbl)
		if IsEntity(chetiretbl[8]) and not IsValid(chetiretbl[8]) then chetiretbl[8] = false end
		if IsEntity(chetiretbl[9]) and not IsValid(chetiretbl[9]) then chetiretbl[9] = false end
		
		if chetiretbl[7].zanyat and not chetiretbl[6].zanyat then																												--если выехал из тупика
			for k,v in pairs(chetiretbl[7].zanyat.WagonList) do																													--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if v == chetiretbl[9] then chetiretbl[9] = false end											
			end
		end
		if chetiretbl[3].zanyat or chetiretbl[4].zanyat or chetiretbl[5].zanyat then																											--если состав появился в тупике
			chetiretbl[9] = chetiretbl[3].zanyat and chetiretbl[3].zanyat or (chetiretbl[4].zanyat and chetiretbl[4].zanyat or chetiretbl[5].zanyat)
			if not chetiretbl[2].zanyat then 
				if chetiretbl[8] then
					for k,v in pairs(chetiretbl[3].zanyat and chetiretbl[3].zanyat.WagonList or (chetiretbl[4].zanyat and chetiretbl[4].zanyat.WagonList or chetiretbl[5].zanyat.WagonList)) do
						if v == chetiretbl[8] then chetiretbl[8] = false end
					end
				end
				if not chetiretbl[8] then
					ForAvtooborot(chetiretbl[11])
				end
			end			
		end
		if chetiretbl[1].zanyat and not chetiretbl[8] then																													--если приехал на станцию
			if not chetiretbl[9] then				--если оба тупика свободны
				chetiretbl[8] = chetiretbl[1].zanyat
				ForAvtooborot(chetiretbl[10])
			end
		end
		return chetiretbl
	end
	
	local function chetire(chetiretbl)
		if IsEntity(chetiretbl[10 + 2]) and not IsValid(chetiretbl[10 + 2]) then chetiretbl[10 + 2] = false end
		if IsEntity(chetiretbl[11 + 2]) and not IsValid(chetiretbl[11 + 2]) then chetiretbl[11 + 2] = false end
		if IsEntity(chetiretbl[12 + 2]) and not IsValid(chetiretbl[12 + 2]) then chetiretbl[12 + 2] = false end
		
		if chetiretbl[9 + 2].zanyat and not chetiretbl[8 + 2].zanyat then																												--если выехал из тупика
			for k,v in pairs(chetiretbl[9 + 2].zanyat.WagonList) do
				if v == chetiretbl[11 + 2] then chetiretbl[11 + 2] = false end																														--вообще тут лучше сделать через elseif, но я сделал так на всякийслучай
				if v == chetiretbl[12 + 2] then chetiretbl[12 + 2] = false end											
			end
		end
		
		if chetiretbl[5 + 2].zanyat or chetiretbl[6 + 2].zanyat or chetiretbl[7 + 2].zanyat then																											--если состав появился в дальнем тупике
			chetiretbl[12 + 2] = chetiretbl[5+2].zanyat and chetiretbl[5+2].zanyat or (chetiretbl[6+2].zanyat and chetiretbl[6+2].zanyat or chetiretbl[7+2].zanyat)
			if not chetiretbl[3].zanyat then 
				if chetiretbl[10 + 2] then
					for k,v in pairs(chetiretbl[5+2].zanyat and chetiretbl[5+2].zanyat.WagonList or (chetiretbl[6+2].zanyat and chetiretbl[6+2].zanyat.WagonList or chetiretbl[7+2].zanyat.WagonList)) do
						if v == chetiretbl[10 + 2] then chetiretbl[10 + 2] = false end
					end
				end
				if not chetiretbl[10 + 2] and not chetiretbl[11 + 2] then
					ForAvtooborot(chetiretbl[15 + 2])
				end
			end			
		end
			
		if chetiretbl[2 + 2].zanyat or chetiretbl[3 + 2].zanyat or chetiretbl[4 + 2].zanyat then																										--если состав появился в ближнеи тупике
			chetiretbl[11 + 2] = chetiretbl[2+2].zanyat and chetiretbl[2+2].zanyat or (chetiretbl[3+2].zanyat and chetiretbl[3+2].zanyat or chetiretbl[4+2].zanyat)
			if not chetiretbl[2].zanyat then 
				if chetiretbl[10 + 2] then
					for k,v in pairs(chetiretbl[2+2].zanyat and chetiretbl[2+2].zanyat.WagonList or (chetiretbl[3+2].zanyat and chetiretbl[3+2].zanyat.WagonList or chetiretbl[4+2].zanyat.WagonList)) do
						if v == chetiretbl[10 + 2] then chetiretbl[10 + 2] = false end
					end
				end
				if not chetiretbl[10 + 2] and not chetiretbl[12 + 2] then
					ForAvtooborot(chetiretbl[16 + 2])
				end
			end	
		end

		if chetiretbl[1].zanyat and not chetiretbl[10 + 2] then																													--если приехал на станцию
			if not chetiretbl[11 + 2] and not chetiretbl[12 + 2] then				--если оба тупика свободны
				chetiretbl[10 + 2] = chetiretbl[1].zanyat
				ForAvtooborot(chetiretbl[13 + 2])
			elseif not chetiretbl[11 + 2] and chetiretbl[12 + 2] then																--если дальний занят и ближний свободен
				chetiretbl[10 + 2] = chetiretbl[1].zanyat
				ForAvtooborot(chetiretbl[14 + 2])
			end
		end
		
		return chetiretbl
	end
	
	function UpdateAvtooborot()
		if AvtooborotEnabled ~= 1 then return end
		
		if AvtooborotTBL["4"] then
			for k,v in pairs(AvtooborotTBL["4"]) do
				v = chetire(v)
			end
			
			if AvtooborotTBL["4"]["Братеево"] then			--дополнительное условие для братеево. Чтобы по умолчанию стрелка открывалась по отклюнению
				if not AvtooborotTBL["4"]["Братеево"][12] and not AvtooborotTBL["4"]["Братеево"][13] and not AvtooborotTBL["4"]["Братеево"][14] then ForAvtooborot(AvtooborotTBL["4"]["Братеево"][15]) end	-- значение на братеево по умолчанию
				if not AvtooborotTBL["4"]["Братеево"][13] and not AvtooborotTBL["4"]["Братеево"][12] and AvtooborotTBL["4"]["Братеево"][14] then ForAvtooborot(AvtooborotTBL["4"]["Братеево"][16]) end
			end
		end
		
		if AvtooborotTBL["2"] then
			for k,v in pairs(AvtooborotTBL["2"]) do
				v = dva(v)
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
		draw.SimpleText(text, "ChatFont",ScrW() - 15, ScrH()/2 - 250, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	end)
end
