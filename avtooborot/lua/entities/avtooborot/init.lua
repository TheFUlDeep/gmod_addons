
ENT.Base = "base_entity"
ENT.Type = "brush"
--ENT.preventity = nil

function ENT:StartTouch( entity )
	if entity:GetClass():find("gmod_subway") --and entity:CPPIGetOwner() ~= self.lastowner 
	then
		self.zanyat = entity
		--[[if self.preventity and self.preventity.WagonList then
			for k,v in pairs(self.preventity.WagonList) do
				if entity == v then self.preventity = entity return end
			end
		end]]
		--ulx.fancyLog("занят #s", self.name)
		--self.preventity = entity
		UpdateAvtooborot()
	end
end

function ENT:EndTouch( entity )
	timer.Simple(2, function() 
		if entity == self.zanyat then self.zanyat = nil
			UpdateAvtooborot()
			--ulx.fancyLog("освободился #s", self.name)
		end
	end)
end

function ENT:Initialize()
end