if SERVER then retuen end
if CLIENT then return end

if SERVER then
	local WebServerTyp = "chat"
	local HostName = GetHostName()
	local Map = game.GetMap()
	local WebServerUrl = "http://metronorank.ddns.net/sync/"
	local function SendToWebServer(tbl,url,typ)
		local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName, map = Map,typ = typ}
		http.Post(url, TableToSend)
	end

	local outputTBL = {}
	local function GetFromWebServer(url,typ)
		http.Fetch( 
		url.."?typ="..typ,
		function (body)
			outputTBL[typ] = {}
			if body then
				outputTBL[typ] = util.JSONToTable(body)
			end
		end,
		function()
			outputTBL[typ] = {}
		end
		)
		local tbl2 = {}
		if not outputTBL[typ] or not istable(outputTBL[typ]) then return {} end
		for k,v in pairs(outputTBL[typ]) do
			if k == HostName or (v.map and v.map ~= Map) then continue end
			if not v.MainTable then continue end
			for k1,v1 in pairs(v.MainTable) do
				table.insert(tbl2,1,v1)
			end
		end
		return tbl2
	end
	
	local function CheckTableSize(tbl)
		if tbl and #tbl > 10 then
			local i
			for i = 11, #tbl do
				tbl[i] = nil
			end
		end
	end
	
	local ChatTBL = {}
	hook.Add("PlayerSay","SyncChatPlayerSay",function(ply,msg)
		table.insert(ChatTBL,1,{ply = ply:Nick(),msg = msg,OsTime = os.clock()})
		CheckTableSize(ChatTBL)
	end)
	
	local shetchik0 = true
	local LastChatTBL = {}
	local function SendChatTBL()
		if ChatTBL and LastChatTBL and ChatTBL == LastChatTBL then return end
		if not ChatTBL or #ChatTBL == 0 then 
			if shetchik0 then
				SendToWebServer(ChatTBL,WebServerUrl,WebServerTyp)
				LastChatTBL = ChatTBL
				shetchik0 = false
			else 
				return 
			end
		else
			if not shetchik0 then shetchik0 = true end
			SendToWebServer(ChatTBL,WebServerUrl,WebServerTyp)
			LastChatTBL = ChatTBL
		end
	end
	
	util.AddNetworkString("SyncChatNetworkString")
	local function SendChatToClients(tbl)
		if not tbl or #tbl == 0 then return end
		net.Start("SyncChatNetworkString")
			local TableToSend = util.Compress(util.TableToJSON(tbl))
			local TableToSendN = #TableToSend
			net.WriteUInt(TableToSendN, 32)
			net.WriteData(TableToSend, TableToSendN)
		net.Broadcast()
	end
	
	local WasInChatTBL = {}
	local function GetChatTBL()
		local GetChatTBL = {}
		GetChatTBL = GetFromWebServer(WebServerUrl,WebServerTyp)
		if not GetChatTBL or #GetChatTBL == 0 then return end
		if WasInChatTBL and #WasInChatTBL > 0 then
			local i
			local j
			for i = 1, #WasInChatTBL do
				for j = 1, #GetChatTBL do
					if WasInChatTBL[i].msg == GetChatTBL[j].msg and WasInChatTBL[i].OsTime == GetChatTBL[j].OsTime and WasInChatTBL[i].ply == GetChatTBL[j].ply then
						GetChatTBL[j] = nil
					end
				end
			end
		end
		if GetChatTBL and #GetChatTBL > 0 then
			SendChatToClients(GetChatTBL)
			local i
			for i = 1, #GetChatTBL do
				table.insert(WasInChatTBL,1,GetChatTBL[i])
			end
		CheckTableSize(WasInChatTBL)
		end
	end
	
	local interval = 0.5
	local lasttime = os.clock()
	hook.Add("Think","SyncChatThink", function()
		if os.clock() - lasttime < interval then return end
		lasttime = os.clock()
		
		SendChatTBL()
		GetChatTBL()
	end)
end

if CLIENT then
	net.Receive( "SyncChatNetworkString", function()
		local GetChatTBLN = net.ReadUInt(32)
		local GetChatTBL = util.JSONToTable(util.Decompress(net.ReadData(GetChatTBLN)))
		if not GetChatTBL then return end
		local i
		for i = 1, #GetChatTBL do
			chat.AddText(Color(0,0,0), GetChatTBL[i].nick, Color(255,255,255), ": "..(GetChatTBL[i].msg))
		end
	end
end