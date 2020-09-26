if SERVER then return end

local maxdist = 3000*3000
local vec = Vector(3.8,50,5)
local ang = Angle(0,180,-30)

local CEnts = {}
local scale = 3
local symboloffset = 3
timer.Create("Metrostroi RC names",1,0,function()
	local ply = LocalPlayer and LocalPlayer()
	if not ply then return end
	local plypos = ply:GetPos()
	
	for sig,rcnames in pairs(CEnts)do
		if not IsValid(sig) then
			if rcnames then
				for k,v in pairs(rcnames) do
					SafeRemoveEntity(v)
				end
			end
			CEnts[sig] = nil
		end
	end
	
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.ARSOnly then continue end
		if sig:GetPos():DistToSqr(plypos) > maxdist then
			if sig.RCNames then 
				for k,v in pairs(sig.RCNames)do
					SafeRemoveEntity(v)
				end
				sig.RCNames = nil
			end
		else
			if sig.RCNames then
				local delete
				for k,v in pairs(sig.RCNames)do
					if not IsValid(v) then delete = true break end
				end
				if delete or sig.Name ~= sig.RCName then
					for k,v in pairs(sig.RCNames)do
						SafeRemoveEntity(v)
					end
					sig.RCNames = nil
				end
			end
		
			if not sig.RCNames and sig.Name then
				sig.RCName = sig.Name
				local len = sig.Name:len()
				if len > 0 then
					sig.RCNames = {}
					for i = 1,len do
						sig.RCNames[i] = ClientsideModel("models/metrostroi/signals/mus/sign_letter_small.mdl")
						sig.RCNames[i]:SetModelScale(scale)
						for k,v in pairs(sig.RCNames[i]:GetMaterials()) do
							if v:find("models/metrostroi/signals/let/let_start") then
								sig.RCNames[i]:SetSubMaterial(k-1,"models/metrostroi/signals/let/"..(Metrostroi.LiterWarper[sig.Name[i]] or sig.Name[i]))
							end
						end
					end
					CEnts[sig] = sig.RCNames
				end
			end
			
			if sig.RCNames then
				local offset = (#sig.RCNames*symboloffset*scale)/2
				for k,v in pairs(sig.RCNames) do
					if IsValid(v) then
						v:SetPos(sig:LocalToWorld(vec+Vector(offset+k*-symboloffset*scale,0,0)))
						v:SetAngles(sig:LocalToWorldAngles(ang))
					end
				end
			end
		end
	end
end)