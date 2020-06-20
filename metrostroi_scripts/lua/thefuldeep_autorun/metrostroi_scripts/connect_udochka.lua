local entsFindByClass=ents.FindByClass
local entsFindAlongRay = ents.FindAlongRay
local mathabs = math.abs
local mathfloor = math.floor
local mathmax = math.max

--тут сохранение позиции удочек
local uposes={}
if SERVER then
	local function SaveUPoses(u)
		if not IsValid(u) or u:GetClass()~="gmod_track_udochka"then return end
		local upos=u:GetPos()
		uposes[u]={u,upos}
		--[[for _,ent in pairs (entsFindAlongRay(Vector(upos[1],upos[2],upos[3]+50),Vector(upos[1],upos[2],upos[3]+500)))do
			if not IsValid(ent) then continue end
			--uposes[#uposes+1]={ent,u:WorldToLocal(ent:GetPos()),ent:GetMoveType()}
			uposes[#uposes+1]=ent
		end]]
	end
	hook.Add("OnEntityCreated","Save Udocka's poses for connect_udockka.lua",function(ent)
		timer.Simple(0,function()SaveUPoses(ent)end)
	end)
	
	for _,v in pairs(entsFindByClass("gmod_track_udochka"))do SaveUPoses(v) end
end

local function SetUPos(u,pos)
	if u:IsPlayerHolding()or IsValid(u.Coupled)then return end
	--u:SetMoveType(MOVETYPE_FLY)
	--u:SetMoveType(MOVETYPE_NONE)
	u:SetMoveType(MOVETYPE_NOCLIP)
	--[[local upos=u:GetPos()
	local delta1=mathabs(upos[1]-pos[1])
	local delta2=mathabs(upos[2]-pos[2])
	local delta3=mathabs(upos[3]-pos[3])
	local k
	if delta1 > delta2 and delta1 > delta3 then k=1
	elseif delta2 > delta1 and delta2 > delta3 then k=2
	elseif delta3 > delta1 and delta3 > delta2 then k=3
	end]]
	

	u:SetPos(pos)
	timer.Simple(2,function()
		if IsValid(u) then u:SetMoveType(MOVETYPE_VPHYSICS)end
	end)
	--[[local skip={[1]=true,[2]=true}
	for j,v in pairs(uposes[u])do
		if skip[j] or not IsValid(v) then continue end
		local newpos=v:GetPos()
		newpos[k]=upos[k]
		v:SetPos(newpos)
	end]]
end

local function connect(ply)
	if CLIENT then return end
	--все неподключенные удочки возвращаю на родину
	for k,u in pairs(uposes)do
		if IsValid(u[1])then 
			SetUPos(u[1],u[2])
		else
			uposes[k]=nil
		end
	end
		
	local seat=ply:GetVehicle()
	if not IsValid(seat)then ply:ChatPrint("Ты не в сидушке")return end
	local wag=seat:GetNW2Entity("TrainEntity")
	if not IsValid(wag)then ply:ChatPrint("Ты не в составе")return end
	--проверка на головной вагон - он должен быть сцеплен с другим только с одной стороны
	local rc=IsValid(wag.RearCouple)and IsValid(wag.RearCouple.CoupledEnt)and IsValid(wag.RearCouple.CoupledEnt:GetNW2Entity("TrainEntity"))
	local fc=IsValid(wag.FrontCouple)and IsValid(wag.FrontCouple.CoupledEnt)and IsValid(wag.FrontCouple.CoupledEnt:GetNW2Entity("TrainEntity"))
	if rc and fc then ply:ChatPrint("Ты не в головном вагоне")return end
		
	--проверка на то,что к составу не подключена ни одна удочка
	local bogeys={}
	for _,wag1 in pairs(wag.WagonList or {wag})do
		if IsValid(wag1.FrontBogey)then bogeys[wag1.FrontBogey]=true end
		if IsValid(wag1.RearBogey)then bogeys[wag1.RearBogey]=true end
	end
	for _,ent in pairs(uposes)do
		if IsValid(ent[1].Coupled)and bogeys[ent[1].Coupled]then ply:ChatPrint("К составу уже подключена удочка")return end
	end
	
	--проверка, есть ли у состава напряжение от контакного рельса
	local uconnects={}
	for _,u in pairs(uposes)do
		if IsValid(u[1].Coupled)then uconnects[u[1].Coupled]=u[1] end
	end

	for _,wag1 in pairs(wag.WagonList or{wag})do
		if not IsValid(wag1)then continue end
		
		local rb=wag1.RearBogey
		local fb=wag1.FrontBogey
		if IsValid(rb)and rb.Voltage>0 and not uconnects[rb] or IsValid(fb)and fb.Voltage>0 and not uconnects[fb]then
			ply:ChatPrint("Состав на контактном рельсе")
			return
		end
	end
	
	local curwagpos=wag:GetPos()
	--прохожусь по всем удочкам и ищу ту, которая справа от вагона и самая ближняя
	local mindist,nearestudochka
	
	
	local curwagang = wag:GetAngles()
	local lastwag = wag.WagonList and wag.WagonList[#wag.WagonList] or wag
	local lastwagang = lastwag:GetAngles()
	local sameang=mathabs(lastwagang[1]-curwagang[1]) < 5 and mathabs(lastwagang[2]-curwagang[2]) < 5 and mathabs(lastwagang[3]-curwagang[3]) < 5
	local lastwagminlocal = lastwag:OBBMins()
	local lastwagmin = lastwag:LocalToWorld(lastwagminlocal)
	local lastwagmaxlocal = lastwag:OBBMaxs()
	local lastwagmax = lastwag:LocalToWorld(lastwagmaxlocal)
	local curwagminlocal = wag:OBBMins()
	local curwagmin = wag:LocalToWorld(curwagminlocal)
	local curwagmaxlocal = wag:OBBMaxs()
	local curwagmax= wag:LocalToWorld(curwagmaxlocal)
	local obbmin,obbmax
	local obbang = wag:GetAngles()
	if sameang then
		if lastwagmin:DistToSqr(curwagmax) < curwagmin:DistToSqr(lastwagmax) then
			obbmin=curwagmin
			obbmax=lastwagmax
		else
			obbmin=lastwagmin
			obbmax=curwagmax
		end
	else
		if curwagmax:DistToSqr(lastwagmax) > lastwagmin:DistToSqr(curwagmin) then
			lastwagmaxlocal[3]=-lastwagmaxlocal[3]
			obbmin=lastwag:LocalToWorld(lastwagmaxlocal)
			obbmax=curwagmax
		else
			lastwagminlocal[3]=-lastwagminlocal[3]
			obbmin=lastwag:LocalToWorld(lastwagminlocal)
			obbmax=curwagmin
		end
	end
	

	--if 1 then return end
	--перпендикуляр к составу, проходящий через удочку (+Vector(0,0,100)) должен пересекать плоскость вагона и расстояние от удочки до точки пересечения должно быть меньше 1000
	for _,u in pairs(uposes)do
		local curdist = u[2]:DistToSqr(curwagpos)
		if (not mindist or curdist < mindist) then
			local ang=(u[2]-curwagpos):Angle()
			ang = ang-curwagang
			ang:Normalize()
			if ang[2] > 0 then continue end
			--[[ply:ExitVehicle()
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetPos(u[1]:GetPos())]]
			
			local normal=wag:LocalToWorldAngles(Angle(0,90,0)):Forward()
			local endpoint=util.IntersectRayWithPlane(u[2]+Vector(0,0,100), normal, wag:GetPos(), normal)

			if not endpoint or endpoint:DistToSqr(u[2]) > 300^2 then continue end
			
			local vec=endpoint
			local x,y,z = vec[1],vec[2],vec[3]
			
			local mins = obbmin
			local xmin,ymin,zmin = mins[1],mins[2],mins[3]
			
			local maxs = obbmax
			local xmax,ymax,zmax = maxs[1],maxs[2],maxs[3]
			
			if (x <= xmax and x >= xmin or x >= xmax and x <= xmin) and (y <= ymax and y >= ymin or y >= ymax and y <= ymin) and (z <= zmax and z >= zmin or z >= zmax and z >= zmin) then
				mindist=curdist 
				nearestudochka=u[1] 
			end
		end
	end
	
	if not nearestudochka then ply:ChatPrint("Не удалось найти удочку")return end
	if IsValid(nearestudochka.Coupled) then ply:ChatPrint("Удочка уже куда-то подключена")return end
			
	local function ChooseNearestSide(bogey,pos)
		local fs,ss
		local bogeymodel = bogey:GetModel()
		--if bogeymodel=="models/metrostroi_train/bogey/metro_bogey_717.mdl"then
			fs = bogey:LocalToWorld(Vector(0,bogey:OBBMins()[2]+10,-15))
			ss = bogey:LocalToWorld(Vector(0,bogey:OBBMaxs()[2]-10,-15))
		--end
		if fs:DistToSqr(pos) < ss:DistToSqr(pos) then
			return fs
		else
			return ss
		end
	end
	
	if not fc and not rc then
		if IsValid(wag.RearBogey) then
			local pos=ChooseNearestSide(wag.RearBogey,nearestudochka:GetPos())
			if pos then SetUPos(nearestudochka,pos)end
			ply:ChatPrint("Удочка подключена")
			return
		elseif IsValid(wag.FrontBogey) then
			local pos=ChooseNearestSide(wag.FrontBogey,nearestudochka:GetPos())
			if pos then SetUPos(nearestudochka,pos)end
			ply:ChatPrint("Удочка подключена")
			return
		end
	else
		if IsValid(wag.WagonList[2].FrontBogey) then
			local pos=ChooseNearestSide(wag.WagonList[2].FrontBogey,wag:LocalToWorld(Vector(0,-300,0)))
			if pos then SetUPos(nearestudochka,pos)end
			ply:ChatPrint("Удочка подключена")
			return
		elseif IsValid(wag.WagonList[2].RearBogey) then
			local pos=ChooseNearestSide(wag.WagonList[2].RearBogey,wag:LocalToWorld(Vector(0,-300,0)))
			if pos then SetUPos(nearestudochka,pos)end
			ply:ChatPrint("Удочка подключена")
			return
		end
	end
	
	--пихать удочку в ближайшую найденную тележку с ближайшей стороны, но не в вагон, в котором сидит игрок (если естть прицеп)
		
	
	--local u = {}
	--тут проверка на то, в каком луче из connectbeams находится игрок и подключение удочки,найденной из соответствующего findbeams
	--проверка на то, что удочка ни к чему не подключена
	--if IsValid(u.Coupled)then ply:ChatPrint("Ты не в головном вагоне")continue end
	--если я двигаю удочку, то ply:ChatPrint("Удочка подключена")return end
	ply:ChatPrint("Не удалось найти/подключить удочку")
end

local function disconnect(ply)
	if CLIENT then return end
	local seat=ply:GetVehicle()
	if not IsValid(seat)then ply:ChatPrint("Ты не в сидушке")return end
	local wag=seat:GetNW2Entity("TrainEntity")
	if not IsValid(wag)then ply:ChatPrint("Ты не в составе")return end

	--поиск подключенных удочек к тележкам
	local disconnected
	local bogeys={}
	for _,wag1 in pairs(wag.WagonList or {wag})do
		if IsValid(wag1.FrontBogey)then bogeys[wag1.FrontBogey]=true end
		if IsValid(wag1.RearBogey)then bogeys[wag1.RearBogey]=true end
	end
	for _,ent in pairs(uposes)do
		if IsValid(ent[1])and IsValid(ent[1].Coupled)and bogeys[ent[1].Coupled]then
			ent[1]:Use(ent[1],ent[1],0,0)
			disconnected=true
			SetUPos(ent[1],ent[2])--возвращаю удочку на стартовую позицию
		end
	end
	if disconnected then 
		ply:ChatPrint("Удочка отсоединена")
	else
		ply:ChatPrint("К составу не подключена удочка")
	end
end

timer.Simple(0,function()

	
	if ulx and ulx.command then
		local comm=ulx.command("Metrostroi","ulx connect_udochka",connect,"!connect_udochka",true,false,true)
		comm:defaultAccess(ULib.ACCESS_ALL)
		comm:help("Подключить удочку справа от вагона, в котором сидишь")
	end
	
	if ulx and ulx.command then
		local comm=ulx.command("Metrostroi","ulx disconnect_udochka",disconnect,"!disconnect_udochka",true,false,true)
		comm:defaultAccess(ULib.ACCESS_ALL)
		comm:help("Отключить удочку")
	end
end)

if CLIENT then return end
	
	
timer.Create("Disconnect udochka if train has voltage by third rail",2,0,function()
	--if 1 then return end
	local uconnects={}
	for _,u in pairs(uposes)do
		if IsValid(u[1])and IsValid(u[1].Coupled)then uconnects[u[1].Coupled]=u[1] end
	end

	local checkedwags={}
	for _,wag in pairs(entsFindByClass("gmod_subway_*"))do
		if not IsValid(wag)or checkedwags[wag]then continue end
		
		local hasKR
		for _,wag1 in pairs(wag.WagonList or{wag})do
			if not IsValid(wag1)then continue end
			
			checkedwags[wag1]=true
			if hasKR then continue end--это сделано, чтобы цикл все равно прошелся по всех вагонам в составе и записал их в checkedwags
			local rb=wag1.RearBogey
			local fb=wag1.FrontBogey
			if IsValid(rb)and rb.Voltage>0 and not uconnects[rb] or IsValid(fb)and fb.Voltage>0 and not uconnects[fb]then
				hasKR=true
			end
		end
			
		if not hasKR then continue end
		for _,wag1 in pairs(wag.WagonList or{wag})do
			if not IsValid(wag1)then continue end
				
			local rb=wag1.RearBogey
			if IsValid(rb)then 
				local u=uconnects[rb]
				if u then
					u:Use(u,u,0,0)
					if uposes[u] then SetUPos(u,uposes[u][2])end
				end
			end
				
			local fb=wag1.FrontBogey
			if IsValid(fb)then 
				local u=uconnects[fb]
				if u then
					u:Use(u,u,0,0) 
					if uposes[u] then SetUPos(u,uposes[u][2])end
				end
			end
		end
	end
end)
	
	
 concommand.Add(
	"connect_udochka",
	function(ply)connect(ply)end,
	nil,
	"connects udochka to train"
)
	
 concommand.Add(
	"disconnect_udochka",
	function(ply)disconnect(ply)end,
	nil,
	"disconnects udochka to train"
)

--[[local seats={"DriverSeat","InstructorsSeat","ExtraSeat"}
local function IsSeatFromWagon(wag,myseat)
	for i=0,4 do
		local str=i > 0 and tostring(i)or""
		for _,seat1 in pairs(seats)do
			local seat=seat1..str
			if wag[seat]==myseat then return true end
		end
	end
end]]