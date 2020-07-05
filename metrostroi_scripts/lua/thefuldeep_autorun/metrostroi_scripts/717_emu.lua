local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "Электронный"

local tablename = "RouteNumberType"
local readtablename = "Тип номера маршрута"
timer.Simple(0,function()
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
	
	local function RemoveEnt(ent)if ent then SafeRemoveEntity(ent) end end
	
	local function UpdateModelCallBack(ENT,cprop,modelcallback,callback,precallback)
		
		if modelcallback then
			local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
			ENT.ClientProps[cprop].modelcallback = function(wag,...)
				return modelcallback(wag,...) or oldmodelcallback(wag,...)
			end
		end
		
		if callback then
			local oldcallback = ENT.ClientProps[cprop].callback or function() end
			ENT.ClientProps[cprop].callback = function(wag,...)
				if precallback then precallback(wag,...)end
				oldcallback(wag,...)
				callback(wag,...)
			end
		end
		
		--удаление пропа при апдейте спавнером для принудительного обновленяи модели
		local oldupdate = ENT.UpdateWagonNumber or function() end
		ENT.UpdateWagonNumber = function(wag,...)
			timer.Simple(0.5,function()
				RemoveEnt(wag.ClientEnts[cprop])
			end)
			oldupdate(wag,...)
		end
	end
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	table.insert(ENT.Cameras,{Vector(407.5+75,0.3,44.5),Angle(20,180,0),"EMU"})
	
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
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("ASNP:Line",0)] or nil
			local Path = self:GetNW2Bool("ASNP:Path",false)
			local Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil		--красивый враиант. Спереди показывается одна станция, сзади другая
			--local Station = Line and Line[self:GetNW2Int("ASNP:LastStation",0)] or nil		--вариант, как в реальности. То есть и спереди и сзади одна и та же станция
			if Station then Station = Station[2] or nil end
			if Line and not Station then Station = "Кольцевая" end
			if Station then return Station else return "Посадки нет" end
		end
	end
	
	local sogltbl = {"б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ"}
	local function ShortingString(str)
		if #str <= 17*2 - 1 then return str end
		for i = 1, #str do
			for k,v in pairs(sogltbl) do
				local startpos = string.find(str,v,i)
				if startpos then 
					if startpos <= 15*2 then 
						return string.sub(str,1,startpos + 1).."." 
					end
				end
			end
		end
		return str
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
		if self.ASNPState < 1 then return end
		
		self:DrawOnPanel("EMU1",function()
			local rn = Format("%02d",self:GetNW2Int("ASNP:RouteNumber",0))
			draw.Text({
				text = rn,
				font = "Metrostroi_Tickers",
				pos = { 44, 90 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Color(0,255,0,255)})
		end)
		self:DrawOnPanel("EMU",function()
			draw.Text({
				text = self.GettedLastStationForEmu,
				font = "Metrostroi_Tickers",
				pos = { 315	, 135 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Color(0,255,0,255)})
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
			function(wag)
				if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
				wag:ShowHide("route",false)
				wag:ShowHide("route1",false)
				wag:ShowHide("route2",false)
				wag:HidePanel("Route",true)
				wag:HidePanel("LastStation",true)
				local ent = wag.ClientEnts and wag.ClientEnts[propname]
				if not IsValid(ent) then return end
				ent:SetPos(wag:LocalToWorld(Vector(460*2+1,0,-12)))
			end,
			function(wag)
				wag:ShowHide("route",true)
				wag:ShowHide("route1",true)
				wag:ShowHide("route2",true)
				wag:HidePanel("Route",false)
				wag:HidePanel("LastStation",false)
			end
		)
	end
	
end)