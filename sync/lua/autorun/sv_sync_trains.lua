if CLIENT then return end

local interval = 0.5
local lasttime = os.clock()
local SyncedTrainsTBL = {}
local RoutesTBL = {}
local GetTrainsTBLL = {}
local GetSyncedRoutesTbl = {}
local SwitchesTBL = {}
local GetSyncedSwitchesTbl = {}

local function SendSyncedTrains(arg)
	local TrainsTBL = {}
	local i = 0
	local p = 0
	for k,v in pairs(Metrostroi.TrainClasses) do
		for k1,v1 in pairs(ents.FindByClass(v)) do
			if not IsValid(v1) then continue end
			i = i + 1
			p = 0
			TrainsTBL[i] = {
				OsTime = os.clock(),
				model = v1:GetModel(),
				pos = v1:GetPos(),
				ang = v1:GetAngles()
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
	file.Write("SyncTrainsDataSend.txt",util.TableToJSON(TrainsTBL))
end

local function CreateSyncedTrain(index)
	local ent = ents.Create( "gmod_subway_base" )
	ent.name = "SyncedTrain"
	ent:SetPos(Vector(0,0,0))
	ent:SetPersistent(true)
	ent:SetMoveType(MOVETYPE_FLY)
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

local shetchik = 1
local LastGetSyncedTrains
local function GetSyncedTrains(arg)
	if not file.Exists("SyncTrainsDataRec.txt", "DATA") then
		if not SyncedTrainsTBL then return end
		for k,v in pairs(SyncedTrainsTBL) do
			if IsValid(v) then v:Remove() end 
		end 
		return
	end
	if LastGetSyncedTrains == file.Read("SyncTrainsDataRec.txt", "DATA") then
		if not SyncedTrainsTBL then return end
		if shetchik ~= 50 then shetchik = shetchik + 1 return end
		shetchik = 1
		for k,v in pairs(SyncedTrainsTBL) do
			DeleteSyncedTrain(k)
		end
		return
	end
	LastGetSyncedTrains = file.Read("SyncTrainsDataRec.txt", "DATA")
	GetTrainsTBLL = util.JSONToTable(LastGetSyncedTrains)
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
		if not GetTrainsTBLL[k] then DeleteSyncedTrain(k) end
	end
	
	for k,v in pairs(GetTrainsTBLL) do
		for k1,v1 in pairs(SyncedTrainsTBL) do
			if k == k1 and IsValid(v1) then 
				v1:SetModel(v.model)
				v1:SetMoveType(MOVETYPE_NONE)
				v1:SetMoveType(MOVETYPE_FLY)					-- установится ли?
				v1:SetPos(v.pos + Vector(200,0,0))
				v1:SetAngles(v.ang)
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
			if str == bigrustosmall(v1.RouteName) then v:OpenRoute(k1) end
		end
	end
end

local function CheckRoutes(arg)
	if not RoutesTBL then return end
	for k,v in pairs(RoutesTBL) do
		if v.OsTime + interval  < os.clock() then 
			RoutesTBL[k] = nil
		end
	end
end

local LastGetSyncedRoutes
local function GetSyncedRoutes(arg)
	if file.Exists("SyncRoutesDataRec.txt", "DATA") then 
		if LastGetSyncedRoutes == file.Read("SyncRoutesDataRec.txt", "DATA") then return end
		LastGetSyncedRoutes = file.Read("SyncRoutesDataRec.txt", "DATA")
		GetSyncedRoutesTbl = util.JSONToTable(LastGetSyncedRoutes)
	end
	if not GetSyncedRoutesTbl then return end
	local comm
	for key1,value1 in pairs(GetSyncedRoutesTbl) do
		if not value1.comm then continue end
			print("route "..(value1.comm))
		for key,value in pairs(ents.FindByClass("gmod_track_signal")) do
			comm = value1.comm
			if comm:sub(1,8) == "!sactiv " then
				comm = comm:sub(9,-1):upper()

				comm = string.Explode(":",comm)
				if value.Routes then
					for k,v in pairs(value.Routes) do
						if (v.RouteName and v.RouteName:upper() == comm[1] or comm[1] == "*") and v.Emer then
							if value.LastOpenedRoute and k ~= value.LastOpenedRoute then value:CloseRoute(value.LastOpenedRoute) end
							v.IsOpened = true
							break
						end
					end
				end
			elseif comm:sub(1,10) == "!sdeactiv " then
				comm = comm:sub(11,-1):upper()

				comm = string.Explode(":",comm)
				if value.Routes then
					for k,v in pairs(value.Routes) do
						if (v.RouteName and v.RouteName:upper() == comm[1] or comm[1] == "*") and v.Emer then
							v.IsOpened = false
							break
						end
					end
				end
			elseif comm:sub(1,8) == "!sclose " then
				comm = comm:sub(9,-1):upper()

				comm = string.Explode(":",comm)
				if comm[1] == value.Name then
					if value.Routes[1] and value.Routes[1].Manual then
						value:CloseRoute(1)
					else
						if not value.Close then
							value.Close = true
						end
						if value.InvationSignal then
							value.InvationSignal = false
						end
						if (value.LastOpenedRoute and value.LastOpenedRoute == 1) or value.Routes[1].Repeater then
							value:CloseRoute(1)
						else
							value:OpenRoute(1)
						end
					end
				elseif value.Routes then
					for k,v in pairs(value.Routes) do
						if v.RouteName and v.RouteName:upper() == comm[1] then
							if value.LastOpenedRoute and k ~= value.LastOpenedRoute then value:CloseRoute(value.LastOpenedRoute) end
							value:CloseRoute(k)
						end
					end
				end
			elseif comm:sub(1,7) == "!sopen " then
				comm = comm:sub(8,-1):upper()
				comm = string.Explode(":",comm)
				if comm[1] == value.Name then
					RunConsoleCommand("say",comm)
					if comm[2] then
						if value.NextSignals[comm[2]] then
							local Route
							for k,v in pairs(value.Routes) do
								if v.NextSignal == comm[2] then Route = k break end
							end
							value:OpenRoute(Route)
						end
					else
						if value.Routes[1] and value.Routes[1].Manual then
							value:OpenRoute(1)
						elseif value.Close then
							value.Close = false
						end
					end
				elseif value.Routes then
					for k,v in pairs(value.Routes) do
						if v.RouteName and v.RouteName:upper() == comm[1] then
							if value.LastOpenedRoute and k ~= value.LastOpenedRoute then value:CloseRoute(value.LastOpenedRoute) end
							value:OpenRoute(k)
						end
					end
				end
			elseif comm:sub(1,7) == "!sopps " then
				comm = comm:sub(8,-1):upper()
				comm = string.Explode(":",comm)
				if comm[1] == value.Name then
					value.InvationSignal = true
				end
			elseif comm:sub(1,7) == "!sclps " then
				comm = comm:sub(8,-1):upper()
				comm = string.Explode(":",comm)
				if comm[1] == value.Name then
					value.InvationSignal = false
				end
			end
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

local LastGetSyncedSwitches
local function GetSyncedSwitches(arg)
	if not file.Exists("SyncSwitchesDataRec.txt", "DATA") then return end
	if LastGetSyncedSwitches == file.Read("SyncSwitchesDataRec.txt", "DATA") then return end
	LastGetSyncedSwitches = file.Read("SyncSwitchesDataRec.txt", "DATA")
	GetSyncedSwitchesTbl = util.JSONToTable(LastGetSyncedSwitches)
	if not GetSyncedSwitchesTbl then return end
	for k,v in pairs(GetSyncedSwitchesTbl) do
		--if not name then continue end
			SetSwitchState(v.name,v.state)
			print("switch "..(v.name))
	end
end

local function CheckSwitchesTBL(arg)
	if SwitchesTBL then
		for k,v in pairs(SwitchesTBL) do
			if v.OsTime + interval < os.clock() then 
				SwitchesTBL[k] = nil
			end
		end
	end
end

local function SendSyncedSwitches(arg)
	file.Write("SyncSwitchesDataSend.txt",util.TableToJSON(SwitchesTBL))
end

local function SendSyncedRoutes(arg)
	file.Write("SyncRoutesDataSend.txt",util.TableToJSON(RoutesTBL))
end

for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	if IsValid(v) and v.name == "SyncedTrain" then v:Remove() end
end

for k,v in pairs(ents.FindByClass("gmod_button")) do
	if IsValid(v) and v.name == "SyncedTrain" then v:Remove() end
end

--hook.Remove("Think","SyncTrainsSend")

hook.Add("Think", "SyncTrainsSend", function()
	if os.clock() - lasttime < interval then return end
	lasttime = os.clock()

	SendSyncedTrains(nil)
	GetSyncedTrains(nil)
	
	CheckRoutes(nil)
	SendSyncedRoutes(nil)
	GetSyncedRoutes(nil)
	
	CheckSwitchesTBL(nil)
	SendSyncedSwitches(nil)
	GetSyncedSwitches(nil)
end)

hook.Add("PlayerSay","SyncRoutes", function(ply,text)
	if stringfind(text,"!sclps ") or stringfind(text,"!sopps ") or stringfind(text,"!sopen ") or stringfind(text,"!sclose ") or stringfind(text,"!sactiv ") or stringfind(text,"!sdeactiv ") then
		table.insert(RoutesTBL,1,{comm = text, OsTime = os.clock()})
	end
end)

hook.Add("MetrostroiChangedSwitch", "SyncSwitches", function(self,AlternateTrack)
	local state = nil
	if AlternateTrack then state = "Open" else state = "Close" end
	table.insert(SwitchesTBL,1,{name = self.Name,state = state,OsTime = os.clock()})
end)


function ForAvtooborot(route)
	OpenRoute(route)
	table.insert(RoutesTBL,1,{comm = "!sopen "..route, OsTime = os.clock()})
	--PrintTable(SopensTBL)
end



--[[										--код передатчика
local function Send(Send, Rec)
	local string2 = nil
	local file = nil
	local stringg = nil
  file = io.open(Send)
  if not file then return end
  stringg = file:read()
  file:close()
  file = nil
  if stringg then
    file = io.open(Rec, "w")
    if not file then return end
		string2 = file:read()
		if string2 and stringg == string2 then file:close() return end
      file:write(stringg)
      file:close()
      file = nil
      stringg = nil
  end
end

local server1 = "T:\\gms_norank_obnova2\\garrysmod\\data\\"
--local server1 = "R:\\Downloads\\gms_norank\\garrysmod\\data\\"
local server2 = "T:\\gms_norank_obnova\\garrysmod\\data\\"
--local server2 = "R:\\Downloads\\gms_norank\\garrysmod\\data\\"
local interval = 0.1
local lasttime = os.clock()
::cycle::
while true do
  if os.clock() - lasttime < interval then goto cycle end
	lasttime = os.clock()
  
  local lastmap1 = io.open(server1.."lastmap.txt")
  local lastmap2 = io.open(server2.."lastmap.txt")
  if lastmap1 and lastmap2 and lastmap1:read() ~= lastmap2:read() then lastmap1:close() lastmap2:close() goto cycle end
  
  Send(server1.."SyncTrainsDataSend.txt", server2.."SyncTrainsDataRec.txt")
  Send(server2.."SyncTrainsDataSend.txt", server1.."SyncTrainsDataRec.txt")
  
  Send(server1.."SyncRoutesDataSend.txt", server2.."SyncRoutesDataRec.txt")
  Send(server2.."SyncRoutesDataSend.txt", server1.."SyncRoutesDataRec.txt")
  
  Send(server1.."SyncSwitchesDataSend.txt", server2.."SyncSwitchesDataRec.txt")
  Send(server2.."SyncSwitchesDataSend.txt", server1.."SyncSwitchesDataRec.txt")
  
  --Send(server1.."SyncChatDataRec.txt", server2.."SyncChatDataRec.txt")
  
 end
 ]]