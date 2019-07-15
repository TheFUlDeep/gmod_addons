--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	local ENT = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if ENT and ENT.t and ENT.t.Spawner then
		local cont = false
		for k,v in pairs(ENT.t.Spawner) do
			if istable(v) and v[1]=="BlueSpeed" then cont = true break end
		end
		if cont then return end
	
		table.insert(ENT.t.Spawner,{"BlueSpeed","Синий скоростемер","Boolean"})
	end
end)

if SERVER then return end

timer.Create("Change Speed Color",5,0,function()							--использую именно таймер, потому что ентити на клиентской части доступно не всегда
	for k,v in pairs(ents.FindByClass("gmod_subway_81-717_mvm")) do
		if not IsValid(v) then continue end
		for k1,v1 in pairs(v.ClientEnts) do
			if not IsValid(v1) or not k1:find("SSpeed") then continue end
			if v:GetNW2Bool("BlueSpeed",false) then
				v1:SetColor(Color(100,100,255))
			else
				v1:SetColor(Color(175,250,20))
			end
		end
	end
end)