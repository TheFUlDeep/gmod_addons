local Class = "gmod_subway_81-717_lvz"

if SERVER then
	resource.AddWorkshop("1768332944")
	timer.Create("UpdateNWFor 540model",1,0,function()
		for _,ent in pairs(ents.FindByClass(Class)) do
			if ent:GetNW2Bool("81-540model") then
				ent:SetNW2Bool("KVR",true)
				--ent:SetNW2Int("AVType",1)
			end
		end
	end)
end

--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	--for k,v in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(Class)
		if ENT and ENT.t and ENT.t.Spawner then
			local cont = false
			for k,v in pairs(ENT.t.Spawner) do
				if istable(v) and v[1]=="81-540model" then return end
			end
			table.insert(ENT.t.Spawner,{"81-540model","Кузов 81-540","Boolean"})
		end
	--end
end)

if SERVER then return end

local function SetPrevModel(ent)
	ent.model540.Preved = true
	
	local TrainModel = ent:GetModel()
	if ent.model540.PrevModel and TrainModel ~= ent.model540.PrevModel then ent:SetModel(ent.model540.PrevModel) end
	for k,v in pairs(ent.ClientEnts) do
		if not IsValid(v) then continue end
		if k == "mask22_1" or k == "mask222_lvz" or k == "mask22_2" and v:GetModelScale() ~= 1 then
			v:SetModelScale(1)
		end
		if k == "cabine_old" or k == "cabine_new" or k == "RedLights" or k == "Headlights222_1" or k == "Headlights22_1" or k == "Headlights222_2" or k == "Headlights22_2" or k == "Lamps_cab2" or k == "Lamps_cab1" or k == "Lamps2_cab1" or k == "Lamps2_cab2" then --внутренняя кабина
			local EntModel = v:GetModel()
			if ent.model540[k] and EntModel ~= ent.model540[k] then v:SetModel(ent.model540[k]) end
		end
	end
end

timer.Create("UpdateClientEnts on 540",1,0,function()
	for _,ent in pairs(ents.FindByClass(Class)) do
		if not IsValid(ent) then continue end
		if not ent.model540 then ent.model540 = {} end
		if not ent:GetNW2Bool("81-540model") then 
			if not ent.model540.Preved then SetPrevModel(ent) end
			return 
		end
		
		ent.model540.Preved = false
		
		local TrainModel = ent:GetModel()
		if TrainModel ~= "models/metrostroi_train/81-5402/81-5402_body.mdl" then 
			ent.model540.PrevModel = TrainModel 
			ent:SetModel("models/metrostroi_train/81-5402/81-5402_body.mdl")
		end
		
		if not ent.ClientEnts then return end
		for k,v in pairs(ent.ClientEnts) do
			if not IsValid(v) then continue end
			local EntModel = v:GetModel()
			if (k == "cabine_old" or k == "cabine_new") and EntModel ~= "models/metrostroi_train/81-5402/81-5402_cab.mdl" then --внутренняя кабина
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/81-5402_cab.mdl")
			end
			if k == "mask22_1" or k == "mask222_lvz" or k == "mask22_2" then
				v:SetModelScale(0)
			end
			if k == "RedLights" and EntModel ~= "models/metrostroi_train/81-5402/redlights.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/redlights.mdl")
			end
			if (k == "Headlights222_1" or k == "Headlights22_1") and EntModel ~= "models/metrostroi_train/81-5402/group1.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/group1.mdl")
			end
			if (k == "Headlights222_2" or k == "Headlights22_2") and EntModel ~= "models/metrostroi_train/81-5402/group2.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/group2.mdl")
			end
			if (k == "Headlights222_2" or k == "Headlights22_2") and EntModel ~= "models/metrostroi_train/81-5402/group2.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/group2.mdl")
			end
			if (k == "Lamps_cab1" or k == "Lamps2_cab1") and EntModel ~= "models/metrostroi_train/81-5402/lamp_cab1.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/lamp_cab1.mdl")
			end
			if (k == "Lamps_cab2" or k == "Lamps2_cab2") and EntModel ~= "models/metrostroi_train/81-5402/lamp_cab2.mdl" then
				ent.model540[k] = EntModel
				v:SetModel("models/metrostroi_train/81-5402/lamp_cab2.mdl")
			end
		end
	end
end)

