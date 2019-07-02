if CLIENT then return end

local function ConvertDescriptionToUse(v)
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
	if not CheckSkin(item:Description()) then return false,"данного скина нет на сервере. Покупка запрещена" end
end)

--PrintTable(Metrostroi.Skins)