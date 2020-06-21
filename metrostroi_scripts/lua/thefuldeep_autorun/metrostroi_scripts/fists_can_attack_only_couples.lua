if CLIENT then return end


local function TraceCouple(owner)
    if not IsValid(owner) then return end
    local ent = owner:GetEyeTraceNoCursor().Entity
    if IsValid(ent) and ent:GetClass() == "gmod_train_couple" then return true end
end

timer.Simple(0,function()
    local weapon = weapons.GetStored("weapon_fists")
    if not weapon then return end
    print("upgrading fists...")
    for i = 1,2 do
        local attack = i == 1 and "PrimaryAttack" or "SecondaryAttack"
        local oldattack = weapon[attack] or function()end
        weapon[attack] = function(self,...)        
            local ostime = os.time()
            if not self.LastAttackTimesTamp or ostime - self.LastAttackTimesTamp > 0 then self.LastAttackTimesTamp = ostime else return end
            if not TraceCouple(self.Owner) then return end
            return oldattack(self,...)
        end
    end
end)

