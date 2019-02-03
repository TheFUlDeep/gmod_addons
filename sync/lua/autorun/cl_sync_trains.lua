if SERVER then return end

local TrainsTBL = {}

local NewTrainsTBL = {}
local function GetNewTrains()
	NewTrainsTBL = {}
	for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
		local model = v:GetModel()
		if model == "стандартная модель" then continue end
		table.insert(NewTrainsTBL,1,{model = model, pos = v:GetPos(), ang = v:GetAngles(),ent = v})			-- в будущем еще v:GetNW2Bool("headlights") и т.п.
	end
end

local function AddClientProp(model,name,k)
	if not model or not name then return end
	local ClientEntity = ents.CreateClientProp()
	ClientEntity.name = name					--будет ли ругаться, что нет поля name?
	ClientEntity:SetModel(model)
	ClientEntity:SetPos(Vector(0,0,0))
	ClientEntity:SetPersistent(true)
	ClientEntity:SetMoveType(MOVETYPE_FLY)
	ClientEntity:SetParent(TrainsTBL[k].ent)	-- оно надо вообще?
	ClientEntity:Spawn()
	return ClientEntity
end

local function AddNewTrain(k)
	--util.PrecacheModel на сервере
	--спавн нужных пропов
	if not TrainsTBL[k].model then return end
	TrainsTBL[k].ents = {}
	if TrainsTBL[k].model == "модель паравоза" then
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","имя1",k))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","имя2",k))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель1","имя3",k))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель1","имя4",k))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель2","имя5",k))
	end
end

local function RemoveTrain(k)
	--удаление ненужных пропов
	if not TrainsTBL[k] then return end
	if not TrainsTBL[k].ents then TrainsTBL[k] = nil return end
	for k,v in pairs(TrainsTBL) do
		if not v.ents then continue end
		for k1,v1 in pairs(v.ents) do
			v1:Remove()
		end
	end
	 TrainsTBL[k] = nil
end

local function Sdvig()
	for k,v in pairs(TrainsTBL) do
		if not v.ents then continue end
		for k1,v1 in pairs(v.ents) do
			if not v1.name then continue end
			if v1.name == "asdadsa1" then v1:SetPos(v1:GetPos() + Vector(1,0,0))
			elseif v1.name == "asdadsa2" then v1:SetPos(v1:GetPos() + Vector(2,0,0))
			elseif v1.name == "asdadsa3" then v1:SetPos(v1:GetPos() + Vector(3,0,0))
			elseif v1.name == "asdadsa4" then v1:SetPos(v1:GetPos() + Vector(4,0,0))
			elseif v1.name == "asdadsa5" then v1:SetPos(v1:GetPos() + Vector(5,0,0))
			end
		end
	end
end

local function UpdatePositions()
	for k,v in pairs(TrainsTBL) do
		if not v.ents then continue end
		for k1,v1 in pairs(v.ents) do
			v1:SetPos(v.pos)
			v1:SetAngles(v.ang)
			--v1:SetModel()						--??????????????????
		end
	end
	Sdvig()
end

local function UpdateTrains()
	
	if util.TableToJSON(NewTrainsTBL) == util.TableToJSON(TrainsTBL) then return end
	
	for k,v in pairs(NewTrainsTBL) do
		if not TrainsTBL[k] then
			AddNewTrain(k)
		end
	end
	
	for k,v in pairs(TrainsTBL) do
		if not NewTrainsTBL[k] then
			RemoveTrain(k)
		end
	end
	
	UpdatePositions()
end

hook.Add("Think","DrawSyncedTrains",function()
	GetNewTrains()
	UpdateTrains()
end)