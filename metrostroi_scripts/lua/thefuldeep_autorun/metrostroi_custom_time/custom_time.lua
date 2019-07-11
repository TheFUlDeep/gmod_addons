if SERVER then return end

timer.Create("Metrostroi Custom Time Load",1,0,function()
	if not Metrostroi or not Metrostroi.GetSyncTime then return end
	timer.Remove("Metrostroi Custom Time Load")
	print("Loading custom metrostroi time")
	local OldTime = Metrostroi.GetSyncTime
	Metrostroi.GetSyncTime = function(arg)
		return OldTime(arg) + GetConVar("metrostroi_custom_time"):GetInt() * 60 * 60
	end
end)


timer.Create("Metrostroi Custim Time Intervals",5,0,function()
	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and not v.CustomTimeLoaded and v.GetIntervalResetTime then 
			v.CustomTimeLoaded = true
			local OldGetIntervalResetTime = v.GetIntervalResetTime
			v.GetIntervalResetTime = function(v)
				return OldGetIntervalResetTime(v) + GetConVar("metrostroi_custom_time"):GetInt() * 60 * 60
			end
		end
	end
end)