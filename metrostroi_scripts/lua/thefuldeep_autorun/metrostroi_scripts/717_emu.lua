--TODO не создавать новую камеру, а двигать имеющиеся
local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "Электронный"

local tablename = "RouteNumberType"
local readtablename = "Тип номера маршрута"

if CLIENT then
	MetrostroiWagNumUpdateRecieve = MetrostroiWagNumUpdateRecieve or function(index)
		local ent = Entity(index)
		--таймер, чтобы дождаться обновления сетевых значений (ну а вдруг)
		timer.Simple(0.3,function()
			if IsValid(ent) and ent.UpdateWagNumCallBack then 
				ent:UpdateWagNumCallBack()
				--ent:UpdateTextures()
			end
		end)
	end
end

if SERVER then
	local hooks = hook.GetTable()
	if not hooks.MetrostroiSpawnerUpdate or not hooks.MetrostroiSpawnerUpdate["Call hook on clientside"] then
		hook.Add("MetrostroiSpawnerUpdate","Call hook on clientside",function(ent)
			if not IsValid(ent) then return end
			local idx = ent:EntIndex()
			for _,ply in pairs(player.GetHumans())do
				if IsValid(ply)then ply:SendLua("MetrostroiWagNumUpdateRecieve("..idx..")")end
			end
		end)
	end
end

local function RemoveEnt(wag,prop)
	local ent = wag.ClientEnts and wag.ClientEnts[prop]
	if IsValid(ent) then SafeRemoveEntity(ent)end
end

local function UpdateModelCallBack(ENT,cprop,modelcallback,callback,precallback)	
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	if modelcallback then
		local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
		ENT.ClientProps[cprop].modelcallback = function(wag,...)
			return modelcallback(wag) or oldmodelcallback(wag,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if precallback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			precallback(wag,cent)
			oldcallback(wag,cent,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if callback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			oldcallback(wag,cent,...)
			callback(wag,cent)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
end

hook.Add("InitPostEntity","Metrostroi 717_mvm emu",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if ENT then ENT = ENT.t else return end
	if not ENT.Spawner then return end
	
	local foundtable
	for k,v in pairs(ENT.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(ENT.Spawner,6,{tablename,readtablename,"List",{"Default",paramname}})
		inserted_index = 2
	else
		inserted_index = table.insert(ENT.Spawner[foundtable][4],paramname)
	end
	
	if SERVER then return end
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	local oldinit = ENT.Initialize
	ENT.Initialize = function(self,...)
		oldinit(self,...)
		if self.LastStation then
			local oldthink = self.LastStation.ClientThink
			self.LastStation.ClientThink = function(sys,...)
				if not IsValid(self.ClientEnts[sys.EntityName]) then return end
				oldthink(sys,...)
			end
		end
	end
	
	table.insert(ENT.Cameras,{Vector(407.5+75,0.3,44.5),Angle(20,180,0),"Train.Common.LastStation"})
	
	ENT.LastGettedLastStationForEmu = 0
	
	ENT.ButtonMap["EMU"] = {
		pos = Vector(461,-28,54),
		ang = Angle(0,90,90),
		width = 1,
		height = 1,
		scale = 0.1,
	}
	
	ENT.ButtonMap["EMU1"] = {
		pos = Vector(461,-28,54),
		ang = Angle(0,90,90),
		width = 1,
		height = 1,
		scale = 0.15,
	}
	
	local function GetLastStation(self)
		if not Metrostroi.StationConfigurations or not Metrostroi.ASNPSetup then
			return "Обкатка"
		else
			if self.ASNPState < 7 then return "Посадки нет" end
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)]
			local Line = Selected and Selected[self:GetNW2Int("ASNP:Line",0)]
			local Path = self:GetNW2Bool("ASNP:Path",false)
			local Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil		--красивый враиант. Спереди показывается одна станция, сзади другая
			--local Station = Line and Line[self:GetNW2Int("ASNP:LastStation",0)] or nil		--вариант, как в реальности. То есть и спереди и сзади одна и та же станция
			if Station then Station = Station[2] or nil end
			if Line and not Station then Station = "Кольцевая" end
			if Station then return Station else return "Посадки нет" end
		end
	end
	
	--копирую код функции utf8.sub, потому что иногда клиент ее не видит, по какой-то причине
	local function strRelToAbsChar( str, pos )--getted from https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/utf8.lua#L364-L377
		if pos < 0 then
			pos = math.max( pos + utf8.len( str ) + 1, 0 )
		end
		return pos
	end
	local function GetChar( str, idx )
		idx = strRelToAbsChar( str, idx )

		if idx == 0 then return "" end
		if idx > utf8.len( str ) then return "" end

		local off = utf8.offset( str, idx - 1 )
		return utf8.char( utf8.codepoint( str, off ) )
	end
	local function sub( str, charstart, charend )
		charstart = strRelToAbsChar( str, charstart )
		charend = strRelToAbsChar( str, charend or -1 )

		local buf = {}
		for i = charstart, charend do
			buf[#buf + 1] = GetChar( str, i )
		end

		return table.concat( buf )
	end
	
	local sogltbl = {"б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ"}
	for i = 1, #sogltbl do
		sogltbl[sogltbl[i]] = true
		sogltbl[i] = nil
	end
	local maxlen = 19
	local function ShortingString(str)
		local len = utf8.len(str)
		if len <= maxlen then return str end
		for i = maxlen,1,-1 do
			if sogltbl[sub(str,i,i)] then
				return sub(str,1,i).."."
			end
		end
		return sub(str,1,maxlen).."."
	end
	
	local oldDrawPost = ENT.DrawPost
	ENT.DrawPost = function(self,...)
		oldDrawPost(self,...)
		
		local ClientEnts = self.ClientEnts
		if not ClientEnts or (not IsValid(ClientEnts.destination) and not IsValid(ClientEnts.destination1)) then return end
		
		if self:GetNW2Int(tablename,0) ~= inserted_index then return end
		if os.time() - self.LastGettedLastStationForEmu > 1 then
			self.LastGettedLastStationForEmu = os.time()
			self.ASNPState = self:GetNW2Int("ASNP:State",-1)
			self.GettedLastStationForEmu = ShortingString(GetLastStation(self))
		end
		if self.ASNPState < 1 or self:GetPackedRatio("BatteryVoltage") == 0 then return end
		
		
		self:DrawOnPanel("EMU1",function()
			local rn = Format("%02d",self:GetNW2Int("ASNP:RouteNumber",0))
			draw.Text({
				text = rn,
				font = "Metrostroi_Tickers",
				pos = { 44, 90 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = color_0_255_0})
		end)
		self:DrawOnPanel("EMU",function()
			draw.Text({
				text = self.GettedLastStationForEmu,
				font = "Metrostroi_Tickers",
				pos = { 315	, 135 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = color_0_255_0})
		end)
	end
	
	
	for i = 1,2 do
		local propname = i == 1 and "destination" or "destination1"
		UpdateModelCallBack(
			ENT,
			propname,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-720/720_tablo.mdl" end
			end,
			function(wag,cent)
				if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
				cent:SetPos(wag:LocalToWorld(Vector(460*2+1,0,-12)))
			end
		)
	end
	
	local oldupdate = ENT.UpdateWagNumCallBack
	ENT.UpdateWagNumCallBack = function(wag)
		wag:ShowHide("route",true)
		wag:ShowHide("route1",true)
		wag:ShowHide("route2",true)
		wag:HidePanel("Route",false)
		wag:HidePanel("LastStation",false)
		oldupdate(wag)
		if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
		wag:ShowHide("route",false)
		wag:ShowHide("route1",false)
		wag:ShowHide("route2",false)
		wag:HidePanel("Route",true)
		wag:HidePanel("LastStation",true)
	end
	
	--если UpdateWagNumCallBack не вызвалась из-за того, что состав уже был
	UpdateModelCallBack(
		ENT,
		"route",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then wag:ShowHide("route",false)end
		end
	)
	UpdateModelCallBack(
		ENT,
		"route1",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then wag:ShowHide("route1",false)end
		end
	)
	UpdateModelCallBack(
		ENT,
		"route2",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then wag:ShowHide("route2",false)end
		end
	)
	
end)

