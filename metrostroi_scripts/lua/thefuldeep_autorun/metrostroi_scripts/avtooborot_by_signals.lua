timer.Simple(0,function()
	if not ulx or not ulx.command then return end
	
	local function toggle(calling_ply,str)
		if CLIENT then return end
		calling_ply:ConCommand("thefuldeeps_avtooborot_toggle_"..str)
	end
	local comm = ulx.command("Metrostroi", "ulx avtooborot", toggle, "!avtooborot", true, false, true)
	comm:addParam{ type=ULib.cmds.StringArg, hint="name"}
	comm:defaultAccess(ULib.ACCESS_OPERATOR)
	comm:help("Включить/выключить автооборот по его имени")
	
	local function info(calling_ply)
		if CLIENT then return end
		calling_ply:ConCommand("thefuldeeps_avtooborot_info")
	end
	local comm = ulx.command("Metrostroi", "ulx avtooborotinfo", info, "!avtooborotinfo", true, false, true)
	comm:defaultAccess(ULib.ACCESS_ALL)
	comm:help("Вывести в чат информацию об автооборотах")
end)
if CLIENT then return end

--ulx.fancyLogAdmin(ply, true, "#A заспавнил #s", TrainName)
--ulx.fancyLog(true, "Вагонов: #i", WagNum)

Metrostroi = Metrostroi or {}
Metrostroi.TheFulDeepsAvtooborot = Metrostroi.TheFulDeepsAvtooborot or {}
local TheFulDeepsAvtooborot = Metrostroi.TheFulDeepsAvtooborot

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

TheFulDeepsAvtooborot.Add = function(Name,Commands,Occupied,NotOccuped,NeedOpened,NeedNotOpened)--в качестве аргументов подаются таблицы имен сигналов
	Commands = Commands or {}
	Occupied = Occupied or {}
	NotOccuped = NotOccuped or {}
	NeedOpened = NeedOpened or {}
	NeedNotOpened = NeedNotOpened or {}
	if not istable(Commands) then Commands = {tostring(Commands)} end
	if not istable(Occupied) then Occupied = {tostring(Occupied)} end
	if not istable(NotOccuped) then NotOccuped = {tostring(NotOccuped)} end
	if not istable(NeedOpened) then NeedOpened = {tostring(NeedOpened)} end
	if not istable(NeedNotOpened) then NeedNotOpened = {tostring(NeedNotOpened)} end
	if not Name or not isstring(Name) or Name == "" then ChatPrint(nil,"wrong Avtooborot Add arguments") return end
	Name = Name:gsub(' ', '_')
	
	concommand.Add(
		"thefuldeeps_avtooborot_toggle_"..Name,
		function(ply)
			if IsValid(ply) and not ply:IsAdmin() then ChatPrint(ply,"Только админ может переключать автооборот") return end
			if ConditionsTbls[Name][6] then
				ConditionsTbls[Name][6] = nil
				ChatPrintAll("Автооборот "..Name.." включен.",ply)
			else
				ConditionsTbls[Name][6] = true
				ChatPrintAll("Автооборот "..Name.." выключен.",ply)
			end
		end,
		nil,
		"enabling/disabling avtooborot by name",
		128
	)
	--имя = команды, занятые, не занятые, должен быть открыт, должен быть не открыт, выключен ли, открыт ли, количество проверок (защита от ложных срабатываний)
	ConditionsTbls[Name] = {Commands,Occupied,NotOccuped,NeedOpened,NeedNotOpened,false,false,0}
	print("added avtooborot "..Name)
end
local Add = TheFulDeepsAvtooborot.Add

TheFulDeepsAvtooborot.Remove = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	ConditionsTbls[Name] = nil
	concommand.Remove("thefuldeeps_avtooborot_toggle_"..Name)
	print("Автооборот "..Name.." удален.")
end
local Remove = TheFulDeepsAvtooborot.Remove

TheFulDeepsAvtooborot.Toggle = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	RunConsoleCommand("thefuldeeps_avtooborot_toggle_"..Name)
end
local Toggle = TheFulDeepsAvtooborot.Toggle

concommand.Add(
	"thefuldeeps_avtooborot_info",
	function(ply)
		if table.Count(ConditionsTbls) == 0 then ChatPrint(ply,"Автооборотов нет.") return end
		for name,tbl in pairs(ConditionsTbls) do
			ChatPrint(ply,name.." "..(tbl[6] and "off" or "on"))
		end
	end,
	nil,
	"show avtooborot info"
)


local NamesSignals = {}
hook.Add("OnEntityCreated","Update NamesSignals table for avtooborot",function(ent)
	timer.Simple(0,function()
		if not IsValid(ent) or ent:GetClass() ~= "gmod_track_signal" then return end
		timer.Create("Update NamesSignals table for avtooborot",2,1,function()
			for _,sig in pairs(ents.FindByClass("gmod_track_signal")) do
				if IsValid(sig) and sig.Name then NamesSignals[sig.Name] = sig end
			end
		end)
	end)
end)

local function CheckOccupationTbl(tbl,needoccuped)--во время перевода стрелок occupied становится true. Это проблема
	for _,name in pairs(tbl) do
		local sig = NamesSignals[name]
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
		local sig = NamesSignals[name]
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

local function CompareTables(tbl1,tbl2)
	for _,val1 in pairs(tbl1) do
		if not table.HasValue(tbl2,val1) then return end
	end
	return true
end

local function CheckCondition(tbl,dothings)
	if not tbl[6] and CheckOccupationTbl(tbl[2],true) and CheckOccupationTbl(tbl[3]) and CheckForOpened(tbl[4],true) and CheckForOpened(tbl[5]) then
		tbl[8] = 0
		if tbl[7] then return end--tbl[7] означает, что этот автооборот уже сработал
		
		if dothings then
			--если есть несколько условий для открытия одного маршрута, то всем условиям сообщяю, что маршрут открыт
			for _,t in pairs(ConditionsTbls) do
				if CompareTables(t[1], tbl[1]) then t[7] = true end
			end
				
			local comms = tbl[1]
			for _,comm in pairs(comms) do
				for _,sig in pairs(NamesSignals) do
					if sig.SayHook then sig:SayHook(nil,comm) end
				end
				ChatPrintAll(comm)
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
	for _,tbl in pairs(ConditionsTbls) do
		if CheckCondition(tbl)then timer.Simple(opendelay,function()CheckCondition(tbl,true)end)end
	end
end

timer.Create("Avtooborot Think",timerdelay,0,AvtooborotThink)


--эти две строчки, чтобы я могу перезапускать скрипт
for name,tbl in pairs(ConditionsTbls)do Remove(name)end
for _,sig in pairs(ents.FindByClass("gmod_track_signal"))do if IsValid(sig)and sig.Name then NamesSignals[sig.Name]=sig end end




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
end