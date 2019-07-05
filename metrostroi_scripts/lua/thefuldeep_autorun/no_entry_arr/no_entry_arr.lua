if CLIENT then return end

local no_entry_arr = Sound("thefuldeeps_sounds/no_entry_arr.mp3")
local function GetLastStation(self)
	if not Metrostroi.StationConfigurations then
		return nil
	else
		local Station
		if not Station and Metrostroi.ASNPSetup then
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("ASNP:Line",0)] or nil
			local Path = self:GetNW2Bool("ASNP:Path",false)
			Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil
			if Station then Station = Station[1] or nil end
			if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			if not Station then
				local Line = Selected and Selected[self:GetNW2Int("RRI:Line",0)] or nil
				Station = Line and Line[self:GetNW2Int("RRI:LastStation",0)] or nil
				if Station then Station = Station[1] or nil end
				if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			end
		end
		if not Station and Metrostroi.SarmatUPOSetup then
			local Selected = Metrostroi.SarmatUPOSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("SarmatLine",0)] or nil
			local Path = self:GetNW2Bool("SarmatPath",false)
			Station = Line and (not Path and Line[self:GetNW2Int("SarmatEndStation",0)] or Path and Line[self:GetNW2Int("SarmatStartStation",0)]) or nil
			Station = Station and Station[1] or nil
			if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
		end
		if not Station and Metrostroi.RRISetup then
			local Line = Metrostroi.RRISetup[self:GetNW2Int("RRI:Line",0)] or nil
			Station = Line and Line[self:GetNW2Int("RRI:LastStation",0)] or nil
			Station = Station and Station[1] or nil
			if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
		end
		--[[if not Station and Metrostroi.UPOSetup then		-- у упо нельзя выбирать кастомные конечные станции, поэтому оно бесполезно
			local Path = self:ReadCell(49170)
			local Line = 1
			local tbl = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path]
			Station = tbl and tbl[1].stations[#tbl[1].stations].id
		end]]
		--print(Station)
		return Station
	end
end

timer.Create("no_entry_arr",2,0,function()
	for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
		if v.CurrentTrain and (not v.LastCurrentTrain or v.CurrentTrain ~= v.LastCurrentTrain) then
			v.LastCurrentTrain = v.CurrentTrain
			local LastStation = GetLastStation(v.CurrentTrain)
			if LastStation and LastStation == v.StationIndex then 
				local PlatformLen = v.PlatformStart:Distance(v.PlatformEnd)
				
				--делю платформу на участки по 1000
				local sections = PlatformLen / 1000
				--на каждом отрезке проигрываю звук
				for i = 1, sections do
					local percent = i/sections
					local vec = LerpVector(percent, v.PlatformStart, v.PlatformEnd)
					sound.Play(no_entry_arr,vec,120,100,0.4)
				end
			end
		elseif not v.CurrentTrain then
			v.LastCurrentTrain = nil
		end
	end
end)

