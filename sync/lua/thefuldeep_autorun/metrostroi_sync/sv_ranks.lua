--if CLIENT then return end
local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/sync/ranks/"
if SERVER then
	local api = file.Read("steamapikey.txt") or "0"
	
	local FamilySteamIDs = {}--тут будутхраниться айди, если игрок зашел с семейного доступа

	local function SendRankToWebServer(url,SteamID,Nick,Rank)
		if not url or not SteamID or not Rank then return end
		if not Nick then Nick = "Unknown" end
		http.Post(url, {SteamID = SteamID, Nick = Nick, Rank = Rank})
	end

	local function GetRankFromWebServer(url,SteamID)
		http.Fetch( 
			url.."?SteamID="..SteamID,
			function (body)
				local ply = player.GetBySteamID(SteamID)
				if body and body ~= "" then
					body = util.JSONToTable(body)
					if body and body.Rank then
						if not IsValid(player.GetBySteamID(SteamID)) then return end						
						local Rank = ply:GetUserGroup()
						if Rank ~= body.Rank then
							if body.Rank == "user" then 
								RunConsoleCommand("ulx","removeuserid",SteamID,body.Rank)
							else
								RunConsoleCommand("ulx","adduserid",SteamID,body.Rank)
							end
						end
					end
				end
				timer.Simple(0.1, function()
					if not IsValid(ply) then return end
					SendRankToWebServer(WebServerUrl,ply:SteamID(),ply:Nick(),ply:GetUserGroup())
					--print("Saving rank "..ply:GetUserGroup().." to "..ply:Nick())
				end)
			end
		)
	end

	local function CheckUserRank(ply)
		if not IsValid(ply) then return end
		GetRankFromWebServer(WebServerUrl,ply:SteamID())
	end

	local function CheckRanks()
		local i = 0
		for k,v in pairs(player.GetAll()) do
			timer.Simple(i,function() 
				if not IsValid(v) then return end
				CheckUserRank(v)
			end)
			i = i + 1
		end
	end
	timer.Create("CheckingRanks",60,0,function() CheckRanks() end)

	gameevent.Listen("player_changename")
	hook.Add( "player_changename", "SendChangedNickToWebServer", function( data )
		GetRankFromWebServer(WebServerUrl,Player(data.userid):SteamID())
	end)


	local function CheckIfBanned(SteamID,parent)
		http.Fetch(
			WebServerUrl.."bans/?SteamID="..SteamID,
			function(body)
				if not body then return end
				body = util.JSONToTable(body)
				if not body or not body.Nick then return end
				local BanDate = os.date("%H:%M:%S %d/%m/%Y",body.BanDate)
				local UnBanDate = "никогда"
				local BanTime = ""
				if body.UnBanDate ~= "perma" then 
					UnBanDate = os.date("%H:%M:%S %d/%m/%Y",body.UnBanDate)
					BanTime = "\nДо разбана осталось "..tostring(math.floor((body.UnBanDate - os.time()) / 60)).." мин."
				end
				game.KickID(SteamID,"ВЫ ЗАБАНЕНЫ\nЗабанил "..(body.WhoBanned)..", его SteamID: "..(body.WhoBannedID).."\nПричина: "..(body.Reason).."\nДата бана: "..BanDate.."\nДата разбана: "..UnBanDate..BanTime)
				--[[if BansTBL[SteamID].Nick == "Unknown" then				--вообще можно еще сделать проверку и обновление ника, но мне лень
					
				end]]
			end
		)
		if not parent and FamilySteamIDs[SteamID] then CheckIfBanned(FamilySteamIDs[SteamID],true) end
	end
	
	local BansTBL = {}
	
	local function GetBansFromWebServer()
		http.Fetch(WebServerUrl.."bans/",
			function(body)
				local tbl = util.JSONToTable(body)
				if not tbl then return end
				BansTBL = tbl
			end
		)
	end
	
	GetBansFromWebServer()
	timer.Create("UpdateBansTBL",30,0,GetBansFromWebServer)
	

	local function CheckIfLocalBanned(SteamID,parent)
		if table.Count(BansTBL) < 1 then return end
		for _k,_v in pairs(BansTBL) do
			for k,v in pairs(_v) do
				if k == SteamID and not v.Unbanned and (v.UnBanDate == "perma" or os.time() < v.UnBanDate) then
					local BanDate = os.date("%H:%M:%S %d/%m/%Y",v.BanDate)
					local UnBanDate = "никогда"
					local BanTime = ""
					if v.UnBanDate ~= "perma" then 
						UnBanDate = os.date("%H:%M:%S %d/%m/%Y",v.UnBanDate)
						BanTime = "\nДо разбана осталось "..tostring(math.floor((v.UnBanDate - os.time()) / 60)).." мин."
					end
					return "ВЫ ЗАБАНЕНЫ\nЗабанил "..(v.WhoBanned)..", его SteamID: "..(v.WhoBannedID).."\nПричина: "..(v.Reason).."\nДата бана: "..BanDate.."\nДата разбана: "..UnBanDate..BanTime
				end
			end
		end
		if not parent and FamilySteamIDs[SteamID] then return CheckIfLocalBanned(FamilySteamIDs[SteamID],true) end
	end
	
	local function asd2(SteamID)--вынес это в отдельную функцию, так как код повторяется. Не знаю, как ее назвать
		--TODO если имя изменилось, то запостить его в базу рангов. Каждые 30 секунд пуолчать таблица рангов, чтобы не обращаться к серверу каждый раз при заходе игрока. После поста нового ника принудительно получить всю таблицу рангов
		local Banned = CheckIfLocalBanned(SteamID)
		if Banned then game.KickID(SteamID,Banned) return end
		CheckIfBanned(SteamID)
	end
	
	hook.Add("PlayerInitialSpawn","CheckIfBannedInitialSpawn",function(ply)
		timer.Simple(1,function()
			if not IsValid(ply) then return end
			CheckUserRank(ply)
			asd2(ply:SteamID())		-- в этом хуке просто на всякий случай
		end)
	end)


	hook.Add( "CheckPassword", "SyncBanCheck", function(steamID64,ipAddress,svPassword,clPassword,name)
		--привходе игрока узнаю, зашел ли он с семейного доступа и сохраняю в таблицу
		local SteamID = util.SteamIDFrom64(steamID64)
		if FamilySteamIDs[SteamID] == nil then --если этот игрок еще не заходил, то сохранить его в локальные проверки на семейный доступ
			http.Fetch("https://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/".."?key="..api.."&steamid="..steamID64.."&appid_playing=4000",
			function(body)
				body = body and util.JSONToTable(body)
				local parentsteamid = body and body.response and body.response.lender_steamid
				if parentsteamid and parentsteamid ~= 0 and parentsteamid ~= "0" and util.SteamIDFrom64(parentsteamid) ~= "STEAM_0:0:0" then
					FamilySteamIDs[SteamID] = util.SteamIDFrom64(parentsteamid)
					print(SteamID.." зашел через семейный доступ. Родитель "..FamilySteamIDs[SteamID])
				else
					FamilySteamIDs[SteamID] = false
				end
				asd2(SteamID)
			end)
		else
			if FamilySteamIDs[SteamID] then print(SteamID.." зашел через семейный доступ. Родитель "..FamilySteamIDs[SteamID]) end
			asd2(SteamID)
		end
	end)
	
	local function CheckingIfBanned()
		local i = 0
		for k,v in pairs(player.GetAll()) do
			timer.Simple(i,function() 
				if not IsValid(v) then return end
				CheckIfBanned(v:SteamID())
			end)
			i = i + 1
		end
	end
	timer.Create("CheckingBan",60,0,function() CheckingIfBanned() end)
		
		--SendRankToWebServer(WebServerUrl,"SteamID","Nick","user1")
		--ulx.adduserid(nil,"STEAM_0:1:37134658","superadmin")
		
		--PrintTable(ULib.ucl.groups)
	--local function OverWriteUlxCommands()
	--PrintTable(CheckIfBanned("STEAM_0:1:37134658"))
	
end

local function OverWriteUlxCommands()
	local CATEGORY_NAME = "Utility"	
	
	local function SendRankToWebServer(url,SteamID,Nick,Rank)
		if not url or not SteamID or not Rank then return end
		if not Nick then Nick = "Unknown" end
		http.Post(url, {SteamID = SteamID, Nick = Nick, Rank = Rank})
	end
	
	local function SetRank(SteamID, rank)
		--если игрока на сервере нет, то ищем ник по базе и отправляем уже с этим ником
		if not rank then rank = "user" end
		if IsValid(player.GetBySteamID(SteamID)) then
			local target_ply = player.GetBySteamID(SteamID)
			SendRankToWebServer(WebServerUrl,target_ply:SteamID(),target_ply:Nick(),rank)
			return
		end
		http.Fetch(
			WebServerUrl.."?SteamID="..SteamID,
			function(body)
				if not body then SendRankToWebServer(WebServerUrl,SteamID,"Unknown",rank) return end
				body = util.JSONToTable(body)
				if body and body.Nick and body.Nick ~= "" and body.Nick ~= "Unknown" then
					SendRankToWebServer(WebServerUrl,SteamID,body.Nick,rank)
				else 
					SendRankToWebServer(WebServerUrl,SteamID,"Unknown",rank)
				end
			end
		)
	end
	
	local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/sync/ranks/"
	local function SetBan(SteamID,Nick,WhoBannedSteamID,WhoBanned,reason,duration)
		if not SteamID then ULib.tsayError(ply,"No SteamID") return end
		duration = tostring(duration)
		if FamilySteamIDs[SteamID] then
			reason = reason.." Child SteamID="..SteamID
			SteamID = FamilySteamIDs[SteamID]
		end
		--if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid SteamID", true ) return end
		if not WhoBannedSteamID then WhoBannedSteamID = "Console" end
		if not WhoBanned then WhoBanned = "Console" end
		if not Nick then Nick = "Unknown" end
		if IsValid(player.GetBySteamID(SteamID)) then Nick = player.GetBySteamID(SteamID):Nick() end
		--TODO если ник доступен, запостить его в базу рангов для обновления его ника там.
		http.Post(
			WebServerUrl.."bans/",
			{SteamID = SteamID,Nick = Nick,WhoBanned = WhoBanned, WhoBannedID = WhoBannedSteamID,Reason = reason,Duration = duration},
			function()
				local ply = player.GetBySteamID(SteamID)
				if IsValid(ply) then ply:Kick("ВЫ ЗАБАНЕНЫ\nЗабанил "..WhoBanned.." его SteamID: "..WhoBannedSteamID.."\nПричина: "..reason.."\nДлительность: "..duration.." мин.") end
				local calling_ply = WhoBannedSteamID
				local target_ply = SteamID.." ("..Nick..")"
				if ULib.isValidSteamID(WhoBannedSteamID) and IsValid(player.GetBySteamID(WhoBannedSteamID)) then calling_ply = WhoBannedSteamID.." ("..(player.GetBySteamID(WhoBannedSteamID):Nick())..")" end
				ulx.fancyLog(false,"#s забанил игрока #s на #s мин.",calling_ply,target_ply,duration) 
				ulx.fancyLog(false,"Причина #s",reason) 
				--[[timer.Simple(1,function()
					GetBansFromWebServer()		-- оно не видит эту функцию
				end)]]
			end
		)
	end
	
	function ulx.ban(calling_ply,target_ply,minutes,reason)
		if not minutes or minutes == 0 or minutes == "" then minutes = "perma" end
		if not reason or reason == "" then reason = "не указана" end
		local WhoBanned
		local WhoBannedSteamID
		if not IsValid(calling_ply) then
			WhoBanned = "Console" 
			WhoBannedSteamID = "Console" 
		else
			WhoBanned = calling_ply:Nick()
			WhoBannedSteamID = calling_ply:SteamID()
		end
		SetBan(target_ply:SteamID(),target_ply:Nick(),WhoBannedSteamID,WhoBanned,reason,minutes)
		--ulx.fancyLogAdmin(calling_ply,"#A забанил игрока #T на #i мин.. Причина #s",target_ply,minutes,reason)
	end
	local ban = ulx.command( CATEGORY_NAME, "ulx ban", ulx.ban, "!ban", false, false, true )
	ban:addParam{ type=ULib.cmds.PlayerArg }
	ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	ban:addParam{ type=ULib.cmds.StringArg, hint="причина", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	ban:defaultAccess( ULib.ACCESS_ADMIN )
	ban:help( "Bans target." )
	
	function ulx.banid( calling_ply, steamid, minutes, reason )
		if not minutes or minutes == 0 or minutes == "" then minutes = "perma" end
		if not ULib.isValidSteamID(steamid) then ULib.tsayError(calling_ply,"Invalid SteamID") return end
		if not reason then reason = "reason" end
		if not IsValid(calling_ply) or not calling_ply:SteamID() then WhoBanned = "Console" WhoBannedSteamID = "Console" else WhoBanned = calling_ply:Nick() WhoBannedSteamID = calling_ply:SteamID() end
		local ply = player.GetBySteamID(steamid)
		local Nick = "Unknown"
		if IsValid(ply) then 
			Nick = ply:Nick()
			SetBan(steamid,Nick,WhoBannedSteamID,WhoBanned,reason,minutes)
		else
			http.Fetch(
				WebServerUrl.."?SteamID="..steamid,
				function(body)
					if not body then SetBan(steamid,Nick,WhoBannedSteamID,WhoBanned,reason,minutes) return end
					body = util.JSONToTable(body)
					if body and body.Nick and body.Nick ~= "" and body.Nick ~= "Unknown" then
						SetBan(steamid,body.Nick,WhoBannedSteamID,WhoBanned,reason,minutes)
					else 
						SetBan(steamid,Nick,WhoBannedSteamID,WhoBanned,reason,minutes)
					end
				end
			)
		end
	end
	local banid = ulx.command( CATEGORY_NAME, "ulx banid", ulx.banid, nil, false, false, true )
	banid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
	banid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	banid:addParam{ type=ULib.cmds.StringArg, hint="причина", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	banid:defaultAccess( ULib.ACCESS_SUPERADMIN )
	banid:help( "Bans steamid." )
	
	function ulx.unban(calling_ply,steamid)
		if not ULib.isValidSteamID( steamid ) then ULib.tsayError( calling_ply, "Invalid SteamID." ) return end
		http.Post(WebServerUrl.."bans/", {SteamID = steamid, Unbanned = "unbanned"})
	end
	local unban = ulx.command( CATEGORY_NAME, "ulx unban", ulx.unban, nil, false, false, true )
	unban:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
	unban:defaultAccess( ULib.ACCESS_ADMIN )
	unban:help( "Unbans steamid." )
		--local OLDulxadduser = ulx.adduser
	function ulx.adduser(calling_ply, target_ply, group_name)
		if not ULib.ucl.groups[ group_name ] then return error( "Group does not exist (" .. group_name .. ")", 2 ) end
		--OLDulxadduser(calling_ply, target_ply, group_name)
		ULib.ucl.addUser(target_ply:SteamID(),nil,nil,group_name)
		ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #T ранг #s",target_ply,group_name)
		SendRankToWebServer(WebServerUrl,target_ply:SteamID(),target_ply:Nick(),group_name)
	end
	
	--local OLDulxremoveuser = ulx.removeuser
	function ulx.removeuser(calling_ply, target_ply)
		--OLDulxremoveuser(calling_ply, target_ply)
		ULib.ucl.addUser(target_ply:SteamID(),nil,nil,"admin")		-- это пранк, не обращай внимания
		ULib.ucl.removeUser( target_ply:SteamID() )
		ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #T ранг #s",target_ply,"user")
		SendRankToWebServer(WebServerUrl,target_ply:SteamID(),target_ply:Nick(),"user")
	end
	
	--local OLDulxadduserid = ulx.adduser
	function ulx.adduserid(calling_ply, id, group_name)
		if not ULib.ucl.groups[ group_name ] then return error( "Group does not exist (" .. group_name .. ")", 2 ) end
		if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid SteamID", true ) return end
		ULib.ucl.addUser(id,nil,nil,group_name)
		--OLDulxadduserid(calling_ply, id, group_name)
		if IsValid(player.GetBySteamID(id)) then
			ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #T ранг #s",player.GetBySteamID(id),group_name)
		else
			ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #s ранг #s",id,group_name)
		end
		SetRank(id,group_name)
	end
	
	--local OLDulxremoveuserid = ulx.removeuserid
	function ulx.removeuserid(calling_ply, id)
		if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid SteamID", true ) return end
		ULib.ucl.addUser(id,nil,nil,"admin")		-- это пранк, не обращай внимания
		ULib.ucl.removeUser( id )
		--OLDulxremoveuserid(calling_ply, id)
		if IsValid(player.GetBySteamID(id)) then
			ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #T ранг #s",player.GetBySteamID(id),"user")
		else
			ulx.fancyLogAdmin(calling_ply,false, "#A установил игроку #s ранг #s",id,"user")
		end
		SetRank(id,"user")
	end
	
	--TODO ulx.checkban
	
	local adduser = ulx.command( CATEGORY_NAME, "ulx adduser", ulx.adduser, nil, false, false, true )
	adduser:addParam{ type=ULib.cmds.PlayerArg }
	adduser:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	adduser:defaultAccess( ULib.ACCESS_SUPERADMIN )
	adduser:help( "Add a user to specified group." )
	local adduserid = ulx.command( CATEGORY_NAME, "ulx adduserid", ulx.adduserid, nil, false, false, true )
	adduserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
	adduserid:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	adduserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
	adduserid:help( "Add a user by ID to specified group." )
	local removeuser = ulx.command( CATEGORY_NAME, "ulx removeuser", ulx.removeuser, nil, false, false, true )
	removeuser:addParam{ type=ULib.cmds.PlayerArg }
	removeuser:defaultAccess( ULib.ACCESS_SUPERADMIN )
	removeuser:help( "Permanently removes a user's access." )
	local removeuserid = ulx.command( CATEGORY_NAME, "ulx removeuserid", ulx.removeuserid, nil, false, false, true )
	removeuserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
	removeuserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
	removeuserid:help( "Permanently removes a user's access by ID." )
		
end

local function CheckULX()
	if not ulx or not ulx.ban then timer.Simple(5,function() CheckULX() end)
	else OverWriteUlxCommands()
	end
end
CheckULX()
