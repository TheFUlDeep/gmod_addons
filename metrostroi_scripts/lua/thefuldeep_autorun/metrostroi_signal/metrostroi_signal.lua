if SERVER then return end

local AutoStopSound = Sound("autostop.mp3")
timer.Create("Metrostroi signal Autostop sound",0.3,0,function()
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(v) then continue end
		if not v.LastAutostopPosLoaded then
			v.LastAutostopPosLoaded = true
			v.LastAutostopPos = v:GetNW2Bool("Autostop")
		end
		if v.LastAutostopPos ~= v:GetNW2Bool("Autostop") and v.Models and v.Models[1] and v.Models[1]["autostop"] then
			v.LastAutostopPos = v:GetNW2Bool("Autostop")
			sound.Play( AutoStopSound, v.Models[1]["autostop"]:GetPos(), 55, 180, 1 )
		end
	end
end)