if CLIENT then return end

local Ents = {"streamradio","camera","mediaplayer"}

hook.Add("OnEntityCreated","Disabling collisions on some props for metrostroi",function(ent)
	if not IsValid(ent) then return end
	local Class = ent:GetClass():lower()
	for _,v in pairs(Ents) do
		if Class:find(v,1,true) then ent:SetCollisionGroup(COLLISION_GROUP_WORLD) return end
	end
end)