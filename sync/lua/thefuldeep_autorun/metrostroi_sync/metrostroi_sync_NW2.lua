--TODO звуки ТЭДов и дверей
--TODO BUG если улететь за карту, а пото вернуться на большом расстоянии состав будет постоянно перезагружаться
local NetValues = {}-- 1 - setNetValuevalue, 2 - field, 3 - getonserver, 4 - getNetValueonclient
timer.Simple(0,function()
	local function GetOwner(ent)
		local owner = CPPI and ent:CPPIGetOwner()
		if IsValid(owner) then return owner:Nick() end
	end
	
	local function SetNW2String(ent,id,val)ent:SetNW2String(id,val)end
	local function SetNW2Vector(ent,id,val)ent:SetNW2Vector(id,val)end
	local function SetNW2Angle(ent,id,val)ent:SetNW2Angle(id,val)end
	local function SetNW2Bool(ent,id,val)ent:SetNW2Bool(id,val)end
	local function SetNW2Float(ent,id,val)ent:SetNW2Float(id,val)end
	local function SetNW2Int(ent,id,val)ent:SetNW2Int(id,val)end
	
	local function GetNW2String(ent,val)return ent:GetNW2String(val)end
	local function GetNW2Vector(ent,val)return ent:GetNW2Vector(val)end
	local function GetNW2Angle(ent,val)return ent:GetNW2Angle(val)end
	local function GetNW2Bool(ent,val)return ent:GetNW2Bool(val)end
	local function GetNW2Float(ent,val)return ent:GetNW2Float(val)end
	local function GetNW2Int(ent,val)return ent:GetNW2Int(val)end
	
	local function GetClass(ent)return ent:GetClass()end
	local function GetModel(ent)return ent:GetModel()end
	local function GetPos(ent)return ent:GetPos()end
	local function GetAngles(ent)return ent:GetAngles()end
	
	local function GetEntID(ent)return game.GetIPAddress()..ent:EntIndex()end
	
	local function GetRoute(ent)return ent:GetNW2Int("RouteNumber",-1)end
	
	local function GetTexture(ent)return ent:GetNW2String("Texture")end
	local function GetPassTexture(ent)return ent:GetNW2String("PassTexture")end
	local function GetPassCabTexture(ent)return ent:GetNW2String("CabTexture")end
	
	local function GetDoorsLState(ent)return ent:GetNW2Bool("DoorL")end
	local function GetDoorsRState(ent)return ent:GetNW2Bool("DoorR")end
	
	local function GetSpeed(ent)return ent:GetNW2Float("Speed")end
	
	local function GetHeadlightState(ent)return ent:GetNW2Bool("HeadLights1") or ent:GetNW2Bool("HeadLights2") or ent:GetNW2Bool("HeadLights")end
	local function GetRedlightState(ent)return ent:GetNW2Bool("RedLight") or ent:GetNW2Bool("RedLights")end
	
	local function GetMotorPower(ent)return ent.FrontBogey:GetMotorPower()end
	
	local function Getfbm(ent)return ent.FrontBogey:GetModel()end
	local function Getfbp(ent)return ent:WorldToLocal(ent.FrontBogey:GetPos())end
	local function Getfba(ent)return ent:WorldToLocalAngles(ent.FrontBogey:GetAngles())end
	
	local function Getrbm(ent)return ent.RearBogey:GetModel()end
	local function Getrbp(ent)return ent:WorldToLocal(ent.RearBogey:GetPos())end
	local function Getrba(ent)return ent:WorldToLocalAngles(ent.RearBogey:GetAngles())end
	
	local function Getfcm(ent)return ent.FrontCouple:GetModel()end
	local function Getfcp(ent)return ent:WorldToLocal(ent.FrontCouple:GetPos())end
	local function Getfca(ent)return ent:WorldToLocalAngles(ent.FrontCouple:GetAngles())end

	local function Getrcm(ent)return ent.RearCouple:GetModel()end
	local function Getrcp(ent)return ent:WorldToLocal(ent.RearCouple:GetPos())end
	local function Getrca(ent)return ent:WorldToLocalAngles(ent.RearCouple:GetAngles())end
	
	NetValues = {
		{SetNW2String,"syncid",GetEntID,GetNW2String},
		{SetNW2String,"class",GetClass,GetNW2String},
		{SetNW2String,"model",GetModel,GetNW2String},
		{SetNW2Vector,"pos",GetPos,GetNW2Vector},
		{SetNW2Angle,"ang",GetAngles,GetNW2Angle},
		{SetNW2String,"owner",GetOwner,GetNW2String},
		{SetNW2String,"route",GetRoute,GetNW2String},
		{SetNW2String,"texture",GetTexture,GetNW2String},
		{SetNW2String,"passtexture",GetPassTexture,GetNW2String},
		{SetNW2String,"cabtexture",GetPassCabTexture,GetNW2String},
		{SetNW2Bool,"doorL",GetDoorsLState,GetNW2Bool},
		{SetNW2Bool,"doorR",GetDoorsRState,GetNW2Bool},
		{SetNW2Bool,"hl",GetHeadlightState,GetNW2Bool},
		{SetNW2Bool,"rl",GetRedlightState,GetNW2Bool},
		{SetNW2Float,"speed",GetSpeed,GetNW2Float},
		{SetNW2Int,"motorpower",GetMotorPower,GetNW2Int},
		
		{SetNW2String,"fbm",Getfbm,GetNW2String},
		{SetNW2Vector,"fbp",Getfbp,GetNW2Vector},
		{SetNW2Angle,"fba",Getfba,GetNW2Angle},

		{SetNW2String,"rbm",Getrbm,GetNW2String},
		{SetNW2Vector,"rbp",Getrbp,GetNW2Vector},
		{SetNW2Angle,"rba",Getrba,GetNW2Angle},

		{SetNW2String,"fcm",Getfcm,GetNW2String},
		{SetNW2Vector,"fcp",Getfcp,GetNW2Vector},
		{SetNW2Angle,"fca",Getfca,GetNW2Angle},

		{SetNW2String,"rcm",Getrcm,GetNW2String},
		{SetNW2Vector,"rcp",Getrcp,GetNW2Vector},
		{SetNW2Angle,"rca",Getrca,GetNW2Angle},
	}
end)













if CLIENT then
	local bogey,setsoundstate,reinitsounds,think,getmotorpower,getspeed
	timer.Simple(0,function()
		bogey = scripted_ents.GetStored("gmod_train_bogey").t
		setsoundstate = bogey.SetSoundState
		reinitsounds = bogey.ReinitializeSounds
		think = bogey.Think
		getmotorpower = bogey.GetMotorPower
		getspeed = bogey.GetSpeed
	end)
	
	
	Metrostroi = Metrostroi or {}
	Metrostroi.MetrostroiSync = Metrostroi.MetrostroiSync or {}
	Metrostroi.MetrostroiSync.SyncedWags = Metrostroi.MetrostroiSync.SyncedWags or {}
	Metrostroi.MetrostroiSync.SyncedWagsBases = Metrostroi.MetrostroiSync.SyncedWagsBases or {}
	local SyncedWags = Metrostroi.MetrostroiSync.SyncedWags
	local SyncedWagsBases = Metrostroi.MetrostroiSync.SyncedWagsBases
	
	--[[
	
	--TODO сохранять возвращяемые значения от функций Animate, ShowHide, ShowHideSmooth
	
	timer.Simple(0,function()
		for _,class in pairs(Metrostroi.TrainClasses)do
			local ENT = scripted_ents.GetStored(class).t
			if not ENT then continue end
			if ENT.Animate then
				ENT.AnimateStates = {}
				local OldAnimate = ENT.Animate
				ENT.Animate = function(sef,prop,...)
					local res = OldAnimate(self,prop,...)
					self.AnimateStates[prop] = res
					return res
				end
			end
			
			if ENT.ShowHide then
				ENT.ShowHideStates = {}
				local OldShowHide = ENT.ShowHide
				ENT.ShowHide = function(sef,prop,...)
					local res = OldShowHide(self,prop,...)
					if res then self.ShowHideStates[prop] = not self.ShowHideStates[prop] end
					return res
				end
			end
			
			if ENT.ShowHideSmooth then
				ENT.ShowHideSmoothStates = {}
				local OldShowHideSmooth = ENT.ShowHideSmooth
				ENT.ShowHideSmooth = function(sef,prop,...)
					local res = OldShowHideSmooth(self,prop,...)
					self.ShowHideSmoothStates[prop] = res
					return res
				end
			end
		end
	end)]]
	
	
	hook.Add("OnEntityCreated","SyncedTrainsSave",function(ent)
		timer.Simple(1,function()
			if not IsValid(ent) or ent:GetClass() ~= "gmod_subway_base" --[[or not ent:GetNWBool("SyncedWag",false)]] then return end
			SyncedWagsBases[#SyncedWagsBases+1] = ent
			ent.SpawnCSEnt = function() end
			ent.ShouldDrawClientEnt = function() end
			ent.UpdateTextures = function() end
			ent.Think = function() end
			ent.Draw = function() end
			ent.StopAllSounds = function(self)
				for _,snd in pairs(self.Sounds or {}) do
					snd:Stop()
				end
			end
			ent.OnRemove = function(self)self:StopAllSounds()end
			ent.CalcAbsolutePosition = function() end
			
			--ent:SetNW2Entity("TrainEntity",ent)
			
			ent.MotorPowerSound = 0
			ent.Sounds = nil
			ent.ReinitializeSounds = function(self,...) reinitsounds(self,...) end
			ent.EngineSNDConfig = {}
			ent.SetSoundState = function(self,snd,...) if not IsValid(self) then setsoundstate(self,snd,0) return end setsoundstate(self,snd,...) end
			ent.GetMotorPower = function(self,...) return --[[return getmotorpower(self,...)]] ent:GetNW2Int("motorpower",0) end
			ent.GetSpeed = function(self,...) return --[[getspeed(self,...)]] self:GetNW2Float("speed",0)/5 end
			ent.Think = function(self,...) if not IsValid(self) then self:StopAllSounds() end think(self,...) end
		end)
	end)
	
	net.Receive("MetrostroiChatSync", function()
		local dataN = net.ReadUInt(32)
		local tbl = util.JSONToTable(util.Decompress(net.ReadData(dataN)))
		local text = {}
		for i = 1,#tbl.Texts do
			local color = string.ToColor(tbl.Colors[i] or "")
			table.insert(text,color)
			table.insert(text,tbl.Texts[i])
		end
		chat.AddText(unpack(text))
	end)
	
	local MetrostroiDotSixLoadTextures1 = function() end
	timer.Simple(0,function()
		if not MetrostroiDotSixLoadTextures then return end
		MetrostroiDotSixLoadTextures1 = function(wag)
			local baseent
			for _,v in pairs(ents.FindByClass("gmod_subway_base")) do
				if not IsValid(v) then continue end
				baseent = v
				break
			end
			if not baseent then return end
			baseent.ClientProps = wag.ClientProps
			baseent.ClientEnts = wag.ClientProps
			local basetbl = wag.base
			baseent:SetNW2String("Texture",basetbl.texture)
			baseent:SetNW2String("CabTexture",basetbl.cabtexture)
			baseent:SetNW2String("PassTexture",basetbl.passtexture)
			MetrostroiDotSixLoadTextures(baseent,0)
		end
	end)
	
	local UpdateTextures = function() end
	local SetLightPower = function() end
	local ShouldRenderClientEnts = function() end
	timer.Simple(0,function()
		local base = scripted_ents.GetStored("gmod_subway_base").t
		if not base then return end
		UpdateTextures = function(wag)
			local baseent
			for _,v in pairs(ents.FindByClass("gmod_subway_base")) do
				if not IsValid(v) then continue end
				baseent = v
				break
			end
			if not baseent then return end
			baseent.ClientProps = wag.ClientProps or {}
			baseent.ClientEnts = wag.ClientProps or {}
			local basetbl = wag.base
			baseent:SetNW2String("Texture",basetbl.texture)
			baseent:SetNW2String("CabTexture",basetbl.cabtexture)
			baseent:SetNW2String("PassTexture",basetbl.passtexture)
			base.UpdateTextures(baseent)
		end
		
		SetLightPower = base.SetLightPower or SetLightPower
		ShouldRenderClientEnts = base.ShouldRenderClientEnts or ShouldRenderClientEnts
		local OldShouldRenderClientEnts = ShouldRenderClientEnts
		ShouldRenderClientEnts = function(ent)
			if IsValid(ent) and LocalPlayer():GetPos():DistToSqr(ent:GetPos()) > 3000*3000 then return false end
			return OldShouldRenderClientEnts(ent)
		end
		
		local oldShouldDrawClientEnt = base.ShouldDrawClientEnt
		base.ShouldDrawClientEnt = function(self,v,...)
			v.pos = v.pos or Vector(0)
			return oldShouldDrawClientEnt(self,v,...)
		end
	end)

	local function MoveSmooth(ent,vec2,ang2)
		--не двигать,если vec2 такой же, как и в прошлый раз
		if vec2 == ent.prevpos then return end--тут еще можно добавить проверку по ang, но так как позиция почти всегда будет обновляться, так как поезд качатеся, то она лишняя
		ent.prevpos = vec2
		local vec1 = ent:GetPos()
		local ang1 = ent:GetAngles()
		local CallTime = CurTime()
		local HookName = "MoveSmooth"..ent.base.syncid
		local light = ent.Lights and ent.GlowingLights and ent.GlowingLights[1]
		local lightpos,lightang
		if light then
			lightpos = ent.Lights[1][2]
			lightang = ent.Lights[1][3]
		end
		local interval = CallTime - (ent.prevmovecall or (CallTime-0.001))
		ent.interval = interval
		ent.prevmovecall = CallTime
		--print(interval)
		hook.Add("Think",HookName, function()
			if not IsValid(ent) then hook.Remove("Think",HookName) return end
			local CurTime = CurTime()
			if CurTime - CallTime > interval --[[or ent:GetPos() == vec2]] then 
				hook.Remove("Think",HookName)
				--ent:SetPos(vec2)
				return 
			end
			local percent = ((CurTime - CallTime) / interval * 0.9)
			ent:SetPos(LerpVector( percent, vec1, vec2 ))	
			ent:SetAngles(LerpAngle( percent, ang1, ang2 ))	
			if light then
				light:SetPos(ent:LocalToWorld(lightpos))
				light:SetAngles(ent:LocalToWorldAngles(lightang))
				light:Update()
			end
		end)
	end
	
	local function AddCProp(wag,propstbl,params,name)
		--if propstbl[name] then return end
		local prop = ClientsideModel(params.model)
		prop:SetPos(wag:LocalToWorld(params.pos or Vector(0)))
		prop:SetAngles(wag:LocalToWorldAngles(params.ang or Angle(0)))
		prop:SetModelScale(params.scale or 1)
		prop:SetParent(wag)
		prop.scale = params.scale or 1
		prop.nohide = params.nohide
		prop.hideseat = params.hideseat
		prop.hide = params.hide
		if name then propstbl[name] = prop else table.insert(propstbl,prop) end
	end
	
	local function CreateClientProps(wag)
		if not wag.wag then
			wag.wag = ClientsideModel(wag.model)
			wag.wag.base = wag
		end
		
		local base = wag
		local wag = base.wag
		wag:SetPos(base.pos)
		wag:SetAngles(base.ang)
		
		local bool
		if Metrostroi.ShouldHideTrain then wag.LastDrawCheckClientEnts = 0 bool = Metrostroi.ShouldHideTrain(wag) else bool = ShouldRenderClientEnts(wag) end
		if not bool then return end
		
		wag.ClientProps = wag.ClientProps or {}
		local ClientProps = wag.ClientProps

		ClientProps.fb = ClientsideModel(base.fbm)
		ClientProps.fb:SetPos(wag:LocalToWorld(base.fbp))
		ClientProps.fb:SetAngles(wag:LocalToWorldAngles(base.fba))
		ClientProps.fb:SetParent(wag)

		ClientProps.rb = ClientsideModel(base.rbm)
		ClientProps.rb:SetPos(wag:LocalToWorld(base.rbp))
		ClientProps.rb:SetAngles(wag:LocalToWorldAngles(base.rba))
		ClientProps.rb:SetParent(wag)

		ClientProps.rc = ClientsideModel(base.rcm)
		ClientProps.rc:SetPos(wag:LocalToWorld(base.rcp))
		ClientProps.rc:SetAngles(wag:LocalToWorldAngles(base.rca))
		ClientProps.rc:SetParent(wag)

		ClientProps.fc = ClientsideModel(base.fcm)
		ClientProps.fc:SetPos(wag:LocalToWorld(base.fcp))
		ClientProps.fc:SetAngles(wag:LocalToWorldAngles(base.fca))
		ClientProps.fc:SetParent(wag)
		
		local ENT = scripted_ents.GetStored(base.class).t
		if not ENT then return end
		local d,s,c,m,h = 1,1,1,1,1
		for name,prop in pairs(ENT.ClientProps or {}) do
			if not prop.model then continue end
			local namelower = tostring(name):lower()
			if namelower:find("door",1,true) then
				AddCProp(wag,ClientProps,prop,name..d)
				d = d + 1
			end
			if namelower:find("pass",1,true) or namelower:find("salon",1,true) then
				AddCProp(wag,ClientProps,prop,name..s)
				s = s + 1
			end
			if namelower:find("cabin",1,true) and c == 1 then--хз по поводу кабин
				AddCProp(wag,ClientProps,prop,name..c)
				c = c + 1
			end
			if namelower:find("mask",1,true) and m == 1 then--первая попашваящя маска
				AddCProp(wag,ClientProps,prop,name..m)
				m = m + 1
			end
			if namelower:find("light",1,true) or namelower:find("lamp",1,true) and not namelower:find("!",1,true) then--лампочки
				AddCProp(wag,ClientProps,prop,name..h)
				h = h + 1
			end
		end
		
		wag.Lights = ENT.Lights
		table.insert(ClientProps,wag)
		base.ClientProps = ClientProps
		return true
	end
	
	local function RemoveWagProps(wag)
		for i,prop in pairs(wag.ClientProps or {}) do
			SafeRemoveEntity(prop)
			wag.ClientProps[i] = nil
		end
		if IsValid(wag.wag) and wag.wag.Lights and wag.wag.Lights[1] then
			SetLightPower(wag.wag,1,wag.hl,0)
		end
		--wag.ClientProps = nil
	end
	
	local function DrawClientProps(wag)
		local bool
		if Metrostroi.ShouldHideTrain then wag.wag.LastDrawCheckClientEnts = 0 bool = Metrostroi.ShouldHideTrain(wag.wag) else bool = ShouldRenderClientEnts(wag.wag) end
		if not bool then RemoveWagProps(wag) wag.PropsRemoved = true return false end
		if wag.PropsRemoved then
			wag.PropsRemoved = false
			CreateClientProps(wag)
		end
		return true
	end

	local function GetNetValues(subwaybase)
		local res = {}
		for _,field in pairs(NetValues) do
			res[field[2]] = field[4](subwaybase,field[2])
		end
		return res
	end
	
	timer.Create("Update SyncedWags",0.5,0,function()
		local CurTime = CurTime()		
		for _,subwaybase in pairs(SyncedWagsBases or {}) do
			if not IsValid(subwaybase) or not subwaybase:GetNW2Bool("SyncedWag",false) then continue end
			local entid = subwaybase:GetNW2String("syncid","")
			if entid == "" then continue end
			local wag = SyncedWags[entid]
			
			if not wag then 
				if subwaybase:IsDormant() then continue end
				SyncedWags[entid] = GetNetValues(subwaybase)
				wag = SyncedWags[entid]
				if not CreateClientProps(wag) then continue end
				UpdateTextures(wag.wag)
				wag.wag:SetPos(wag.pos)
				wag.wag:SetAngles(wag.ang)
				wag.Update = CurTime
				continue
			end
			
			local ent = wag.wag
			if not IsValid(ent) then SafeRemoveEntity(ent) RemoveWagProps(wag) --[[wag.wag = nil]] SyncedWags[entid] = nil continue end
			
			if subwaybase:IsDormant() or not wag.Update or CurTime - wag.Update > (wag.interval and wag.interval > 0.4 and wag.interval*2 or 5) then 
				SafeRemoveEntity(ent)
				RemoveWagProps(wag)
				SyncedWags[entid] = nil
				continue
			end
			
			
			wag = GetNetValues(subwaybase)
			wag.wag = ent
			wag.ClientProps = ent.ClientProps
			
			wag.Update = CurTime
			SyncedWags[entid] = wag
			MoveSmooth(ent,wag.pos,wag.ang)
			
			if not DrawClientProps(wag) then continue end
			UpdateTextures(ent)
			--MetrostroiDotSixLoadTextures1(wag,0)--TODO не работает на точкушесть
			for name,prop in pairs(wag.ClientProps or {}) do
				local namelower = tostring(name):lower()
				if namelower:find("door",1,true) and namelower:find("x1",1,true) then--скрытие и раскрытие дверей левых
					prop:SetModelScale(wag.doorL and 0 or prop.scale)
				end
				if namelower:find("door",1,true) and namelower:find("x0",1,true) then--скрытие и раскрытие дверей правых
					prop:SetModelScale(wag.doorR and 0 or prop.scale)
				end
				if namelower:find("redl",1,true) then--скрытие и раскрытие красных огней
					prop:SetModelScale(wag.rl and prop.scale or 0)
				end
			end
			if wag.wag.Lights and wag.wag.Lights[1] then
				--if wag.wag.GlowingLights then PrintTable(wag.wag.GlowingLights) end
				SetLightPower(wag.wag,1,wag.hl,1)--свет от фар
			end
		end
	end)
	
	--[[timer.Create("CheckForOldWagons SyncedWags",5,0,function()
		for _,wag in pairs(SyncedWags) do--проверяю отдельно, не "просрочены" ли клиентские паравозы, потому что они могут не удалится от gmod_subway_base
			if not wag.Update or CurTime() - wag.Update > (wag.interval and wag.interval > 0.4 and wag.interval*2 or 5) then 
				SafeRemoveEntity(wag.wag)
				RemoveWagProps(wag)
				if SyncedWags[wag.entid] then SyncedWags[wag.entid] = nil end
			end
		end
	end)]]
	
	hook.Add("EntityRemoved","SyncedTrainsClear",function(ent)
		local k = table.KeyFromValue(SyncedWagsBases, ent)
		if k then table.remove(SyncedWagsBases, k) end
		local entid = ent:GetNW2String("syncid","")
		local wag = SyncedWags[entid]
		if not wag then return end
		SafeRemoveEntity(wag.wag)
		RemoveWagProps(wag)
		SyncedWags[entid] = nil
	end)
	
	
	--[[net.Receive("MetrostroiSync WagonsInfo",function()--TODO можно поулчить net.ReadType: Couldn't read type X, если передавать объекты (https://wiki.garrysmod.com/page/net/ReadTable)
		local tbl = net.ReadTable()
		local wag = SyncedWags[tbl.EntID]
		if not wag then
			SyncedWags[tbl.EntID] = tbl
			wag = SyncedWags[tbl.EntID]
			if not CreateClientProps(wag) then return end
			UpdateTextures(wag.wag)
			wag.wag:SetPos(wag.WagPos)
			wag.wag:SetAngles(wag.WagAng)
			wag.Update = CurTime()
		else
			local ent = wag.wag
			if not IsValid(ent) then SafeRemoveEntity(ent) RemoveWagProps(wag) wag.wag = nil SyncedWags[tbl.EntID] = nil return end
			wag = tbl
			wag.wag = ent
			ent.base = wag
			
			wag.Update = CurTime()
			SyncedWags[tbl.EntID] = wag
			MoveSmooth(ent,tbl.WagPos,tbl.WagAng)			
		end
	end)]]
	--TODO HUDPaint овнера и номер маршрута
end
if CLIENT then return end


for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	v:Remove()
end

require("gwsockets")

--[[if Metrostroi and Metrostroi.MetrostroiSync and Metrostroi.MetrostroiSync.socket then
	Metrostroi.MetrostroiSync.socket:close()
end]]

Metrostroi = Metrostroi or {}
Metrostroi.MetrostroiSync = Metrostroi.MetrostroiSync or {}
Metrostroi.SwitchesProps = Metrostroi.SwitchesProps or {}
local SwitchesProps = Metrostroi.SwitchesProps
timer.Simple(0,function()
	SwitchesProps = {}
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(SwitchesProps,v)
		end
	end
end)
local MetrostroiSync = Metrostroi.MetrostroiSync
MetrostroiSync = MetrostroiSync or {}
MetrostroiSync.Wagons = MetrostroiSync.Wagons or {}
MetrostroiSync.socket = MetrostroiSync.socket or GWSockets.createWebSocket("ws://"..(file.Read("web_server_ip.txt") or "127.0.0.1")..':228')
--MetrostroiSync.interval = 5
local socket = MetrostroiSync.socket
local Wagons = MetrostroiSync.Wagons


local send_data = CreateConVar( "metrostroibd_sync_time", "5", FCVAR_ARCHIVE, "Interval between send data", 0, 60 )
local SwitchesInterval = CreateConVar( "metrostroibd_sync_switches_time", "5", FCVAR_ARCHIVE, "Interval between send data", 1, 60 )
local SyncEnabled = CreateConVar( "metrostroibd_sync_enabled", "0", FCVAR_ARCHIVE, "", 0, 1 )
timer.Simple(5,function()
	if SyncEnabled:GetBool() then RunConsoleCommand("metrostroibd_sync_enable") end
end)

local CurrentMap = ""
timer.Simple(0,function()
	CurrentMap = game.GetMap()
end)

local function sendData(tbl)
	tbl.map = CurrentMap
	socket:write(util.TableToJSON(tbl))
end

local function sendText(text)
	local dat = {
		type = "chatMessage",
		msg = text,
	}
	table.insert(dat.msg.Colors,1,"133 133 133 0")
	table.insert(dat.msg.Texts,1,"["..GetHostName().."] ")
	sendData(dat)
end
MetrostroiSync.sendText = sendText

local function sendTrains(tbl)
	local dat = {
		type = "trains",
		msg = tbl,
	}
	sendData(dat)
end

local LastSettingSwitchesState = 0
local function sendSwitches(tbl)
	if CurTime() - LastSettingSwitchesState < SwitchesInterval:GetInt()*2 then return end--возможно надо будет добавить еще небольшой оффсет, потому что при одновременном получении данных сервера смогут одновременно отправить
	local dat = {
		type = "switches",
		msg = tbl,
	}
	sendData(dat)
end

local function sendRoute(command)
	local dat = {
		type = "routes",
		msg = command,
	}
	sendData(dat)
end
MetrostroiSync.sendRoute = sendRoute

local function GetSignalsFile(type,onlytxt)
	local path = "metrostroi_data/"..type.."_"..CurrentMap
	if file.Exists(path..".txt","DATA") then
		return file.Read(path..".txt", "DATA" ) or ""
	end
	if onlytxt then return "" end
	if file.Exists(path..".lua","LUA") then
		return file.Read(path..".lua", "LUA" ) or ""
	end
	return ""
end

local function sendSignals()--может крашнуться на етой функции???
	local signs = {
		auto = GetSignalsFile("auto"),
		pa = GetSignalsFile("pa"),
		signs = GetSignalsFile("signs"),
		track = GetSignalsFile("track")
	}
	local i = 0
	for type,str in pairs(signs) do
		i = i + 1
		timer.Simple(i,function()
		local dat = {
			type = "signals",
			msg = {
				[type] = str
			}
		}
		sendData(dat)
		end)
	end

end



local function CheckForOldWagons()
	local time = CurTime()
	for k,wag in pairs(Wagons) do
		if not wag.update or time - wag.update > send_data:GetFloat()*2 then
			if IsValid(wag)then wag:Remove() end
			table.remove(Wagons,k)
		end
	end
end

--util.AddNetworkString("MetrostroiSync WagonsInfo")
local function SendNetValues(wag,params,onspawn)
	--wag.TblToSend = wag.TblToSend or {}
	--local TblToSend = wag.TblToSend
	wag:SetNW2Bool("SyncedWag",true)
	
	for _,field in pairs(NetValues) do
		field[1](wag,field[2],params[field[2]])
	end
	
	--net.Start("MetrostroiSync WagonsInfo")
--		net.WriteTable(TblToSend)
--	net.Broadcast()
	
end

local function SetWagonPos(params)
	local FoundWag
	local time = CurTime()
	for k,wag in pairs(Wagons) do
		if wag.syncid ~= params.syncid then continue end
		wag:SetPos(params.pos)
		--wag:SetAngles(params.ang)
		--MoveSmooth(wag,pos,ang)
		wag.update = time
		SendNetValues(wag,params)
		return
	end
   	local wagon = ents.Create("gmod_subway_base")
   	--wagon:SetModel(model)
	wagon:SetModelScale(0)
   	wagon:SetPos(params.pos)
   	wagon:SetAngles(params.ang)
	wagon.syncid = params.syncid
	wagon.type = "syncedwagon"
	wagon.update = time
	wagon:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	wagon:SetNW2Int("MotorPower",params.motorpower)
	--wagon:SetNW2Float("BrakeSqueal",params.brakesqueal)
	--wagon:SetNW2Float("BrakeSqueal1",params.brakesqueal1)
	--wagon:SetNW2Int("SquealSound",params.squealsound)
	--wagon:SetNW2Int("MotorSoundType",params.motorsoundtype)
	--wagon:SetNW2Int("SquealType",params.squealtype)
	wagon:Spawn()
	SendNetValues(wagon,params,true)
	table.insert(Wagons,wagon)
	--[[for k,v in pairs(player.GetHumans()) do
		v:SetPos(params.pos)
		break
	end]]
end


local function SetSwitchState(name,state)
	local swhs = ents.FindByName(name)
	for _,swh in pairs(swhs or {}) do
		if not IsValid(swh) then continue end
		swh:Fire((state == 0 or state == 3) and "Close" or "Open","","0")
	end
end

local function OpenRoute(command)
	for _,signal in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(signal) or not signal.SayHook then continue end
		signal:SayHook(command,command)--TODO возможны ерроры
	end
end

local function SendChatMessageToClients(tbl)
	for i = 1,#tbl.Texts do
		MsgC(i == 1 and Color(255,255,255) or string.ToColor(tbl.Colors[i] or ""),tbl.Texts[i])--i == 1 and Color(255,255,255) чтобы в консоли имя сервера было белым
	end
	Msg("\n")
	net.Start("MetrostroiChatSync")
		local data = util.Compress(util.TableToJSON(tbl))
		local dataN = #data
		net.WriteUInt(dataN,32)
		net.WriteData(data,dataN)
	net.Broadcast()
end

local signsloaded = {}
local function LoadSignals(data)--эта функция выполняется слишком много раз, но в итоге она выполнится максимум 4 раза при проиоединении нового сервера, так что покс
	local signals = {
		auto = GetSignalsFile("auto",true),
		pa = GetSignalsFile("pa",true),
		signs = GetSignalsFile("signs",true),
		track = GetSignalsFile("track",true)
	}
	
	local date = os.date("%d_%m_%Y-%H_%M_%S", os.time())
	for type,str in pairs(signals) do
		local path = "metrostroi_data/"..type.."_"..CurrentMap.."_backup_"..date..".txt"
		if str ~= "" and not file.Exists(path,"DATA") then
			file.Write(path, str)
		end
	end
	
	for type,str in pairs(data) do
		file.Write("metrostroi_data/"..type.."_"..CurrentMap..".txt",str)
		signsloaded[type] = true
	end
	--PrintTable(signsloaded)
	if signsloaded.auto and signsloaded.pa and signsloaded.signs and signsloaded.track then RunConsoleCommand("metrostroi_load") signsloaded = {} end
	
end

util.AddNetworkString("MetrostroiChatSync")
local function onMessage(txt)
	local data = util.JSONToTable(txt)
	if not data then return end
	if data.map ~= CurrentMap then return end

	if data.type == "chatMessage" then
		SendChatMessageToClients(data.msg)
	end
	if data.type == "trains" then
		local trains = data.msg.trains
		for k,v in pairs(trains) do
			SetWagonPos(v)
		end
	end
	if data.type == "switches" then
		for name,state in pairs(data.msg) do
			SetSwitchState(name,state)
		end
		LastSettingSwitchesState = CurTime()
	end
	if data.type == "routes" then
		OpenRoute(data.msg)
	end
	if data.type == "signals" then
		LoadSignals(data.msg)
	end
end

function socket:onError(txt)
   	print("MetrostroiBD Sync Error: " .. txt)
end

function socket:onConnected()
	MetrostroiSync.connected = true
	sendSignals()
	print("MetrostroiBD Sync enabled")
end

function socket:onDisconnected()
	MetrostroiSync.connected = false
    print("MetrostroiBD Sync disabled")
end

function socket:onMessage(txt)
	onMessage(txt)
end

concommand.Add("metrostroibd_sync_enable",function(ply,_,args)
	if IsValid(ply) then 
		if not ply:IsSuperAdmin() then return end
		SyncEnabled:SetBool(true)
		socket:open()
	else
		SyncEnabled:SetBool(true)
		socket:open()
	end
end)

concommand.Add("metrostroibd_sync_disable",function(ply,_,args)
	if IsValid(ply) then 
		if not ply:IsSuperAdmin() then return end
		SyncEnabled:SetBool(false)
		socket:close()
	else
		SyncEnabled:SetBool(false)
		socket:close()
	end
	for k,wag in pairs(Wagons) do
		if IsValid(wag) then wag:Remove() end
	end
	Wagons = {}
end)

concommand.Add("metrostroibd_sync_trains_interval",function(ply,_,args)
	if not args[1] or not tonumber(args[1]) then return end
	arg = tonumber(args[1])
	if IsValid(ply) then 
		if not ply:IsSuperAdmin() then return end
		send_data:SetFloat(arg)
	else
		send_data:SetFloat(arg)
	end
end)

concommand.Add("metrostroibd_sync_switches_interval",function(ply,_,args)
	if not args[1] or not tonumber(args[1]) then return end
	arg = math.floor(tonumber(args[1]+0.5))--округляю о целых
	if IsValid(ply) then 
		if not ply:IsSuperAdmin() then return end
		SwitchesInterval:SetInt(arg)
	else
		SwitchesInterval:SetInt(arg)
	end
end)

local time = CurTime()
local time2 = time


hook.Add("Think","SyncTrains",function()
	if MetrostroiSync.connected then
		local CurTime = CurTime()
		if CurTime > time + send_data:GetFloat() then
			time = CurTime
			CheckForOldWagons()
			local data = {
				map = game.GetMap(),
				name = GetHostName(),
				trains = {	

				}
			}
			local addr = game.GetIPAddress()
			for k,v in pairs(Metrostroi.TrainClasses) do
				if v == "gmod_subway_base" then continue end
				for k1,wag in pairs(ents.FindByClass(v)) do
					if not IsValid(wag) then continue end
					local train = {}
					for _,field in pairs(NetValues) do
						train[field[2]] = field[3](wag)
					end												
						--brakesqueal = v1:GetNW2Float("BrakeSqueal",0),
						--brakesqueal1 = v1:GetNW2Float("BrakeSqueal1",0),
						--squealtype = v1:GetNW2Int("SquealType",0),
						--squealsound = v1:GetNW2Int("SquealSound",0),
						--motorsoundtype = v1:GetNWInt("MotorSoundType",1),
					table.insert(data.trains,train)
				end
			end
			if #data.trains > 0 then sendTrains(data) end
		end
		
		if CurTime - time2 > SwitchesInterval:GetInt() then
			time2 = CurTime
			local swhs = {}
			for k,v in pairs(SwitchesProps) do
				if not IsValid(v) then continue end
				swhs[v:GetName()] = v:GetInternalVariable("m_eDoorState") or 0
			end
			sendSwitches(swhs)
		end
	end
end)



timer.Simple(0,function()--чтобы етот хук добавлялся последним
hook.Add("PlayerSay","SyncChat",function(ply,text)
	local NickColor = team.GetColor(ply:Team())
	local text1 = {
		Colors = {
			NickColor.r.." "..NickColor.g.." "..NickColor.b.." "..NickColor.a
		},
		Texts = {
			ply:Nick(),
			": "..text
		}
	}
	sendText(text1)
	local low = text:lower()
	if low:find("!sopen",1,true) or low:find("!sclose",1,true) or low:find("!sopps",1,true) or low:find("!sclps",1,true) or low:find("!sactiv",1,true) or low:find("!sdeactiv",1,true) then
		sendRoute(text)
	end
end)
end)


local function HookAdd(type,name,func)
	local hooks = hook.GetTable()[type]
	if not hooks then hook.Add(type,name,function(...)return func(...)end) return end
	local hookfuncs = {}
	for hookname,hookfunc in pairs(hooks) do
		table.insert(hookfuncs,hookfunc)
		hooks[hookname] = function() end
		hook.Remove(type,hookname)
	end
	hook.Add(type,name,function(...)
		local res = func(...)
		if res ~= nil then return res end
		for _,hookfunc in pairs(hookfuncs) do
			local res = hookfunc(...)
			if res ~= nil then return res end
		end
	end)
end

timer.Simple(0,function()
hook.Add("MetrostroiPassedRed","MetrostroiPassedRedSync",function(train,ply,mode,arsback)
	ulx.fancyLogAdmin(ply, true, '#"A" проехал светофор #s с запрещающим показанием', arsback.Name)
	
	local NickColor = team.GetColor(ply:Team())
	local text = {
		Colors = {
			NickColor.r.." "..NickColor.g.." "..NickColor.b.." "..NickColor.a,
			"",
			"0 255 0 0"
		},
		Texts = {
			ply:Nick(),
			" проеxaл светофор ",
			arsback.Name,
			" c запрещающим показанием."
		}
	}
	sendText(text)
	
	return true
end)

hook.Add("MetrostroiPlombBroken", "MetrostroiPlombBrokenSync", function(train,but,ply)
	ulx.fancyLogAdmin(ply, true, '#"A" сорвал пломбу с #s на #s', but, train.SubwayTrain.Name)
	local NickColor = team.GetColor(ply:Team())
	local text = {
		Colors = {
			"",
			NickColor.r.." "..NickColor.g.." "..NickColor.b.." "..NickColor.a,
			"",
			"0 255 0 0",
			"",
			"0 255 0 0"
		},
		Texts = {
			'"',
			ply:Nick(),
			'" сорвал пломбу с ',
			but,
			" на ",
			train.SubwayTrain.Name,
			"."
		}
	}
	sendText(text)
	return true
end)
end)












--[[
есть еще такой варик в качестве альтернативы https://github.com/Bromvlieg/gm_bromsock, https://github.com/HunterNL/Gmod-Websockets


dll модуль https://github.com/FredyH/GWSockets/releases

код на nodeJS

const WebSocket = require('ws');
 
const wss = new WebSocket.Server({ port: 228 });
 
wss.on('connection', function connection(ws) {
	var now = new Date();
	console.log(now);
	console.log("NEW CONNECTION");
	//console.log(wss.clients);
  ws.on('message', function incoming(message) {
	  //console.log("recieved");
    //let data = JSON.parse(message)
   // if (data.type == "chatMessage") {
    	wss.clients.forEach(function each(client) {
			//console.log("client");
	    	if (client !== ws && client.readyState === WebSocket.OPEN) {
	    	//if (client.readyState === WebSocket.OPEN) {
				//console.log("sending");
	    		//let dat = {
	    			//"type": "syncChat",
	    			//"msg": data.msg
	    		//}
	    		client.send(message);
	    	}
	   	});
    //}
  });
});




]]