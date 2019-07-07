if SERVER then return end


local FPSLimit = 20
local TimeLimit = 10 * FPSLimit
local i = 0
hook.Add("Think","RecomendHideTrains",function()
	if not system.HasFocus() then return end
	local fps = 1 / RealFrameTime()
	if fps < FPSLimit then i = i + 1 else i = 0 end
	if i > TimeLimit then
		hook.Remove("Think","RecomendHideTrains")
		chat.AddText(
			Color(255,0,0),"Обнаружена низкая производительность. Для повышения fps попробуйте консольные команды ", 
			Color(255,255,0), "hideothertrains 1", 
			Color(255,0,0), " или ", 
			Color(255,255,0), "hidealltrains 1", 
			Color(255,0,0), ". А также убедитесь, что режим съемки выключен (", 
			Color(255,255,0), "metrostroi_screenshotmode 0", 
			Color(255,0,0), ")!"
		)
	end
end)
