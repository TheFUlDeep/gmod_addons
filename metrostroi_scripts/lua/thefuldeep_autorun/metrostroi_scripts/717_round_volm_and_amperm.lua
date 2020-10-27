if SERVER then
	resource.AddWorkshop("2152040472")
end


local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "Round"

local tablename = "VaAType"
local readtablename = "Тип вольтметра и амперметра"

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

hook.Add("InitPostEntity","Metrostroi 717_mvm round voltm and amperm",function()
    local ENT = scripted_ents.GetStored(nomerogg.."_custom")
    if ENT then ENT = ENT.t else return end
	if not ENT.Spawner then return end
	
	local foundtable
	for k,v in pairs(ENT.Spawner) do
		if istable(v) and v[1] == tablename then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(ENT.Spawner,6,{tablename,readtablename,"List",{"Default",paramname}})
		inserted_index = 2
	else
		inserted_index = table.insert(ENT.Spawner[foundtable][4],paramname)
	end
	
	if SERVER then return end
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	ENT.ClientProps["RoundVaALight"] = {
        model = "models/dev4you/new_voltm/new_voltm_light.mdl",
        pos = vector_origin,
        ang = angle_zero,
        --hideseat = 0.2,
		hide = 2
	}
	
	ENT.ClientProps["RoundVaA"] = {
        model = "models/dev4you/new_voltm/new_voltm.mdl",
        pos = vector_origin,
        ang = angle_zero,
        --hideseat = 0.2,
		hide = 2
	}
	
	UpdateModelCallBack(
		ENT,
		"cabine_mvm",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then 
				return "models/dev4you/new_voltm/cabine_mvm_new_voltm.mdl" 
			end
		end
	)
	
	local oldupdate = ENT.UpdateWagNumCallBack
	ENT.UpdateWagNumCallBack = function(self)
		self:ShowHide("RoundVaA",true)
		oldupdate(self)
	end
	
	UpdateModelCallBack(
		ENT,
		"RoundVaA",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then wag:ShowHide("RoundVaA",false)end
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"cabine_lvz",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then 
				return "models/dev4you/new_voltm/cabine_lvz_new_voltm.mdl" 
			end
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"ampermeter",
		nil,
		function(wag,cent)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
			cent:SetPos(wag:LocalToWorld(Vector(449.799988,-33.349998,14.5)))
			cent:SetAngles(wag:LocalToWorldAngles(Angle(90,0,20)))
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"voltmeter",
		nil,
		function(wag,cent)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
			cent:SetPos(wag:LocalToWorld(Vector(451.399994,-28.923,14.3)))
			cent:SetAngles(wag:LocalToWorldAngles(Angle(90,0,20)))
		end
	)
	
	local oldthink = ENT.Think
	ENT.Think = function(self,...)
		local res = oldthink(self,...)
		self:ShowHide("RoundVaALight",self:GetNW2Int(tablename,0) == inserted_index and self:GetPackedBool("PanelLights"))
		return res
	end
	
end)