if SERVER then resource.AddWorkshop("2201339930") end

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

local function UpdateCpropCallBack(ENT,cprop,modelcallback,precallback,callback)	
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


hook.Add("InitPostEntity","Metrostroi 720 custom KVs",function()
	local YAUZA = scripted_ents.GetStored("gmod_subway_81-720")
	if not YAUZA then return else YAUZA = YAUZA.t end

	local kv_type_index1 = -1
	local kv_type_index2 = -1
	local kv_type_read_table_name = "Тип КВ asd"
	local kv_type_table_name = "KVTypeCustom"
	local foundtable
	for k,v in pairs(YAUZA.Spawner) do
		if istable(v) and v[1] == kv_type_table_name then foundtable = k break end
	end
	if not foundtable then
		table.insert(YAUZA.Spawner,6,{kv_type_table_name,kv_type_read_table_name,"List",{"Default","Black","White"}})
		kv_type_index1 = 2
		kv_type_index2 = 3
	else
		kv_type_index1 = table.insert(YAUZA.Spawner[foundtable][4],"Black")
		kv_type_index2 = table.insert(YAUZA.Spawner[foundtable][4],"White")
	end
	
	if SERVER then return end
	
	UpdateCpropCallBack(
		YAUZA,
		"controller",
		function(wag)
			if wag:GetNW2Int(kv_type_table_name,0) == kv_type_index1 then return "models/metrostroi_train/skif_kv/kv_black.mdl"
			elseif wag:GetNW2Int(kv_type_table_name,0) == kv_type_index2 then return "models/metrostroi_train/skif_kv/kv_white.mdl"
			end
		end,
		nil,
		function(wag,cent)
			local nw = wag:GetNW2Int(kv_type_table_name,0)
			if nw == kv_type_index1 or nw == kv_type_index2 then
				cent:SetPos(wag:LocalToWorld(Vector(458.114589,25.265604,-29.064625)))
				cent:SetAngles(wag:LocalToWorldAngles(Angle(0.000000,-90.000000,30.589429)))
			end
		end
	)
end)

