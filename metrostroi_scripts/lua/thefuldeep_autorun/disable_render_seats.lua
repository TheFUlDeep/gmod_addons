if CLIENT then return end

local seats = {"DriverSeat","InstructorsSeat","ExtraSeat1","ExtraSeat2","ExtraSeat3"}

timer.Simple(0,function()
	for _,class in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(class)
		if not ENT or not ENT.t or not ENT.t.Initialize then continue else ENT = ENT.t end
		local OldInit = ENT.Initialize
		ENT.Initialize = function(self,...)
			OldInit(self,...)
			for _,seat in pairs(seats) do
				if IsValid(self[seat]) then self[seat]:SetRenderMode(RENDERMODE_NONE) end
			end
		end
	end
end)
