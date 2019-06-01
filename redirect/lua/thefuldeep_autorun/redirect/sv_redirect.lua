if CLIENT then return end
local WebServerUrl = "http://212.22.77.19/metrostroi/sync/"

local function SendToWebServer(tbl,url,typ)
	if GetConVar("sv_password"):GetString() and GetConVar("sv_password"):GetString() ~= "" then
		tbl.password = "true"
	end
	local TableToSend = {MainTable = util.TableToJSON(tbl), server = GetHostName(), map = game.GetMap(),typ = typ}
	http.Post(url, TableToSend)
end

hook.Add("PlayerInitialSpawn","SpawnRedirect",function(ply)
	timer.Simple(1, function()
		SendToWebServer({ip = game.GetIPAddress(),count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
		if ply:GetUserGroup() == "superadmin" then return
		elseif game.MaxPlayers() == player.GetCount() then ulx.redirect(ply)
		end
	end)
end)

hook.Add("PlayerConnect","RedirectConnect",function()
	SendToWebServer({ip = game.GetIPAddress(),count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
end)

hook.Add("PlayerDisconnected","RedirectDisconnect",function()
	timer.Simple(1,function()
		SendToWebServer({ip = game.GetIPAddress(),count = player.GetCount(),maxx = game.MaxPlayers()},WebServerUrl,"PlayerCount")
	end)
end)

hook.Add("ShutDown","RedirectShutDown",function()
	SendToWebServer({ShutDown = "SHUTDOWN"},WebServerUrl,"PlayerCount")
end)