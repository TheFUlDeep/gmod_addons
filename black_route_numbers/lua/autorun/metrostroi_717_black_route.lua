local matspath = "materials/models/metrostroi_train/common/routes/black/m"
if SERVER then
	for i = 0,9 do
		resource.AddFile(matspath..i..".vmt")
	end
end


local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "Default Black"

local tablename = "RouteNumberType"
local readtablename = "Тип номера маршрута"
timer.Simple(0,function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if ENT then ENT = ENT.t else return end
	if not ENT.Spawner then return end
	
	local foundtable
	for _,v in pairs(ENT.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = true break end
	end
	
	if not foundtable then
		table.insert(ENT.Spawner,{tablename,readtablename,"List",{"Default",paramname}})
		inserted_index = 2
	else
		for _,v in pairs(ENT.Spawner) do
			if istable(v) and v[1] == tablename then
				inserted_index = table.insert(v[4],paramname)
			end
		end
	end
	
	if SERVER then return end
	
	local function RemoveEnt(ent)if ent then SafeRemoveEntity(ent) end end
	
	local function UpdateModelCallBack(ENT,cprop,modelcallback,callback)
		
		if modelcallback then
			local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
			ENT.ClientProps[cprop].modelcallback = function(wag,...)
				return modelcallback(wag,...) or oldmodelcallback(wag,...)
			end
		end
		
		if callback then
			local oldcallback = ENT.ClientProps[cprop].callback or function() end
			ENT.ClientProps[cprop].callback = function(wag,...)
				oldcallback(wag,...)
				callback(wag,...)
			end
		end
		
		--удаление пропа при апдейте спавнером для принудительного обновленяи модели
		local oldupdate = ENT.UpdateWagonNumber or function() end
		ENT.UpdateWagonNumber = function(wag,...)
			RemoveEnt(wag.ClientEnts[cprop])
			oldupdate(wag,...)
		end
	end
	
	
	matspath = matspath:sub(11)
	local defaultmatspath = "models/metrostroi_train/common/routes/ezh/m"
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	for i = 1,2 do
		UpdateModelCallBack(
			ENT,
			"route"..i,
			nil,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then 
					local ent = wag.ClientEnts and wag.ClientEnts["route"..i]
					if not IsValid(ent) then return end	
					for i = 0,9 do
						ent:SetSubMaterial(i,matspath..i)
					end
				end
				if wag:GetNW2Int(tablename,0) == 1 then
					local ent = wag.ClientEnts and wag.ClientEnts["route"..i]
					if not IsValid(ent) then return end
					for i = 0,9 do
						ent:SetSubMaterial(i,defaultmatspath..i)
					end
				end
			end
		)
	end
	
end)


