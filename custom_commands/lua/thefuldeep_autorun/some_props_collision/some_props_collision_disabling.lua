if CLIENT then return end

local Ents = {"streamradio","camera","mediaplayer"}

local function func(ent)
	if not IsValid(ent) then return end
	local Class = ent:GetClass():lower()
	for _,v in pairs(Ents) do
		if Class:find(v,1,true) then ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)return end
	end
end

hook.Add("OnEntityCreated","Disabling collisions on some props for metrostroi",function(ent)
	--делаю два раза, потому что с одного раза почему-то для камеры не ставится нужная коллизия
	func(ent)
	timer.Simple(0,function()func(ent)end)
end)