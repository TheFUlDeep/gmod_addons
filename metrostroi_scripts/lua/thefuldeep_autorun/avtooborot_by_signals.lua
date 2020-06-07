if 1 then return end

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
	msg = "("..(ply2 and ply2:Nick() or "Console")..") "..msg
	--[[if ulx.fancyLogAdmin then
		ulx.fancyLog(true,""..msg)
	else]]
		for _,ply in pairs(player.GetHumans()) do
			ply:ChatPrint(msg)
		end
	--end
end

TheFulDeepsAvtooborot.Add = function(Name,Commands,Occupied,NotOccuped)--в качестве аргументов подаются таблицы имен сигналов
	Commands = Commands or {}
	Occupied = Occupied or {}
	NotOccuped = NotOccuped or {}
	if not istable(Commands) then Commands = {tostring(Commands)} end
	if not istable(Occupied) then Occupied = {tostring(Occupied)} end
	if not istable(NotOccuped) then NotOccuped = {tostring(NotOccuped)} end
	if not Name or not isstring(Name) or Name == "" then ChatPrint(nil,"wrong Avtooborot Add arguments") return end
	Name = Name:gsub(' ', '_')
	
	concommand.Add(
		"thefuldeeps_avtooborot_toggle_"..Name,
		function(ply)
			if IsValid(ply) and not ply:IsAdmin() then ChatPrint(ply,"Только админ может переключать автооборот") return end
			if ConditionsTbls[Name][4] then
				ConditionsTbls[Name][4] = nil
				ChatPrintAll("Автооборот "..Name.." включен.",ply)
			else
				ConditionsTbls[Name][4] = true
				ChatPrintAll("Автооборот "..Name.." выключен.",ply)
			end
		end,
		nil,
		"enabling/disabling avtooborot by name",
		128
	)
	--имя = команды, занятые, не занятые, выключен ли, открыт ли, количество проверок (защита от ложных срабатываний)
	ConditionsTbls[Name] = {Commands,Occupied,NotOccuped,false,false,0}
	print("added avtooborot "..Name)
end

TheFulDeepsAvtooborot.Remove = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	ConditionsTbls[Name] = nil
	concommand.Remove("thefuldeeps_avtooborot_toggle_"..Name)
	print("Автооборот "..Name.." удален.")
end

TheFulDeepsAvtooborot.Toggle = function(Name)
	if not ConditionsTbls[Name] then print("автооборота с таким именем не существует") return end
	RunConsoleCommand("thefuldeeps_avtooborot_toggle_"..Name)
end

concommand.Add(
	"thefuldeeps_avtooborot_info",
	function(ply)
		if table.Count(ConditionsTbls) == 0 then ChatPrint(ply,"Автооборотов нет.") return end
		for name,tbl in pairs(ConditionsTbls) do
			ChatPrint(ply,name.." "..(tbl[4] and "off" or "on"))
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

local function AvtooborotThink()
	for _,tbl in pairs(ConditionsTbls) do
		if not tbl[4] and CheckOccupationTbl(tbl[2],true) and CheckOccupationTbl(tbl[3]) then
			tbl[6] = 0
			if tbl[5] then continue end--tbl[5] означает, что этот автооборот уже сработал
			tbl[5] = true
			local comms = tbl[1]
			for _,comm in pairs(comms) do
				for _,sig in pairs(NamesSignals) do
					if sig.SayHook then sig:SayHook(nil,comm) end
				end
				ChatPrintAll(comm)
			end
		else
			tbl[6] = tbl[6] + 1--возможно из-за этого будут приколы (баги)
			if tbl[6] == 2 then tbl[5] = false tbl[6] = 0 end
		end
	end
end

timer.Create("Avtooborot Think",5,0,AvtooborotThink)



TheFulDeepsAvtooborot.Add("asd",{"!sopen le3-1"},{"LE131B"},{"LE3","LE113"})