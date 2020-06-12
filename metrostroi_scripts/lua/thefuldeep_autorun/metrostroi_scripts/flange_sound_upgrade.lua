if SERVER then return end

local flangsounds = {
	flangea = true,
	flangeb = true,
	flange1 = true,
	flange2 = true
}
local mathRand = math.Rand
local mathrandom = math.random

local function newfunc(self,sound,volume,pitch,name,level,...)
	if (flangsounds[sound]) and volume > 0 then
		--print(volume,pitch)
		local CurTime = CurTime()
		if CurTime < self.EndEmit and CurTime > self.StartEmit then
			--тут есть звук
			volume = volume*1.5--делаю чуток погромче
			local percentDone = ((CurTime-self.StartEmit)/self.EmitDist)*100
			--print("done",percentDone,"fadeinpercent",self.FadeInPercent,"fadeoutpercent",self.FadeOutPercent)
			if percentDone <= self.FadeInPercent then
				--возрастание от 0 до volume
				--print("fade in multipier",percentDone/self.FadeInPercent)
				volume = volume*(percentDone/self.FadeInPercent)
			elseif percentDone >= self.FadeOutPercent then
				--убывание от volume до 0
				--print("fade out multipier",(100-percentDone)/(self.FadeInPercentR))
				volume = volume*((100-percentDone)/(self.FadeInPercentR))
			end
			--print(volume)
		else
			--тут нет звука
			volume = 0
			if CurTime > self.EndEmit then
				self.StartEmit = CurTime + mathRand(0,2)
				self.EndEmit = self.StartEmit + mathRand(0.1,3)
				self.EmitDist = self.EndEmit - self.StartEmit
				--print("silent for",self.StartEmit - CurTime)
				--print("eimt for",self.EmitDist)
				
				--даю минимум 5 процентов на fadein и fadeout
				self.FadeInPercent = mathrandom(5,95)
				--если длина возрастания по времени меньше, чем 0.1, то сделать ее 0.1
				--если с начала нет места
				if (self.EmitDist/100)*self.FadeInPercent < 0.05 then
					self.FadeInPercent = (0.05/self.EmitDist)*100
				end
				--если с конца нет места
				if (self.EmitDist/100)*(100-self.FadeInPercent) < 0.05 then
					self.FadeInPercent = 100-(0.05/self.EmitDist)*100
				end
				
				self.FadeOutPercent = mathrandom(self.FadeInPercent,95)
				self.FadeInPercentR = 100-self.FadeOutPercent
				--если длина убывания по времени меньше, чем 0.1, то сделать ее 0.1
				--print("len",self.EmitDist)
				--print("out percent",self.FadeOutPercent)
				--print("out len",(self.EmitDist/100)*self.FadeInPercentR)
				if (self.EmitDist/100)*self.FadeInPercentR < 0.5 then
					self.FadeInPercentR = (0.5/self.EmitDist)*100
					self.FadeOutPercent = 100-self.FadeInPercentR
				end
				--print("fade in",self.FadeInPercent)
				--print("fade out",self.FadeOutPercent)
			end
		end
		--print(volume)
	end
	self.oldsetsoundstate(self,sound,volume,pitch,name,level,...)
end

timer.Simple(0,function()
	local ENT = scripted_ents.GetStored("gmod_train_bogey").t
	ENT.oldsetsoundstate = ENT.SetSoundState
	ENT.SetSoundState = newfunc
	
	local oldinit = ENT.Initialize
	ENT.Initialize = function(self,...)
		self.FadeInPercent = mathrandom(5,95)
		self.FadeInPercentR = 100-self.FadeInPercent
		self.FadeOutPercent = mathrandom(self.FadeInPercent,95)
		self.StartEmit = 0
		self.EndEmit = 0
		self.EmitDist = 0
		oldinit(self,...)
	end
end)