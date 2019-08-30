if CLIENT then return end

local function ConvertDescriptionToUse(v)
	if not v or not v:find("%a") then return end
	v = string.sub(v,stringfind(v,"\n[[") + 3, - 3)
	local start1 = string.find(v," ")
	if not start1 then return nil end
	local TrainClass1 = string.sub(v,1,start1 - 1)
	local start2 = string.find(v," ",start1 + 1)
	if not start2 then return nil end
	local TextureClass1 = string.sub(v,start1 + 1, start2 - 1)
	local TextureName1 = string.sub(v,start2 + 1)
	
	return TrainClass1,TextureClass1,TextureName1
end

local function IsThisTyp(str,EntClass)
	if str == "81-502" and EntClass == "gmod_subway_81-502" then return true end
	if str == "81-702" and EntClass == "gmod_subway_81-702" then return true end
	if str == "81-703" and EntClass == "gmod_subway_81-703" then return true end
	if str == "81-717_msk" and EntClass == "gmod_subway_81-717_mvm_custom" then return true end
	if str == "81-718" and EntClass == "gmod_subway_81-718" then return true end
	if str == "81-720" and EntClass == "gmod_subway_81-720" then return true end
	if str == "81-722" and EntClass == "gmod_subway_81-722" then return true end
	if str == "81-710" and EntClass == "gmod_subway_ezh3" then return true end
	if str == "81-707" and EntClass == "gmod_subway_ezh" then return true end
	return false
end

local function CheckSkin(item_description)
	local TrainClass1,TextureClass1,TextureName1 = ConvertDescriptionToUse(item_description)
	if TrainClass1 ~= "gmod_subway_81-717_6" then
		local TextureClass2 = TextureClass1 == "Texture" and "train" or TextureClass1 == "CabTexture" and "cab" or TextureClass1 == "PassTexture" and "pass" or ""
		if TextureClass2 == "" then return false end
		for k,v in pairs(Metrostroi.Skins) do
			if type(v) ~= "table" then continue end
			if k ~= TextureClass2 then continue end
			for k1,v1 in pairs(v) do
				if type(v1) ~= "table" then continue end
				if v1.typ and v1.name and v1.name == TextureName1 and IsThisTyp(v1.typ,TrainClass1) then
					return true
				end
			end
		end
	else
		local TextureClass2 = TextureClass1 == "Texture" and "Train" or TextureClass1 == "CabTexture" and "Cab" or TextureClass1 == "PassTexture" and "Int" or ""
		if TextureClass2 == "" then return false end
		for k,v in pairs(MetrostroiDotSixSkins[TextureClass2]) do
			if v.Name == TextureName1 then return true end
		end
	end
	
	return false
end

hook.Add("IGS.CanPlayerBuyItem", "CheckMetrostroiSkin", function(pl,item,global,invid)
	if item:Description() == "Разрешает использовать все скины на месяц" then return end
	if not CheckSkin(item:Description()) then return false,"данного скина нет на сервере. Покупка запрещена" end
end)


















local function DetectNoAddedSkins()
	if not IGS or not Metrostroi or not Metrostroi.Skins or not IGS.ITEMS then return end
	local SkinsOnServer = {}--имя, тип, айди
	for k,v in pairs(Metrostroi.Skins) do
		if istable(v) and k == "train" or k == "pass" or k == "cab" then
			for k1,v1 in pairs(v) do
				if v1.typ:find("_spb") then continue end
				for k2,v2 in pairs(v1) do
					if k2 == "name" then table.insert(SkinsOnServer,1,{v2,k,k1,v1.typ}) end
				end
			end
		end
	end
	--PrintTable(SkinsOnServer)
		
	local SkinsInDonate = {}
	for k,v in pairs(IGS.ITEMS) do
		if not istable(v) then continue end
		for k1,v1 in pairs(v) do
			if not istable(v1) then continue end
			local TrainClass1,TextureClass1,TextureName1 = ConvertDescriptionToUse(v1.description)
			if not TrainClass1 or not TextureClass1 or not TextureName1 then continue end
			if TextureClass1 == "Texture" then TextureClass1 = "train" end
			if TextureClass1 == "Pass" then TextureClass1 = "pass" end
			if TextureClass1 == "Cab" then TextureClass1 = "cab" end
			if TextureClass1 == "CabTexture" then TextureClass1 = "cab" end
			if TextureClass1 == "PassTexture" then TextureClass1 = "pass" end
			table.insert(SkinsInDonate,1,{--[[v1.name,]]TrainClass1,TextureClass1,TextureName1,v1.id,v1.id})
		end
		
		--PrintTable(SkinsInDonate)
	end

	local FoundDifference = {}
	for k,v in pairs(SkinsOnServer) do
		if v[1] == "Random" then continue end
		local FoundName = {}
		for k1,v1 in pairs(SkinsInDonate) do
			if v[1] == v1[3] then
				table.insert(FoundName,k1)
			end
		end
		
		if #FoundName > 0 then
			for k1,v1 in pairs(FoundName) do
				if SkinsInDonate[v1][2] ~= v[2] then 
					table.insert(FoundDifference,1,k)
				end
			end
		else
			table.insert(FoundDifference,1,k)
		end
		
	end	

	for k,v in pairs(FoundDifference) do
		for k1,v1 in pairs(FoundDifference) do
			if k ~= k1 and v == v1 then FoundDifference[k1] = nil end
		end
	end	
	
	local function AddSkinToDonate(name,typ,id,train)	--я это не дописал, но лучше  добавлять все вручную
		local typ1,price,word
		if typ == "pass" then typ1 = "PassTexture" price = 5 word = "салона"
		elseif typ == "cab" then typ1 = "CabTexture" price = 5 word = "кабины"
		elseif typ == "train" then typ1 = "Texture" price = 15 word = "кузова"
		else return
		end
		
		local BeautyName,DscriptionName,EntName
		if train == "81-717_msk" then BeautyName,EntName = "81-717 МСК (номерной)","gmod_subway_81-717_mvm_custom"
		elseif train == "81-702" then BeautyName,EntName = "81-702 (Д)","gmod_subway_81-702"
		elseif train == "81-703" then BeautyName,EntName = "81-703 (E)","gmod_subway_81-703"
		else return
		end
		
		print("adding "..BeautyName.." "..name.." "..typ)
		IGS(BeautyName.." "..typ.." "..name, id)
		:SetPrice(price)
		:SetPerma()
		:SetDescription("Разрешает использовать скин "..word.." "..name.." на составе "..train.."\n[[.."..EntName.." "..typ1.." "..name.."]]")
		:SetCategory("Скины на "..BeautyName)
	end
	
	local FoundDifferenceCount = table.Count(FoundDifference)
	if FoundDifferenceCount > 0 then
		print("Найдены скины, недобавленные в донаты! Игроки не смогут ими пользоваться!",FoundDifferenceCount)
		for _,v in pairs(FoundDifference) do
			--AddSkinToDonate(SkinsOnServer[v][1],SkinsOnServer[v][2],SkinsOnServer[v][3],SkinsOnServer[v][4])
			PrintTable(SkinsOnServer[v])
			print("-----------------------------------")
		end
	end
	

end

DetectNoAddedSkins()
--PrintTable(Metrostroi.Skins)