--if CLIENT then return end
if SERVER then
	local WebServerUrl = "http://metronorank.ddns.net/sync/ranks/"
	local function SendRankToWebServer(url,SteamID,Nick,Rank)
		if not url or not SteamID or not Rank then return end
		if not Nick then Nick = "Unknown" end
		http.Post(url, {SteamID = SteamID, Nick = Nick, Rank = Rank})
	end

	local function GetRankFromWebServer(url,SteamID)
		http.Fetch( 
			url.."?SteamID="..SteamID,
			function (body)
				if not body or body == "" then return end
				body = util.JSONToTable(body)
				if not body.Rank then return end
				--print(body)
				if not IsValid(player.GetBySteamID(SteamID)) then return end
				local ply = player.GetBySteamID(SteamID)
				local Rank = ply:GetUserGroup()
				if Rank == body.Rank then return end
				if body.Rank == "user" then 
					RunConsoleCommand("ulx","removeuserid",SteamID,body.Rank)
				else
					RunConsoleCommand("ulx","adduserid",SteamID,body.Rank)
				end
				--print("Setting rank "..body.." to "..ply:Nick())
			end
		)
	end

	local function CheckUserRank(ply)
		if not IsValid(ply) then return end
		GetRankFromWebServer(WebServerUrl,ply:SteamID(),ply)
	end

	hook.Add("PlayerInitialSpawn","SyncRanksInitialSpawn1",function(ply)
		timer.Simple(1,function()
			CheckUserRank(ply)
		end)
	end)

	hook.Add("PlayerInitialSpawn","SyncRanksInitialSpawn2",function(ply)
		timer.Simple(2,function()
			if not IsValid(ply) then return end
			SendRankToWebServer(WebServerUrl,ply:SteamID(),ply:Nick(),ply:GetUserGroup())
			print("Saving rank "..ply:GetUserGroup().." to "..ply:Nick())
		end)
	end)


	local function CheckRanks()
		--print("Checking Ranks")
		local i = 0
		for k,v in pairs(player.GetAll()) do
			timer.Simple(i,function() 
				if not IsValid(v) then return end
				CheckUserRank(v)
			end)
			i = i + 1
		end
		timer.Simple(60,function() CheckRanks() end)
	end
	CheckRanks()



	local function CheckIfBanned(SteamID)
		http.Fetch(
			WebServerUrl.."bans/?SteamID="..SteamID,
			function(body)
				if not body then return end
				body = util.JSONToTable(body)
				if not body or not body.Nick then return end
				local BanDate = os.date("%H:%M:%S %d/%m/%Y",body.BanDate)
				local UnBanDate = "никогда"
				if body.UnBanDate ~= "perma" then UnBanDate = os.date("%H:%M:%S %d/%m/%Y",body.UnBanDate) end
				game.KickID(SteamID,"ВЫ ЗАБАНЕНЫ\nЗабанил "..(body.WhoBanned).." его SteamID: "..(body.WhoBannedID).."\nПричина: "..(body.Reason).."\nДата бана: "..BanDate.."\nДата разбана: "..UnBanDate)
				--[[if BansTBL[SteamID].Nick == "Unknown" then				--вообще можно еще сделать проверку и обновление ника, но мне лень
					
				end]]
			end,
			function(errorr)
				BansTBL[SteamID] = {}
			end
		)
	end

	hook.Add( "CheckPassword", "SyncBanCheck", function(steamID64,ipAddress,svPassword,clPassword,name)
		local SteamID = util.SteamIDFrom64(steamID64)
		CheckIfBanned(SteamID)
	end)
	
	local function CheckingIfBanned()
		--print("Checking Ranks")
		local i = 0
		for k,v in pairs(player.GetAll()) do
			timer.Simple(i,function() 
				if not IsValid(v) then return end
				CheckIfBanned(v:SteamID())
			end)
			i = i + 1
		end
		timer.Simple(60,function() CheckingIfBanned() end)
	end
	CheckingIfBanned()
		
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
	
	local WebServerUrl = "http://metronorank.ddns.net/sync/ranks/"
	local function SetBan(SteamID,Nick,WhoBannedSteamID,WhoBanned,reason,duration)
		if not SteamID then ULib.tsayError(ply,"No SteamID") return end
		duration = tostring(duration)
		--if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid SteamID", true ) return end
		if not WhoBannedSteamID then WhoBannedSteamID = "Console" end
		if not WhoBanned then WhoBanned = "Console" end
		if not Nick then Nick = "Unknown" end
		if IsValid(player.GetBySteamID(SteamID)) then Nick = player.GetBySteamID(SteamID):Nick() end
		http.Post(WebServerUrl.."bans/", {SteamID = SteamID,Nick = Nick,WhoBanned = WhoBanned, WhoBannedID = WhoBannedSteamID,Reason = reason,Duration = duration})
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
		if IsValid(target_ply) then target_ply:Kick("ВЫ ЗАБАНЕНЫ\nЗабанил "..WhoBanned..", его SteamID: "..WhoBannedSteamID.."\nПричина: "..reason.."\nДлительность: "..minutes.." мин.") end
		ulx.fancyLogAdmin(calling_ply,"#A забанил игрока #T на #i мин.. Причина #s",target_ply,minutes,reason)
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
		local ply
		local Nick = "Unknown"
		if IsValid(player.GetBySteamID(steamid)) then 
			ply = player.GetBySteamID(steamid)
			Nick = ply:Nick()
			ply:Kick("ВЫ ЗАБАНЕНЫ\nЗабанил "..WhoBanned.." его SteamID: "..WhoBannedSteamID.."\nПричина: "..reason.."\nДлительность: "..minutes.." мин.")
		end
		SetBan(steamid,Nick,WhoBannedSteamID,WhoBanned,reason,minutes)
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
