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
          local c = ent:GetClass()
          for _,class in pairs(classes) do
            if c:find(class,1,true) then
              ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
              return
            end
          end
		  if c == classes[4] then
			timer.Create("ChangeCouplesCollisionOnSpawn",0.001,1,TimerFunc)--чтобы при спавне целого состава вызвалась только одна функция, а не для каждой новой сцепки
		  end
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
end)
