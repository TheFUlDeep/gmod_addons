if CLIENT then return end
--local backsignals,forwsignals = {},{}

hook.Add("MetrostroiLoaded","UpgradeTracks",function()
	local continuations = {}--тут сохраняю связи концов треков, если есть
	local maxdist = (384/2)^2
	local parts = 3
	--максимальная дистанция между ноудами одного трека - 500
	--делю каждый ноуд на три части, и тогда лимит в 192 пройдет корректно
	local function FindNearNode(node)--довольно медленная функция, но она вызывается только при загрузке сигналки, поэтому пофиг
		local nodepathid = node.path.id
		local pos = node.pos
		local nrearestnode,curdist,x,lerptonext
		for pathid,path in pairs(Metrostroi.Paths)do
			for id,node1 in ipairs(path)do
				if pathid == nodepathid and math.abs(id - node.id) < 5 then continue end--если это соседний ноуд, то пропустить
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
								another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90 or another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90
						}
						end
					end
				end
			end
		end
		for k,v in pairs(continuations)do
			for k1,v1 in pairs(v)do
				print("linked path",k,"node",k1,"and path",v1[1],"node",v1[2])
			end
		end
	end
	
	
	local oldload = Metrostroi.Load
	Metrostroi.Load = function(...)
		oldload(...)
		UpgradeTracks()
		backsignals = {}
		forwsignals = {}
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
	
	--TODO нет проверки на isolating
	local function findfunc(startnode,startx,dir,back)
		if back then dir = not dir end
		local was_nodes = {}--чтобы случайно не уйти в рекурсию сохраняю пройденные ноуды
		local curnode = startnode
		local dirstr = dir and "next" or "prev"
		while curnode do
			--проверка на рекурсию
			if was_nodes[curnode] then break end
			was_nodes[curnode] = true
			
			--поиск сигнала
			if Metrostroi.SignalEntitiesForNode[curnode] then
			local nearestent
			for _,ent in pairs(Metrostroi.SignalEntitiesForNode[curnode]) do
				if IsValid(ent) and (back and dir ~= ent.TrackDir or not back and dir == ent.TrackDir) and ent.OutputARS ~= 0 and (dir and ent.TrackX > startx or not dir and ent.TrackX < startx) then
					if not nearestent or dir and ent.TrackX < nearestent.TrackX or not dir and ent.TrackX > nearestent.TrackX then--поиск ближайшего
						nearestent = ent
					end
				end
			end
			if nearestent then return nearestent end
			end
			
			--переход на следующий ноуд (или на следующий трек)
			if curnode[dirstr] then
				curnode = curnode[dirstr]
			else
				local newnodeparams = continuations[curnode.path.id][curnode.id]
				if newnodeparams then
					curnode = Metrostroi.Paths[newnodeparams[1]][newnodeparams[2]]
					if curnode then
						startx = newnodeparams[3]
						dir = newnodeparams[4]
						dirstr = dir and "next" or "prev"
					end
				else
					curnode = nil
				end
			end
		end
	end
	
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
end)

--TODO
--[[hook.Add("InitPostEntity","Metrostroi signals occupation upgrade",function()
	local SIG = scripted_ents.GetStored("gmod_track_signal")
	if not SIG then return else SIG = SIG.t end
	
	SIG.CheckOccupation = function(self,...)
		local CurTime = CurTime()
		
		self.Occupied = backsignals[self] and CurTime - backsignals[self] < 2 or self.NextSignalLink and self ~= self.NextSignalLink and forwsignals[self.NextSignalLink] and CurTime - forwsignals[self.NextSignalLink] < 2 or self.Routes[self.Route] and self.Routes[self.Route].Manual and not self.Routes[self.Route].IsOpened or self.Close or self.KGU
		if self.Close or self.KGU then
			self.NextSignalLink = nil
		end
		
		local occupied
		occupied,self.OccupiedBy,self.OccupiedByNow = Metrostroi.IsTrackOccupied(self.Node, self.TrackPosition.x,self.TrackPosition.forward,self.ARSOnly and "ars" or "light", self)
		self.Occupied = self.Occupied or occupied
		
		if self.PrevOccupiedBy ~= self.OccupiedByNow then
			self.InvationSignal = false
			self.PrevOccupied = self.OccupiedByNow
		end
	end
end)]]

