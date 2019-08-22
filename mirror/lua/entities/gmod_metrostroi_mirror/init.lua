AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function GetPly()
	for k,v in pairs(player.GetAll()) do
		return v
	end
end

function ENT:Initialize()

	self:SetModel(self.Model)
	--self:PhysicsInit( SOLID_VPHYSICS )
	--self:SetMoveType( MOVETYPE_VPHYSICS )
	--self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	--self:SetPos(self:GetPos()+Vector(0,0,250))
	
	self:SetModelScale(2)
	
	self:SetMaterial("models/rendertarget")
	
	local RTCam = GetGlobalEntity("MirrorRTCam")
	if not IsValid(RTCam) then
		RTCam = ents.Create( "point_camera" )
		RTCam:SetKeyValue( "GlobalOverride", 1 )
		SetGlobalEntity("MirrorRTCam",RTCam)
	else
		local ang = self:GetAngles()
		self:SetAngles(Angle(0,ang.y-90,ang.r))
		local Pos = self:LocalToWorld(self:OBBCenter())
		RTCam:SetPos(Pos)
	end
	
	
	--RenderTargetCamera:Spawn()
end