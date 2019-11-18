--[[============================= ЗАГРУЗКА ПОСЛЕДНЕЙ КАРТЫ сохранение последней карты прописано в mapcycle ==========================]]
if SERVER then
timer.Create("CheckLastMap",1,0,function()
	if not THEFULDEEP or not THEFULDEEP.MAP then return end
	if file.Exists( "lastmap.txt", "DATA" ) then
		local lastmap = file.Read( "lastmap.txt", "DATA" )
		if lastmap and lastmap:lower():find("%a") and THEFULDEEP.MAP ~= lastmap then 
			game.ConsoleCommand("changelevel "..lastmap.."\n") 		
			return
		end
	end
	timer.Remove("CheckLastMap")
end)
end