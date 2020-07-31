if SERVER then resource.AddWorkshop("1563745153") end
timer.Simple(1,function()
	local YazSoundFile = "subway_trains/bogey/skrip_yaz_v2.wav"
	local IsYazSoundFileExists = file.Exists("sound/"..YazSoundFile, "GAME")
	
	local bogeysWagons = {}
	local bogeysSkripType = {}
	
	local entsFindByClass = ents.FindByClass
	
	local paramname1,paramname2 = "Стандартный рандомный","by YaZ"
	local inserted_index1,inserted_index2 = -1,-1
	
	local tablename = "WheelsSkripType"
	local readtablename = "Тип скрипа колес"
	
	for k,class in pairs(Metrostroi and Metrostroi.TrainClasses or {}) do
		if class:find("76",1,true) then continue end--у оки как-то иначе работает тележка
		local ENT = scripted_ents.GetStored(class)
		if ENT.t then ENT = ENT.t else continue end
		
		
		if ENT and ENT.Spawner then		
			local foundtable
			for k,v in pairs(ENT.Spawner) do
				if istable(v) and v[1] == tablename then foundtable = k break end
			end
			
			if not foundtable then
				table.insert(ENT.Spawner,#ENT.Spawner,{tablename,readtablename,"List",{"Стандартный",paramname1,paramname2}})
				inserted_index1 = 2
				inserted_index2 = 3
			else
				inserted_index1 = table.insert(ENT.Spawner[foundtable][4],paramname1)
				inserted_index2 = table.insert(ENT.Spawner[foundtable][4],paramname2)
			end
		end
		
		if CLIENT and ENT and ENT.UpdateWagonNumber then
			local oldupdate = ENT.UpdateWagonNumber
			ENT.UpdateWagonNumber = function(self,...)
				oldupdate(self,...)
				
				for _,bogey in pairs(entsFindByClass("gmod_train_bogey")) do --не совсем крутой вариант, но не думаю, что это так страшно
					if bogeysWagons[bogey] == self then
						bogeysSkripType[bogey] = self:GetNW2Int(tablename,0)
						if bogeysSkripType[bogey] == inserted_index2 and not IsYazSoundFileExists then bogeysSkripType[bogey] = inserted_index1 end
						bogey:ReinitializeSounds()
					end
				end
			end
		end
	end
	if SERVER then return end

	local ENT = scripted_ents.GetStored("gmod_train_bogey")
	if not ENT then return else ENT = ENT.t end
	
	local flangsoundsForYaz = {
		flangea = true,
		flangeb = true,
		flange1 = true,
		--flange2 = true
	}
	
	local flangsounds = {
		flangea = true,
		flangeb = true,
		flange1 = true,
		flange2 = true
	}
	
	local yaz_sound_name = "flange2"
	
	local skip = {[1]=true,[inserted_index1]=true}
	local oldinitsounds = ENT.ReinitializeSounds
	ENT.ReinitializeSounds = function(self,...)
		oldinitsounds(self,...)
		--если стандартный или стандартный рандомный, то пропустить, так как заменять звук не нужно
		if skip[bogeysSkripType[self]] then return end
		self.Sounds[yaz_sound_name]:Stop()
		self.SoundNames[yaz_sound_name] = YazSoundFile
		util.PrecacheSound(YazSoundFile)
		self.Sounds[yaz_sound_name] = CreateSound(self, Sound(YazSoundFile))
	end
	
	
	local mathRand = math.Rand
	local mathrandom = math.random
	
	local minpause = 0
	local maxpause = minpause + 2
	
	local minfadein = 0.1
	local minfadeout = 0.4
	
	local minlen = minfadein + minfadeout
	local maxlen = minlen + 5
	
	local oldsetsoundstate = ENT.SetSoundState
	ENT.SetSoundState = function(self,sound,volume,pitch,name,level,...)
		if bogeysSkripType[self] == inserted_index2 then
			if flangsoundsForYaz[sound] then volume = 0
			elseif sound == yaz_sound_name and volume > 0 then
				--print(volume,pitch)
				local CurTime = CurTime()
				if CurTime <= self.EndEmit and CurTime >= self.StartEmit then
					--тут есть звук
					pitch = pitch - 0.2
					volume = volume*5--делаю чуток погромче
					local percentDone = ((CurTime-self.StartEmit)/self.EmitDist)*100
					--print("done",percentDone,"fadeinpercent",self.FadeInPercent,"fadeoutpercent",self.FadeOutPercent)
					if percentDone <= self.FadeInPercent then
						--возрастание от 0 до volume
						--print("fade in multipier",percentDone/self.FadeInPercent)
						volume = volume*(percentDone/self.FadeInPercent)
					end
					if percentDone >= self.FadeOutPercent then
						--убывание от volume до 0
						--print("fade out multipier",(100-percentDone)/(self.FadeOutPercentR))
						volume = volume*((100-percentDone)/(self.FadeOutPercentR))
					end
					--print(volume)
				else
					--тут нет звука
					volume = 0
					if CurTime >= self.EndEmit then
						self.StartEmit = CurTime + mathRand(minpause,maxpause)
						self.EndEmit = self.StartEmit + mathRand(minlen,maxlen)
						self.EmitDist = self.EndEmit - self.StartEmit
						--print("silent for",self.StartEmit - CurTime)
						--print("eimt for",self.EmitDist)
						
						--даю минимум 0.1 секунды на возрастание и 0.4 на затухание	
						local minstart = (minfadein/self.EmitDist)*100
						local maxend = 100-(minfadeout/self.EmitDist)*100
						
						self.FadeInPercent = mathrandom(minstart,maxend)
						self.FadeOutPercent = mathrandom(self.FadeInPercent,maxend)
						self.FadeOutPercentR = 100-self.FadeOutPercent
					end
				end
				--print(volume)
			end
		elseif bogeysSkripType[self] == inserted_index1 then
			if flangsounds[sound] and volume > 0 then
				--print(volume,pitch)
				local CurTime = CurTime()
				if CurTime <= self.EndEmit and CurTime >= self.StartEmit then
					--тут есть звук
					volume = volume*1.5--делаю чуток погромче
					local percentDone = ((CurTime-self.StartEmit)/self.EmitDist)*100
					--print("done",percentDone,"fadeinpercent",self.FadeInPercent,"fadeoutpercent",self.FadeOutPercent)
					if percentDone <= self.FadeInPercent then
						--возрастание от 0 до volume
						--print("fade in multipier",percentDone/self.FadeInPercent)
						volume = volume*(percentDone/self.FadeInPercent)
					end
					if percentDone >= self.FadeOutPercent then
						--убывание от volume до 0
						--print("fade out multipier",(100-percentDone)/(self.FadeOutPercentR))
						volume = volume*((100-percentDone)/(self.FadeOutPercentR))
					end
					--print(volume)
				else
					--тут нет звука
					volume = 0
					if CurTime >= self.EndEmit then
						self.StartEmit = CurTime + mathRand(minpause,maxpause)
						self.EndEmit = self.StartEmit + mathRand(minlen,maxlen)
						self.EmitDist = self.EndEmit - self.StartEmit
						--print("silent for",self.StartEmit - CurTime)
						--print("eimt for",self.EmitDist)
						
						--даю минимум 0.1 секунды на возрастание и 0.4 на затухание	
						local minstart = (minfadein/self.EmitDist)*100
						local maxend = 100-(minfadeout/self.EmitDist)*100
						
						self.FadeInPercent = mathrandom(minstart,maxend)
						self.FadeOutPercent = mathrandom(self.FadeInPercent,maxend)
						self.FadeOutPercentR = 100-self.FadeOutPercent
					end
				end
				--print(volume)
			end
		end
		oldsetsoundstate(self,sound,volume,pitch,name,level,...)
	end
	
	local oldinit = ENT.Initialize
	ENT.Initialize = function(self,...)
		self.FadeInPercent = mathrandom(5,95)
		self.FadeOutPercent = mathrandom(self.FadeInPercent,95)
		self.FadeOutPercentR = 100-self.FadeInPercent
		self.StartEmit = 0
		self.EndEmit = 0
		self.EmitDist = 0
		bogeysWagons[self] = self:GetNW2Entity("TrainEntity")
		oldinit(self,...)
	end
end)