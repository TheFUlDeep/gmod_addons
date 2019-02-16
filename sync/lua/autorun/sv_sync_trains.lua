if CLIENT then return end

local interval = 0.5
local lasttime = os.clock()
local SyncedTrainsTBL = {}
local RoutesTBL = {}
local GetTrainsTBLL = {}
local GetSyncedRoutesTbl = {}
local SwitchesTBL = {}
local GetSyncedSwitchesTbl = {}
local TrainsTBL = {}

local HostName = GetHostName()
local Map = game.GetMap()
local WebServerUrl = "http://metronorank.ddns.net/sync/"
local function SendToWebServer(tbl,url,typ)
	local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName, map = Map,typ = typ}
	http.Post(url, TableToSend)
end

local outputTBL = {}
local function GetFromWebServer(url,typ)
	http.Fetch( 
	url.."?typ="..typ,
	function (body)
		outputTBL[typ] = {}
		if body then
			outputTBL[typ] = util.JSONToTable(body)
		end
	end,
	function()
		outputTBL[typ] = {}
	end
	)
	local tbl2 = {}
	if not outputTBL[typ] or not istable(outputTBL[typ]) then return {} end
	for k,v in pairs(outputTBL[typ]) do
		if k == HostName or (v.map and v.map ~= Map) then continue end
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
			TrainsTBLL[i] = {
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
	TrainsTBL = TrainsTBLL
	if not TrainsTBL or #TrainsTBL == 0 then 
		if shetchik0 then
			SendToWebServer(TrainsTBL, WebServerUrl,"trains")
			shetchik0 = false
		else 
			return 
		end
	else
		shetchik0 = true
		SendToWebServer(TrainsTBL, WebServerUrl,"trains")
	end
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
		if not GetTrainsTBLL[k] then DeleteSyncedTrain(k) end
	end
	
	for k,v in pairs(GetTrainsTBLL) do
		for k1,v1 in pairs(SyncedTrainsTBL) do
			if k == k1 and IsValid(v1) then 
				v1:SetModel(v.model)
				v1:SetMoveType(MOVETYPE_NONE)
				v1:SetMoveType(MOVETYPE_FLY)					-- установится ли?
				v1:SetPersistent(true)
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
			if not v1.RouteName then continue end
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

local function GetSyncedRoutes(arg)
	GetSyncedRoutesTbl = GetFromWebServer(WebServerUrl,"routes")
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

local function GetSyncedSwitches(arg)
	GetSyncedSwitchesTbl = GetFromWebServer(WebServerUrl,"switches")
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
		shetchik1 = true
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
		shetchik2 = true
		SendToWebServer(RoutesTBL, WebServerUrl,"routes")
	end
end

for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
	if IsValid(v) and v.name == "SyncedTrain" then v:Remove() end
end

for k,v in pairs(ents.FindByClass("gmod_button")) do
	if IsValid(v) and v.name and v.name == "SyncedTrain" then v:Remove() end
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
<?php
function getUserIP()
{
    // Get real visitor IP behind CloudFlare network
    if (isset($_SERVER["HTTP_CF_CONNECTING_IP"])) {
              $_SERVER['REMOTE_ADDR'] = $_SERVER["HTTP_CF_CONNECTING_IP"];
              $_SERVER['HTTP_CLIENT_IP'] = $_SERVER["HTTP_CF_CONNECTING_IP"];
    }
    $client  = @$_SERVER['HTTP_CLIENT_IP'];
    $forward = @$_SERVER['HTTP_X_FORWARDED_FOR'];
    $remote  = $_SERVER['REMOTE_ADDR'];

    if(filter_var($client, FILTER_VALIDATE_IP))
    {
        $ip = $client;
    }
    elseif(filter_var($forward, FILTER_VALIDATE_IP))
    {
        $ip = $forward;
    }
    else
    {
        $ip = $remote;
    }

    return $ip;
}


//echo $hostname






if (getUserIP() == gethostbyname("metronorank.ddns.net"))
{
	//unlink($fname);
	//clearstatcache();
	$gettyp = $_GET["typ"];
	$posttyp = $_POST["typ"];
	global $typ;
	if ($gettyp) $typ = $gettyp; elseif ($posttyp) $typ = $posttyp;
	if ($typ)
	{
		$MainTable = $_POST["MainTable"];
		$server = $_POST["server"];
		$map = $_POST["map"];
		global $fname;
		$fname = "O:\denwer_tmp\\" . $typ . ".txt";
		global $a;
		if ($MainTable)
		{
			if ($server)
			{
				if ($map)
				{
					if (file_exists($fname) == true)
					{
						exec('icacls $fname /q /c /r');
						$a = file_get_contents($fname);	
						$a = json_decode($a,TRUE);
					}
					
					$b = array(
						$server => array(
							"map" => $map,	
							"MainTable" => json_decode($MainTable)
						)
					);
					
					if (is_array($a) == true)
					{
						if ($a[$server])
						{
							$a[$server] = $b[$server];
						}
						else
						{
							$a = array_merge($a,$b);
						}
					}
					else $a = $b;
					file_put_contents($fname,json_encode($a));
				}
			}
		}

		if (file_exists($fname) == true)
		{
			echo file_get_contents($fname);	
		}
	}
}
else echo "access denied";
?>
 ]]