if CLIENT then return end

local DIST_TO_ENABLE_COLLISION = 200^2


--проверка, есть ли Use доступ у игроков друг к другу
local function IsHasAccess(ent1,ent2)
	if not CPPI then return true end
	local Owner1 = ent1:CPPIGetOwner()
	local Owner2 = ent2:CPPIGetOwner()
	if not IsValid(Owner1) or not IsValid(Owner2) then return end
	if Owner1 == Owner2 then return true end
	
	if ent1:CPPICanUse(Owner2) and ent2:CPPICanUse(Owner1) then return true end
end

local function ChangeCollision(ent,type)--на всякий случай делаю проверку на коллизию при смене, а то вдруг установка коллизии на ту же нагружает сервер
	if ent:GetCollisionGroup() ~= type then ent:SetCollisionGroup(type)end
end

local entsFindByClass = ents.FindByClass

--проверка, есть ли поблизости еще сцепки
local function IsCoupleHasNearCouple1(couple,couples)
	local pos = couple:GetPos()
	local nearcouple
	for _,ent in pairs(couples)do
		if not IsValid(ent) or ent == couple then continue end
		if ent:GetPos():DistToSqr(pos) < DIST_TO_ENABLE_COLLISION then 
			--если найдена чужая сцепка, то вернуть nil
			if not IsHasAccess(couple,ent) then
				return
			else
				nearcouple = ent
			end
		end
	end
	if nearcouple then return true end
end

local function TimerFunc()
	local couples = entsFindByClass("gmod_train_couple")

	
	for _,ent1 in pairs(couples)do
		if not IsValid(ent1) then continue end
		
		if IsValid(ent1.CoupledEnt) then ChangeCollision(ent1,COLLISION_GROUP_INTERACTIVE_DEBRIS) continue end
		
		if IsCoupleHasNearCouple1(ent1,couples) then
		
			--сохраняю вагон сцепки, чтобы в дальнейшем пропустить его
			local wag = ent1:GetNW2Entity("TrainEntity")
			if not IsValid(wag) then continue end
			
			--если сцепка рядом с сотавом (или внутри состава), к которому нет доступа, то коллизию не включать
			local entsinsphere = ents.FindInSphere(ent1:GetPos(),100)
			local anotherwag
			for _,v in pairs(entsinsphere) do
				if IsValid(v) and v ~= wag and v:GetClass():find("gmod_subway_",1,true) and not IsHasAccess(wag,v) then anotherwag = v break end
			end
			if anotherwag then continue end
			ChangeCollision(ent1,COLLISION_GROUP_NONE)
		else
			ChangeCollision(ent1,COLLISION_GROUP_INTERACTIVE_DEBRIS)
		end
	end
end
timer.Create("Change couples collision for security",3,0,TimerFunc)

local classes = {"gmod_subway_","gmod_train_bogey","gmod_train_wheels","gmod_train_couple"}

hook.Add("OnEntityCreated","ChangeTrainsCollisionForSecurity",function(ent)
    --timer.Simple(0,function()
        if IsValid(ent) then 
		  --ent.SpawnTime = os.clock()
          local c = ent:GetClass()
          for _,class in pairs(classes) do
            if c:find(class,1,true) then
              ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
            end
          end
		  if c == classes[4] then
			timer.Create("ChangeCouplesCollisionOnSpawn",0.001,1,TimerFunc)--чтобы при спавне целого состава вызвалась только одна функция, а не для каждой новой сцепки
		  end
		  
		  --TODO если могу определить трек, на котором находится ентити, то найти другие ентити на этом же треке
		  --и если на этом же треке есть другое ентити со скоростью больше 5, то не спавнить
		  --(возможно это можно сделать чеез метростроевский хук спавнера)
		  
        end
    --end)
end)

timer.Simple(0,function()


	local ENT = scripted_ents.GetStored("gmod_train_couple")
	local ENT = ENT and ENT.t
	if not ENT then return end
	local olddecouple = ENT.Decouple
	ENT.Decouple = function(self,...)
		olddecouple(self,...)
		self.DeCoupleTime = self.DeCoupleTime + 2--добавляю небольшой таймаут, чтобы сцепки не сцепились обратно при возвращении коллизии
	end
	
	local oldcouple = ENT.Couple
	ENT.Couple = function(self,ent,...)
		--эта проверка на доступ просто на всякий случай
		if not IsHasAccess(self,ent) then
			ChangeCollision(self,COLLISION_GROUP_INTERACTIVE_DEBRIS)		
			ChangeCollision(ent,COLLISION_GROUP_INTERACTIVE_DEBRIS)	
			return
		end
		oldcouple(self,ent,...)
		
		--при сцепе тут же отключаю коллизию
		ChangeCollision(self,COLLISION_GROUP_INTERACTIVE_DEBRIS)		
		ChangeCollision(ent,COLLISION_GROUP_INTERACTIVE_DEBRIS)	
	end
	
	
	
	local EventName = "PhysgunPickup"
	local hookstbl = hook.GetTable()[EventName] or {}
	
	local funcs = {}
	for name,func in pairs(hookstbl or {})do
		funcs[name] = func
		--hook.Add(EventName,name,function()end)
		hook.Remove(EventName,name)
	end
	
	local tableHasValue = table.HasValue
	local mclasses = Metrostroi.TrainClasses
	
	--задержка в 5 секунд, чтобы сразу же после спавна нельзя было таскать паравоз (так как у сцепок может включитсья коллизия)
	--[[local delay = 5
	hook.Add(EventName,"Delay for trains for security",function(ply,ent)
		if IsValid(ent) and (tableHasValue(classes,ent:GetClass()) or tableHasValue(mclasses,ent:GetClass())) and os.clock() - (ent.SpawnTime or 0) < delay then return false end
	end)]]
	
	hook.Add(EventName,"Block physgun on trains with normal collision",function(ply,ent)
		if not IsValid(ent) then return end
		local class = ent:GetClass()
		
		local couple1,couple2
		if class == "gmod_train_couple" or class == "gmod_train_bogey" then
			local wag = ent:GetNW2Entity("TrainEntity")
			if not IsValid(wag) then return end
			couple1 = wag.FronCouple
			couple2 = wag.RearCouple
		elseif class == "gmod_train_wheels" then
			local bogey = ent:GetNW2Entity("TrainBogey")
			if not IsValid(bogey)then return end
			local wag = ent:GetNW2Entity("TrainEntity")
			if not IsValid(wag) then return end
			couple1 = wag.FronCouple
			couple2 = wag.RearCouple
		elseif tableHasValue(mclasses,class)then
			couple1 = ent.FronCouple
			couple2 = ent.RearCouple
		end
		
		if IsValid(couple1) and couple1:GetCollisionGroup() == COLLISION_GROUP_NONE 
			or IsValid(couple2) and couple2:GetCollisionGroup() == COLLISION_GROUP_NONE then 
				return false 
		end
		
	end)
end)
