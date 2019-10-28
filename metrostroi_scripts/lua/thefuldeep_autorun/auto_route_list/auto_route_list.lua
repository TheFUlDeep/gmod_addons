--[[============================= string.lower ДЛЯ РУССКИХ СИМВОЛОВ ==========================]]
local BIGRUS = {"А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я"}
local smallrus = {"а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"}

local function bigrustosmall(str)
	for i,letter in pairs(BIGRUS) do
		str = str:gsub(BIGRUS[i],smallrus[i])
	end
	return string.lower(str)
end

--КЛИЕНТ - отрисовка маршрутников из гитхаба https://github.com/TheFUlDeep/gmod_metrostroi_routes_from_google_sheets
if CLIENT then	
	local Font = CreateClientConVar("metrostroi_routes_font", "Trebuchet24", true)--ScrW() default
	local font = Font:GetString()

	local ypos = CreateClientConVar("metrostroi_routes_ypos", 0, true)--ScrH() default
	local xpos = CreateClientConVar("metrostroi_routes_xpos", 0, true)--ScrW() default
	local xPos = xpos:GetInt()
	local yPos = ypos:GetInt()

	local Alph = CreateClientConVar("metrostroi_routes_alph", 30, true)
	local Alph2 = CreateClientConVar("metrostroi_routes_alph2", 0, true)
	local Alph3 = CreateClientConVar("metrostroi_routes_alph3", 0, true)
	local Alph4 = CreateClientConVar("metrostroi_routes_alph4", 0, true)
	local alph = 255-Alph:GetInt()
	local alph2 = 255-Alph2:GetInt()
	local alph3 = 255-Alph3:GetInt()
	local alph4 = 255-Alph4:GetInt()

	local r1ConVar = CreateClientConVar("metrostroi_routes_r1", 0, true)
	local r2ConVar = CreateClientConVar("metrostroi_routes_r2", 255, true)
	local r3ConVar = CreateClientConVar("metrostroi_routes_r3", 255, true)
	local r4ConVar = CreateClientConVar("metrostroi_routes_r4", 0, true)
	local g1ConVar = CreateClientConVar("metrostroi_routes_g1", 0, true)
	local g2ConVar = CreateClientConVar("metrostroi_routes_g2", 255, true)
	local g3ConVar = CreateClientConVar("metrostroi_routes_g3", 255, true)
	local g4ConVar = CreateClientConVar("metrostroi_routes_g4", 0, true)
	local b1ConVar = CreateClientConVar("metrostroi_routes_b1", 0, true)
	local b2ConVar = CreateClientConVar("metrostroi_routes_b2", 255, true)
	local b3ConVar = CreateClientConVar("metrostroi_routes_b3", 255, true)
	local b4ConVar = CreateClientConVar("metrostroi_routes_b4", 0, true)

	local r1 = r1ConVar:GetInt()
	local r2 = r2ConVar:GetInt()
	local r3 = r3ConVar:GetInt()
	local r4 = r4ConVar:GetInt()
	local g1 = g1ConVar:GetInt()
	local g2 = g2ConVar:GetInt()
	local g3 = g3ConVar:GetInt()
	local g4 = g4ConVar:GetInt()
	local b1 = b1ConVar:GetInt()
	local b2 = b2ConVar:GetInt()
	local b3 = b3ConVar:GetInt()
	local b4 = b4ConVar:GetInt()

	local SecretConVar = CreateClientConVar("metrostroi_routes_secret", 0, true)
	local Secret = SecretConVar:GetFloat()

	local RouteList
	local MaxCols = {}
	local Cols = {}

	local h1,w1
	local function GetW(RowNumber,ColNumber)
		local w = 0
		for i = 1,ColNumber do 
			if i == ColNumber then continue end
			w1,h1 = surface.GetTextSize(MaxCols[i] or "")
			w = w1 + w + 10
		end
		return w
	end

	local function GetH(RowNumber)
		local h2 = 0
		for i = 1, RowNumber do
			local w,h = surface.GetTextSize("")
			h2 = h2 + h
		end
		return h2
	end

	local Maxs = {}
	local Lines = {}
	local function MathLines()
		local sdvig = 5
		Lines = {}
		for i = 1,#RouteList-1 do
			Lines[#Lines+1] = {}
			Lines[#Lines].Start = {}
			Lines[#Lines].End = {}

			Lines[#Lines].Start.x = xPos+GetW(i,1) - sdvig
			Lines[#Lines].Start.y = yPos+GetH(i,1)

			Lines[#Lines].End.x = xPos+Maxs[3] -1 -- - sdvig
			Lines[#Lines].End.y = yPos+GetH(i,#Cols)
		end

		for i = 2,#Cols do
			Lines[#Lines+1] = {}
			Lines[#Lines].Start = {}
			Lines[#Lines].End = {}

			Lines[#Lines].Start.x = xPos+GetW(2,i) - sdvig
			if i == 2 then 
				Lines[#Lines].Start.y = yPos
			else
				Lines[#Lines].Start.y = yPos+GetH(2,i)
			end

			Lines[#Lines].End.x = xPos+GetW(#RouteList,i) - sdvig
			Lines[#Lines].End.y = yPos+GetH(#RouteList,i)
		end
	end
	
	local StringsPositions = {}
	
	--detect and convert time
	local function MathCustomTime()
		local CustomTimeConVar = GetConVar("metrostroi_custom_time")
		if not CustomTimeConVar then return end
		
		for k,v in pairs(StringsPositions) do
			if not v.val then --[[print("continue1")]] continue end
			local start1 = v.val:find(":",1,true)
			if not start1 then --[[print("continue2",v.val)]] continue end
			local start2 = v.val:find(":",start1+1,true)
			if not start2 then --[[print("continue3",v.val)]] continue end
			local hours = tonumber(v.val:sub(1,start1-1))
			local minutes = tonumber(v.val:sub(start1+1,start2-1))
			local seconds = tonumber(v.val:sub(start2+1))
			if not hours or not minutes or not seconds then --[[print("continue4",v.val)]] continue end
			
			StringsPositions[k].val = os.date( "!%H:%M:%S" , hours*60*60+minutes*60+seconds+CustomTimeConVar:GetInt()*60*60)
			--print(os.date( "%H:%M:%S" , hours*60*60+minutes*60+seconds))
		end
	end

	local function MathStringsPositions()
		--print("Math")
		if not RouteList then return end
		surface.SetFont(font)
		xPos = xpos:GetInt()
		yPos = ypos:GetInt()
		--[[alph = 255-Alph:GetInt()
		alph2 = 255-Alph2:GetInt()
		alph3 = 255-Alph3:GetInt()
		alph4 = 255-Alph4:GetInt()
		r1 = r1ConVar:GetInt()
		r2 = r2ConVar:GetInt()
		r3 = r3ConVar:GetInt()
		r4 = r4ConVar:GetInt()
		g1 = g1ConVar:GetInt()
		g2 = g2ConVar:GetInt()
		g3 = g3ConVar:GetInt()
		g4 = g4ConVar:GetInt()
		b1 = b1ConVar:GetInt()
		b2 = b2ConVar:GetInt()
		b3 = b3ConVar:GetInt()
		b4 = b4ConVar:GetInt()

		Secret = SecretConVar:GetFloat()]]
		StringsPositions = {}

		Cols = {}
		for RowNumber,Col in pairs(RouteList) do
			for k,v in pairs(Col) do
				if not Cols[k] then Cols[k] = {} end
				Cols[k][RowNumber] = v
			end
		end

		for RowNumber,Col in pairs(RouteList) do
			for ColNumber,val in pairs(Col) do
				if val == "-" then continue end
				if tonumber(val) and val/10 < 1 then val = "0"..val end
				local XPos = xPos+(GetW(RowNumber,ColNumber) or 0)
				local YPos = yPos+(h1 and h1*RowNumber or 0)-(h1 or 0)
				StringsPositions[#StringsPositions+1] = {}
				StringsPositions[#StringsPositions].val = val
				StringsPositions[#StringsPositions].xpos = XPos
				StringsPositions[#StringsPositions].ypos = YPos
				StringsPositions[#StringsPositions].col = ColNumber
				StringsPositions[#StringsPositions].row = RowNumber
				local w,h = surface.GetTextSize(val)
				StringsPositions[#StringsPositions].w = w
				StringsPositions[#StringsPositions].h = h
				StringsPositions[#StringsPositions].wB = math.abs(StringsPositions[#StringsPositions].xpos-xPos)+w
				StringsPositions[#StringsPositions].hB = math.abs(StringsPositions[#StringsPositions].ypos-yPos)+h
			end
		end

		local MaxX,MaxY
		for _,str in pairs(StringsPositions) do
			if not MaxX or MaxX < str.wB then MaxX = str.wB end
			if not MaxY or MaxY < str.hB then MaxY = str.hB end
		end
		Maxs = {MaxX,MaxY,MaxX,GetH(#RouteList)}

		MathLines()
		
		MathCustomTime()
		--PrintTable(StringsPositions)
	end

	net.Receive( "Metrostroi Routes From Google Sheets", function() 
		local IsChatMessage = net.ReadBool()
		local String = net.ReadString()
		if IsChatMessage then 
			chat.AddText(color_white,String) 
			return
		else
			RouteList = util.JSONToTable(String)
			if not RouteList then return end
			--PrintTable(RouteList)
		end

		-----FOR DEBUG---------------------------------------------
		--[[RouteList = {}
		RouteList[1] = {"П № 2","Время хода 08:02"}
		RouteList[2] = {"M № 1","Инт 02:00"}
		RouteList[3] = {nil,"Час","Мин","Cек"}
		RouteList[4] = {"Советская",17,27,04}
		RouteList[5] = {"Артемид-ая",17,28,55}
		RouteList[6] = {"Антиколлаб.",17,30,44}
		RouteList[7] = {"Индустриал.",17,32,34}
		RouteList[8] = {"Площадь Восстания",17,35,06}
		RouteList[9] = {"ОТПР."}
		RouteList[10] = {"П. № 12",17,38,06}]]
		-----FOR DEBUG---------------------------------------------

		--PrintTable(RouteList)

		for RowNumber,Col in pairs(RouteList) do
			for k,v in pairs(Col) do
				if not Cols[k] then Cols[k] = {} end
				Cols[k][RowNumber] = v
			end
		end

		Cols = {}
		for RowNumber,Col in pairs(RouteList) do
			for k,v in pairs(Col) do
				if not Cols[k] then Cols[k] = {} end
				Cols[k][RowNumber] = v
			end
		end

		MaxCols = {}
		surface.SetFont(font)
		for ColNumber,Row in pairs(Cols) do
			local Max,MaxStr
			for RowNumber,v in pairs(Row) do
				if RowNumber < 3 and ColNumber ~= 1 then continue end --отвязал первые две строки от сетки
				local v = tostring(v)
				if not Max or Max < surface.GetTextSize(v) then Max = surface.GetTextSize(v) MaxStr = v end
			end
			MaxCols[ColNumber] = MaxStr
		end
		MathStringsPositions()
	end)

	cvars.AddChangeCallback( "metrostroi_routes_font", function(convar,olval,newval)
		if newval:lower():find("%a") then
			font = newval
			MathStringsPositions()
		else
			chat.AddText(color_white,"Нельзя указать пустой шрифт")
		end
	end)

	cvars.AddChangeCallback( "metrostroi_routes_xpos", function(convar,olval,newval)MathStringsPositions()end)
	cvars.AddChangeCallback( "metrostroi_routes_ypos", function(convar,olval,newval)MathStringsPositions()end)
	cvars.AddChangeCallback( "metrostroi_routes_alph", function(convar,olval,newval)alph = 255-newval end)
	cvars.AddChangeCallback( "metrostroi_routes_alph2", function(convar,olval,newval)alph2 = 255-newval end)
	cvars.AddChangeCallback( "metrostroi_routes_alph3", function(convar,olval,newval)alph3 = 255-newval end)
	cvars.AddChangeCallback( "metrostroi_routes_alph4", function(convar,olval,newval)alph4 = 255-newval end)
	cvars.AddChangeCallback( "metrostroi_routes_r1", function(convar,olval,newval)r1 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_r2", function(convar,olval,newval)r2 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_r3", function(convar,olval,newval)r3 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_r4", function(convar,olval,newval)r4 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_g1", function(convar,olval,newval)g1 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_g2", function(convar,olval,newval)g2 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_g3", function(convar,olval,newval)g3 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_g4", function(convar,olval,newval)g4 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_b1", function(convar,olval,newval)b1 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_b2", function(convar,olval,newval)b2 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_b3", function(convar,olval,newval)b3 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_b4", function(convar,olval,newval)b4 = newval end)
	cvars.AddChangeCallback( "metrostroi_routes_secret", function(convar,olval,newval)Secret = newval end)

	hook.Add( "PopulateToolMenu", "Metrostroi Routes Control Panel", function()
		spawnmenu.AddToolMenuOption( "Utilities", "Metrostroi", "metrostroi_client_panel_routes", "Маршрутники", "", "", function(panel)
			panel:ClearControls()
			panel:NumSlider("Расположение по\nгоризонтали","metrostroi_routes_xpos",0, ScrW(),0)
			panel:NumSlider("Расположение по\nвертикали","metrostroi_routes_ypos",0, ScrH(),0)
			panel:TextEntry("Шрифт","metrostroi_routes_font")
			panel:Help("Простые шрифты можно найти здесь: https://wiki.garrysmod.com/page/Default_Fonts")
			panel:TextEntry("Айди таблицы","metrostroi_routes_setid")
			panel:Button("Загрузить таблицу на сервер","metrostroi_routes_load")
			panel:TextEntry("Выдать мрашрут","metrostroi_routes_setroutenumber")
			panel:TextEntry("Выдать \nмрашрутный лист","metrostroi_routes_setlistnumber")
			panel:Button("Выдать следующий мрашрутный лист","metrostroi_routes_next")
			panel:Button("Выдать предыдущий мрашрутный лист","metrostroi_routes_prev")
			panel:Help("\nЦвета:")
			panel:Help("Фон таблицы")
			panel:NumSlider("Красный","metrostroi_routes_r1",0, 255,0)
			panel:NumSlider("Зеленый","metrostroi_routes_g1",0, 255,0)
			panel:NumSlider("Синий","metrostroi_routes_b1",0, 255,0)
			panel:NumSlider("Прозрачность","metrostroi_routes_alph",0, 255,0)
			panel:Help("\nСетка")
			panel:NumSlider("Красный","metrostroi_routes_r2",0, 255,0)
			panel:NumSlider("Зеленый","metrostroi_routes_g2",0, 255,0)
			panel:NumSlider("Синий","metrostroi_routes_b2",0, 255,0)
			panel:NumSlider("Прозрачность","metrostroi_routes_alph2",0, 255,0)
			panel:Help("\nТекст")
			panel:NumSlider("Красный","metrostroi_routes_r3",0, 255,0)
			panel:NumSlider("Зеленый","metrostroi_routes_g3",0, 255,0)
			panel:NumSlider("Синий","metrostroi_routes_b3",0, 255,0)
			panel:NumSlider("Прозрачность","metrostroi_routes_alph3",0, 255,0)
			panel:Help('\nОбводка текста')
			panel:NumSlider("Красный","metrostroi_routes_r4",0, 255,0)
			panel:NumSlider("Зеленый","metrostroi_routes_g4",0, 255,0)
			panel:NumSlider("Синий","metrostroi_routes_b4",0, 255,0)
			panel:NumSlider("Прозрачность","metrostroi_routes_alph4",0, 255,0)
			panel:NumSlider("Секрет","metrostroi_routes_secret",0, 5)
		end)
	end)

	local LastColorUpdate = CurTime()
	hook.Add( "HUDPaint", "Draw Route List", function()
		if not RouteList then return end
		--[[--старый вариант отрисовки
		yPos = ypos:GetInt()
		xPos = xpos:GetInt()

		surface.SetFont(font)
		for RowNumber,Col in pairs(RouteList) do
			for ColNumber,val in pairs(Col) do
				if val == "-" then continue end
				if tonumber(val) and val/10 < 1 then val = "0"..val end
				local XPos = xPos+(GetW(RowNumber,ColNumber) or 0)
				local YPos = yPos+(h1 and h1*RowNumber or 0)-(h1 or 0)
				local w,h = surface.GetTextSize(val)
				draw.RoundedBox( 10, XPos-2, YPos-1,w+5,h, Color(0, 0, 0, 150))
				draw.SimpleText( val, font, XPos, YPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP )
			end
		end
		]]
		local Secret1 = tonumber(Secret)
		if Secret1 and Secret1 > 0 then
			if CurTime() - LastColorUpdate > Secret1 then
				LastColorUpdate = CurTime()
				Alph:SetInt(math.random(0,255))
				Alph2:SetInt(math.random(0,255))
				Alph3:SetInt(math.random(0,255))
				Alph4:SetInt(math.random(0,255))

				r1ConVar:SetInt(math.random(0,255))
				r2ConVar:SetInt(math.random(0,255))
				r3ConVar:SetInt(math.random(0,255))
				r4ConVar:SetInt(math.random(0,255))

				g1ConVar:SetInt(math.random(0,255))
				g2ConVar:SetInt(math.random(0,255))
				g3ConVar:SetInt(math.random(0,255))
				g4ConVar:SetInt(math.random(0,255))

				b1ConVar:SetInt(math.random(0,255))
				b2ConVar:SetInt(math.random(0,255))
				b3ConVar:SetInt(math.random(0,255))
				b4ConVar:SetInt(math.random(0,255))
			end
		end

		--1 - фон, 2 - сетка, 3 - текст, 4 - фон текста
		surface.SetFont(font)
		draw.RoundedBox( 0, xPos, yPos,Maxs[3] or 0,Maxs[4] or 0, Color(r1,g1,b1,alph))
		surface.SetDrawColor(Color(r2,g2,b2,alph2))
		for _,line in pairs(Lines) do
			surface.DrawLine( line.Start.x, line.Start.y, line.End.x , line.End.y )
		end
		for k,str in pairs(StringsPositions) do
			--print(xPos, yPos,StringsPositions[#StringsPositions].wB,StringsPositions[#StringsPositions].hB)
			--draw.SimpleText( str.val, font, str.xpos, str.ypos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP )
			draw.SimpleTextOutlined( str.val, font, str.xpos, str.ypos, Color( r3, g3, b3, alph3), TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,1,Color(r4,g4,b4,alph4) )
		end
	end)
end

if CLIENT then return end

util.AddNetworkString("Metrostroi Routes From Google Sheets")

local function timeToSec(str)
	local x = string.find(str,":")
	if not x then return tonumber(sec) or 0 end

	local min = tonumber(string.sub(str,1,x-1)) or 0
	local sec = tonumber(string.sub(str,x+1)) or 0
	return min*60+sec,min,sec
end

local function prepareRouteData(routeData,name,ply)
	-- Prepare general route information
	routeData.Duration = 0
	routeData.Name = name
	-- Fix up every station
	for i,stationID in pairs(routeData) do
		if not tonumber(i) then continue end --мое
		routeData[i].ID = i
		routeData[i].TimeOffset = routeData.Duration
		if routeData[i+1] then
			if not Metrostroi.Stations[routeData[i][1]]						then print(Format("No station %d",routeData[i][1])) return end
			if not Metrostroi.Stations[routeData[i][1]][routeData[i][2]]	then print(Format("No platform %d for station %d",routeData[i][2],routeData[i][1])) return end
			if not Metrostroi.Stations[routeData[i+1][1]]					then print(Format("No station %d",routeData[i+1][1])) return end
			if not Metrostroi.Stations[routeData[i+1][1]][routeData[i][2]]	then print(Format("No platform %d for station %d",routeData[i+1][2],routeData[i+1][1])) return end

			-- Get nodes
			local start_node =	Metrostroi.Stations[routeData[i  ][1]][routeData[i  ][2]].node_end
			local end_node =	Metrostroi.Stations[routeData[i+1][1]][routeData[i+1][2]].node_end
			if false and start_node.path ~= end_node.path then	--тут проверка на трэк, возможно ее стоит будет врубить
				print(Format("Platform %d for station %d: path %d; Platform %d for station %d: path %d",
					routeData[i  ][2],routeData[i  ][1],start_node.path.id,
					routeData[i+1][2],routeData[i+1][1],end_node.path.id))
				return
			end

			-- Calculate travel time between two nodes
			local travelTime,travelDistance = Metrostroi.GetTravelTime(start_node,end_node)
			-- Add time for startup and slowdown
			travelTime = travelTime + 25

			-- Remember stats
			routeData.Duration = routeData.Duration + travelTime
			routeData[i].TravelTime = travelTime
			routeData[i].TravelDistance = travelDistance

			-- Print debug information
			print(Format("\t\t[%03d-%d]->[%03d-%d]  %02d:%02d min  %4.0f m  %4.1f km/h",
				routeData[i][1],routeData[i][2],
				routeData[i+1][1],routeData[i+1][2],
				math.floor(travelTime/60),math.floor(travelTime)%60,travelDistance,(travelDistance/travelTime)*3.6))
		else
			routeData.LastID = i
			routeData.LastStation = routeData[i][1]
		end
	end

	-- Add a quick lookup
	routeData.Lookup = {}
	for i,_ in ipairs(routeData) do
		routeData.Lookup[routeData[i][1]] = routeData[i]
	end
end

local function SendChatMessageOrTbl(ply,IsChatMessage,str)
	net.Start("Metrostroi Routes From Google Sheets")
		net.WriteBool(IsChatMessage)
		net.WriteString(str)
	if ply and ply:IsValid() then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local function GetAnyValueFromTable(tbl) --эту функцию можно заменить на получение имени станции на нужном языке
	for _,v in pairs(tbl) do
		return tostring(v)
	end
end


local function GetStationByIndex(index)
	if not Metrostroi or not Metrostroi.StationConfigurations then return end
	index = tonumber(index)
	if not index then return end
	for index1,v in pairs(Metrostroi.StationConfigurations) do
		if not tonumber(index1) or not v.names or not istable(v.names) or table.Count(v.names) < 1 then continue end
		if tonumber(index1) == index then
			return GetAnyValueFromTable(v.names)
		end
	end
end

timer.Simple(0,function()
function Metrostroi.GenerateSchedule(routeID,starts,ends,path)
	Metrostroi.InitializeSchedules()
	
	if not Metrostroi.ScheduleRoutes[routeID] then print("Error generating schedule, line or path not found") return end
	local st = 1
	local fst = not starts
	local en = #Metrostroi.ScheduleRoutes[routeID]
	local fen = not ends
	for k,v in ipairs(Metrostroi.ScheduleRoutes[routeID]) do
		if v[1] == starts and not fst then
			st = k
			fst = true
		end
		if v[1] == ends and not fen then
			en = k
			fen = true
		end
		if fst and fen then break end
	end
	if not fst then print("Metrostroi: Warning! Station "..starts.." not found") st = 1 end
	if not fen then print("Metrostroi: Warning! Station "..ends.." not found") en = #Metrostroi.ScheduleRoutes[routeID] end

	-- Time padding (extra time before schedule starts, wait time between trains)
	local paddingTime = timeToSec("1:30")
	-- Current server time
	local serverTime = Metrostroi.ServerTime()/60
	-- hack
	if routeID == "Line1_Platform2" then
		paddingTime = timeToSec("3:00")
	end

	-- Determine schedule configuration
	local interval
	for _,config in pairs(Metrostroi.ScheduleConfiguration) do
		local t_start = timeToSec(config[1])
		local t_end = timeToSec(config[2])
		if (config[3] == routeID) and (t_start <= serverTime) and (t_end > serverTime) then
			interval = timeToSec(config[4])
		end
		
		interval = timeToSec(config[4])--мое
	end

	-- If no interval, then no schedules available
	if not interval then print("no interval") return end

	-- If no schedules started
	if not Metrostroi.DepartureTime[routeID] then
		Metrostroi.DepartureTime[routeID] = serverTime + paddingTime/60
	else
		-- If schedules started, depart with interval
		Metrostroi.DepartureTime[routeID] = math.max(Metrostroi.DepartureTime[routeID] + interval/60,serverTime + paddingTime/60)
	end

	-- Create new schedule
	Metrostroi.ScheduleID = Metrostroi.ScheduleID + 1
	local schedule = {
		ScheduleID = Metrostroi.ScheduleID,
		Interval = interval,
		Duration = Metrostroi.ScheduleRoutes[routeID].Duration,
	}

	-- Fill out all stations
	local currentTime = Metrostroi.DepartureTime[routeID]
	for id,stationData in ipairs(Metrostroi.ScheduleRoutes[routeID]) do
		if st > id or id > en then continue end
		-- Calculate stop time
		local stopTime = 15
--		if not stationData.TravelTime then stopTime = 0 end

		-- Add entry
		schedule[#schedule+1] = {
			stationData[1],				-- Station
			stationData[2],				-- Platform
			currentTime+stopTime/60,		-- Departure time
			currentTime,				-- Arrival time
		}

		schedule[#schedule].arrivalTimeStr =
			Format("%02d:%02d:%02d",
				math.floor(schedule[#schedule][3]/60),
				math.floor(schedule[#schedule][3])%60,
				math.floor(schedule[#schedule][3]*60)%60)

		-- Add travel time
		if stationData.TravelTime then
			currentTime = currentTime + (stationData.TravelTime + stopTime)/60
		end
	end

	-- Fill out start and end
	schedule.StartStation = schedule[1][1]
	schedule.EndStation = schedule[#schedule][1]
	schedule.StartTime = schedule[1][2]
	schedule.EndTime = schedule[#schedule][2]

	-- Print result
	print(Format("--- %03d --- From %03d to %03d --------------------",
		schedule.ScheduleID,schedule.StartStation,schedule.EndStation))
	
	for i,d in ipairs(schedule) do
		print(Format("\t%03d   %s",d[1],d.arrivalTimeStr))
	end
	--PrintTable(schedule)
	
	return schedule
end
end)

local function RouteIDByStatsionAndPath(starts,ends,path)
	if not starts or not ends or not path then  print("bad args") return end
	for routeID,v in pairs(Metrostroi.ScheduleRoutes) do
		local StartNum,EndNum
		for num,station in pairs(v) do--station[1] - index, station[2] - path
			if not istable(station) then continue end
			if station[2] ~= path then continue end
			if station[1] == starts then StartNum = num end
			if station[1] == ends then EndNum = num end
		end
		if StartNum and EndNum and StartNum < EndNum then 
			return routeID 
		else
			continue
		end
	end
end

local function GenerateSchedule1(starts,ends,path)
	local routeID = RouteIDByStatsionAndPath(starts,ends,path) or ""
	--if not routeID then SendChatMessageOrTbl(ply,false,"") return end
	return Metrostroi.GenerateSchedule(routeID,starts,ends,path)
	
	--[[local TblToSend = {}
	for i,d in ipairs(nt.metrostroi_route_list) do
		TblToSend[i] = TblToSend[k] or {}
		TblToSend[i][1] = GetStationByIndex(d[1])
		TblToSend[i][2] = d.arrivalTimeStr
	end
	
	SendChatMessageOrTbl(ply,false,util.TableToJSON(TblToSend))]]
end

local function GetValuesFromTable(tbl,startindex,endindex)
	if not tbl[endindex] then return end
	local tabl = {}
	for k,v in ipairs(tbl) do
		if k >= startindex or k <= endindex then table.insert(tabl,v) end
	end
	
	return tabl
end

local function GetPlatformByIndex(index)
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
		if not IsValid(Platform) then continue end
		if Platform.StationIndex == index then return Platform end
	end
end

local function GenerateRoutes()
	if not Metrostroi or not Metrostroi.StationConfigurations then return end
	
	Metrostroi.StationNames = {}
	
	local IndexesToSort = {}
	
	--[[for index,v in pairs(Metrostroi.StationConfigurations) do --поиск индексов по луа файлу станций
		if not tonumber(index) or not v.names or not istable(v.names) or table.Count(v.names) < 1 then continue end
		local index = tonumber(index)
		if not GetPlatformByIndex(index) then continue end
		--Metrostroi.StationNames[index] = GetAnyValueFromTable(v.names)
		table.insert(IndexesToSort,index)
	end]]
	
	--поиск индексов по платформам
	local IndexesWas = {}
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
		if not IsValid(Platform) or not Platform.StationIndex then continue end
		local index = tonumber(Platform.StationIndex)
		if not index then continue end
		if IndexesWas[index] then continue end
		IndexesWas[index] = true
		Metrostroi.StationNames[index] = GetStationByIndex(index) or "ERROR"--"ERROR" потому что "" не будет создавать маршрут
		table.insert(IndexesToSort,index)
	end
	
	table.sort(IndexesToSort,function(a,b) return a < b end)
	
	local SortedNames = IndexesToSort
	
	if not SortedNames or not istable(SortedNames) or #SortedNames < 2 then return end
	
	local Routes = {}
	
	for index,stationindex in pairs(SortedNames) do
		for forw = 1,2 do
			for i = 1,2 do
				local Line = tostring(stationindex):sub(1,1)
				Routes[Line.."-"..i.."-"..forw] = Routes[Line.."-"..i.."-"..forw] or  {}-- line-path-forw
				Routes[Line.."-"..i.."-"..forw][index] = {stationindex,i}
			end
		end
	end
	
	for RouteName,v in pairs(Routes) do
		if RouteName:sub(-1,-1) == "2" then Routes[RouteName] = table.Reverse(v) end
	end
	
	--PrintTable(Routes)
	

	local data = {}
	data.Configuration = {{0,0,0,"1:00"}} -- интервал в одну минуту
	
	data.Routes = Routes
	
	Metrostroi.LoadSchedulesData(data)
end

timer.Simple(0,function()
	GenerateRoutes()
end)

concommand.Add("metrostroi_schedules_generate",GenerateRoutes)

--concommand.Add("metrostroi_route_list", function(ply, _, args)
--	GenerateSchedule1(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]),ply)
--end)
--metrostroi_print_scheduleinfo
--metrostroi_resetschedules

local function GetStationIndexByName(str)
	if not str or not Metrostroi or not Metrostroi.StationConfigurations then return end
	
	for index,v in pairs(Metrostroi.StationConfigurations) do
		if not tonumber(index) or not v.names or not istable(v.names) or table.Count(v.names) < 1 then continue end
		local index = tonumber(index)
		for _,name in pairs(v.names) do
			if bigrustosmall(name) == str then return index end
		end
	end
end

local function GetStationIndexByNameFromPA(ent,StationName)
	local Path = ent:ReadCell(49170)
	local Line = 1
	local stations = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path] and Metrostroi.PAMConfTest[Line][Path][1] and Metrostroi.PAMConfTest[Line][Path][1].stations
	if not stations or not istable(stations) then return end
	for _,v in pairs(stations) do
		if not v.name or not v.id or not tonumber(v.id) then continue end
		if v.isLast then return tonumber(v.id) end
		--if bigrustosmall(v.name) == StationName then return tonumber(v.id) end
	end

end

local function GetLastStation(self)
	if not Metrostroi.StationConfigurations
	then
		return nil
	else
		local Station
		if not Station and Metrostroi.ASNPSetup then --искать станцию только если аснп полностью настроен
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = self:GetNW2Int("ASNP:State",0) >=7 and Selected and Selected[self:GetNW2Int("ASNP:Line",0)] or nil
			local Path = self:GetNW2Bool("ASNP:Path",false)
			Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil
			if Station then Station = Station[1] or nil end
			--if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			if not Station then
				local Line = Selected and Selected[self:GetNW2Int("RRI:Line",0)] or nil
				Station = Line and Line[self:GetNW2Int("RRI:LastStation",0)] or nil
				if Station then Station = Station[1] or nil end
				--if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			end
		end
		if not Station and Metrostroi.SarmatUPOSetup and self:GetNW2Int("SarmatState",0) > 0 then
			local Selected = Metrostroi.SarmatUPOSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("SarmatLine",0)] or nil
			local Path = self:GetNW2Bool("SarmatPath",false)
			Station = Line and (not Path and Line[self:GetNW2Int("SarmatEndStation",0)] or Path and Line[self:GetNW2Int("SarmatStartStation",0)]) or nil
			Station = Station and Station[1] or nil
			--if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
		end
		if not Station and Metrostroi.RRISetup then
			local Line = Metrostroi.RRISetup[self:GetNW2Int("RRI:Line",0)] or nil
			Station = Line and Line[self:GetNW2Int("RRI:LastStation",0)] or nil
			Station = Station and Station[1] or nil
			--if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
		end
		if not Station and self:GetNW2String("PAM:TargetStation","") ~= "" then
			local StationName = bigrustosmall(self:GetNW2String("PAM:TargetStation"))
			Station = GetStationIndexByNameFromPA(self,StationName) or GetStationIndexByName(StationName)
		end
		--[[if not Station and Metrostroi.UPOSetup  --не хочу пихать первую станцию на линии без возможности настройки
		and self:GetNW2Int("SarmatState",-228) == -228 
		and self:GetNW2Int("ASNP:State",-228) == -228 
		and self:GetNW2Int("RRI:Line",-228) == -228 
		then
			local Path = self:ReadCell(49170)
			local Line = 1
			local tbl = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path]
			Station = tbl and tbl[1] and tbl[1].stations and tbl[1].stations[#tbl[1].stations] and tbl[1].stations[#tbl[1].stations].id
		end]]
		
		if not Station then return end
		
		local FirstStation
		if not FirstStation and Metrostroi.ASNPSetup then
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = self:GetNW2Int("ASNP:State",0) >=7 and Selected and Selected[self:GetNW2Int("ASNP:Line",0)] or nil
			local Path = self:GetNW2Bool("ASNP:Path",false)
			FirstStation = Line and (Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or not Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil
			if FirstStation then FirstStation = FirstStation[1] or nil end
			--if FirstStation and (not tonumber(FirstStation) or not Line.Loop and (FirstStation == Line[#Line][1] or FirstStation == Line[1][1])) then FirstStation = nil end
			if not FirstStation then
				local Line = Selected and Selected[self:GetNW2Int("RRI:Line",0)] or nil
				FirstStation = Line and Line[self:GetNW2Int("RRI:FirstStation",0)] or nil
				if FirstStation then FirstStation = FirstStation[1] or nil end
				--if FirstStation and (not tonumber(FirstStation) or not Line.Loop and (FirstStation == Line[#Line][1] or FirstStation == Line[1][1])) then FirstStation = nil end
			end
		end
		if not FirstStation and Metrostroi.SarmatUPOSetup and self:GetNW2Int("SarmatState",0) > 0 then
			local Selected = Metrostroi.SarmatUPOSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("SarmatLine",0)] or nil
			local Path = self:GetNW2Bool("SarmatPath",false)
			FirstStation = Line and (Path and Line[self:GetNW2Int("SarmatEndStation",0)] or not Path and Line[self:GetNW2Int("SarmatStartStation",0)]) or nil
			FirstStation = FirstStation and FirstStation[1] or nil
			--if FirstStation and (not tonumber(FirstStation) or not Line.Loop and (FirstStation == Line[#Line][1] or FirstStation == Line[1][1])) then FirstStation = nil end
		end
		if not FirstStation and Metrostroi.RRISetup then
			local Line = Metrostroi.RRISetup[self:GetNW2Int("RRI:Line",0)] or nil
			FirstStation = Line and Line[self:GetNW2Int("RRI:FirstStation",0)] or nil
			FirstStation = FirstStation and FirstStation[1] or nil
			--if FirstStation and (not tonumber(FirstStation) or not Line.Loop and (FirstStation == Line[#Line][1] or FirstStation == Line[1][1])) then FirstStation = nil end
		end
		if not FirstStation and self:GetNW2String("PAM:StationS","") ~= "" then
			FirstStation = tonumber(self:GetNW2String("PAM:StationS"))
		end
		
		--[[if not FirstStation and Metrostroi.UPOSetup --не хочу пихать последнюю станцию на линии без возможности настройки
		and self:GetNW2Int("SarmatState",-228) == -228 
		and self:GetNW2Int("ASNP:State",-228) == -228 
		and self:GetNW2Int("RRI:Line",-228) == -228 
		then
			local Path = self:ReadCell(49170)
			local Line = 1
			local tbl = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path]
			FirstStation = tbl and tbl[1] and tbl[1].stations and tbl[1].stations[1] and tbl[1].stations[1].id
		end]]
		
		--print(Station)
		
		return FirstStation,Station
	end
end

local TrackIDPaths = {}

timer.Simple(0,function()
	for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
		if not IsValid(Platform) or not Platform.PlatformEnd or not Platform.PlatformStart or not Platform.PlatformIndex then continue end
		
		local track = Metrostroi.GetPositionOnTrack(LerpVector(0.5, Platform.PlatformEnd, Platform.PlatformStart))
		if not track[1] or not track[1].path or not track[1].path.id then continue end
		
		TrackIDPaths[track[1].path.id] = Platform.PlatformIndex
	end
end)

hook.Add("PlayerInitialSpawn","metrostroi_schedules_generate for metrostroi_auto_route_lists",function()
	hook.Remove("PlayerInitialSpawn","metrostroi_schedules_generate for metrostroi_auto_route_lists")
	timer.Simple(5,function()
	
		for _,Platform in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(Platform) or not Platform.PlatformEnd or not Platform.PlatformStart or not Platform.PlatformIndex then continue end
			
			local track = Metrostroi.GetPositionOnTrack(LerpVector(0.5, Platform.PlatformEnd, Platform.PlatformStart))
			if not track[1] or not track[1].path or not track[1].path.id then continue end
			
			TrackIDPaths[track[1].path.id] = Platform.PlatformIndex
		end
	
		GenerateRoutes()
	end)
end)

local function GetPath(vec)
	local Track = Metrostroi.GetPositionOnTrack(vec)
	if not Track[1] or not Track[1].path or not Track[1].path.id then return end
	
	return Track[1].path.id
end

--[[
Что можно сделать
	При continue отправлять водителям пустой стринг
]]
timer.Create("Update/Set Route list",1,0,function()
	--расписание присваивается поезду. Если игрок в составе, то дать ему это расписание, иначе отнять
	if not Metrostroi or not Metrostroi.TrainClasses then return end
	for _,trainclass in pairs(Metrostroi.TrainClasses) do
		for _,wag in pairs(ents.FindByClass(trainclass)) do
			if not IsValid(wag) or not wag.DriverSeat or not IsValid(wag.DriverSeat:GetDriver()) --[[or not wag.SubwayTrain or wag.SubwayTrain.WagType ~= 1]] then --[[print("continue1")]] continue end-- нужен машинист в кабине
			
			wag.metrostroi_route_list = wag.metrostroi_route_list or {}
			
			local metrostroi_route_list = wag.metrostroi_route_list
			
			local FirstStation,LastStation = GetLastStation(wag)
			FirstStation = tonumber(FirstStation)
			LastStation = tonumber(LastStation)
			if not FirstStation or not LastStation then --[[metrostroi_route_list.list = nil]] --[[print("continue2",FirstStation,LastStation)]] continue end
			
			local TrackID = GetPath(wag:GetPos())
			if not TrackID or not TrackIDPaths[TrackID] then --[[metrostroi_route_list.list = nil]] --[[print("continue3",TrackID)]] continue end
			TrackID = TrackIDPaths[TrackID]
			
			if not metrostroi_route_list.list -- если маршрутника никогда не было, то он выдастся при настройке информатора. Если же он уже есть, то поменяется только при движении и при ненулевом реверсе
			or (TrackID ~= metrostroi_route_list.Track 
			or FirstStation ~= metrostroi_route_list.FirstStation 
			or LastStation ~= metrostroi_route_list.LastStation)
			and wag.Speed and wag.Speed > 5--если скорость больше пяти
			and (wag.KV and wag.KV.ReverserPosition ~= 0--если реверс не в нуле
			or wag.KR and wag.KR.Position ~= 0
			or wag.KRO and wag.KRO.Value ~= 1
			or wag.RV and wag.RV.KROPosition ~= 0)
			then
				metrostroi_route_list.Track = TrackID
				metrostroi_route_list.FirstStation = FirstStation
				metrostroi_route_list.LastStation = LastStation
				
				metrostroi_route_list.list = GenerateSchedule1(FirstStation,LastStation,TrackID)
				
			end
			
			if not metrostroi_route_list.list then --[[print("continue4",metrostroi_route_list.list)]] continue end
			
			
			for i = 1,5 do
				local seat = i == 1 and "DriverSeat" or i == 2 and "InstructorsSeat" or i == 3 and "ExtraSeat1" or i == 4 and "ExtraSeat2" or i == 5 and "ExtraSeat3"
				if not wag[seat] then continue end
				local Driver = wag[seat]:GetDriver()
				if not IsValid(Driver) then --[[print("continue5",Driver)]] continue end
				
				local TblToSend = {}
				for i,d in ipairs(metrostroi_route_list.list) do
					TblToSend[i] = TblToSend[i] or {}
					TblToSend[i][1] = GetStationByIndex(d[1]) or "ERROR"
					TblToSend[i][2] = d.arrivalTimeStr
				end
				
				SendChatMessageOrTbl(Driver,false,util.TableToJSON(TblToSend))
			end
			
		end
	end
	
	for _,ply in pairs(player.GetHumans()) do
		if not ply:InVehicle() then SendChatMessageOrTbl(ply,false,"") end
	end
end)


