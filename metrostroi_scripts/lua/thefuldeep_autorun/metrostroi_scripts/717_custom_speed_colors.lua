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


if CLIENT then
	MetrostroiWagNumUpdateRecieve = MetrostroiWagNumUpdateRecieve or function(index)
		local ent = Entity(index)
		--таймер, чтобы дождаться обновления сетевых значений (ну а вдруг)
		timer.Simple(0.3,function()
			if IsValid(ent) and ent.UpdateWagNumCallBack then 
				ent:UpdateWagNumCallBack()
				--ent:UpdateTextures()
			end
		end)
	end
end

if SERVER then
	local hooks = hook.GetTable()
	if not hooks.MetrostroiSpawnerUpdate or not hooks.MetrostroiSpawnerUpdate["Call hook on clientside"] then
		hook.Add("MetrostroiSpawnerUpdate","Call hook on clientside",function(ent)
			if not IsValid(ent) then return end
			local idx = ent:EntIndex()
			for _,ply in pairs(player.GetHumans())do
				if IsValid(ply)then ply:SendLua("MetrostroiWagNumUpdateRecieve("..idx..")")end
			end
		end)
	end
end

local function RemoveEnt(wag,prop)
	local ent = wag.ClientEnts and wag.ClientEnts[prop]
	if IsValid(ent) then SafeRemoveEntity(ent)end
end

local function UpdateModelCallBack(ENT,cprop,callback,precallback)	
	local modelcallback
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	if modelcallback then
		local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
		ENT.ClientProps[cprop].modelcallback = function(wag,...)
			return modelcallback(wag) or oldmodelcallback(wag,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if precallback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			precallback(wag,cent)
			oldcallback(wag,cent,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if callback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			oldcallback(wag,cent,...)
			callback(wag,cent)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
end


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
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	for i = 1,2 do
		local propname = i == 1 and "SSpeed1" or "SSpeed2"
			UpdateModelCallBack(
				ENT,
				propname,
				function(wag,cent)
					if wag:GetNW2Int(tablename,0) == inserted_index1 then cent:SetColor(color_white)
					elseif wag:GetNW2Int(tablename,0) == inserted_index2 then cent:SetColor(color_255_0_0)
					elseif wag:GetNW2Int(tablename,0) == inserted_index3 then cent:SetColor(color_0_255_0)
					elseif wag:GetNW2Int(tablename,0) == inserted_index4 then cent:SetColor(color_0_0_255)
					end
				end
			)
	end
	
end)