	--[[============================= АВТООБОРОТ реализация в аддоне avtooborot ==========================]]
function ulx.avtooborottoggle(ply)
	AvtooborotToggle(ply)
end
local avtooborottoggle = ulx.command( "Metrostroi", "ulx avtooborottoggle", ulx.avtooborottoggle, "!avtooborottoggle", true )
avtooborottoggle:defaultAccess( ULib.ACCESS_OPERATOR )
avtooborottoggle:help( "Включить/выключить автооборот" )