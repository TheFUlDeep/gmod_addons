if CLIENT then return end

hook.Add("OnEntityCreated","Disabling collisions on some props for metrostroi",function(ent)
	timer.Simple(0.5,function()
		if not IsValid(ent) then return end
		local Class = ent:GetClass():lower()
		if Class:find("streamradio",1,true) or Class:find("camera",1,true) or Class:find("mediaplayer",1,true) then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end
	end)
end)