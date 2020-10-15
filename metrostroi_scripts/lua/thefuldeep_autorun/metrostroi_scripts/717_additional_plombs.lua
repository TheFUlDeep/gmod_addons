if true then return end
hook.Add("InitPostEntity","Metrostroi 717 plombs",function()
--timer.Simple(0,function()
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm")
	if not NOMER then return else NOMER = NOMER.t end
	
	if SERVER then
		local oldinit = NOMER.TrainSpawnerUpdate
		NOMER.TrainSpawnerUpdate = function(self,...)
			oldinit(self,...)
			--TODO если состав сам ставится на ках, то АЛС должна быть выключена
			self.ALS:TriggerInput("Block",false)
			self.ALS:TriggerInput("Set",1)
			self.ALS:TriggerInput("Block",true)
			self.Plombs.ALS = true
			
			--TODO
			--self.R_ASNPOn:TriggerInput("Block",false)
			--self.R_ASNPOn:TriggerInput("Set",1)
			--self.R_ASNPOn:TriggerInput("Block",true)
			--self.Plombs.R_ASNPOn = true
			
			self.Plombs.Init = true
		end
	end
end)