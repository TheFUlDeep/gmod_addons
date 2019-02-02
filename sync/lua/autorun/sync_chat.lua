local function SravnenieForTbl(tbl1,tbl2)
	if not tbl1 or not tbl2 then return false end
	local ravno = false
	local maxx
	local minn
	if #tbl1 < #tbl2 then 
		minn = tbl1 maxx = tbl2 
	else 
		minn = tbl2 maxx = tbl1
	end
	for k,v in pairs(maxx) do
		ravno = false
		for k1,v1 in pairs(minn) do
			if not ravno and table.ToString(v) == table.ToString(v1) then ravno = true end
		end
	end
	if ravno then return true else return false end
end

if CLIENT then

	local function ClearWasInChat(tbl)
		if not tbl then return end
		local i
		if #tbl > 10 then
			for i = 11, #tbl do
				tbl[i] = nil
			end
		end
	end

	local RecChatTBL = {}
	local WasInChat = {}
	net.Receive( "SyncedChat", function()
		local NewTable = util.JSONToTable(util.Decompress(net.ReadData(GetGlobalInt("SyncChat"))))
		if SravnenieForTbl(NewTable, RecChatTBL) then return end
		RecChatTBL = NewTable
		if not RecChatTBL then return end
		for k,v in pairs(WasInChat) do
			for k1,v1 in pairs(RecChatTBL) do
				if v1.nick == v.nick and v.msg == v1.msg and v.OsTime == v1.OsTime then RecChatTBL[k1] = nil end
			end
		end
		--PrintTable(RecChatTBL)
		for k,v in pairs(RecChatTBL) do 
			chat.AddText(Color(0,0,0), v.nick, Color(255,255,255), ": "..(v.msg))
			table.insert(WasInChat,1,RecChatTBL[k])
		end
		ClearWasInChat(WasInChat)
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
		ChatTBL = {}
		return
	end
	if SravnenieForTbl(util.JSONToTable(file.Read("SyncChatDataRec.txt", "DATA")), ChatTBL) then return end
	ChatTBL = util.JSONToTable(file.Read("SyncChatDataRec.txt", "DATA"))
	if not ChatTBL then return end
		net.Start( "SyncedChat" )
		--net.WriteString(ChatTBL)3
		SetGlobalInt("SyncChat", string.len(util.TableToJSON(ChatTBL)))
		net.WriteData(util.Compress(util.TableToJSON(ChatTBL)),GetGlobalInt("SyncChat"))
		net.Broadcast()
		--net.Send(ply)
end)





-- код дискорд бота


--[[
local discordia = require('discordia')
local Client = discordia.Client()
local json = require ("json")

local BotSettings = {
	['Token'] = "Bot ";
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

local SendTBL = {}
local function CheckSendTBL(tbl)
	if not tbl then return end
	local i
	if #tbl > 10 then 
		for i = 11, #tbl do
			tbl[i] = nil
		end
	end
end
Client:on('messageCreate', function(message)
	--if message.author.name:find('TheFulDeep') then return end
		--message.channel:send(message.author.mentionString..' пидорас ')
		--print(message.author.mentionString)
		local server
		local nick
		local msg
		--print(message.content)
	if message.channel.id == "485508569073188874" then
		CheckSendTBL(SendTBL)
		if message.author.mentionString ~= "<@514197550509850655>" then 
			server = "Discord"
			msg = (message.content)
			nick = "["..server.."] "..(message.author.name)
		else
			server = string.sub(message.content, 1,stringfind(message.content,"]"))
			msg = (string.sub(message.content,stringfind(message.content,"]") + 2))
			nick = server.." "..(message.author.name)
			--print("asdasd")
		end
		table.insert(SendTBL,1,{msg = msg,nick = nick,server = server,OsTime = os.time()})
	end
	if not SendTBL then return end
	local SendToFirst = {}
	local SendToSecond = {}
	for k,v in pairs (SendTBL) do
		if stringfind(v.server,"1") then
			table.insert(SendToSecond,1,{msg = v.msg,nick = v.nick, OsTime = v.OsTime})
		elseif stringfind(v.server,"2") then
			table.insert(SendToFirst,1,{msg = v.msg,nick = v.nick, OsTime = v.OsTime})
		else
			table.insert(SendToSecond,1,{msg = v.msg,nick = v.nick, OsTime = v.OsTime})
			table.insert(SendToFirst,1,{msg = v.msg,nick = v.nick, OsTime = v.OsTime})
		end
	end
	SendToFirst = json.encode(SendToFirst)
	SendToSecond = json.encode(SendToSecond)
	filewrite("SyncChatDataRec",SendToFirst,"C:\\gms_norank_obnova\\garrysmod\\data\\")
	filewrite("SyncChatDataRec",SendToSecond,"C:\\gms_norank_obnova2\\garrysmod\\data\\")
	
end)

Client:run(BotSettings.Token)
]]