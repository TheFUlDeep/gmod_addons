if CLIENT then return end

local function SignalCommand(route)
	for _,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(v) or not v.SayHook then continue end
		v:SayHook(nil,route)
	end
end

local function SpawnButton(name,pos,ang,model,SignalCommands,switchnames,switchstates)
	local button =  ents.Create("gmod_button")
	button.Name = name
	button.Type = "button for metrostroi"
	button:SetPos(pos)
	button:SetAngles(ang or Angle(0,0,0))
	button:SetModel(model or "models/dav0r/buttons/button.mdl" )
	button.SignalCommands = SignalCommands
	button.switchnames = switchnames
	button.switchstates = switchstates
	button:SetUseType(SIMPLE_USE)
	button:Spawn()

	button.Use = function(self,activator,caller,useType,value)
		if useType ~= USE_ON then return end

		if self.SignalCommands and istable(self.SignalCommands) then for _,v in pairs(self.SignalCommands) do SignalCommand(v) end end

		if self.switchnames and istable(self.switchnames) and self.switchstates and istable(self.switchstates) and #self.switchnames == #self.switchnames then 
			for k,v in pairs(self.switchnames) do 
				if not self.switchstates[k] then continue end
				for _,swhitch in pairs(ents.FindByName(v)) do
					if not IsValid(swhitch) or not swhitch.Fire then continue end
					swhitch:Fire(self.switchstates[k],"","0")
				end
			end 
		end
	end
end


--[[for _,ent in pairs(ents.FindByClass("gmod_button")) do
	if not IsValid(ent) or not ent.Type or ent.Type ~= "button for metrostroi" then continue end
	ent:Remove()
end

for _,ply in pairs(player.GetHumans()) do
	SpawnButton("asd",ply:EyePos(),nil,nil,{"!sopen PE-OB3"})
	SpawnButton("asd",ply:EyePos()+Vector(10,0,0),nil,nil,{"!sclose PE-OB3"})
end]]