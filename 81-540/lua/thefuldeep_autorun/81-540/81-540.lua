--[[if SERVER then		--пока что не стоит
	resource.AddWorkshop("1768332944")
end]]


--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	--for k,v in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored("gmod_subway_81-717_lvz_custom")
		if ENT and ENT.t and ENT.t.Spawner then
			local cont = false
			for k,v in pairs(ENT.t.Spawner) do
				if istable(v) and v[1]=="81-540model" then cont = true break end
			end
			if cont then continue end
		
			table.insert(ENT.t.Spawner,{"81-540model","Кузов 81-540","Boolean"})
		end
	--end
end)

if SERVER then return end

local function ChangeModel(ent)
	local Class = ent:GetClass()
	if Class ~= "gmod_subway_81-717_lvz_custom" then return end
	if not ent:GetNW2Bool("81-540model") then return end
	ent:SetModel("models/metrostroi_train/81-5402/81-5402_body.mdl")
	--TODO клиентпропы (+ их сдвиг, если понадобится)
	
	
	--обновление модели при нажатии спавнером на вагон
	if ent.TrainSpawnerUpdate and not ent.TrainSpawnerUpdate540modelchanched then
		ent.TrainSpawnerUpdate540modelchanched = true
		local OldTrainSpawnerUpdate = ent.TrainSpawnerUpdate
		ent.TrainSpawnerUpdate = function(ent)
			OldTrainSpawnerUpdate(ent)
			ChangeModel(ent)
		end
	end
end

hook.Add( "OnEntityCreated", "81-540model", ChangeModel)--TODO не уверен, что триггернетися на все ентити в клиентской части, и будет ли это триггериться, если ентити уже есть, а игрок только заходит на сервер