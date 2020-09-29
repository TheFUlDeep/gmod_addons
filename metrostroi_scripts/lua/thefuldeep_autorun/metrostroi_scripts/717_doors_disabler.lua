--TODO кнопку отключения в боковой буттон мап
--TODO промежуток
hook.Add("InitPostEntity","Metrostroi 717 doors disabling",function()
--timer.Simple(0,function()
	local mathClamp = math.Clamp
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not NOMER then return else NOMER = NOMER.t end

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
		
	if SERVER then
	
		local oldinit = NOMER.Initialize
		NOMER.Initialize = function(self,...)
			oldinit(self,...)
			local oldpneumo = self.Pneumatic.Think
			self.Pneumatic.Think = function(sys,...)
				oldpneumo(sys,...)
				local wag = sys.Train
				--print(wag:GetNW2Bool("DoorL"),wag:GetNW2Bool("DoorR"))--true, если открыты
				--0 закрыты, 500 открыты
				local CurTime = CurTime()
				local DoorsDisabled = wag:GetNW2Bool("DoorsDisabled")
				local openedL
				local openedR
				for k,bname in pairs(buttons)do
					local str = "Door"..(k < 9 and "L" or "R")..((k+3)%4+1)
					if wag[bname.."asd"] then
						--								startvalue																len		  						speed					isopeinig		
						local val = mathClamp((DoorsDisabled and wag["Prev"..str.."State"] or wag:GetNW2Float(str,0))+(not DoorsDisabled and (CurTime-wag[bname.."asd"])*250 or 50)*((k < 5 or k > 8 and k < 13) and 1 or -1),0,500)
						wag:SetNW2Float(str,val)
					elseif DoorsDisabled then
						wag:SetNW2Float(str,wag["Prev"..str.."State"] or wag:GetNW2Float(str,0))
					end
					--print(wag:GetNW2Float(str,0))
					local val = wag:GetNW2Float(str,0)
					wag["Prev"..str.."State"] = val
						if val ~= 0 then
							if k < 9 then
								openedL = true
							else
								openedR = true
							end
						end
				end
				if openedL then 
					wag:SetNW2Bool("DoorL",true)
				end
				if openedR then 
					wag:SetNW2Bool("DoorR",true)
				end
				wag.BD:TriggerInput("Set",not openedL and not openedR)
				
			end
		end
		
		local oldpress = NOMER.OnButtonPress
		NOMER.OnButtonPress = function(self,button,...)
			--print(button)
			self[button.."asd"] = CurTime()
			if button == "DisableDoors" then
				self:SetNW2Bool("DoorsDisabled",not self:GetNW2Bool("DoorsDisabled"))
			end
			oldpress(self,button,...)
		end
		
		local oldrelease = NOMER.OnButtonRelease
		NOMER.OnButtonRelease = function(self,button,...)
			--print(button)
			self[button.."asd"] = false
			oldrelease(self,button,...)
		end
	end
	
	if CLIENT then
		NOMER.ButtonMap["DoorsManualLeft"] = {
			pos = Vector(-405,62.6,50),
			ang = Angle(0,0,90),
			width = 800,
			height = 100,
			scale = 1,
			buttons = {
			}
		}
		for i = 1,4 do
			local button = NOMER.ButtonMap["DoorsManualLeft"].buttons
			button[#button+1] = {ID = buttons[i],x=18+(4-i)*230.2,y=0,w=70,h=50,tooltip=""}
			button[#button+1] = {ID = buttons[i+4],x=18+(4-i)*230.2,y=50,w=70,h=50,tooltip=""}
		end
		
		NOMER.ButtonMap["DoorsManualRight"] = {
			pos = Vector(375.5,-62.6,50),
			ang = Angle(0,180,90),
			width = 800,
			height = 100,
			scale = 1,
			buttons = {
			}
		}
		for i = 9,12 do
			local button = NOMER.ButtonMap["DoorsManualRight"].buttons
			button[#button+1] = {ID = buttons[i],x=1+(i-9)*230.2,y=0,w=70,h=50,tooltip=""}
			button[#button+1] = {ID = buttons[i+4],x=1+(i-9)*230.2,y=50,w=70,h=50,tooltip=""}
		end
		
		
        NOMER.ButtonMap["DoorsDisabler1"] = {
            pos = Vector(273,-61.6,-5),
            ang = Angle(0,0,270),
            width = 200,
            height = 400,
            scale = 0.1/2,
                buttons = {
                    {ID = "DisableDoors",x=0,y=0,w=200,h=400,tooltip="Выключатель дверей"},
            }
        }
		
		NOMER.ClientProps["DoorsDisabler1"] = {
            model = "models/metrostroi_train/81-717/stop_mvm.mdl",
            pos = Vector(276,-61.6,11.5),
            ang = Angle(0,180,0),
            hideseat=0.2,
		}
		
		local oldthink = NOMER.Think
		NOMER.Think = function(self,...)
			local res = oldthink(self,...)
			self:Animate("DoorsDisabler1",self:GetNW2Bool("DoorsDisabled") and 0.25 or 0, 0,1, 5,false)
			return res
		end
	end
end)