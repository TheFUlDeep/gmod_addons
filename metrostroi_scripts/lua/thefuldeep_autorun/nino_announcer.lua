--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	for k,v in pairs(Metrostroi.TrainClasses) do
		if not v:find("717",1,true) then continue end
		local ENT = scripted_ents.GetStored(v)
		if ENT and ENT.t and ENT.t.Spawner then
			local cont = false
			for k,v in pairs(ENT.t.Spawner) do
				if istable(v) and v[1]=="nino_announcer" then cont = true break end
			end
			if cont then continue end
		
			table.insert(ENT.t.Spawner,{"nino_announcer","Нижегородский информатор","Boolean"})
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

local function UpgradeASNP(ent)
	--print("changing asnp on",ent)
	local queue = ent.Announcer.Queue
	ent.Announcer.Queue = function(self,tbl,...)
		queue(self,tbl,...)
		
		if not ent:GetNW2Bool("nino_announcer") then return end
		
		--добавил проверку, потому что почему-то звук добавляется несоклько раз
		for k, snd in pairs(self.Schedule) do
			if snd[1] == nino_asnp_snd_path then return end
		end
		
		local inserted
		for k, snd in pairs(self.Schedule) do
			if snd[1] and snd[1]:lower():find("click",1,true) then 
				inserted = true 
				table.insert(self.Schedule,k+1,{nino_asnp_snd_path, nino_asnp_snd_len}) 
				break 
			end
		end
		if not inserted then table.insert(self.Schedule,1,{nino_asnp_snd_path, nino_asnp_snd_len}) end
	end
end

hook.Add("OnEntityCreated","nino_announcer",function(ent)
	timer.Simple(1,function()
		if not IsValid(ent) or not ent.Announcer or not ent.Announcer.Queue or not ent.ASNP or not ent.ASNP.AnnQueue then return end
		UpgradeASNP(ent)
	end)
end)