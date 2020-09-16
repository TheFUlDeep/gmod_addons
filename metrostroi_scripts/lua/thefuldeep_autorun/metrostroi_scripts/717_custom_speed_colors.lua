local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index1 = -1
local inserted_index2 = -1
local inserted_index3 = -1
local inserted_index4 = -1
local paramname1 = "Белый"
local paramname2 = "Красный"
local paramname3 = "Зеленый"
local paramname4 = "Синий"

local tablename = "SpeedColor"
local readtablename = "Цвет скоростемера"
hook.Add("InitPostEntity","Metrostroi 717_mvm custom speed color",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if ENT then ENT = ENT.t else return end
	if not ENT.Spawner then return end
	
	local foundtable
	for k,v in pairs(ENT.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(ENT.Spawner,6,{tablename,readtablename,"List",{"Default",paramname1,paramname2,paramname3,paramname4}})
		inserted_index1 = 2
		inserted_index2 = 3
		inserted_index3 = 4
		inserted_index4 = 5
	else
		inserted_index1 = table.insert(ENT.Spawner[foundtable][4],paramname1)
		inserted_index2 = table.insert(ENT.Spawner[foundtable][4],paramname2)
		inserted_index3 = table.insert(ENT.Spawner[foundtable][4],paramname3)
		inserted_index4 = table.insert(ENT.Spawner[foundtable][4],paramname4)
	end
	
	if SERVER then return end
	
	local function RemoveEnt(ent)if ent then SafeRemoveEntity(ent) end end
	
	local function UpdateModelCallBack(ENT,cprop,callback)
		
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			oldcallback(wag,cent,...)
			callback(wag,cent,...)
		end
		
		--удаление пропа при апдейте спавнером для принудительного обновленяи модели
		local oldupdate = ENT.UpdateWagonNumber or function() end
		ENT.UpdateWagonNumber = function(wag,...)
			RemoveEnt(wag.ClientEnts and wag.ClientEnts[cprop])
			oldupdate(wag,...)
		end
	end
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	for i = 1,2 do
		local propname = i == 1 and "SSpeed1" or "SSpeed2"
			UpdateModelCallBack(
				ENT,
				propname,
				function(wag,cent)
					if wag:GetNW2Int(tablename,0) == inserted_index1 then cent:SetColor(Color(255,255,255))
					elseif wag:GetNW2Int(tablename,0) == inserted_index2 then cent:SetColor(Color(255,0,0))
					elseif wag:GetNW2Int(tablename,0) == inserted_index3 then cent:SetColor(Color(0,255,0))
					elseif wag:GetNW2Int(tablename,0) == inserted_index4 then cent:SetColor(Color(0,0,255))
					end
				end
			)
	end
	
end)