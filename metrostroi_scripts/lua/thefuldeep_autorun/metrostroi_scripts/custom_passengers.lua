if SERVER then return end
local tableRandom = table.Random

local humansmodels = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl",
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl",
}

local female_sequences = {2,5,6,7,11,17}
local male_sequences = {2,3,4,6,10}

timer.Simple(1,function()
	local metrostroi_custom_passengers = GetConVar("metrostroi_custom_passengers")
	if not metrostroi_custom_passengers then return end

	local function SetNewModel(v)
		if IsValid(v) and not v.ChangedModel then
			v.ChangedModel = true
			local model = tableRandom(humansmodels)
			v:SetAngles(v:GetAngles()+Angle(0,180,0))
			v:SetModel(model)
			v:ResetSequence(tableRandom(model:find("female",1,true) and female_sequences or male_sequences))
		end
	end

	local PLATFORM = scripted_ents.GetStored("gmod_track_platform")
	if PLATFORM then
		PLATFORM = PLATFORM.t
		local oldthink = PLATFORM.Think
		PLATFORM.Think = function(self,...)
			local res = oldthink(self,...)
			if metrostroi_custom_passengers:GetBool() then
				for _,v in pairs(self.ClientModels)do SetNewModel(v)end
				for _,v in pairs(self.CleanupModels) do
					local ent = v.ent
					SetNewModel(ent)
					if IsValid(ent) then ent:SetAngles(ent:GetAngles() + Angle(0,180,0))end
				end
			end
			return res
		end
	end
	
	local BASE = scripted_ents.GetStored("gmod_subway_base")
	if BASE then
		BASE = BASE.t
		local oldthink = BASE.Think
		BASE.Think = function(self,...)
			local res = oldthink(self,...)
			if metrostroi_custom_passengers:GetBool() then
			--if self.PassengerEnts then
				for _,v in pairs(self.PassengerEnts)do SetNewModel(v)end
			--end
			end
			
			return res
		end
	end
end)