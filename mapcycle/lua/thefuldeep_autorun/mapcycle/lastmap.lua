--[[============================= ЗАГРУЗКА ПОСЛЕДНЕЙ КАРТЫ сохранение последней карты прописано в mapcycle ==========================]]
if SERVER then
timer.Simple(0,function()
	if file.Exists( "lastmap.txt", "DATA" ) then
		local lastmap = file.Read( "lastmap.txt", "DATA" )
		if lastmap and lastmap:lower():find("%a") and lastmap ~= game.GetMap() then 
			game.ConsoleCommand("changelevel "..lastmap.."\n") 		
		end
	end
end)
end