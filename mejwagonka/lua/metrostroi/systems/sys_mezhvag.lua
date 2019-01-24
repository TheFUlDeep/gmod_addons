--------------------------------------------------------------------------------
print("1")
--------------------------------------------------------------------------------

Metrostroi.DefineSystem("MEZHVAG")
TRAIN_SYSTEM.DontAccelerateSimulation = true

if SERVER then

	util.AddNetworkString("mezhvag")

	function TRAIN_SYSTEM:Think()
		local v = self.Train
		local Couple2 = v.RearCouple
		local Couple1 = v.FrontCouple

		local function Sending(train1,train2,front1,front2,delete)
			net.Start("mezhvag")
			net.WriteEntity(train1)			-- train
			net.WriteEntity(train2)			-- train (coupled to)
			net.WriteBool(front1)			-- true - front, false - rear
			net.WriteBool(front2)			-- front or rear (coupled to)
			net.WriteBool(delete)	-- true - spawn, false - delete mezhvag
			net.Broadcast()
		end
		
		Couple2.mezhvag = Couple2.mezhvag or false --need for checking for exist mezhvag
		Couple1.mezhvag = Couple1.mezhvag or false --need for checking for exist mezhvag
		
		--======== SENDING ========--
		
		--==== RearCouple ====--
		
		if Couple2.CoupledEnt ~= nil then
		
				local v2 = Couple2.CoupledEnt:GetNW2Entity("TrainEntity")
				local front = false
				if Couple2.CoupledEnt == v2.FrontCouple then front = true end
		
			if not Couple2.mezhvag then
				
				Sending(v,v2,false,front,true)
				
				Couple2.mezhvag = true
				Couple2.mezhvagtimer = CurTime()
			else
				-- timer for updating
				Couple2.mezhvagtimer = Couple2.mezhvagtimer or CurTime()
				
				if CurTime() - Couple2.mezhvagtimer > 10 then
					Sending(v,v2,false,front,true)
					Couple2.mezhvagtimer = CurTime()
				end
			end
		else
			if Couple2.mezhvag then
			
				Sending(v,NULL,false,false,false)
			
				Couple2.mezhvag = false
			end
		end
		
		--==== FrontCouple ====--
		
		if Couple1.CoupledEnt ~= nil then
		
				local v2 = Couple1.CoupledEnt:GetNW2Entity("TrainEntity")
				local front = false
				if Couple1.CoupledEnt == v2.FrontCouple then front = true end
		
			if not Couple1.mezhvag then
				
				Sending(v,v2,true,front,true)
				
				Couple1.mezhvag = true
				Couple1.mezhvagtimer = CurTime()
			else
				-- timer for updating
				Couple1.mezhvagtimer = Couple1.mezhvagtimer or CurTime()
				
				if CurTime() - Couple1.mezhvagtimer > 10 then
					Sending(v,v2,true,front,true)
					Couple1.mezhvagtimer = CurTime()
				end
			end
		else
			if Couple1.mezhvag then
			
				Sending(v,NULL,true,false,false)
			
				Couple1.mezhvag = false
			end
		end
	end
end

if CLIENT then

	util.PrecacheModel("models/metrostroi/mezhvag.mdl")
	
	hook.Add("Think","MetrostroiMezhvagThink",function()
		for _,ent in pairs(ents.FindByClass("gmod_subway_*")) do
			if IsValid(ent.RearMezhvag) then
				if not ent:ShouldRenderClientEnts() or not IsValid(ent.RearMezhvag:GetParent()) then
					ent.RearMezhvag:Remove()
				end
			end
			
			if IsValid(ent.FrontMezhvag) then
				if not ent:ShouldRenderClientEnts() or not IsValid(ent.FrontMezhvag:GetParent()) then
					ent.FrontMezhvag:Remove()
				end
			end
		end
	end)
	
	local OBP = 29.196-0.633789	--OriginalBonePosition (get from 3ds max)
	
	--ent:ManipulateBonePosition(boneid,pos)
	--Note that the position is relative to the original bone position, not relative to the world or the entity.
	
	local TMPT = {			-- TrainMezhvagPositionTable
	["gmod_subway_81-717_lvz"] = Vector(-472,464,0),		--Vector(reardist,frontdist,updist)
	["gmod_subway_81-714_lvz"] = Vector(-472,458.5,0),
	["gmod_subway_81-717_mvm"] = Vector(-472,464,0),
	["gmod_subway_81-714_mvm"] = Vector(-472,458.5,0),
	["gmod_subway_81-718"] = Vector(-472,458.5,0),
	["gmod_subway_81-719"] = Vector(-472,458.5,0),
	["gmod_subway_81-722"] = Vector(-467,494,-15),
	["gmod_subway_81-723"] = Vector(-467,461,-15),
	["gmod_subway_81-724"] = Vector(-467,461,-15),
	["gmod_subway_81-720"] = Vector(-467,496,-15),
	["gmod_subway_81-721"] = Vector(-467,461,-15),
	["gmod_subway_81-703"] = Vector(-464,461,-12),
	["gmod_subway_81-703_2"] = Vector(-464,461,-12),
	["gmod_subway_ezh"] = Vector(-472,468,-12),
	["gmod_subway_ezh1"] = Vector(-472,468,-12),
	["gmod_subway_ezh3"] = Vector(-472,468,-12),
	["gmod_subway_em508t"] = Vector(-472,468,-12),
	["gmod_subway_em508"] = Vector(-472,468,-12),
	["gmod_subway_em508_int"] = Vector(-472,468,-12),
	["gmod_subway_ema"] = Vector(-472,468,-12),
	["gmod_subway_em"] = Vector(-472,468,-12),
	["gmod_subway_81-717_6"] = Vector(-468,480,0.2),
	["gmod_subway_81-714_6"] = Vector(-465.5,465.7),	
	}
	
	local function Mezhvag(create,ent,front,ent2,front2)
	
		if create then

			if not IsValid(ent) or not IsValid(ent2) then return end
			if TMPT[ent2:GetClass()]==nil or TMPT[ent:GetClass()]==nil then return end
			if not ent:ShouldRenderClientEnts() then return end
			
			if not front then
				
				if IsValid(ent.RearMezhvag) then ent.RearMezhvag:Remove() end
					
				ent.RearMezhvag = ClientsideModel("models/metrostroi/mezhvag.mdl")
					
				if IsValid(ent.RearMezhvag) then
				
					ent.RearMezhvag:SetParent(nil)
					ent.RearMezhvag:SetPos(ent:LocalToWorld(Vector(TMPT[ent:GetClass()].x,0,TMPT[ent:GetClass()].z)))
					ent.RearMezhvag:SetAngles(ent:LocalToWorldAngles(Angle(0,90,0)))
					ent.RearMezhvag:SetParent(ent)
					ent.RearMezhvag.CoupledTrain = ent2
					ent.RearMezhvag.CoupledTrainFront = front2
					ent.RearMezhvag.Train = ent
					
					hook.Add("Think",ent.RearMezhvag,function()
						if not IsValid(ent.RearMezhvag:GetParent()) or not ent:ShouldRenderClientEnts() then
							ent.RearMezhvag:Remove()
						end
					end)
				end
			else
				
				if IsValid(ent.FrontMezhvag) then ent.FrontMezhvag:Remove() end
				
				ent.FrontMezhvag = ClientsideModel("models/metrostroi/mezhvag.mdl")
					
				if IsValid(ent.FrontMezhvag) then
				
					ent.FrontMezhvag:SetParent(nil)
					ent.FrontMezhvag:SetPos(ent:LocalToWorld(Vector(TMPT[ent:GetClass()].y,0,TMPT[ent:GetClass()].z)))
					ent.FrontMezhvag:SetAngles(ent:LocalToWorldAngles(Angle(0,-90,0)))
					ent.FrontMezhvag:SetParent(ent)
					ent.FrontMezhvag.CoupledTrain = ent2
					ent.FrontMezhvag.CoupledTrainFront = front2
					ent.FrontMezhvag.Train = ent
					
					function ent.FrontMezhvag:Think()
						if not IsValid(self:GetParent()) or not self.Train:ShouldRenderClientEnts() then
							self:Remove()
						end
					end
				end
			end
		else
			if not front and IsValid(ent.RearMezhvag) then ent.RearMezhvag:Remove() end
			if front and IsValid(ent.FrontMezhvag) then ent.FrontMezhvag:Remove() end
		end
	end

	net.Receive("mezhvag",function(len)
		local train1 = net.ReadEntity()
		local train2 = net.ReadEntity()
		local front1 = net.ReadBool()
		local front2 = net.ReadBool()
		local spawn = net.ReadBool()

		Mezhvag(spawn,train1,front1,train2,front2)
	end)
	
	function TRAIN_SYSTEM:ClientThink()
	
		local ent = self.Train
	
		if IsValid(ent.RearMezhvag) then
			
			if not IsValid(ent.RearMezhvag:GetParent()) or not ent:ShouldRenderClientEnts() then
			
				ent.RearMezhvag:Remove() 
			else
				if IsValid(ent.RearMezhvag.CoupledTrain) then
				
					local ent2 = ent.RearMezhvag.CoupledTrain
					local front2 = ent.RearMezhvag.CoupledTrainFront
					
					local a = 1
					local r = "x"
					if front2 then a = -1 r = "y" end
					
					local dist = ent.RearMezhvag:WorldToLocal(ent2:LocalToWorld(Vector(TMPT[ent2:GetClass()][r]-OBP*a,0,TMPT[ent2:GetClass()].z))) 
					ent.RearMezhvag:ManipulateBonePosition(0,dist) 

					local ang1 = ent.RearMezhvag:WorldToLocalAngles(ent2:LocalToWorldAngles(Angle(0,-90*a,0)))
					local ang = Angle(-ang1.r,ang1.y,ang1.p)
					ent.RearMezhvag:ManipulateBoneAngles(0,ang)
				else
					ent.RearMezhvag:Remove()
				end
			end
		end
		
		if IsValid(ent.FrontMezhvag) then
		
			if not IsValid(ent.FrontMezhvag:GetParent()) or not ent:ShouldRenderClientEnts() then
			
				ent.FrontMezhvag:Remove() 
			else
				if IsValid(ent.FrontMezhvag.CoupledTrain) then

					local ent2 = ent.FrontMezhvag.CoupledTrain
					local front2 = ent.FrontMezhvag.CoupledTrainFront

					local a = 1
					local r = "x"
					if front2 then a = -1 r = "y" end
					
					local dist = ent.FrontMezhvag:WorldToLocal(ent2:LocalToWorld(Vector(TMPT[ent2:GetClass()][r]-OBP*a,0,TMPT[ent2:GetClass()].z)))
					ent.FrontMezhvag:ManipulateBonePosition(0,dist)

					local ang1 = ent.FrontMezhvag:WorldToLocalAngles(ent2:LocalToWorldAngles(Angle(0,-90*a,0)))
					local ang = Angle(-ang1.r,ang1.y,ang1.p)
					ent.FrontMezhvag:ManipulateBoneAngles(0,ang)
				else
					ent.FrontMezhvag:Remove()
				end
			end
		end
	end
	
	hook.Add("EntityRemoved","MezhvagsRemove",function(ent)
		if IsValid(ent.RearMezhvag) then ent.RearMezhvag:Remove() end
		if IsValid(ent.FrontMezhvag) then ent.FrontMezhvag:Remove() end
	end)
end

--MsgC(Color(0,255,0),"Metrostroi: Mezhvag system loaded!\n")