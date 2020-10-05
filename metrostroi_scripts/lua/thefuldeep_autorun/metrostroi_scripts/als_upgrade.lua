if CLIENT then return end
hook.Add("MetrostroiLoaded","UpgradeTracks",function()
	local continuations = {}--тут сохраняю связи концов треков, если есть
	local function FindNearNode(node)
		local maxdist = (384/2)^2
		local nodepathid = node.path.id
		local pos = node.pos
		local nrearestnode,curdist,x,lerptonext
		for pathid,path in pairs(Metrostroi.Paths)do
			for id,node1 in ipairs(path)do
				if pathid == nodepathid and math.abs(id - node.id) < 5 then continue end--если это соседний ноуд, то пропустить
				local nextnode = node1.next
				for i = 0, node1.next and 3 or 0 do
					local lerp = i/3
					local curpos = LerpVector(lerp,node1.pos,nextnode and nextnode.pos or node1.pos)--делю на части потому что не всегда находит
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
					local selfnode = Metrostroi.Paths[id][idx]
					if selfnode then
						local another,lerptonext = FindNearNode(selfnode)
						if another then
							continuations[id][idx] = {another.path.id,another.id,  another.x + (another.pos:Distance(LerpVector(lerptonext,another.pos, lerptonext ~= 0 and another.next.pos or another.pos)))*0.01905}
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
		--print("second",forw and forw.Name)
		
		--И если все равно не нашел, то иду до конца трека, ищу там новый трек, и ищу по нему в направлении в зависимости от угла новым способом
		--фишка этой штуки в том, что оно может перепрыгивать с трека на трек. Но может спрыгивать только с конца трека, а запрыгивать в любом месте трека
		if not forw then
			local nodepathid = node.path.id
			local path = Metrostroi.Paths[nodepathid]
			local nodeid = dir and #path or 1
			local endNode = path[nodeid]
			local ang = (endNode.pos - (dir and path[nodeid-1].pos or path[nodeid+1].pos)):Angle()--угол в сторону крайнего ноуда
			local newnodeparams = continuations[nodepathid][endNode.id]
			if newnodeparams then
				local newnode = Metrostroi.Paths[newnodeparams[1]][newnodeparams[2]]
				if newnode then
					if newnode.next then
						local newang = (newnode.next.pos - newnode.pos):Angle()--угол в сторону next ноуда
						--print(ang,newang)
						forw = Metrostroi.GetARSJoint(newnode,newnodeparams[3],math.abs(ang[2]-newang[2]) < 90,train)
					end
					
					if not forw and newnode.prev then
						local newang = (newnode.prev.pos - newnode.pos):Angle()--угол в сторону prev ноуда
						--print(ang,newang)
						forw = Metrostroi.GetARSJoint(newnode,newnodeparams[3],math.abs(ang[2]-newang[2]) > 90,train)
					end
				end
			end
		end
		
		--этот вариант не сработает, потому что мрашрут может дропнуться во время проезда
		--или сработает?
		if IsValid(train) and not forw and IsValid(back) and back:GetClass() == "gmod_track_signal" and back.NextSignalLink and back.NextSignalLink ~= back then
			forw = back.NextSignalLink
		end
		
		--back не надо, так как он используется только для определения проезда сигнала?
		--print(forw and forw.Name, back and back.Name)
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

