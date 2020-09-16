if SERVER then resource.AddWorkshop("1563745153") end
local inserted_index1 = -1
local inserted_index2 = -1
local tablename = "ASNPPreSoundType"

hook.Add("InitPostEntity","Metrostroi 717_mvm asnp changing",function()

	local readtablename = "Изменение ASNP"
	local paramname1 = "Нижний Новгород"
	local paramname2 = "Аэроэкспресс"
	
	for k,class in pairs(Metrostroi and Metrostroi.TrainClasses or {}) do
		if not class:find("717",1,true) then continue end
		local ENT = scripted_ents.GetStored(class)
		if ENT.t then ENT = ENT.t else continue end
		
		
		if ENT and ENT.Spawner then		
			local foundtable
			for k,v in pairs(ENT.Spawner) do
				if istable(v) and v[1] == tablename then foundtable = k break end
			end
			
			if not foundtable then
				table.insert(ENT.Spawner,8,{tablename,readtablename,"List",{"Отсутствует",paramname1,paramname2}})
				inserted_index1 = 2
				inserted_index2 = 3
			else
				inserted_index1 = table.insert(ENT.Spawner[foundtable][4],paramname1)
				inserted_index2 = table.insert(ENT.Spawner[foundtable][4],paramname2)
			end
		end
	end
end)


if CLIENT then return end
--[[local ent = Player(2):GetEyeTraceNoCursor().Entity
local ann_queue = ent.ASNP.AnnQueue
local write_message = ent.Announcer.WriteMessage]]

--print("прокачиваю функцию...")

--[[ent.Announcer.WriteMessage = function(self,msg,...)
	print(msg)
	write_message(self,msg,...)
end]]


local nino_asnp_snd_len = 1.8
local nino_asnp_snd_path = "thefuldeeps_sounds/nino_asnp.mp3"
local nino_asnp_sound = Sound(nino_asnp_snd_path)

local aeroexpress_asnp_snd_path = "thefuldeeps_sounds/aeroexpress_asnp.mp3"
local aeroexpress_asnp_snd_len = 3.6
local aeroexpress_asnp_sound = Sound(aeroexpress_asnp_snd_path)

local function UpgradeASNP(ent)
	--print("changing asnp on",ent)
	local queue = ent.Announcer.Queue
	ent.Announcer.Queue = function(self,tbl,...)
		queue(self,tbl,...)
		
		local type = ent:GetNW2Int(tablename,0)
		if type < 2 then return end
		
		local path,len
		
		if type == inserted_index1 then
			path = nino_asnp_snd_path
			len = nino_asnp_snd_len
		elseif type == inserted_index2 then
			path = aeroexpress_asnp_snd_path
			len = aeroexpress_asnp_snd_len
		else
			return
		end
		
		--добавил проверку, потому что почему-то звук добавляется несоклько раз
		for k, snd in pairs(self.Schedule) do
			if snd[1] == path then return end
		end
		
		local inserted
		for k, snd in pairs(self.Schedule) do
			if snd[1] and snd[1]:lower():find("click",1,true) then 
				inserted = true 
				table.insert(self.Schedule,k+1,{path, len}) 
				break 
			end
		end
		if not inserted then table.insert(self.Schedule,1,{path, len}) end
	end
end

hook.Add("OnEntityCreated","asnp pre sound",function(ent)
	timer.Simple(1,function()
		if not IsValid(ent) or not ent.Announcer or not ent.Announcer.Queue or not ent.ASNP or not ent.ASNP.AnnQueue then return end
		UpgradeASNP(ent)
	end)
end)