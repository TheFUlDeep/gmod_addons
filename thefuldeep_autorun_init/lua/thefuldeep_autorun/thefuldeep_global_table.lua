if CLIENT then return end
if not THEFULDEEP then THEFULDEEP = {} end		--THEFULDEEP is global table

hook.Add("PlayerInitialSpawn","THEFULDEEPTBL INITIALIZE",function()
	--THEFULDEEP.SERVERNAME = GetHostName()		мне это пока не нужно
	THEFULDEEP.HOSTNAME = game.GetIPAddress()
	THEFULDEEP.MAP = game.GetMap()
	THEFULDEEP.SERVERINFOINITIALIZED = true
end)

THEFULDEEP.SERVERINFO = {}			
--print(THEFULDEEP.GETSERVERINFOLOCAL)		таблица получения полной информации на этом сервере (нужен файл server_info.lua)
THEFULDEEP.WEBSERVERIP = file.Read("web_server_ip.txt")
local WebServerUrl = "http://"..(THEFULDEEP.WEBSERVERIP or "127.0.0.1").."/serverinfo/"

THEFULDEEP.GETSERVERINFOGLOBAL = function()
	if not THEFULDEEP.SERVERINFOINITIALIZED then return end
	if MetrostroiSyncEnabled then
		http.Fetch(
			WebServerUrl,
			function(body)
				body = util.JSONToTable(body)
				if body then
					THEFULDEEP.SERVERINFO = body
				end
			end,
			function()
				THEFULDEEP.SERVERINFO = {}
			end
		)
	else
		THEFULDEEP.SERVERINFO[THEFULDEEP.HOSTNAME] = THEFULDEEP.GETSERVERINFOLOCAL()
	end
end