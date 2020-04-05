if CLIENT then return end

local serverstarted = os.time()
timer.Create("autorestart",10,0,function()
	if ((os.time() - serverstarted) > (6*60*60)) and table.IsEmpty(player.GetHumans() or {}) then RunConsoleCommand("_restart") end
end