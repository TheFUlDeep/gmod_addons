--TODO правильнее было бы ворваться в систему ASNP и там обновлять сетевые значения при нажатии на кнопку
if CLIENT then return end

local function GetLastStation(self)
	if not Metrostroi.StationConfigurations or not Metrostroi.ASNPSetup or self:GetNW2Int("ASNP:State"0) < 7 then
		return
	else
		local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)]
		local Line = Selected and Selected[self:GetNW2Int("ASNP:Line",0)]
		local Path = self:GetNW2Bool("ASNP:Path",false)
		local Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil		--красивый враиант. Спереди показывается одна станция, сзади другая
		--local Station = Line and Line[self:GetNW2Int("ASNP:LastStation",0)] or nil		--вариант, как в реальности. То есть и спереди и сзади одна и та же станция
		Station = Station and Station[1]
		return Station and tonumber(Station)
	end
end

local id = "717_routes"
timer.Create("set last station by asnp for 81-717",5,0,function()
	for _,ent in pairs(ents.FindByClass("gmod_subway_81-717_mvm"))do
		if not IsValid(ent)then return end
		local res = GetLastStation(ent)
		res = res and Metrostroi.Skins[id][res]
		if res then
			ent:SetNW2String("LastStationID",res)
		end
	end
end)