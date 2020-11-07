if CLIENT then return end

hook.Add("InitPostEntity","Metrostroi 717 ASNP radioinformator",function()
-- timer.Simple(0,function()
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not NOMER then return else NOMER = NOMER.t end
	
	
	local oldpress = NOMER.OnButtonPress
	NOMER.OnButtonPress = function(self,but,...)
		oldpress(self,but,...)
		if but == "R_RadioToggle" then
			if self.R_Radio.Value == 1 then self.Announcer:Reset() end
		end
	end
	
	local names = {R_Program1=true,R_Program1H=true,R_Program2=true,R_Program2H=true}
	
	local oldinit = NOMER.Initialize
	NOMER.Initialize = function(self,...)
		oldinit(self,...)
		local oldtrigger = self.ASNP.Trigger
		self.ASNP.Trigger = function(self1,name,...)
			oldtrigger(self1,name,...)
			if names[name] and self.R_Radio.Value == 0 then
				self.Announcer:Reset()
			end
		end
	end
end)