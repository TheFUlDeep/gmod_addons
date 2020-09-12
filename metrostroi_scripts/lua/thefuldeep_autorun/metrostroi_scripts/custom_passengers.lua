if SERVER then return end
local tableRandom = table.Random
local entsFindByClass = ents.FindByClass
local tableinsert = table.insert
local mathabs = math.abs
local mathDistance = math.Distance
local mathfloor = math.floor
local mathrandom = math.random

local CycleAnims = {}

local function GetAnimPartsCount(ent,seqName)--нахожу кольцо анимации и вычисляю, сколько там частей
	local id = ent:LookupSequence(seqName)
	local start = 0
	
	local info = ent:GetSequenceInfo(id).anims or {}
	
	for _,v in pairs(info) do start = v break end
	
	local reversed = {}
	for k,v in pairs(info) do
		tableinsert(reversed,1,{k,v})
	end
	
	local End = reversed[1][1]
	
	for _,tbl in pairs(reversed)do
		if tbl[2] == start then End = tbl[1] break end
	end
	
	return mathabs(End-1)
end

hook.Add("Think","Metrostroi custom passengers anims",function()
	local CurTime = CurTime()
	for k,v in pairs(CycleAnims)do
		local ent = v.ent
		if not IsValid(ent) then CycleAnims[k] = nil continue end
		
		
		if CurTime > v["end"] then
			v["end"] = CurTime + v.onepartlen
			if not v.curpart or v.curpart >= v.parts then
				v.curpart = 0
			end
			
			ent:ResetSequence(v.id)
			ent:SetCycle(v.curpart/v.parts)
			ent:SetPlaybackRate(v.playbackrate)
			v.curpart = v.curpart + 1
		end
		
	end
end)

local function StartCycleSequence(ent,seqName,speed)
	speed = speed or 1
	speed = 1/speed
	
	--[[local num = tonumber(seqName)
	if num then
		seqName = ent:GetSequenceList()[num]
	end]]
	
	if CycleAnims[ent] then
		local tbl = CycleAnims[ent]
		if speed ~= tbl.speed then
			local len = ent:SequenceDuration(tbl.id)
			local needparts = mathfloor(speed/len+0.5)
			tbl.curpart = needparts * ((tbl.curpart or 0) / tbl.parts)
			tbl.parts = needparts
			tbl.playbackrate = tbl.seqParts*(1/needparts)
			tbl.onepartlen = len/tbl.seqParts
		end
		if tbl.seqName == seqName then return end
	end
	
	local id,len = ent:LookupSequence(seqName)
	local parts = GetAnimPartsCount(ent,seqName)
	local needparts = mathfloor(speed/len+0.5)
	
	CycleAnims[ent] = {["end"] = 0, id = id, seqName = seqName, speed = speed, ent = ent, seqParts = parts, playbackrate = parts*(1/needparts), onepartlen = len/parts, parts = needparts}
end


local platform_class = "gmod_track_platform"

local humansmodels = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl",
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl",
}

local female_sequences = {2,5,6,7,11,17}
local male_sequences = {2,3,4,6,10}

timer.Simple(1,function()
	local metrostroi_custom_passengers = GetConVar("metrostroi_custom_passengers")
	if not metrostroi_custom_passengers then 
		metrostroi_custom_passengers = CreateClientConVar("metrostroi_custom_passengers","0",true,false,"")
	end
	
	local metrostroi_custom_passengers_bool = metrostroi_custom_passengers:GetBool()

	local function SetNewModel(v)
		if IsValid(v) and not v.ChangedModel then
			v.ChangedModel = true
			local model = tableRandom(humansmodels)
			v:SetAngles(v:GetAngles()+Angle(0,180,0))
			v:SetModel(model)
			--v:SetSkin(mathrandom(1,v:SkinCount()))
			v:ResetSequence(tableRandom(model:find("female",1,true) and female_sequences or male_sequences))
		end
	end

	local PLATFORM = scripted_ents.GetStored(platform_class)
	if PLATFORM then
		PLATFORM = PLATFORM.t
		local oldthink = PLATFORM.Think
		PLATFORM.Think = function(self,...)
			local res = oldthink(self,...)
			if metrostroi_custom_passengers_bool then
				for _,v in pairs(self.ClientModels)do SetNewModel(v)end
				for _,v in pairs(self.CleanupModels) do
					local ent = v.ent
					SetNewModel(ent)
					if IsValid(ent) then 
						ent:SetAngles(ent:GetAngles() + Angle(0,180,0))
						local curpos = ent:GetPos()
						local speed = ent.PrevPos and (mathDistance(curpos[1],curpos[2],ent.PrevPos[1],ent.PrevPos[2])/RealFrameTime())/(640)
						StartCycleSequence(ent,"run_all",speed)
						ent.PrevPos = curpos
					end
				end
			end
			return res
		end
	end
	
	local BASE = scripted_ents.GetStored("gmod_subway_base")
	if BASE then
		BASE = BASE.t
		local oldthink = BASE.Think
		BASE.Think = function(self,...)
			local res = oldthink(self,...)
			if metrostroi_custom_passengers_bool then
			--if self.PassengerEnts then
				for _,v in pairs(self.PassengerEnts)do SetNewModel(v)end
			--end
			end
			
			return res
		end
	end
	
	timer.Create("Metrostroi Custom Passengers positions check",1,0,function()
		metrostroi_custom_passengers_bool = metrostroi_custom_passengers:GetBool()
		if not metrostroi_custom_passengers_bool then return end
		for _,platform in pairs(entsFindByClass(platform_class))do
			if IsValid(platform) and #platform.CleanupModels == 0 then
				for k,pass in pairs(platform.ClientModels)do
					if IsValid(pass) and pass:GetPos() ~= platform.Pool[k].pos then 
						pass:SetPos(platform.Pool[k].pos)
						pass:SetAngles(platform.Pool[k].ang + Angle(0,180,0))
					end
				end
			end
		end
		
		for _,wag in pairs(entsFindByClass("gmod_subway_*"))do
			if IsValid(wag) then
				for k,pass in pairs(wag.PassengerEnts)do
					if IsValid(pass) and pass:GetPos() ~= wag:LocalToWorld(wag.PassengerPositions[k]) then 
						pass:SetPos(wag:LocalToWorld(wag.PassengerPositions[k]))
						pass:SetAngles(Angle(0,math.random(0,360),0))
					end
				end
			end
		end
	end)
end)