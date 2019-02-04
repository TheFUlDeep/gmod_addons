	--[[============================= АВТООБОРОТ реализация в аддоне avtooborot ==========================]]
if SERVER then
	function ulx.avtooborottoggle(ply)
		if AvtooborotEnabled == 0 then
			ulx.fancyLogAdmin(ply, "#A включил автооборот") 
			createavtooborot()
		elseif AvtooborotEnabled == 1 then 
			ulx.fancyLogAdmin(ply, "#A отключил автооборот") 
			deleteavtooborot()
		end
	end
end
local avtooborottoggle = ulx.command( "Metrostroi", "ulx avtooborottoggle", ulx.avtooborottoggle, "!avtooborottoggle", true )
avtooborottoggle:defaultAccess( ULib.ACCESS_OPERATOR )
avtooborottoggle:help( "Включить/выключить автооборот" )