if CLIENT then return end
hook.Add("MetrostroiLoaded","UpgradeTracks",function()
	local continuations = {}--тут сохраняю связи концов треков, если есть
	local function FindNearNode(node)
		local maxdist = (384/2)^2
		local pathToSkip = node.path.id
		local pos = node.pos
		local nrearestnode,curdist,x,minpos
		for pathid,path in pairs(Metrostroi.Paths)do
			if pathid == pathToSkip then continue end
			for id,node1 in ipairs(path)do
				for i = 1, node1.next and 2 or 1 do
					local curpos = i == 1 and node1.pos or LerpVector(0.5,node1.pos,node1.next.pos)--делю попалам потому что не всегда находит
					if nrearestnode then
						if pos:DistToSqr(curpos) < pos:DistToSqr(nrearestnode.pos) then
							nrearestnode = node1
							minpos = curpos
						end
					elseif pos:DistToSqr(curpos) < maxdist then
						nrearestnode = node1
						minpos = curpos
					end
				end
			end
		end
		return nrearestnode,minpos
	end

	local function UpgradeTracks()
		continuations = {}
		--тут прохожусь во всем концам треков и ищу, есть ли продолжения
		for id,path in pairs(Metrostroi.TrackEditor.Paths)do
			continuations[id] = {}
			local count = #path
			if count > 2 then
				for i = 1,2 do
					local idx = i == 1 and i or count
					local selfnode = Metrostroi.Paths[id][idx]
					if selfnode then
						local another,pos = FindNearNode(selfnode)
						if another then
							continuations[id][idx] = {another.path.id,another.id,pos == another.pos and another.x or another.x + (another.pos:Distance(LerpVector(0.5,another.pos, another.next.pos)))*0.01905}
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
	end




	--первый раз ищется стандартно
	--Если не нашел, то ищется по тому же треку в радиусе 350. Если нашел, то проверяется, что состав точно на этом треке
	--Если не нашел, то ищется по другому треку в радиусе 350. Если нашел, то проверяется, что состав точно на этом треке
	--И если все равно не нашел, то иду до конца трека, ищу там новый трек, и ищу по нему в направлении в зависимости от угла
	local oldGetARSJoint = Metrostroi.GetARSJoint
	
	
	--проверка, что вагон точно на треке. Это ухудшит производительность, но оно проверяется только если forw не найден в первый раз и найден во второй или третий
	--и эта проверка обязательна, так как при увеличенном радиусе может найтись трек соседнего пути
	local function IsTrainOnNode(train,node)
		local start = node.pos
		local end1 = node.prev and node.prev.pos
		local end2 = node.next and node.next.pos
		return end1 and table.HasValue(ents.FindAlongRay(start, end1),train) or end2 and table.HasValue(ents.FindAlongRay(start, end2),train)
	end
	
	local function CheckForw(train,lasttry,node)
		local opts = {ignore_path=lasttry and  node.path or nil,radius=350}
		local pos = Metrostroi.GetPositionOnTrack(train:GetPos(),train:GetAngles(),opts)[1]
		local direction = true
		if pos then
			local pos2 = Metrostroi.GetPositionOnTrack(train:LocalToWorld(Vector(25,0,0)), train:GetAngles(),opts)[1]
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
	end
	
	local function GetLastNode(startnode,dir)
		local curnode = startnode
		local prevnode
		if dir then
			prevnode = curnode.prev
		else
			prevnode = curnode.next
		end
		local dir = dir and "next" or "prev"
		while curnode[dir] do
			prevnode = curnode
			curnode = curnode[dir]
		end
		if not prevnode then return end--если нет предыдущего ноуда, то я не смогу определить угол
		local ang = (curnode.pos-prevnode.pos):Angle()--угол в сторону конца
		ang:Normalize()
		return curnode,ang
	end

	Metrostroi.GetARSJoint = function(node,x,dir,train)
		local forw,back = oldGetARSJoint(node,x,dir,train)
		if IsValid(train) and not forw then
			forw = CheckForw(train,nil,node)
		end
		
		if not forw then
			local endNode,ang = GetLastNode(node,dir)
			if endNode and continuations[endNode.path.id][endNode.id] then
				local newnodeparams = continuations[endNode.path.id][endNode.id]
				print("going to",newnodeparams[1],newnodeparams[2])
				local newnode = newnodeparams and Metrostroi.Paths[newnodeparams[1]][newnodeparams[2]]
				if newnode then
					if newnode.next then
						local newang = (newnode.next.pos - newnode.pos):Angle()--угол в сторону next ноуда
						newang:Normalize()
						forw = Metrostroi.GetARSJoint(newnode,newnodeparams[3],math.abs(ang[2]-newang[2]) < 90,train)
					end
					
					if not forw and newnode.prev then
						local newang = (newnode.prev.pos - newnode.pos):Angle()--угол в сторону next ноуда
						newang:Normalize()
						forw = Metrostroi.GetARSJoint(newnode,newnodeparams[3],math.abs(ang[2]-newang[2]) > 90,train)
					end
				end
			end
		end
		
		return forw,back
	end
	
	
	--мем
	--[[
		GetARSJoint принимает train и передает его в ARSJointScan и ARSJointScanBack.
		А эти функции для опредедления позиции обращаются к Metrostroi.TrainPositions[train]
		А эта таблица заполняется в методе UpdateTrainPositions, и там берутся позиции вагонов через GetPos(), то есть их центр.
		Но правильнее же брать позицию тележки, так как именно там находится принимающая катушка
		Но при проверке оказалось, что в игре частота меняется при проезде тележкой, то есть оно работает правильно. Забавно
	]]
	--[[local oldupdate = Metrostroi.UpdateTrainPositions
	Metrostroi.UpdateTrainPositions = function(...)
		oldupdate(...)
		for train in pairs(Metrostroi.TrainPositions) do
			if IsValid(train) and IsValid(train.FrontBogey) then
				local pos = Metrostroi.GetPositionOnTrack(train.FrontBogey:GetPos()),train.FrontBogey:GetAngles())[1]
				if pos then
					Metrostroi.TrainPositions[train] = {}
					Metrostroi.TrainPositions[train][1] = pos
				end
			end
		end
	end]]
end)