if SERVER then resource.AddWorkshop("1563745153") return end
timer.Simple(0,function()
	local ENT = scripted_ents.GetStored("gmod_train_bogey")
	if not ENT then return else ENT = ENT.t end
	
	local flangsounds = {
		flangea = true,
		flangeb = true,
		flange1 = true,
		--flange2 = true
	}
	
	local snd_with_volume = "flange2"
	local newsound = "subway_trains/bogey/skrip_yaz_v2.wav"
	if file.Exists("sound/"..newsound, "GAME") then
		local oldinitsounds = ENT.ReinitializeSounds
		ENT.ReinitializeSounds = function(self,...)
			oldinitsounds(self,...)
			self.Sounds[snd_with_volume]:Stop()
			self.SoundNames[snd_with_volume] = newsound
			util.PrecacheSound(newsound)
			self.Sounds[snd_with_volume] = CreateSound(self, Sound(newsound))
		end
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
		if flangsounds[sound] then volume = 0
		elseif sound == snd_with_volume and volume > 0 then
			--print(volume,pitch)
			pitch = pitch - 0.2
			local CurTime = CurTime()
			if CurTime < self.EndEmit and CurTime > self.StartEmit then
				--тут есть звук
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
		oldinit(self,...)
	end
end)