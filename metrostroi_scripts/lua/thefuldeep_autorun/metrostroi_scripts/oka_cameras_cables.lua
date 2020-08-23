if CLIENT then return end

timer.Simple(1,function()
	local ochkaG = "gmod_subway_81-760"
	local ochkaP = "gmod_subway_81-761"
	local ochka = {[ochkaG]={rear = {Vector(-464.115234, 33.789383, -34),Vector(-464.115265, -36.757870, -34)}},[ochkaP]={rear = {Vector(-464.115295, 34.050331, -34),Vector(-464.115295, -35.828068, -34)}, front = {Vector(464.115356, -35.108238, -34),Vector(464.115326, 35.117596, -34)}}}

	local ENT = scripted_ents.GetStored("gmod_train_couple")
	if not ENT then return else ENT = ENT.t end
	
	local oldcouple = ENT.Couple
	ENT.Couple = function(self,ent,...)
			oldcouple(self,ent,...)
		
		if IsValid(self.CameraCable1) then return end
		
		if not IsValid(ent) then return end
		
		local selfwag = self:GetNW2Entity("TrainEntity")
		if not IsValid(selfwag) then return end
		local selfwagClass = selfwag:GetClass()
		if not ochka[selfwagClass] then return end
		
		local entwag = ent:GetNW2Entity("TrainEntity")
		if not IsValid(entwag) then return end
		local entwagClass = entwag:GetClass()
		if not ochka[entwagClass] then return end
		
		local IsSelfRear = self == selfwag.RearCouple
		if not IsSelfRear and selfwagClass == ochkaG then return end
		
		local IsEntRear = ent == entwag.RearCouple
		if not IsEntRear and entwagClass == ochkaG then return end
		
		local IsSameDir = IsSelfRear and not IsEntRear or not IsSelfRear and IsEntRear
		
		local CameraCable1 =  constraint.Rope(
			selfwag,entwag,
			0,0,
			IsSameDir and (IsSelfRear and ochka[selfwagClass].rear[1] or ochka[selfwagClass].front[1]) or IsSelfRear and ochka[selfwagClass].rear[1] or ochka[selfwagClass].front[1],
			IsSameDir and (IsEntRear and ochka[entwagClass].rear[2] or ochka[entwagClass].front[2]) or IsEntRear and ochka[entwagClass].rear[2] or ochka[entwagClass].front[2],
			160,
			0, 
			0, 
			2, 
			"cable/cable2"
		)
		
		local CameraCable2 =  constraint.Rope(
			selfwag,entwag,
			0,0,
			IsSameDir and (IsSelfRear and ochka[selfwagClass].rear[2] or ochka[selfwagClass].front[2]) or IsSelfRear and ochka[selfwagClass].rear[2] or ochka[selfwagClass].front[2],
			IsSameDir and (IsEntRear and ochka[entwagClass].rear[1] or ochka[entwagClass].front[1]) or IsEntRear and ochka[entwagClass].rear[1] or ochka[entwagClass].front[1],
			160,
			0, 
			0, 
			2, 
			"cable/cable2"
		)
		
		self.CameraCable1 = CameraCable1
		ent.CameraCable1 = CameraCable1
		
		self.CameraCable2 = CameraCable2
		ent.CameraCable2 = CameraCable2
	end
	
	local olddecouple = ENT.Decouple
	ENT.Decouple = function(self,...)
		olddecouple(self,...)
		if IsValid(self.CameraCable1) then self.CameraCable1:Remove() end
		if IsValid(self.CameraCable2) then self.CameraCable2:Remove() end
	end
end)