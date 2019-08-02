if not THEFULDEEP then THEFULDEEP = {} end
THEFULDEEP.PLAYERCOUNT = 0

if SERVER then
	util.AddNetworkString("tfd_spawnmsg")
	util.AddNetworkString("tfd_connectmsg")
	
	hook.Add("PlayerInitialSpawn", "tfd_spawnmsg",function(ply)
		timer.Simple(1,function()
			if not IsValid(ply) then return end
			net.Start("tfd_spawnmsg")
				net.WriteString(ply:Nick())
				net.WriteColor(team.GetColor(ply:Team()))
			net.Broadcast()
		end)
	end)
	
	gameevent.Listen( "player_connect" )
	hook.Add("player_connect", "tfd_connectmsg",function(data)
		THEFULDEEP.PLAYERCOUNT = THEFULDEEP.PLAYERCOUNT + 1
		net.Start("tfd_connectmsg")
			net.WriteString(data.name)
		net.Broadcast()
	end)
end


if CLIENT then
	net.Receive("tfd_connectmsg",function()
		local nick = net.ReadString()
		chat.AddText(color_white,'Игрок "'..nick..'"', Color(255,255,0)," присоединяется",color_white,".")
	end)
	
	net.Receive("tfd_spawnmsg",function()
		local nick = net.ReadString()
		local color = net.ReadColor()
		chat.AddText(color_white,"Игрок ",'"',color,nick,color_white,'"',Color(150,255,0)," заспавнился",color_white,".")
	end)
end