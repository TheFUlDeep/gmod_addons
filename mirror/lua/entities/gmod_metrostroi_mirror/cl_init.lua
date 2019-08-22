include("shared.lua")

function ENT:Initialize()
	self.RTCam = GetGlobalEntity("MirrorRTCam")
	--self.RTCam:SetKeyValue("FOV",10)
end

--[[function ENT:ShouldRenderClientEnts()
end]]

--[[function ENT:Think()

end]]


local MetrostroiDrawCams--,C_CabFOV,C_FovDesired
timer.Simple(0,function()
	MetrostroiDrawCams = GetConVar("metrostroi_drawcams")
	--C_CabFOV              = GetConVar("metrostroi_cabfov")
	--C_FovDesired          = GetConVar("fov_desired")
end)

function ENT:Draw()
	if MetrostroiDrawCams and not MetrostroiDrawCams:GetBool() then return end
	--if not self:ShouldRenderClientEnts() then return end
	if not IsValid(self.RTCam) then self.RTCam = GetGlobalEntity("MirrorRTCam") return end

	self:DrawModel()
	--[[if #Metrostroi.CamQueue > 0 then
		if self.RTCam.GlobalOverride1 then
			self.RTCam:SetNW2Bool("GlobalOverride",false)
			self.RTCam.GlobalOverride1 = false
		end
		print("a")
		return 
	end
	print("b")
	
	if not self.RTCam.GlobalOverride1 then
		self.RTCam:SetNW2Bool("GlobalOverride",true)
		self.RTCam.GlobalOverride1 = true
	end]]
	
	local MirrorPos = self:LocalToWorld(self:OBBCenter())
	self.RTCam:SetPos(MirrorPos)
	--if self.RTCam:GetPos():DistToSqr(MirrorPos) > 300*300 then return end
	local ply = LocalPlayer()
	local plypos = ply:EyePos()
	local ang = (plypos - MirrorPos):Angle()
	ang = -ang + self:LocalToWorldAngles(self:GetAngles()) + Angle(0,-180,0)
	ang:Normalize()
	self.RTCam:SetAngles(ang)
	
	--[[local FOV
	local Dist = plypos:DistToSqr(MirrorPos)
	local veh = ply:GetVehicle()
	if IsValid(veh) then
		veh = veh:GetNW2Entity("TrainEntity")
	end
	if IsValid(veh) then
		FOV = C_CabFOV:GetFloat()
	else
		FOV = C_FovDesired:GetFloat()
	end]]
end