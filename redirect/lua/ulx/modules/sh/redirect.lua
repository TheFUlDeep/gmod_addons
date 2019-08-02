--[[============================= РЕДИРЕКТ ==========================]]
if SERVER then
	local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/serverinfo/"
	
	local function GetFromWebServer(url,ply)
		if not THEFULDEEP or not THEFULDEEP.HOSTNAME then return end
		http.Fetch( 
		url,
		function (outputTBL)
			if not outputTBL then return end
			outputTBL = util.JSONToTable(outputTBL)
			if not outputTBL then return end
			for ip,tbl in pairs(outputTBL) do
				if ip == THEFULDEEP.HOSTNAME then continue end
				if not tbl.PlayerCount or not tbl.MaxPlayers then continue end
				if tbl.MaxPlayers - tbl.PlayerCount > 1 then 
					ply:SendLua([[LocalPlayer():ConCommand('connect ]]..tostring(ip)..[[')]])
					ulx.fancyLogAdmin(ply, true, "#A был перенаправлен на другой сервер")
				end
			end
		end
		)
	end	
	
	function ulx.redirect(ply)
		GetFromWebServer(WebServerUrl,ply)
		--print(GetHostName())
		--print(redirectip)
	end
	
end
local redirect = ulx.command( "Utility", "ulx redirect", ulx.redirect, "!redirect", true)
redirect:defaultAccess( ULib.ACCESS_ALL )
redirect:help( "Перейти на другой сервер" )

if CLIENT then return end

hook.Add("PlayerInitialSpawn","SpawnRedirect",function(ply)
	timer.Simple(1, function()
		if ply:GetUserGroup() == "superadmin" then return
		elseif game.MaxPlayers() == player.GetCount() then ulx.redirect(ply)
		end
	end)
end)