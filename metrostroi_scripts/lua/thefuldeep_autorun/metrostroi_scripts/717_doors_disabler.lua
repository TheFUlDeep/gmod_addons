hook.Add("InitPostEntity","Metrostroi 717 doors disabling",function()
-- timer.Simple(0,function()
	local mathClamp = math.Clamp
	
	local buttons = {
		"DoorL1ManualOpen",
		"DoorL2ManualOpen",
		"DoorL3ManualOpen",
		"DoorL4ManualOpen",
		"DoorL1ManualClose",
		"DoorL2ManualClose",
		"DoorL3ManualClose",
		"DoorL4ManualClose",
		"DoorR1ManualOpen",
		"DoorR2ManualOpen",
		"DoorR3ManualOpen",
		"DoorR4ManualOpen",
		"DoorR1ManualClose",
		"DoorR2ManualClose",
		"DoorR3ManualClose",
		"DoorR4ManualClose"
	}		
	local buttonsnames = {}
	for _,name in pairs(buttons)do
		buttonsnames[name] = true
	end
	
	local blockbuttons = {
		--левые
		BlockDoor1=true,
		BlockDoor2=true,
		BlockDoor3=true,
		BlockDoor4=true,
		--правые
		BlockDoor5=true,
		BlockDoor6=true,
		BlockDoor7=true,
		BlockDoor8=true
	}
	
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if not NOMER_CUSTOM then return else NOMER_CUSTOM = NOMER_CUSTOM.t end
	table.insert(NOMER_CUSTOM.Spawner,9,{"DoorsDisabler","Выключатель дверей","Boolean"})
	
	for i = 1,2 do
		local class = i == 1 and "gmod_subway_81-717_mvm" or "gmod_subway_81-714_mvm"
		local NOMER = scripted_ents.GetStored(class).t
			
		if SERVER then
			local blockSounsds = {}
			-- local minpressure = 0.2
			-- local maxmanualspeed = 200
			-- local maxplressure = 7.5
			for a = 1,4 do
				for b = 1,2 do
					for c = 1,2 do
						local str = "subway_trains/717/switches/button"..a..(b==1 and "_on" or "_off")..c..".mp3"
						-- util.PrecacheSound(str)
						table.insert(blockSounsds,str)
					end
				end
			end
		
			local oldinit = NOMER.Initialize
			NOMER.Initialize = function(self,...)
				oldinit(self,...)
				-- local oldsounds = self.InitializeSounds
				-- self.InitializeSounds = function(wag,...)
					-- oldsounds(wag,...)
					-- wag.SoundNames["BlockDoor"] = blockSounsds
					-- for name in pairs(blockbuttons)do
						-- local k = tonumber(name:sub(-1))
						-- wag.SoundPositions[name] = {60,1e9,Vector((k > 4 and 5 or 20+230*3)+(k < 5 and 1-k or k-5)*230,k < 5 and 61 or -61,30),1}
					-- end
				-- end
				
				self.PrevsDoorsStates = {}
				self.DoorsBlocked = {}
				local oldpneumo = self.Pneumatic.Think
				self.Pneumatic.Think = function(sys,...)
					oldpneumo(sys,...)
					local wag = sys.Train
					if wag:GetNW2Bool("DoorsDisabler") then
						--print(wag:GetNW2Bool("DoorL"),wag:GetNW2Bool("DoorR"))--true, если открыты
						--0 закрыты, 500 открыты
						-- local TrainLinePressure = sys.TrainLinePressure
						local CurTime = CurTime()
						local DoorsDisabled1 = wag:GetNW2Bool("DoorsDisabled1")
						local DoorsDisabled2 = wag:GetNW2Bool("DoorsDisabled2")
						local DoorsDisabled0 = wag:GetNW2Bool("DoorsDisabled0")
						local openedL
						local openedR
						local prevs = wag.PrevsDoorsStates
						-- local manualspeed = maxmanualspeed - mathClamp(maxmanualspeed*(TrainLinePressure/maxplressure),0,maxmanualspeed)
						for k,bname in pairs(buttons)do
							local n = (k+3)%4+1
							local isleft = k < 9
							local str = "Door"..(isleft and "L" or "R")..n
							if wag.DoorsBlocked[n + (isleft and 0 or 4)] then
								wag:SetNW2Float(str,0)
							else
								local DoorsDisabled = --[[TrainLinePressure < minpressure or]] isleft and DoorsDisabled1 or not isleft and DoorsDisabled2 or (k == 9 or k == 13) and DoorsDisabled0
								if wag[bname] then
									--								startvalue																len		  					speed						isopeinig		
									wag:SetNW2Float(str,mathClamp((DoorsDisabled and prevs[str] or wag:GetNW2Float(str,0))+(not DoorsDisabled and (CurTime-wag[bname])*250--[[+manualspeed]] or 50)*((k < 5 or k > 8 and k < 13) and 1 or -1),0,500))
								elseif DoorsDisabled then
									wag:SetNW2Float(str,mathClamp(prevs[str] or wag:GetNW2Float(str,1),1,500))
								end
							end
							local val = wag:GetNW2Float(str,0)
							if val ~= 0 then
								if k < 9 then
									openedL = true
								else
									openedR = true
								end
							end
							prevs[str] = val
						end
						if openedL then 
							wag:SetNW2Bool("DoorL",true)
						end
						if openedR then 
							wag:SetNW2Bool("DoorR",true)
						end
						if openedL or openedR then
							wag.BD:TriggerInput("Set",false)
						end
					end
					
				end
			end
			
			local oldpress = NOMER.OnButtonPress
			NOMER.OnButtonPress = function(self,button,...)
				if buttonsnames[button] then
					self[button] = CurTime()
				end
				if button == "DisableDoors1" then self:SetNW2Bool("DoorsDisabled1",not self:GetNW2Bool("DoorsDisabled1"))
				elseif button == "DisableDoors2" then self:SetNW2Bool("DoorsDisabled2",not self:GetNW2Bool("DoorsDisabled2"))
				elseif button == "DisableDoors0" then self:SetNW2Bool("DoorsDisabled0",not self:GetNW2Bool("DoorsDisabled0"))
				end
				
				if blockbuttons[button] then
					local n = tonumber(button:sub(-1))
					local isleft = n < 5
					--если дверь заблокирована или не заблокирована и прикрыта, то получится нажат
					if self.DoorsBlocked[n] or not self.DoorsBlocked[n] and self:GetNW2Float("Door"..(isleft and "L" or "R")..(isleft and n or n-4),0) < 10 then
						self.DoorsBlocked[n] = not self.DoorsBlocked[n]
						-- self:PlayOnce("BlockDoor",button,0.7)
						-- EmitSound(
							-- "subway_trains/717/switches/button"..math.random(4)..(math.random(2)==1 and "_on" or "_off")..math.random(2)..".mp3",
							-- Vector(500,0,0),
							-- self:EntIndex()--,
							-- -- nil,--chan
							-- -- 1,--vol
							-- -- 75,--sndlevel
							-- -- SND_NOFLAGS,
							-- -- 100,--pitch
							-- -- 0--dsp
						-- )
						sound.Play(
							blockSounsds[math.random(#blockSounsds)],
							self:LocalToWorld(Vector((n < 5 and 300 or 370)+(n < 5 and 1-n or 5-n)*230,n < 5 and 61 or -61,50)),
							75,--level
							100,--pitch
							0.2--vol
						)
					end
				end
				oldpress(self,button,...)
			end
			
			local oldrelease = NOMER.OnButtonRelease
			NOMER.OnButtonRelease = function(self,button,...)
				if buttonsnames[button] then
					self[button] = false
				end
				oldrelease(self,button,...)
			end
		end
		

		if CLIENT then
			for k = 1,2 do
				local add = k == 1 and "" or "Outside"
				NOMER.ButtonMap["DoorsManualLeft"..add] = {
					pos = Vector(k == 1 and -405 or 375.5,62.6,60),
					ang = Angle(0,k == 1 and 0 or 180,90),
					width = 800,
					height = 110,
					scale = 1,
					buttons = {
					}
				}
				for j = 1,4 do
					local button = NOMER.ButtonMap["DoorsManualLeft"..add].buttons
					button[#button+1] = {ID = buttons[j],x=(k == 1 and 18 or 695)+(k == 1 and 4-j or j-4)*230.2,y=10,w=70,h=50,tooltip=""}
					button[#button+1] = {ID = buttons[j+4],x=(k == 1 and 18 or 695)+(k == 1 and 4-j or j-4)*230.2,y=60,w=70,h=50,tooltip=""}
				end
				
				NOMER.ButtonMap["DoorsManualRight"..add] = {
					pos = Vector(k == 1 and 375.5 or -405,-62.6,60),
					ang = Angle(0,k == 1 and 180 or 0,90),
					width = 800,
					height = 110,
					scale = 1,
					buttons = {
					}
				}
				for j = 9,12 do
					local button = NOMER.ButtonMap["DoorsManualRight"..add].buttons
					button[#button+1] = {ID = buttons[j],x=(k == 1 and 1 or 710)+(k == 1 and j-9 or 9-j)*230.2,y=10,w=70,h=50,tooltip=""}
					button[#button+1] = {ID = buttons[j+4],x=(k == 1 and 1 or 710)+(k == 1 and j-9 or 9-j)*230.2,y=60,w=70,h=50,tooltip=""}
				end
			end
			NOMER.ButtonMap["DoorsManualLeft"].buttons[#(NOMER.ButtonMap["DoorsManualLeft"].buttons)+1] = {ID = "DisableDoors1",x=1+(9.38-(i == 1 and 8.95 or 6.47))*230.2,y=40,w=20,h=20,tooltip="Выключатель дверей"}
			NOMER.ButtonMap["DoorsManualRight"].buttons[#(NOMER.ButtonMap["DoorsManualRight"].buttons)+1] = {ID = "DisableDoors2",x=1+(9.38-(i == 1 and 6.52 or 9))*230.2,y=40,w=20,h=20,tooltip="Выключатель дверей"}
			
			if i == 1 then
				NOMER.ButtonMap["DoorsManualRight"].buttons[#(NOMER.ButtonMap["DoorsManualRight"].buttons)+1] = {ID = "DisableDoors0",x=1+(9.38-9)*230.2,y=40,w=20,h=20,tooltip="Выключатель дверей"}
				NOMER.ClientProps["DoorsDisabler0"] = {
					model = "models/metrostroi_train/81-717/stop_mvm.mdl",
					pos = Vector(276,-61.6,11.5),
					ang = Angle(0,180,0),
					hideseat=0.2,
				}
			end
			
			NOMER.ClientProps["DoorsDisabler1"] = {
				model = "models/metrostroi_train/81-717/stop_mvm.mdl",
				pos = Vector((i == 1 and -295 or 276),61.6,11.5),
				ang = Angle(0,0,0),
				hideseat=0.2,
			}
			
			NOMER.ClientProps["DoorsDisabler2"] = {
				model = "models/metrostroi_train/81-717/stop_mvm.mdl",
				pos = Vector((i == 1 and -295 or 276),-61.6,11.5),
				ang = Angle(0,180,0),
				hideseat=0.2,
			}
			
			for k = 1,8 do
				local side = k < 5 and "DoorsManualLeft" or "DoorsManualRight"
				NOMER.ButtonMap[side].buttons[#(NOMER.ButtonMap[side].buttons)+1] = {ID = "BlockDoor"..k,x=(k > 4 and 5 or 20+230*3)+(k < 5 and 1-k or k-5)*230,y=5,radius=5,tooltip="Блокировка дверей"}
			end
			
			local oldthink = NOMER.Think
			NOMER.Think = function(self,...)
				local res = oldthink(self,...)
				self:Animate("DoorsDisabler1",self:GetNW2Bool("DoorsDisabled1") and 0.25 or 0, 0,1, 5,false)
				self:Animate("DoorsDisabler2",self:GetNW2Bool("DoorsDisabled2") and 0.25 or 0, 0,1, 5,false)
				if i == 1 then
					self:Animate("DoorsDisabler0",self:GetNW2Bool("DoorsDisabled0") and 0.25 or 0, 0,1, 5,false)
				end
				return res
			end
			
			local oldupdate = NOMER.UpdateWagonNumber
			NOMER.UpdateWagonNumber = function(self,...)
				oldupdate(self,...)
				local nw = not self:GetNW2Bool("DoorsDisabler")
				self:HidePanel("DoorsManualLeft",nw)
				self:HidePanel("DoorsManualRight",nw)
				self:HidePanel("DoorsManualLeftOutside",nw)
				self:HidePanel("DoorsManualRightOutside",nw)
				self:ShowHide("DoorsDisabler1",not nw)
				self:ShowHide("DoorsDisabler2",not nw)
				self:ShowHide("DoorsDisabler0",not nw)
			end
		end
	end
end)

