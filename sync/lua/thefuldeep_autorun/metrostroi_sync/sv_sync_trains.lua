if CLIENT then return end

local interval = 1
local lasttime = os.clock()
local SyncedTrainsTBL = {}
local RoutesTBL = {}
local GetTrainsTBLL = {}
local GetSyncedRoutesTbl = {}
local SwitchesTBL = {}
local GetSyncedSwitchesTbl = {}
local TrainsTBL = {}
local CurTime = os.clock()
local NotInitialized = true

local function MoveSmooth(ent,vec1,vec2,ang1,ang2)
	hook.Add("Think",tostring(ent), function()
		if not IsValid(ent) then hook.Remove("Think", tostring(ent)) return end
		CurTime = os.clock()
		if CurTime - lasttime < 0 or ent:GetPos() == vec2 then 
			hook.Remove("Think", tostring(ent))
			--ent:SetPos(vec2)
			return 
		end
		local percent = ((CurTime - lasttime) / interval * 0.9)
		--print(percent)
		ent:SetPos(LerpVector( percent, vec1, vec2 ))	
		ent:SetAngles(LerpAngle( percent, ang1, ang2 ))	
	end)
end

local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/sync/"
local function SendToWebServer(tbl,url,typ)
	local TableToSend = {MainTable = util.TableToJSON(tbl), server = THEFULDEEP.HOSTNAME, map = THEFULDEEP.MAP,typ = typ}
	http.Post(url, TableToSend)
end

--[[local function table.Compare( tbl1, tbl2 )
	if not tbl1 and not tbl2 then return true
	elseif not tbl1 or not tbl2 then return false
	end
	for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
			if ( !table.Compare( v, tbl2[k] ) ) then
				return false
			end
		elseif ( v != tbl2[k] ) then
			return false
		end
	end
end]]

--local shetchik4 = 0
local outputTBL = {}
--local LastOutputTBL = {}
local function GetFromWebServer(url,typ)
	http.Fetch( 
	url.."?typ="..typ,
	function (body)
		--outputTBL[typ] = {}
		if body then
			outputTBL[typ] = util.JSONToTable(body)
		end
	end,
	function()
		outputTBL[typ] = {}
	end
	)
	if not outputTBL[typ] then return {} end
	--[[if shetchik4 == 10 then
		shetchik4 = 0
		for k,v in pairs(outputTBL[typ]) do
			if k == GetHostName() or (v.map and v.map ~= Map) then continue end
			if not v.MainTable then continue end
			if LastOutputTBL[typ] and outputTBL[typ] then
				if (outputTBL[typ][k] and LastOutputTBL[typ][k] and table.ToString(outputTBL[typ][k]) == table.ToString(LastOutputTBL[typ][k])) or (not LastOutputTBL[typ][k] and not outputTBL[typ][k]) then
					outputTBL[typ][k] = nil
				else
					if not LastOutputTBL[typ] then LastOutputTBL[typ] = {} end
					LastOutputTBL[typ][k] = outputTBL[typ][k]
				end
			end
		end
	else
		shetchik4 = shetchik4 + 1
	end]]
	local tbl2 = {}
	for k,v in pairs(outputTBL[typ]) do
		if k == THEFULDEEP.HOSTNAME or (v.map and v.map ~= THEFULDEEP.MAP) then continue end
		if not v.MainTable then continue end		
		for k1,v1 in pairs(v.MainTable) do
			table.insert(tbl2,1,v1)
		end
	end
	return tbl2
end

local shetchik0 = true
local function SendSyncedTrains(arg)
	local TrainsTBLL = {}
	local i = 0
	local p = 0
	for k,v in pairs(Metrostroi.TrainClasses) do
		for k1,v1 in pairs(ents.FindByClass(v)) do
			if not IsValid(v1) then continue end
			i = i + 1
			p = 0
			local Owner = "N/A"
			if IsValid(v1:CPPIGetOwner()) then
				Owner = v1:CPPIGetOwner():Nick()
			end
			TrainsTBLL[(THEFULDEEP.HOSTNAME)..v1:EntIndex()] = {
				OsTime = os.clock(),
				model = v1:GetModel(),
				pos = v1:GetPos(),
				ang = v1:GetAngles(),
				Owner = Owner
			}
			--[[if stringfind(v1:GetClass(),"base") then continue end
			if not v1.ClientEnts then continue end
			for k2,v2 in pairs(v1.ClientEnts) do
				if not IsValid(v2) then continue end
				p = p + 1
				TrainsTBL[i].ClientEnts[p] = {
					model = v2:GetModel(),
					pos = v2:GetPos(),
					ang = v2:GetAngles()
				}
			end]]
		end
	end
	TrainsTBL = TrainsTBLL
	if not TrainsTBL or table.Count(TrainsTBL) == 0 then 
		if shetchik0 then
			SendToWebServer(TrainsTBL, WebServerUrl,"trains")
			shetchik0 = false
		else 
			return 
		end
	else
		if not shetchik0 then shetchik0 = true end
		SendToWebServer(TrainsTBL, WebServerUrl,"trains")
	end
end

local function CreateSyncedTrain(index)
	local ent = ents.Create( "gmod_subway_base" )
	ent.name = "SyncedTrain"
	ent:SetPos(GetTrainsTBLL[index].pos)
	ent:SetAngles(GetTrainsTBLL[index].ang)
	ent:SetPersistent(true)
	ent:SetMoveType(MOVETYPE_FLY)
	ent:SetNWString("Owner",GetTrainsTBLL[index].Owner)
	--ent:SetNW2Bool("IsSyncedTrain",true)
	--ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	ent:Spawn()
	SyncedTrainsTBL[index] = ent
	print("Added SyncedTrain")
end

local function DeleteSyncedTrain(index)
	for k,v in pairs(SyncedTrainsTBL) do
		if k == index then 
			if IsValid(v) then v:Remove() end
			SyncedTrainsTBL[index] = nil print("Removed SyncedTrain") 
		end
	end
end

local shetchik3 = 0
local function GetSyncedTrains(arg)
	GetTrainsTBLL = GetFromWebServer(WebServerUrl,"trains")
	if not GetTrainsTBLL then
		for k,v in pairs(SyncedTrainsTBL) do
			if IsValid(v) then v:Remove() end 
		end 
		return
	end
	
	for k,v in pairs(GetTrainsTBLL) do
		if not SyncedTrainsTBL[k] or not IsValid(SyncedTrainsTBL[k]) then CreateSyncedTrain(k) end
	end
	
	for k,v in pairs(SyncedTrainsTBL) do
		if not GetTrainsTBLL[k] then 
			if shetchik3 == 3 then
				DeleteSyncedTrain(k) 
				shetchik3 = 0
			else
				shetchik3 = shetchik3 + 1
				break
			end
		end
	end
	
	for k,v in pairs(GetTrainsTBLL) do
		for k1,v1 in pairs(SyncedTrainsTBL) do
			if k == k1 and IsValid(v1) then 
				v1:SetModel(v.model)
				v1:SetNWString("Owner",v.Owner)
				v1:SetMoveType(MOVETYPE_NONE)
				v1:SetMoveType(MOVETYPE_FLY)
				v1:SetPersistent(true)
				--v1:SetPos(v.pos)
				--v1:SetAngles(v.ang)
				MoveSmooth(v1,v1:GetPos(),v.pos,v1:GetAngles(),v.ang)
				--print(v.pos)
			end
		end
	end
end

local function OpenRoute(str)
	str = bigrustosmall(str)
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if str == v.Name then
			if v.Routes[1] and v.Routes[1].Manual then v:OpenRoute(1) end
			if v.Close then v.Close = false end
			return
		end
		for k1,v1 in pairs(v.Routes) do
			if not v1.RouteName then continue end
			if str == bigrustosmall(v1.RouteName) then v:OpenRoute(k1) end
		end
	end
end

local function CheckRoutes(arg)
	if not RoutesTBL then return end
	for k,v in pairs(RoutesTBL) do
		if v.OsTime + interval * 2  < os.clock() then 
			RoutesTBL[k] = nil
		end
	end
end

local function GetSyncedRoutes(arg)
	GetSyncedRoutesTbl = GetFromWebServer(WebServerUrl,"routes")
	if not GetSyncedRoutesTbl then return end
	for key1,value1 in pairs(GetSyncedRoutesTbl) do
		if not value1.comm then continue end
			print("route "..(value1.comm))
		for key,value in pairs(ents.FindByClass("gmod_track_signal")) do
			if not IsValid(value) or not value.SayHook then continue end
			value:SayHook(value1.comm,value1.comm)--TODO проверить на ошибки
		end
	end
end

local function SetSwitchState(name,state)
	for k,v in pairs(ents.FindByClass("gmod_track_switch")) do
		if v.Name ~= name then continue end
		if v.Invertred then 
			if state == "Open" then state = "Close"
			elseif state == "Close" then state = "Open"
			end
		end
		for k1,v1 in pairs(v.TrackSwitches) do if IsValid(v1) then v1:Fire(state,"","0") end end
	end
end

local function GetSyncedSwitches(arg)
	GetSyncedSwitchesTbl = GetFromWebServer(WebServerUrl,"switches")
	if not GetSyncedSwitchesTbl then return end
	for k,v in pairs(GetSyncedSwitchesTbl) do
		if not v.name then continue end
			SetSwitchState(v.name,v.state)
			print("switch "..(v.name))
	end
end

local function CheckSwitchesTBL(arg)
	if SwitchesTBL then
		for k,v in pairs(SwitchesTBL) do
			if v.OsTime + interval * 2 < os.clock() then 
				SwitchesTBL[k] = nil
			end
		end
	end
end

local shetchik1 = true
local function SendSyncedSwitches(arg)
	if not SwitchesTBL or #SwitchesTBL == 0 then 
		if shetchik1 then
			SendToWebServer(SwitchesTBL, WebServerUrl,"switches")
			shetchik1 = false
		else 
			return 
		end
	else
		if not shetchik1 then shetchik1 = true end
		SendToWebServer(SwitchesTBL, WebServerUrl,"switches")
	end
end

local shetchik2 = true
local function SendSyncedRoutes(arg)
	if not RoutesTBL or #RoutesTBL == 0 then 
		if shetchik2 then
			SendToWebServer(RoutesTBL, WebServerUrl,"routes")
			shetchik2 = false
		else 
			return 
		end
	else
		if not shetchik2 then shetchik2 = true end
		SendToWebServer(RoutesTBL, WebServerUrl,"routes")
	end
end

for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	if IsValid(v) and v.name and v.name == "SyncedTrain" then v:Remove() end
end

for k,v in pairs(ents.FindByClass("gmod_button")) do
	if IsValid(v) and v.name and v.name == "SyncedTrain" then v:Remove() end
end

hook.Add("PlayerSay","SyncRoutes", function(ply,text)
	if stringfind(text,"!sclps ") or stringfind(text,"!sopps ") or stringfind(text,"!sopen ") or stringfind(text,"!sclose ") or stringfind(text,"!sactiv ") or stringfind(text,"!sdeactiv ") then
		table.insert(RoutesTBL,1,{comm = text, OsTime = os.clock()})
	end
end)

hook.Add("MetrostroiChangedSwitch", "SyncSwitches", function(self,AlternateTrack)
	CheckSwitchesTBL()
	local state = nil
	if AlternateTrack then state = "Open" else state = "Close" end
	table.insert(SwitchesTBL,1,{name = self.Name,state = state,OsTime = os.clock()})
end)


function ForAvtooborot(route,hidenotif)
	CheckRoutes()
	if not hidenotif then ulx.fancyLog("[АВТООБОРОТ] Собираю маршрут #s",route) end
	OpenRoute(route)
	table.insert(RoutesTBL,1,{comm = "!sopen "..route, OsTime = os.clock()})
	--PrintTable(SopensTBL)
end


local EmptySended
timer.Create("SyncTrainsThink",interval,0,function()
	if not MetrostroiSyncEnabled or not THEFULDEEP or not THEFULDEEP.SERVERINFOINITIALIZED then 
		if not EmptySended then
			EmptySended = true
			SendToWebServer({},WebServerUrl,"trains")
			SendToWebServer({},WebServerUrl,"routes")
			SendToWebServer({},WebServerUrl,"switches")
			for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
				if IsValid(v) and v.name and v.name == "SyncedTrain" then v:Remove() end
			end
		end
		return
	end
	
	lasttime = os.clock()
	
	EmptySended = false
	
	SendSyncedTrains()
	GetSyncedTrains()
	
	CheckRoutes()
	SendSyncedRoutes()
	GetSyncedRoutes()
	
	CheckSwitchesTBL()
	SendSyncedSwitches()
	GetSyncedSwitches()
	
end)


hook.Add("ShutDown","SyncTrainsSendClearTbls",function()
	hook.Remove("Think","SyncTrainsThink") 
	SendToWebServer({},WebServerUrl,"trains")
	SendToWebServer({},WebServerUrl,"routes")
	SendToWebServer({},WebServerUrl,"switches")
end)
