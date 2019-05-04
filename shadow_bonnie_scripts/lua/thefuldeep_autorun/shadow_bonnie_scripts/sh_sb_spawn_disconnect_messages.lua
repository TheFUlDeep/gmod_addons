--====================ДИСКОННЕКТ ИГРОКА======================================--

--СЕРВЕРНЫЙ
if SERVER then
	util.AddNetworkString("SB_PlayerDisconnectedMessage")
	gameevent.Listen("player_disconnect")

	hook.Add("player_disconnect","SB_PlayerDisconnectedMessage",function(data)
		net.Start("SB_PlayerDisconnectedMessage")
			net.WriteString(data.name)
			net.WriteString(data.networkid)
			net.WriteString(data.reason)
		net.Broadcast()
	end)
end

--КЛИЕНТСКИЙ
if CLIENT then
	net.Receive("SB_PlayerDisconnectedMessage",function(len)
		local nick,steam,reason = net.ReadString(),net.ReadString(),net.ReadString()

		chat.AddText(color_white,"Игрок \"",nick,"\"(",steam,") ",Color(255,0,0),"вышел ",color_white,"с сервера (",reason,")")
	end)
end







--====================ЗАГРУЗКА ИГРОКА======================================--
--СЕРВЕРНЫЙ
if SERVER then
	util.AddNetworkString("SB_PlayerLoaded")

	net.Receive("SB_PlayerLoaded",function(len,ply)
		net.Start("SB_PlayerLoaded")
			net.WriteString(ply:Nick())
			net.WriteColor(team.GetColor(ply:Team()))
		net.Broadcast()

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

		chat.AddText(color_white,"Игрок \"",color,nick,color_white,"\"",Color(0,255,0)," загрузился",color_white,".")
	end)
end