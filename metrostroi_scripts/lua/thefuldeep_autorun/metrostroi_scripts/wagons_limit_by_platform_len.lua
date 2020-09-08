if CLIENT then return end

SetGlobalInt("MaxWagonsByPlatformLen",6)
local minlen
local function hookfunc(ent)
	timer.Simple(2,function()
		if not IsValid(ent) or ent:GetClass() ~= "gmod_track_platform" or not ent.PlatformStart or not ent.PlatformEnd then return end
		local startx = Metrostroi.GetPositionOnTrack(ent.PlatformStart)[1]
		local endx = Metrostroi.GetPositionOnTrack(ent.PlatformEnd)[1]
		if startx and endx then
			local curlen = math.abs(startx.x-endx.x)
			if not minlen or curlen < minlen then 
				minlen = curlen
				local wags = math.floor(curlen/18.5+0.5)--делю и округляю
				SetGlobalInt("MaxWagonsByPlatformLen",wags)
			end
		end
	end)
end

hook.Add("OnEntityCreated","Get smallest platform for wagons limit",hookfunc)


--[[for _,v in pairs(ents.FindByClass("gmod_track_platform"))do
	hookfunc(v)
end]]