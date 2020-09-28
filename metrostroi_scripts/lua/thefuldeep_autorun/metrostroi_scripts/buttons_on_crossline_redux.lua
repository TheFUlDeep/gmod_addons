if CLIENT then return end

if not game.GetMap() or not game:GetMap():find("gm_metro_crossline_r199h",1,true) then return end

local function SignalCommand(route,Signals)
	if not Signals or not istable(Signals) then Signals = ents.FindByClass("gmod_track_signal") end
	for _,v in pairs(Signals) do
		if IsValid(v) and v.SayHook then v:SayHook(route,route) end
	end
end

local function FindSignalsWithRoute(command)
	if not command then return end
	local Signals = {}
	command = command:sub(8,-1):upper()
	for _,signal in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(signal) or not signal.Routes then continue end
		for _,route in pairs(signal.Routes) do
			if route.RouteName and command == route.RouteName and not table.HasValue(Signals,signal)then table.insert(Signals,1,signal) end
		end
	end
	
	return #Signals > 0 and Signals
end

local function MoveButton(but,vec)
	but:SetPos(but:LocalToWorld(vec))
end

local Buttons = {}

local function SpawnButton(name,pos,ang,model,modelscale,SignalCommands,switchnames,switchstates,LightOnValues)
	local button =  ents.Create("gmod_button")
	if not IsValid(button) then return end
	button.Name = name
	button.Type = "button for metrostroi on crossline redux"
	button:SetPos(pos)
	button:SetAngles(ang or angle_zero)
	button:SetModel(model or "models/maxofs2d/button_05.mdl" )
	--button:SetModel(model or "models/station/disp_sigment_1.mdl" )
	button:SetModelScale(modelscale or 1)
	button.SignalCommands = SignalCommands

	if SignalCommands and istable(SignalCommands) then	--ищу все светофоры из списка мрашрутов
		local Signals = {}
		for _,command in pairs(SignalCommands) do
			command = command:sub(8,-1):upper()
			for _,signal in pairs(ents.FindByClass("gmod_track_signal")) do
				if not IsValid(signal) or not signal.Routes then continue end
				if command == signal.Name and not table.HasValue(Signals,signal)then table.insert(Signals,1,signal) end
				for _,route in pairs(signal.Routes) do
					if route.RouteName and command == route.RouteName and not table.HasValue(Signals,signal)then table.insert(Signals,1,signal) end
				end
			end
		end
		button.Signals = #Signals > 0 and Signals
	end


	button.switchnames = switchnames

	if switchnames and istable(switchnames) then	--ищу все остряки
		local Switches = {}
		for k,switchname in pairs(switchnames) do
			local Swhs = ents.FindByName(switchname)
			if not Swhs then continue end
			for i,swh in pairs(Swhs) do
				if not IsValid(swh) or swh:GetClass() ~= "prop_door_rotating" then table.remove(Swhs,i) end
			end
			Switches[k] = Swhs
		end
		button.Switches = table.Count(Switches) > 0 and Switches
	end

	button.switchstates = switchstates
	button.LightOnValues = LightOnValues
	button:SetUseType(SIMPLE_USE)
	button:SetLabel(name)
	button:SetCollisionGroup(COLLISION_GROUP_NONE)
	button:SetPersistent(true)
	button:Spawn()
	
	button:SetMoveType(MOVETYPE_NONE)

	button.Use = function(self,activator,caller,useType,value)
		if useType ~= USE_ON then return end
		
		sound.Play("buttons/blip1.wav", button:LocalToWorld(button:OBBCenter()), 120, 100, 1)

		if self.Signals then for _,v in pairs(self.SignalCommands) do SignalCommand(v,self.Signals) end end

		if self.Switches and self.switchnames and istable(self.switchnames) and self.switchstates and istable(self.switchstates) and #self.switchnames == #self.switchnames then 
			for k,v in pairs(self.switchnames) do 
				if not self.switchstates[k] or not self.Switches[k] then continue end
				for _,swhitch in pairs(self.Switches[k]) do
					if IsValid(swhitch) and swhitch.Fire then swhitch:Fire(self.switchstates[k],"","0") end
				end
			end 
		end
	end
	
	button.DefaultColor = button:GetColor()
	table.insert(Buttons,1,button)
	return button
end

local function SpawnButtons()
	print("Spawning buttons...")
	for _,ent in pairs(ents.FindByClass("gmod_button")) do
		if IsValid(ent) and ent.Type == "button for metrostroi on crossline redux" then ent:Remove() end
	end
	
	--международная
	local vec = Vector(268-200, 1654+15, 1892-30)
	local flat = -37
	local he = -14
	local ang = Angle(90,45,0)
	local button = SpawnButton(
		'2 -> 2 (в тупик)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD2-2"},
		{"trackswitch_md2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(-5+he,-5+5+5,flat))

	button = SpawnButton(
		'2 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD2-3"},
		{"trackswitch_md2","trackswitch_md4","trackswitch_md5"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(-5+he,-5,flat))

	button = SpawnButton(
		'2 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD2-4"},
		{"trackswitch_md2","trackswitch_md4","trackswitch_md6"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(-5+he,-5+5,flat))

	button = SpawnButton(
		'3 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD3-1"},
		{"trackswitch_md5","trackswitch_md3","trackswitch_md1"},
		{"Close","Open","Open"},
		{0,1,1}
	)
	MoveButton(button,Vector(0+he,-5,flat))

	button = SpawnButton(
		'3 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD3-2"},
		{"trackswitch_md5","trackswitch_md4","trackswitch_md2"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(0+he,-5+5,flat))

	button = SpawnButton(
		'4 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD4-1"},
		{"trackswitch_md6","trackswitch_md3","trackswitch_md1"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(-5+5+he,-5+5+5,flat))

	button = SpawnButton(
		'4 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD4-2"},
		{"trackswitch_md6","trackswitch_md4","trackswitch_md2"},
		{"Close","Open","Open"},
		{0,1,1}
	)
	MoveButton(button,Vector(-5+5+he,-5+5+5+5,flat))

	button = SpawnButton(
		'Сброс',
		vec,
		ang,
		nil,--"models/dav0r/buttons/button.mdl",
		0.2,
		nil,
		{"trackswitch_md2","trackswitch_md4","trackswitch_md3","trackswitch_md1","trackswitch_md6","trackswitch_md5"},
		{"Close","Close","Close","Close","Close","Close"},
		{0,0,0,0,0,0}
	)
	MoveButton(button,Vector(8+he,22,flat))

	button = SpawnButton(
		'2+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5*3+he,-42.5,flat))

	button = SpawnButton(
		'2-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md2"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8-5*2+he,-42.5,flat))

	button = SpawnButton(
		'1-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md1"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8+he,-42.5,flat))

	button = SpawnButton(
		'1+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5+he,-42.5,flat))

	button = SpawnButton(
		'4+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md4"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5*3+he,-42.5-10,flat))

	button = SpawnButton(
		'4-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md4"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8-5*2+he,-42.5-10,flat))

	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5*1+he,-42.5-10,flat))

	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8-5*0+he,-42.5-10,flat))

	button = SpawnButton(
		'6+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md6"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5*3+he,-42.5-10*2,flat))

	button = SpawnButton(
		'6-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md6"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8-5*2+he,-42.5-10*2,flat))

	button = SpawnButton(
		'5+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md5"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(8-5*1+he,-42.5-10*2,flat))

	button = SpawnButton(
		'5-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_md5"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(8-5*0+he,-42.5-10*2,flat))
	
	button = SpawnButton(
		'1 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD1-3"},
		{"trackswitch_md5","trackswitch_md3","trackswitch_md1"},
		{"Close","Open","Open"},
		{0,1,1}
	)
	MoveButton(button,Vector(5*1+he,5*0,flat))
	
	button = SpawnButton(
		'1 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD1-4"},
		{"trackswitch_md6","trackswitch_md3","trackswitch_md1"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(5*1+he,5*1,flat))
	
	button = SpawnButton(		--эта кнопка не загорится, так как есть несколько светофоров D. А еще светофор откроется только если во время нажатия кнопки стрелки уже были в нужном положении
		'1 -> 1 (в тупик)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen D"},
		{"trackswitch_md1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*1+he,5*-1,flat))
	
	button = SpawnButton(
		'1 -> 1 (из тупика)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD1-1"},
		{"trackswitch_md1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*-1,flat))
	
	button = SpawnButton(
		'2 -> 2 (из тупика)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen MD6-2"},
		{"trackswitch_md2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*0,flat))
	
	--политехническая
	vec = Vector(13839.784180+50, -1569.711060, 3016.301514)
	ang = Angle(90,90,0)
	flat = -87
	he = 15
	
	button = SpawnButton(
		'1+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(0+he,0,0+flat))

	button = SpawnButton(
		'1-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt1"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,0,0+flat))	

	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*1,0+flat))	

	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*1,0+flat))		
	
	button = SpawnButton(
		'2+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*2,0+flat))	
	
	button = SpawnButton(
		'2-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt2"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*2,0+flat))
	
	button = SpawnButton(
		'1 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT1-1"},
		{"trackswitch_pt1","trackswitch_pt3"},
		{"Close","Close"},
		{0,0}
	)
	MoveButton(button,Vector(5*0+he,5*7,0+flat))	
	
	button = SpawnButton(
		'1 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT1-3"},
		{"trackswitch_pt1","trackswitch_pt3"},
		{"Close","Open"},
		{0,1}
	)
	MoveButton(button,Vector(5*0+he,5*8,0+flat))

	button = SpawnButton(
		'2 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT2-1"},
		{"trackswitch_pt2","trackswitch_pt1","trackswitch_pt3"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(5*1+he,5*7,0+flat))	
	
	button = SpawnButton(
		'2 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT2-3"},
		{"trackswitch_pt2","trackswitch_pt1","trackswitch_pt3"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*1+he,5*8,0+flat))	
	
	button = SpawnButton(
		'2 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT2-2"},
		{"trackswitch_pt2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*8,0+flat))
	
	button = SpawnButton(
		'1 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT1-2"},
		{"trackswitch_pt3","trackswitch_pt1","trackswitch_pt2"},
		{"Close","Open","Open"},
		{0,1,1}
	)
	MoveButton(button,Vector(5*2+he,5*7,0+flat))
	
	button = SpawnButton(
		'3 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT3-1"},
		{"trackswitch_pt3","trackswitch_pt1"},
		{"Open","Close"},
		{1,0}
	)
	MoveButton(button,Vector(5*0+he,5*10,0+flat))
	
	button = SpawnButton(
		'3 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen PT3-2"},
		{"trackswitch_pt3","trackswitch_pt1","trackswitch_pt2"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*0+he,5*11,0+flat))
	
	button = SpawnButton(
		'Cброс',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_pt3","trackswitch_pt1","trackswitch_pt2"},
		{"Close","Close","Close"},
		{0,0,0}
	)
	MoveButton(button,Vector(5*3+he,5*13,0+flat))
	
	--октябрьская
	vec = Vector(1660.113159, -4964.553711, -275.156738)
	ang = Angle(90,90+45,0)
	flat = -81.5
	he = -20
	local g = -0
	
	button = SpawnButton(
		'1+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'1-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok1"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'2+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'2-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok2"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'4+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok4"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'4-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok4"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*3+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*3+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'6+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok6"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'6-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok6"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*5+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'5+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok5"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'5-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok5"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*5+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'1 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK1-4"},
		{"trackswitch_ok1","trackswitch_ok3","trackswitch_ok6"},
		{"Open","Close","Close"},
		{1,0,0}
	)
	MoveButton(button,Vector(5*1+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'1 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK1-3"},
		{"trackswitch_ok1","trackswitch_ok3","trackswitch_ok5"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*1+he,5*5+g,0+flat))
	
	button = SpawnButton(
		'1 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK1-1"},
		{"trackswitch_ok1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*1+he,5*6+g,0+flat))
	
	button = SpawnButton(
		'2 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK2-2"},
		{"trackswitch_ok2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'2 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK2-4"},
		{"trackswitch_ok2","trackswitch_ok4","trackswitch_ok6"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*2+he,5*5+g,0+flat))
	
	button = SpawnButton(
		'2 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK2-3"},
		{"trackswitch_ok2","trackswitch_ok4","trackswitch_ok5"},
		{"Open","Close","Close"},
		{1,0,0}
	)
	MoveButton(button,Vector(5*2+he,5*6+g,0+flat))
	
	button = SpawnButton(
		'4 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK4-1"},
		{"trackswitch_ok1","trackswitch_ok3","trackswitch_ok6"},
		{"Open","Close","Close"},
		{1,0,0}
	)
	MoveButton(button,Vector(5*3+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'4 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK4-2"},
		{"trackswitch_ok2","trackswitch_ok4","trackswitch_ok6"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*3+he,5*5+g,0+flat))
	
	button = SpawnButton(
		'3 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK3-1"},
		{"trackswitch_ok1","trackswitch_ok3","trackswitch_ok5"},
		{"Open","Open","Open"},
		{1,1,1}
	)
	MoveButton(button,Vector(5*4+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'3 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OK3-2"},
		{"trackswitch_ok2","trackswitch_ok4","trackswitch_ok5"},
		{"Open","Close","Close"},
		{1,0,0}
	)
	MoveButton(button,Vector(5*4+he,5*5+g,0+flat))
	
	button = SpawnButton(
		'Сброс',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ok1","trackswitch_ok2","trackswitch_ok3","trackswitch_ok4","trackswitch_ok5","trackswitch_ok6"},
		{"Close","Close","Close","Close","Close","Close"},
		{0,0,0,0,0,0}
	)
	MoveButton(button,Vector(5*5+he,5*9+g,0+flat))
	
	--речная
	vec = Vector(3712.581787, -14028.981445, 381.656250)
	ang = Angle(90,90+70,0)
	flat = -70
	he = -0
	g = -30
	
	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_rx3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_rx3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*0+g,0+flat))
	
	button = SpawnButton(
		'4+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_rx4"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'4-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_rx4"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*1+he,5*-1+g,0+flat))
	
	button = SpawnButton(
		'2 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen RX2-1"},
		{"trackswitch_rx3","trackswitch_rx4"},
		{"Open","Open"},
		{1,1}
	)
	MoveButton(button,Vector(5*0+he,5*3+g,0+flat))
	
	button = SpawnButton(
		'1 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen RX1-1"},
		{"trackswitch_rx3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*0+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'1 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen RX1-2"},
		{"trackswitch_rx3","trackswitch_rx4"},
		{"Open","Open"},
		{1,1}
	)
	MoveButton(button,Vector(5*1+he,5*3+g,0+flat))
	
	button = SpawnButton(
		'2 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen RX2-2"},
		{"trackswitch_rx4"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*1+he,5*4+g,0+flat))
	
	button = SpawnButton(
		'Сброс',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_rx3","trackswitch_rx4"},
		{"Close","Close"},
		{0,0}
	)
	MoveButton(button,Vector(5*2+he,5*7+g,0+flat))
	
	
	--олимпийская
	vec = Vector(4120.740234, -7708.735840, -1400.089844)
	ang = Angle(90,-54,0)
	flat = -71.8
	he = -11
	g = -100
	
	button = SpawnButton(
		'1+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*7+g,0+flat))
	
	button = SpawnButton(
		'1-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol1"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*3+he,5*7+g,0+flat))
	
	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*8+g,0+flat))
	
	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*3+he,5*8+g,0+flat))
	
	button = SpawnButton(
		'2+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*6+g,0+flat))
	
	button = SpawnButton(
		'2-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol2"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*3+he,5*6+g,0+flat))
	
	button = SpawnButton(
		'1 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL1-1"},
		{"trackswitch_ol1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*2+he,5*11+g,0+flat))
	
	button = SpawnButton(
		'1 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL1-3"},
		{"trackswitch_ol1","trackswitch_ol3"},
		{"Open","Open"},
		{1,1}
	)
	MoveButton(button,Vector(5*2+he,5*12+g,0+flat))
	
	button = SpawnButton(
		'3 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL3-1"},
		{"trackswitch_ol1","trackswitch_ol3"},
		{"Open","Open"},
		{1,1}
	)
	MoveButton(button,Vector(5*3+he,5*11+g,0+flat))
	
	button = SpawnButton(
		'3 -> 2 (2 -> 3)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL3-2"},
		{"trackswitch_ol2","trackswitch_ol3"},
		{"Open","Close"},
		{1,0}
	)
	MoveButton(button,Vector(5*3+he,5*12+g,0+flat))
	
	button = SpawnButton(
		'2 -> 3 (3 -> 2)',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL3-2"},
		{"trackswitch_ol2","trackswitch_ol3"},
		{"Open","Close"},
		{1,0}
	)
	MoveButton(button,Vector(5*4+he,5*12+g,0+flat))
	
	button = SpawnButton(
		'2 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen OL2-2"},
		{"trackswitch_ol2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*11+g,0+flat))
	
	button = SpawnButton(
		'Cсброс',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ol2","trackswitch_ol3","trackswitch_ol1"},
		{"Close","Close","Close"},
		{0,0,0}
	)
	MoveButton(button,Vector(5*4.5+he,5*15+g,0+flat))
	
	
	--TODO молодежная
	vec = Vector(-9684.206055, 3160.464600, -2403.028809)
	ang = Angle(90,-30,0)
	flat = -38.8
	he = -30
	g = -0
	
	button = SpawnButton(
		'1+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'1-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml1"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*5+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'2+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'2-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml2"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*5+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'4+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml4"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*6+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'4-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml4"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*7+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'6+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml6"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*8+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'6-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml6"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*9+he,5*14+g,0+flat))
	
	button = SpawnButton(
		'3+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml3"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*6+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'3-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml3"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*7+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'5+',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml5"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*8+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'5-',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml5"},
		{"Open"},
		{1}
	)
	MoveButton(button,Vector(5*9+he,5*15+g,0+flat))
	
	button = SpawnButton(
		'1 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML1-4"},
		{"trackswitch_ml1","trackswitch_ml3","trackswitch_ml6"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(5*4+he,5*20+g,0+flat))
	
	button = SpawnButton(
		'1 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML1-3"},
		{"trackswitch_ml1","trackswitch_ml3","trackswitch_ml5"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(5*4+he,5*21+g,0+flat))
	
	button = SpawnButton(
		'1 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML1-1"},
		{"trackswitch_ml1"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*4+he,5*22+g,0+flat))
	
	button = SpawnButton(
		'2 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML2-2"},
		{"trackswitch_ml2"},
		{"Close"},
		{0}
	)
	MoveButton(button,Vector(5*5+he,5*20+g,0+flat))
	
	button = SpawnButton(
		'2 -> 4',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML2-4"},
		{"trackswitch_ml2","trackswitch_ml4","trackswitch_ml6"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(5*5+he,5*21+g,0+flat))
	
	button = SpawnButton(
		'2 -> 3',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML2-3"},
		{"trackswitch_ml2","trackswitch_ml4","trackswitch_ml5"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(5*5+he,5*22+g,0+flat))
	
	button = SpawnButton(
		'4 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML4-1"},
		{"trackswitch_ml1","trackswitch_ml3","trackswitch_ml6"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(5*6+he,5*20+g,0+flat))
	
	button = SpawnButton(
		'4 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML4-2"},
		{"trackswitch_ml2","trackswitch_ml4","trackswitch_ml6"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(5*6+he,5*21+g,0+flat))
	
	button = SpawnButton(
		'3 -> 1',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML3-1"},
		{"trackswitch_ml1","trackswitch_ml3","trackswitch_ml5"},
		{"Open","Open","Close"},
		{1,1,0}
	)
	MoveButton(button,Vector(5*7+he,5*20+g,0+flat))
	
	button = SpawnButton(
		'3 -> 2',
		vec,
		ang,
		nil,
		0.2,
		{"!sopen ML3-2"},
		{"trackswitch_ml2","trackswitch_ml4","trackswitch_ml5"},
		{"Open","Close","Open"},
		{1,0,1}
	)
	MoveButton(button,Vector(5*7+he,5*21+g,0+flat))
	
	button = SpawnButton(
		'Сброс',
		vec,
		ang,
		nil,
		0.2,
		nil,
		{"trackswitch_ml2","trackswitch_ml4","trackswitch_ml5","trackswitch_ml1","trackswitch_ml3","trackswitch_ml6"},
		{"Close","Close","Close","Close","Close","Close"},
		{0,0,0,0,0,0}
	)
	MoveButton(button,Vector(5*9+he,5*26+g,0+flat))
	
	--TODO депо
end


if not Metrostroi then Metrostroi = {} end

local SwitchProps = {}
timer.Simple(0,function()
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(SwitchProps,1,v)
			v.OldSwitchState2 = v:GetInternalVariable("m_eDoorState") or 0
		end
	end
	
	SpawnButtons()

	local concommandTbl = concommand.GetTable()
	local MetrostroiLoadFunction = concommandTbl.metrostroi_load
	if not Metrostroi.metrostroi_load_for_crossline_rexus_overrided then
		print("overriding metrostroi_load")
		Metrostroi.metrostroi_load_for_crossline_rexus_overrided = true
		concommandTbl.metrostroi_load = function(ply,_,args)
			if IsValid(ply) and not ply:IsAdmin() then return end
			timer.Simple(2,SpawnButtons)
			MetrostroiLoadFunction(ply,_,args)
		end
	end
end)

hook.Add("PlayerInitialSpawn","Получить пропы остряков и заспавнить кнопки для кросслайна редукс",function() --при определении положения остаряков добавляю двойки, потому что у меня еще один аддон на определение положения остряков
	hook.Remove("PlayerInitialSpawn","Получить пропы остряков и заспавнить кнопки для кросслайна редукс")
	print("сохраняю остряки")
	SwitchProps = {}
	for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
		if not IsValid(v) then continue end
		local Name = v:GetName()
		if Name:find("swit") or Name:find("swh") then
			table.insert(SwitchProps,1,v)
			v.OldSwitchState2 = v:GetInternalVariable("m_eDoorState") or 0
		end
	end
	
	timer.Simple(4,SpawnButtons)

	local concommandTbl = concommand.GetTable()
	local MetrostroiLoadFunction = concommandTbl.metrostroi_load
	if not Metrostroi.metrostroi_load_for_crossline_rexus_overrided then
		print("overriding metrostroi_load")
		Metrostroi.metrostroi_load_for_crossline_rexus_overrided = true
		concommandTbl.metrostroi_load = function(ply,_,args)
			if IsValid(ply) and not ply:IsAdmin() then return end
			timer.Simple(2,SpawnButtons)
			MetrostroiLoadFunction(ply,_,args)
		end
	end
	
end)

local function SetDefaultColor(button)
	local color = button:GetColor()
	local defcolor = button.DefaultColor
	if color.a ~= defcolor.a or color.r ~= defcolor.r or color.g ~= defcolor.g or color.b ~= defcolor.b then
		button:SetColor(defcolor)
	end
end

timer.Create("CheckSwitchesState and buttons on crossline redux",3,0,function()
	for k,v in pairs(SwitchProps) do
		if not IsValid(v) then continue end
		local State =  v:GetInternalVariable("m_eDoorState") or 0
		if v.OldSwitchState2 == State or v.OldSwitchState2 == 3 and State == 0 or v.OldSwitchState2 == 1 and State == 2 then 
			v.OldSwitchState2 = State 
			continue 
		else
			v.OldSwitchState2 = State 
		end		
	end
	
	for k,button in pairs(Buttons) do
		if not IsValid(button) --[[or button.Type ~= "button for metrostroi on crossline redux" or not button.Name]] then continue end --закомментил, потому что все кнопки, по которым я прохожусь - это мои кнопки
		local NeedContinue
		if button.switchnames and button.LightOnValues and #button.switchstates == #button.LightOnValues then
			local Switches = button.Switches
			for i,swhname in pairs(button.switchnames) do
				local SwhEnts = Switches and Switches[i]
				if not SwhEnts or table.Count(SwhEnts) < 1 then NeedContinue = true break end
				for _,swhent in pairs(SwhEnts) do
					if not swhent.OldSwitchState2 then NeedContinue = true break end
					if button.LightOnValues[i] == 0 then
						if swhent.OldSwitchState2 ~= 0 and swhent.OldSwitchState2 ~= 3 then NeedContinue = true break end--уточнить эти значения
					elseif button.LightOnValues[i] == 1 then
						if swhent.OldSwitchState2 ~= 1 and swhent.OldSwitchState2 ~= 2 then NeedContinue = true break end--уточнить эти значения
					else
						NeedContinue = true
					end
				end
			end
		end
		if button.SignalCommands then
			local Signals = button.Signals
			for _,command in pairs(button.SignalCommands) do
				if not Signals then NeedContinue = true break end				
				for _,signal in pairs(Signals) do
					if signal.Red and not signal.InvationSignal then NeedContinue = true break end
				end
			end
		end
		
		if NeedContinue then SetDefaultColor(button) continue end
		
		local color = button:GetColor()
		if color.r ~= 255 or color.g ~= 255 or color.b ~= 0 or color.a ~= 0 then
			button:SetColor(Color(255,255,0,0))
		end
	end
	
end)

--[[for _,ply in pairs(player.GetHumans()) do
	print(ply:GetEyeTrace().Entity:GetName())
	--SpawnButton("asd",ply:EyePos(),nil,nil,{"!sopen PE-OB3"})
	--SpawnButton("asd",ply:EyePos()+Vector(10,0,0),nil,nil,{"!sclose PE-OB3"})
	--ply:SetPos(button:GetPos())
	print(ply:EyePos())
end]]
local TheFulDeep = player.GetBySteamID("STEAM_0:1:37134658")

TheFulDeep:ChatPrint(TheFulDeep:GetEyeTrace().Entity:GetName())
TheFulDeep:ChatPrint(tostring(TheFulDeep:EyePos()))