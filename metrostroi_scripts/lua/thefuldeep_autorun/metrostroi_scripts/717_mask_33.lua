--https://steamcommunity.com/sharedfiles/filedetails/?id=2035749253
--mask_11_no_logo_2.mdl" с черным лого
local maskmodel = "models/yaz/mask3-3/maska_33.mdl"
local hlmodel1 = "models/yaz/mask3-3/headlights_33_g1.mdl"
local hlmodel2 = "models/yaz/mask3-3/headlights_33.mdl"

local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "3-3"

if SERVER then
	resource.AddFile(maskmodel)
	resource.AddFile(hlmodel1)
	resource.AddFile(hlmodel2)
end


timer.Simple(0,function()
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


local function RemoveEnt(ent)if ent then SafeRemoveEntity(ent) end end

local function UpdateModelCallBack(ENT,cprop,modelcallback,callback)
	
	if modelcallback then
		local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
		ENT.ClientProps[cprop].modelcallback = function(wag,...)
			return modelcallback(wag) or oldmodelcallback(wag,...)
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


local masks = {"mask22_mvm","mask222_mvm","mask222_lvz","mask141_mvm"}

local lights1 = {"Headlights222_1","Headlights141_1","Headlights22_1"}
local lights2 = {"Headlights222_2","Headlights141_2","Headlights22_2"}

timer.Simple(0,function()
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