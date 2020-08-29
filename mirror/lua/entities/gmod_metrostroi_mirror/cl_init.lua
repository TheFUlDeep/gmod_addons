include("shared.lua")
function ENT:Initialize()
	local IsSquare = self:GetModel():find("square") and true or false
	
	--self.Frame = ents.CreateClientProp()
	self.Frame = ClientsideModel(self:GetModel():gsub(".mdl","_frame.mdl"),RENDERGROUP_STATIC)--хз по поводу рендер группы
	self.Frame:SetPos(self:GetPos())
	--self.Frame:SetModel(self:GetModel():gsub(".mdl","_frame.mdl"))
	local ang = self:GetAngles()
	self.Frame:SetAngles(Angle(0,ang.y,0))
	local size = self:GetModelScale()
	self.Frame:SetModelScale(size)
	self.Frame:Spawn()
	
	local stickdown = not self:GetNW2Bool("StickDown",false)
	
	--self.Stick = ents.CreateClientProp()
	self.Stick = ClientsideModel("models/props_c17/signpole001.mdl",RENDERGROUP_STATIC)--хз по поводу рендер группы
	self.Stick:SetPos(self.Frame:LocalToWorld(not IsSquare and Vector(0,-2.5*size,stickdown and -153*size or 42*size) or Vector(0,-2.5*size,stickdown and -135*size or 25*size)))
	--self.Stick:SetModel("models/props_c17/signpole001.mdl")
	self.Stick:SetAngles(Angle(0,0,0))
	self.Stick:SetModelScale(size)
	self.Stick:Spawn()
	
	self.Draw = THEFULDEEP.MirrorDraw or function() end
end

--[[function ENT:ShouldRenderClientEnts()
end]]

--[[function ENT:Think()

end]]




function ENT:Draw()

end

function ENT:OnRemove()
	if IsValid(self.Frame) then self.Frame:Remove() end
	if IsValid(self.Stick) then self.Stick:Remove() end
end