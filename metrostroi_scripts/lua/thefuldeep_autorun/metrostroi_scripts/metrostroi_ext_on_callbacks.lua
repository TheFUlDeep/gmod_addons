--ВНИМАНИЕ
--metrostroi ext не должен быть в коллекции сервера!!! (чтобы не было их скриптов)

--мне не нравится, что у emm все на финках, поэтому напишу аналог на коллбэках

if SERVER then 
	resource.AddWorkshop("2240199465") 
end



hook.Add("InitPostEntity","Metrostroi extrinsions on callbacks",function()
	--TODO кран выключения дверей
	--НОМЕРНОЙ
	local NOMER_CUSTOM = scripted_ents.GetStored("gmod_subway_81-717_mvm_custom")
	if NOMER_CUSTOM then NOMER_CUSTOM = NOMER_CUSTOM.t else return end--больше таких проверок делать не надо, так как 718 точно прогрузится, если 717 есть
	local NOMER = scripted_ents.GetStored("gmod_subway_81-717_mvm").t
	local NOMER_714 = scripted_ents.GetStored("gmod_subway_81-714_mvm").t
	
	local UpdateModelCallBack
	local RemoveEnt
	if CLIENT then
		RemoveEnt = function(ent)if ent then SafeRemoveEntity(ent) end end
		UpdateModelCallBack = function(ENT,cprop,modelcallback,callback,precallback)
			if modelcallback then
				local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
				ENT.ClientProps[cprop].modelcallback = function(wag,...)
					return modelcallback(wag,...) or oldmodelcallback(wag,...)
				end
			end
			
			if callback then
				local oldcallback = ENT.ClientProps[cprop].callback or function() end
				ENT.ClientProps[cprop].callback = function(wag,cent,...)
					if precallback then precallback(wag,cent,...)end
					oldcallback(wag,cent,...)
					callback(wag,cent,...)
				end
			end
			
			--удаление пропа при апдейте спавнером для принудительного обновленяи модели
			local oldupdate = ENT.UpdateWagonNumber or function() end
			ENT.UpdateWagonNumber = function(wag,...)
					RemoveEnt(wag.ClientEnts and wag.ClientEnts[cprop])
				oldupdate(wag,...)
			end
		end
	end
	
	--ТИП САЛОНА
	local interior_type_dot_five_index = -1
	local foundtable
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "interrior_type" then foundtable = k break end
	end
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"interrior_type","Тип салона","List",{"Default",".5M"}})
		interior_type_dot_five_index = 2
	else
		interior_type_dot_five_index = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],".5M")
	end
	if CLIENT then
		UpdateModelCallBack(
			NOMER,
			"salon",
			function(wag)
				if wag:GetNW2Int("interrior_type",0) == interior_type_dot_five_index then return "models/cralix/interior_mvm.mdl" end
			end,
			function(wag,cent)
				if wag:GetNW2Int("interrior_type",0) == interior_type_dot_five_index then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
			end
		)
		UpdateModelCallBack(
			NOMER_714,
			"salon",
			function(wag)
				if wag:GetNW2Int("interrior_type",0) == interior_type_dot_five_index then return "models/cralix/interior_mvm_int.mdl" end
			end,
			function(wag,cent)
				if wag:GetNW2Int("interrior_type",0) == interior_type_dot_five_index then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
			end
		)
	end
	
	--ТИП СИДЕНИЙ
	local seats_index1 = -1
	local seats_index2 = -1
	foundtable = nil
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "SeatType" then foundtable = k break end
	end
	seats_index1 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Колхоз")
	seats_index2 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Антивандальные")


	if CLIENT then
		for _,prop in pairs({"seats_old","seats_new"})do
			UpdateModelCallBack(
				NOMER,
				prop,
				function(wag)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 then return "models/cralix/couch_1592.mdl"
					elseif nw == seats_index2 then return "models/cralix/couch_9190.mdl"
					end
				end,
				function(wag,cent)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 or nw == seats_index2 then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
				end
			)
		end
		
		for _,prop in pairs({"seats_old_cap","seats_new_cap",})do
			UpdateModelCallBack(
				NOMER,
				prop,
				function(wag)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 then return "models/cralix/couch_1592_cap.mdl"
					elseif nw == seats_index2 then return "models/cralix/couch_9190_cap.mdl"
					end
				end,
				function(wag,cent)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 or nw == seats_index2 then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
				end
			)
		end
		
		for _,prop in pairs({"seats_old","seats_new"})do
			UpdateModelCallBack(
				NOMER_714,
				prop,
				function(wag)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 then return "models/cralix/couch_1592_int.mdl"
					elseif nw == seats_index2 then return "models/cralix/couch_9190_int.mdl"
					end
				end,
				function(wag,cent)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 or nw == seats_index2 then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
				end
			)
		end
		
		for _,prop in pairs({"seats_old_cap","seats_new_cap",})do
			UpdateModelCallBack(
				NOMER_714,
				prop,
				function(wag)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 then return "models/cralix/couch_1592_cap.mdl"
					elseif nw == seats_index2 then return "models/cralix/couch_9190_cap.mdl"
					end
				end,
				function(wag,cent)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 or nw == seats_index2 then cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0))) end
				end
			)
		end
		
		for _,prop in pairs({"seats_old_cap_o","seats_new_cap_o",})do
			UpdateModelCallBack(
				NOMER_714,
				prop,
				function(wag)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 then return "models/cralix/couch_1592_cap_o.mdl"
					elseif nw == seats_index2 then return "models/cralix/couch_9190_cap_o.mdl"
					end
				end,
				function(wag,cent)
					local nw = wag:GetNW2Int("SeatType",0)
					if nw == seats_index1 or nw == seats_index2 then 
						cent:SetPos(wag:LocalToWorld(Vector(0)))
						cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
					end
				end
			)
		end
	end
	
	--ТАБЛИЧКА ИЗГОТОВИТЕЛЯ В САЛОНЕ
	local interrior_nameplate_index1 = -1
	local interrior_nameplate_index2 = -1
	foundtable = nil
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "interrior_nameplate" then foundtable = k break end
	end
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"interrior_nameplate","Табличка изготовителя в салоне","List",{".5M","Default"}})
		interrior_nameplate_index1 = 1
		interrior_nameplate_index2 = 2
	else
		interrior_nameplate_index1 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],".5M")
		interrior_nameplate_index2 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Default")
	end
	if CLIENT then
		NOMER.ClientProps["interrior_nameplate"] = {
				model = "models/cralix/tablichka_717_"..(math.random(1,2))..".mdl",
				pos = Vector(0,0,0),
				ang = Angle(Angle(0,-90,0)),
				hide=2
		}
		
		UpdateModelCallBack(
			NOMER,
			"interrior_nameplate",
			function()
				return "models/cralix/tablichka_717_"..(math.random(1,2))..".mdl"
			end,
			function(wag,cent)
				cent:SetSkin(wag:GetNW2Int("interrior_nameplate",0))
			end
		)
		
		NOMER_714.ClientProps["interrior_nameplate"] = {
            model = "models/cralix/tablichka_7145_"..(math.random(1,2))..".mdl",
            pos = Vector(0,0,0),
            ang = Angle(0,-90,0),
            hide=2
        }
		
		UpdateModelCallBack(
			NOMER_714,
			"interrior_nameplate",
			function(wag)
				local nw = wag:GetNW2Int("interrior_nameplate",0)
				if nw == interrior_nameplate_index2 then return "models/cralix/tablichka_7145_2.mdl"
				elseif nw == interrior_nameplate_index1 then return "models/cralix/tablichka_7145_"..(math.random(1,2))..".mdl"
				end
			end,
			function(wag,cent)
				local nw = wag:GetNW2Int("interrior_nameplate",0)
				if nw == interrior_nameplate_index2 then
					cent:SetSkin(2)
				elseif cent:GetModel():sub(-6) == "_2.mdl" then
					cent:SetSkin(1)
				else
					cent:SetSkin(math.random(1,2))
				end
			end
		)
	end
	
	
	--НОВАЯ ДВЕРЬ С ПОРУЧНЕМ
	--я считаю, что ее нет смысла выбирать, поэтому просто заменил стандартную
	if CLIENT then
		NOMER.ClientProps.door2.model = "models/cralix/cab_door.mdl"
	end
	
	
	
	--НОВЫЙ КВ
	local model1 = "models/metrostroi_train/81-717/kv_black.mdl"
	local model2 = "models/metrostroi_train/81-717/kv_white.mdl"
	local model3 = "models/metrostroi_train/81-717/kv_wood.mdl"
	local model4 = "models/metrostroi_train/81-717/kv_yellow.mdl"
	
	foundtable = nil
	local dildo_kv_index = -1
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "KVTypeCustom" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"KVTypeCustom","Тип КВ","List",{"Черный","Белый","Деревянный","Желтый","Дилдо"}})
		dildo_kv_index = 5
	else
		dildo_kv_index = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Дилдо")
	end
	
	if CLIENT then
		UpdateModelCallBack(
			NOMER,
			"Controller",
			function(wag)
				local nw = wag:GetNW2Int("KVTypeCustom",0)
				if nw == dildo_kv_index then return "models/cralix/kv_dildo.mdl"
				elseif nw == 1 then return model1
				elseif nw == 2 then return model2
				elseif nw == 3 then return model3
				elseif nw == 4 then return model4
				end
			end,
			function(wag,cent)
				if wag:GetNW2Int("KVTypeCustom",0) == dildo_kv_index then 
					cent:SetPos(wag:LocalToWorld(Vector(435.854,15.2549,-14.8683)))
					cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,7)))
				end
			end
		)
		
		--не лучшее решение, но я не знаю, как иначе)
		local base_animate = scripted_ents.GetStored("gmod_subway_base").t.Animate
		NOMER.Animate = function(self,prop,val,min,max,...)
			if prop == "Controller" and self:GetNW2Int("KVTypeCustom",0) == dildo_kv_index then
				min = 0
				max = 1
			end
			return base_animate(self,prop,val,min,max,...)
		end
	end
	
	
	--НОВЫЙ ЗВУК КВ
	foundtable = nil
	local kv_sounds_index = -1
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "KVSoundsType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"KVSoundsType","Тип звуков КВ","List",{"Default","Ext"}})
		kv_sounds_index = 2
	else
		kv_sounds_index = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Ext")
	end
	if CLIENT then
		local defaultsounds = {}
		local names = {
			"kv70_0_t1",
			"kv70_t1_0_fix",
			"kv70_t1_0",
			"kv70_t1_t1a",
			"kv70_t1a_t1",
			"kv70_t1a_t2",
			"kv70_t2_t1a",
			"kv70_0_x1",
			"kv70_x1_0",
			"kv70_x1_x2",
			"kv70_x2_x1",
			"kv70_x2_x3",
			"kv70_x3_x2"
		}
		for i = 1,#names do names[#names+1] = names[i].."_2" end
		local oldinitsounds = NOMER.InitializeSounds
		NOMER.InitializeSounds = function(self,...)
			oldinitsounds(self,...)
			for _,name in pairs(names)do
				defaultsounds[name] = self.SoundNames[name]
			end
		end
		
		local oldupdate = NOMER.UpdateWagonNumber
		NOMER.UpdateWagonNumber = function(self,...)
			oldupdate(self,...)
			for _, name in pairs(names)do
				self.SoundNames[name] = defaultsounds[name]
			end
			
			if self:GetNW2Int("KVSoundsType",0) == kv_sounds_index then
                 self.SoundNames["kv70_0_t1"] = "subway_trains/extpack/0-t1.mp3"
                 self.SoundNames["kv70_t1_0_fix"] = "subway_trains/extpack/t1-0.mp3"
                 self.SoundNames["kv70_t1_0"] = self.SoundNames["kv70_t1_0_fix"]
                 self.SoundNames["kv70_t1_t1a"] = "subway_trains/extpack/t1-t1a.mp3"
                 self.SoundNames["kv70_t1a_t1"] = "subway_trains/extpack/t1a-t1.mp3"
                 self.SoundNames["kv70_t1a_t2"] = "subway_trains/extpack/t1a-t2.mp3" 
                 self.SoundNames["kv70_t2_t1a"] = "subway_trains/extpack/t2-t1a.mp3"
                 self.SoundNames["kv70_0_x1"] = "subway_trains/extpack/0-x1.mp3"
                 self.SoundNames["kv70_x1_0"] = "subway_trains/extpack/x1-0.mp3"
                 self.SoundNames["kv70_x1_x2"] = "subway_trains/extpack/x1-x2.mp3"
                 self.SoundNames["kv70_x2_x1"] = "subway_trains/extpack/x2-x1.mp3"
                 self.SoundNames["kv70_x2_x3"] = "subway_trains/extpack/x2-x3.mp3"
                 self.SoundNames["kv70_x3_x2"] = "subway_trains/extpack/x3-x2.mp3"
				for i = 1,13 do
					self.SoundNames[names[i+13]] = self.SoundNames[names[i]]
				end
			end
		end
	end
	
	
	--ТИПЫ ВУД
	--вообще мне кажется, что это должно быть в скинах. Но так как я это ни в одном скине не видел, то пускай будет
	foundtable = nil
	local vud_index1 = -1
	local vud_index2 = -1
	local vud_index3 = -1
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "VUDType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"VUDType","Тип ВУД","List",{"Черный","Белый","Коричневый"}})
		vud_index1 = 1
		vud_index2 = 2
		vud_index3 = 3
	else
		vud_index1 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Черный")
		vud_index2 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Белый")
		vud_index3 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Коричневый")
	end
	
	if CLIENT then
		UpdateModelCallBack(
			NOMER,
			"VUD1Toggle",
			function(wag)
				local nw = wag:GetNW2Int("VUDType",0)
				if nw == vud_index1 then return "models/metrostroi_train/switches/vudblack.mdl"
				elseif nw == vud_index2 then return "models/metrostroi_train/switches/vudwhite.mdl"
				elseif nw == vud_index3 then return "models/metrostroi_train/switches/vudbrown.mdl"
				end
			end
		)
	end
	
	--ТИПЫ СХЕМ
	foundtable = nil
	local schemes_index1 = -1
	local schemes_index2 = -1
	for k,v in pairs(NOMER_CUSTOM.Spawner) do
		if istable(v) and v[1] == "SchemesType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(NOMER_CUSTOM.Spawner,6,{"SchemesType","Тип схем","List",{"Старый","Новый"}})
		schemes_index1 = 1
		schemes_index2 = 2
	else
		schemes_index1 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Старый")
		schemes_index2 = table.insert(NOMER_CUSTOM.Spawner[foundtable][4],"Новый")
	end
	
	if CLIENT then
		UpdateModelCallBack(
			NOMER,
			"schemes",
			function(wag)
				local nw = wag:GetNW2Int("SchemesType",0)
				if nw == schemes_index1 then return "models/cralix/schemes.mdl"
				elseif nw == schemes_index2 then return "models/cralix/schemes_new.mdl"
				end
			end
		)
		UpdateModelCallBack(
			NOMER_714,
			"schemes",
			function(wag)
				local nw = wag:GetNW2Int("SchemesType",0)
				if nw == schemes_index1 then return "models/cralix/schemes.mdl"
				elseif nw == schemes_index2 then return "models/cralix/schemes_new.mdl"
				end
			end
		)
	end
	
	
	
	--КНИГА РЕМОНТА
	--если открытая книга все равно пустая, но нет смысла ее открывать)
	table.insert(NOMER_CUSTOM.Spawner,6,{"RepairBook","Книга ремонта","Boolean"})
	if CLIENT then
        NOMER.ClientProps["repairbook_slot"] = {
            model = "models/cralix/repairbook.mdl",
            pos = Vector(0,0,0),
            ang = Angle(0,-90,0),
            hide=2,
        }
        NOMER.ClientProps["repairbook_book"] = {
            model = "models/cralix/repairbook_book.mdl",
            pos = Vector(0,0,0),
            ang = Angle(0,-90,0),
            hide=2,
        }
        
		local oldupdate = NOMER.UpdateWagonNumber
		NOMER.UpdateWagonNumber = function(self,...)
			local nw = self:GetNW2Bool("RepairBook")
			self:ShowHide("repairbook_slot",nw)
			self:ShowHide("repairbook_book",nw)
			oldupdate(self,...)
		end
	end
	
	
	
	
	
	--ТИСУ
	local TISU = scripted_ents.GetStored("gmod_subway_81-718").t
	local TISU_719 = scripted_ents.GetStored("gmod_subway_81-719").t
	
	
	
	--НОВЫЙ КВ
	foundtable = nil
	local kv_index = -1
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == "KVTypeCustom" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(TISU.Spawner,{"KVTypeCustom","Тип КВ","List",{"Default","Тип 1"}})
		kv_index = 2
	else
		kv_index = table.insert(TISU.Spawner[foundtable][4],"Тип 1")
	end
	
	if CLIENT then
		UpdateModelCallBack(
			TISU,
			"controller",
			function(wag)
				if wag:GetNW2Int("KVTypeCustom",0) == kv_index then 
					return "models/cralix/kv718_old.mdl"
				end
			end,
			function(wag,cent)
				if wag:GetNW2Int("KVTypeCustom",0) == kv_index then 
					cent:SetPos(wag:LocalToWorld(Vector(449.164,14.9407,-11.6733)))
					cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
				end
			end
		)
		
		UpdateModelCallBack(
			TISU,
			"Cabine",
			function(wag)
				if wag:GetNW2Int("KVTypeCustom",0) == kv_index then 
					return "models/cralix/cab718.mdl"
				end
			end,
			function(wag,cent)
				if wag:GetNW2Int("KVTypeCustom",0) == kv_index then 
					--cent:SetPos(wag:LocalToWorld(Vector(449.164,14.9407,-11.6733)))
					cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
				end
			end
		)
		
		--не лучшее решение, но я не знаю, как иначе)
		local base_animate = scripted_ents.GetStored("gmod_subway_base").t.Animate
		TISU.Animate = function(self,prop,val,min,max,...)
			if prop == "controller" and self:GetNW2Int("KVTypeCustom",0) == kv_index then
				--val = 1-val
				min = 1
				max = 0
			end
			return base_animate(self,prop,val,min,max,...)
		end
	end
	
	
	--НОВЫЕ ЛАМПЫ
	--TODO позиции и наклоны свечений + дополнительные пропы свечений
	--[[foundtable = nil
	local lamps_index = -1
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == "LampsType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(TISU.Spawner,{"LampsType","Тип ламп","List",{"Default","LED"}})
		lamps_index = 2
	else
		lamps_index = table.insert(TISU.Spawner[foundtable][4],"LED")
	end
	
	if CLIENT then
        TISU.ClientProps["lampled"] = {
            model = "models/cralix/lamps718_led.mdl",
            pos = Vector(0,0,0),
            ang = Angle(0,-90,0),
            hideseat=3.6,
        }
	
        TISU_719.ClientProps["lampled"] = {
            model = "models/cralix/lamps718_led_int.mdl",
            pos = Vector(0,0,0),
            ang = Angle(0,-90,0),
            hideseat=3.6,
        }
		
		local oldupdate = TISU.UpdateWagonNumber
		TISU.UpdateWagonNumber = function(wag,...)
			wag:ShowHide("lampled",wag:GetNW2Int("LampsType",0) == lamps_index)
			oldupdate(wag,...)
		end
		
		local oldupdate = TISU_719.UpdateWagonNumber
		TISU_719.UpdateWagonNumber = function(wag,...)
			wag:ShowHide("lampled",wag:GetNW2Int("LampsType",0) == lamps_index)
			oldupdate(wag,...)
		end
	

		for i = 1,28 do
			UpdateModelCallBack(
				TISU,
				"lamp1_"..i,
				function(wag)
					if wag:GetNW2Int("LampsType",0) == lamps_index then 
						return i < 14 and "models/cralix/lamps718_led_emmisive.mdl" or "models/cralix/lamps718_led_emmisive_mirror.mdl"
					end
				end,
				function(wag,cent)
					if wag:GetNW2Int("LampsType",0) == lamps_index then 
						cent:SetPos(cent:LocalToWorld(Vector(8.3,5,0)))
					end
				end
			)
		end
		
		for i = 1,30 do
			UpdateModelCallBack(
				TISU_719,
				"lamp1_"..i,
				function(wag)
					if wag:GetNW2Int("LampsType",0) == lamps_index then 
						return "models/cralix/lamps718_led_emmisive_mirror.mdl"
					end
				end
			)
		end
		
		UpdateModelCallBack(
			TISU,
			"salon",
			function(wag)
				if wag:GetNW2Int("LampsType",0) == lamps_index then 
					return "models/cralix/interior_salon_718.mdl"
				end
			end,
			function(wag,cent)
				if wag:GetNW2Int("LampsType",0) == lamps_index then 
					cent:SetAngles(wag:LocalToWorldAngles(Angle(0,-90,0)))
				end
			end
		)
	end]]
	
	--НОВЫЕ СИДУШКИ
	foundtable = nil
	local seats_tisu_index1 = -1
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == "SeatsType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(TISU.Spawner,{"SeatsType","Тип сидушек","List",{"Default","Новые"}})
		seats_tisu_index1 = 2
	else
		seats_tisu_index1 = table.insert(TISU.Spawner[foundtable][4],"Новые")
	end
	
	if CLIENT then	
		UpdateModelCallBack(
			TISU,
			"seats",
			function(wag)
				if wag:GetNW2Int("SeatsType",0) == seats_tisu_index1 then
					return "models/metrostroi_train/81-717/couch_new.mdl" 
				end
			end
		)
		UpdateModelCallBack(
			TISU,
			"couch_cap",
			function(wag)
				if wag:GetNW2Int("SeatsType",0) == seats_tisu_index1 then return "models/metrostroi_train/81-717/couch_new_cap.mdl" end
			end
		)
		UpdateModelCallBack(
			TISU_719,
			"seats",
			function(wag)
				if wag:GetNW2Int("SeatsType",0) == seats_tisu_index1 then
					return "models/metrostroi_train/81-717/couch_new_int.mdl" 
				end
			end
		)
		UpdateModelCallBack(
			TISU_719,
			"seats_old_cap",
			function(wag)
				if wag:GetNW2Int("SeatsType",0) == seats_tisu_index1 then return "models/metrostroi_train/81-717/couch_new_cap.mdl" end
			end
		)
		UpdateModelCallBack(
			TISU_719,
			"seats_old_cap_o",
			function(wag)
				if wag:GetNW2Int("SeatsType",0) == seats_tisu_index1 then return "models/metrostroi_train/81-717/couch_new_cap.mdl" end
			end
		)
	end
	
	
	--ТИПЫ СХЕМ
	foundtable = nil
	local schemes_tisu_index1 = -1
	local schemes_tisu_index2 = -1
	for k,v in pairs(TISU.Spawner) do
		if istable(v) and v[1] == "SchemesType" then foundtable = k break end
	end
	
	if not foundtable then
		table.insert(TISU.Spawner,6,{"SchemesType","Тип схем","List",{"Старый","Новый"}})
		schemes_tisu_index1 = 1
		schemes_tisu_index2 = 2
	else
		schemes_tisu_index1 = table.insert(TISU.Spawner[foundtable][4],"Старый")
		schemes_tisu_index2 = table.insert(TISU.Spawner[foundtable][4],"Новый")
	end
	
	if CLIENT then
		UpdateModelCallBack(
			TISU,
			"schemes",
			function(wag)
				local nw = wag:GetNW2Int("SchemesType",0)
				if nw == schemes_tisu_index1 then return "models/cralix/schemes.mdl"
				elseif nw == schemes_tisu_index2 then return "models/cralix/schemes_new.mdl"
				end
			end
		)
		UpdateModelCallBack(
			TISU_719,
			"schemes",
			function(wag)
				local nw = wag:GetNW2Int("SchemesType",0)
				if nw == schemes_tisu_index1 then return "models/cralix/schemes.mdl"
				elseif nw == schemes_tisu_index2 then return "models/cralix/schemes_new.mdl"
				end
			end
		)
	end
end)