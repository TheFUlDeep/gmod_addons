include("shared.lua")

function ENT:Initialize()
	self.RTCam = GetGlobalEntity("MirrorRTCam")
	--self.RTCam:SetKeyValue("FOV",10)
end

--[[function ENT:ShouldRenderClientEnts()
end]]

--[[function ENT:Think()

end]]




function ENT:Draw()
	THEFULDEEP.MirrorDraw(self)
end