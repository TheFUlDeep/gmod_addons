if CLIENT then return end

--[[============================= СТРИНГФАЙНД ТУТ ВРЕМЕННО ==========================]]
function stringfind(where, what, lowerr, startpos, endpos)
	local Exeption = false
	if not where or not what then --[[print("[STRINGFIND EXEPTION] cant find required arguments")]] return false end
	if type(where) ~= "string" or type(what) ~= "string" then --[[print("[STRINGFIND EXEPTION] not string")]] return false
	elseif string.len(what) > string.len(where) then --[[print("[STRINGFIND EXEPTION] string what you want to find bigger than string where you want to find it")]] Exeption = true 
	end
	if startpos and type(startpos) ~= "number" then startpos = tonumber(startpos) end
	if endpos and type(endpos) ~= "number" then endpos = tonumber(endpos) end
	local strlen1 = string.len(where)
	local strlen2 = string.len(what)
	if not startpos or startpos == 0 then startpos = 1 end
	if startpos < 1 then startpos = strlen1 + startpos + 1 end
	if not endpos or endpos == 0 then endpos = strlen1 end
	if endpos < 1 then endpos = strlen1 + endpos + 1 end
	if endpos > strlen1 then --[[print("[STRINGFIND EXEPTION] end position bigger then source string (source string size = "..#where..")")]] Exeption = true end
	if endpos < startpos then --[[print("[STRINGFIND EXEPTION] end position smaller then start position")]] Exeption = true end
	if startpos > strlen1 - strlen2 + 1 then --[[print("[STRINGFIND EXEPTION] string from your start position smaller then string what you want to find")]] Exeption = true end
	if endpos - startpos + 1 < strlen2 then --[[print("[STRINGFIND EXEPTION] section for finding smaller than string what you want to find")]] Exeption = true end
	if Exeption then return false end
	if lowerr then 
		where = bigrustosmall(where)
		what = bigrustosmall(what)
	end
	for i = startpos, endpos do
		if i + strlen2 - 1 > endpos then return false
		elseif string.sub(where, i, i + strlen2 - 1) == what then return i
		end
	end
	return false
end

local NotInitialized = false			--временно
local HostName = game.GetIPAddress()--временно
local Map = game.GetMap()--временно
hook.Add("PlayerInitialSpawn","Server_Info_Initialize",function()
	hook.Remove("PlayerInitialSpawn","Server_Info_Initialize")
	HostName = game.GetIPAddress()
	Map = game.GetMap()
	NotInitialized = false
end)

local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/serverinfo/"
local function SendToWebServer(tbl)
	PrintTable(tbl)
	local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName}
	http.Post(WebServerUrl, TableToSend)
end

timer.Create("Overriding ulx.map for sending info to WebServer",1,0,function()
	if not ulx or not ulx.map then return end
	timer.Remove("Overriding ulx.map for sending info to WebServer")
	print("overriding ulx.map for sending info to WebServer")
	local OldUlxMap = ulx.map
	ulx.map = function(calling_ply, map, gamemode)
		SendToWebServer({"СМЕНА КАРТЫ"})
		OldUlxMap(calling_ply, map, gamemode)
	end
end)

local function GetRouteNumber(ent)
	local RouteNumber = ent:GetNW2Int("RouteNumber",0)
	local RouteNumber1
	local SPB = false
	local Name = ent.SubwayTrain.Name
	if not ent.ASNP and ent.SubwayTrain.Name ~= "81-718" and ent.SubwayTrain.Name ~= "81-703" and ent.SubwayTrain.Name ~= "81-702" and not ent:GetClass():find("_6") then SPB = true end
	if RouteNumber < 10 then RouteNumber1 = "0"..RouteNumber else RouteNumber1 = RouteNumber end
	if SPB and RouteNumber < 100 then RouteNumber1 = "0"..RouteNumber1 else RouteNumber1 = RouteNumber1 end
	return RouteNumber1
end

local function GetTrainRouteNumber(wagon)
	local routenumber = ""
	local RouteNumbers = {}
	for k1,v1 in pairs(wagon.WagonList) do
		local RouteNumber = GetRouteNumber(v1)
		if not tonumber(RouteNumber) or tonumber(RouteNumber) == 0 then continue end
		table.insert(RouteNumbers,1,RouteNumber)
	end
	for k1,v1 in ipairs(RouteNumbers) do
		for k2,v2 in ipairs(RouteNumbers) do
			if k1 == k2 then continue end
			if v1 == v2 then RouteNumbers[k2] = nil end
		end
	end
	for k1,v1 in ipairs(RouteNumbers) do
		routenumber = routenumber == "" and v1 or routenumber.."/"..v1
	end
	
	return routenumber ~= "" and routenumber or 0
end


local function GetTrainDrivers(wag)
	local Drivers = {}
	for k,v in pairs(wag.WagonList) do
		if not IsValid(v) or not v.DriverSeat then continue end
		local Driver = v.DriverSeat:GetDriver()
		if IsValid(Driver) then table.insert(Drivers,1,Driver) end
	end
	
	return Drivers
end

local function GetTrain(ply)
	local Seat = ply:GetVehicle()
	if not IsValid(Seat) then return nil end
	local wagon = Seat:GetNW2Entity("TrainEntity",nil)
	if not IsValid(wagon) then return nil end
	
	local ResultTbl = {}
	ResultTbl.Class = wagon:GetClass()
	ResultTbl.Name = wagon.SubwayTrain.Name
	ResultTbl.RouteNumber = GetTrainRouteNumber(wagon)
	ResultTbl.WagonCount = #wagon.WagonList
	
	local Owner = CPPI and wagon:CPPIGetOwner()
	if IsValid(Owner) then
		ResultTbl.Owner = {}
		ResultTbl.Owner.Nick = Owner:Nick()
		ResultTbl.Owner.SteamID = Owner:SteamID()
	end
	
	local Drivers = GetTrainDrivers(wagon)
	if #Drivers > 0 then
		ResultTbl.Drivers = {}
		for k,v in pairs(Drivers) do
			ResultTbl.Drivers[v:SteamID()] = v:Nick()
		end
	end
	
	ResultTbl.Speed = wagon.Speed < 5 and 0 or math.floor(wagon.Speed)
	
	return ResultTbl
end

local function GetTrains(calling_ply,target_ply,notif,detectroutes)
	if target_ply and not CPPI then return nil end
	local Class1
	local tbl = {}
	local i = 1 
	local NA = "N/A"
	local Class
	for k,v in pairs (Metrostroi.TrainClasses) do							--переношу все найденные паравозы в отдельную таблицу, чтобы потом уже редактировать ее
		local ents = ents.FindByClass(v)
		for k2,v2 in pairs(ents) do
			if target_ply then
				local Owner = v2:CPPIGetOwner()
				if not IsValid(Owner) or Owner ~= target_ply then continue end
			end
			tbl[i] = {}
			tbl[i]["Entity"] = v2
			i = i + 1
		end
	end
	for k,v in pairs(tbl) do	--беру один вагон, смотрю все сцепленные с ним вагоны (они уже есть в таблице) и удаляю все вагоны (кроме первого), если там нет водителя
		Class = v["Entity"].SubwayTrain.Name
		for _k, _v in pairs(v["Entity"].WagonList) do
			if not stringfind(Class, _v.SubwayTrain.Name) then Class = Class.."/".._v.SubwayTrain.Name end	--уточнение вагонов в составе
		end
		for k1,v1 in pairs(v["Entity"].WagonList) do
			if v["Entity"] ~= v1 and not v1:GetDriver() then
				for k2,v2 in pairs(tbl) do
					if v1 == v2["Entity"] then tbl[k2] = nil end
				end
			end
		end
		v["Name"] = Class
		v["WagonCount"] = #v["Entity"].WagonList
		if CPPI then 
			local Owner = v.Entity:CPPIGetOwner()
			if IsValid(Owner) then
				v["Owner"] = {}
				v["Owner"].SteamID = Owner:SteamID()
				v["Owner"].Nick = Owner:Nick()
			end
		end
		v["RouteNumber"] = GetTrainRouteNumber(v["Entity"])
		v["Speed"] = v["Entity"].Speed < 5 and 0 or math.floor(v["Entity"].Speed)
		
		local Drivers = GetTrainDrivers(v["Entity"])
		if #Drivers > 0 then
			v["Drivers"] = {}
			for k1,v1 in pairs(Drivers) do
				v["Drivers"][v1:SteamID()] = v1:Nick()
			end
		end
	end
	
	if notif then
		ulx.fancyLog("Вагонов на сервере: #s", Metrostroi.TrainCount())
		ulx.fancyLog("Составов на сервере: #i", table.Count(tbl))
		
		
	end
	
	if not target_ply and not notif and detectroutes and CPPI then
		for k,v in pairs(tbl) do
			for k1,v1 in pairs(v.Entity.WagonList) do
				for k2,v2 in pairs(tbl) do
					if k2 == k then continue end
					for k3,v3 in pairs(v2.Entity.WagonList) do
						local RouteNumber1 = GetRouteNumber(v1)
						local RouteNumber2 = GetRouteNumber(v3)
						if tonumber(RouteNumber1) ~= 0 or tonumber(GetRouteNumber(v3)) ~= 0 then
							if RouteNumber1 == RouteNumber2 then
								local Owner1 = v1:CPPIGetOwner()
								local Owner2 = v3:CPPIGetOwner()
								if IsValid(Owner1) and IsValid(Owner2) then
									ulx.fancyLogAdmin(Owner1,false,"#A и #T имеют одинковые номера маршрутов!", Owner2)
								end
								local Drivers1 = GetTrainDrivers(v1)
								local Drivers2 = GetTrainDrivers(v3)
								for key,Driver in pairs(Drivers1) do
									if Driver == Owner1 or Driver == Owner2 then continue end
									for key2,Driver2 in pairs(Drivers2) do
										if Driver2 == Owner1 or Driver2 == Owner2 or Driver2 == Driver then continue end -- Driver2 == Driver невозможно, но оставлю на всякий случай
										ulx.fancyLogAdmin(Driver,false,"#A и #T имеют одинковые номера маршрутов!", Driver2)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	return #tbl == 0 and nil or tbl
end

timer.Create("Send Server Info to WebServer",5,0,function()
	if NotInitialized then return end
	local TblToSend = {}
	TblToSend.Map = Map
	TblToSend.Players = {}
	local i = 0
	for k,v in pairs(player.GetHumans()) do
		i = i + 1
		local SteamID = v:SteamID()
		TblToSend.Players[SteamID] = {}
		TblToSend.Players[SteamID].Nick = v:Nick()
		TblToSend.Players[SteamID].Time = math.floor(v:TimeConnected())
		TblToSend.Players[SteamID].InTrain = GetTrain(v)
		TblToSend.Players[SteamID].Trains = GetTrains(nil,v)
		--TblToSend.Players[SteamID].Position = GetPosition(v)
	end
	TblToSend.PlayerCount = i
	TblToSend.MaxPlayers = game.MaxPlayers()
	TblToSend.Trains = GetTrains()
	
	SendToWebServer(TblToSend)
end)

util.AddNetworkString("ScoreBoardAdditional")
local PeregonsTbl = {}
local function MetrostroiInfo(ToNetwork)	
	timer.Create("ScoreBoardAdditional", 5, 0, function()
		for k,v in pairs(PeregonsTbl) do
			if not IsValid(player.GetBySteamID(k)) then PeregonsTbl[k] = nil end
		end
		if not detectstation then print("detectstation is not avaliable") return end
		for k,v in pairs(player.GetAll()) do
			if not IsValid(v) then continue end
			local SteamID = v:SteamID()
			if not PeregonsTbl[SteamID] then PeregonsTbl[SteamID] = {} PeregonsTbl[SteamID][1] = {} PeregonsTbl[SteamID][2] = {} end
			local pos,pos2,path,posx,pos2x,poscurx = detectstation(v:GetPos())
			--if not pos then return end				-- detectstation всегда возвращает pos, поэтому эта строка не нужна?
			local result = pos
			local strsub1 = string.sub(pos,-36) --(ближайшая по треку)
			local strsub2 = string.sub(pos,-42)	--(ближайшая в плоскости)
			if strsub2 == "(ближайшая в плоскости)" then
				if path then
					result = "перегон"
				elseif stringfind(pos,"депо",true) then
					result = "депо"
				else
					result = "-"
				end
			end
			
			if strsub1 == "(ближайшая по треку)" then
				if pos2 then
					result = "перегон "..string.sub(pos,1,-38).." - "..pos2
				else
					result = "тупик "..string.sub(pos,1,-38)
				end
			end
			
			local GetTrainTbl = GetTrain(v)
			local Train = GetTrainTbl.Name and GetTrainTbl.RouteNumber and GetTrainTbl.Name.." ("..GetTrainTbl.RouteNumber..")" or "-"
			local Owner = GetTrainTbl.Owner or ""
			local Speed = GetTrainTbl.Speed
			local Time = ""
			if string.sub(result,1,15) == "перегон " then							--определяю направление движения по ближайшей стации и сохраняю до тех пор, пока человек в перегоне
				if pos2 and strsub1 == "(ближайшая по треку)" then
					local strsub3 = string.sub(pos,1,-38)
					if PeregonsTbl[SteamID][1][1] and PeregonsTbl[SteamID][2][1] then
						if PeregonsTbl[SteamID][1][1] == strsub3 or PeregonsTbl[SteamID][1][1] == pos2 and PeregonsTbl[SteamID][2][1] == strsub3 or PeregonsTbl[SteamID][2][1] == pos2 then
							result = "перегон "..PeregonsTbl[SteamID][1][1].." - "..PeregonsTbl[SteamID][2][1]
							if Train ~= "-" then
								if Speed and Speed > 5 and PeregonsTbl[SteamID][2][2] and poscurx then
									--Speed = Speed * 1000 / 60 / 60
									Time = math.floor((math.abs(PeregonsTbl[SteamID][2][2] - poscurx) / (50 * 1000 / 60 / 60)))
								else
									Time = ""
								end
							end
						end
					else
						PeregonsTbl[SteamID][1][1] = strsub3
						PeregonsTbl[SteamID][2][1] = pos2
						--PeregonsTbl[SteamID][1][2] = posx			--мне не нужа позиция станции отправления
						PeregonsTbl[SteamID][2][2] = pos2x
					end
				else
					PeregonsTbl[SteamID][1] = {}
				end
			else
				PeregonsTbl[SteamID][2] = {}
			end
			
			if ToNetwork then
				net.Start("ScoreBoardAdditional")
					net.WriteString(result)
					net.WriteString(Train)
					net.WriteString(SteamID)
					net.WriteString(path and " (путь "..path..")" or "")
					net.WriteString(Owner)
					net.WriteString(Time)
				net.Broadcast()
			end
		end
	end)
end

