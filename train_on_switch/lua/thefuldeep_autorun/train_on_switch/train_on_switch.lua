if CLIENT then return end

local TrainOnSwitch = Sound("thefuldeeps_sounds/train_on_switch.mp3")

local Props = {}

local K = 100


hook.Add("PlayerInitialSpawn","Получить пропы остряков",function()
	hook.Remove("PlayerInitialSpawn","Получить пропы остряков")
	print("сохраняю остряки")
	Props = {}
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(Props,1,{ent = v, pos = v:LocalToWorld(v:OBBCenter()),max = v:LocalToWorld(v:OBBMaxs()) + Vector(0,0,K),min = v:LocalToWorld(v:OBBMins()) + Vector(0,0,-K)})
			v.OldSwitchState = v:GetInternalVariable("m_eDoorState") or 0
		end
	end
end)

	Props = {}
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(Props,1,{ent = v, pos = v:LocalToWorld(v:OBBCenter()),max = v:LocalToWorld(v:OBBMaxs()) + Vector(0,0,K),min = v:LocalToWorld(v:OBBMins()) + Vector(0,0,-K)})
			v.OldSwitchState = v:GetInternalVariable("m_eDoorState") or 0
		end
	end

timer.Create("CheckSwitchesState",2,0,function()
	for k,v in pairs(Props) do
		if not IsValid(v.ent) then continue end
		local State =  v.ent:GetInternalVariable("m_eDoorState") or 0
		if v.ent.OldSwitchState == State or v.ent.OldSwitchState == 3 and State == 0 or v.ent.OldSwitchState == 1 and State == 2 then 
			v.ent.OldSwitchState = State 
			continue 
		else
			v.ent.OldSwitchState = State 
		end
		local NearEnts = ents.FindInBox(v.max, v.min)
		local Played
		for k1,v1 in pairs(NearEnts) do
			if Played then break end
			if not IsValid(v1) then continue end
			local Class = v1:GetClass()
			for k2,v2 in pairs(Metrostroi.TrainClasses) do
				if v2 == Class then
					sound.Play(TrainOnSwitch, v.pos, 130, 100, 1)
					Played = true
					break
				end
			end
		end
	end
end)


