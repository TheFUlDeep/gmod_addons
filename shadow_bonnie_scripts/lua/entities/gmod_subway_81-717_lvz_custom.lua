AddCSLuaFile()

function ENT:Initialize() self:Remove() end

ENT.Type			= "anim"
ENT.Base			= "gmod_subway_base"
ENT.PrintName = "81-717 LVZ Custom"
ENT.SkinsType = "81-717_spb"

ENT.Spawnable	   = false
ENT.AdminSpawnable  = false

ENT.SubwayTrain = {
	Type = "81",
	Name = "81-717.5m",
	WagType = 1,
	Manufacturer = "LVZ",
}

local function TrainSpawnerUpdate(self,int)
	local typ = self:GetNW2Int("Type")
	local num = self.WagonNumber

	local kvr = self:GetNW2Bool("KVR")
	
	if typ==1 then --PAKSDM
		self.Electric:TriggerInput("X2PS",0)
		self.Electric:TriggerInput("Type",self.Electric.LVZ_4)
		
		if !int then
			self.PAM:TriggerInput("KSDMode",1)
			self:SetNW2Int("AVType",4)

			if kvr then
				self.UPO.Buzz = math.random() > 0.7 and 2 or math.random() > 0.7 and 1
			else
				self.UPO.Buzz = math.random() > 0.4 and 2 or math.random() > 0.4 and 1
			end
			if not IsValid(self.LightSensor) then
				self.LightSensor = self:AddLightSensor(vector_origin,angle_zero,"models/metrostroi_train/81-717/rfid_reader.mdl")
			end
			SafeRemoveEntity(self.LeftAutoCoil)
			SafeRemoveEntity(self.RightAutoCoil)
			SafeRemoveEntity(self.SBPPSensor)
		end
	elseif typ == 2 then --PUAV
		self.Electric:TriggerInput("X2PS",1)
		self.Electric:TriggerInput("Type",self.Electric.LVZ_2)
		
		if !int then
			self.PAM:TriggerInput("KSDMode",0)
			self:SetNW2Int("AVType",2)

			self.UPO.Buzz = math.random() > 0.6 and 2 or math.random() > 0.6 and 1
			if self.SBPP then
				if not IsValid(self.SBPPSensor) then
					self.SBPPSensor = self:AddLightSensor(vector_origin,angle_zero,"models/metrostroi_train/81-717/dkp_reader.mdl")
				end
				SafeRemoveEntity(self.LeftAutoCoil)
				SafeRemoveEntity(self.RightAutoCoil)
			else
				if not IsValid(self.LeftAutoCoil) then self.LeftAutoCoil = self:AddAutodriveCoil(self.FrontBogey,false) end
				if not IsValid(self.RightAutoCoil) then self.RightAutoCoil = self:AddAutodriveCoil(self.FrontBogey,true) end
				SafeRemoveEntity(self.SBPPSensor)
			end
			SafeRemoveEntity(self.LightSensor)
		end
	elseif typ == 3 then --PAM
		self.Electric:TriggerInput("X2PS",1)
		self.Electric:TriggerInput("Type",self.Electric.LVZ_3)
		
		if !int then
			self:SetNW2Int("AVType",3)
			self.UPO.Buzz = math.random() > 0.6 and 2 or math.random() > 0.6 and 1

			if not IsValid(self.LightSensor) then self.LightSensor = self:AddLightSensor(vector_origin,angle_zero,"models/metrostroi_train/81-717/rfid_reader.mdl") end
			SafeRemoveEntity(self.LeftAutoCoil)
			SafeRemoveEntity(self.RightAutoCoil)
			SafeRemoveEntity(self.SBPPSensor)
		end
	end

	self.Pneumatic.ValveType = self:GetNW2Int("Crane",1)+1
	self.Announcer.AnnouncerType = self:GetNW2Int("Announcer",1)
	self:UpdateTextures()
	self:UpdateLampsColors()

	self:SetNW2Float("UPONoiseVolume",math.Rand(0,0.4))
	self:SetNW2Float("UPOVolume",math.Rand(0.9,1))
	self:SetNW2Float("UPOBuzzVolume",math.Rand(0.6,0.9))
	
	if !int then
		local used = {}
		local str = ""
		for i,k in ipairs(self.PR14XRelaysOrder) do
			local v = self.PR14XRelays[k]
			repeat
				local rndi = math.ceil(math.random()*#v)
				if not used[ v[rndi][1] ] then
					str = str..rndi
					used[ v[rndi][1] ] = true
					break
				end
			until not used[ v[rndi][1] ]
			--print(k,v)
		end
		self:SetNW2String("RelaysConfig",str)
	end

	local pneumoPow = 1.3+(math.random()^1.2)*0.3
	if IsValid(self.FrontBogey) then
		self.FrontBogey:SetNW2Int("SquealType",math.floor(math.random()*7)+1)
		self.FrontBogey.PneumaticPow = pneumoPow
	end
	if IsValid(self.RearBogey) then
		self.RearBogey:SetNW2Int("SquealType",math.floor(math.random()*7)+1)
		self.RearBogey.PneumaticPow = pneumoPow
	end
end

ENT.Spawner = {
	model = {
		"models/metrostroi_train/81-717/81-717_spb.mdl",
		"models/metrostroi_train/81-717/interior_spb.mdl",
		"models/metrostroi_train/81-717/717_body_additional_spb.mdl",
		"models/metrostroi_train/81-717/brake_valves/334.mdl",
		"models/metrostroi_train/81-717/lamps_type1.mdl",
		"models/metrostroi_train/81-717/couch_old.mdl",
		"models/metrostroi_train/81-717/couch_cap_l.mdl",
		"models/metrostroi_train/81-717/handlers_old.mdl",
		"models/metrostroi_train/81-717/mask_spb_222.mdl",
		"models/metrostroi_train/81-717/couch_cap_r.mdl",
		"models/metrostroi_train/81-717/cabine_spb_central.mdl",
		"models/metrostroi_train/81-717/pult/body_spb_yellow.mdl",
		"models/metrostroi_train/81-717/pult/pult_spb_yellow.mdl",
		"models/metrostroi_train/81-717/pult/puav_new.mdl",
		"models/metrostroi_train/81-717/pult/ars_spb_yellow.mdl",
	},
	head = "gmod_subway_81-717_lvz",
	interim = "gmod_subway_81-714_lvz",
	func = function(train,i,max,LastRot)
		train.CustomSettings = true
		local typ = train:GetNW2Int("Type")
		
		if 1==i or i==max then
			train.NumberRangesID = typ==1 and math.ceil(math.random()+0.5) or typ+1
		else
			train.NumberRangesID = typ
		end
		
		train.TrainSpawnerUpdate = function(self) return TrainSpawnerUpdate(self,self:GetClass()=="gmod_subway_81-714_lvz") end
	end,
	{"Type","Spawner.717.Type","List",{"Линия 2 (МПЛ)","Линия 4 (ПБЛ)","Линия 5 (ФПЛ)"}},
	Metrostroi.Skins.GetTable("Texture","Spawner.Texture",false,"train"),
	Metrostroi.Skins.GetTable("PassTexture","Spawner.PassTexture",false,"pass"),
	Metrostroi.Skins.GetTable("CabTexture","Spawner.CabTexture",false,"cab"),
	{"Scheme","Spawner.717.Schemes","List",function()
		local Schemes = {}
		for k,v in pairs(Metrostroi.Skins["717_new_schemes"] or {}) do Schemes[k] = v.name or k end
		return Schemes
	end},
	{},
	{"RingType","Spawner.717.RingType","List",{"Тип 1","Тип 2","Тип 3","Тип 4"}},
	{"RingTypePA","Spawner.717.RingTypePA","List",{"Тип 1","Тип 2","Тип 3","Тип 4"}},
	{"NewUSS","Spawner.717.NewUSS","Boolean"},
	{"KVR","Spawner.717.KVR","Boolean"},
	{"MaskType","Spawner.717.MaskType","List",{"2-2","2-2s","2-2-2"}},
	{"Crane","Spawner.717.CraneType","List",{"013","334"}},
	{"WhitePLights","Spawner.717.WhitePLights","Boolean"},
	{"NewSeats","Spawner.717.NewSeats","Boolean"},
	{"SecondKV","Spawner.717.SecondKV","Boolean"},
	{"BPSNType","Spawner.717.BPSNType","List",{"Тип 1","Тип 2","Тип 3","Тип 4","Тип 5"}},
	{},
	{"SpawnMode","Spawner.717.SpawnMode","List",{"Spawner.717.SpawnMode.Full","Spawner.717.SpawnMode.Deadlock","Spawner.717.SpawnMode.NightDeadlock","Spawner.717.SpawnMode.Depot"}, nil,function(ent,val,rot,i,wagnum,rclk)
		if rclk then return end
        if ent._SpawnerStarted~=val then
            ent.VB:TriggerInput("Set",val<=2 and 1 or 0)
            ent.ParkingBrake:TriggerInput("Set",val==3 and 1 or 0)
            if ent.AR63  then
                local first = i==1 or _LastSpawner~=CurTime()
                ent.A53:TriggerInput("Set",val<=3 and 1 or 0)
                ent.AR63:TriggerInput("Set",val<=2 and 1 or 0)
                ent.R_UNch:TriggerInput("Set",val==1 and 1 or 0)
                ent.R_UPO:TriggerInput("Set",val<=2 and 1 or 0)
                if ent.Plombs.RC1 and val<=2 then
                    ent.VPAOn:TriggerInput("Set",1)
                    timer.Simple(1,function()
                        if not IsValid(ent) or val > 2 then return end
                            ent.VPAOn:TriggerInput("Set",0)
                    end)
                else
                    ent.VPAOn:TriggerInput("Set",0)
                end
                ent.VAU:TriggerInput("Set",(ent.Plombs.RC2 and val<=2) and 1 or 0)
                ent.L_4:TriggerInput("Set",val==1 and 1 or 0)
                ent.BPSNon:TriggerInput("Set",(val==1 and first) and 1 or 0)
                ent.VMK:TriggerInput("Set",(val==1 and first) and 1 or 0)
                ent.ARS:TriggerInput("Set",(ent.Plombs.RC1 and val==1 and first) and 1 or 0)
                ent.ALS:TriggerInput("Set",(ent.Plombs.RC1 and val==1) and 1 or 0)
                ent.L_1:TriggerInput("Set",val==1 and 1 or 0)
                ent.L_3:TriggerInput("Set",val==1 and 1 or 0)
                ent.L_4:TriggerInput("Set",val==1 and 1 or 0)
                ent.EPK:TriggerInput("Set",(ent.Plombs.RC1 and val==1) and 1 or 0)
				ent.VSOSD:TriggerInput("Set",first and val<=3 and 1 or 0)
                _LastSpawner=CurTime()
                ent.CabinDoor = val==4 and first
                ent.PassengerDoor = val==4
                ent.RearDoor = val==4
            else
                ent.FrontDoor = val==4
                ent.RearDoor = val==4
            end
            if val == 1 then ent.BV:TriggerInput("Enable",1) end
            ent.GV:TriggerInput("Set",val<4 and 1 or 0)
            ent._SpawnerStarted = val
        end
        ent.Pneumatic.TrainLinePressure = val==3 and math.random()*4 or val==2 and 4.5+math.random()*3 or 7.6+math.random()*0.6
        if val==4 then ent.Pneumatic.BrakeLinePressure = 5.2 end
	end},
}

--[[local class = "gmod_subway_81-717_lvz_custom"

if !table.HasValue(Metrostroi.TrainClasses,class) then
	table.insert(Metrostroi.TrainClasses,class)
end]]