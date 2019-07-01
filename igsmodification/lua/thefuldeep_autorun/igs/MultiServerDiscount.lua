if SERVER then
	hook.Add("PlayerInitialSpawn","IGS MultiServerDiscount",function()
		hook.Remove("PlayerInitialSpawn","IGS MultiServerDiscount")
		include("igs/settings/config_sh.lua")
		print("changed IGS.C.MultiServerDiscount to "..IGS.C.MultiServerDiscount)
	end)
end

if CLIENT then 
	timer.Create("IGS MultiServerDiscount",5,0,function()
		if not IGS or not IGS.C or not IGS.SERVERS or not IGS.SERVERS.ENABLED or IGS.SERVERS.ENABLED < 1 then return end
		timer.Remove("IGS MultiServerDiscount")
		IGS.C.MultiServerDiscount = 100 - (1 / IGS.SERVERS.ENABLED * 100) 
		print("changed IGS.C.MultiServerDiscount to "..IGS.C.MultiServerDiscount)
	end)
end