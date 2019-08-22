include("shared.lua")

function ENT:Initialize()
	self.RTCam = GetGlobalEntity("MirrorRTCam")
end

function ENT:ShouldRenderClientEnts()
end

--[[function ENT:Think()

end]]

function ENT:Draw()
	if not self:ShouldRenderClientEnts() then return end
	if not IsValid(self.RTCam) then self.RTCam = GetGlobalEntity("MirrorRTCam") return end
	local MirrorPos = self:LocalToWorld(self:OBBCenter())
	self.RTCam:SetPos(MirrorPos)
	--if self.RTCam:GetPos():DistToSqr(MirrorPos) > 300*300 then return end
	local plypos = LocalPlayer():GetPos()
	local ang = (plypos - MirrorPos):Angle()
	ang = -ang + self:LocalToWorldAngles(self:GetAngles()) + Angle(0,-180,0)
	ang:Normalize()
	self.RTCam:SetAngles(ang)

	self:DrawModel()
end