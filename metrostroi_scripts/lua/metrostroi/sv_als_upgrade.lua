if CLIENT then return end

--teleport to track
concommand.Add("metrostroi_ttt", function(ply,cmd,args)
	if not IsValid(ply) then print("Эта команда должна вызываться игроком") return end
	if not args[1] or not args[2] then ply:ChatPrint("Не указан айди трека или айди ноуда") return end
	local arg1 = tonumber(args[1])
	local arg2 = tonumber(args[2])
	if not arg1 or not arg2 then ply:ChatPrint("Айди трека и айди ноуда должны быть числами") return end
	local Paths = Metrostroi.Paths
	if not Paths[arg1] or not Paths[arg1][arg2] then ply:ChatPrint("Не найден такой трек с таким ноудом") return end
	ply:ExitVehicle()
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply:SetPos(Paths[arg1][arg2].pos)
end)







local continuations = {}--тут сохраняю связи концов треков, если есть
local maxdist = (384/2)^2
local parts = 3
--максимальная дистанция между ноудами одного трека - 500
--делю каждый ноуд на три части, и тогда лимит в 192 пройдет корректно
local function FindNearNode(node)--довольно медленная функция, но она вызывается только при загрузке сигналки, поэтому пофиг
	local nodepathid = node.path.id
	local nodeid = node.id
	local pos = node.pos
	local nrearestnode,curdist,x,lerptonext
	for pathid,path in pairs(Metrostroi.Paths)do
		for id,node1 in ipairs(path)do
			if pathid == nodepathid and math.abs(id - nodeid) < 5 then continue end--если это соседний ноуд, то пропустить
			local nextnode = node1.next
			for i = 0, nextnode and parts or 0 do
				local lerp = i/parts
				local curpos = LerpVector(lerp,node1.pos,nextnode and nextnode.pos or node1.pos)--делю на части (почему - написано над функцией)
				if nrearestnode then
					if pos:DistToSqr(curpos) < pos:DistToSqr(nrearestnode.pos) then
						nrearestnode = node1
						lerptonext = lerp
					end
				elseif pos:DistToSqr(curpos) < maxdist then
					nrearestnode = node1
					lerptonext = lerp
				end
			end
		end
	end
	return nrearestnode,lerptonext
end

local function UpgradeTracks()
	continuations = {}
	--тут прохожусь во всем концам треков и ищу, есть ли продолжения
	for id,path in pairs(Metrostroi.TrackEditor.Paths)do
		continuations[id] = continuations[id] or {}
		local count = #path
		if count > 2 then
			for i = 1,2 do
				local idx = i == 1 and i or count
				local p = Metrostroi.Paths[id]
				local selfnode = Metrostroi.Paths[id][idx]
				if selfnode then
					local selfang = (selfnode.pos - (i == 1 and p[2].pos or p[count-1].pos)):Angle()[2]--угол в сторону крайнего ноуда
					local another,lerptonext = FindNearNode(selfnode)--может можно использовать Metrostroi.NearestNodes(pos)?
					if another then
						continuations[id][idx] = {
							another.path.id,
							another.id,
							another.x + (another.pos:Distance(LerpVector(lerptonext,another.pos, lerptonext ~= 0 and another.next.pos or another.pos)))*0.01905,
							another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90 or another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90,
							--i == 2--не нужно, так как тут берутся только концы треков
						}
						
						--связываю в обратную сторону
						--TODO не уверен в этом
						continuations[another.path.id] = continuations[another.path.id] or {}
						continuations[another.path.id][another.id] = {
							id,
							idx,
							selfnode.x,
							i == 1,
							not continuations[id][idx][4]--рестрикт, указание, с какого направления можно перепрыгивать
						}
					end
				end
			end
		end
	end
	for k,v in pairs(continuations)do
		for k1,v1 in pairs(v)do
			print("linked path",k,"node",k1,"and path",v1[1],"node",v1[2],"new dir is",v1[4],"allow from dir",v1[5])
		end
	end
end


--TODO нет проверки на isolating
local function findfunc(startnode,startx,dir,back,returnPassedNodes)
	if back then dir = not dir end
	local curnodes = {{startx},{dir},{startnode}}--так будет только три таблицы
	local nodescount = 1
	local wasNodes = {}
	while nodescount > 0 do
		startx = curnodes[1][nodescount]
		dir = curnodes[2][nodescount]
		dirstr = dir and "next" or "prev"
		curnode = curnodes[3][nodescount]
		
		local pathid = curnode.path.id
		
		for i = 1,3 do curnodes[i][nodescount] = nil end
		nodescount = nodescount - 1
		
		--проверка на рекурсию
		if wasNodes[curnode] then continue end
		wasNodes[curnode] = true
		
		
		--поиск сигнала
		local needcontinue
		if Metrostroi.SignalEntitiesForNode[curnode] then
			local nearestent
			for _,ent in pairs(Metrostroi.SignalEntitiesForNode[curnode]) do
				if IsValid(ent) and (back and dir ~= ent.TrackDir or not back and dir == ent.TrackDir) and ent.OutputARS ~= 0 and (dir and ent.TrackPosition.x > startx or not dir and ent.TrackX < startx) then
					if not nearestent or dir and ent.TrackX < nearestent.TrackX or not dir and ent.TrackX > nearestent.TrackX then--поиск ближайшего
						nearestent = ent
					end
				end
			end
			
			if nearestent then
				if not returnPassedNodes then
					return nearestent
				else
					-- print(nearestent.Name)
					needcontinue = true
				end
			end
		end

		--переход на следующий ноуд (или на следующий трек)		
		--сначала ищется на другом треке
		local newnodeparams = continuations[pathid] and continuations[pathid][curnode.id]
		-- print(pathid,curnode.id, needcontinue)
		if newnodeparams then
			local curnode = Metrostroi.Paths[newnodeparams[1]][newnodeparams[2]]
			if curnode and (newnodeparams[5] == nil or dir == newnodeparams[5]) then
				nodescount = nodescount + 1
				curnodes[1][nodescount] = newnodeparams[3]
				curnodes[2][nodescount] = newnodeparams[4]
				curnodes[3][nodescount] = curnode
			end
		end
		
		if needcontinue then continue end
		--потом ищется на том же треке, потому что добавляется в конец списка и будет проверятсья первым
		if curnode[dirstr] then
			nodescount = nodescount + 1
			curnodes[1][nodescount] = startx
			curnodes[2][nodescount] = dir
			curnodes[3][nodescount] = curnode[dirstr]
		end
		
	end
	
	if returnPassedNodes then return wasNodes end
end


local RawOccupationSections = {}
local function GenerateRawOccupationSections()
	RawOccupationSections = {}
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		--создаю отрезки от стартового сигнала до всех возможных следующих сигналов
		local starttrackid = sig.TrackPosition.path.id
		local startnodeid = sig.TrackPosition.node1.id
		
		--поиск всех ограничивающих светофоров спереди
		local way = findfunc(sig.TrackPosition.node1,sig.TrackPosition.x,sig.TrackDir,false,true)
		-- findfunc возвращает одну большую таблицу, чтобы сама функция findfunc работала быстрее, так как используется постоянно, а здесь оно исопльзуется только один раз, значит можно потратить ресурсы на обработку таблицы
		for node in pairs(way or {})do
			local pathid = node.path.id
			local nodeid = node.id
			RawOccupationSections[pathid] = RawOccupationSections[pathid] or {}
			RawOccupationSections[pathid][nodeid] = RawOccupationSections[pathid][nodeid] or {}
			RawOccupationSections[pathid][nodeid][sig] = true
		end		
	end
end
-- UpgradeTracks()
--GenerateRawOccupationSections()
-- for k,v in pairs(RawOccupationSections)do
	-- for k1,v1 in pairs(v) do
		-- for k2 in pairs(v1) do
			-- if k2.Name ~= "PRD" then continue end
			-- print(k,k1,k2)
		-- end
	-- end
-- end
-- local asd = Metrostroi.GetSignalByName("MR283")
-- print("AAAAAAAAAAAAAAAAAAAAAAAAA")
-- for k,v in pairs(findfunc(asd.TrackPosition.node1,asd.TrackPosition.x,asd.TrackDir,false,true))do
	-- print(k.path.id,k.id)
-- end
-- print("BBBBBBBBBBBBBBBBBBBBBBBBB")

local PrevSignals = {}
local function GeneratePrevSignals()
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) then continue end
		for _,nextsig in pairs(sig.NextSignals)do
			PrevSignals[nextsig] = PrevSignals[nextsig] or {}
			PrevSignals[nextsig][sig] = true
		end
	end
end


local occupiedSigs = {}--таблица светофоров, которые заняты поездами
timer.Create("Metrostroi Signals Occupation Upgrade",1,0,function()
	occupiedSigs = {}
	--смотрю каждую позицию поездов и указываю занятость в сигналам по сгенерированной таблице
	for train,pos in pairs(Metrostroi.TrainPositions)do
		if not pos[1] then continue end
		pos = pos[1]
		local pathid = pos.path.id
		local nodeid = pos.node1.id
		if RawOccupationSections[pathid] and RawOccupationSections[pathid][nodeid] then
			for sig in pairs(RawOccupationSections[pathid][nodeid])do
				if not IsValid(sig) or not sig.TrackPosition then continue end
				if pathid ~= sig.TrackPosition.path.id or pathid == sig.TrackPosition.path.id and (sig.TrackDir and pos.x > sig.TrackPosition.x or not sig.TrackDir and pos.x < sig.TrackPosition.x) then
					occupiedSigs[sig] = train
					print(sig.Name, "occupied")
					--если репитер или галка PassOccupation то надо передать это назад до тех пор, пока не попадется обычный чигнал
					local sigs = {sig}
					local wassigs = {}
					local sigscount = 1
					while sigscount > 0 do
						local cursig = sigs[sigscount]
						sigs[sigscount] = nil
						sigscount = sigscount - 1
						if wassigs[cursig] then continue end
						wassigs[cursig] = true
						-- if (cursig.PassOcc or cursig.Routes and cursig.Route and cursig.Routes[cursig.Route].Repeater) and PrevSignals[cursig] then
						if cursig.PassOcc and PrevSignals[cursig] then
							for prevsig in pairs(PrevSignals[cursig])do
								occupiedSigs[prevsig] = train
								print(prevsig.Name, "occupied")
								sigscount = sigscount + 1
								sigs[sigscount] = prevsig
							end
						end
					end
				end
			end
		end
	end
end)




hook.Add("MetrostroiLoaded","UpgradeTracks",function()
-- timer.Simple(0,function()
-- hook.Add("InitPostEntity","test",function()
	local oldload = Metrostroi.Load
	Metrostroi.Load = function(...)
		oldload(...)
		UpgradeTracks()
		--backsignals = {}
		--forwsignals = {}
	end
	
	local oldPostInit = Metrostroi.PostSignalInitialize
	Metrostroi.PostSignalInitialize = function()
		oldPostInit()
		GeneratePrevSignals()
		GenerateRawOccupationSections()
	end
	
	local oldGetARSJoint = Metrostroi.GetARSJoint
	
	
	--проверка, что вагон точно на треке. Это ухудшит производительность, но оно проверяется только если forw не найден в первый раз и найден во второй или третий
	--и эта проверка обязательна, так как при увеличенном радиусе может найтись трек соседнего пути
	--[[local function IsTrainOnNode(train,node)
		local start = node.pos
		local end1 = node.prev and node.prev.pos
		local end2 = node.next and node.next.pos
		return end1 and table.HasValue(ents.FindAlongRay(start, end1),train) or end2 and table.HasValue(ents.FindAlongRay(start, end2),train)
	end
	
	local function CheckForw(train,lasttry,node)
		local opts = {ignore_path=lasttry and  node.path or nil,radius=350,z_pad=200}
		local posent = IsValid(train.FrontBogey) and train.FrontBogey or train
		local pos = Metrostroi.GetPositionOnTrack(posent:GetPos(),posent:GetAngles(),opts)[1]
		if not pos then 
			posent = train 
			pos = Metrostroi.GetPositionOnTrack(posent:GetPos(),posent:GetAngles(),opts)[1]
		end
		local direction = true
		if pos then
			local pos2 = Metrostroi.GetPositionOnTrack(posent:LocalToWorld(Vector(25,0,0)), posent:GetAngles(),opts)[1]
			if pos2 then
				direction = (pos2.x - pos.x) > 0
			end
			if lasttry then
				local forw = oldGetARSJoint(pos.node1,pos.x, direction, train)
				return forw and IsTrainOnNode(train,pos.node1) and forw
			else
				local res = oldGetARSJoint(pos.node1,pos.x, direction, train)
				return res and IsTrainOnNode(train,pos.node1) and res or CheckForw(train,true,node)
			end
		end
	end]]
	
	Metrostroi.GetARSJoint = function(node,x,dir,train)
		--первый раз ищется стандартно
		local forw,back = oldGetARSJoint(node,x,dir,train)
		--do return forw,back end
		--print("first",forw and forw.Name)
		
		--Если не нашел, то ищется по тому же треку в радиусе 350 стандартным способом. Если нашел, то проверяется, что состав точно на этом треке
		--Если не нашел, то ищется по другому треку в радиусе 350 стандартным способом. Если нашел, то проверяется, что состав точно на этом треке
		--Глеб сказал, что этот вариант медленнее, поэтому пока что отключил
		--[[if IsValid(train) and not forw then
			forw = CheckForw(train,nil,node)
		end]]
		--print("oldmethod",forw and forw.Name)
		
		--И если все равно не нашел, то иду до конца трека, ищу там новый трек, и ищу по нему в направлении в зависимости от угла новым способом
		--фишка этой штуки в том, что оно может перепрыгивать с трека на трек. Но может спрыгивать только с конца трека, а запрыгивать в любом месте трека
		if not forw then
			forw = findfunc(node,x,dir)
			--print("forw by forw",forw and forw.Name)
			if not forw and IsValid(train) then
				--если не нашел forw, то определяю его по заднему сигналу
				--этот вариант не сработает, потому что мрашрут может дропнуться во время проезда
				--или сработает?
				if not back then 
					back = findfunc(node,x,dir,true) 
					--print("back by back",back and back.Name)
				end
				

				if back and back.NextSignalLink and back.NextSignalLink ~= back then
					forw = back.NextSignalLink
					--print("forw by back",forw and forw.Name)
				end
			end
		end
		
		--[[if IsValid(train) then
			local CurTime = CurTime()
			if forw then forwsignals[forw] = CurTime end
			if back then backsignals[back] = CurTime end
			
			--ищу сигнал вперед относительно задней головы
			local lastwag = train.WagonList and train.WagonList[#train.WagonList]
			local pos = lastwag and Metrostroi.TrainPositions[lastwag]
			if pos then
				local backsig = findfunc(pos.node1,pos.x,Metrostroi.TrainDirections[lastwag])
				local forwsig = findfunc(pos.node1,pos.x,Metrostroi.TrainDirections[lastwag],true)
				if backsig then backsignals[backsig] = CurTime end
				if forwsig then forwsignals[forwsig] = CurTime end
			end
		end]]
		--print("res",forw and forw.Name, back and back.Name)
		return forw,back
	end
	
	
	
	
	
	
	
	
	
	--TODO не проверено достаточно качественно
	local function Rotate180(ang)if ang <= 180 then return ang + 180 else return ang - 180 end end

	--данный апгрейд сделан, чтобы не ловвить неправильный трек на перекрестиях
	local oldGetPositionOnTrack = Metrostroi.GetPositionOnTrack
	Metrostroi.GetPositionOnTrack = function(pos,ang,opts)
		if not ang then
			return oldGetPositionOnTrack(pos,ang,opts)
		else
			local res = oldGetPositionOnTrack(pos,ang,opts)
			
			--если найдено хоть что-то
			if res[1] then
				ang = ang[2]
				--метод :Angle возвращает угол от 0 до 360, а ang может прийти в формате от -180 до 180, поэтому явно преобразую в нужный мне формат
				if ang < 0 then ang = -ang + 180 end
				
				--ищу трек, который лучше всего по углу подходит к искомому углу
				local minang,minkey
				for k,params in pairs(res)do
					local node = params.node1
					if node.next then
						local curang = math.abs(ang - (node.pos - node.next.pos):Angle()[2])
						curang = math.min(curang,Rotate180(curang))
						if not minang or minang > curang then minang = curang minkey = k end
					end
					if node.prev then
						local curang = math.abs(ang - (node.pos - node.prev.pos):Angle()[2])
						curang = math.min(curang,Rotate180(curang))
						if not minang or minang > curang then minang = curang minkey = k end
					end
				end
				if minkey then
					-- print("выбрал трек",res[minkey]..path.id)
					res = {res[minkey]}
				end
			end
			
			return res
		end
	end	
end)


hook.Add("InitPostEntity","Metrostroi signals occupation upgrade",function()
	local SIGNAL = scripted_ents.GetStored("gmod_track_signal").t
	--основу скопировал из ентити сигнала
	SIGNAL.CheckOccupation = function(self)
		-- print(self.FoundedAll)
		-- if not self.FoundedAll then return end
		if not self.Close and not self.KGU then --not self.OverrideTrackOccupied and
			if self.Node and  self.TrackPosition then
				self.Occupied = occupiedSigs[self] and true
				local train = occupiedSigs[self] and (occupiedSigs[self].WagonList or {occupiedSigs[self]})
				self.OccupiedBy = train and train[#train]
				self.OccupiedByNow = train and train[1]
			end
			if self.Routes[self.Route] and self.Routes[self.Route].Manual then
				self.Occupied = self.Occupied or not self.Routes[self.Route].IsOpened
			end
			if self.OccupiedByNowOld ~= self.OccupiedByNow then
				self.InvationSignal = false
				self.OccupiedByNowOld = self.OccupiedByNow
			end
		else
			self.NextSignalLink = nil
			self.Occupied = self.Close or self.KGU --self.OverrideTrackOccupied or
		end
	end
end)

