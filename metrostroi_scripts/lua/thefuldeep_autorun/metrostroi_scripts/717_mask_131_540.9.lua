--https://steamcommunity.com/sharedfiles/filedetails/?id=1939746885
--mask_11_no_logo_2.mdl" с черным лого
if SERVER then
	resource.AddWorkshop("1939746885")
end

local maskmodel = "models/metrostroi_train/81-717/mask_540_9.mdl"
local hlmodel1 = "models/metrostroi_train/81-717/lamps/headlights_540_group1.mdl"
local hlmodel2 = "models/metrostroi_train/81-717/lamps/headlights_540_group2.mdl"
local maatspath = "materials/models/metrostroi_train/81-717/"

local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "1-3-1 540.9"

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


hook.Add("InitPostEntity","Metrostroi 717_mvm 540.9 mask",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if not ENT or not ENT.t then return end
	for _,v in pairs(ENT.t.Spawner or {}) do
		if type(v) == "table" and v[1] == "MaskType" then
			inserted_index = table.insert(v[4],paramname)
			break
		end
	end
end)
if SERVER then return end

local masks = {"mask22_mvm","mask222_mvm","mask222_lvz","mask141_mvm"}

local lights1 = {"Headlights222_1","Headlights141_1","Headlights22_1"}
local lights2 = {"Headlights222_2","Headlights141_2","Headlights22_2"}

hook.Add("InitPostEntity","Metrostroi 717_mvm 540.9 mask2",function()
	local ENT = scripted_ents.GetStored(nomerogg)
	if not ENT or not ENT.t then return else ENT = ENT.t end
	for _,mask in pairs(masks) do
		UpdateModelCallBack(
			ENT,
			mask,
			function(wag)
				return wag:GetNW2Int("MaskType",0) == inserted_index and maskmodel or nil
			end
		)
	end
		
	for _,light in pairs(lights1) do
		UpdateModelCallBack(
			ENT,
			light,
			function(wag)
				return wag:GetNW2Int("MaskType",0) == inserted_index and hlmodel1 or nil
			end
		)
	end
		
	for _,light in pairs(lights2) do
		UpdateModelCallBack(
			ENT,
			light,
			function(wag)
				return wag:GetNW2Int("MaskType",0) == inserted_index and hlmodel2 or nil
			end
		)
	end
end)