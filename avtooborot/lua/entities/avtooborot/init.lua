
ENT.Base = "base_entity"
ENT.Type = "brush"
ENT.ents = {}

local function ChatPrint(str)
	for k,v in pairs(player.GetHumans()) do
		v:ChatPrint(str)
	end
end

local function TableInsert(tbl,value)
	for k,v in pairs(tbl) do
		if v == value then return end
	end
	table.insert(tbl,1,value)
end

function ENT:StartTouch(entity)
	if entity:GetClass():sub(1,12) == "gmod_subway_" then
		self.occupied = entity
		--ChatPrint(self.name.." занят")
		TableInsert(self.ents,entity)
		UpdateAvtooborot()
		--PrintTable(self.ents)
	end
end

function ENT:EndTouch(entity)
	timer.Simple(2.1, function() 
		if entity == self.occupied then 
			--ChatPrint(self.name.." освободился")
			self.occupied = nil
			UpdateAvtooborot()
			--PrintTable(self.ents)
		end
	end)
end