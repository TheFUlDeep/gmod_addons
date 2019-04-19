--[[============================= ЗАГРУЗКА ПОСЛЕДНЕЙ КАРТЫ сохранение последней карты прописано в mapcycle ==========================]]
if SERVER then
	hook.Add( "PlayerConnect", "lastmap", function()
		hook.Remove("PlayerConnect", "lastmap")
		if file.Exists( "lastmap.txt", "DATA" ) then
			local lastmap = file.Read( "lastmap.txt", "DATA" )
			if game.GetMap() ~= lastmap then game.ConsoleCommand("changelevel "..lastmap.."\n") end
		end
	end)
end