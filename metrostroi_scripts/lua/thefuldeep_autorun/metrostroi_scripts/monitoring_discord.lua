if CLIENT then return end

include("server/websocket.lua")
local wevsocketPort = 228
local discordChannelID = "622503663998468096"

if not file.Exists("web_server_ip.txt","DATA") or not WS then return end
local webserverip = file.Read("web_server_ip.txt","DATA")
if not webserverip:find("%a") and not webserverip:find("%d") then return end
local ws = WS.Client(webserverip,wevsocketPort)
local map = game.GetMap()
local maxplayers = tostring(game.MaxPlayers())

local function TimerFunc()
	local ipAddress = game.GetIPAddress()
	if ipAddress:sub(1,7) == "0.0.0.0" then return end
	if not ws:IsActive() then
		ws:Close()
		ws = WS.Client(webserverip,wevsocketPort)
		ws:Connect()
		return
	end
	
	--айди канала, имя сервера, адрес сервера, карта, максимальное количество игроков, вагоны, список игроков
	local data = {discordChannelID,GetHostName(),ipAddress,map,maxplayers,GetGlobalInt("metrostroi_train_count",0)..'/'..GetGlobalInt("metrostroi_maxwagons",0)}
	
	local players = player.GetHumans()
	if #players > 0 then
		data[7] = {}
		local tbl = data[7]
		for k,ply in pairs(player.GetHumans())do
			tbl[k] = ply:Nick().." ("..ply:SteamID()..")"
		end
	end
	ws:Send(util.TableToJSON(data))
end

timer.Simple(5,TimerFunc)
timer.Create("Send server info to discord bot",30,0,TimerFunc)