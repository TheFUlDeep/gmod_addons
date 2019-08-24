AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function GetPly()
	for k,v in pairs(player.GetAll()) do
		return v
	end
end

function ENT:Initialize()

	self:SetModel(self.Model or "models/thefuldeeps_models/mirror_square.mdl")
	--self:PhysicsInit( SOLID_VPHYSICS )
	--self:SetMoveType( MOVETYPE_VPHYSICS )
	--self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	--local Mat = Material("models/rendertarget")	--тут я "вычислял" параметры материала "рендертаргет"
	--print(Mat)
	--print(Mat:GetString("$basetexture"))
	
	local RTCam = GetGlobalEntity("MirrorRTCam")
	if not IsValid(RTCam) then
		RTCam = ents.Create( "point_camera" )
		RTCam:SetKeyValue( "GlobalOverride", 1 )
		--RTCam:Activate()
		--RTCam:Spawn()
		SetGlobalEntity("MirrorRTCam",RTCam)
	end
	
end

--[[function ENT:OnRemove()
	local RTCam = GetGlobalEntity("MirrorRTCam")
	if IsValid(RTCam) then RTCam:Remove() print("removed") end
end]]