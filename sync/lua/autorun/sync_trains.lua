if CLIENT then return end

for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	if IsValid(v) and v.name == "SyncedTrain" then v:Remove() end
end

for k,v in pairs(ents.FindByClass("gmod_button")) do
	if IsValid(v) and v.name == "SyncedTrain" then v:Remove() end
end
--file.CreateDir("MetrostroiSync")
local ShW = false
hook.Remove("Think","SyncTrainsSend")
local interval = 1
local lasttime = os.time()
hook.Add("Think", "SyncTrainsSend", function()
	if os.time() - lasttime < interval then return end
	lasttime = os.time()

	SendSyncedTrains()
	GetSyncedTrains()
	
	SendSyncedRoutes()
	CheckRoutes()
	GetSyncedRoutes()
	
	SendSyncedSwitches()
	CheckSwitchesTBL()
	GetSyncedSwitches()
end)
hook.Remove("Think","SyncTrainsSend")
function SendSyncedTrains()
	local TrainsTBL = {}
	local i = 0
	local p = 0
	for k,v in pairs(Metrostroi.TrainClasses) do
		for k1,v1 in pairs(ents.FindByClass(v)) do
			if not IsValid(v1) then continue end
			i = i + 1
			p = 0
			TrainsTBL[i] = {
				OsTime = os.time(),
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

local SyncedTrainsTBL = {}
function CreateSyncedTrain(index)
	local ent = ents.Create( "gmod_subway_base" )
	ent.name = "SyncedTrain"
	ent:SetPos(Vector(0,0,0))
	ent:Spawn()
	ent:SetPersistent(true)
	ent:SetMoveType(MOVETYPE_FLY)
	--ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	SyncedTrainsTBL[index] = ent
	print("Added SyncedTrain")
end

function DeleteSyncedTrain(index)
	for k,v in pairs(SyncedTrainsTBL) do
		if k == index then 
			if IsValid(v) then v:Remove() end
			SyncedTrainsTBL[index] = nil print("Removed SyncedTrain") 
		end
	end
end

function GetSyncedTrains()
	if not file.Exists("SyncTrainsDataRec.txt", "DATA") then return end
	local tbl = {}
	tbl = util.JSONToTable(file.Read("SyncTrainsDataRec.txt", "DATA"))
	if not tbl then return end
	for k,v in pairs(tbl) do
		if not SyncedTrainsTBL[k] or not IsValid(SyncedTrainsTBL[k]) then CreateSyncedTrain(k) end
	end
	
	for k,v in pairs(SyncedTrainsTBL) do
		if not tbl[k] then DeleteSyncedTrain(k) end
	end
	
	for k,v in pairs(tbl) do
		for k1,v1 in pairs(SyncedTrainsTBL) do
			if k == k1 and IsValid(v1) then 
				v1:SetModel(v.model)
				v1:SetPos(v.pos)
				v1:SetAngles(v.ang)
				--print(v.pos)
			end
		end
	end
end


function OpenRoute(str)
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

--CloseRoute("626M")
local RoutesTBL = {}
hook.Add("PlayerSay","SyncRoutes", function(ply,text)
	if stringfind(text,"!sclps ") or stringfind(text,"!sopps ") or stringfind(text,"!sopen ") or stringfind(text,"!sclose ") or stringfind(text,"!sactiv ") or stringfind(text,"!sdeactiv ") then
		table.insert(RoutesTBL,1,{comm = text, OsTime = os.time()})
	end
end)

function CheckRoutes()
	if not RoutesTBL then return end
	for k,v in pairs(RoutesTBL) do
		if v.OsTime + interval  < os.time() then 
			RoutesTBL[k] = nil
		end
	end
end

function SendSyncedRoutes()
	file.Write("SyncRoutesDataSend.txt",util.TableToJSON(RoutesTBL))
end

function GetSyncedRoutes()
	local tbl = {}
	if file.Exists("SyncRoutesDataRec.txt", "DATA") then 
		tbl = util.JSONToTable(file.Read("SyncRoutesDataRec.txt", "DATA"))
	end
	if not tbl then return end
	local comm
	for key1,value1 in pairs(tbl) do
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


local SwitchesTBL = {}
hook.Add("MetrostroiChangedSwitch", "SyncSwitches", function(self,AlternateTrack)
	local state = nil
	if AlternateTrack then state = "Open" else state = "Close" end
	table.insert(SwitchesTBL,1,{name = self.Name,state = state,OsTime = os.time()})
end)

function CheckSwitchesTBL()
	if SwitchesTBL then
		for k,v in pairs(SwitchesTBL) do
			if v.OsTime + interval < os.time() then 
				SwitchesTBL[k] = nil
			end
		end
	end
end

function SendSyncedSwitches()
	file.Write("SyncSwitchesDataSend.txt",util.TableToJSON(SwitchesTBL))
end

function GetSyncedSwitches()
	if not file.Exists("SyncSwitchesDataRec.txt", "DATA") then return end
	local tbl = {}
	tbl = util.JSONToTable(file.Read("SyncSwitchesDataRec.txt", "DATA"))
	if not tbl then return end
	for k,v in pairs(tbl) do
			SetSwitchState(v.name,v.state)
	end
end

function SetSwitchState(name,state)
	if not name then return end
	for k,v in pairs(ents.FindByClass("gmod_track_switch")) do
		if v.Name ~= name then continue end
		if v.Invertred then 
			if state == "Open" then state = "Close"
			elseif state == "Close" then state = "Open"
			end
		end
		for k1,v1 in pairs(v.TrackSwitches) do if IsValid(v1) then v1:Fire(state,"","0") end end
		print("changed switch "..name)
	end
end

function ForAvtooborot(route)
	OpenRoute(route)
	table.insert(RoutesTBL,1,{comm = "!sopen "..route, OsTime = os.time()})
	--PrintTable(SopensTBL)
end