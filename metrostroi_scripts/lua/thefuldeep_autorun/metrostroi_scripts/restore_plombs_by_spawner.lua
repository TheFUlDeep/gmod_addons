if CLIENT then return end

timer.Simple(0,function()
	local function RestoreBlomb(self,but,val)
		self[but]:TriggerInput("Set",val)
		self[but]:TriggerInput("Block",true)
		self.Plombs[but] = true
		self:SetPackedBool(but.."Pl",true)
	end
	

	local BrokenPlombs = {}
	
	local BASE = scripted_ents.GetStored("gmod_subway_base")
	if not BASE then return else BASE = BASE.t end
	
	local oldbroke = BASE.BrokePlomb
	BASE.BrokePlomb = function(self,but,...)
		oldbroke(self,but,...)
		BrokenPlombs[self][but] = self[but].Value
	end
	
	
	for _,class in pairs(Metrostroi and Metrostroi.TrainClasses or {})do
		local ENT = scripted_ents.GetStored(class)
		if not ENT then continue else ENT = ENT.t end
		local oldupdate = ENT.TrainSpawnerUpdate or function()end
		ENT.TrainSpawnerUpdate = function(self,...)
			oldupdate(self,...)
			for but,val in pairs(BrokenPlombs[self] or {})do
				RestoreBlomb(self,but,val)
			end
			BrokenPlombs[self] = {}
			self:TriggerInput("FailSimReset")
			self.TrainWireOutside = {}
		end
	end
end)