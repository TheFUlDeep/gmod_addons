if SERVER then return end

local maxdist = 4000^2
local hlimit = 1000--вместо этого будет IsDormant
local vec = Vector(3.8,50,5)
local ang = Angle(0,180,-30)

local cvar = GetConVar("show_rcs_names")
if not cvar then cvar = CreateClientConVar("show_rcs_names","1",true,false,"", 0, 1) end

local CEnts = {}
local scale = 3
local symboloffset = 3
timer.Create("Metrostroi RC names",1,0,function()
	if not cvar:GetBool() then--если выключено, то все удалить
		for sig,symbols in pairs(CEnts)do
			if symbols then
				for k,v in ipairs(symbols)do
					SafeRemoveEntity(v)
				end
			end
			CEnts[sig] = nil
		end
		return
	end

	local ply = LocalPlayer and LocalPlayer()
	if not ply then return end
	local plypos = ply:GetPos()
	
	for sig,rcnames in pairs(CEnts)do--проверяю, надо ли удалить
		if not IsValid(sig) then
			if rcnames then
				for k,v in ipairs(rcnames) do
					SafeRemoveEntity(v)
				end
			end
			CEnts[sig] = nil
		end
	end
	
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.ARSOnly then continue end
		if sig:IsDormant() or sig:GetPos():DistToSqr(plypos) > maxdist or math.abs(sig:GetPos().z - plypos.z) > hlimit then--проверяю, надо ли удалить
			if CEnts[sig] then 
				for k,v in ipairs(CEnts[sig])do
					SafeRemoveEntity(v)
				end
				CEnts[sig] = nil
			end
		else
			if CEnts[sig] then--проверяю, надо ли зареспавнить
				local delete = sig.Name ~= CEnts[sig].RCName
				if not delete then
					for k,v in ipairs(CEnts[sig])do
						if not IsValid(v) then delete = true break end
					end
				end
				if delete or not same_name then
					for k,v in ipairs(CEnts[sig])do
						SafeRemoveEntity(v)
					end
					CEnts[sig] = nil
				end
			end
		
			if not CEnts[sig] and sig.Name then--спавню, если надо
				local len = sig.Name:len()
				if len > 0 then
					CEnts[sig] = {}
					CEnts[sig].RCName = sig.Name
					CEnts[sig].count = len
					for i = 1,len do
						local ent = ClientsideModel("models/metrostroi/signals/mus/sign_letter_small.mdl")
						CEnts[sig][i] = ent
						if IsValid(ent) then
							ent:SetModelScale(scale)
							for k,v in pairs(ent:GetMaterials()) do
								if v:find("models/metrostroi/signals/let/let_start") then
									ent:SetSubMaterial(k-1,"models/metrostroi/signals/let/"..(Metrostroi.LiterWarper[sig.Name[i]] or sig.Name[i]))
								end
							end
						end
					end
				end
			end
			
			if CEnts[sig] then
				local offset = (CEnts[sig].count*symboloffset*scale)/2
				for k,v in ipairs(CEnts[sig]) do
					if IsValid(v) then
						v:SetPos(sig:LocalToWorld(vec+Vector(offset+k*-symboloffset*scale,0,0)))
						v:SetAngles(sig:LocalToWorldAngles(ang))
					end
				end
			end
		end
	end
end)