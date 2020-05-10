if CLIENT then return end

--local no_entry_arr = Sound("thefuldeeps_sounds/no_entry_arr.mp3")
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

local function GetStationIndexByName(str)
	if not Metrostroi or not Metrostroi.StationConfigurations or not str or str == "" then return end
	str = bigrustosmall(str)
	local StationIndex
	for curindex,v in pairs(Metrostroi.StationConfigurations) do
		local CurIndex = tonumber(curindex)
		if not istable(v) or not CurIndex then continue end
		for _,name in pairs(v.names or {}) do
			if bigrustosmall(name) == str then return CurIndex end
		end
	end
end

local function GetLastStation(self)
	if not Metrostroi.StationConfigurations then
		return nil
	else
		local Station
		if not Station and Metrostroi.ASNPSetup then --искать станцию только если аснп полностью настроен
			local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
			local Line = Selected and Selected[self:GetNW2Int("ASNP:Line",0)] or nil
			local Path = self:GetNW2Bool("ASNP:Path",false)
			Station = Line and (not Path and Line[self:GetNW2Int("ASNP:LastStation",0)] or Path and Line[self:GetNW2Int("ASNP:FirstStation",0)]) or nil
			Station = Station and Station[1]
			
			if self:GetClass():find("760",1,true) then--TODO возможно ока берет информатор не из asnp, но оставлю так
				Station = GetStationIndexByName(self:GetNW2String("BMCISLast"..self:GetNW2Int("BMCISLastStationEntered",-1),nil))
			end
			if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			if not Station then
				local Line = Selected and Selected[self:GetNW2Int("RRI:Line",0)] or nil
				Station = Line and Line[self:GetNW2Int("RRI:LastStation",0)] or nil
				if Station then Station = Station[1] or nil end
				if Station and (not tonumber(Station) or not Line.Loop and (Station == Line[#Line][1] or Station == Line[1][1])) then Station = nil end
			end
			if not Station then
				local Selected = Metrostroi.ASNPSetup[self:GetNW2Int("Announcer",0)] or nil
				local Line = Selected and Selected[self:GetNW2Int("BMCISLine",0)] or nil
				local Path = self:GetNW2Bool("BMCISPath",false)
				Station = Line and (not Path and Line[self:GetNW2Int("BMCISLastStation",0)] or Path and Line[self:GetNW2Int("BMCISFirstStation",0)]) or nil
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
		--[[if not Station and self:GetNW2String("PAM:TargetStation","") ~= "" then--тут последняя станция определяется всегда последней, так что это не нужно
			--local StationName = bigrustosmall(self:GetNW2String("PAM:TargetStation"))
			--Station = GetStationIndexByNameFromPA(self,StationName) or GetStationIndexByName(StationName)
			local Path = self:ReadCell(49170)
			local Line = 1
			local tbl = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path]
			Station = tbl and tbl[1] and tbl[1].stations and tbl[1].stations[#tbl[1].stations] and tbl[1].stations[#tbl[1].stations].id
		end]]
		--[[if not Station and Metrostroi.UPOSetup --тут последняя станция определяется всегда последней, так что это не нужно
		and self:GetNW2Int("SarmatState",-228) == -228 
		and self:GetNW2Int("ASNP:State",-228) == -228 
		and self:GetNW2Int("RRI:Line",-228) == -228 
		then
			local Path = self:ReadCell(49170)
			local Line = 1
			local tbl = Metrostroi.PAMConfTest and Metrostroi.PAMConfTest[Line] and Metrostroi.PAMConfTest[Line][Path]
			Station = tbl and tbl[1] and tbl[1].stations and tbl[1].stations[#tbl[1].stations] and tbl[1].stations[#tbl[1].stations].id
		end]]
		
		return Station
	end
end

timer.Create("no_entry_arr",2,0,function()
	if not tfd_play_url then return end
	for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
		if v.CurrentTrain and (not v.LastCurrentTrain or v.CurrentTrain ~= v.LastCurrentTrain) then
			v.LastCurrentTrain = v.CurrentTrain
			local LastStation = GetLastStation(v.CurrentTrain)
			print(LastStation)
			local NumLast = LastStation and tonumber(LastStation)
			local NumIndex = v.StationIndex and tonumber(v.StationIndex)
			if not NumLast or not NumIndex then continue end
			if NumLast == NumIndex then 
				--[[local PlatformLen = v.PlatformStart:DistToSqr(v.PlatformEnd)
				
				--делю платформу на участки по 1000
				local sections = PlatformLen / (2000*2000) --возвожу в квадрат, так как длину искал в квадрате
				--на каждом отрезке проигрываю звук
				print("ДОЛЖЕН ВОСПРОИЗВЕСТИСЬ ЗВУК")
				print(sections)
				for i = 1, sections do
					local percent = i/sections
					local vec = LerpVector(percent, v.PlatformStart, v.PlatformEnd)
					sound.Play(no_entry_arr,vec,120,100,0.4)
				end]]
				tfd_play_url(
					"https://cdn.discordapp.com/attachments/696426533954519052/696426551566270505/no_entry_arr.mp3",
					nil,
					LerpVector(0.5, v.PlatformStart, v.PlatformEnd),
					nil,
					(v.PlatformStart:Distance(v.PlatformEnd))/2
				)
			end
		elseif not v.CurrentTrain then
			v.LastCurrentTrain = nil
		end
	end
end)

