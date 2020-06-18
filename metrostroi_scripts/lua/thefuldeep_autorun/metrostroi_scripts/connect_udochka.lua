if 1 then return end

timer.Simple(0,function()
	--тут надо сохранить позиции удочек
	local uposes = {}
	if SERVER then
		hook.Add( "OnEntityCreated", "Save Udocka's poses for connect_udockka.lua", function( ent )
			timer.Simple(0,function()if IsValid(ent) then uposes[ent]=ent:GetPos() end end)
		end)
	end
	
	--нужен конфиг для каждой карты
	--указать луч, где можно брать удочу
	--указать луч, куда найденную удочку можно цеплять
	local findbeams = {}
	local connectbeams = {}
	if not ulx or not ulx.command then return end
	
	local function connect(ply)
		if CLIENT then return end
		local seat = ply:GetVehicle()
		if not IsValid(seat) then ply:ChatPrint("Ты не в сидушке") return end
		local wag = seat:GetNW2Entity("TrainEntity")
		if not IsValid(wag) then ply:ChatPrint("Ты не в составе") return end
		
		--проверка на то, что к составу не подключена ни одна удочка
		local bogeys = {}
		for _,wag1 in pairs(wag.WagonList or {wag}) do
			if IsValid(wag1.FrontBogey) then bogeys[wag1.FrontBogey] = true end
			if IsValid(wag1.RearBogey) then bogeys[wag1.RearBogey] = true end
		end
		for _,ent in pairs(ents.FindByClass("gmod_track_udochka"))do
			if IsValid(ent)and IsValid(ent.Coupled)and bogeys[ent.Coupled] then ply:ChatPrint("К составу уже подключена удочка") return end
		end
		--тут проверка на то, в каком луче из connectbeams находится игрок и подключение удочки, найденной из соответствующего findbeams
		--проверка на то, что удочка ни к чему не подключена
		--и сохранение в каждый вагон ентити удочки
	end
	local comm = ulx.command("Metrostroi", "ulx connect_udochka", connect, "!connect_udochka", true, false, true)
	comm:defaultAccess(ULib.ACCESS_ALL)
	comm:help("Подключить удочку")
	
	local function disconnect(ply)
		if CLIENT then return end
		local seat = ply:GetVehicle()
		if not IsValid(seat) then ply:ChatPrint("Ты не в сидушке") return end
		local wag = seat:GetNW2Entity("TrainEntity")
		if not IsValid(wag) then ply:ChatPrint("Ты не в составе") return end
		for _,wag1 in pairs(wag.WagonList or {wag}) do
			local u = wag1.ConnectedUdochka
			if not IsValid(u) then continue end
			u:Use(u,u,0,0)
			if uposes[u] then u:SetPos(uposes[u])end--возвращаю удочку на стартовую позицию
			for _,wag2 in pairs(wag.WagonList or {wag}) do wag2.ConnectedUdochka = nil end
			return
		end
		ply:ChatPrint("К составу не подключена удочка")
	end
	local comm = ulx.command("Metrostroi", "ulx connect_udochka", connect, "!connect_udochka", true, false, true)
	comm:defaultAccess(ULib.ACCESS_ALL)
	comm:help("Подключить удочку")
	
	 concommand.Add(
		"connect_udochka", 
		function(ply)connect(ply)end, 
		nil, 
		"connects udochka to train"
	)
	
	 concommand.Add(
		"disconnect_udochka", 
		function(ply)disconnect(ply)end, 
		nil, 
		"connects udochka to train"
	)
end)

--[[local seats = {"DriverSeat","InstructorsSeat","ExtraSeat"}
local function IsSeatFromWagon(wag,myseat)
	for i = 0,4 do
		local str = i > 0 and tostring(i) or ""
		for _,seat1 in pairs(seats) do
			local seat = seat1..str
			if wag[seat] == myseat then return true end
		end
	end
end]]