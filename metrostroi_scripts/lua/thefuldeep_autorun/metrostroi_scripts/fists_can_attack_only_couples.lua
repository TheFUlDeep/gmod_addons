if CLIENT then return end


local function TraceCouple(owner)
    if not IsValid(owner) then return end
	local trace = owner:GetEyeTraceNoCursor()
    local ent = trace.Entity
    if IsValid(ent) and ent:GetClass() == "gmod_train_couple" then return ent, trace.HitPos end
end

hook.Add("InitPostEntity","upgrade fists for metrostroi",function()
    local weapon = weapons.GetStored("weapon_fists")
    if not weapon then return end
    print("upgrading fists...")
	local distlimit = 50*50
	local oldDealdmg = weapon.DealDamage or function()end
	weapon.DealDamage = function(self,...)
		local couple,hitpos = TraceCouple(self.Owner)
		if not couple or couple and self.Owner:GetShootPos():DistToSqr(hitpos) > distlimit then return end
		oldDealdmg(self,...)
	end
end)

