if SERVER then return end

for k,v in pairs(ents.GetAll()) do
	if v.class and v.class == "SyncedTrain" then v:Remove() end
end

local TrainsTBL = {}

local NewTrainsTBL = {}
local function GetNewTrains()
	NewTrainsTBL = {}
	for k,v in pairs(ents.FindByClass("gmod_subway_base")) do
		--print(v:GetNW2Bool("IsSyncedTrain",false))
		--if not v:GetNW2Bool("IsSyncedTrain",false) then continue end
		local model = v:GetModel()
		if model == "models/props_lab/reciever01a.mdl" then continue end
		table.insert(NewTrainsTBL,1,{model = v:GetModel(), ent = v})			-- в будущем еще v:GetNW2Bool("headlights") и т.п.
	end
end

local function AddClientProp(model,name)
	if not model or not name then return end
	local ClientEntity = ents.CreateClientProp()
	ClientEntity.name = name
	ClientEntity.class = "SyncedTrain"
	ClientEntity:SetModel(model)
	ClientEntity:SetPos(Vector(0,0,0))
	ClientEntity:SetPersistent(true)
	ClientEntity:SetMoveType(MOVETYPE_FLY)
	ClientEntity:Spawn()
	print("Added ClientEntity "..name.." witch model "..model)
	return ClientEntity
end

local function AddNewTrain(k)
	--util.PrecacheModel на сервере
	--спавн нужных пропов
	TrainsTBL[k] = NewTrainsTBL[k]
	if not TrainsTBL[k].model then return end
	--print(TrainsTBL[k].model)
	TrainsTBL[k].ents = {}
		--table.insert(TrainsTBL[k].ents,1,AddClientProp("models/metrostroi_train/bogey/metro_couple_ezh.mdl","сцепка2"))
		--table.insert(TrainsTBL[k].ents,1,AddClientProp("models/metrostroi_train/bogey/metro_couple_noekk.mdl","сцепка2"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","тележка1"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","тележка2"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","колесная пара 1:1"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","колесная пара 1:2"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","колесная пара 2:1"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","колесная пара 2:2"))
	if TrainsTBL[k].model == "models/metrostroi_train/81-717/81-717_mvm.mdl" then
		table.insert(TrainsTBL[k].ents,1,AddClientProp("models/metrostroi_train/bogey/metro_couple_717.mdl","сцепка1 717мсск"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("models/metrostroi_train/81-717/interior_mvm.mdl","салон"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("models/metrostroi_train/bogey/metro_couple_717.mdl","сцепка2 717мск"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель","имя2"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель1","имя3"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель1","имя4"))
		table.insert(TrainsTBL[k].ents,1,AddClientProp("модель2","имя5"))
	end
	print("Done adding ClientEnts for "..(TrainsTBL[k].model))
end

local function RemoveTrain(k)
	--удаление ненужных пропов
	if not TrainsTBL[k] or not TrainsTBL[k].ents then return end
	for k1,v1 in pairs(TrainsTBL[k].ents) do
		--if not IsValid(v) then continue end
		v1:Remove()
		print("Removed ClientEntity "..(v1.name))
	end
	TrainsTBL[k] = nil
end

local function GetTrainAngle(ent)				-- поиск вагона на определенном расстоянии и нахождение угла между ними
	--Vector:AngleEx( Vector up )
	-- или вместо AngleEx просто вычитать углы
	--Vector:DistToSqr( Vector otherVec )
	return false
end

local function SetCLientPropPos(ClientEntity,TrainEntity,vec,ang)
	if not ClientEntity or not TrainEntity then return end
	if not ang then 
		ang = TrainEntity:GetAngles()
	else
		ang = ang + TrainEntity:GetAngles()
	end
	local ang2 = GetTrainAngle(ClientEntity) or ang
	if not vec then vec = Vector(0,0,0) end
	if not isvector(vec) then return end
	ClientEntity:SetPos(TrainEntity:LocalToWorld(vec))
	ClientEntity:SetAngles(ang2)
end

local function Sdvig()
	for k,v in pairs(TrainsTBL) do
		if not v.ents then continue end
		for k1,v1 in pairs(v.ents) do
			if not v1.name then continue end
			if v1.name == "сцепка1 717мсск" then SetCLientPropPos(v1,v.ent,Vector(410,0,-68))
			elseif v1.name == "сцепка2 717мск" then SetCLientPropPos(v1,v.ent,Vector(-420.9,0,-68),Angle(0,180,0))
			end
		end
	end
end

local function UpdatePositions()
	for k,v in pairs(TrainsTBL) do
		if not v.ents then continue end
		for k1,v1 in pairs(v.ents) do
			v1:SetPos(v.ent:GetPos())
			v1:SetAngles(v.ent:GetAngles())
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

--[[hook.Add("Think","DrawSyncedTrains",function()
	GetNewTrains()
	UpdateTrains()
end)]]

hook.Add("HUDPaint","Draw SyncedTrain's owner",function() 
	if not IsValid(LocalPlayer()) then return end
	local ent = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(ent) then return end
	if ent:GetClass() ~= "gmod_subway_base" then return end
	local Owner = ent:GetNWString("Owner","N/A Owner")
	local w1,h1 = surface.GetTextSize(Owner)
	draw.RoundedBox(6, 5, ScrH()/2 - 250 - 3, w1*1.8, h1 + 10, Color(0, 0, 0, 150))
	draw.SimpleText(Owner, "ChatFont",10, ScrH()/2 - 250, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
end)