if CLIENT then return end

local seatstbl = {"DriverSeat","InstructorsSeat","ExtraSeat"}
for i = 1,4 do
	table.insert(seatstbl,"InstructorsSeat"..i)
	table.insert(seatstbl,"ExtraSeat"..i)
end

timer.Simple(0,function()
	for _,class in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(class)
		if not ENT or not ENT.t or not ENT.t.Initialize then continue else ENT = ENT.t end
		local OldInit = ENT.Initialize
		ENT.Initialize = function(self,...)
			OldInit(self,...)
			for _,seat in pairs(seatstbl) do
				if IsValid(self[seat]) then 
					self[seat]:SetRenderMode(RENDERMODE_NONE) 
					self[seat]:DrawShadow(false)
				end
			end
		end
	end
end)
