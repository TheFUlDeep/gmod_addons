if CLIENT then return end

local HostName
local Map
local NotInitialized = true
timer.Simple(0,function()
	HostName = game.GetIPAddress()
	Map = game.GetMap()
	NotInitialized = false
end)

local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/sync/"

local function SendToWebServer(tbl,url,typ)
	if NotInitialized then return end
	if GetConVar("sv_password"):GetString() and GetConVar("sv_password"):GetString() ~= "" then
		tbl.password = "true"
	end
	local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName, map = Map,typ = typ}
	http.Post(url, TableToSend)
end

hook.Add("PlayerInitialSpawn","SpawnRedirect",function(ply)
	timer.Simple(1, function()
		SendToWebServer({ip = HostName,count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
		if ply:GetUserGroup() == "superadmin" then return
		elseif game.MaxPlayers() == player.GetCount() then ulx.redirect(ply)
		end
	end)
end)

hook.Add("PlayerConnect","RedirectConnect",function()
	SendToWebServer({ip = HostName,count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
end)

hook.Add("PlayerDisconnected","RedirectDisconnect",function()
	timer.Simple(1,function()
		SendToWebServer({ip = HostName,count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
	end)
end)

hook.Add("ShutDown","RedirectShutDown",function()
	SendToWebServer({ShutDown = "SHUTDOWN"},WebServerUrl,"PlayerCount")
end)