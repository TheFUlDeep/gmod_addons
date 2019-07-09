if SERVER then
	local WebServerTyp = "chat"
	local HostName
	local Map
	local NotInitialized = true
	hook.Add("PlayerInitialSpawn","Sync_Chat_Initialize",function()
		hook.Remove("PlayerInitialSpawn","Sync_Chat_Initialize")
		HostName = game.GetIPAddress()
		Map = game.GetMap()
		NotInitialized = false
	end)

	local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/sync/"
	local function SendToWebServer(tbl,url,typ)
		local TableToSend = {MainTable = util.TableToJSON(tbl), server = HostName, map = Map,typ = typ}
		http.Post(url, TableToSend)
	end
	
	local function CheckTableSize(tbl,k1)
		if tbl and table.Count(tbl) > k1 then
			local i = 0
			for k,v in pairs(tbl) do
				i = i + 1
				if i > k1 then tbl[k] = nil end
			end
		end
	end
	
	util.AddNetworkString("SyncChatNetworkString")
	local function SendChatToClients(tbl)
		if not tbl then return end
		net.Start("SyncChatNetworkString")
			local TableToSend = util.Compress(util.TableToJSON(tbl))
			local TableToSendN = #TableToSend
			net.WriteUInt(TableToSendN, 32)
			net.WriteData(TableToSend, TableToSendN)
		net.Broadcast()
	end

	local WasInChatTBL = {}
	local function GetChatTBL(GetChatTBLL)
		if not GetChatTBLL or table.Count(GetChatTBLL) == 0 then return end
		if WasInChatTBL and table.Count(WasInChatTBL) > 0 then
			for k,v in pairs(WasInChatTBL) do
				for k1,v1 in pairs(GetChatTBLL) do
					if v.msg == v1.msg and v.OsTime == v1.OsTime and v.ply == v1.ply then GetChatTBLL[k1] = nil end
				end
			end
		end
		if GetChatTBLL and table.Count(GetChatTBLL) > 0 then
			--PrintTable(GetChatTBLL)
			SendChatToClients(GetChatTBLL)
			for k,v in pairs(GetChatTBLL) do
				print((v.ply)..": "..(v.msg))
			end
			for k,v in pairs(GetChatTBLL) do
				table.insert(WasInChatTBL,1,v)
			end
		CheckTableSize(WasInChatTBL,100)
		end
	end
	
	local function GetFromWebServer(url,typ)
		if NotInitialized then return end
		http.Fetch( 
		url.."?typ="..typ,
		function (body)
			if not body or body == "" then return end
			local tbl = util.JSONToTable(body)
			if not tbl then return end
			local tbl2 = {}
			for k,v in pairs(tbl) do
				if k == HostName or (v.map and v.map ~= Map) then continue end
				if not v.MainTable then continue end
				for k1,v1 in pairs(v.MainTable) do
					v1.ply = "["..(k).."] "..(v1.ply)
					table.insert(tbl2,1,v1)
				end
			end
			GetChatTBL(tbl2)
		end
		)
	end
	
	local ChatTBL = {}
	local shetchik0 = true
	local LastChatTBL = {}
	local function SendChatTBL()
		if NotInitialized then return end
		--PrintTable(ChatTBL)
		--if not ChatTBL and LastChatTBL and util.TableToJSON(ChatTBL) == util.TableToJSON(LastChatTBL) then return end
		if not ChatTBL then 
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
	
	hook.Add("PlayerSay","SyncChatPlayerSay",function(ply,msg)
		table.insert(ChatTBL,1,{ply = ply:Nick(),msg = msg,OsTime = os.clock()})
		CheckTableSize(ChatTBL,5)
		SendChatTBL()
	end)
	
	hook.Add("PlayerDisconnected","SyncChatPlayerDisconnected",function(ply)
		table.insert(ChatTBL,1,{ply = ply:Nick(),msg = "вышел с сервера. Его SteamID: "..ply:SteamID(),OsTime = os.clock()})
		CheckTableSize(ChatTBL,5)
		SendChatTBL()
	end)
	
	hook.Add("PlayerInitialSpawn","SyncChatPlayerInitialSpawn",function(ply)
		timer.Simple(1,function()
			table.insert(ChatTBL,1,{ply = ply:Nick(),msg = "завершает загрузку.",OsTime = os.clock()})
			CheckTableSize(ChatTBL,5)
			SendChatTBL()
		end)
	end)
	
	hook.Add("PlayerConnect","SyncChatPlayerConnect",function(nick)
		table.insert(ChatTBL,1,{ply = nick,msg = "присоединяется",OsTime = os.clock()})
		CheckTableSize(ChatTBL,5)
		SendChatTBL()
	end)
	
	local interval = 1
	local lasttime = os.clock()
	hook.Remove("Think","SyncChatThink")
	function SyncChatThink()
		hook.Add("Think","SyncChatThink",function() 
			if not MetrostroiSyncEnabled then hook.Remove("Think","SyncChatThink") end
			if lasttime + interval > os.clock() then return end
			lasttime = os.clock()
			GetFromWebServer(WebServerUrl,WebServerTyp)
		end)
	end
	timer.Simple(0,function() SyncChatThink() end)
end

if CLIENT then
	net.Receive( "SyncChatNetworkString", function()
		local GetChatTBLN = net.ReadUInt(32)
		local GetChatTBL = util.JSONToTable(util.Decompress(net.ReadData(GetChatTBLN)))
		if not GetChatTBL then return end
		for k,v in pairs(GetChatTBL) do
			chat.AddText(Color(0,0,0), v.ply, Color(255,255,255), ": "..(v.msg))
		end
	end)
end