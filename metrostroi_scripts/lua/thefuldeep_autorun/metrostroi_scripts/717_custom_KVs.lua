--ВНИМАНИЕ
--пражский аддон и metrostroi ext не должны быть в коллекции сервера!!! (чтобы не было их скриптов)
if SERVER then 
	resource.AddWorkshop("2189954527") 
end

local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local inserted_index2 = -1
local paramname = "Пражский 1"
local paramname2 = "Пражский 2"

local model1 = "models/metrostroi_train/81-717/kv_black.mdl"
local model2 = "models/metrostroi_train/81-717/kv_white.mdl"
local model3 = "models/metrostroi_train/81-717/kv_wood.mdl"
local model4 = "models/metrostroi_train/81-717/kv_yellow.mdl"
local model_praha = "models/yaz/717_praha/kv_praha.mdl"
local model_praha2 = "models/yaz/717_praha/kv_praha2.mdl"

local tablename = "KVTypeCustom"
local readtablename = "Тип КВ"
hook.Add("InitPostEntity","Metrostroi 717_mvm praha kv",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if ENT then ENT = ENT.t else return end
	if not ENT.Spawner then return end
	
	local foundtable
	for k,v in pairs(ENT.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(ENT.Spawner,6,{tablename,readtablename,"List",{"Черный","Белый","Деревянный","Желтый",paramname,paramname2}})
		inserted_index = 5
		inserted_index2 = 6
	else
		inserted_index = table.insert(ENT.Spawner[foundtable][4],paramname)
		inserted_index2 = table.insert(ENT.Spawner[foundtable][4],paramname2)
	end
	
	if SERVER then return end
	
	local function RemoveEnt(ent)if ent then SafeRemoveEntity(ent) end end
	
	local function UpdateModelCallBack(ENT,cprop,modelcallback,callback,precallback)
		
		if modelcallback then
			local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
			ENT.ClientProps[cprop].modelcallback = function(wag,...)
				return modelcallback(wag,...) or oldmodelcallback(wag,...)
			end
		end
		
		if callback then
			local oldcallback = ENT.ClientProps[cprop].callback or function() end
			ENT.ClientProps[cprop].callback = function(wag,...)
				if precallback then precallback(wag,...)end
				oldcallback(wag,...)
				callback(wag,...)
			end
		end
		
		--удаление пропа при апдейте спавнером для принудительного обновленяи модели
		local oldupdate = ENT.UpdateWagonNumber or function() end
		ENT.UpdateWagonNumber = function(wag,...)
			RemoveEnt(wag.ClientEnts and wag.ClientEnts[cprop])
			oldupdate(wag,...)
		end
	end
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	local propname = "Controller"
	UpdateModelCallBack(
		ENT,
		propname,
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then return model_praha
			elseif wag:GetNW2Int(tablename,0) == inserted_index2 then return model_praha2
			elseif wag:GetNW2Int(tablename,0) == 1 then return model1
			elseif wag:GetNW2Int(tablename,0) == 2 then return model2
			elseif wag:GetNW2Int(tablename,0) == 3 then return model3
			elseif wag:GetNW2Int(tablename,0) == 4 then return model4
			end
		end--[[,
		
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
			local ent = wag.ClientEnts and wag.ClientEnts[propname]
			if not IsValid(ent) then return end
			ent:SetPos(wag:LocalToWorld(Vector(0,0,0)))
		end]]
	)
	
end)