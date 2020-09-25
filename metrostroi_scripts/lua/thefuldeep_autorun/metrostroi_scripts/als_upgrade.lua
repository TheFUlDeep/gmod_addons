if CLIENT then return end
timer.Simple(0,function()
	--первый раз ищется стандартно
	--Если не нашел, то ищется по тому же треку в радиусе 350. Если нашел, то проверяется, что состав точно на этом треке
	--Если не нашел, то ищется по другому треку в радиусе 350. Если нашел, то проверяется, что состав точно на этом треке
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
		local pos2 = Metrostroi.GetPositionOnTrack(train:LocalToWorld(Vector(25,0,0)), train:GetAngles(),opts)[1]
		local direction = true
		if pos then
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

	Metrostroi.GetARSJoint = function(node,x,...)
		local forw,back = oldGetARSJoint(node,x,...)
		if train and not forw then
			forw = CheckForw(train,nil,node)
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