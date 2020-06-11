if CLIENT then return end

local seats = {"DriverSeat","InstructorsSeat","ExtraSeat"}

timer.Simple(0,function()
	for _,class in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(class)
		if not ENT or not ENT.t or not ENT.t.Initialize then continue else ENT = ENT.t end
		local OldInit = ENT.Initialize
		ENT.Initialize = function(self,...)
			OldInit(self,...)
			for i = 0,4 do
				local str = i > 0 and tostring(i) or ""
				for _,seat1 in pairs(seats) do
					local seat = seat1..str
					if IsValid(self[seat]) then 
						self[seat]:SetRenderMode(RENDERMODE_NONE) 
						self[seat]:DrawShadow(false)
					end
				end
			end
		end
	end
end)
