--это только для параллелепипедов (OBB)
--TODO написать это на плюсах в качестве модуля


local function IsPointOnSection(point,Start,End,skipLineChecking)
	if not skipLineChecking then
		--проверка, что точка на той же линии
		if (End-Start):GetNormalized() ~= (point-Start):GetNormalized() then return end
	end
	
	local x,y,z = point[1],point[2],point[3]
	local sx,sy,sz = Start[1],Start[2],Start[3]
	local ex,ey,ez = End[1],End[2],End[3]
	--проверка, что точка в пределах отрезка
	if (x >= sx and x <= ex or x >= ex and x <= sx) and (y >= sy and y <= ey or y >= ey and y <= sy) and (z >= sz and z <= ez or z >= ez and z <= sz) then return true end
end


local function IsPointInEntity(ent,vec)
	if not vec then return end
	local vec = ent:WorldToLocal(vec)
	local x,y,z = vec[1],vec[2],vec[3]
	
	local mins = ent:OBBMins()
	local xmin,ymin,zmin = mins[1],mins[2],mins[3]
	
	local maxs = ent:OBBMaxs()
	local xmax,ymax,zmax = maxs[1],maxs[2],maxs[3]
	
	return x <= xmax and x >= xmins and y <= ymax and y >= ymins and z <= zmax and z >= zmins
end


local AnglesForPlanes = {Angle(0,0,0),Angle(90,0,0),Angle(0,90,0)}
local function IsSectionPartInEntity(ent,Start,End)
	if not Start or not End then return end
	if IsPointInEntity(ent,Start) or IsPointInEntity(ent,End) then return true end
	
	local dir = (End-Start)--:GetNormalized()
	
	local entang = ent:GetAngles()
	
	--первое число - вверх - -90, вниз - 90
	--второе число - вправо - -90, влево - 90
	for i = 1,2 do
		local planepos = i == 1 and ent:LocalToWorld(ent:OBBMins()) or ent:LocalToWorld(ent:OBBMaxs())
		for k = 1,3 do
			local planenormal = (entang + AnglesForPlanes[k]):Forward()
			local Intersect = util.IntersectRayWithPlane(Start, dir, planepos, planenormal)
			if IsPointOnSection(Intersect,Start,End,true) then return true end
		end
	end
end