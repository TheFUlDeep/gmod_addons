-- сигналы определяют занятость перепригивая на другие треки
-- функция GetARSJoint работает быстрее, так как просто проверяется по нужному ноуду, а не производит поиск по треку
-- производительность определения сигнала составом быстрее примерно в 35к раз

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
			if pathid == nodepathid and math.abs(id - nodeid) < 5 then continue end--если это соседний ноуд того же трека, то пропустить
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
		if count > 1 then
			for i = 1,2 do
				local idx = i == 1 and i or count
				local p = Metrostroi.Paths[id]
				local selfnode = Metrostroi.Paths[id][idx]
				if selfnode then
					local selfang = (selfnode.pos - (i == 1 and p[2].pos or p[count-1].pos)):Angle()[2]--угол в сторону крайнего ноуда
					local another,lerptonext = FindNearNode(selfnode)--может можно использовать Metrostroi.NearestNodes(pos)?
					--если перепрыгивает на новый трек, и у этого нового трека это первый (или последний) ноуд, то добавлять только в том случае, если угол подходит
					if another and
						(
						another.next and another.prev
						or not another.prev and another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90
						or not another.next and another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90
						)
					then
						continuations[id][idx] = continuations[id][idx] or {}
						local n = table.insert(continuations[id][idx],
							{
								another.path.id,
								another.id,
								another.x + (another.pos:Distance(LerpVector(lerptonext,another.pos, lerptonext ~= 0 and another.next.pos or another.pos)))*0.01905,
								another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90 or another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90,
								i == 2
							}
						)
						
						--связываю в обратную сторону
						continuations[another.path.id] = continuations[another.path.id] or {}
						continuations[another.path.id][another.id] = continuations[another.path.id][another.id] or {}
						table.insert(continuations[another.path.id][another.id],
							{
								id,
								idx,
								selfnode.x,
								i == 1,
								not continuations[id][idx][n][4]--рестрикт, указание, с какого направления можно перепрыгивать
							}
						)
					end
				end
			end
		end
	end
	for k,v in pairs(continuations)do
		for k1,v2 in pairs(v)do
			for _,v1 in pairs(v2) do
				print("linked path",k,"node",k1,"and path",v1[1],"node",v1[2],"new dir is",v1[4],"allow from dir",v1[5])
			end
		end
	end
end


local function findfunc(startnode,startx,dir,back,returnPassedNodes,withIsolateSwitches)
	--когда returnPassedNodes = true, я буду скипать passOcc потому что исопльзуется только для генерации отрезков занятости
	if back then dir = not dir end
	local curnodes = {{startx},{dir},{startnode}}--так будет только три таблицы
	local nodescount = 1
	local wasNodes = {}
	local EndSignals = {}
	-- 1 - началы отрезков, 2 - концы отрезков
	local startEnds = {{},{}}
	while nodescount > 0 do
		startx = curnodes[1][nodescount]
		dir = curnodes[2][nodescount]
		dirstr = dir and "next" or "prev"
		curnode = curnodes[3][nodescount]
		
		local pathid = curnode.path.id
		startEnds[1][pathid] = startEnds[1][pathid] or startx
		startEnds[2][pathid] = startEnds[2][pathid] or startx
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
				if IsValid(ent) and (withIsolateSwitches and ent.IsolateSwitches or not withIsolateSwitches) and not ent.PassOcc and (back and dir ~= ent.TrackDir or not back and dir == ent.TrackDir) and ent.OutputARS ~= 0 and (dir and ent.TrackPosition.x > startx or not dir and ent.TrackPosition.x < startx) then
					if not nearestent or math.abs(startx - ent.TrackX) < math.abs(startx - nearestent.TrackX) then--поиск ближайшего
						nearestent = ent
						startEnds[2][pathid] = nearestent.TrackX
					end
				end
			end
			
			if nearestent then
				if not returnPassedNodes then
					if not allEndSignals then
						return nearestent
					else
						EndSignals[nearestent] = true
						needcontinue = true
					end
				else
					needcontinue = true
				end
			end
		end

		--переход на следующий ноуд (или на следующий трек)		
		--сначала ищется на другом треке
		local newnodeparamsTbl = continuations[pathid] and continuations[pathid][curnode.id]
		if newnodeparamsTbl then
			for _,newnodeparams in pairs(newnodeparamsTbl) do
				local curnode = Metrostroi.Paths[newnodeparams[1]][newnodeparams[2]]
				if curnode and dir == newnodeparams[5] then
					nodescount = nodescount + 1
					curnodes[1][nodescount] = newnodeparams[3]
					startEnds[1][curnode.path.id] = startEnds[1][curnode.path.id] or newnodeparams[3]
					startEnds[2][curnode.path.id] = startEnds[2][curnode.path.id] or newnodeparams[3]
					curnodes[2][nodescount] = newnodeparams[4]
					curnodes[3][nodescount] = curnode
				end
			end
		end
		
		if needcontinue then continue end
		--потом ищется на том же треке, потому что добавляется в конец списка и будет проверятсья первым
		if curnode[dirstr] then
			nodescount = nodescount + 1
			curnodes[1][nodescount] = startx
			curnodes[2][nodescount] = dir
			curnodes[3][nodescount] = curnode[dirstr]
			startEnds[2][pathid] = curnode[dirstr].x
		end
		
	end
	
	if returnPassedNodes then return startEnds, wasNodes end
end


local et = {}--empty table


local OccupationSections = {}
local function GenerateOccupationSections()
	OccupationSections = {}
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		
		--поиск всех отрезков занятости
		local way, nodes = findfunc(sig.TrackPosition.node1,sig.TrackPosition.x,sig.TrackDir,false,true)
		local pathid = sig.TrackPosition.path.id
		for pathid,startx in pairs(way[1])do
			local condition = {start = startx, ["end"] = way[2][pathid], sig = sig}
			OccupationSections[pathid] = OccupationSections[pathid] or {}
			for node in pairs(nodes) do
				OccupationSections[pathid][node.id] = OccupationSections[pathid][node.id] or {}
				table.insert(OccupationSections[pathid][node.id],condition)
			end
		end
	end
end



local LinkedTracksToSignals = {}
local function LinkTracksToSignals()
	LinkedTracksToSignals = {}

	local wasNodes = {}
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		
		local pathid = sig.TrackPosition.node1.path.id
		local node = sig.TrackPosition.node1
		wasNodes[node] = wasNodes[node] or {}
		wasNodes[node][sig.TrackDir] = true
		local x = sig.TrackPosition.x
		LinkedTracksToSignals[pathid] = LinkedTracksToSignals[pathid] or {}
		LinkedTracksToSignals[pathid][sig.TrackDir] = LinkedTracksToSignals[pathid][sig.TrackDir] or {}
		LinkedTracksToSignals[pathid][sig.TrackDir][node] = LinkedTracksToSignals[pathid][sig.TrackDir][node] or {}
		table.insert(LinkedTracksToSignals[pathid][sig.TrackDir][node],{["sig"] = sig, ["nextsig"] = findfunc(node,x,sig.TrackDir)})
	end
	
	-- вот это самая калящая меня часть, возможно она будет отрабатывать сто лет
	for pathid,path in pairs(Metrostroi.Paths or et)do
		for i = 1, #path do
		local node = path[i]
			LinkedTracksToSignals[pathid] = LinkedTracksToSignals[pathid] or {}
			for dirdec = 0,1 do
				local dir = dirdec == 1
				if wasNodes[node] and wasNodes[node][dir] then continue end
				LinkedTracksToSignals[pathid][dir] = LinkedTracksToSignals[pathid][dir] or {}
				LinkedTracksToSignals[pathid][dir][node] = LinkedTracksToSignals[pathid][dir][node] or {}
				LinkedTracksToSignals[pathid][dir][node].nextsig = findfunc(node,node.x,dir)
			end
		end
	end
end


local LinkedBackTracksToSignals = {}
local function LinkBackTracksToSignals()
	LinkedBackTracksToSignals = {}

	local wasNodes = {}
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		
		local pathid = sig.TrackPosition.node1.path.id
		local node = sig.TrackPosition.node1
		wasNodes[node] = wasNodes[node] or {}
		wasNodes[node][sig.TrackDir] = true
		local x = sig.TrackPosition.x
		LinkedBackTracksToSignals[pathid] = LinkedBackTracksToSignals[pathid] or {}
		LinkedBackTracksToSignals[pathid][sig.TrackDir] = LinkedBackTracksToSignals[pathid][sig.TrackDir] or {}
		LinkedBackTracksToSignals[pathid][sig.TrackDir][node] = LinkedBackTracksToSignals[pathid][sig.TrackDir][node] or {}
		table.insert(LinkedBackTracksToSignals[pathid][sig.TrackDir][node],{["sig"] = sig, ["nextsig"] = findfunc(node,x,sig.TrackDir)})
	end
	
	-- вот это самая калящая меня часть, возможно она будет отрабатывать сто лет
	for pathid,path in pairs(Metrostroi.Paths or et)do
		for i = 1, #path do
		local node = path[i]
			LinkedBackTracksToSignals[pathid] = LinkedBackTracksToSignals[pathid] or {}
			for dirdec = 0,1 do
				local dir = dirdec == 1
				if wasNodes[node] and wasNodes[node][dir] then continue end
				LinkedBackTracksToSignals[pathid][dir] = LinkedBackTracksToSignals[pathid][dir] or {}
				LinkedBackTracksToSignals[pathid][dir][node] = LinkedBackTracksToSignals[pathid][dir][node] or {}
				LinkedBackTracksToSignals[pathid][dir][node].nextsig = findfunc(node,node.x,dir,true)
			end
		end
	end
end


timer.Create("Metrostroi Signals Occupation Upgrade",1,0,function()
	--смотрю каждую позицию поездов и указываю занятость в сигналам по сгенерированной таблице
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if IsValid(sig) then
			sig.OccupiedTfd = false
		end
	end
	
	for train,pos in pairs(Metrostroi.TrainPositions)do
		if not pos[1] then continue end
		pos = pos[1]
		local x = pos.x
		local pathid = pos.path.id
		for _,condition in pairs(OccupationSections[pathid] and OccupationSections[pathid][pos.node1.id] or et)do
			if IsValid(condition.sig) and (x < condition['end'] and x > condition['start'] or x > condition['end'] and x < condition['start']) then
				condition.sig.OccupiedTfd = train
			end
		end
	end
end)

-- local RemovedSignals = {}
local function RemoveUselessRepeaters()
	local sigs = ents.FindByClass("gmod_track_signal")
	for _,sig in pairs(sigs)do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		
		local IsBadRepeater
		for routeid, params in pairs(sig.Routes or et)do
			if not params.Repeater or params.Switches and (params.Switches:find("+",1,true) or params.Switches:find("-",1,true)) then IsBadRepeater = true break end
			for name,ent in pairs(sig.NextSignals or et)do
				--findfunc(startnode,startx,dir,back,returnPassedNodes)
				if (name:find("%a") or name:find("%d") or name == "*") and findfunc(sig.TrackPosition.node1, sig.TrackPosition.x, sig.TrackDir) ~= ent then IsBadRepeater = true break end
			end
			if IsBadRepeater then break end
		end
		if IsBadRepeater then continue end
		
		for _,sig2 in pairs(sigs)do
			if not IsValid(sig2) or sig2 == sig then continue end
			for routeid,params in pairs(sig2.Routes or et)do
				local nextsignalName = params.NextSignal
				if nextsignalName == "*" then nextsignalName = sig2.NextSignals["*"] and sig2.NextSignals["*"].Name end
				if nextsignalName and nextsignalName == sig.Name then
					sig2.NextSignals[params.NextSignal] = nil
					local nextSignalEnt = findfunc(sig.TrackPosition.node1, sig.TrackPosition.x, sig.TrackDir)
					params.NextSignal = nextSignalEnt.Name
					sig2.NextSignals[params.NextSignal] = nextSignalEnt
					print("reconfiguting signal "..(sig2.Name or tostring(sig2).." "..sig2:EntIndex()).." because of deleting signal "..nextsignalName)
				end
			end
		end
		SafeRemoveEntity(sig)
		print("removed signal "..sig.Name.." because it useless repeater")
	end
end


hook.Add("MetrostroiLoaded","UpgradeTracks",function()
-- timer.Simple(0,function()
-- hook.Add("InitPostEntity","test",function()
	local oldload = Metrostroi.Load
	Metrostroi.Load = function(...)
		-- RemovedSignals = {}
		oldload(...)
		UpgradeTracks()
		--backsignals = {}
		--forwsignals = {}
	end
	
	-- local oldUpdateSignalEntities = Metrostroi.UpdateSignalEntities
	-- Metrostroi.UpdateSignalEntities = function(...)
		-- for _,self in pairs(ents.FindByClass("gmod_track_signal"))do
			-- if not IsValid(self) then continue end
			-- local needIterations = self.Routes and #self.Routes or 0
			-- while needIterations > 0 do
				-- if not self.Routes[needIterations].NextSignal or self.Routes[needIterations].Repeater and self.Routes[needIterations].NextSignal == self.Name or not self.Routes[needIterations].NextSignal:find("%a") and not self.Routes[needIterations].NextSignal:find("%d") and not self.Routes[needIterations].NextSignal:find("*",1,true) then
					-- table.remove(self.Routes,needIterations)
				-- end
				-- needIterations = needIterations - 1
			-- end
			-- if not self.Routes or #self.Routes == 0 then
				-- self.Routes = {{}}
				-- if self.Name then
					-- RemovedSignals[self.Name] = true
				-- end
				-- print("removed signal "..(self.Name or "NAME").." because of bad settings")
				-- SafeRemoveEntity(self)
			-- end
		-- end
		-- return oldUpdateSignalEntities(...)
	-- end
	
	local oldGetARSJoint = Metrostroi.GetARSJoint
	function Metrostroi.NewGetARSJoint(node,x,dir,train)
		local forwsig,backsig
		local pathid = node.path.id
		local nextsigs = LinkedTracksToSignals[pathid] and LinkedTracksToSignals[pathid][dir] and LinkedTracksToSignals[pathid][dir][node] and LinkedTracksToSignals[pathid][dir][node]
		if #nextsigs == 0 then
			forwsig = nextsigs.nextsig
		else
			local minleng,lastnearestsig
			for _,nextsig in pairs(nextsigs or et)do
				local sig = (dir and x < nextsig.sig.TrackPosition.x or not dir and x > nextsig.sig.TrackPosition.x) and nextsig.sig or nextsig.nextsig
				if not sig then continue end
				local leng = math.abs(x - sig.TrackPosition.x)
				if not minleng or leng < minleng then
					minx = leng
					forwsig = sig
				end
			end
		end
			
		local nextsigs = LinkedBackTracksToSignals[pathid] and LinkedBackTracksToSignals[pathid][dir] and LinkedBackTracksToSignals[pathid][dir][node] and LinkedBackTracksToSignals[pathid][dir][node]
		if #nextsigs == 0 then
			backsig = nextsigs.nextsig
		else
			local minleng,lastnearestsig
			for _,nextsig in pairs(nextsigs or et)do
				local sig = (dir and x < nextsig.sig.TrackPosition.x or not dir and x > nextsig.sig.TrackPosition.x) and nextsig.nextsig or nextsig.sig
				if not sig then continue end
				local leng = math.abs(x - sig.TrackPosition.x)
				if not minleng or leng < minleng then
					minx = leng
					backsig = sig
				end
			end
		end

		return forwsig, backsig
	end
	
	local oldPostInit = Metrostroi.PostSignalInitialize
	Metrostroi.PostSignalInitialize = function()
		Metrostroi.GetARSJoint = oldGetARSJoint
		oldPostInit()
		RemoveUselessRepeaters()
		
		-- for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
			-- if IsValid(sig) then
				-- for routeid,params in pairs(sig.Routes or et)do
					-- local nextsignal = params.NextSignal
					-- if nextsignal == "*" then nextsignal = sig.NextSignals["*"] and sig.NextSignals["*"].Name end
					-- if nextsignal and RemovedSignals[nextsignal] then
						-- sig.NextSignals[nextsignal] = nil
						-- params.NextSignal = sig.Name
						-- sig.NextSignals[params.NextSignal] = sig
						-- print("reconfiguting signal "..sig.Name.." to self because of deleted signal "..nextsignal)
					-- end
				-- end
			-- end
		-- end
		
		GenerateOccupationSections()
		LinkTracksToSignals()
		LinkBackTracksToSignals()
		Metrostroi.GetARSJoint = Metrostroi.NewGetARSJoint
	end
	
	
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
	
	-- Metrostroi.GetARSJoint = function(node,x,dir,train)
		-- --первый раз ищется стандартно
		-- local forw,back = oldGetARSJoint(node,x,dir,train)
		-- --do return forw,back end
		-- --print("first",forw and forw.Name)
		
		-- --Если не нашел, то ищется по тому же треку в радиусе 350 стандартным способом. Если нашел, то проверяется, что состав точно на этом треке
		-- --Если не нашел, то ищется по другому треку в радиусе 350 стандартным способом. Если нашел, то проверяется, что состав точно на этом треке
		-- --Глеб сказал, что этот вариант медленнее, поэтому пока что отключил
		-- --[[if IsValid(train) and not forw then
			-- forw = CheckForw(train,nil,node)
		-- end]]
		-- --print("oldmethod",forw and forw.Name)
		
		-- --И если все равно не нашел, то иду до конца трека, ищу там новый трек, и ищу по нему в направлении в зависимости от угла новым способом
		-- --фишка этой штуки в том, что оно может перепрыгивать с трека на трек. Но может спрыгивать только с конца трека, а запрыгивать в любом месте трека
		-- if not forw then
			-- forw = findfunc(node,x,dir)
			-- --print("forw by forw",forw and forw.Name)
			-- if not forw and IsValid(train) then
				-- --если не нашел forw, то определяю его по заднему сигналу
				-- --этот вариант не сработает, потому что мрашрут может дропнуться во время проезда
				-- --или сработает?
				-- if not back then 
					-- back = findfunc(node,x,dir,true) 
					-- --print("back by back",back and back.Name)
				-- end
				

				-- if back and back.NextSignalLink and back.NextSignalLink ~= back then
					-- forw = back.NextSignalLink
					-- --print("forw by back",forw and forw.Name)
				-- end
			-- end
		-- end
		
		-- --[[if IsValid(train) then
			-- local CurTime = CurTime()
			-- if forw then forwsignals[forw] = CurTime end
			-- if back then backsignals[back] = CurTime end
			
			-- --ищу сигнал вперед относительно задней головы
			-- local lastwag = train.WagonList and train.WagonList[#train.WagonList]
			-- local pos = lastwag and Metrostroi.TrainPositions[lastwag]
			-- if pos then
				-- local backsig = findfunc(pos.node1,pos.x,Metrostroi.TrainDirections[lastwag])
				-- local forwsig = findfunc(pos.node1,pos.x,Metrostroi.TrainDirections[lastwag],true)
				-- if backsig then backsignals[backsig] = CurTime end
				-- if forwsig then forwsignals[forwsig] = CurTime end
			-- end
		-- end]]
		-- --print("res",forw and forw.Name, back and back.Name)
		-- return forw,back
	-- end
	
	
	
	
	
	
	
	--TODO не проверено достаточно качественно
	--на калинине из-за этого прикола ловятся рельсовые цепи с соседних треков и получается неправильная частота
	-- local function Rotate180(ang)if ang <= 180 then return ang + 180 else return ang - 180 end end

	-- --данный апгрейд сделан, чтобы не ловвить неправильный трек на перекрестиях
	-- local oldGetPositionOnTrack = Metrostroi.GetPositionOnTrack
	-- Metrostroi.GetPositionOnTrack = function(pos,ang,opts)
		-- if not ang then
			-- return oldGetPositionOnTrack(pos,ang,opts)
		-- else
			-- local res = oldGetPositionOnTrack(pos,ang,opts)
			
			-- --если найдено хоть что-то
			-- if res[1] then
				-- ang = ang[2]
				-- --метод :Angle возвращает угол от 0 до 360, а ang может прийти в формате от -180 до 180, поэтому явно преобразую в нужный мне формат
				-- if ang < 0 then ang = -ang + 180 end
				
				-- --ищу трек, который лучше всего по углу подходит к искомому углу
				-- local minang,minkey
				-- for k,params in pairs(res)do
					-- local node = params.node1
					-- if node.next then
						-- local curang = math.abs(ang - (node.pos - node.next.pos):Angle()[2])
						-- curang = math.min(curang,Rotate180(curang))
						-- if not minang or minang > curang then minang = curang minkey = k end
					-- end
					-- if node.prev then
						-- local curang = math.abs(ang - (node.pos - node.prev.pos):Angle()[2])
						-- curang = math.min(curang,Rotate180(curang))
						-- if not minang or minang > curang then minang = curang minkey = k end
					-- end
				-- end
				-- if minkey then
					-- -- print("выбрал трек",res[minkey]..path.id)
					-- res = {res[minkey]}
				-- end
			-- end
			
			-- return res
		-- end
	-- end	
end)


hook.Add("InitPostEntity","Metrostroi signals occupation upgrade",function()
	local SIGNAL = scripted_ents.GetStored("gmod_track_signal").t
	--основу скопировал из ентити сигнала
	SIGNAL.CheckOccupation = function(self)
		-- print(self.FoundedAll)
		-- if not self.FoundedAll then return end
		if not self.Close and not self.KGU then --not self.OverrideTrackOccupied and
			if self.Node and self.TrackPosition then
				self.Occupied = self.OccupiedTfd and true
				local train = self.OccupiedTfd and (self.OccupiedTfd.WagonList or {self.OccupiedTfd})
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
	
	local oldARSLogick = SIGNAL.ARSLogic
	SIGNAL.ARSLogic = function(self,...)
		if self.Routes[self.Route or 1].Repeater then self:CheckOccupation() end
		return oldARSLogick(self,...)
	end
	
end)
