if CLIENT then return end

local function SpawnPlatform(platformpos,startpos,endpos,stationindex,platformindex,islast,horlift)
    local Platform = ents.Create("gmod_track_platform")
    Platform.Type = "lua platform"
    
    Platform:SetPos(platformpos)
    
    Platform.VMF = {}
    
    local PlatformStart = ents.Create("gmod_button")
    PlatformStart:SetPos(startpos)
    PlatformStart:SetModel("models/dav0r/buttons/button.mdl" )
    PlatformStart:SetName("PlatformStart"..stationindex..platformindex)
    PlatformStart.Type = "lua platform"
    PlatformStart:Spawn()
    Platform.VMF.PlatformStart = PlatformStart:GetName()
    
    local PlatformEnd = ents.Create("gmod_button")
    PlatformEnd:SetPos(endpos)
    PlatformEnd:SetModel("models/dav0r/buttons/button.mdl" )
    PlatformEnd:SetName("PlatformEnd"..stationindex..platformindex)
    PlatformEnd.Type = "lua platform"
    PlatformEnd:Spawn()
    Platform.VMF.PlatformEnd = PlatformEnd:GetName()
    
    Platform.VMF.StationIndex = stationindex
    Platform.VMF.PlatformIndex = platformindex
    
    Platform.VMF.PlatformLast = islast and "yes"
    
    Platform.VMF.HorliftStation = horlift
    
    Platform:Spawn()
    PlatformStart:Remove()
    PlatformEnd:Remove()
    
    return Platform
end

local function InitPlatformsSpawn()
	local function SpawnLuaPlatforms()
		for _,ent in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(ent) or not ent.Type or ent.Type ~= "lua platform" then continue end
			ent:Remove()
		end
		SpawnPlatform(
			Vector(11999.375000, -10255.084961, -14188.489258),
			Vector(12018.311523, -9232.045898, -14177.619141),
			Vector(12004.626953, -11972.561523, -14159.229492),
			228,
			2
		)
		
		RunConsoleCommand("metrostroi_load")
	end
	SpawnLuaPlatforms()
	hook.Add("PlayerInitialSpawn","Spawn lua metrostroi platforms",function()--такой хук еще исопльзуется в редуксе, так что надо будет поменять азвание
		hook.Remove("PlayerInitialSpawn","Spawn lua metrostroi platforms")
		timer.Simple(0.5, SpawnLuaPlatforms)
	end)
end

--InitPlatformsSpawn()