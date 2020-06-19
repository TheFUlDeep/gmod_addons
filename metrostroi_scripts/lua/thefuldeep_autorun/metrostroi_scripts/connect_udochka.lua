if 1 then return end

timer.Simple(0,function()
	--тут надо сохранить позиции удочек
	local uposes={}
	if SERVER then
		hook.Add("OnEntityCreated","Save Udocka's poses for connect_udockka.lua",function(ent)
			timer.Simple(0,function()if IsValid(ent)and ent:GetClass()=="gmod_track_udochka"then uposes[ent]=ent:GetPos()end end)
		end)
	end
	
	--нужен конфиг для каждой карты
	--указать луч, где можно брать удочу
	--указать луч, куда найденную удочку можно цеплять
	local findbeams={}
	local connectbeams={}
	
	
	local function IsSideCoupled(wag,isrear)
		if isrear then
			return IsValid(wag.RearCouple)and IsValid(wag.RearCouple.CoupledEnt)and IsValid(wag.RearCouple.CoupledEnt:GetNW2Entity("TrainEntity"))
		else
			return IsValid(wag.FrontCouple)and IsValid(wag.FrontCouple.CoupledEnt)and IsValid(wag.FrontCouple.CoupledEnt:GetNW2Entity("TrainEntity"))
		end
	end
	--проверка на головной вагон - он должен быть сцеплен с другим только с одной стороны
	local function IsWagFirstOrLast(wag)
		local rc=IsSideCoupled(wag,true)
		local fc=IsSideCoupled(wag)
		if rc and not fc or fc and not rc then return true end
	end
	
	local function connect(ply)
		if CLIENT then return end
		local seat=ply:GetVehicle()
		if not IsValid(seat)then ply:ChatPrint("Ты не в сидушке")return end
		local wag=seat:GetNW2Entity("TrainEntity")
		if not IsValid(wag)then ply:ChatPrint("Ты не в составе")return end
		if not IsWagFirstOrLast(wag)then ply:ChatPrint("Ты не в головном вагоне")return end
		
		--проверка на то,что к составу не подключена ни одна удочка
		local bogeys={}
		for _,wag1 in pairs(wag.WagonList or {wag})do
			if IsValid(wag1.FrontBogey)then bogeys[wag1.FrontBogey]=true end
			if IsValid(wag1.RearBogey)then bogeys[wag1.RearBogey]=true end
		end
		for _,ent in pairs(ents.FindByClass("gmod_track_udochka"))do
			if IsValid(ent)and IsValid(ent.Coupled)and bogeys[ent.Coupled]then ply:ChatPrint("К составу уже подключена удочка")return end
		end
		--тут проверка на то, в каком луче из connectbeams находится игрок и подключение удочки,найденной из соответствующего findbeams
		--проверка на то, что удочка ни к чему не подключена
		--и сохранение в каждый вагон ентити удочки
	end
	
	if ulx and ulx.command then
		local comm=ulx.command("Metrostroi","ulx connect_udochka",connect,"!connect_udochka",true,false,true)
		comm:defaultAccess(ULib.ACCESS_ALL)
		comm:help("Подключить удочку")
	end
	
	local function disconnect(ply)
		if CLIENT then return end
		local seat=ply:GetVehicle()
		if not IsValid(seat)then ply:ChatPrint("Ты не в сидушке")return end
		local wag=seat:GetNW2Entity("TrainEntity")
		if not IsValid(wag)then ply:ChatPrint("Ты не в составе")return end

		--поиск подключенных удочек к тележкам
		local disconnected
		local bogeys={}
		for _,wag1 in pairs(wag.WagonList or {wag})do
			if IsValid(wag1.FrontBogey)then bogeys[wag1.FrontBogey]=true end
			if IsValid(wag1.RearBogey)then bogeys[wag1.RearBogey]=true end
		end
		for _,ent in pairs(ents.FindByClass("gmod_track_udochka"))do
			if IsValid(ent)and IsValid(ent.Coupled)and bogeys[ent.Coupled]then
				ent:Use(ent,ent,0,0)
				disconnected=true
				if uposes[ent]then ent:SetPos(uposes[ent])end--возвращаю удочку на стартовую позицию
			end
		end
		if disconnected then 
			ply:ChatPrint("Удочка отсоединена")
		else
			ply:ChatPrint("К составу не подключена удочка")
		end
	end
	
	if ulx and ulx.command then
		local comm=ulx.command("Metrostroi","ulx connect_udochka",connect,"!connect_udochka",true,false,true)
		comm:defaultAccess(ULib.ACCESS_ALL)
		comm:help("Подключить удочку")
	end
	
	if CLIENT then return end
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
		"disconnects udochka to train"
	)
end)

--[[local seats={"DriverSeat","InstructorsSeat","ExtraSeat"}
local function IsSeatFromWagon(wag,myseat)
	for i=0,4 do
		local str=i > 0 and tostring(i)or""
		for _,seat1 in pairs(seats)do
			local seat=seat1..str
			if wag[seat]==myseat then return true end
		end
	end
end]]