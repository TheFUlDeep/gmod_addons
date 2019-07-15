if CLIENT then return end

local TrainOnSwitch = Sound("thefuldeeps_sounds/train_on_switch.mp3")

local Props = {}

hook.Add("Initialize","Получить пропы остряков",function()
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(Props,1,v)
			v.OldSwitchState = v:GetInternalVariable("m_eDoorState") or 0
		end
	end
end)

timer.Create("CheckSwitchesState",2,0,function()
	for k,v in pairs(Props) do
		if not IsValid(v) then continue end
		local State =  v:GetInternalVariable("m_eDoorState") or 0
		if v.OldSwitchState == State or v.OldSwitchState == 3 and State == 0 or v.OldSwitchState == 1 and State == 2 then 
			v.OldSwitchState = State 
			continue 
		else
			v.OldSwitchState = State 
		end
		local NearEnts = ents.FindInSphere(v:GetPos(), 50)
		for k1,v1 in pairs(NearEnts) do
			if not IsValid(v1) then continue end
			local Class = v1:GetClass()
			for k2,v2 in pairs(Metrostroi.TrainClasses) do
				if v2 == Class then
					sound.Play(TrainOnSwitch, v:GetPos(), 100, 100, 1)
					break
				end
			end
		end
	end
end)


