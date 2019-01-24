timer.Simple(6, function()
	--[[============================= Новая функция adduser для мгновенного сохранения ранга ==========================]]
	function ulx.adduser( calling_ply, target_ply, group_name )
		local userInfo = ULib.ucl.authed[ target_ply:UniqueID() ]

		local id = ULib.ucl.getUserRegisteredID( target_ply )
		if not id then id = target_ply:SteamID() end

		ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, group_name )
		
		MSync.SaveRank(target_ply:SteamID64(), group_name)

		ulx.fancyLogAdmin( calling_ply, "#A added #T to group #s", target_ply, group_name )
	end
	local adduser = ulx.command( "User Management", "ulx adduser", ulx.adduser, nil, false, false, true )
	adduser:addParam{ type=ULib.cmds.PlayerArg }
	adduser:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	adduser:defaultAccess( ULib.ACCESS_SUPERADMIN )
	adduser:help( "Add a user to specified group." )

	function ulx.adduserid( calling_ply, id, group_name )
		id = id:upper() -- Steam id needs to be upper
	--[[if IsValid(calling_ply) then
		-- Check for valid and properly formatted ID
		if not checkForValidId( calling_ply, id ) then return false end
	end]]
		-- Now add the fool!
		if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid StemID", true ) return end
		
		ULib.ucl.addUser( id, allows, denies, group_name )

		if ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name then
			ulx.fancyLogAdmin( calling_ply, "#A added #s to group #s", ULib.ucl.users[ id ].name, group_name )
		else
			ulx.fancyLogAdmin( calling_ply, "#A added userid #s to group #s", id, group_name )
		end
		MSync.SaveRank(util.SteamIDTo64( id ), group_name)
	end
	local adduserid = ulx.command( "User Management", "ulx adduserid", ulx.adduserid, nil, false, false, true )
	adduserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
	adduserid:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
	adduserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
	adduserid:help( "Add a user by ID to specified group." )

	function ulx.removeuser( calling_ply, target_ply )
		ULib.ucl.addUser( target_ply:SteamID(), nil,nil,"user")
		
		MSync.SaveRank(target_ply:SteamID64(), "user")

		ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #T", target_ply )
	end
	local removeuser = ulx.command( "User Management", "ulx removeuser", ulx.removeuser, nil, false, false, true )
	removeuser:addParam{ type=ULib.cmds.PlayerArg }
	removeuser:defaultAccess( ULib.ACCESS_SUPERADMIN )
	removeuser:help( "Permanently removes a user's access." )

	function ulx.removeuserid( calling_ply, id )
		id = id:upper() -- Steam id needs to be upper
	--[[if IsValid(calling_ply) then
		-- Check for valid and properly formatted ID
		if not checkForValidId( calling_ply, id ) then return false end
	end]]
		--[[if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
			ULib.tsayError( calling_ply, "No player with id \"" .. id .. "\" exists in the ULib user list", true )
			return false
		end]]
		
		if not ULib.isValidSteamID(id) then ULib.tsayError( calling_ply, "Invalid StemID", true ) return end

		local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name)

		ULib.ucl.addUser( id, nil,nil,"user")

		if name then
			ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #s", name )
		else
			ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #s", id )
		end
		MSync.SaveRank(util.SteamIDTo64( id ), "user")
	end
	local removeuserid = ulx.command( "User Management", "ulx removeuserid", ulx.removeuserid, nil, false, false, true )
	removeuserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID, IP, or UniqueID" }
	removeuserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
	removeuserid:help( "Permanently removes a user's access by ID." )

	function voteBanDone2( t, nick, steamid, time, ply, reason )
		local shouldBan = false

		if t.results[ 1 ] and t.results[ 1 ] > 0 then
			ulx.fancyLogAdmin( ply, "#A approved the voteban against #s (#s minutes) (#s))", nick, time, reason or "" )
			shouldBan = true
		else
			ulx.fancyLogAdmin( ply, "#A denied the voteban against #s", nick )
		end

		if shouldBan then
			--ULib.addBan( steamid, time, reason, nick, ply )
			MSync.banid( ply, steamid, time, reason or "" )
		end
	end

	function voteBanDone( t, nick, steamid, time, ply, reason )
		local results = t.results
		local winner
		local winnernum = 0
		for id, numvotes in pairs( results ) do
			if numvotes > winnernum then
				winner = id
				winnernum = numvotes
			end
		end

		local ratioNeeded = GetConVarNumber( "ulx_votebanSuccessratio" )
		local minVotes = GetConVarNumber( "ulx_votebanMinvotes" )
		local str
		if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
			str = "Vote results: User will not be banned. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
		else
			reason = ("[ULX Voteban] " .. (reason or "")):Trim()
			if ply:IsValid() then
				str = "Vote results: User will now be banned, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
				ulx.doVote( "Accept result and ban " .. nick .. "?", { "Yes", "No" }, voteBanDone2, 30000, { ply }, true, nick, steamid, time, ply, reason )
			else -- Vote from server console, roll with it
				str = "Vote results: User will now be banned. (" .. winnernum .. "/" .. t.voters .. ")"
				--ULib.addBan( steamid, time, reason, nick, ply )
				MSync.banid( ply, steamid, time, reason or "" )
			end
		end

		ULib.tsay( _, str ) -- TODO, color?
		ulx.logString( str )
		Msg( str .. "\n" )
	end
	
	function ulx.unban( calling_ply, steamid )
		steamid = steamid:upper()
		if not ULib.isValidSteamID( steamid ) then
			ULib.tsayError( calling_ply, "Invalid SteamID." )
			return
		end

		MSync.RemoveBan(steamid,calling_ply)
	end
		local unban = ulx.command( CATEGORY_NAME, "ulx unban", ulx.unban,"!unban" )
		unban:addParam{ type=ULib.cmds.StringArg, hint="SteamID" }
		unban:defaultAccess( ULib.ACCESS_ADMIN )
		unban:help( "[MBSync] Unbans SteamID." )
end)