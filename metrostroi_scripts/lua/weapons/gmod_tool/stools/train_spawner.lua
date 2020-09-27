--local TOOL = player.GetBySteamID("STEAM_0:1:31566374"):GetTool("train_spawner")
TOOL.AddToMenu = false

local function SpawnNotif(ply, self, vector, WagNum)	-- SpawnNotif(ply, self.Train.ClassName, trace.HitPos, self.Settings.WagNum) в функции TOOL:SpawnWagon
	if not THEFULDEEP or not THEFULDEEP.DETECTSTATION then return end
	local TrainName = self.Train.SubwayTrain.Name
	ulx.fancyLogAdmin(ply, true, "#A заспавнил #s", TrainName--[[, self.Train.ClassName, self.Train.Spawner.interim]])
	
	local ourstation = THEFULDEEP.DETECTSTATION(vector)
	if ourstation == "" or ourstation == nil 
		then ulx.fancyLog(true, "Вагонов: #i", WagNum)
	else ulx.fancyLog(true, "Станция: #s. Вагонов: #i", ourstation, WagNum)
	end
end

local function MaximumWagons(ply,self)
	local Map = game.GetMap()
	if not ply.GetUserGroup then return 0 end
	local Rank = ply:GetUserGroup()
	local maximum = 6
	local MetrostroiTrainCount = GetGlobalInt("metrostroi_train_count")
	local MetrostroiMaxWagons = GetGlobalInt("metrostroi_maxwagons")
	if MetrostroiTrainCount <= 0 then MetrostroiTrainCount = 1 end
	if MetrostroiMaxWagons <= 0 then MetrostroiMaxWagons = 1 end
	if MetrostroiMaxWagons <= MetrostroiTrainCount then return 0 end
	local percent = MetrostroiTrainCount / MetrostroiMaxWagons 
	if percent < 0.25 then maximum = 6
	elseif percent < 0.5 then maximum = 4
	elseif percent < 0.75 then maximum = 3
	else maximum = 2
	end
	if Rank == "superadmin" then maximum = 6 end
	if maximum < 4 and (Rank == "operator" or Rank == "admin" or Rank == "SuperVIP") then maximum = 4 end
	maximum = not ply:GetNW2Bool("ignoremapwaglimit") and maximum > GetGlobalInt("MaxWagonsByPlatformLen",0) and GetGlobalInt("MaxWagonsByPlatformLen",0) or maximum
	if SERVER and self then
		if maximum < 6 and self.Train.ClassName == "gmod_subway_81-722" then self.Settings.WagNum = 3 end
	end
	return maximum
end


if CLIENT then
    language.Add("Tool.train_spawner.name", "Train Spawner")
    language.Add("Tool.train_spawner.desc", "Spawn a train")
    language.Add("Tool.train_spawner.0", "Primary: Spawns a full train. Secondary: self.Reverse facing (yellow ed when facing the opposite side).")
    language.Add("Undone_81-7036", "Undone 81-7036 (does not work)")
    language.Add("Undone_81-7037", "Undone 81-7037 (does not work)")
    language.Add("Undone_81-717", "Undone 81-717")
    language.Add("Undone_81-714", "Undone 81-714")
    language.Add("Undone_Ezh3", "Undone Ezh3")
    language.Add("Undone_Ema508T", "Undone Em508T")
    language.Add("SBoxLimit_spawner_wrong_pos","Wrong train position! Can't spawn")
    language.Add("SBoxLimit_spawner_restrict","This train is restricted for you")
end

local function CustomSkin(self,OnSpawn)
	if 1 then return end
	if not IGS or not IGS.ITEMS or not IGS.PlayerPurchases or CLIENT or not self.Train or not self.Train.ClassName 
		or self.Train.ClassName == "gmod_subway_81-540_2" 
		or self.Train.ClassName == "gmod_subway_81-760" 
		or self.Train.ClassName == "gmod_subway_81-760a" 
		or self.Train.ClassName == "gmod_subway_81-761" 
		or self.Train.ClassName == "gmod_subway_81-761a" 
		or self.Train.ClassName == "gmod_subway_81-763a" 
		or self.Train.ClassName == "gmod_subway_em508" 
	then return end
	local ply = self:GetOwner()
	
	if ply:GetUserGroup() == "SuperVIP" or ply:IsSuperAdmin() then return end
	
	for k,v in pairs(IGS.PlayerPurchases(ply) or {}) do
		if tostring(k) == "9999" then return end
	end
	
	local TexturesTbl = {}

	if self.Train.Spawner then 
		for k,v in pairs(self.Train.Spawner) do
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					if type(v1) == "string" then
						if v1:lower():find("texture") then table.insert(TexturesTbl,1,v) break end
					end
				end
			end
		end
	end
	
	for k,v in pairs(TexturesTbl) do
		if v[1] and v[4] and type(v[4]) == "function" then
			TexturesTbl[v[1]] = v[4]()
		end
	end
	
	local function GetNameAndDescriptionByUID(IdOfItem)
		for k,v in pairs(IGS.ITEMS) do
			if type(v) ~= "table" then continue end
			for k1,v1 in pairs(v) do
				if type(v1) ~= "table" then continue end
				for k2,v2 in pairs(v1) do
					local type1 = type(v2)
					if type1 ~= "string" and type1 ~= "number" then continue end
					if v2 == IdOfItem then
						if IGS.ITEMS[k][k1]["name"] and IGS.ITEMS[k][k1]["description"] then
							return IGS.ITEMS[k][k1]["name"], IGS.ITEMS[k][k1]["description"]
						else
							continue
						end
					end
				end
			end
		end
	end

	local function GetAndConvertItems(ply)
		local NewInventory = {}
		local Inventory = IGS.PlayerPurchases(ply) or {}
		for k,v in pairs(Inventory) do
			local name,description = GetNameAndDescriptionByUID(k)
			if not name or not description then continue end
			NewInventory[k] = {}
			NewInventory[k]["name"] = name
			NewInventory[k]["description"] = description
		end
		return NewInventory
	end
	
	local function IsThisSkinInInventory(TrainClass,TextureClass,TextureName)
		local result = false
		local Inventory = GetAndConvertItems(ply) or {}
		for k,v in pairs(Inventory) do
			if not v["description"] or not stringfind(v["description"],"\n[[") then continue end
			v = string.sub(v["description"],stringfind(v["description"],"\n[[") + 3, - 3)
			--print(v)
			local start1 = string.find(v," ")
			if not start1 then continue end
			local TrainClass1 = string.sub(v,1,start1 - 1)
			if TrainClass ~= TrainClass1 then continue end
			local start2 = string.find(v," ",start1 + 1)
			if not start2 then continue end
			local TextureClass1 = string.sub(v,start1 + 1, start2 - 1)
			if TextureClass1 ~= TextureClass then continue end
			local TextureName1 = string.sub(v,start2 + 1)
			if TextureName1 ~= TextureName then continue else result = true end
		end
		--print(result)
		return result
	end
	
	local function NoSkinsForThisTrain(self,TextureClass)
		if TexturesTbl[TextureClass] and self.Settings[TextureClass] and TexturesTbl[TextureClass][self.Settings[TextureClass]] and IsThisSkinInInventory(self.Train.ClassName,TextureClass,TexturesTbl[TextureClass][self.Settings[TextureClass]]) then
			return false
		else 
			return true
		end
	end
	
	local NotOnlyOneSkin
	
	local function ReturnRandomKeyFromTable(tbl,TextureClass)
		local TBL = tbl
--		for k,v in pairs(TBL) do
--			if IsThisSkinInInventory(self.Train.ClassName,TextureClass,v) then TBL[k] = nil --[[print("nilled",v)]] end		-- выбираю рандомный скин, предварительно очистив купленные
--		end
		local TblCount = table.Count(TBL)
		if TblCount > 1 then NotOnlyOneSkin = true end 	--вообще тут надо ставить > 0, так как по сути будет ставиться рандомный скин, но он будет только один. Так что и так соайдет
		math.randomseed(os.clock())
		local key = math.random(1,TblCount)
		local i = 0
		for k,v in pairs(TBL) do
			i = i + 1
			if i == key then return k end
		end
	end
	
	local randomSkin = false
	for k,v in pairs(TexturesTbl) do
		for k1,v1 in pairs(self.Settings) do
			if k1 == k then
				if NoSkinsForThisTrain(self,k) then --если этот скин не куплен, то рандомить скин
					--print("was",self.Settings[k1],k)
					local was = self.Settings[k1]
					self.Settings[k1] = ReturnRandomKeyFromTable(v,k)
					--print("now",self.Settings[k1],k)
					timer.Simple(0.0001,function() self.Settings[k1] = was end) -- я не уверен, что таким способом оно будет работать всегда корректно
					randomSkin = true 
				end 
				-- v -- таблица всех текстур
				-- v1 -- выбранный айди скина
			end
		end
	end
	
	if randomSkin and OnSpawn and NotOnlyOneSkin then 
		ULib.tsayError(ply,"Скины на некупленные части состава установятся случайно.") 
		ULib.tsayError(ply,"Купить скин можно в /donate") 
	end
end

local function Trace(ply,tr)
    local verticaloffset = 5 -- Offset for the train model
    local distancecap = 2000 -- When to ignore hitpos and spawn at set distanace
    local pos, ang = nil
    local inhibitrerail = false

    --TODO: Make this work better for raw base ent

    if tr.Hit then
        -- Setup trace to find out of this is a track
        local tracesetup = {}
        tracesetup.start=tr.HitPos
        tracesetup.endpos=tr.HitPos+tr.HitNormal*80
        tracesetup.filter=ply

        local tracedata = util.TraceLine(tracesetup)

        if tracedata.Hit then
            -- Trackspawn
            pos = (tr.HitPos + tracedata.HitPos)/2 + Vector(0,0,verticaloffset)
            ang = tracedata.HitNormal
            ang:Rotate(Angle(0,90,0))
            ang = ang:Angle()
            -- Bit ugly because Rotate() messes with the orthogonal vector | Orthogonal? I wrote "origional?!" :V
        else
            -- Regular spawn
            if tr.HitPos:Distance(tr.StartPos) > distancecap then
                -- Spawnpos is far away, put it at distancecap instead
                pos = tr.StartPos + tr.Normal * distancecap
                inhibitrerail = true
            else
                -- Spawn is near
                pos = tr.HitPos + tr.HitNormal * verticaloffset
            end
            ang = Angle(0,tr.Normal:Angle().y,0)
        end
    else
        -- Trace didn't hit anything, spawn at distancecap
        pos = tr.StartPos + tr.Normal * distancecap
        ang = Angle(0,tr.Normal:Angle().y,0)
    end
    return {pos,ang,inhibitrerail}
end

function UpdateGhostPos(pl)
    local trace = util.TraceLine(util.GetPlayerTrace(pl))
    local tbl =  Metrostroi.RerailGetTrackData(trace.HitPos,pl:GetAimVector())

    if not tbl then tbl = Trace(pl, trace) end
    local class = IsValid(trace.Entity) and trace.Entity:GetClass()

    local pos,ang = vector_origin,angle_zero
    if tbl[3] ~= nil then
        pos = tbl[1]+Vector(0,0,55)
        ang = tbl[2]
        return pos,ang,false,not class or (class == "func_door" or class == "prop_door_rotating")
    else
        pos = tbl.centerpos + Vector(0,0,112)
        ang = tbl.right:Angle()+Angle(0,90,0)
        return pos,ang,true,not class or (class == "func_door" or class == "prop_door_rotating")
    end
end


function TOOL:UpdateGhost()
    local good,canDraw
    for i,e in ipairs(self.GhostEntities) do
        local t = self.Model[i]
        local pos,ang
        if i==1 then
            pos,ang,good,canDraw = UpdateGhostPos(self:GetOwner())
            if self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev") then
                ang = ang+Angle(0,180,0)
            end
        elseif type(t) ~= "string" then
            pos,ang = self.GhostEntities[1]:LocalToWorld(t.pos or vector_origin),self.GhostEntities[1]:LocalToWorldAngles(self.Model[i].ang or angle_zero)
        else
            pos,ang = self.GhostEntities[1]:GetPos(),self.GhostEntities[1]:GetAngles()
        end
        e:SetNoDraw(not canDraw)
        --if not pos then bad = true else pos,ang = rpos,rang end
        if not good then
            e:SetColor(Color(255,150,150,255))
        elseif self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev") then
            e:SetColor(Color(255,255,150,255))
        else
            e:SetColor(color_white)
        end
        e:SetPos(pos)
        e:SetAngles(ang)
    end
end

function TOOL:Holster()
    if not IsFirstTimePredicted() or SERVER then return end
end

--local owner
function TOOL:Think()
    if not self.Train then return end
    --owner = self:GetOwner()
    --self.tbl = self:GetConvar()
    --self.int = self.tbl.Prom > 0 or !Trains[self.tbl.Train][1]:find("Ezh3")
    if CLIENT and self.Train.Spawner.model then
        if not self.GhostEntities  then self.GhostEntities = {} end
        if not IsValid(self.GhostEntities[1]) or self.Model ~= self.Train.Spawner.model then
            self.Model = self.Train.Spawner.model
            for _,e in pairs(self.GhostEntities) do SafeRemoveEntity(e) end
            self.GhostEntities = {}
            if type(self.Model) == "string" then
                self.GhostEntities[1] = ClientsideModel(self.Model,RENDERGROUP_OPAQUE)
                self.GhostEntities[1]:SetModel(self.Model)
            else
                for i,t in pairs(self.Model) do
                    if type(t) == "string" then
                        self.GhostEntities[i] = ClientsideModel(t,RENDERGROUP_OPAQUE)
                        self.GhostEntities[i]:SetModel(t)
                    else
                        self.GhostEntities[i] = ClientsideModel(t[1],RENDERGROUP_OPAQUE)
                        self.GhostEntities[i]:SetModel(t[1])
                    end
                end
            end
            for i,e in pairs(self.GhostEntities) do
                e:SetRenderMode(RENDERMODE_TRANSALPHA)
                e.GetBodyColor = function() return Vector(1,1,1) end
                e.GetDirtLevel = function() return 0.25 end
            end
            hook.Add("Think",self.GhostEntities[1],function()
                if not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon():GetClass()~="gmod_tool" or GetConVarString("gmod_toolmode") ~= "train_spawner" then
                    self:OnRemove()
                end
            end)
        else
            self:UpdateGhost()
        end
    end
    ---if SERVER then self.Rev = self.Rev end
end

function TOOL:SetSettings(ent, ply, i,inth)
    local rot = false
    if i > 1 then
        rot = i == self.tbl.WagNum and true or math.random() > 0.5
    end
end

local function SetValue(ent,id,val)
    if type(val) == "number" then
        ent:SetNW2Int(id,val)
    elseif type(val) == "string" then
        ent:SetNW2String(id,val)
    elseif type(val) == "boolean" then
        ent:SetNW2Bool(id,val)
    end
end

function TOOL:SpawnWagon(trace)
    if CLIENT then return end
    local ply = self:GetOwner()
	
    local FIXFIXFIX = {}
    for i=1,math.random(12) do
        FIXFIXFIX[i] = ents.Create("env_sprite")
        FIXFIXFIX[i]:Spawn()
    end

    local LastRot,LastEnt = false
    local trains = {}
    for i=1,self.Settings.WagNum do
		CustomSkin(self,i == 1)
        local spawnfunc = self.Train.Spawner.spawnfunc
        local ent
        if i == 1 then
            if spawnfunc then
                ent = self.Train:SpawnFunction(ply,trace,spawnfunc(i,self.Settings,self.Train),self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev"))
            else
                ent = self.Train:SpawnFunction(ply,trace,self.Train.Spawner.head or self.Train.ClassName,self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev"))
            end
            --nil,self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev") and Angle(0,180,0) or angle_zero) --Create a first entity in queue
            if ent then
                undo.Create(self.Train.Spawner.head or self.Train.ClassName)
            else
                self:GetOwner():LimitHit("spawner_wrong_pos")
                return false
            end
            --if self:GetOwner():GetNW2Bool("metrostroi_train_spawner_rev") then
                --ent:SetAngles(ent:LocalToWorldAngles(Angle(0,180,0)))
            --end
            --if self.Rot then
        end
        if i > 1 then
            local rot = (i==self.Settings.WagNum or math.random() > 0.5) -- Rotate last wagon or rotate it randomly
            if spawnfunc then
                ent = ents.Create(spawnfunc(i,self.Settings,self.Train))
            else
                ent = ents.Create(i~=self.Settings.WagNum and self.Train.Spawner.interim or self.Train.Spawner.head or self.Train.ClassName)
            end
            ent.Owner = ply
            ent:Spawn()
            -- Invert bogeys by rotation
            local bogeyL1,bogeyE1,bogeyE2
            local couplL1,couplE1,couplE2
            if LastRot then
                bogeyL1 = LastEnt.FrontBogey
                couplL1 = LastEnt.FrontCouple
            else
                bogeyL1 = LastEnt.RearBogey
                couplL1 = LastEnt.RearCouple
            end
            if rot then
                bogeyE1,bogeyE2 = ent.RearBogey,ent.FrontBogey
                couplE1,couplE2 = ent.FrontCouple,ent.RearCouple
            else
                bogeyE1,bogeyE2 = ent.FrontBogey,ent.RearBogey
                couplE1,couplE2 = ent.RearCouple,ent.FrontCouple
            end
            local haveCoupler = couplL1 ~= nil
            if haveCoupler then
                bogeyE1:SetAngles(ent:LocalToWorldAngles(bogeyE1.SpawnAng))
                bogeyE2:SetAngles(ent:LocalToWorldAngles(bogeyE1.SpawnAng))
                --print(couplL1 == LastEnt.RearBogey,couplL1 == ent.RearCouple,couplL2 == ent.RearCouple)
                -- Set bogey position by our bogey couple offset and lastent bogey couple offset
                couplE1:SetPos(
                    couplL1:LocalToWorld(
                        Vector(
                            couplL1.CouplingPointOffset.x*1.1+couplE1.CouplingPointOffset.x*1.1,
                            couplL1.CouplingPointOffset.y-couplE1.CouplingPointOffset.y,
                            couplL1.CouplingPointOffset.z-couplE1.CouplingPointOffset.z
                        )
                    )
                )
                -- Set bogey angles
                couplE1:SetAngles(couplL1:LocalToWorldAngles(Angle(0,180,0)))
                -- Set entity position by bogey pos and bogey offset
                couplE2:SetAngles(couplE1:LocalToWorldAngles(Angle(0,180,0)))
                ent:SetPos(couplE1:LocalToWorld(couplE1.SpawnPos*Vector(rot and -1 or 1,-1,-1)))
                -- Set entity angles by last ent and rotation
                ent:SetAngles(LastEnt:LocalToWorldAngles(Angle(0,rot ~= LastRot and 180 or 0,0)))

                -- Set bogey pos
                bogeyE1:SetPos(ent:LocalToWorld(bogeyE1.SpawnPos))
                bogeyE2:SetPos(ent:LocalToWorld(bogeyE2.SpawnPos))
                -- Set bogey angles
                bogeyE1:SetAngles(ent:LocalToWorldAngles(bogeyE1.SpawnAng))
                bogeyE2:SetAngles(ent:LocalToWorldAngles(bogeyE1.SpawnAng))
            else
                -- Set bogey position by our bogey couple offset and lastent bogey couple offset
                bogeyE1:SetPos(
                            bogeyL1:LocalToWorld(
                                Vector(bogeyL1.CouplingPointOffset.x*1.1+bogeyE1.CouplingPointOffset.x*1.05,bogeyL1.CouplingPointOffset.y-bogeyE1.CouplingPointOffset.y,bogeyL1.CouplingPointOffset.z-bogeyE1.CouplingPointOffset.z)
                            )
                )
                -- Set bogey angles
                bogeyE1:SetAngles(bogeyL1:LocalToWorldAngles(Angle(0,180,0)))
                -- Set entity position by bogey pos and bogey offset
                bogeyE2:SetAngles(bogeyE1:LocalToWorldAngles(Angle(0,180,0)))
                ent:SetPos(bogeyE1:LocalToWorld(bogeyE1.SpawnPos*Vector(rot and -1 or 1,-1,-1)))
                -- Set entity angles by last ent and rotation
                ent:SetAngles(LastEnt:LocalToWorldAngles(Angle(0,rot ~= LastRot and 180 or 0,0)))
                -- Set second bogey pos
                bogeyE2:SetPos(ent:LocalToWorld(bogeyE2.SpawnPos))
            end

            Metrostroi.RerailTrain(ent) --Rerail train
            --LastEnt:LocalToWorld(bogeyL1:WorldToLocal(Vector))))
            --print)

            LastRot = rot
			
        end
        table.insert(trains,ent)
        undo.AddEntity(ent)
        --[[
        ent:SetMoveType(MOVETYPE_NONE)
        ent.FrontBogey:SetMoveType(MOVETYPE_NONE)
        ent.RearBogey:SetMoveType(MOVETYPE_NONE)
        if IsValid(ent.FrontCouple) then
            ent.FrontCouple:SetMoveType(MOVETYPE_NONE)
            ent.RearCouple:SetMoveType(MOVETYPE_NONE)
        end]]
        for _, set in ipairs(self.Train.Spawner) do
            local val = self.Settings[set[1]]
            if set[3] == "List" then
                if set[6] and type(set[6]) == "function" then   set[6](ent,val,LastRot,i,self.Settings.WagNum) else SetValue(ent,set[1],val) end
            elseif set[3] == "Boolean" then
                if set[5] and type(set[5]) == "function" then   set[5](ent,val,LastRot,i,self.Settings.WagNum) else ent:SetNW2Bool(set[1],val) end
            elseif set[3] == "Slider" then
                if set[8] and type(set[8]) == "function" then   set[8](ent,val,LastRot,i,self.Settings.WagNum) else ent:SetNW2Int(set[1],val) end
            end
        end
        if self.Train.Spawner.func then self.Train.Spawner.func(ent,i,self.Settings.WagNum,LastRot) end
        if self.Train.Spawner.wagfunc then ent:GenerateWagonNumber(function(_,number) return self.Train.Spawner.wagfunc(ent,i,number) end) end
        if ent.TrainSpawnerUpdate then ent:TrainSpawnerUpdate() end
        hook.Run("MetrostroiSpawnerUpdate",ent,self.Settings)
        ent:UpdateTextures()
        ent.FrontAutoCouple = i > 1 and i < self.Settings.WagNum
        ent.RearAutoCouple = true
        LastEnt = ent
		
    end
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Undone a train")
    undo.Finish()
    if self.Train.Spawner.postfunc then self.Train.Spawner.postfunc(trains,self.Settings.WagNum) end
    --if self.Settings.AutoCouple and #trains > 1 then
        for i=2,#trains do
            trains[i].IgnoreEngine = true
        end
        timer.Simple(3,function()
            if not IsValid(trains[1]) then return end
            trains[#trains].RearBogey.MotorForce = 35300
            trains[#trains].RearBogey.MotorPower = 1
            if IsValid(trains[1].RearCouple) then
                trains[1].RearCouple.OnCoupleSpawner = function(ent)
                    for i=1,#trains do
                        trains[i].IgnoreEngine = false
                    end
                end
                timer.Simple(1*#trains,function()
                    if IsValid(trains[1]) and IsValid(trains[1].RearCouple) and trains[1].RearCouple.OnCoupleSpawner then
                        trains[1].RearCouple:OnCoupleSpawner()
                    end
                end)
            else
                trains[1].RearBogey.OnCoupleSpawner = function(ent)
                    for i=1,#trains do
                        trains[i].IgnoreEngine = false
                    end
                end
                timer.Simple(1*#trains,function()
                    if IsValid(trains[1].RearBogey) and trains[1].RearBogey.OnCoupleSpawner then
                        trains[1].RearBogey:OnCoupleSpawner()
                    end
                end)
            end
        end)
    --end
    --self.rot = false
	
	--------------УВЕДОМЛЕНИЕ В ЧАТ-------------------------------------------
	SpawnNotif(ply, self, trace.HitPos, self.Settings.WagNum)
	
    for k,v in pairs(FIXFIXFIX) do SafeRemoveEntity(v) end
end

function TOOL:OnRemove()
    self:Finish()
end
function TOOL:Finish()
    for _,e in pairs(self.GhostEntities) do SafeRemoveEntity(e) end
    self.GhostEntities = {}
end

function TOOL:Reload(trace)
    if CLIENT then return end
    local spawner = ents.Create("gmod_train_spawner")
    spawner:SpawnFunction(self:GetOwner())
end
function TOOL:LeftClick(trace)
    local class = IsValid(trace.Entity) and trace.Entity:GetClass()
    if class and (trace.Entity.Spawner or class ~= "func_door" and class ~= "prop_door_rotating")  then
        if SERVER then
            if trace.Entity.ClassName == (self.Train.Spawner.head or self.Train.ClassName) or trace.Entity.ClassName == self.Train.Spawner.interim then
                local LastEnt
                local trains = {}
                for k,ent in ipairs(trace.Entity.WagonList) do
					CustomSkin(self)
                    --[[
                    local rot = ent.RearTrain and ent.RearTrain.FrontTrain == ent or ent.FrontTrain and ent.FrontTrain.RearTrain == ent
                    if not LastRot then
                        rot = ent.RearTrain and ent.RearTrain.RearTrain == ent or ent.FrontTrain and ent.FrontTrain.FrontTrain == ent
                    end]]
                    local rot = ent.RearTrain == LastEnt
                    LastEnt = ent
                    for i, set in ipairs(self.Train.Spawner) do
                        local val = self.Settings[set[1]]
                        if set[3] == "List" then
                            if set[6] and type(set[6]) == "function" then   set[6](ent,val,rot,k,self.Settings.WagNum) else SetValue(ent,set[1],val) end
                        elseif set[3] == "Boolean" then
                            if set[5] and type(set[5]) == "function" then   set[5](ent,val,rot,k,self.Settings.WagNum) else ent:SetNW2Bool(set[1],val) end
                        elseif set[3] == "Slider" then
                            if set[8] and type(set[8]) == "function" then   set[8](ent,val,rot,k,self.Settings.WagNum) else ent:SetNW2Int(set[1],val) end
                        end
                    end
                    if self.Train.Spawner.func then self.Train.Spawner.func(ent,k,self.Settings.WagNum,rot) end
                    ent:GenerateWagonNumber(self.Train.Spawner.wagfunc)
                    if ent.TrainSpawnerUpdate then ent:TrainSpawnerUpdate() end
                    hook.Run("MetrostroiSpawnerUpdate",ent,self.Settings)
                    ent:UpdateTextures()
                    table.insert(trains,ent)
                end
                if self.Train.Spawner.postfunc then self.Train.Spawner.postfunc(trains,self.Settings.WagNum) end
            end
        end
        return
    end
    if not self.AllowSpawn or not self.Train then return end
    if SERVER then
		local ply = self:GetOwner()
	--self.Settings.WagNum = 6
	--if (self.Train.ClassName == "gmod_subway_81-703" or self.Train.ClassName == "gmod_subway_em508" or self.Train.ClassName == "gmod_subway_81-702") and ply:GetUserGroup() == "user" then ULib.tsayError( ply, "Тебе нельзя спавнить этот состав", true ) return end
	--if self.Train.ClassName == "gmod_subway_81-717_6" and ply:GetUserGroup() ~= "superadmin"  then ULib.tsayError( ply, "Тебе нельзя спавнить этот состав", true ) return end
	if self.Train.ClassName == "gmod_subway_81-740.4" then self.Settings.WagNum = 2 end --только 2 вагона для русича

		local maximum = MaximumWagons(ply,self)

        if self.Settings.WagNum > maximum then
            self.Settings.WagNum = maximum
        end
		
		if self.Settings.WagNum ~= 3 and self.Settings.WagNum ~= 6 and self.Train.ClassName == "gmod_subway_81-722" then return end
		
        if Metrostroi.TrainCountOnPlayer(self:GetOwner()) + self.Settings.WagNum > maximum
            or Metrostroi.TrainCount() + self.Settings.WagNum > GetConVarNumber("metrostroi_maxwagons") then
                self:GetOwner():LimitHit("train_limit")
			--	lasttimeusage = CurTime() - 5
            return true
        end
        if hook.Run("MetrostroiSpawnerRestrict",self:GetOwner(),self.Settings) then
            self:GetOwner():LimitHit("spawner_restrict")
            return true
        end
    end
    self:SpawnWagon(trace)
    return
end

function TOOL:RightClick(trace)
    if IsValid(trace.Entity) then
		--if 1 then return end
        if SERVER then
            if trace.Entity.ClassName == (self.Train.Spawner.head or self.Train.ClassName) or trace.Entity.ClassName == self.Train.Spawner.interim then
                local LastEnt
                local trains = {}
                for k,ent in pairs(trace.Entity.WagonList) do
                    local rot = ent.RearTrain == LastEnt
                    LastEnt = ent
                    if ent ~= trace.Entity then continue end
					CustomSkin(self)
                    for i, set in ipairs(self.Train.Spawner) do
                        local val = self.Settings[set[1]]
                        if set[3] == "List" then
                            if set[6] and type(set[6]) == "function" then set[6](ent,val,rot,k,self.Settings.WagNum,true) else SetValue(ent,set[1],val) end
                        elseif set[3] == "Boolean" then
                            if set[5] and type(set[5]) == "function" then set[5](ent,val,rot,k,self.Settings.WagNum,true) else ent:SetNW2Bool(set[1],val) end
                        elseif set[3] == "Slider" then
                            if set[8] and type(set[8]) == "function" then set[8](ent,val,rot,k,self.Settings.WagNum,true) else ent:SetNW2Int(set[1],val) end
                        end
                    end
                    if self.Train.Spawner.func then self.Train.Spawner.func(ent,k,self.Settings.WagNum,rot) end
                    ent:GenerateWagonNumber(self.Train.Spawner.wagfunc)
                    if ent.TrainSpawnerUpdate then ent:TrainSpawnerUpdate() end
                    hook.Run("MetrostroiSpawnerUpdate",ent,self.Settings)
                    ent:UpdateTextures()
                    table.insert(trains,ent)
                    if self.Train.Spawner.postfunc then self.Train.Spawner.postfunc(trains,self.Settings.WagNum) end
                end
            end
        end
        return
    end
    if not self.AllowSpawn or not self.Train then return end
    if CLIENT then return end
    self.Rev = not self.Rev
    self:GetOwner():SetNW2Bool("metrostroi_train_spawner_rev",self.Rev)

end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Text = "#Tool.train_spawner.name", Description = "#Tool.train_spawner.desc" })
end

if SERVER then
    util.AddNetworkString "train_spawner_open"
    net.Receive("train_spawner_open",function(len,ply)
        ply:ConCommand("gmod_tool train_spawner")
        ply:SelectWeapon("gmod_tool")
        local tool = ply:GetTool("train_spawner")
        tool.AllowSpawn = true
        tool.Settings = net.ReadTable()
        local ENT = scripted_ents.Get(tool.Settings.Train)
        if not ENT then tool.AllowSpawn = false else tool.Train = ENT end
    end)
    return
end
