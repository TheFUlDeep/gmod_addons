if CLIENT then

	function UpdateTblByFinding(whereTbl,whatTbl)
		for k,v in pairs(whereTbl) do
			for k1,v1 in pairs(whatTbl) do
				if v.nick == v1.nick and v.msg == v1.msg then whereTbl[k] = nil end
			end
		end
		return whereTbl
	end

	function FindInTbl(where,what,key)
		for k1,v1 in pairs(where) do
			if what[key].nick == v1.nick and what[key].msg == v1.msg then return true end
		end
		return false
	end

	local WasInChat = {}
	net.Receive( "SyncedChat", function()
		local tbl = {}
		tbl = util.JSONToTable(util.Decompress(net.ReadData()))
		if not tbl then return end
		--Добавляю новые поля
		for k,v in pairs(tbl) do
			if not FindInTbl(WasInChat,tbl,k) then table.insert(WasInChat,1,{nick = v.nick,msg = v.msg,OsTime = os.time()})
		end
		--Удаляю просроченные поля
		for k,v in pairs(WasInChat) do
			if v.OsTime + interval < os.time() then 
				WasInChat[k] = nil
			end
		end
		--Удаляю то, что уже было секунду назад, но не просрочено
		tbl = UpdateTblByFinding(tbl,WasInChat)
		for k,v in pairs(tbl) do
			chat.AddText(Color(0,0,0),tbl.nick, ": ",Color(255,255,255),tbl.msg)
		end
	end)
end
if CLIENT then return end


local HostName = GetHostName()
hook.Add("PlayerSay","chat_to_discord",function(ply,text,team)
	http.Post( "https://discordapp.com/api/webhooks/514197550509850655/VdoxR99ZM2vGhrmC629rH3rYCcUtHSUtIT9_7PxauoLhRA-DnLwnpWedmqlHoQvtCrDL", {username = ply:Nick(), content = "["..HostName.."] "..text})
end)

util.AddNetworkString( "SyncedChat" )
local interval = 1
local lasttime = os.time()
local ChatTBL = {}
hook.Add("Think","SyncChat", function()
	if os.time() - lasttime < interval then return end
	lasttime = os.time()
	
	if not file.Exists("SyncChatDataRec.txt", "DATA") then
		if not ChatTBL then return end
		ChatTBL = {}
	end
	ChatTBL = util.JSONToTable(file.Read("SyncChatDataRec.txt", "DATA"))
	if not ChatTBL then return end
		net.Start( "SyncedChat" )
		--net.WriteString(ChatTBL)3
		net.WriteData(util.Compress(util.TableToJSON(ChatTBL)))
		net.Broadcast()
		--net.Send(ply)
	end
end)











--[[					 						-- код дискорд бота
local discordia = require('discordia')
local Client = discordia.Client()
local json = require "json"

local BotSettings = {
	['Token'] = "Bot NTE0Mzg3ODY0NjUwNTE0NDY3.DtV0tg.XVat0wATqf5NxSLo2dQ8ewgsoX0";
	['Prefix'] = ";";
}

local function stringfind(where,what,lowerr,startpos,endpos)
	local Exeption = false
	if not where or not what then print("[STRINGFIND EXEPTION] cant find required arguments") return false end
	if type(where) ~= "string" or type(what) ~= "string" then print("[STRINGFIND EXEPTION] not string") return false
	elseif string.len(what) > string.len(where) then print("[STRINGFIND EXEPTION] string what you want to find bigger than string where you want to find it") Exeption = true 
	end
	if lowerr then 
		where = bigrustosmall(where)
		what = bigrustosmall(what)
	end
	local strlen1 = string.len(where)
	local strlen2 = string.len(what)
	if not startpos then startpos = 1 end
	if startpos < 1 then print("[STRINGFIND EXEPTION] start position smaller then 1") Exeption = true end
	if not endpos then endpos = strlen1	end
	if endpos > strlen1 then print("[STRINGFIND EXEPTION] end position bigger then source string (source string size = "..#where..")") Exeption = true end
	if endpos < startpos then print("[STRINGFIND EXEPTION] end position smaller then start position") Exeption = true end
	if startpos > strlen1 - strlen2 + 1 then print("[STRINGFIND EXEPTION] string from your start position smaller then string what you want to find") Exeption = true end
	if endpos - startpos + 1 < strlen2 then print("[STRINGFIND EXEPTION] section for finding smaller than string what you want to find") Exeption = true end
	if Exeption then return false end
	for i = startpos, endpos do
		if i + strlen2 - 1 > endpos then return false
		elseif string.sub(where, i, i + strlen2 - 1) == what then return i
		end
	end
	return false
end

local function filewrite(filename, filetext,path)
--local file = io.open("T:\\Downloads\\discond_bot\\"..filename..".txt", "w" )
local file = io.open(path..filename..".txt", "w" )
file:write(filetext)
file:close()
end

local lasttime = os.time
local interval = 1
local SendTBL = {}
local function CheckSendTBL()
	if not SendTBL then return end
	for k,v in pairs(SendTBL) do
		if v.OsTime + interval < os.time() then 
			SendTBL[k] = nil
		end
	end
end
Client:on('messageCreate', function(message)
	--if message.author.name:find('TheFulDeep') then return end
		--message.channel:send(message.author.mentionString..' пидорас ')
	if message.channel.id == "485508569073188874" then
		CheckSendTBL()
		table.insert(CheckSendTBL,1,{msg = string.sub(message.content,stringfind(message.content,"]") + 2),nick = message.author.name,OsTime = os.time(),server = string.sub(message.content, 1,stringfind(message.content,"]"))})
	end
	if os.time() - lasttime < interval then return end
	lasttime = os.time()
	if not SendTBL then return end
	local SendToFirst = {}
	local SendToSecond = {}
	for k,v in pairsSendTBL) do
		if stringfind(v.server,"1") then
			table.insert(SendToFirst,1,{msg = v.msg,nick = v.nick})
		elseif stringfind(v.server,"2")
			table.insert(SendToSecond,1,{msg = v.msg,nick = v.nick})
		end
	end
	SendToFirst = json.encode(SendToFirst)
	SendToSecond = json.encode(SendToSecond)
	filwrite("SyncChatDataRec.txt",SendToFirst,"C:\\gms_norank_obnova\\garrysmod\\data\\")
	filwrite("SyncChatDataRec.txt",SendToSecond,"C:\\gms_norank_obnova2\\garrysmod\\data\\")
	
      --[[if not message.author.name:find("[norank1]") then
        filewrite("SyncChatDataRec",message.author.name..":::"..message.content,"C:\\gms_norank_obnova\\garrysmod\\data\\")
		print("sended "..message.content.." to norank1")
      end
      if not message.author.name:find("[norank2]") then
        filewrite("SyncChatDataRec",message.author.name..":::"..message.content,"C:\\gms_norank_obnova2\\garrysmod\\data\\")
		print("sended "..message.content.." to norank2")
      end]]
end)

Client:run(BotSettings.Token)]]