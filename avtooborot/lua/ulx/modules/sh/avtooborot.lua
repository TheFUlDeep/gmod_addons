if SERVER then
	function ulx.avtooborot(ply,comm)
		AvtooborotControl(ply,comm)
	end
end
local avtooborot = ulx.command("Metrostroi", "ulx avtooborot", ulx.avtooborot, "!avtooborot",true)
avtooborot:addParam{ type=ULib.cmds.StringArg, hint="команда для автооборота"}
avtooborot:defaultAccess(ULib.ACCESS_OPERATOR)
avtooborot:help("Управление автооборотом.")