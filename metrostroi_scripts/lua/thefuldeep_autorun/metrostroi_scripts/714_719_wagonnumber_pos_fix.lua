if SERVER then return end

local offset = 120

local classes = {"gmod_subway_81-714_mvm","gmod_subway_81-719","gmod_subway_81-714_lvz"}

hook.Add("InitPostEntity","Metrostroi 714, 719 wagnum pos fix",function()
-- timer.Simple(0,function()
	for _,class in pairs(classes)do
		local NOMER = scripted_ents.GetStored(class)
		if not NOMER then continue else NOMER = NOMER.t end

		for i = 0,4 do
			if not NOMER.ClientProps["TrainNumberL"..i] then continue end
			NOMER.ClientProps["TrainNumberL"..i].pos[1] = NOMER.ClientProps["TrainNumberL"..i].pos[1] + offset
			NOMER.ClientProps["TrainNumberR"..i].pos[1] = NOMER.ClientProps["TrainNumberR"..i].pos[1] - offset
		end
		
		local oldupdate = NOMER.UpdateWagonNumber
		NOMER.UpdateWagonNumber = function(self,...)
			oldupdate(self,...)

			if not self.ClientEnts then return end
			for i = 0,4 do
				if not self.ClientEnts["TrainNumberL"..i] then continue end
				local ent = self.ClientEnts["TrainNumberL"..i]
				if IsValid(ent) then ent:SetPos(ent:LocalToWorld(Vector(offset,0,0)))end
				ent = self.ClientEnts["TrainNumberR"..i]
				if IsValid(ent) then ent:SetPos(ent:LocalToWorld(Vector(-offset,0,0)))end
			end
		end
	end
end)