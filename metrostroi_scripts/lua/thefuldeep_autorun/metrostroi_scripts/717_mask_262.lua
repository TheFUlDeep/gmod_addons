if SERVER then resource.AddWorkshop("2018098142") end

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


hook.Add("InitPostEntity","Metrostroi 717 mask 262",function()
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if not NOMER_CUSTOM then return else NOMER_CUSTOM = NOMER_CUSTOM.t end
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm").t
	
	local masks = {"mask22_mvm","mask222_mvm","mask222_lvz","mask141_mvm"}

	local lights1 = {"Headlights222_1","Headlights141_1","Headlights22_1"}
	local lights2 = {"Headlights222_2","Headlights141_2","Headlights22_2"}
	
	local inserted_index = -1
	
	local tablename = "MaskType"
	
	for _,v in pairs(NOMER_CUSTOM.Spawner or {}) do
		if istable(v) and v[1] == tablename then
			inserted_index = table.insert(v[4],"2-6-2")
			break
		end
	end
	
	if SERVER then return end
	
	for _,prop in pairs(masks)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-711/mask_540_9.mdl"end
			end
		)
	end
	
	for _,prop in pairs(lights1)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-711/lamps/headlights_540_group1.mdl"end
			end
		)
	end
	
	for _,prop in pairs(lights2)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-711/lamps/headlights_540_group2.mdl"end
			end
		)
	end
end)

