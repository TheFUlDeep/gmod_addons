if SERVER then
	resource.AddWorkshop("2152040472")
end


local nomerogg = "gmod_subway_81-717_mvm"
local inserted_index = -1
local paramname = "Round"

local tablename = "VaAType"
local readtablename = "Тип вольтметра и амперметра"
timer.Simple(0,function()
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
	
	local ENT = scripted_ents.GetStored(nomerogg).t
	
	ENT.ClientProps["RoundVaALight"] = {
        model = "models/dev4you/new_voltm/new_voltm_light.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        hideseat = 0.2,
	}
	
	ENT.ClientProps["RoundVaA"] = {
        model = "models/dev4you/new_voltm/new_voltm.mdl",
        pos = Vector(0,0,0),
        ang = Angle(0,0,0),
        hideseat = 0.2,
	}
	
	UpdateModelCallBack(
		ENT,
		"RoundVaA",
		nil,
		function(wag)--скрываю, если ентити есть, но его не должно быть
			if wag:GetNW2Int(tablename,0) ~= inserted_index then wag:ShowHide("RoundVaA",false) end
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"cabine_mvm",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then 
				wag:ShowHide("RoundVaA",true)--показываю новые датчики
				--не уверен на сто процентов в работе ShowHide датчиков через кабину
				return "models/dev4you/new_voltm/cabine_mvm_new_voltm.mdl" 
			end
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"cabine_lvz",
		function(wag)
			if wag:GetNW2Int(tablename,0) == inserted_index then 
				wag:ShowHide("RoundVaA",true)--показываю новые датчики
				--не уверен на сто процентов в работе ShowHide датчиков через кабину
				return "models/dev4you/new_voltm/cabine_lvz_new_voltm.mdl" 
			end
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"ampermeter",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
			local ent = wag.ClientEnts and wag.ClientEnts.ampermeter
			if not IsValid(ent)then return end
			ent:SetPos(wag:LocalToWorld(Vector(449.799988,-33.349998,14.5)))
			ent:SetAngles(wag:LocalToWorldAngles(Angle(90,0,20)))
		end
	)
	
	UpdateModelCallBack(
		ENT,
		"voltmeter",
		nil,
		function(wag)
			if wag:GetNW2Int(tablename,0) ~= inserted_index then return end
			local ent = wag.ClientEnts and wag.ClientEnts.voltmeter
			if not IsValid(ent)then return end
			ent:SetPos(wag:LocalToWorld(Vector(451.399994,-28.923,14.3)))
			ent:SetAngles(wag:LocalToWorldAngles(Angle(90,0,20)))
		end
	)
	
	local oldthink = ENT.Think
	ENT.Think = function(self,...)
		local res = oldthink(self,...)
		self:ShowHide("RoundVaALight",self:GetNW2Int(tablename,0) == inserted_index and self:GetPackedBool("PanelLights"))
		return res
	end
	
end)


