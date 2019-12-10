timer.Create("AutoDonate_Kill",1,0,function()
	hook.Remove("PlayerInitialSpawn","IGSFail")
	if timer.Exists("IGSFail") then timer.Remove("IGSFail") end
end)