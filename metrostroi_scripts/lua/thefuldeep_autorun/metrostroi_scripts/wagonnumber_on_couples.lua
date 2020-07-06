if SERVER then return end

local wagons = {}
local tableinsert = table.insert
hook.Add("OnEntityCreated","SaveWagonByCouple for wagonnumber",function(ent)
	timer.Simple(0,function()
		if not IsValid(ent)or ent:GetClass() ~= "gmod_train_couple" then return end
		local wag = ent:GetNW2Entity("TrainEntity")
		if not IsValid(wag) then return end
		wagons[wag] = wagons[wag] or {}
		if #wagons[wag] > 1 then wagons[wag] = {} end
		wagons[wag][#wagons[wag]+1] = ent
	end)
end)

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
	
	local oldUpdateWagonNumber = ENT.UpdateWagonNumber
	ENT.UpdateWagonNumber = function(self,...)
		oldUpdateWagonNumber(self,...)
		local ClientEnts = self.ClientEnts
		if not ClientEnts then return end
		local count = math.max(4,math.ceil(math.log10(self.WagonNumber+1)))
		if count == 5 then startpos = 6 else startpos = 4.6 end
		
		for i = 0,4 do
			local front = "WagNumFrontCouple"..i
			local rear = "WagNumRearCouple"..i
			
			if not wagons[self] then return end
			local firstcouple = wagons[self][1]
			local seconcouple = wagons[self][2]
			self:ShowHide(front,i<count and IsValid(firstcouple))
			self:ShowHide(rear,i<count and IsValid(seconcouple))
			
			if i< count and self.WagonNumber then
				local num = math.floor(self.WagonNumber%(10^(i+1))/10^i)
			
				local frontnument = ClientEnts[front]
				if IsValid(frontnument) and IsValid(firstcouple) then
					frontnument:SetPos(firstcouple:LocalToWorld(Vector(65,startpos+i*-3,-16)))
					frontnument:SetAngles(firstcouple:LocalToWorldAngles(Angle(0,90,0)))
					frontnument:SetParent(firstcouple)
					frontnument:SetSkin(num)
				end
				
				local rearnument = ClientEnts[rear]
				if IsValid(rearnument) and IsValid(seconcouple) then
					rearnument:SetPos(seconcouple:LocalToWorld(Vector(65,startpos+i*-3,-16)))
					rearnument:SetAngles(seconcouple:LocalToWorldAngles(Angle(0,90,0)))
					rearnument:SetParent(seconcouple)
					rearnument:SetSkin(num)
				end
			end
		end
	end
end)