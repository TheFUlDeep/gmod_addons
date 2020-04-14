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


local function ChangeColor(ClientEnt,bool)
	if not IsValid(ClientEnt) then return end
	local color = ClientEnt:GetColor() 				--проверку на соответствие цветов добавляю, потому что постоянная установка цвета съест больше фпс, чем проверка цвета
	if bool then
		if color.r == 100 and color.g == 100 and color.b == 255 then return end
		ClientEnt:SetColor(Color(100,100,255))
	else
		if color.r == 175 and color.g == 250 and color.b == 20 then return end
		ClientEnt:SetColor(Color(175,250,20))
	end
end

timer.Create("Change Speed Color",1,0,function()							--использую именно таймер, потому что ентити на клиентской части доступно не всегда
	for k,v in pairs(ents.FindByClass("gmod_subway_81-717_mvm")) do
		if not IsValid(v) or not v.ClientEnts then continue end
		--можно добавить еще, но я не уверен, что это что-то оптимизирует if not v.ShouldRenderClientEnts or not v:ShouldRenderClientEnts() then continue end
		local BlueSpeed = v:GetNW2Bool("BlueSpeed",false)
		ChangeColor(v.ClientEnts.SSpeed1,BlueSpeed)
		ChangeColor(v.ClientEnts.SSpeed2,BlueSpeed)
	end
end)