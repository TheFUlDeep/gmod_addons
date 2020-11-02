do return end
--TODO индекс на сервере не соответствует индексу на клиенте
if SERVER then resource.AddWorkshop("2079217659") end

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

--двигать свет от красных фар на серверной части
hook.Add("InitPostEntity","Metrostroi 717 mask 22 717j",function()
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if not NOMER_CUSTOM then return else NOMER_CUSTOM = NOMER_CUSTOM.t end
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm").t
	
	local masks = {"mask22_mvm","mask222_mvm","mask222_lvz","mask141_mvm"}

	local lights1 = {"Headlights222_1","Headlights141_1","Headlights22_1"}
	local lights2 = {"Headlights222_2","Headlights141_2","Headlights22_2"}
	
	local inserted_index = -1
	
	local tablename = "MaskType"
	
	for _,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == tablename then
			inserted_index = table.insert(v[4],"2-2 717j")
			break
		end
	end
	
	if SERVER then
		local defredlightheight
		local newlightheight = -23.5
	
		local oldupdate = NOMER.TrainSpawnerUpdate
		NOMER.TrainSpawnerUpdate = function(wag,...)
			if defredlightheight then
				wag.Lights[8][2][3] = defredlightheight
				wag:SetLightPower(8)
				wag:SetLightPower(8,0)
				wag.Lights[9][2][3] = defredlightheight
				wag:SetLightPower(9)
				wag:SetLightPower(9,0)
			elseif wag.Lights and wag.Lights[8] and wag.Lights[8][2] then
				defredlightheight = wag.Lights[8][2][3]
			end
			oldupdate(wag,...)
			if wag:GetNW2Int(tablename,0) == inserted_index and wag.Lights and wag.Lights[8] and wag.Lights[8][2] then
				wag.Lights[8][2][3] = newlightheight
				wag:SetLightPower(8)
				wag:SetLightPower(8,0)
				wag.Lights[9][2][3] = newlightheight
				wag:SetLightPower(9)
				wag:SetLightPower(9,0)
			end
		end
	end
	
	if SERVER then return end
	
	for _,prop in pairs(masks)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-713/mask_22s.mdl"end
			end
		)
	end
	
	for _,prop in pairs(lights1)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-713/headlights_22_group2.mdl"end
			end
		)
	end
	
	for _,prop in pairs(lights2)do
		UpdateCpropCallBack(
			NOMER,
			prop,
			function(wag)
				if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-713/headlights_22_group1.mdl"end
			end
		)
	end
	
	UpdateCpropCallBack(
		NOMER,
		"RedLights",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then return "models/metrostroi_train/81-713/redlightss.mdl"end
		end
	)
end)

