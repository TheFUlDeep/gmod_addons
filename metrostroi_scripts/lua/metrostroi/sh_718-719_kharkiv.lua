--в этом файле микрообновления вресии, которая лежит в воркшопе
--отключена функция UpdateTextures. Убран таймер установки материала для маски
--правильно указан айди аддона
--апгрейды для 718го кроме ЭМУ (но тут меняется логика ЭМУ)
if SERVER then resource.AddWorkshop("2264299764") end

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
	if not hook.MetrostroiSpawnerUpdate or not hook.MetrostroiSpawnerUpdate["Call hook on clientside"] then
		hook.Add("MetrostroiSpawnerUpdate","Call hook on clientside",function(ent)
			if not IsValid(ent) then return end
			local idx = ent:EntIndex()
			for _,ply in pairs(player.GetHumans())do
				if IsValid(ply)then ply:SendLua("MetrostroiWagNumUpdateRecieve("..idx..")")end
			end
		end)
	end
end

--обновление будт происходить при прогрузке пропа или при нажатии спавнером на паравоз
local function UpdateCpropCallBack(ENT,cprop,modelcallback,precallback,callback)	
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	--if cprop then
		if modelcallback then
			local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
			ENT.ClientProps[cprop].modelcallback = function(wag,...)
				return modelcallback(wag) or oldmodelcallback(wag,...)
			end
			
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				oldstartedcallback(wag)
				local newmodel = modelcallback(wag) or ENT.ClientProps[cprop] and ENT.ClientProps[cprop].model
				if newmodel then
					local ent = wag.ClientEnts and wag.ClientEnts[cprop]
					if IsValid(ent) then ent:SetModel(newmodel) end
				end
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
				local ent = wag.ClientEnts and wag.ClientEnts[cprop]
				if IsValid(ent) then precallback(wag,ent) end
				oldstartedcallback(wag)
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
				local ent = wag.ClientEnts and wag.ClientEnts[cprop]
				if IsValid(ent) then callback(wag,ent) end
			end
		end
	--[[else
		if modelcallback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				oldstartedcallback(wag)
				local res = modelcallback(wag)
				if res then wag:SetModel(res)end
			end
		end
		
		if precallback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				precallback(wag)
				oldstartedcallback(wag)
			end
		end
		
		if callback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				oldstartedcallback(wag)
				callback(wag)
			end
		end
	end]]
end

local function RemoveEnt(wag,prop)
	local ent = wag.ClientEnts and wag.ClientEnts[prop]
	if IsValid(ent) then SafeRemoveEntity(ent)end
end
local function UpdateCpropCallBack(ENT,cprop,modelcallback,precallback,callback)	
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	--if cprop then
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
	--[[else
		if modelcallback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				oldstartedcallback(wag)
				local res = modelcallback(wag)
				if res then wag:SetModel(res)end
			end
		end
		
		if precallback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				precallback(wag)
				oldstartedcallback(wag)
			end
		end
		
		if callback then
			local oldstartedcallback = ENT.UpdateWagNumCallBack
			ENT.UpdateWagNumCallBack = function(wag)
				oldstartedcallback(wag)
				callback(wag)
			end
		end
	end]]
end

hook.Add("InitPostEntity","Metrostroi 718-719 kharkiv",function()
--timer.Simple(0,function()
	local TISU = scripted_ents.GetStored("gmod_subway_81-718")
	if not TISU then return else TISU = TISU.t end
	local TISU_719 = scripted_ents.GetStored("gmod_subway_81-719").t
	
	
	local body_type_index_old = -1
	local body_type_index_new = -1
	local body_type_read_table_name = Metrostroi and Metrostroi.GetPhrase and Metrostroi.GetPhrase("Spawner.717.BodyType") or "Тип кузова" --на клиенте будет локализировано
	local body_type_table_name = "BodyType"
	local foundtable
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == body_type_table_name then foundtable = k break end
	end
	if not foundtable then
		table.insert(TISU.Spawner,#TISU.Spawner-1,{body_type_table_name,body_type_read_table_name,"List",{"Ранний (1991-1998)","Поздний (2001-2004)"}})
		body_type_index_old = 1
		body_type_index_new = 2
	else
		body_type_index_old = table.insert(TISU.Spawner[foundtable][4],"Ранний (1991-1998)")
		body_type_index_new = table.insert(TISU.Spawner[foundtable][4],"Поздний (2001-2004)")
	end
	
	--local mask_type_index_def = -1
	local mask_type_index_new = -1
	local mask_type_read_table_name = Metrostroi and Metrostroi.GetPhrase and Metrostroi.GetPhrase("Spawner.717.MaskType") or "Тип маски" --на клиенте будет локализировано
	local mask_type_table_name = "MaskType"
	local foundtable
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == mask_type_table_name then foundtable = k break end
	end
	if not foundtable then
		table.insert(TISU.Spawner,#TISU.Spawner-1,{mask_type_table_name,mask_type_read_table_name,"List",{"Default","№0250-0251"}})
		--mask_type_index_def = 1
		mask_type_index_new = 2
	else
		--mask_type_index_def = table.insert(TISU.Spawner[foundtable][4],"Default")
		mask_type_index_new = table.insert(TISU.Spawner[foundtable][4],"№0250-0251")
	end
	
	--table.insert(TISU.Spawner,#TISU.Spawner-1,{"Mask №0250-0251","Маска №0250-0251","Boolean"})
	table.insert(TISU.Spawner,#TISU.Spawner-1,{"Podnojki","Подножки","Boolean"})
	
	local oldent = ENT
	ENT = TISU
	table.insert(TISU.Spawner,4,Metrostroi.Skins.GetTable("CabTexture",Metrostroi and Metrostroi.GetPhrase and Metrostroi.GetPhrase("Common.Spawner.CabTexture") or "Окраска кабины",false,"cab"))--на клиенте будет локализировано
	ENT = oldent
	
	--изменение логики ЭМУ
	local oldtisuinit = TISU.Initialize
	TISU.Initialize = function(wag,...)
		local oldload = wag.LoadSystem
		wag.LoadSystem = function(wag1,tablename,systemname,...)
			if tablename == "RouteNumber" and systemname == "81_718_RouteNumber" then systemname = "81_71_RouteNumber" end
			oldload(wag1,tablename,systemname,...)
		end
		oldtisuinit(wag,...)
	end
	if CLIENT then
		TISU.ClientProps["route1_r"].scale = 0
		TISU.ClientProps["route2_r"].scale = 0
		TISU.ClientProps["route1_s"].scale = 1.2
		TISU.ClientProps["route2_s"].scale = 1.2
		local oldthink = TISU.Think
		TISU.Think = function(wag,...)
			local res = oldthink(wag,...)
			local ents = wag.ClientEnts
			if ents then
				local rn = wag:GetNW2String("RouteNumber","000")
				local ent = ents["route1_s"]
				if IsValid(ent) and ent:GetSkin() ~= rn[1] then ent:SetSkin(rn[1]) end
				ent = ents["route2_s"]
				if IsValid(ent) and ent:GetSkin() ~= rn[2] then ent:SetSkin(rn[2]) end
			end
			return res
		end
	end

	if SERVER then
		for i = 1,2 do
			local TISU = scripted_ents.GetStored(i == 1 and "gmod_subway_81-718" or "gmod_subway_81-719").t
			
			local oldupdate = TISU.TrainSpawnerUpdate
			TISU.TrainSpawnerUpdate = function(wag,...)
				oldupdate(wag,...)
				
				if i == 1 then
					--отключение подножек и маски если кузов .2
					if wag:GetNW2Int(body_type_table_name,0) == body_type_index_new then
						wag:SetNW2Bool("Podnojki",false)
						--wag:SetNW2Bool("Mask №0250-0251",false)
					end
					--кузов 718
					if wag:GetNW2Int(body_type_table_name,0) == body_type_index_old and wag:GetModel() ~= "models/metrostroi_train/81-718/718_body_orig.mdl" then wag:SetModel("models/metrostroi_train/81-718/718_body_orig.mdl")
					elseif wag:GetNW2Int(body_type_table_name,0) == body_type_index_new and wag:GetModel() ~= "models/metrostroi_train/81-718/718_body_mp.mdl" then wag:SetModel("models/metrostroi_train/81-718/718_body_mp.mdl")
					end
				else
					--кузов 719
					if wag:GetNW2Int(body_type_table_name,0) == body_type_index_old and wag:GetModel() ~= TISU.Model then wag:SetModel(TISU.Model)
					elseif wag:GetNW2Int(body_type_table_name,0) == body_type_index_new and wag:GetModel() ~= "models/metrostroi_train/81-718/718_int_body_mp.mdl" then wag:SetModel("models/metrostroi_train/81-718/718_int_body_mp.mdl")
					end
				end
			end
		end
	end

	if CLIENT then
	local TISU = scripted_ents.GetStored("gmod_subway_81-718").t
	
	--СПИДОМЕТР
	for i = 1,2 do
		local propname = "SPU_Speed"..i
		TISU.ClientProps[propname] = {
			model = "models/metrostroi_train/81-717/segments/segment_mvm.mdl",
			pos = Vector(459.65,-3.99+(i-2)*0.92,-5.12),
			hideseat=0.2,
			ang = Angle(90-14.971,180,0),
			scale = 1.25,
			color=Color(175,250,20)
		}
	end
	
	
	--ЭМУ
	for i = 1,2 do
		local propname = "route"..i
		TISU.ClientProps[propname].color = Color(255,0,0)
	end
	
	
	--МАСКА
	UpdateCpropCallBack(
		TISU,
		"Cabine",
		nil,
		function(wag,cent)
			--if not wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7)end
		end,
		function(wag,cent)
			--таймер, потому что сначала вызывается коллбэк, а потом обновление текстуры, и моя текстура заменяется
			--gmod_subwa_base строка 751
			--timer.Simple(0.1,function()
				--if not IsValid(wag) or not IsValid(cent) then return end
				--if wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
				if wag:GetNW2Int(mask_type_table_name,0) == mask_type_index_new and wag:GetNW2Int(body_type_table_name,0) == body_type_index_old then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
			--end)
		end
	)
	--взлом metrostroi ext
	timer.Simple(2,function()
	timer.Simple(0,function()
		local TISU = scripted_ents.GetStored("gmod_subway_81-718").t
		if TISU.ClientProps.Cabine_old then
			UpdateCpropCallBack(
				TISU,
				"Cabine_old",
				nil,
				function(wag,cent)
					--if not wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7)end
				end,
				function(wag,cent)
					--таймер, потому что сначала вызывается коллбэк, а потом обновление текстуры, и моя текстура заменяется
					--gmod_subwa_base строка 751
					timer.Simple(0.1,function()
						if not IsValid(wag) or not IsValid(cent) then return end
						--if wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
						if wag:GetNW2Int(mask_type_table_name,0) == mask_type_index_new and wag:GetNW2Int(body_type_table_name,0) == body_type_index_old then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
					end)
				end
			)
		end
	end)
	end)
	
	
	--ПОДНОЖКИ У МАСКИ
	TISU.ClientProps["podnog_mp"] = {
		model = "models/metrostroi_train/81-718/718_podnog_mp.mdl",
		hide = 2,
		pos = Vector(0),
		ang = Angle(0)
	}
	local oldstartedcallback = TISU.UpdateWagNumCallBack
	TISU.UpdateWagNumCallBack = function(wag)
		wag:ShowHide("podnog_mp",wag:GetNW2Bool("Podnojki"))
		oldstartedcallback(wag)
	end
	
	for i = 1,2 do
		UpdateCpropCallBack(
			TISU,
			"Cabine",
			nil,
			function(wag,cent)
				--if not wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7)end
			end,
			function(wag,cent)
				--таймер, потому что сначала вызывается коллбэк, а потом обновление текстуры, и моя текстура заменяется
				--gmod_subwa_base строка 751
				timer.Simple(0.1,function()
					if not IsValid(wag) or not IsValid(cent) then return end
					--if wag:GetNW2Bool("Mask №0250-0251") then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
					if wag:GetNW2Int(mask_type_table_name,0) == mask_type_index_new and wag:GetNW2Int(body_type_table_name,0) == body_type_index_old then cent:SetSubMaterial(7,"models/metrostroi_train/81_718/mp718_2")end
				end)
			end
		)
	end
	end	
end)

