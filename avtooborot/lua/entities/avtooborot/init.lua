
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:StartTouch( entity )
	local Class = entity:GetClass()
	for k,v in pairs(Metrostroi.TrainClasses) do
		if Class == v or stringfind(Class,"base") then
			self.zanyat = entity
			--ulx.fancyLog("занят #s", self.name)
			UpdateAvtooborot()
			return
		end
	end
end

function ENT:EndTouch( entity )
	timer.Simple(2.1, function() 
		if entity == self.zanyat then self.zanyat = nil
			UpdateAvtooborot()
			--ulx.fancyLog("освободился #s", self.name)
		end
	end)
end

function ENT:Initialize()
end