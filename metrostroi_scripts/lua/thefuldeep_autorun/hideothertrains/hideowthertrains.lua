if SERVER then return end

CreateClientConVar("hideothertrains", "0", true, false, "" )

CreateClientConVar("hidealltrains","0",true,false,"")

local fps
local PrevFPS
local FPSLimit = 15
timer.Create("RecomendHideTrains",20,0,function()
	if not system.HasFocus() then return end
	PrevFPS = fps
	fps = 1 / RealFrameTime()
	if PrevFPS and PrevFPS < FPSLimit and fps < FPSLimit then
		timer.Remove("RecomendHideTrains")
		chat.AddText(Color(255,0,0,200),"Обнаружена низкая производительность. Для повышения fps попробуйте консольные команды hideothertrains 1 или hidealltrains 1. А также убедитесь, что режим съемки выключен!")
	end
end)