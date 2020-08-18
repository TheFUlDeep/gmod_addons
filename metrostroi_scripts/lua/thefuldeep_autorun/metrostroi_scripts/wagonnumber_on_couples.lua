if SERVER then return end

timer.Simple(0,function()
	local ENT = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not ENT then return else ENT = ENT.t end
	
	for i = 0,4 do
		ENT.ClientProps["WagNumFrontCouple"..i] = {
			model = "models/metrostroi_train/common/bort_numbers.mdl",
			pos = Vector(0),
			ang = Angle(0),
			skin=i,
			hide = 1.5,
			scale = 0.5,
			callback = function(ent)
				ent.WagonNumber = false
			end,
		}
		
		ENT.ClientProps["WagNumRearCouple"..i] = {
			model = "models/metrostroi_train/common/bort_numbers.mdl",
			pos = Vector(0),
			ang = Angle(0),
			skin=i,
			hide = 1.5,
			scale = 0.5,
			callback = function(ent)
				ent.WagonNumber = false
			end,
		}
	end
	
	local entsFindByClass = ents.FindByClass
	
	local function FindCouplesForWagon(wag)
		local first
		for _,b in pairs(entsFindByClass("gmod_train_couple")) do
			if not IsValid(b) or b:GetNW2Entity("TrainEntity") ~= wag then continue end
			if not first then 
				first = b
			else
				return first,b
			end
		end
	end
	
	local mathmax = math.max
	local mathfloor = math.floor
	local mathceil = math.ceil
	local mathlog10 = math.log10
	
	local oldUpdateWagonNumber = ENT.UpdateWagonNumber
	ENT.UpdateWagonNumber = function(self,...)
		oldUpdateWagonNumber(self,...)
		if not self.WagonNumber then return end
		local ClientEnts = self.ClientEnts
		if not ClientEnts then return end
		local count = mathmax(4,mathceil(mathlog10(self.WagonNumber+1)))
		if count == 5 then startpos = 6 else startpos = 4.6 end
		
		local firstcouple,secondcouple = FindCouplesForWagon(self)
		if not firstcouple then return end
		
		for i = 0,4 do
			local front = "WagNumFrontCouple"..i
			local rear = "WagNumRearCouple"..i
			
			self:ShowHide(front,i<count and IsValid(firstcouple))
			self:ShowHide(rear,i<count and IsValid(secondcouple))
			
			if i< count and self.WagonNumber then
				local num = mathfloor(self.WagonNumber%(10^(i+1))/10^i)
			
				local frontnument = ClientEnts[front]
				if IsValid(frontnument) and IsValid(firstcouple) then
					frontnument:SetPos(firstcouple:LocalToWorld(Vector(65,startpos+i*-3,-16)))
					frontnument:SetAngles(firstcouple:LocalToWorldAngles(Angle(0,90,0)))
					frontnument:SetParent(firstcouple)
					frontnument:SetSkin(num)
				end
				
				local rearnument = ClientEnts[rear]
				if IsValid(rearnument) and IsValid(secondcouple) then
					rearnument:SetPos(secondcouple:LocalToWorld(Vector(65,startpos+i*-3,-16)))
					rearnument:SetAngles(secondcouple:LocalToWorldAngles(Angle(0,90,0)))
					rearnument:SetParent(secondcouple)
					rearnument:SetSkin(num)
				end
			end
		end
	end
end)