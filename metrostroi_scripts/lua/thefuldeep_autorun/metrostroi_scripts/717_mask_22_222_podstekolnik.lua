--https://steamcommunity.com/sharedfiles/filedetails/?id=1799298441
--mask_11_no_logo_2.mdl" с черным лого
if SERVER then
	resource.AddWorkshop("1799298441")
end

local maskmodels = {"models/dev4you/fedot/mask_pds_mvm.mdl","models/dev4you/fedot/mask_pds_lvz.mdl","models/dev4you/fedot/mask_pds222_mvm.mdl","models/dev4you/fedot/mask_pds222_lvz.mdl"}
local hlmodel22_1 = "models/dev4you/fedot/headlights_pds_group1.mdl"
local hlmodel22_2 = "models/dev4you/fedot/headlights_pds_group2.mdl"
local hlmodel222_1 = "models/dev4you/fedot/headlights_pds222_group1.mdl"
local hlmodel222_2 = "models/dev4you/fedot/headlights_pds222_group2.mdl"
local maatspath = "materials/models/dev4you/fedot/"

local nomerogg = "gmod_subway_81-717_mvm"
local inserted_indexes = {-1,-1,-1,-1}
local paramnames = {"2-2 Подстекольник МВМ","2-2 Подстекльник ЛВЗ","2-2-2 Подстекольник МВМ","2-2-2 Подстекольник ЛВЗ"}

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

local function UpdateModelCallBack(ENT,cprop,modelcallback,callback,precallback)	
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

hook.Add("InitPostEntity","Metrostroi 717_mvm podsteklo",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if not ENT or not ENT.t then return end
	for _,v in pairs(ENT.t.Spawner or {}) do
		if type(v) == "table" and v[1] == "MaskType" then
			for k, paramname in pairs(paramnames) do
				inserted_indexes[k] = table.insert(v[4],paramname)
			end
			break
		end
	end
end)
if SERVER then return end


local masks = {"mask22_mvm","mask222_mvm","mask222_lvz","mask141_mvm"}

local lights1 = {"Headlights222_1","Headlights141_1","Headlights22_1"}
local lights2 = {"Headlights222_2","Headlights141_2","Headlights22_2"}

hook.Add("InitPostEntity","Metrostroi 717_mvm podsteklo2",function()
	local ENT = scripted_ents.GetStored(nomerogg)
	if not ENT or not ENT.t then return else ENT = ENT.t end
	for i = 1,4 do
		for _,mask in pairs(masks) do
			UpdateModelCallBack(
				ENT,
				mask,
				function(wag)
					return wag:GetNW2Int("MaskType",0) == inserted_indexes[i] and maskmodels[i] or nil
				end,
				function(wag)
					if wag:GetNW2Int("MaskType",0) ~= inserted_indexes[i] then return end
					local ent = wag.ClientEnts and wag.ClientEnts[mask]
					if IsValid(ent) then
						ent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
					end
				end
			)
		end
		
		for _,light in pairs(lights1) do
			UpdateModelCallBack(
				ENT,
				light,
				function(wag)
					return wag:GetNW2Int("MaskType",0) == inserted_indexes[i] and ((i == 1 or i == 2) and hlmodel22_1 or hlmodel222_1) or nil
				end,
				function(wag)
					if wag:GetNW2Int("MaskType",0) ~= inserted_indexes[i] then return end
					local ent = wag.ClientEnts and wag.ClientEnts[light]
					if IsValid(ent) then
						ent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
					end
				end
			)
		end
		
		for _,light in pairs(lights2) do
			UpdateModelCallBack(
				ENT,
				light,
				function(wag)
					return wag:GetNW2Int("MaskType",0) == inserted_indexes[i] and ((i == 1 or i == 2) and hlmodel22_2 or hlmodel222_2) or nil
				end,
				function(wag)
					if wag:GetNW2Int("MaskType",0) ~= inserted_indexes[i] then return end
					local ent = wag.ClientEnts and wag.ClientEnts[light]
					if IsValid(ent) then
						ent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
					end
				end
			)
		end
	end
end)