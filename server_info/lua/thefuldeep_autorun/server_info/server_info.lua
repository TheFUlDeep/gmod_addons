if CLIENT then return end


local NotInitialized = false --временно
local HostName = game.GetIPAddress()--временно
local Map = game.GetMap()--временно
hook.Add("PlayerInitialSpawn","Server_Info_Initialize",function()
	hook.Remove("PlayerInitialSpawn","Server_Info_Initialize")
	HostName = game.GetIPAddress()
	Map = game.GetMap()
	NotInitialized = false
end)

local WebServerUrl = "http://thefuldeep.ddns.net/serverinfo/"
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

local function GetTrain(ent)
	local wagon
	if ent.SteamID then
		local Seat = ent:GetVehicle()
		if not IsValid(Seat) then return nil end
		wagon = Seat:GetNW2Entity("TrainEntity",nil)
	else
		wagon = ent
	end
	
	if not IsValid(wagon) then return end
	
	local ResultTbl = {}
	--ResultTbl.Class = wagon:GetClass()
	ResultTbl.Name = wagon.SubwayTrain.Name
	ResultTbl.RouteNumber = GetTrainRouteNumber(wagon)
	ResultTbl.WagonCount = #wagon.WagonList
	ResultTbl.Entity = wagon
	
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
			table.insert(ResultTbl.Drivers,1,{SteamID = v:SteamID(),Nick = v:Nick()})
		end
	end
	
	ResultTbl.Speed = wagon.Speed < 5 and 0 or math.floor(wagon.Speed)
	
	-- TODO ResultTbl["Position"] = 
	
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
				table.insert(v["Drivers"],1,{SteamID = v1:SteamID(), Nick = v1:Nick()})
			end
		end
	end
	
	local tbl2 = {}
	for k,v in pairs(tbl) do
		table.insert(tbl2,1,v)
	end
	
	tbl = tbl2
	
	if notif then
		ulx.fancyLog("Вагонов на сервере: #s", Metrostroi.TrainCount())
		ulx.fancyLog("Составов на сервере: #i", table.Count(tbl))
		for k,v in pairs(tbl) do
			if not v.Owner or not v.RouteNumber or not v.WagonCount then continue end
			ulx.fancyLogAdmin(player.GetBySteamID(v.Owner.SteamID),false,"Владелец #A, маршрут #s, вагонов #s", tostring(v.RouteNumber),tostring(v.WagonCount))
			if v.Drivers then
				local DriversCount = table.Count(v.Drivers)
				if DriversCount > 1 then
					local DriversString = ""
					for k1,v1 in pairs(v.Drivers) do
						DriversString = DriversString == "" and v1.Nick or DriversString..", "..v1.Nick
					end
					ulx.fancyLog("управляют #s", DriversString)
				elseif DriversCount == 1 then
					ulx.fancyLogAdmin(player.GetBySteamID(v.Drivers[1].SteamID),"управляет #A")
				end
			end
		end
		
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

GetTrains(nil,nil,true)

local PeregonsTbl = {}
local function ScoreBoardFunction(ent)
	for k,v in pairs(PeregonsTbl) do
		if --[[not IsValid(player.GetBySteamID(k)) and]] not IsValid(ents.GetByIndex(k)) then PeregonsTbl[k] = nil end
	end
	
	local vector = ent:GetPos()
	local ID = --[[ent.SteamID and ent:SteamID() or]] ent:EntIndex()
	
	--for k,v in pairs(player.GetHumans()) do
		if not PeregonsTbl[ID] then PeregonsTbl[ID] = {} PeregonsTbl[ID][1] = {} PeregonsTbl[ID][2] = {} end
		local pos,pos2,path,posx,pos2x,poscurx = detectstation(vector)
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
		
		local GetTrainTbl = GetTrain(ent)
		local Train = GetTrainTbl and GetTrainTbl.Name and GetTrainTbl.RouteNumber and GetTrainTbl.Name.." ("..GetTrainTbl.RouteNumber..")" or "-"
		local Owner = GetTrainTbl and GetTrainTbl.Owner and GetTrainTbl.Owner.Nick or ""
		local Speed = GetTrainTbl and GetTrainTbl.Speed
		local Time = ""
		local Dist = ""
		if string.sub(result,1,15) == "перегон " then							--определяю направление движения по ближайшей стации и сохраняю до тех пор, пока человек в перегоне
			if pos2 and strsub1 == "(ближайшая по треку)" then
				local strsub3 = string.sub(pos,1,-38)
				if PeregonsTbl[ID][1][1] and PeregonsTbl[ID][2][1] then
					if PeregonsTbl[ID][1][1] == strsub3 or PeregonsTbl[ID][1][1] == pos2 and PeregonsTbl[ID][2][1] == strsub3 or PeregonsTbl[ID][2][1] == pos2 then
						result = "перегон "..PeregonsTbl[ID][1][1].." - "..PeregonsTbl[ID][2][1]
					end
				else
					PeregonsTbl[ID][1][1] = strsub3
					PeregonsTbl[ID][2][1] = pos2
					--PeregonsTbl[ID][1][2] = posx			--мне не нужа позиция станции отправления
					PeregonsTbl[ID][2][2] = pos2x
				end
				
				if PeregonsTbl[ID][2][2] and poscurx then
					Dist = math.floor(math.abs(PeregonsTbl[ID][2][2] - poscurx))
					if Speed and Speed > 5 then
						--Speed = Speed * 1000 / 60 / 60
						Time = math.floor((math.abs(PeregonsTbl[ID][2][2] - poscurx) / (50 * 1000 / 60 / 60)))
					end
				end
				
			else
				PeregonsTbl[ID][1] = {}
			end
		else
			PeregonsTbl[ID][2] = {}
		end
	--end
		return result,Train,ID,path,Owner,Time,Dist
end


util.AddNetworkString("ScoreBoardAdditional")
local function MetrostroiInfo()	
	if not detectstation then print("detectstation is not avaliable") return end
	for k,v in pairs(player.GetHumans()) do
		local result,Train,SteamID,path,Owner,Time,Dist = ScoreBoardFunction(v)
		net.Start("ScoreBoardAdditional")
			net.WriteString(result)
			net.WriteString(Train)
			net.WriteString(SteamID)
			net.WriteString(path and " (путь "..path..")" or "")
			net.WriteString(Owner)
			net.WriteString(Time)
			net.WriteString(Dist)
		net.Broadcast()
	end
end

timer.Create("ScoreBoardAdditional", 5, 0, MetrostroiInfo)

local function PrepareDataToSending()
	if NotInitialized then return end
	if not detectstation then print("detectstation is not avaliable") return end
	local TblToSend = {}
	TblToSend.Map = Map
	local Humans = player.GetHumans()
	local i = 0
	if table.Count(Humans) > 0 then
		TblToSend.Players = {}
		for k,v in pairs(player.GetHumans()) do
			local Index = table.Count(TblToSend.Players) + 1
			i = i + 1
			
			TblToSend.Players[Index] = {}
			TblToSend.Players[Index].SteamID = v:SteamID()
			TblToSend.Players[Index].Nick = v:Nick()
			TblToSend.Players[Index].Time = math.floor(v:TimeConnected())
			
			local result,Train,ID,path,Owner,Time,Dist = ScoreBoardFunction(v)
			if result and result ~= "" then TblToSend.Players[Index].Position = result end
			if path and path ~= "" then TblToSend.Players[Index].Path = path end
			if Time and Time ~= "" then TblToSend.Players[Index].ArrTime = Time end
			if Dist and Dist ~= "" then TblToSend.Players[Index].ArrDist = Dist end
			
			
			TblToSend.Players[Index].InTrain = GetTrain(v)
			if TblToSend.Players[Index].InTrain then
				local result,Train,ID,path,Owner,Time,Dist = ScoreBoardFunction(TblToSend.Players[Index].InTrain.Entity)
				local Speed = math.floor(TblToSend.Players[Index].InTrain.Entity.Speed)
				Speed = Speed > 5 and Speed or 0
				TblToSend.Players[Index].InTrain.Speed = Speed
				
				if Time and Time ~= "" then 
					TblToSend.Players[Index].InTrain.ArrTime = Time 
					TblToSend.Players[Index].ArrTime = Time 
				end
				if Dist and Dist ~= "" then TblToSend.Players[Index].InTrain.ArrDist = Dist end
			end
				
			TblToSend.Players[Index].Trains = GetTrains(nil,v)
			if #TblToSend.Players[Index].Trains < 1 then TblToSend.Players[Index].Trains = nil end
			if TblToSend.Players[Index].Trains then
				for k1,v1 in pairs(TblToSend.Players[Index].Trains) do
					if v1.Entity then
						local result,Train,ID,path,Owner,Time,Dist = ScoreBoardFunction(v1.Entity)
						if result and result ~= "" then v1.Position = result end
						if path and path ~= "" then v1.Path = path end
						if Time and Time ~= "" then v1.ArrTime = Time end
						if Dist and Dist ~= "" then v1.ArrDist = Dist end
					end
				end
			end
			--TblToSend.Players[Index].Position = GetPosition(v)
		end
	end
	TblToSend.PlayerCount = i
	TblToSend.MaxPlayers = game.MaxPlayers()
	TblToSend.Trains = GetTrains()
	if table.Count(TblToSend.Trains) < 1 then TblToSend.Trains = nil end
	if TblToSend.Trains then
		for k,v in pairs(TblToSend.Trains) do
			if v.Entity then
				local result,Train,ID,path,Owner,Time,Dist = ScoreBoardFunction(v.Entity)
				if result and result ~= "-" then v.Position = result end
				if path and path ~= "" then v.Path = path end
				if Time and Time ~= "" then v.ArrTime = Time end
				if Dist and Dist ~= "" then v.ArrDist = Dist end
			end
		end
	end
	
	return TblToSend
end

timer.Create("UpdatePeregonsTbl",1,0,PrepareDataToSending)

timer.Create("Send Server Info to WebServer",5,0,function()
	TblToSend = PrepareDataToSending()
	
	SendToWebServer(TblToSend)
end)


