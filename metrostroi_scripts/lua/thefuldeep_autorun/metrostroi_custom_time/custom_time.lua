if SERVER then return end

timer.Create("Metrostroi Custo Time Load",0,0,function()
	if not Metrostroi or not Metrostroi.GetSyncTime then return end
	timer.Remove("Metrostroi Custo Time Load")
	print("Loading custom metrostroi time")
	local OldTime = Metrostroi.GetSyncTime
	Metrostroi.GetSyncTime = function(arg)
		return OldTime(arg) + GetConVar("metrostroi_custom_time"):GetInt() * 60 * 60
	end
end)