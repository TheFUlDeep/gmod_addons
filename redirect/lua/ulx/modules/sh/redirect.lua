--[[============================= РЕДИРЕКТ ==========================]]
if SERVER then
	local IpAdress = game.GetIPAddress()
	local MaxPlayers = game.MaxPlayers()
	local HostName = GetHostName()
	local Map = game.GetMap()
	local WebServerUrl = "http://metronorank.ddns.net/sync/"
	local function SendToWebServer(tbl,url,typ)
		local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName, map = Map,typ = typ}
		http.Post(url, TableToSend)
	end
	--SendToWebServer({ip = IpAdress,count = #player.GetAll(),maxx = MaxPlayers},WebServerUrl,"PlayerCount")
	
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
			if not v.MainTable then continue end
			for k1,v1 in pairs(v.MainTable) do
				table.insert(tbl2,1,v1)
			end
		end
		return tbl2
	end
	
	hook.Add("PlayerInitialSpawn","SpawnRedirect",function(ply)
		timer.Simple(1, function()
			SendToWebServer({ip = IpAdress,count = #player.GetAll(),maxx = MaxPlayers},WebServerUrl,"PlayerCount")
			if ply:GetUserGroup() == "superadmin" then return
			elseif game.MaxPlayers() == #player.GetAll() then ulx.redirect(ply)
			end
		end)
	end)
	hook.Add("PlayerDisconnected","RedirectDisconnect",function()
		timer.Simple(1,function()
			SendToWebServer({ip = IpAdress,count = #player.GetAll(),maxx = MaxPlayers},WebServerUrl,"PlayerCount")
		end)
	end)
	
	hook.Add("ShutDown","RedirectShutDown",function()
		for k,v in pairs(player.GetAll()) do
			ulx.redirect(v)
		end
		SendToWebServer({ip = IpAdress,count = 0,maxx = MaxPlayers},WebServerUrl,"PlayerCount")
	end)
	
	
	function ulx.redirect(ply)
		local PlayerCount = GetFromWebServer(WebServerUrl,"PlayerCount")
		if not PlayerCount then return end
		for k,v in pairs(PlayerCount) do
			if not v.ip or not v.count or not v.maxx then continue end
			if v.ip ~= IpAdress and v.count < v.maxx then 
				ply:SendLua([[LocalPlayer():ConCommand('connect ]]..tostring(v.ip)..[[')]])
				ulx.fancyLogAdmin(ply, true, "#A был перенаправлен на другой сервер")
				break
			end
		end
		--print(GetHostName())
		--print(redirectip)
	end
	
end
local redirect = ulx.command( "Utility", "ulx redirect", ulx.redirect, "!redirect", true, false, true )
redirect:defaultAccess( ULib.ACCESS_ALL )
redirect:help( "Перейти на другой сервер" )