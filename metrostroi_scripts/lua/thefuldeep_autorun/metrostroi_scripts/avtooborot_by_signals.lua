--TODO возможность добавлять и убирать автообороты в игре
--возможно на других серверах будет работать некорректно, так как у меня свой алгоритм занятости сигналов
-- timer.Simple(0,function()
hook.Add("InitPostEntity","Avtooborot by signals init",function()
	if not ulx or not ulx.command then return end
	
	local function toggle(calling_ply,str)
		if CLIENT then return end
		calling_ply:ConCommand("metrostroi_avtooborot_toggle "..str)
	end
	local comm = ulx.command("Metrostroi", "ulx avtooborottoggle", toggle, "!avtooborottoggle", true, false, true)
	comm:addParam{ type=ULib.cmds.StringArg, hint="name"}
	comm:defaultAccess(ULib.ACCESS_OPERATOR)
	comm:help("Включить/выключить автооборот по его имени")
	
	local function info(calling_ply)
		if CLIENT then return end
		calling_ply:ConCommand("metrostroi_avtooborot_info")
	end
	local comm = ulx.command("Metrostroi", "ulx avtooborotinfo", info, "!avtooborotinfo", true, false, true)
	comm:defaultAccess(ULib.ACCESS_ALL)
	comm:help("Вывести в чат информацию об автооборотах")
end)
if CLIENT then return end

--ulx.fancyLogAdmin(ply, true, "#A заспавнил #s", TrainName)
--ulx.fancyLog(true, "Вагонов: #i", WagNum)

-- Metrostroi = Metrostroi or {}
-- Metrostroi.TheFulDeepsAvtooborot = Metrostroi.TheFulDeepsAvtooborot or {}
-- local TheFulDeepsAvtooborot = Metrostroi.TheFulDeepsAvtooborot
TheFulDeepsAvtooborot = TheFulDeepsAvtooborot or {}

TheFulDeepsAvtooborot.ConditionsTbls = TheFulDeepsAvtooborot.ConditionsTbls or {}
local ConditionsTbls = TheFulDeepsAvtooborot.ConditionsTbls
--local ConditionsTbls = {[name] = {command,occupied,notoccupied,disabled}, [name2] = {command,occupied,notoccupied,disabled}} --name - string, command - string, occupied и notoccupied - таблицы имен, disabled - bool


local function ChatPrint(ply,msg)
	if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
end

local function ChatPrintAll(msg,ply2)
	msg = "("..(IsValid(ply2) and ply2:Nick() or "Console")..") "..msg
	--[[if ulx.fancyLogAdmin then
		ulx.fancyLog(true,""..msg)
	else]]
		for _,ply in pairs(player.GetHumans()) do
			ply:ChatPrint(msg)
		end
	--end
end

concommand.Add(
	"metrostroi_avtooborot_toggle",
	function(ply,cmd,args)
		if IsValid(ply) and not (ply:IsSuperAdmin() or ULib and ULib.ucl.query(ply,"ulx avtooborottoggle")) then ChatPrint(ply,"Недостаточно прав для переключения автооборота") return end
		local Name = args[1]
		if not Name or not ConditionsTbls[Name] then
			ChatPrint(ply,"Автооборота с именем '"..(Name or '').."' не найдено")
			return
		end
		if ConditionsTbls[Name][6] then
			ConditionsTbls[Name][6] = nil
			ChatPrintAll("Автооборот "..Name.." включен.",ply)
		else
			ConditionsTbls[Name][6] = true
			ChatPrintAll("Автооборот "..Name.." выключен.",ply)
		end
	end,
	nil,
	"enabling/disabling avtooborot by name"
)

TheFulDeepsAvtooborot.Add = function(Name,Commands,Occupied,NotOccuped,NeedOpened,NeedNotOpened,SwitchesToChange,SwitchesToCheck,RouteIndexesToOpen)--в качестве аргументов подаются таблицы имен сигналов
	Commands = Commands or {}
	Occupied = Occupied or {}
	NotOccuped = NotOccuped or {}
	NeedOpened = NeedOpened or {}
	NeedNotOpened = NeedNotOpened or {}
	SwitchesToChange = SwitchesToChange or {}
	SwitchesToCheck = SwitchesToCheck or {}
	RouteIndexesToOpen = RouteIndexesToOpen or {}
	if not istable(Commands) then Commands = {tostring(Commands)} end
	if not istable(Occupied) then Occupied = {tostring(Occupied)} end
	if not istable(NotOccuped) then NotOccuped = {tostring(NotOccuped)} end
	if not istable(NeedOpened) then NeedOpened = {tostring(NeedOpened)} end
	if not istable(NeedNotOpened) then NeedNotOpened = {tostring(NeedNotOpened)} end
	if not istable(SwitchesToChange) then SwitchesToChange = {tostring(SwitchesToChange)} end
	if not istable(SwitchesToCheck) then SwitchesToCheck = {tostring(SwitchesToCheck)} end
	--if not istable(RouteIndexesToOpen) then RouteIndexesToOpen = {tostring(RouteIndexesToOpen)} end
	if not Name or not isstring(Name) or Name == "" then ChatPrint(nil,"wrong Avtooborot Add arguments") return end
	Name = Name:gsub('%s', '_')

	--имя = команды, занятые, не занятые, должен быть открыт, должен быть не открыт, выключен ли, открыт ли, количество проверок (защита от ложных срабатываний)
	ConditionsTbls[Name] = {Commands,Occupied,NotOccuped,NeedOpened,NeedNotOpened,false,false,0,SwitchesToChange,SwitchesToCheck,RouteIndexesToOpen}
	print("added avtooborot "..Name)
end
local Add = TheFulDeepsAvtooborot.Add

TheFulDeepsAvtooborot.Remove = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	ConditionsTbls[Name] = nil
	print("Автооборот "..Name.." удален.")
end
local Remove = TheFulDeepsAvtooborot.Remove

TheFulDeepsAvtooborot.Toggle = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	RunConsoleCommand("metrostroi_avtooborot_toggle_"..Name)
end
local Toggle = TheFulDeepsAvtooborot.Toggle

concommand.Add(
	"metrostroi_avtooborot_info",
	function(ply)
		if table.Count(ConditionsTbls) == 0 then ChatPrint(ply,"Автооборотов нет.") return end
		for name,tbl in pairs(ConditionsTbls) do
			ChatPrint(ply,name.." "..(tbl[6] and "off" or "on"))
		end
	end,
	nil,
	"show avtooborot info"
)


local function CheckOccupationTbl(tbl,needoccuped)--во время перевода стрелок occupied становится true. Это проблема
	for _,name in pairs(tbl) do
		local sig = Metrostroi.SignalEntitiesByName[name]
		if IsValid(sig) and ((needoccuped and not sig.Occupied) or (not needoccuped and sig.Occupied)) then return end
	end
	return true
end

--проверка на то, что указанный автооборот открыт или не открыт
--если автооборот выключен, то он пропускается
local function CheckForOpened(tbl,needopened)
	if needopened then
		for _,name in pairs(tbl) do
			local tbl = ConditionsTbls[name]
			if tbl and not tbl[6] and not tbl[7] then return end
		end
	else
		for _,name in pairs(tbl) do
			local tbl = ConditionsTbls[name]
			if tbl and not tbl[6] and tbl[7] then return end
		end
	end
	return true
end

--[[local function IsSignalsRed(tbl)
	for _,name in pairs(tbl) do
		local sig = Metrostroi.SignalEntitiesByName[name]
		if IsValid(sig) and sig.Red then return true end
	end
end

local function SignalCommand(signals,commands)
	for _,command in pairs(commands) do
		for _,signal in pairs(#signals > 0 and signals or ents.FindByClass("gmod_track_signal")) do
			if signal.
			signal:
		end
	end
end]]

local function CompareTables(tbl1,tbl2,forRouteIndexes)
	if forRouteIndexes then
		for signame,routeindex in pairs(tbl1) do
			if tbl2[signame] ~= routeindex then return end
		end
	else
		for _,val1 in pairs(tbl1) do
			if not table.HasValue(tbl2,val1) then return end
		end
	end
	return true
end

local function CheckSwitches(tbl)
	for _,name in pairs(tbl)do
		local state = name:sub(-1,-1)
		if state == "+" or state == "-" then
			for _,ent in pairs(ents.FindByName(swh:sub(1,-2)))do
				if IsValid(ent) and ent:GetClass() == "prop_door_rotating" then
					local curstate = ent:GetInternalVariable("m_eDoorState") or 0
					--TODO проверить правильность m_eDoorState, потому что я не помню, какие числа должны быть
					if state == "+" and curstate ~= 0 and curstate ~= 2 or state == "-" and curstate ~= 1 and curstate ~= 3 then return end
				end
			end
		end
	end
	return true
end

local function CheckRouteIndexes(tbl)
	for signame,routeindex in pairs(tbl)do
		local sig = Metrostroi.SignalEntitiesByName[signame]
		if IsValid(sig) and sig.Route ~= routeindex or (sig.Routes and sig.Routes[routeindex] and not sig.Routes[routeindex].IsOpened) then return end
	end
	return true
end

local function CheckCondition(tbl,dothings)
	--если добавить not CheckRouteIndexes(tbl[11]), то при ручном переводе оно вернет обратно
	--а без этого условия он откроет маршрут только если обновится состояние оккупации или открытия других оборотов
	if not tbl[6] and CheckOccupationTbl(tbl[2],true) and CheckOccupationTbl(tbl[3]) and CheckForOpened(tbl[4],true) and CheckForOpened(tbl[5]) and CheckSwitches(tbl[10]) --[[and not CheckRouteIndexes(tbl[11])]] then
		tbl[8] = 0
		if tbl[7] then return end--tbl[7] означает, что этот автооборот уже сработал
		
		if dothings then
			--если есть несколько условий для открытия одного маршрута, то всем условиям сообщяю, что маршрут открыт
			for _,t in pairs(ConditionsTbls) do
				if CompareTables(t[1], tbl[1]) or CompareTables(t[9], tbl[9]) or CompareTables(t[11], tbl[11],true) then t[7] = true end
			end
				
			local comms = tbl[1]
			for _,comm in pairs(comms) do
				for _,sig in pairs(Metrostroi.SignalEntitiesByName) do
					if IsValid(sig) then
						if sig.SayHook then sig:SayHook(nil,comm)
						elseif MSignalSayHook then MSignalSayHook(nil,comm)--TODO не работает для нового метростроя почему лол?
						end
					end
				end
				ChatPrintAll(comm)
			end
			

			for _,swh in pairs(tbl[9])do
				local pos = swh:sub(-1,-1)
				if pos == "+" or pos == "-" then
					for _,ent in pairs(ents.FindByName(swh:sub(1,-2)))do
						if IsValid(ent) and ent:GetClass() == "prop_door_rotating" then
							ent:Fire(pos == "+" and "Close" or "Open","","0")
						end
						ChatPrintAll(swh)
					end
				end
			end
			
			for signame,routeindex in pairs(tbl[11])do
				local sig = Metrostroi.SignalEntitiesByName[signame]
				--TODO не уверен, возможно тут нужны еще дополнительыне проверки (например как на sig.Close)
				if IsValid(sig) and sig.Routes and sig.Routes[routeindex] then 
					sig.Close = false
					sig:OpenRoute(routeindex)
					ChatPrintAll("Opening route '"..(sig.Routes[routeindex].RouteName and sig.Routes[routeindex].RouteName:find("%a") and sig.Routes[routeindex].RouteName or routeindex).."' for signal '"..signame.."'")
				end
			end
		else
			return true
		end
	else
		tbl[8] = tbl[8] + 1--возможно из-за этого будут приколы (баги)
		if tbl[8] == 2 then tbl[7] = false tbl[8] = 0 end
	end
end

local timerdelay = 5
local opendelay = timerdelay - 0.5

local function AvtooborotThink()
	if not Metrostroi or not Metrostroi.SignalEntitiesByName then return end
	for _,tbl in pairs(ConditionsTbls) do
		if CheckCondition(tbl)then timer.Simple(opendelay,function()CheckCondition(tbl,true)end)end
	end
end

timer.Create("Avtooborot Think",timerdelay,0,AvtooborotThink)


--эта строчка, чтобы я мог перезапускать скрипт
for name,tbl in pairs(ConditionsTbls)do Remove(name)end




local map = game.GetMap()
if map == "gm_mus_crimson_line_tox_v9_21" then
	
elseif map == "gm_metro_crossline_r199h" then
	--МОЛОДЕЖНАЯ
	--заезд
	Add("ml1-4","!sopen ml1-4",{"ML515"},{"ML517","ML3S","ML4S","ML4","ML3"})
	Add("ml1-3","!sopen ml1-3",{"ML515","ML4S",},{"ML517","ML3S","ML3","ML4"})
	
	--выезд
	Add("mle","!sopen mle",{"ML1S"},{"ML517","MLE","ML3","ML4","ML511"})
	--Add("mlg","!sopen mlg",{"MLDR1"},{"ML3","ML4","MLG"})--тут в конце тупика нет рельсовой цепи, поэтому не могу детектить занятость
	Add("ml4-2","!sopen ml4-2",{"ML4S"},{"ML3S","ML3","ML4",--[["MLDR1",]]"MLG"})
	Add("ml3-2","!sopen ml3-2",{"ML3S"},{"ML4S","ML3","ML4",--[["MLDR1",]]"MLG"})
	
	
	--полоитех
	Add("pt2-1","!sopen pt2-1",{"RC188"},{" DM","PT179MG","PT181","RC173"})
	Toggle("pt2-1")
	
	
	--международная
	--заезд
	Add("md2-3","!sopen md2-3",{"RC144A"},{"MD138G","MD1","MD2","MD5SA","MD6SA"})
	Add("md2-4","!sopen md2-4",{"RC144A","MD5SA"},{"MD138G","MD1","MD2","MD6SA"})
	
	--выезд
	Add("md6-2","!sopen md6-2",{"MD2SF"},{"MD138G","MD1","MD2","E","MD140","RC144A"})
	--Add("md1-1","!sopen md1-1",{"asd"},{"zxc"})--тут чота сложна
	Add("md3-1","!sopen md3-1",{"MD5SA"},{"MD1","MD2","MD6SA","G"})
	Add("md4-1","!sopen md4-1",{"MD6SA"},{"MD1","MD2","MD5SA","G"})
	
	
elseif map == "gm_metro_mosldl_v1" then
	--105(люблино)
	Add("lb1-3","!sopen lb1-3",{"197A"},{"RCLB51M","LB51M","LB3","LB3A"})
	Add("lbe-1","!sopen lbe-1",{"LB1A"},{"LBE","LB3","LB3A","LB65","197","197A","RCLB51M","LB51M"})
	Add("lbg-2","!sopen lbg-2",{"LBGA"},{"LB3","LB3A","LBG"})
	Add("lb3-2","!sopen lb3-2",{"LB3A"},{"RCLB51M","LB51M","LB3","LBG","LBGA"})
	
	--106(волжская)
	Add("vkdm-2","!sopen vkdm-2",{"175"},{"VK75","28","72M","VK74M"})
	Toggle("vkdm-2")
	
	--107(печатники)
	Add("px4-2","!sopen px4-2",{"PX4A"},{"PX2","PXOP1","PX82MG","50","48","46","44"})
	Add("px3-1","!sopen px3-1",{"PX3A"},{"PX1","PX1RC","PX85","143","141","139","137"})
	
	--109(дубровка)
	Add("db2-3","!sopen db2-3",{"110"},{"S102","DB102","DB4A","DB4","DB3A","DB3"})
	Add("db2-4","!sopen db2-4",{"110","DB3A"},{"S102","DB102","DB4A","DB4","DB3"})
	Add("db3-1","!sopen db3-1",{"DB3A"},{"S102","DB102","DB4A","DB4","DB3"})
	Add("db4-1","!sopen db4-1",{"DB4A"},{"S102","DB102","DB3A","DB4","DB3"})
	
	
elseif map == "gm_mus_orange_metro_h" then
	Add("mt2-1","!sopen mt2-1","MT236",{"MT238","MT222","MT111"},nil,{"mt2-1_2","mt1-1"})
	Add("mt2-2","!sopen mt2-2",{"MT236","MT111"},{"MT238","MT222"},nil,"mt2-1")
	
	Add("mt1-1","!sopen mt1-1","MT111","MT1",nil,"mt2-1_2")
	Add("mt12-1_2","!sopen mt2-1","MT222","MT1",nil,{"mt1-1","mt2-1","mt2-2"})
	
	
elseif map == "gm_metro_crossline_n3" then
	--международная
	Add("md2-3","!sopen md2-3","MD222A",{"MD218","MDE","MD2","MD1","MDA4","MDA3"},nil,{"md4-1","md3-1"})
	Add("md2-4","!sopen md2-4",{"MD222A","MDA3"},{"MD218","MDE","MD2","MD1","MDA4"},nil,"md4-1")
	
	Add("md3-1","!sopen md3-1","MDA3",{"MDG","MD2","MD1"},nil,{"md4-1","md1-1"})
	Add("md4-1","!sopen md4-1","MDA4",{"MDG","MD2","MD1"},nil,"md3-1","md1-1")
	--Add("md1-1","!sopen md1-1","MDA4",{"MDG","MD2","MD1"},nil,"md3-1","md1-1")--meh
	
	--пролетарская
	Add("pr1-2","!sopen pr1-2","401B",{"PR387","PRE","PR376","PRA1"},nil,"pr2-2")
	Add("pr2-2","!sopen pr2-2","PRA1",{"PR387","PR376"},nil,"pr1-2")
	
elseif map == "gm_jar_pll_remastered_v9" then
	--Новомосковская
	Add("nm5-1","!sopen nm5-1","NM7A",{"NM5","NM17","NM1","NM1O","NM3"},nil,{"nm1-2","nm1-3"})
	Add("nm1-2","!sopen nm1-2","NM1O",{"NM5","NM17","NMD","NM1","NM3","NM3O","NM31","NM33"},nil,{"nm5-1","nm3-2","nm3-3","nm1-3"})
	Add("nm1-3","!sopen nm1-3","NM1O",{"NM5","NM17","NMD","NM1","NM3","NM3O","NM31","NM33"},nil,{"nm5-1","nm3-2","nm3-3","nm1-2"})
	Toggle("nm1-3")
	
	Add("nm3-2","!sopen nm3-2","NM3O",{"NM5","NM17","NMD","NM1","NM3","NM31","NM33"},nil,{"nm1-2","nm3-3","nm1-3"})
	Add("nm3-3","!sopen nm3-3","NM3O",{"NM5","NM17","NMD","NM1","NM3","NM31","NM33"},nil,{"nm1-2","nm3-2","nm1-3"})
	Toggle("nm3-3")
	
	Add("nm19-2","!sopen nm19-2","NM15",{"NM19","NM2","NM4","NM6","NM9"},nil,"nm9-3")
	Add("nm9-3","!sopen nm9-3","NM7",{"NM9","NM19","NM15"},nil,"nm19-2")
	Toggle("nm9-3")
	
	Add("nm2-2","!sopen nm2-2",nil,{"NM4","NM6","NM19","NM15"})
	
	--Динамо
	Add("dn1-1","!sopen dn1-1","DNA3",{"DN3","DN5","DN7"})
	Add("dn2-1","!sopen dn2-1",nil,{"DN2172","DN3","DNA3","DN7","DNT4"},nil,"dn1-1")
	
	--Октябрьская
	Add("ok1-3","!sopen ok1-3","OK1129A",{"OK1133","OKE","OK3","OKA3"},nil,"ok3-2")
	Add("oke-1","!sopen oke-1","OKAA1",{"OKE","OK1133","OK1129A","OK1129","1127","1125"})
	
	Add("ok3-2","!sopen ok3-2","OKA3",{"OK3","OK1133","OKG"},nil,"okg-2")
	--Add("okg-2","!sopen okg-2","OKA2",{"OKG","OK3"},nil,"ok3-2")--OKA2 почему-то всегда занят, так что не могу тут сделать АД
	
	--Лесопарковая
	--[[гавно сложна TODO
	Add("lp3-1","{!sopen lp3-1",!sopen lp2-4},"LP1",{"LP153","LP151","LP2","LP4","LP5O","LP3","LP5","LP172","LP170"},nil,"lp4-1")
	Add("lp4-1","!sopen lp4-1","LP174",{"LP153","LP151","LP2","LP4","LP5O","LP3","LP5","LP172","LP170"},nil,"lp3-1")
	]]
	--TODO если у лесопарковой все свободно, то !sopen lp2-3
	--TODO если у лесопарковой занят третий и свободен четвертый то, то !sopen lp2-4
elseif map == "gm_metro_nsk_line_2_v4" then
	--площадь гарина михайловского
	Add("gm2-1","!sopen gm2-1","GM143A","GM112M",nil,"gm2-2","trackswitch_pg1-")
	Add("gm2-2","!sopen gm2-2",nil,{"GM112M","GM143","GM143A"},nil,"gm2-1","trackswitch_pg1+")
	
	--золотая нива
	Add("zn1-1","!sopen zn1-1","ZN194B",{"ZN311","ZN194A","ZN321","ZN194"},nil,"zn1-2","zn_switch1+")
	Add("zn1-2","!sopen zn1-2",nil,{"ZN311","ZN194A","ZN321","ZN194","ZN194B"},nil,"zn1-1","zn_switch1-")
elseif map == "gm_mustox_neocrimson_line_a" then
	--сталинская
	Add("ste-1","!sopen ste-1","RCST125A",{"STE","ST133","131A","ST131","ST127","ST123"},nil,{"st1-3","st1-4"})
	Add("st1-4","!sopen st1-4","131A",{"ST133","RCST31","RCST41","ST1","ST2"},nil,{"st4-2","st3-2"})
	Add("st1-3","!sopen st1-3",{"131A","RCST41"},{"ST133","RCST31","ST1"},nil,{"st3-2","st1-4"})
end