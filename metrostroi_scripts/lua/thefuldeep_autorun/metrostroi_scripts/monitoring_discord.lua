if CLIENT then return end

local wevsocketPort = 228
local discordGuildID = "622155158952083482"
local discordChannelID = "622503663998468096"

if not file.Exists("webserverip.txt","DATA") or not WS then return end
local webserverip = file.Read("webserverip.txt","DATA")
if not webserverip:find("%a") or not webserverip:find("%d") then return end
local ws = WS.Client(webserverip,wevsocketPort)
local map = game.GetMap()
local maxplayers = tostring(game.MaxPlayers())
timer.Create("Send server info to discord bot",1,0,function()
	local ipAddress = game.GetIPAddress()
	if ipAddress:sub(1,7) == "0.0.0.0" then return end
	if not ws:IsActive() then
		ws:Connect()
		return
	end
	
	--айди гильдии, айди канала, имя сервера, адрес сервера, карта, максимальное количество игроков, вагоны, список игроков
	local data = {discordGuildID,discordChannelID,GetHostName(),ipAddress,map,maxplayers,GetGlobalInt("metrostroi_train_count",0)..'/'..GetGlobalInt("metrostroi_maxwagons",0)}
	
	local players = player.GetHumans()
	if #players > 0 then
		data[8] = {}
		local tbl = data[8]
		for k,ply in pairs(player.GetHumans())do
			tbl[k] = ply:Nick().." ("..ply:SteamID()..")"
		end
	end
	ws:Send(util.TableToJSON(data))
end)

