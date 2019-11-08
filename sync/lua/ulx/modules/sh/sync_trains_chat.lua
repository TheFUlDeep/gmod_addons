if SERVER then
	function ulx.metrostroisync(ply)
		MetrostroiSyncEnabled = not MetrostroiSyncEnabled
	end
end

local metrostroisync = ulx.command("Metrostroi", "ulx metrostroisync", ulx.metrostroisync, "!metrostroisync",true)
metrostroisync:defaultAccess(ULib.ACCESS_SUPERADMIN)
metrostroisync:help("Включение/отключение синхронизации паравозов и чата")