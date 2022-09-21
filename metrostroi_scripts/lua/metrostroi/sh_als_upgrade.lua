-- сигналы определяют занятость перепригивая на другие треки
-- функция GetARSJoint работает быстрее, так как просто проверяется по нужному ноуду, а не производит поиск по треку
-- TODO сравнить скорость выполнения дефолтной и новой версии GetARSJoint
-- TODO узнать, что быстрее, два раза обращение к полю таблицы или один раз помещение в таблицу и два раза обращение к этой переменной?\
--TODO в местах, где треки рядом, уточнять угол паравоза (то есть прокачать getpositionontrack)
--TODO деление на чанки для определенеия позиции не треке? там проблема, что можнт неудачно встать граница чанка. как вариант - проверять соседние чанки (но тогда 27 чанков + изначальный поиск чанка)
--TODO не до конца проверено удаление ненужных повторителей и добавление CheckOccupation повторителям
local et = {}

if CLIENT then
	local ShowPaths=true
	hook.Add("MetrostroiLoaded","Metrostroi.AlsUpgrade",function()
		local  c_metrostroi_trackeditor_togglenodes = concommand.GetTable()
		c_metrostroi_trackeditor_togglenodes = c_metrostroi_trackeditor_togglenodes.metrostroi_trackeditor_togglenodes

		concommand.Add("metrostroi_trackeditor_togglenodes",function()
			c_metrostroi_trackeditor_togglenodes()
			ShowPaths=not ShowPaths
		end)
	end)
	
	local receiivedTbl = {nodeposs = {}}
	local receiivedStr = ""
	--tbltosend = {forwsigs = {forwdir = {}, backdir = {}}, backsigs = {forwdir = {}, backdir = {}}, occupiedsigs = {false = {}, true = {}}, nodeposs = {}, nodeangs = {}}
	net.Receive("Metrostroi.AlsUpgrade",function()
		local leng = net.ReadUInt(16)
		if leng == 0 then
			receiivedTbl = util.JSONToTable(util.Decompress(receiivedStr))
			receiivedStr = ""
			for i = 1, #receiivedTbl.nodeposs do
				receiivedTbl.nodeposs[i] = Vector(receiivedTbl.nodeposs[i][1],receiivedTbl.nodeposs[i][2],receiivedTbl.nodeposs[i][3])
				receiivedTbl.nodeangs[i] = Angle(receiivedTbl.nodeangs[i][1],receiivedTbl.nodeangs[i][2],receiivedTbl.nodeangs[i][3])
			end
		else
			receiivedStr = receiivedStr..net.ReadData(leng)
		end
	end)
	
	local texts = {}
	local viewpos = Vector(0)
	local maxdist = 2000^2
	local backang = Angle(0,180,0)
	local offset = Angle(0,90+180,90)
	local zeroangle = Angle(0,0,0)
	timer.Create("Metrostroi.AlsUpgrade",1,0,function()
		if not ShowPaths then return end
		texts = {}
		
		for idx = 1, #receiivedTbl.nodeposs do
			if receiivedTbl.nodeposs[idx]:DistToSqr(viewpos) > maxdist then continue end
			for i = 0,1 do
				local newidx = table.insert(texts,{})
				texts[newidx].pos = receiivedTbl.nodeposs[idx]
				texts[newidx].ang = receiivedTbl.nodeangs[idx] + offset + (i == 0 and zeroangle or backang)
				texts[newidx].texts = {}
				for d = 0,2 do
					local tbl = d == 0 and (i == 0 and receiivedTbl.forwsigs.forwdir[idx] or receiivedTbl.forwsigs.backdir[idx]) or d == 1 and (i == 0 and receiivedTbl.backsigs.forwdir[idx] or receiivedTbl.backsigs.backdir[idx]) or (i == 0 and receiivedTbl.occupiedsigs["true"][idx] or receiivedTbl.occupiedsigs["false"][idx])
					for _,signame in ipairs(tbl)do
						table.insert(texts[newidx].texts, d == 0 and "next "..signame or d == 1 and "prev "..signame or d == 2 and "occup "..signame)
					end
				end
			end
			-- if table.IsEmpty(texts[newidx].texts) then table.remove(texts,newidx)end
		end
	end)



	local font = "Default"
	local drawSimpleTextOutlined = draw.SimpleTextOutlined
	local r,g,b = 255,255,255
	local color = Color(r,g,b,255)
	local color2 = Color(255-r,255-g,255-b,255)
	local EyePos = EyePos
	hook.Add("PreDrawEffects","Metrostroi.AlsUpgrade",function()
		if not ShowPaths then return end
		viewpos = EyePos()
		
		for _,params in pairs(texts) do
			cam.Start3D2D(params.pos,params.ang,1)
				local hlast = 0
				for _,text in pairs(params.texts) do
					local w,h = drawSimpleTextOutlined(text, font, 0, hlast, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color2)
					hlast = hlast - h
				end
			cam.End3D2D()
		end
	end)
end
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
local maxdist = (384/2)^2 -- это дефолтный Y_PAD в функции GetPositionOnTrack 
local parts = 3
--максимальная дистанция между ноудами одного трека - 500 (MAX_NODE_DISTANCE в sv_trackeditor.lua)
--делю каждый ноуд на три части, и тогда лимит в 192 пройдет корректно
local function FindNearNode(node,ignorePaths)--довольно медленная функция, но она вызывается только при загрузке сигналки, поэтому пофиг
	ignorePaths = ignorePaths or et
	local nodepathid = node.path.id
	local nodeid = node.id
	local pos = node.pos
	local nrearestnode,curdist,x,lerptonext
	for pathid,path in pairs(Metrostroi.Paths)do
		if ignorePaths[pathid] then continue end
		for id,node1 in ipairs(path)do
			if pathid == nodepathid and math.abs(id - nodeid) < 5 then continue end--если это соседний ноуд того же трека, то пропустить. Почему именно 5? да прост взял от балды число
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

local function IsTablesDifferents(tbl1,tbl2)
	for k,v in pairs(tbl1)do
		if tbl2[k] ~= v then return true end
	end
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
				if not selfnode then continue end
				local selfang = (selfnode.pos - (i == 1 and p[2].pos or p[count-1].pos)):Angle()[2]--угол в сторону крайнего ноуда
				local another,lerptonext = FindNearNode(selfnode,ignorePaths)--может можно использовать Metrostroi.NearestNodes(pos)?
				local ignorePaths = {}
				while another do
					ignorePaths[another.path.id] = true
					--если перепрыгнул не на крайний ноуд или
					--если перепрыгивает на новый трек, и у этого нового трека это крайний, то добавлять только в том случае, если угол подходит
					
					--тут отсекаются ограничения по углам
					if not
						(
							another.next and another.prev
							or not another.prev and another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90
							or not another.next and another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90
						)
					then
						another,lerptonext = FindNearNode(selfnode,ignorePaths)--может можно использовать Metrostroi.NearestNodes(pos)?
						continue
					end
							
					continuations[id][idx] = continuations[id][idx] or {}
					local n = table.insert(continuations[id][idx],
						{
							another.path.id,
							another.id,
							another.x + (another.pos:Distance(LerpVector(lerptonext,another.pos, lerptonext ~= 0 and another.next.pos or another.pos)))*0.01905,
							--тут не надо второе. Так как если перепрыгивает не на край нового трека, то этого условия хватает. А если это край, то отсекается условиями выше
							another.next and math.abs(selfang - (another.next.pos - another.pos):Angle()[2]) < 90 or false --[[ another.prev and math.abs(selfang - (another.prev.pos - another.pos):Angle()[2]) > 90]],
							i == 2
						}
					)
					
					--связываю в обратную сторону для того, чтобы можно было "спрыгивать" не только с краев
					--если перепрыгивание было на другоей конец, то пропускаю, так как он сам потом свяжется в обратную сторону. То есть таким образом избегаю дублей
					--закомментил, потому что это условие не работает, потому что может случиться так, что треки сканируются не в "идеальном" порядке
					--Так что прописал удаление дубликатов отдельно в конце, когда все уже сгенерировано
					-- if not (another.next and another.prev) then
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
					-- end
					another,lerptonext = FindNearNode(selfnode,ignorePaths)--может можно использовать Metrostroi.NearestNodes(pos)?
				end
			end
		end
	end
	
	--очистка от дубликатов и принт заликнованных сигналов
	for k,v in pairs(continuations)do
		for k1,v2 in pairs(v)do
			for k3,v3 in pairs(v2)do
				for k4,v4 in pairs(v2)do
					if k3 ~= k4 and not IsTablesDifferents(v3,v4)then 
						table.remove(v2,k4)
						-- print("removed dubplicate")
					end
				end
			-- print("linked path",k,"node",k1,"and path",v3[1],"node",v3[2],"new dir is",v3[4],"allow from dir",v3[5])
			end
		end
	end
	print("Metrostroi: Linked Pahts")
end


local function findfunc(startnode,startx,dir,back,returnPassedNodes)
	if back then dir = not dir end
	local curnodes = {{startx},{dir},{startnode}}--так будет только три таблицы
	local nodescount = 1
	local wasNodes = {}
	-- local EndSignals = {}
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
		
		--проверка на рекурсию. В первую очередь делалась для луплайна
		if wasNodes[curnode] ~= nil then continue end
		wasNodes[curnode] = dir or false --нельзя, чтобы сюда попал nil
		
		
		--поиск сигнала
		local needcontinue
		if Metrostroi.SignalEntitiesForNode[curnode] then
			local nearestent
			for _,ent in pairs(Metrostroi.SignalEntitiesForNode[curnode]) do
				if IsValid(ent) and (back and dir ~= ent.TrackDir or not back and dir == ent.TrackDir) and ent.OutputARS ~= 0 and (dir and ent.TrackPosition.x > startx or not dir and ent.TrackPosition.x < startx) then
					if not nearestent or math.abs(startx - ent.TrackX) < math.abs(startx - nearestent.TrackX) then--поиск ближайшего
						nearestent = ent
						startEnds[2][pathid] = nearestent.TrackX
					end
				end
			end
			
			if nearestent then
				if not returnPassedNodes then
					-- if not allEndSignals then
						return nearestent
					-- else
						-- EndSignals[nearestent] = true
						-- needcontinue = true
					-- end
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


local OccupationSections = {}
local function GenerateOccupationSections()
	OccupationSections = {}
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if not IsValid(sig) or not sig.TrackPosition then continue end
		
		--поиск всех отрезков занятости от каждого сигнала
		local way, nodes = findfunc(sig.Node,sig.TrackPosition.x,sig.TrackDir,false,true)
		local pathid = sig.TrackPosition.path.id
		for pathid,startx in pairs(way[1])do
			OccupationSections[pathid] = OccupationSections[pathid] or {}
			for node,dir in pairs(nodes) do
				-- начальный ноуд будет с условием по иксу, а все следующие без условия (даже если там впереди будет сигнал, думаю не страшно)
				OccupationSections[pathid][node] = OccupationSections[pathid][node] or {}
				OccupationSections[pathid][node][dir] = OccupationSections[pathid][node][dir] or {}
				if node ~= sig.Node then
					table.insert(OccupationSections[pathid][node][dir],{sig=sig})--тут таблица {sig = sig}, а не просто значение sig, потому что она может проверяться на поле start
				else
					table.insert(OccupationSections[pathid][node][dir],{sig=sig,start=startx})
				end
			end
		end
	end
	--TODO тут можно пройтись по полученным ноудам и дать дополнительный ключ тем, у которых все сигналы без startx (ну или наоборот)
	--чтобы в таймере сразу по этому ключу обрезать один из двух циклов. Но я думаю это будет мизерное изменение в производительности
	print("Metrostroi: Linked Signals to nodes for Occupation")
end


local LinkedTracksToSignals = {}
local LinkedBackTracksToSignals = {}
local function LinkTracksToSignals()
	LinkedTracksToSignals = {}
	LinkedBackTracksToSignals = {}
	
	for b = 0,1 do
		local linksTbl = b == 1 and LinkedBackTracksToSignals or LinkedTracksToSignals
		local wasNodes = {}
		for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
			if not IsValid(sig) or not sig.TrackPosition then continue end
			
			local pathid = sig.Node.path.id
			local node = sig.Node
			wasNodes[node] = wasNodes[node] or {}
			wasNodes[node][sig.TrackDir] = true
			linksTbl[pathid] = linksTbl[pathid] or {}
			linksTbl[pathid][sig.TrackDir] = linksTbl[pathid][sig.TrackDir] or {}
			linksTbl[pathid][sig.TrackDir][node] = linksTbl[pathid][sig.TrackDir][node] or {}
			table.insert(linksTbl[pathid][sig.TrackDir][node],{["sig"] = sig, ["nextsig"] = findfunc(node,sig.TrackPosition.x,sig.TrackDir,b == 1)})
		end
		
		-- вот это самая калящая меня часть, возможно она будет отрабатывать сто лет
		for pathid,path in pairs(Metrostroi.Paths or et)do
			for i = 1, #path do
				local node = path[i]
				linksTbl[pathid] = linksTbl[pathid] or {}
				for dirdec = 0,1 do
					local dir = dirdec == 1
					--если на этом ноуде есть сигнал, то он пропускается
					--в принципе эту проверку можно было заменить на if Metrostroi.SignalEntitiesForNode[node] then continue end, было бы тоже самое
					--но у меня перед этим еще проверяется на IsValid, поэтому нынешний вариант лучше
					if wasNodes[node] and wasNodes[node][dir] then continue end
					linksTbl[pathid][dir] = linksTbl[pathid][dir] or {}
					linksTbl[pathid][dir][node] = linksTbl[pathid][dir][node] or {}
					linksTbl[pathid][dir][node].nextsig = findfunc(node,node.x,dir, b==1)
				end
			end
		end
	end
	print("Metrostroi: Linked Signals to nodes for ALS")
end


timer.Create("Metrostroi Signals Occupation Upgrade",1,0,function()
	--смотрю каждую позицию поездов и указываю занятость в сигналам по сгенерированной таблице
	for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do
		if IsValid(sig) then
			sig.OccupiedTfd = ""
		end
	end

	for train,pos in pairs(Metrostroi.TrainPositions)do
		if not pos[1] then continue end
		pos = pos[1]
		local trainx = pos.x
		local pathid = pos.path.id
		if not OccupationSections[pathid] or not OccupationSections[pathid][pos.node1] then continue end
		for d = 0,1 do
			local dir = d == 1
			local minlen,occupiedbyx
			for _,condition in ipairs(OccupationSections[pathid][pos.node1][dir] or et)do
				-- тут надо найти самый ближний в правильном направлении
				if not IsValid(condition.sig) or not condition.start then continue end
				local startx = condition.start
				local sigdir = condition.sig.TrackDir
				if sigdir and trainx > startx or not sigdir and trainx < startx then
					local len = math.abs(startx - trainx)
					if not minlen or len < minlen then
						occupiedbyx = condition.sig
						minlen = len
					end
				end
			end
			if occupiedbyx then
				occupiedbyx.OccupiedTfd = occupiedbyx.OccupiedTfd..train:EntIndex()
				-- print(occupiedbyx and occupiedbyx.Name, "occupied by x")
			else
				for _,condition in ipairs(OccupationSections[pathid][pos.node1][dir] or et)do
					if not IsValid(condition.sig) or condition.start then continue end
					condition.sig.OccupiedTfd = condition.sig.OccupiedTfd..train:EntIndex()
					-- print(condition.sig and condition.sig.Name,"occupied by node")
				end
			end
		end
	end
end)

--мб тут надо поменять
--Удалять повторители надо в том случае, если у него только один маршрут и это только репитер (или все маршруты без условий указывают на один сигнал) (короче если репитер всегда указывает только на один спал (если у него есть второй роут с другим сигналом но без условий - не трогать, потому что возможно им управляют через луа)) и при его удалении некстсигнал у светофора, который указывал на репитер, некстсигнал не поменяется. Итого - у репитера должен быть один роут без условий и при его удалении будет тот же сигнал если просто скипать репитер для всех светофоров, которые указывают на этот репитер, ну и реконфинурировать сигналы, которые указывали на репитер
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
					-- print("reconfiguting signal "..(sig2.Name or tostring(sig2).." "..sig2:EntIndex()).." because of deleting signal "..nextsignalName)
				end
			end
		end
		SafeRemoveEntity(sig)
		-- print("removed signal "..sig.Name.." because it useless repeater")
	end
end

-- при нажатии на кнопку load в трек эдиторе, на каждом ноуде будут рисоваться сигналы спереди, сзади и те, что будут occupied
util.AddNetworkString("Metrostroi.AlsUpgrade")

hook.Add("MetrostroiLoaded","UpgradeTracks",function()
	Metrostroi.oldGetARSJoint = Metrostroi.GetARSJoint
	function Metrostroi.NewGetARSJoint(node,x,dir,train)
		local forwsig,backsig
		for b = 0,1 do
			local linksTbl = b == 1 and LinkedBackTracksToSignals or LinkedTracksToSignals
			local res
			local pathid = node.path.id
			local nextsigs = linksTbl[pathid] and linksTbl[pathid][dir] and linksTbl[pathid][dir][node]
			if not nextsigs then continue end
			--если на ноуде не было сигналов, то ему дается только одно поле nextsig
			if #nextsigs == 0 then
				res = nextsigs.nextsig
			else
				-- если "спереди" на этом ноуде сигналов нет, то беру nextsig от ближайщего (то есть ближайшего "заднего")
				-- если есть то беру sig ближайшего (то есть самого ближайшего)
						
				--памятка для себя. Как это я проверяю по иксу, а вдруг сигнал на другом треке? 
				--Тут проверяются сигналы которые конкретно на ноуде, на котором стоит вагон (если на этом ноуде нет сигналов, то#nextsigs == 0)
				--поэтому это работает
				local minlenforw, minlen, sigforw, sig
				--по сути тут можно использовать ipairs, но разницы не будет, так как если #nextsigs~=0 то в таблице будут только числовые ключи
				for _,nextsig in pairs(nextsigs)do
					-- только тут условия местами поменялись по сравнению с комментом выше
					local len = math.abs(x - nextsig.sig.TrackPosition.x)
					if dir and (b ~= 1 and x < nextsig.sig.TrackPosition.x or b == 1 and x > nextsig.sig.TrackPosition.x) or not dir and (b ~= 1 and x > nextsig.sig.TrackPosition.x or b == 1 and x < nextsig.sig.TrackPosition.x) then
						if not minlenforw or len < minlenforw then
							minlenforw = len
							sigforw = nextsig.sig
						end
					else
						if not minlen or len < minlen then
							minlen = len
							sig = nextsig.nextsig
						end
					end
				end
				res = sigforw or sig
			end
			
			if b == 1 then backsig = res else forwsig = res end
		end
		-- print("forw",forwsig and forwsig.Name, "back",backsig and backsig.Name)
		return forwsig, backsig
	end
	
	local oldPostInit = Metrostroi.PostSignalInitialize
	Metrostroi.PostSignalInitialize = function(...)
		Metrostroi.GetARSJoint = Metrostroi.oldGetARSJoint
		timer.Create("metrostroi PostSignalInitialize upgrade",2,1,function()
			UpgradeTracks()
			--отключил потому что хз кто там чо через луа как будет сигналы трогать
			--RemoveUselessRepeaters()
			GenerateOccupationSections()
			LinkTracksToSignals()
			Metrostroi.GetARSJoint = Metrostroi.NewGetARSJoint
		end)
		return oldPostInit(...)
	end
	
	
	local c_metrostroi_trackeditor_load = concommand.GetTable()
	c_metrostroi_trackeditor_load = c_metrostroi_trackeditor_load.metrostroi_trackeditor_load

	concommand.Add("metrostroi_trackeditor_load",function(ply,cmd,args,fullstring)
		c_metrostroi_trackeditor_load(ply,cmd,args,fullstring)
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end
		local tbltosend = {forwsigs = {forwdir = {}, backdir = {}}, backsigs = {forwdir = {}, backdir = {}}, occupiedsigs = {[false] = {}, [true] = {}}, nodeposs = {}, nodeangs = {}}
		for pathid,path in pairs(Metrostroi.Paths or et)do
			for nodeid, node in ipairs(path)do
				local idx = #tbltosend.nodeposs + 1
				tbltosend.nodeposs[idx] = {node.pos[1],node.pos[2],node.pos[3]}
				tbltosend.nodeangs[idx] = node.next and (node.next.pos - node.pos):Angle() or node.prev and (node.pos - node.prev.pos):Angle()
				tbltosend.nodeangs[idx] = {tbltosend.nodeangs[idx][1],tbltosend.nodeangs[idx][2],tbltosend.nodeangs[idx][3]}
				for i = 0,1 do
					local dir = i == 1
					for b = 0,1 do
						local tbllinks = b == 1 and LinkedBackTracksToSignals or LinkedTracksToSignals or et
						local nextsigs = tbllinks[pathid] and tbllinks[pathid][dir] and tbllinks[pathid][dir][node]
						if not nextsigs then continue end
						local key = b == 1 and "backsigs" or "forwsigs"
						local key2 = dir and "forwdir" or "backdir"
						tbltosend[key][key2][idx] = tbltosend[key][key2][idx] or {}
						table.insert(tbltosend[key][key2][idx], nextsigs.nextsig and nextsigs.nextsig.Name)
						for _,nextsig in pairs(nextsigs or et)do
							table.insert(tbltosend[key][key2][idx], nextsig.nextsig and nextsig.nextsig.Name)
							table.insert(tbltosend[key][key2][idx], nextsig.sig and nextsig.sig.Name)
						end
					end
					
					tbltosend.occupiedsigs[dir] = tbltosend.occupiedsigs[dir] or {}
					tbltosend.occupiedsigs[dir][idx] = tbltosend.occupiedsigs[dir][idx] or {}
					for _,tbl in ipairs(OccupationSections[pathid] and OccupationSections[pathid][node] and OccupationSections[pathid][node][dir] or et)do
						table.insert(tbltosend.occupiedsigs[dir][idx], tbl.sig and tbl.sig.Name)
					end
				end
			end
		end
		
		--именно такое отправление, чтобы с меньшей вероятностью кикнуло с причиной Client # overflowed reliable channel
		tbltosend = util.Compress(util.TableToJSON(tbltosend,true))
		local timeout = game.SinglePlayer() and 0 or 5
		for i = 1, #tbltosend, 60000 do
			timer.Simple(timeout,function()
				local data = string.sub(tbltosend,i,i+59999)
				net.Start("Metrostroi.AlsUpgrade")
					net.WriteUInt(#data, 16)
					net.WriteData(data,#data)
				net.Send(ply)
			end)
			timeout = timeout + (game.SinglePlayer() and 0 or 5)
		end
		timer.Simple(timeout,function()
			net.Start("Metrostroi.AlsUpgrade")
				net.WriteUInt(0, 16)
			net.Send(ply)
		end)

	end)	
end)


hook.Add("InitPostEntity","Metrostroi signals occupation upgrade",function()
	local SIGNAL = scripted_ents.GetStored("gmod_track_signal").t
	--основу скопировал из ентити сигнала
	SIGNAL.CheckOccupation = function(self)
		if not self.Close and not self.KGU then --not self.OverrideTrackOccupied and
			local OccupiedTfd = self.OccupiedTfd
			if self.NextSignalLink and self.NextSignalLink.PassOcc then OccupiedTfd = OccupiedTfd..self.NextSignalLink.OccupiedTfd end
			--поле OccupiedBy нужно для работы интервальных часов. Так бы я убрал его полностью
			if OccupiedTfd ~= "" then
				-- TODO тут пригласительный отключится не только в случае заезда нового вагона на блок участок, но и в случае исчезновения любого вагона с блок участка, а это наверное неправильно
				-- но я не хочу тратить ресурсы на обработку таблц, поэтому  оставил так
				--OccupiedBy надо для работы интервальных часов
				if OccupiedTfd ~= self.PrevOccupiedTfd then
					self.InvationSignal = false
				end
				self.Occupied = true
				self.OccupiedBy = true
			else
				self.Occupied = false
				self.OccupiedBy = false
			end
			self.PrevOccupiedTfd = OccupiedTfd
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
		self.OccupiedTfd = ""
		self.PrevOccupiedTfd = ""
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

	
