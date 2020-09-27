--====================ДИСКОННЕКТ ИГРОКА======================================--
--СЕРВЕРНЫЙ
if SERVER then
	util.AddNetworkString("SB_PlayerDisconnectedMessage")
	gameevent.Listen("player_disconnect")

	hook.Add("player_disconnect","SB_PlayerDisconnectedMessage",function(data)
		timer.Simple(1,function()
			if THEFULDEEP and THEFULDEEP.PLAYERCOUNT then 
				THEFULDEEP.PLAYERCOUNT = THEFULDEEP.PLAYERCOUNT - 1 
				local PlayerCount = player.GetCount()
				if THEFULDEEP.PLAYERCOUNT < PlayerCount then THEFULDEEP.PLAYERCOUNT = PlayerCount end --TODO это костыль. Почему-то может произойти, что дисконнектов больше, чем коннектов
			end
		end)
		net.Start("SB_PlayerDisconnectedMessage")
			net.WriteString(data.name)
			net.WriteString(data.networkid)
			net.WriteString(data.reason)
		net.Broadcast()
		if not Metrostroi or not Metrostroi.MetrostroiSync or not Metrostroi.MetrostroiSync.sendText then return end
		local text1 = {
			Colors = {
				"",
				"255 0 0 0"
			},
			Texts = {
				'Игрок "'..data.name..'"'.."("..data.networkid..")",
				" вышел",
				" c сервера ("..data.reason..")."
			}
		}
		Metrostroi.MetrostroiSync.sendText(text1)
	end)
end

--КЛИЕНТСКИЙ
if CLIENT then
	net.Receive("SB_PlayerDisconnectedMessage",function(len)
		local nick,steam,reason = net.ReadString(),net.ReadString(),net.ReadString()

		chat.AddText(color_white,"Игрок \"",nick,"\"(",steam,") ",color_255_0_0,"вышел ",color_white,"с сервера (",reason,").")
	end)
end







--====================ЗАГРУЗКА ИГРОКА======================================--
--СЕРВЕРНЫЙ
if SERVER then
	util.AddNetworkString("SB_PlayerLoaded")

	net.Receive("SB_PlayerLoaded",function(len,ply)
		if ply.AntiAfk and ply.AntiAfk.AfkBlock then ply.AntiAfk.AfkBlock = nil end	--this line for anti_afk.lua
		local NickColor = team.GetColor(ply:Team())
		local Nick = ply:Nick()
		net.Start("SB_PlayerLoaded")
			net.WriteString(Nick)
			net.WriteColor(NickColor)
		net.Broadcast()
		if not Metrostroi or not Metrostroi.MetrostroiSync or not Metrostroi.MetrostroiSync.sendText then return end
		local text1 = {
			Colors = {
				"",
				NickColor.r.." "..NickColor.g.." "..NickColor.b.." "..NickColor.a,
				"",
				"0 255 0 0"
			},
			Texts = {
				'Игрок "',
				Nick,
				'"',
				" загрузился",
				"."
			}
		}
		Metrostroi.MetrostroiSync.sendText(text1)

		hook.Run("PlayerLoaded",ply)
	end)
end

--КЛИЕНТСКИЙ
if CLIENT then
	if !IsValid(LocalPlayer()) then
		hook.Add("Think","SB_PlayerLoaded",function()
			if !IsValid(LocalPlayer()) then return end

			net.Start("SB_PlayerLoaded")
			net.SendToServer()

			hook.Remove("Think","SB_PlayerLoaded")
			hook.Run("PlayerLoaded",LocalPlayer())
		end)
	end

	net.Receive("SB_PlayerLoaded",function(len)
		local nick = net.ReadString()
		local color = net.ReadColor()

		chat.AddText(color_white,"Игрок \"",color,nick,color_white,"\"",color_0_255_0," загрузился",color_white,".")
	end)
end