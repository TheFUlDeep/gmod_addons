--TODO перемещение камеры
if SERVER then resource.AddWorkshop("2245045087") end

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

hook.Add("InitPostEntity","Metrostroi 717 minsk chapaeff",function()
--timer.Simple(0,function()
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not NOMER then return else NOMER = NOMER.t end
	
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom").t
	local NOMER_714 = scripted_ents.GetStored("gmod_subway_81-714_mvm").t
	
	
	local inserted_index = -1
	local paramname = "Минск"
	local tablename = "RouteNumberType"
	local readtablename = "Тип номера маршрута"
	
	local foundtable
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{tablename,readtablename,"List",{"Default",paramname}})
		inserted_index = 2
	else
		inserted_index = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],paramname)
	end
	table.insert(NOMER_CUSTOM.Spawner,9,{"MinskParts","Minsk props","Boolean"})
	

	if SERVER then return end
	
	
	NOMER.ClientProps["minsk_parts"] = {
        model = "models/metrostroi_custom/minsk/717_minsk.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        nohide=true, 
    }
	
    NOMER.ClientProps["minsk_parts2"] = {
        model = "models/metrostroi_custom/minsk/rk1b.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        nohide=true, 
    }
	
    NOMER.ClientProps["minsk_stickers_outside"] = {
        model = "models/metrostroi_custom/minsk/stickers.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        nohide=true, 
    }
	
	
	
	for i = 1,2 do
		NOMER.ClientProps["Minsk_RouteNumber_Inside"..i] = {
			model = "models/metrostroi_train/81-717/segments/segment_mvm.mdl",
			pos = Vector(i == 2 and 456.32-0.25 or 456.4-0.2,-45.31+(i-1)*-0.8,37.72),
			ang = Angle(90,171,0),
			color = Color(228,28,28),
			hideseat=0.2, 
		}
	end
	
	NOMER.ClientProps["Minsk_Dist_Light"] = {
		model = "models/metrostroi_custom/minsk/minsk_destination_light.mdl",
		pos = Vector(0),
		ang = Angle(0),
		nohide=true, 
	}
	
	--[[NOMER.ClientProps["Minsk_Dist_Frame_And_Route"] = {
		model = "models/metrostroi_custom/minsk/minsk_destination.mdl",
		pos = Vector(0),
		ang = Angle(0),
		nohide=true, 
	}]]


	local color = Color(255,160,0)
	local pos1 = Vector(457+0.2,-50,38.7)
	local pos2 = Vector(458.25+0.2,-42.5,38.7)
	for i = 1,2 do
		local propname = "route"..i
		UpdateModelCallBack(
			NOMER,
			propname,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_custom/minsk/segments/segment_minsk.mdl" end
			end,
			function(wag,cent)
				if wag:GetNW2Int(tablename,0) == inserted_index then
					cent:SetPos(wag:LocalToWorld(i == 1 and pos1 or pos2))
					cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-9,0)))
					cent:SetColor(color)
					--cent:SetSkin(0)
				end
			end
		)
	end
	
	--models/metrostroi_custom/minsk/minsk_destination_display.mdl
	--models/metrostroi_custom/minsk/minsk_destination.mdl
	local defRNpos,defRNang = NOMER.ButtonMap["Route"].pos, NOMER.ButtonMap["Route"].ang
	UpdateModelCallBack(
		NOMER,
		"route",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_custom/minsk/minsk_destination.mdl" end
		end,
		function(wag,cent)
			if wag:GetNW2Int(tablename,0) == inserted_index then
				cent:SetPos(wag:LocalToWorld(Vector(0)))
				cent:SetAngles(wag:LocalToWorldAngles(Angle(0)))
				wag.ButtonMap["Route"].pos = Vector(457,-51,43)
				wag.ButtonMap["Route"].ang = Angle(0,81,90)
			end
		end,
		function(wag)
			wag.ButtonMap["Route"].pos = defRNpos
			wag.ButtonMap["Route"].ang = defRNang
		end
	)
	
	local oldupdate = NOMER.UpdateWagNumCallBack
	NOMER.UpdateWagNumCallBack = function(self)
		self:ShowHide("route1",true)
		self:ShowHide("route2",true)
		oldupdate(self)
		
		local nw = self:GetNW2Bool("MinskParts")
		self:ShowHide("minsk_parts",nw)
		self:ShowHide("minsk_parts2",nw)
		self:ShowHide("minsk_stickers_outside",nw)

		local nw = self:GetNW2Int(tablename,0) == inserted_index
		self:ShowHide("Minsk_Dist_Light",nw)
		self:ShowHide("Minsk_RouteNumber_Inside1",nw)
		self:ShowHide("Minsk_RouteNumber_Inside2",nw)
		
		--self:ShowHide("Minsk_Dist_Frame_And_Route",nw)
		--self:ShowHide("route",not nw)
	end
	
	--если UpdateWagNumCallBack не вызвалась из-за того, что состав уже был
	UpdateModelCallBack(
		NOMER,
		"minsk_parts",
		nil,
		function(wag)
			if not wag:GetNW2Bool("MinskParts") then wag:ShowHide("minsk_parts",false)end
		end
	)
	UpdateModelCallBack(
		NOMER,
		"minsk_parts2",
		nil,
		function(wag)
			if not wag:GetNW2Bool("MinskParts") then wag:ShowHide("minsk_parts2",false)end
		end
	)
	UpdateModelCallBack(
		NOMER,
		"minsk_stickers_outside",
		nil,
		function(wag)
			if not wag:GetNW2Bool("MinskParts") then wag:ShowHide("minsk_stickers_outside",false)end
		end
	)
	UpdateModelCallBack(
		NOMER,
		"Minsk_Dist_Light",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then wag:ShowHide("Minsk_Dist_Light",false)end
		end
	)
	UpdateModelCallBack(
		NOMER,
		"Minsk_RouteNumber_Inside1",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then wag:ShowHide("Minsk_RouteNumber_Inside1",false)end
		end
	)
	UpdateModelCallBack(
		NOMER,
		"Minsk_RouteNumber_Inside2",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then wag:ShowHide("Minsk_RouteNumber_Inside2",false)end
		end
	)
	
	
	
	local dists = {"destination","destination1"}
	for _,propname in pairs(dists)do
		UpdateModelCallBack(
			NOMER,
			propname,
			nil,
			function(wag,cent)
				if wag:GetNW2Int(tablename,0) == inserted_index then
					cent:SetModelScale(0.979)
					cent:SetPos(wag:LocalToWorld(Vector(10.2,-0.035,-0.25)))
				end
			end
		)
	end
	
	local oldinit = NOMER.Initialize
	NOMER.Initialize = function(self,...)
		oldinit(self,...)
		if self.LastStation then
			local oldthink = self.LastStation.ClientThink
			self.LastStation.ClientThink = function(sys,...)
				if not IsValid(self.ClientEnts[sys.EntityName]) then return end
				oldthink(sys,...)
			end
		end
	end
	
	local oldthink = NOMER.Think
	NOMER.Think = function(self,...)
		local res = oldthink(self,...)		
		local nw = self:GetNW2Int(tablename,0) == inserted_index
		local bv = self:GetPackedRatio("BatteryVoltage") > 0
		if nw then
			self:ShowHide("route1",bv)
			self:ShowHide("route2",bv)
			self:ShowHide("Minsk_RouteNumber_Inside1",bv)
			self:ShowHide("Minsk_RouteNumber_Inside2",bv)
			self:ShowHide("Minsk_Dist_Light",bv)
			if self.ClientEnts then
				local texture = Metrostroi.Skins["702_routes"] and Metrostroi.Skins["702_routes"][self:GetNW2Int("LastStationID",0)]
				if texture then
					for _,propname in pairs(dists)do
						local ent = self.ClientEnts[propname]
						if IsValid(ent) and ent:GetSubMaterial(0) ~= texture then
							ent:SetSubMaterial(0,texture)
						end
					end
				end
			end
			local rn = Format("%03d",self:GetNW2String("RouteNumber","000"))
			for i=1,2 do
				local ent = self.ClientEnts["Minsk_RouteNumber_Inside"..i]
	      		if IsValid(ent) and ent:GetSkin() ~= rn[i] then
					ent:SetSkin(rn[i])
	        	end
   			end
		end
		return res
	end
	
	
	--714
    NOMER_714.ClientProps["minsk_stickers_outside"] = {
        model = "models/metrostroi_custom/minsk/stickers.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        nohide=true, 
    }

	local oldupdate = NOMER_714.UpdateWagNumCallBack or function()end
	NOMER_714.UpdateWagNumCallBack = function(self)
		oldupdate(self)
		self:ShowHide("minsk_stickers_outside",self:GetNW2Bool("MinskParts"))
	end
	--если UpdateWagNumCallBack не вызвалась из-за того, что состав уже был
	UpdateModelCallBack(
		NOMER_714,
		"minsk_stickers_outside",
		nil,
		function(wag)
			wag:ShowHide("minsk_stickers_outside",wag:GetNW2Bool("MinskParts"))
		end
	)
end)

