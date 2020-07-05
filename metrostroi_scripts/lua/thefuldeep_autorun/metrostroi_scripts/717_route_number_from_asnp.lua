--TODO правильнее было бы ворваться в систему ASNP и там обновлять сетевые значения при нажатии на кнопку
if CLIENT then return end
timer.Create("set routenumber by asnp for 81-717",5,0,function()
	for _,ent in pairs(ents.FindByClass("gmod_subway_81-717_mvm"))do
		if not IsValid(ent)then return end
		ent:SetNW2String("RouteNumber",ent:GetNW2Int("ASNP:RouteNumber",0)*10)
	end
end)