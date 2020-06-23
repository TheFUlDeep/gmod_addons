if SERVER or CLIENT then return end
--наверное этот скрипт не нужен
--TODO
--[[timer.Create("CheckForTwoToSix",2,0,function()
	local ply = LocalPlayer()
	if not CPPI or not ply:InVehicle() then return end
	
	local Seat = ply:GetVehicle()
	if not IsValid(Seat) then return end
	
	local Train = Seat:GetNW2Entity("TrainEntity",nil)
	if not IsValid(Train) then return end
	
	local Class = Train:GetClass()
	if Class ~= "gmod_subway_81-703" and Class ~= "gmod_subway_81-702" then return end
	
	local MinDist,CurDist,NearestSignal
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if not IsValid(v) then continue end
		CurDist = ply:GetPos():DistToSqr(v:GetPos())
		if not MinDist or CurDist < MinDist then MinDist = CurDist NearestSignal = v end
	end
	
	if NearestSignal:GetNW2Bool("2/6",false) then
		chat.AddText(Color(200,135,0), "На твоем составе нельзя здесь кататься.")
		--и тут функция удаления состава (я пока хз, как это сделать. Можно отправить нетворкстринг на сервер, и ентити удалится с серверной части)
	end
end]]