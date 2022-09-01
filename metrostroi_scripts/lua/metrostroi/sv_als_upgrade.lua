-- сигналы определяют занятость перепригивая на другие треки
-- функция GetARSJoint работает быстрее, так как просто проверяется по нужному ноуду, а не производит поиск по треку
-- производительность определения сигнала составом быстрее примерно в 35к раз
-- TODO узнать, что быстрее, два раза обращение к полю таблицы или один раз помещение в таблицу и два раза обращение к этой переменной?

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
		local dirstr = dir and "next" or "prev"
		local curnode = curnodes[3][nodescount]
		
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
		local way, nodes = findfunc(sig.Node,sig.TrackPosition.x,sig.TrackDir,false,true)
		local pathid = sig.TrackPosition.path.id
		for pathid,startx in pairs(way[1])do
			-- local condition = {start = startx, ["end"] = way[2][pathid], sig = sig}
			OccupationSections[pathid] = OccupationSections[pathid] or {}
			for node in pairs(nodes) do
				-- начальный ноуд будет с условием по иксу, а все следующие без условия (даже если там впереди будет сигнал, думаю не страшно)
				OccupationSections[pathid][node] = OccupationSections[pathid][node] or {}
				if node ~= sig.Node then
					table.insert(OccupationSections[pathid][node],{sig=sig})--тут таблица {sig = sig}, а не просто значение sig, потому что она может проверяться на поле start
				else
					table.insert(OccupationSections[pathid][node],{sig=sig,start=startx})
				end
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
		
		local pathid = sig.Node.path.id
		local node = sig.Node
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
		
		local pathid = sig.Node.path.id
		local node = sig.Node
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
			sig.OccupiedTfd = {}
		end
	end

	for train,pos in pairs(Metrostroi.TrainPositions)do
		if not pos[1] then continue end
		pos = pos[1]
		local trainx = pos.x
		local pathid = pos.path.id
		if not OccupationSections[pathid] then continue end
		local minlen,foundnearsig
		for _,condition in ipairs(OccupationSections[pathid][pos.node1] or et)do
			-- тут надо найти самый ближний в правильном направлении
			if not condition.start or not IsValid(condition.sig) then continue end
			local startx = condition.start
			local sigdir = condition.sig.TrackDir
			if sigdir and trainx > startx or not sigdir and trainx < startx then
				if not minlen or math.abs(startx - trainx) < minlen then
					-- print("occupied by x", condition.sig.Name)
					condition.sig.OccupiedTfd[train] = true
					foundnearsig = condition.sig
				end
			end
		end
		
		for _,condition in ipairs(OccupationSections[pathid][pos.node1] or et)do
			-- тут надо найти самый ближний в правильном направлении
			if condition.start or not IsValid(condition.sig) then continue end
			if not foundnearsig then
				condition.sig.OccupiedTfd[train] = true
				-- print("occupied by node", condition.sig.Name)
			else
				if trainx < foundnearsig.TrackPosition.x and trainx > condition.sig.TrackPosition.x or trainx > foundnearsig.TrackPosition.x and trainx < condition.sig.TrackPosition.x then
					condition.sig.OccupiedTfd[train] = true
					-- print("occupied by node and x", condition.sig.Name)
				end
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
				if (name:find("%a") or name:find("%d") or name == "*") and findfunc(sig.Node, sig.TrackPosition.x, sig.TrackDir) ~= ent then IsBadRepeater = true break end
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
					local nextSignalEnt = findfunc(sig.Node, sig.TrackPosition.x, sig.TrackDir)
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
	Metrostroi.oldGetARSJoint = Metrostroi.GetARSJoint
	function Metrostroi.NewGetARSJoint(node,x,dir,train)
		local forwsig,backsig
		local pathid = node.path.id
		local nextsigs = LinkedTracksToSignals[pathid] and LinkedTracksToSignals[pathid][dir] and LinkedTracksToSignals[pathid][dir][node] and LinkedTracksToSignals[pathid][dir][node]
		if #nextsigs == 0 then
			forwsig = nextsigs.nextsig
		else
			local minleng
			for _,nextsig in pairs(nextsigs or et)do
				local sig = (dir and x < nextsig.sig.TrackPosition.x or not dir and x > nextsig.sig.TrackPosition.x) and nextsig.sig or nextsig.nextsig
				if not sig then continue end
				local leng = math.abs(x - sig.TrackPosition.x)
				if not minleng or leng < minlengprin then
					minx = leng
					forwsig = sig
				end
			end
		end
			
		local nextsigs = LinkedBackTracksToSignals[pathid] and LinkedBackTracksToSignals[pathid][dir] and LinkedBackTracksToSignals[pathid][dir][node] and LinkedBackTracksToSignals[pathid][dir][node]
		if #nextsigs == 0 then
			backsig = nextsigs.nextsig
		else
			local minleng
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
	Metrostroi.PostSignalInitialize = function(...)
		Metrostroi.GetARSJoint = Metrostroi.oldGetARSJoint
		timer.Create("metrostroi PostSignalInitialize upgrade",2,1,function()
			UpgradeTracks()
			RemoveUselessRepeaters()
			GenerateOccupationSections()
			LinkTracksToSignals()
			LinkBackTracksToSignals()
			Metrostroi.GetARSJoint = Metrostroi.NewGetARSJoint
		end)
		return oldPostInit(...)
	end
end)

local function compareTables(new,old)
	for k in pairs(new)do
		if not old[k] then return k end
	end
end

hook.Add("InitPostEntity","Metrostroi signals occupation upgrade",function()
	local SIGNAL = scripted_ents.GetStored("gmod_track_signal").t
	--основу скопировал из ентити сигнала
	SIGNAL.CheckOccupation = function(self)
		if not self.Close and not self.KGU then --not self.OverrideTrackOccupied and
			if not table.IsEmpty(self.OccupiedTfd or et) then
				-- добавил self.OccupiedTfd ~= self.PrevOccupiedTfd с надеждой на то, что уменьшу количество вызовов функции compareTables
				local newwag = self.OccupiedTfd ~= self.PrevOccupiedTfd and compareTables(self.OccupiedTfd, self.PrevOccupiedTfd)
				if newwag then
					self.OccupiedBy = newwag
					self.InvationSignal = false
				end
			else
				self.OccupiedBy = nil
			end
			self.Occupied = self.OccupiedBy and true
			self.PrevOccupiedTfd = self.OccupiedTfd
			if self.Routes[self.Route] and self.Routes[self.Route].Manual then
				self.Occupied = self.Occupied or not self.Routes[self.Route].IsOpened
			end
		else
			self.NextSignalLink = nil
			self.Occupied = self.Close or self.KGU --self.OverrideTrackOccupied or
		end
	end
	
	local oldinit = SIGNAL.Initialize
	SIGNAL.Initialize = function(self,...)
		self.OccupiedTfd = {}
		self.PrevOccupiedTfd = {}
		return oldinit(self,...)
	end
	
	-- TODO проверить, будет ли адекватно везде работать
	local oldARSLogick = SIGNAL.ARSLogic
	SIGNAL.ARSLogic = function(self,...)
		if self.Routes[self.Route or 1].Repeater then self:CheckOccupation() end
		return oldARSLogick(self,...)
	end	
	
	
	local oldpostinit = SIGNAL.PostInitalize
	SIGNAL.PostInitalize = function(...)
		Metrostroi.GetARSJoint = Metrostroi.oldGetARSJoint
		local res oldpostinit(...)
		Metrostroi.GetARSJoint = Metrostroi.NewGetARSJoint
		return res
	end
end)
