--[[============================= АВТООБОРОТ ==========================]]
 
if SERVER then 
	util.AddNetworkString("Avtooborot")
	AvtooborotEnabled = -1
	function SendAvtooborot(int)
		net.Start("Avtooborot")
			net.WriteInt(int,2)
			AvtooborotEnabled = int
		net.Broadcast()
	end
	
	SendAvtooborot(-1)

	local function createTrigger(name, vector)
		SendAvtooborot(1)
		local ent = ents.Create( "avtooborot" )
		ent.name = name
		ent.zanyat = nil
		ent:SetPos(vector)
		--ent:SetSolid(SOLID_BBOX)
		--ent:SetCollisionBounds(vector + Vector(10,10,10), vector - Vector(100,100,100))
		ent:UseTriggerBounds(true, 10)
	--[[local scale = 0.1
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
		ent = nil
	end

	
	local avtooborottbl = {}
	local chetiretblST1 = {}
	local chetiretblST2 = {}
	local dvatbl1 = {}

	function deleteavtooborot()
		SendAvtooborot(0)
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "avtooborot" or v:GetModel() == "models/6000/6000.mdl" then v:Remove() end
		end
		--[[for k,v in pairs(ents.FindByClass("avtooborot")) do
			v:Remove()
		end]]
		avtooborottbl = {}
	end


	function createavtooborot()
		if game.GetMap():find("crossline") then
		--[[=============================ПРОЛЕТАРСКАЯ ==========================]]
			createTrigger("pr1",Vector(-15563.694336, -5413.343750 + 50, -9845.212891))
			createTrigger("pr20",Vector(-10872.337891 - 950, -14594.821289, -9883.062500))
			createTrigger("pr21",Vector(-10872.337891, -14594.821289, -9883.062500))
			createTrigger("pr22",Vector(-9924.507813 + 1900, -14591.441406, -9875.230469))
			createTrigger("pr23",Vector(-9924.507813 +1900 + 1900, -14591.441406, -9875.230469))
			createTrigger("pr2v",Vector(-14832.340820, -9584.333008+1000, -9846.887695))
			createTrigger("pr2v2",Vector(-14832.258789, -9485.821289+1000, -9846.148438))
			
			local i = 0
			for k,v in pairs(ents.FindByClass("avtooborot")) do
				if v.name:find("pr") then i = i + 1 dvatbl1[i] = v end
			end
			dvatbl1[table.Count(dvatbl1) + 1] = false			--8
			dvatbl1[table.Count(dvatbl1) + 1] = false
			dvatbl1[table.Count(dvatbl1) + 1] = "pr1-2"
			dvatbl1[table.Count(dvatbl1) + 1] = "pr2-2"
			
			--[[=============================МЕЖДУНАРОДНАЯ ==========================]]
			createTrigger("md2",Vector(-2918.047363, -2447.674805, -14484.669922))
			createTrigger("md34",Vector(2915.535156, 3854.378906, -14488.509766))
			createTrigger("md1",Vector(-1637.656250, -3.905661, -14509.456055))
			createTrigger("md11",Vector(-2100.766846, -324.450134, -14536.151367))
			
		end
		
		if game.GetMap():find("ruralline") then
		--[[=============================РОКЛЕЙК ==========================]]
			createTrigger("pr1",Vector(-10305.263672, -14071.332031, -13875.839844 + 20))
			createTrigger("pr20",Vector(-13116.477539, -3953.990723 - 2950, -13844.466797))
			createTrigger("pr21",Vector(-13116.477539, -3953.990723 - 3000 + 950, -13844.466797))
			createTrigger("pr22",Vector(-13116.477539, -3953.990723 - 3000 + 950 + 1900, -13844.466797))
			createTrigger("pr23",Vector(-13116.477539, -3953.990723 - 3000 + 950 + 1900 + 950, -13844.466797))
			createTrigger("prv1",Vector(-4489.781250 + 60, -14523.852539, -13850.818359))
			createTrigger("prv2",Vector(-4489.781250 + 60 + 200, -14523.852539, -13850.818359))
			createTrigger("obnovlenie",Vector(-3839.271729, -14173.636719, -13857.780273))
			
			local i = 0
			for k,v in pairs(ents.FindByClass("avtooborot")) do
				if v.name:find("pr") then i = i + 1 dvatbl1[i] = v end
			end
			dvatbl1[table.Count(dvatbl1) + 1] = false			--8
			dvatbl1[table.Count(dvatbl1) + 1] = false
			dvatbl1[table.Count(dvatbl1) + 1] = "RL1-2"
			dvatbl1[table.Count(dvatbl1) + 1] = "RL2-2"
			
			--[[=============================МАРКЕТ СТРИТ ==========================]]
			createTrigger("md2",Vector(-1986.927979, 15190.926758, -16212.073242))
			createTrigger("md40",Vector(-10374.126953, 15068.288086 + 125, -16188.178711 -20 ))
			createTrigger("md30",Vector(-10374.126953, 15068.288086 + 125, -16188.178711 -20 ))
			createTrigger("md4",Vector(-10374.126953, 15068.288086 + 125, -16188.178711 -20 ))
			createTrigger("md44",Vector(-10374.126953 -1900, 15068.288086 + 125, -16188.178711 -20 ))
			createTrigger("md444",Vector(-10374.126953 -1900 - 1000, 15068.288086 + 125, -16188.178711 -20 ))
			createTrigger("md3",Vector(-10374.126953, 15068.288086 - 125, -16188.178711 -20 ))
			createTrigger("md33",Vector(-10374.126953 - 1900, 15068.288086 - 125, -16188.178711 -20 ))
			createTrigger("md333",Vector(-10374.126953 - 1900 - 1000, 15068.288086 - 125, -16188.178711 -20 ))
			createTrigger("md1",Vector(-7202.187988, 14937.003906, -16208), nil)
			createTrigger("md11",Vector(-7202.187988 + 300, 14937.003906, -16208), nil)
			
			local i = 0
			for k,v in pairs(ents.FindByClass("avtooborot")) do
				if v.name:find("md") then i = i + 1 chetiretblST1[i] = v end
			end
			chetiretblST1[table.Count(chetiretblST1) + 1] = false			-- 10 + 2
			chetiretblST1[table.Count(chetiretblST1) + 1] = false
			chetiretblST1[table.Count(chetiretblST1) + 1] = false
			chetiretblST1[table.Count(chetiretblST1) + 1] = "MS2-3"	
			chetiretblST1[table.Count(chetiretblST1) + 1] = "MS2-4"
			chetiretblST1[table.Count(chetiretblST1) + 1] = "MS3-1"
			chetiretblST1[table.Count(chetiretblST1) + 1] = "MS4-1"
			
		end
		
		if game.GetMap():find("neocrims") then
			--[[=============================СТАЛИНСКАЯ ==========================]]
			createTrigger("st1", Vector(-799.596069, -6264.959961, -3994.191650 + 50))	--станция
			createTrigger("st30", Vector(6738.398926 - 1300, -5884.746582, -3982.595459))	--у ближнего светофора
			createTrigger("st40", Vector(6738.398926 - 1300, -5884.746582 +260 , -3982.595459))	--у дальнего светофора
			createTrigger("st3", Vector(6738.398926 - 350, -5884.746582, -3982.595459))		--ближний путь	--расстояние между двумя 1900
			createTrigger("st33", Vector(6738.398926 + 1600, -5884.746582, -3982.595459))
			createTrigger("st333", Vector(6738.398926 + 1600 + 1900, -5884.746582, -3982.595459))
			createTrigger("st4", Vector(6738.398926 - 350, -5884.746582 + 260, -3982.595459))
			createTrigger("st44", Vector(6738.398926 + 1600, -5884.746582 + 260, -3982.595459))
			createTrigger("st444", Vector(6738.398926 + 1600 + 1900, -5884.746582 + 260, -3982.595459))
			createTrigger("st2", Vector(2916.443115, -5629.077148, -4024.620117 +50))
			createTrigger("st22", Vector(2916.443115 - 400, -5629.077148 + 10, -4024.620117 +50))
			local i = 0
			for k,v in pairs(ents.FindByClass("avtooborot")) do
				if v.name:find("st") then i = i + 1 chetiretblST1[i] = v end
			end
			chetiretblST1[table.Count(chetiretblST1) + 1] = false			--станция		-- 10 + 2
			chetiretblST1[table.Count(chetiretblST1) + 1] = false			--ближний
			chetiretblST1[table.Count(chetiretblST1) + 1] = false			--дальний
			chetiretblST1[table.Count(chetiretblST1) + 1] = "ST1-4"	--на дальний
			chetiretblST1[table.Count(chetiretblST1) + 1] = "ST1-3"
			chetiretblST1[table.Count(chetiretblST1) + 1] = "ST4-2"	--с дальнего
			chetiretblST1[table.Count(chetiretblST1) + 1] = "ST3-2"
			
			--[[=============================БРАТЕЕВО ==========================]]
			createTrigger("br1", Vector(-14735.519531, -9313.416016 +4800 + 1900, -1478.274414-20))	--станция
			createTrigger("br30", Vector(-14735.519531, -9313.416016, -1478.274414-20))	--у ближнего светофора
			createTrigger("br40", Vector(-14735.519531 + 600, -9313.416016 - 400, -1478.274414-20))	--у дальнего светофора
			createTrigger("br3", Vector(-14735.519531, -9313.416016 - 1900, -1478.274414-20))		--ближний путь	--расстояние между двумя 1900
			createTrigger("br33", Vector(-14735.519531, -9313.416016 - 1900 - 1900, -1478.274414-20))
			createTrigger("br333", Vector(-14735.519531, -9313.416016 - 1900 - 1900 - 1900, -1478.274414-20))
			createTrigger("br4", Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900, -1478.274414-20))
			createTrigger("br44", Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900 - 1900, -1478.274414-20))
			createTrigger("br444", Vector(-14735.519531 + 600, -9313.416016 - 400 - 1900 - 1900 -1900, -1478.274414-20))
			createTrigger("br2", Vector(-14735.519531 + 600, -9313.416016 + 4100, -1478.274414-20))
			createTrigger("br22", Vector(-14735.519531 + 600, -9313.416016 + 4100 + 500, -1478.274414))
			createTrigger("obnovlenie", Vector(11817.193359, -405.242218, -1466.181519 + 20-20))
			local i = 0
			for k,v in pairs(ents.FindByClass("avtooborot")) do
				if v.name:find("br") then i = i + 1 chetiretblST2[i] = v end
			end
			chetiretblST2[table.Count(chetiretblST2) + 1] = false			--станция		-- 10 + 2
			chetiretblST2[table.Count(chetiretblST2) + 1] = false			--ближний
			chetiretblST2[table.Count(chetiretblST2) + 1] = false			--дальний
			chetiretblST2[table.Count(chetiretblST2) + 1] = "BR2-1"	--на дальний
			chetiretblST2[table.Count(chetiretblST2) + 1] = "BR2-2"
			chetiretblST2[table.Count(chetiretblST2) + 1] = "BR1-1"	--с дальнего
			chetiretblST2[table.Count(chetiretblST2) + 1] = "BR1-2"
		end
		for k,v in pairs(ents.FindByClass("avtooborot")) do
			avtooborottbl[v.name] = v
			--[[if v.name == "md34" then
				for k1,v1 in pairs(player.GetAll()) do
					v1:SetPos(v:GetPos())
				end
			end]]
		end
		PrintTable(avtooborottbl)
	end

	deleteavtooborot()
	timer.Simple(2, function() createavtooborot() end)

local md2 = nil
local md34 = nil

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
	
		if game.GetMap():find("crossline") then
			dvatbl1 = dva(dvatbl1)	-- пролетарская

		--[[============================= МЕЖДУНАРОДНАЯ ==========================]]
			if not IsValid(md2) then md2 = nil end
			if not IsValid(md34) then md34 = nil end
			if avtooborottbl["md34"].zanyat and md34 == nil then md34 = avtooborottbl["md34"].zanyat ForAvtooborot("md4-1") end
			if avtooborottbl["md2"].zanyat and md2 == nil and md34 == nil and not avtooborottbl["md34"].zanyat then		-- на станцию
				md2 = avtooborottbl["md2"].zanyat.WagonList[table.Count(avtooborottbl["md2"].zanyat.WagonList)]
				ForAvtooborot("md2-4")
				--ulx.fancyLogAdmin(md2:CPPIGetOwner(),"Игроку #A собран маршрут в оборотный тупик Междануродной")
			end
			if avtooborottbl["md34"].zanyat and avtooborottbl["md34"].zanyat == md2 then md34 = md2 ForAvtooborot("md4-1") md2 = nil end

			if avtooborottbl["md11"].zanyat and not avtooborottbl["md1"].zanyat and md34 ~= nil then			--освобождение md4 с помощью двух триггеров
				for k,v in pairs(avtooborottbl["md11"].zanyat.WagonList) do
					if md34 == v then md34 = nil break end
				end
			end 
		end

		if game.GetMap():find("ruralline") then
			dvatbl1 = dva(dvatbl1)					-- роклейк
			if not dvatbl1[8] and not dvatbl1[9] then ForAvtooborot(dvatbl1[10]) end
			
			chetiretblST1 = chetire(chetiretblST1)	-- маркет стрит
		end
		if game.GetMap():find("neocrims") then	
			chetiretblST1 = chetire(chetiretblST1)	-- сталинская
			chetiretblST2 = chetire(chetiretblST2)	-- братеево
			if not chetiretblST2[10 + 2] and not chetiretblST2[11 + 2] and not chetiretblST2[12 + 2] then ForAvtooborot(chetiretblST2[13 + 2]) end	-- значение на братеево по умолчанию
			if not chetiretblST2[11+2] and not chetiretblST2[10 + 2] and chetiretblST2[12+2] then ForAvtooborot(chetiretblST2[14+2]) end
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
	net.Receive("AvtooborotEnabled", function()
		AvtooborotEnabled = net.ReadInt(1)
	end)
		
	hook.Add( "HUDPaint", "AvtooborotEnabled1", function()
		if AvtooborotEnabled < 0 then return end
		local text
		local w1
		local h1
		if AvtooborotEnabled == 1 then text = "Автооборот: включен" else text = "Автооборот: выключен" end
		w1,h1 = surface.GetTextSize(text)
		draw.RoundedBox(6, ScrW() - w1 - 24, ScrH()/2 - 250 - 5, w1 + 15, h1 + 10, Color(0, 0, 0, 150))
		draw.SimpleText(text, "ChatFont",ScrW() - 15, ScrH()/2 - 250, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	end)
end
