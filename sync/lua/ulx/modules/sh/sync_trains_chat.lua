if SERVER then
	function ulx.metrostroisync(ply)
		if not MetrostroiSyncEnabled then
			MetrostroiSyncEnabled = true
			SyncTrainsThink()
			SyncChatThink()
			ulx.fancyLogAdmin(ply, "#A включил синхронизацию чата и поездов")
		else
			MetrostroiSyncEnabled = false
			ulx.fancyLogAdmin(ply, "#A отключил синхронизацию чата и поездов")
		end
	end
end

local metrostroisync = ulx.command("Metrostroi", "ulx metrostroisync", ulx.metrostroisync, "!metrostroisync",true)
metrostroisync:defaultAccess(ULib.ACCESS_SUPERADMIN)
metrostroisync:help("Включение/отключение синхронизации паравозов и чата")