if SERVER then return end

CreateClientConVar("hideothertrains", "0", true, false, "" )

CreateClientConVar("hidealltrains","0",true,false,"")


local FPSLimit = 20
local TimeLimit = 10 * FPSLimit
local i = 0
hook.Add("Think","RecomendHideTrains",function()
	if not system.HasFocus() then return end
	local fps = 1 / RealFrameTime()
	if fps < FPSLimit then i = i + 1 else i = 0 end
	if i > TimeLimit then
		hook.Remove("Think","RecomendHideTrains")
		chat.AddText(Color(255,0,0,200),"Обнаружена низкая производительность. Для повышения fps попробуйте консольные команды hideothertrains 1 или hidealltrains 1. А также убедитесь, что режим съемки выключен!")
	end
end)