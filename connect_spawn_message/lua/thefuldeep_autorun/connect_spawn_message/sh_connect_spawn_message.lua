if not THEFULDEEP then THEFULDEEP = {} end
THEFULDEEP.PLAYERCOUNT = 0

if SERVER then
	util.AddNetworkString("tfd_spawnmsg")
	util.AddNetworkString("tfd_connectmsg")
	
	hook.Add("PlayerInitialSpawn", "tfd_spawnmsg",function(ply)
		timer.Simple(1,function()
			if not IsValid(ply) then return end
			local PlayerCount = player.GetCount()
			if THEFULDEEP.PLAYERCOUNT < PlayerCount then THEFULDEEP.PLAYERCOUNT = PlayerCount end --TODO это костыль. Почему-то может произойти, что дисконнектов больше, чем коннектов
			local NickColor = team.GetColor(ply:Team())
			local Nick = ply:Nick()
			net.Start("tfd_spawnmsg")
				net.WriteString(Nick)
				net.WriteColor(NickColor)
				net.WriteBool(ply:IsSuperAdmin())
			net.Broadcast()
			if not Metrostroi or not Metrostroi.MetrostroiSync or not Metrostroi.MetrostroiSync.sendText then return end
			local text1 = {
				Colors = {
					"",
					NickColor.r.." "..NickColor.g.." "..NickColor.b.." "..NickColor.a,
					"",
					"150 255 0 0"
				},
				Texts = {
					'Игрок "',
					Nick,
					'"',
					" заспавнился",
					"."
				}
			}
			Metrostroi.MetrostroiSync.sendText(text1)
		end)
	end)
	
	gameevent.Listen( "player_connect" )
	hook.Add("player_connect", "tfd_connectmsg",function(data)
		THEFULDEEP.PLAYERCOUNT = THEFULDEEP.PLAYERCOUNT + 1
		net.Start("tfd_connectmsg")
			net.WriteString(data.name)
		net.Broadcast()
		if not Metrostroi or not Metrostroi.MetrostroiSync or not Metrostroi.MetrostroiSync.sendText then return end
		local text1 = {
			Colors = {
				"",
				"255 255 0 0"
			},
			Texts = {
				'Игрок "'..data.name..'"',
				" присоединяется",
				"."
			}
		}
		Metrostroi.MetrostroiSync.sendText(text1)
	end)
end


if CLIENT then
	net.Receive("tfd_connectmsg",function()
		local nick = net.ReadString()
		chat.AddText(color_white,'Игрок "'..nick..'"', color_255_255_0," присоединяется",color_white,".")
	end)
	
	net.Receive("tfd_spawnmsg",function()
		local nick = net.ReadString()
		local color = net.ReadColor()
		local IsAdmin = net.ReadBool()
		chat.AddText(color_white,"Игрок ",'"',color,nick,color_white,'"',color_155_255_0," заспавнился",color_white,".")
		
		if IsAdmin then
			sound.PlayURL( 
				"https://cdn.discordapp.com/attachments/622487500308611101/641683411471171595/vv324513450981jh.mp3",
				"mono",
				function(audio)	--я не понимаю, зачем эта функция. Оно восрпоизводит, даже если функция пустая
					if not IsValid(audio) then return end
					audio:SetVolume(0.15)
					--audio:Play()
				end
			)
		end
		
	end)
end