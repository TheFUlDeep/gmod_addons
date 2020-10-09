hook.Add("InitPostEntity","Metrostroi 717 custom dirt level",function()
--timer.Simple(0,function()
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if not NOMER_CUSTOM then return else NOMER_CUSTOM = NOMER_CUSTOM.t end
	table.insert(NOMER_CUSTOM.Spawner,#NOMER_CUSTOM.Spawner-1,{"DirtLevelCustom","Загрязненность","Slider",0,-1,100})
	
	if SERVER then
		for i = 1,2 do
			local NOMER = scripted_ents.GetStored(i == 1 and "gmod_subway_81-717_mvm" or "gmod_subway_81-714_mvm").t
			local oldinit = NOMER.Initialize
			NOMER.Initialize = function(self,...)
				oldinit(self,...)
				local oldupdate = self.UpdateTextures
				self.UpdateTextures = function(self,...)
					oldupdate(self,...)
					local dirtlevel = self:GetNW2Int("DirtLevelCustom",-1)
					if dirtlevel == -1 then dirtlevel = math.random(1,60) end
					self:SetNW2Vector("DirtLevel",(dirtlevel/100)*3)
				end
			end
		end
	end
end)