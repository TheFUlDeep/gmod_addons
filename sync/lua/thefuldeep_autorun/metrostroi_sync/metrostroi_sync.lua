if CLIENT then
	Metrostroi = Metrostroi or {}
	Metrostroi.MetrostroiSync = Metrostroi.MetrostroiSync or {}
	Metrostroi.MetrostroiSync.SyncedWags = Metrostroi.MetrostroiSync.SyncedWags or {}
	local SyncedWags = Metrostroi.MetrostroiSync.SyncedWags
	
	local UpdateTextures = function() end
	local SetLightPower = function() end
	local ShouldRenderClientEnts = function() end
	timer.Simple(0,function()
		local base = scripted_ents.Get("gmod_subway_base")
		if not base then return end
		UpdateTextures = base.UpdateTextures or UpdateTextures
		SetLightPower = base.SetLightPower or SetLightPower
		ShouldRenderClientEnts = base.ShouldRenderClientEnts or ShouldRenderClientEnts
		local OldShouldRenderClientEnts = ShouldRenderClientEnts
		ShouldRenderClientEnts = function(ent)
			if IsValid(ent) and IsValid(ent.wag) and LocalPlayer():GetPos():DistToSqr(ent.wag:GetPos()) > 3000*3000 then return false end
			return OldShouldRenderClientEnts(ent)
		end
	end)

	local function MoveSmooth(ent,vec2,ang2)
		if not IsValid(ent) or ent.moving then return end
		local vec1 = ent:GetPos()
		local ang1 = ent:GetAngles()
		local CallTime = CurTime()
		local HookName = "MoveSmooth"..ent.base.EntID
		local interval = GetGlobalFloat("MetrostroiSyncInterval",5)
		local light = ent.GlowingLights and ent.GlowingLights[1]
		local lightpos = ent.Lights[1][2]
		local lightang = ent.Lights[1][3]
		ent.moving = true
		hook.Add("Think",HookName, function()
			if not IsValid(ent) then hook.Remove("Think",HookName) return end
			local CurTime = CurTime()
			if CurTime - CallTime > interval or ent:GetPos() == vec2 then 
				ent.moving = false
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
		if propstbl[name] then return end
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
		if wag.ClientProps then
			for k,prop in pairs(wag.ClientProps) do
				if not IsValid(prop) then prop:Remove() wag.ClientProps[k]=nil end
			end
		end
		if wag.wag and not IsValid(wag.wag) then wag.wag:Remove() wag.wag = nil end
	
		wag.EntID = wag:GetNW2String("EntID")
		if not wag.wag then
			wag.wag = ClientsideModel(wag:GetNW2String("WagModel"))
			wag.wag:SetAngles(wag:GetNW2Angle("WagAng"))
			wag.wag:SetPos(wag:GetNW2Vector("WagPos"))
			wag.wag.base = wag
		end
		local base = wag
		local wag = base.wag
		wag.ClientProps = wag.ClientProps or {}
		local ClientProps = wag.ClientProps
		if not ClientProps.fb then
		ClientProps.fb = ClientsideModel(base:GetNW2String("fbm"))
		ClientProps.fb:SetPos(base:GetNW2Vector("fbp"))
		ClientProps.fb:SetAngles(base:GetNW2Angle("fba"))
		ClientProps.fb:SetParent(wag)
		end
		
		if not ClientProps.rb then
		ClientProps.rb = ClientsideModel(base:GetNW2String("rbm"))
		ClientProps.rb:SetPos(base:GetNW2Vector("rbp"))
		ClientProps.rb:SetAngles(base:GetNW2Angle("rba"))
		ClientProps.rb:SetParent(wag)
		end
		
		if not ClientProps.rc then
		ClientProps.rc = ClientsideModel(base:GetNW2String("rcm"))
		ClientProps.rc:SetPos(base:GetNW2Vector("rcp"))
		ClientProps.rc:SetAngles(base:GetNW2Angle("rca"))
		ClientProps.rc:SetParent(wag)
		end

		if not ClientProps.fc then
		ClientProps.fc = ClientsideModel(base:GetNW2String("fcm"))
		ClientProps.fc:SetPos(base:GetNW2Vector("fcp"))
		ClientProps.fc:SetAngles(base:GetNW2Angle("fca"))
		ClientProps.fc:SetParent(wag)
		end
		
		base.Class = base:GetNW2String("Class")
		local ENT = scripted_ents.Get(base.Class)
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
		
		wag.Lights = ENT.Lights--это я добавил ради фар
		table.insert(wag.ClientProps,wag)
		wag.ClientEnts = wag.ClientProps
		base.ClientEnts = wag.ClientProps
		base.ClientProps = wag.ClientProps
		base.AllPropsCreated = true
		--print(table.Count(wag.ClientProps))
	end
	
	hook.Add("OnEntityCreated","SyncedTrainsSave",function(ent)
		timer.Simple(1,function()
			if not IsValid(ent) or ent:GetClass() ~= "gmod_subway_base" or not ent:GetNW2Bool("SyncedWag",false) then return end
			CreateClientProps(ent)
			ent.ShouldDrawClientEnt = function() end
			ent.UpdateTextures = function() end
			table.insert(SyncedWags,ent)
		end)
	end)
	
	hook.Add("EntityRemoved","SyncedTrainsClear",function(ent)
		if not IsValid(ent) or ent:GetClass() ~= "gmod_subway_base" or not ent:GetNW2Bool("SyncedWag",false) then return end
		for _,prop in pairs(ent.wag.ClientProps or {}) do
			if prop == ent.wag then continue end
			prop:Remove()
		end
		if ent.wag then ent.wag:Remove() end
		local k = table.KeyFromValue(SyncedWags, ent)
		if k then table.remove(SyncedWags,k) end
	end)
	
	local function RemoveWagProps(wag)
		if wag.ClientProps then
			for i,prop in pairs(wag.ClientProps) do
				if prop == wag.wag or i == "rc" or i == "fc" or i == "rb" or i == "fb" then continue end
				prop:Remove()
				wag.ClientProps[i] = nil
			end
		end
	end
	
	local function DrawClientProps(base)
		local bool
		if Metrostroi.ShouldHideTrain then bool = Metrostroi.ShouldHideTrain(base) else bool = ShouldRenderClientEnts(base) end
		if not bool then RemoveWagProps(base)return false end
		CreateClientProps(base)
		return true
	end

	
	timer.Create("Update SyncedWags",2,0,function()
		for k,wag in pairs(SyncedWags) do
			if not IsValid(wag) or not DrawClientProps(wag) then continue end
			UpdateTextures(wag)
			if MetrostroiDotSixLoadTextures then MetrostroiDotSixLoadTextures(wag,0) end--TODO не работает на точкушесть
			local DoorL = wag:GetNW2Bool("DoorL")
			local DoorR = wag:GetNW2Bool("DoorR")
			local RL = wag:GetNW2Bool("RedLight",false)
			for name,prop in pairs(wag.ClientProps) do
				if not IsValid(prop) then continue end
				local namelower = tostring(name):lower()
				if namelower:find("door",1,true) and namelower:find("x1",1,true) then--скрытие и раскрытие дверей левых
					prop:SetModelScale(DoorL and 0 or prop.scale)
				end
				if namelower:find("door",1,true) and namelower:find("x0",1,true) then--скрытие и раскрытие дверей правых
					prop:SetModelScale(DoorR and 0 or prop.scale)
				end
				if namelower:find("redl",1,true) then--скрытие и раскрытие красных огней
					prop:SetModelScale(RL and prop.scale or 0)
				end
			end
			if wag.wag and wag.wag.Lights then
				--if wag.wag.GlowingLights then PrintTable(wag.wag.GlowingLights) end
				SetLightPower(wag.wag,1,wag:GetNW2Bool("HeadLights"),1)--свет от фар
			end
		end
	end)
	
	hook.Add("Think","SyncedWagsMove",function()
		for k,wag in pairs(SyncedWags) do
			if not IsValid(wag) then table.remove(SyncedWags,k) continue end
			--local Wag = wag.ClientProps.wag
			MoveSmooth(wag.wag,wag:GetPos(),wag:GetAngles())
		end
	end)
end
if CLIENT then return end


for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	v:Remove()
end

require("gwsockets")

if Metrostroi and Metrostroi.MetrostroiSync and Metrostroi.MetrostroiSync.socket then
	Metrostroi.MetrostroiSync.socket:close()
end

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
SetGlobalFloat("MetrostroiSyncInterval",send_data:GetFloat())
timer.Simple(0,function()
	if SyncEnabled:GetBool() then RunConsoleCommand("metrostroibd_sync_enable") end
end)

local CurrentMap = ""
timer.Simple(0,function()
	CurrentMap = game.GetMap()
end)

local function sendText(text)
	local dat = {
		type = "chatMessage",
		msg = text,
		map = CurrentMap
	}
	socket:write(util.TableToJSON(dat))
end

local function sendTrains(tbl)
	local dat = {
		type = "trains",
		msg = tbl,
		map = CurrentMap
	}
	socket:write(util.TableToJSON(dat))
end

local function sendSwitches(tbl)
	local dat = {
		type = "switches",
		msg = tbl,
		map = CurrentMap
	}
	socket:write(util.TableToJSON(dat))
end

local function sendRoute(command)
	print("sending route")
	local dat = {
		type = "routes",
		msg = command,
		map = CurrentMap
	}
	socket:write(util.TableToJSON(dat))
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

local function SendNetValues(wag,params,onspawn)
	wag:SetNW2String("RouteNumber",params.route)
	
	wag:SetNW2String("Texture",params.texture)
	wag:SetNW2String("PassTexture",params.passtexture)
	wag:SetNW2String("CabTexture",params.cabtexture)
	
	wag:SetNW2Bool("DoorL",params.doorL)
	wag:SetNW2Bool("DoorR",params.doorR)
	
	wag:SetNW2Bool("HeadLights",params.hl)
	wag:SetNW2Bool("RedLight",params.rl)
	
	if onspawn then
		wag:SetNW2String("EntID",params.syncid)
		wag:SetNW2String("WagModel",params.model)
		wag:SetNW2String("Class",params.class)
	
		wag:SetNW2Bool("SyncedWag",true)
		wag:SetNW2Vector("WagPos",params.pos)
		wag:SetNW2Angle("WagAng",params.ang)
		
		wag:SetNW2String("fbm",params.fbm)
		wag:SetNW2Vector("fbp",params.fbp)
		wag:SetNW2Angle("fba",params.fba)
		wag:SetNW2String("rbm",params.rbm)
		wag:SetNW2Vector("rbp",params.rbp)
		wag:SetNW2Angle("rba",params.rba)
		
		wag:SetNW2String("fcm",params.fcm)
		wag:SetNW2Vector("fcp",params.fcp)
		wag:SetNW2Angle("fca",params.fca)
		wag:SetNW2String("rcm",params.rcm)
		wag:SetNW2Vector("rcp",params.rcp)
		wag:SetNW2Angle("rca",params.rca)
	end
end

local function SetWagonPos(params)
	local FoundWag
	local time = CurTime()
	for k,wag in pairs(Wagons) do
		if wag.syncid ~= params.syncid then continue end
		wag:SetPos(params.pos)
		wag:SetAngles(params.ang)
		--MoveSmooth(wag,pos,ang)
		wag.update = time
		SendNetValues(wag,params)
		FoundWag = true
	end
	if FoundWag then return end
   	local wagon = ents.Create("gmod_subway_base")
   	--wagon:SetModel(model)
	wagon:SetModelScale(0)
   	wagon:SetPos(params.pos)
   	wagon:SetAngles(params.ang)
   	wagon.TrainOwner = params.owner
	wagon.syncid = params.syncid
	wagon.type = "syncedwagon"
	wagon.update = time
	wagon:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	SendNetValues(wagon,params,true)
	wagon:Spawn()
	table.insert(Wagons,wagon)
end

local function SetSwitchState(name,state)
	local swhs = ents.FindByName(name)
	for _,swh in pairs(swhs or {}) do
		if not IsValid(swh) then return end
		swh:Fire((state == 0 or state == 3) and "Close" or "Open","","0")
	end
end

local function OpenRoute(command)
	for _,signal in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(signal) or not signal.SayHook then continue end
		signal:SayHook(command,command)
	end
end


local function onMessage(txt)
	local data = util.JSONToTable(txt)
	if data.map ~= CurrentMap then return end
	if data.type == "chatMessage" then
		PrintMessage(3,data.msg)
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
	end
	if data.type == "routes" then
		OpenRoute(data.msg)
	end
end

function socket:onError(txt)
   	print("MetrostroiBD Sync Error: " .. txt)
end

function socket:onConnected()
	MetrostroiSync.connected = true
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

concommand.Add("metrostroibd_sync_trains_inreval",function(ply,_,args)
	if not args[1] or not tonumber(args[1]) then return end
	arg = tonumber(args[1])
	if IsValid(ply) then 
		if not ply:IsSuperAdmin() then return end
		send_data:SetFloat(arg)
		SetGlobalFloat("MetrostroiSyncInterval",arg)
	else
		send_data:SetFloat(arg)
		SetGlobalFloat("MetrostroiSyncInterval",arg)
	end
end)

concommand.Add("metrostroibd_sync_switches_inreval",function(ply,_,args)
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
				for k1,v1 in pairs(ents.FindByClass(v)) do
					local train = {
						syncid = addr..v1:EntIndex(),
						model = v1:GetModel(),
						route = v1:GetNW2Int("RouteNumber",-1),
						class = v1:GetClass(),
						pos = v1:GetPos(),
						ang = v1:GetAngles(),
						owner = CPPI and v1:CPPIGetOwner():Nick(),
						
						texture = v1:GetNW2String("Texture"),
						passtexture = v1:GetNW2String("PassTexture"),
						cabtexture = v1:GetNW2String("CabTexture"),
						
						doorL = v1:GetNW2Bool("DoorL"),
						doorR = v1:GetNW2Bool("DoorR"),
						
						hl = v1:GetNW2Bool("HeadLights1") or v1:GetNW2Bool("HeadLights2") or v1:GetNW2Bool("HeadLights"),
						rl = v1:GetNW2Bool("RedLight") or v1:GetNW2Bool("RedLights"),
						
						rbm = v1.RearBogey:GetModel(),
						rbp = v1.RearBogey:GetPos(),
						rba = v1.RearBogey:GetAngles(),
						fbm = v1.FrontBogey:GetModel(),
						fbp = v1.FrontBogey:GetPos(),
						fba = v1.FrontBogey:GetAngles(),
						
						fcm = v1.FrontCouple:GetModel(),
						fcp = v1.FrontCouple:GetPos(),
						fca = v1.FrontCouple:GetAngles(),
						rcm = v1.RearCouple:GetModel(),
						rcp = v1.RearCouple:GetPos(),
						rca = v1.RearCouple:GetAngles(),
					}
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
	if text ~= "/stoprpc" then
		sendText("["..GetHostName().."] "..ply:Nick()..": " ..text)
		local low = text:lower()
		if low:find("!sopen",1,true) or low:find("!sclose",1,true) or low:find("!sopps",1,true) or low:find("!sclps",1,true) or low:find("!sactiv",1,true) or low:find("!sdeactiv",1,true) then
			sendRoute(text)
		end
	else
		socket:close()
	end
end)
end)


local function HookAdd(type,name,func)
	local hooks = hook.GetTable().type
	if not hooks then hook.Add(type,name,function(...)return func(...)end) return end
	local hookfuncs = {}
	for hookname,hookfunc in pairs(hooks) do
		table.insert(hookfuncs,hookfunc)
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
HookAdd("MetrostroiPassedRed","MetrostroiPassedRedSync",function(Train,ply,mode,arsback)
	sendText("["..GetHostName().."] "..ply:Nick().." проехал светофор "..name.." с запрещающим показанием.")
end)
HookAdd("MetrostroiPlombBroken","MetrostroiPlombBrokenSync",function(self,but,ply)
	sendText("["..GetHostName().."] "..ply:Nick().." снял пломбу "..but..".")
end)
end)