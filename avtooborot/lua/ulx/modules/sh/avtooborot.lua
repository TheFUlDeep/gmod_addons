if SERVER then
	function ulx.autooborot(ply,comm)
		AvtooborotControl(ply,comm)
	end
end
local autooborot = ulx.command("Metrostroi", "ulx autooborot", ulx.autooborot, "!autooborot",true)
autooborot:addParam{ type=ULib.cmds.StringArg, hint="команда для автооборота"}
autooborot:defaultAccess(ULib.ACCESS_OPERATOR)
autooborot:help("Управление автооборотом.")