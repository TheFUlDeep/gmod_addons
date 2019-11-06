if SERVER then return end

gameevent.Listen("player_spawn")
hook.Add("player_spawn","AudioNotificationWhenSuperAdminSpawned",function(data)
	timer.Simple(1,function()
		local ply  = Player(data.userid)
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end
		sound.PlayURL( 
			"https://cdn.discordapp.com/attachments/622487500308611101/641683411471171595/vv324513450981jh.mp3",
			"mono",
			function(audio)	--я не понимаю, зачем эта функция. Оно восрпоизводит, даже если функция пустая
				if not IsValid(audio) then return end
				--audio:Play()
			end
		)
	end)
end)

local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/loading_screen/"

timer.Simple(0,function()
	RunConsoleCommand("sv_loadingurl",WebServerUrl)
end)
