for k,v in pairs(ents.FindByClass("gmod_metrostroi_mirror")) do
	v:Remove()
end

if SERVER then
	local function SpawnMirror(pos,ang)
		local mirror = ents.Create("gmod_metrostroi_mirror")
		if not IsValid(mirror) then print("ERROR with createin mirror") return end
		mirror:SetPos(pos)
		mirror:SetAngles(ang)
		mirror:Spawn()
		print("Mirror spawned")
	end
	for k,v in pairs(player.GetHumans()) do
		print(v:EyePos())
	end
	
	local function SpawnMirrors()
		local Map = game.GetMap()
		if Map == "gm_jar_pll" then
			SpawnMirror(Vector(12304.909180, -2448.336670, -14158),Angle(0,-90-20,0))
		end
	end
	SpawnMirrors()
	hook.Add("PlayerInitialSpawn","SpawnMirrors",SpawnMirrors)
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