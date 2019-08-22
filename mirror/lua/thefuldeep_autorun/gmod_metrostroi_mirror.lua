--TODO наклоны по вертикали
--TODO модели
--TODO фикс конфликта с камерами метростроя

if SERVER then
	if not THEFULDEEP then THEFULDEEP = {} end
	local function SpawnMirror(pos,ang)
		local mirror = ents.Create("gmod_metrostroi_mirror")
		if not IsValid(mirror) then print("ERROR with createin mirror") return end
		mirror:Spawn()
		timer.Simple(0.3,function()
			mirror:SetPos(pos)
			mirror:SetAngles(ang)
		end)
		print("Mirror spawned")
		return mirror
	end
	
	THEFULDEEP.SpawnMirror = SpawnMirror
	
	--[[hook.Add("Think","DisableMirrors",function()
		local RTCam = GetGlobalEntity("MirrorRTCam")
		if IsValid(RTCam) then
			RTCam:SetKeyValue( "GlobalOverride", RTCam:GetNW2Bool("GlobalOverride",false) and 1 or 0 )
		end
	end)
	hook.Remove("Think","DisableMirrors")]]
	
	concommand.Add("mirrors_save", function()
		local File = file.Read("mirrors.txt")
		local Mirrors = File and util.JSONToTable(File) or {}
		local Map = game.GetMap()
		Mirrors[Map] = {}
		for _,ent in pairs(ents.FindByClass("gmod_metrostroi_mirror")) do
			if IsValid(ent) then table.insert(Mirrors[Map],1,{ent:GetPos(),ent:GetAngles()}) end
		end
		if #Mirrors[Map] < 1 then print("no mirrors") return end
		file.Write("mirrors.txt", util.TableToJSON(Mirrors))
		print("mirrors saved")
	end)
	
	concommand.Add("mirrors_load", function()
		local File = file.Read("mirrors.txt")
		local Mirrors = File and util.JSONToTable(File) or {}
		local Map = game.GetMap()
		
		for k,v in pairs(ents.FindByClass("gmod_metrostroi_mirror")) do
			print("removed mirror")
			v:Remove()
		end
		timer.Simple(1,function()
		if not Mirrors[Map] or #Mirrors[Map] < 1 then print("no mirrors for this map") 
			return 
		else
			for _,mirror in ipairs(Mirrors[Map]) do
				SpawnMirror(mirror[1],mirror[2])
			end
		end
		print("loaded "..table.Count(ents.FindByClass("gmod_metrostroi_mirror")).." mirrors")
		end)
	end)
	
	hook.Add("PlayerInitialSpawn","SpawnMirrors",function() 
		hook.Remove("PlayerInitialSpawn","SpawnMirrors")
		RunConsoleCommand("mirrors_load")
	end)
	
end
if SERVER then return end


--[[local w,h = 512,512
local rtTexture = surface.GetTextureID( "pp/rt" )
		

local function DrawRTTexture()
	if 1 then return end
	-- draw render target
	surface.SetTexture( rtTexture )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0 , 0, w, h )
end

timer.Create("DrawMetrostroiMirror",1,0,function()
	hook.Add( "HUDPaint", "DrawRTTexture", DrawRTTexture )
end)]]