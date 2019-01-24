if(table.HasValue(MSync.Settings.EnabledModules, "MBSync")) then
	print("[MBSync] Loading...")

	function MSync.AddBan(steamid, name, staff_steamid, staff_name, reason, duration_minutes)

		-- Put all queries into a trasaction for atomicity
		local transaction = MSync.DB:createTransaction()

		-- First, "shorten" last permanent ban (if any) to end right now
		local ReleasePermanentBans = MSync.DB:prepare([[
			UPDATE `]] .. MSync.TableNameBans .. [[`
				SET `duration` = (UNIX_TIMESTAMP() - `ban_date`)
				WHERE `steamid` = ? AND `duration` = 0
				ORDER BY `ban_date` DESC LIMIT 1
		]])
		ReleasePermanentBans:setString(1, steamid)
		transaction:addQuery(ReleasePermanentBans)

		-- Then, shorten last temporary ban which is still in effect (if any) to end right now
		local ShortenBans = MSync.DB:prepare([[
			UPDATE `]] .. MSync.TableNameBans .. [[`
				SET `duration` = (UNIX_TIMESTAMP() - `ban_date`)
				WHERE `steamid` = ? AND (`ban_date` + `duration` > UNIX_TIMESTAMP())
				ORDER BY `ban_date` DESC LIMIT 1
		]])
		ShortenBans:setString(1, steamid)
		transaction:addQuery(ShortenBans)

		-- Then finally add the new ban
		local QbanAdd = MSync.DB:prepare([[
			INSERT INTO `]] .. MSync.TableNameBans .. [[`
				(`steamid`, `name`, `staff_steamid`, `staff_name`, `reason`, `ban_date`, `duration`)
				VALUES (?, ?, ?, ?, ?, ?, ?)
		]])
		QbanAdd:setString(1, steamid)
		QbanAdd:setString(2, name)
		if staff_steamid == nil then
			QbanAdd:setNull(3)
		else
			QbanAdd:setString(3, staff_steamid)
		end
		QbanAdd:setString(4, staff_name)
		QbanAdd:setString(5, reason)
		QbanAdd:setNumber(6, os.time())
		QbanAdd:setNumber(7, tonumber(duration_minutes) * 60)
		transaction:addQuery(QbanAdd)

		transaction.onSuccess = function()
			game.KickID(steamid, MSync.GetBannedMessage(reason, os.time(), duration_minutes * 60, staff_name))
			if duration_minutes <= 0 then
				MSync.PrintToAll(Color(200,0,0), "Player " .. name .. " got permanently banned for reason: " .. reason .. " by: " .. staff_name)
			else
				MSync.PrintToAll(Color(200,0,0), "Player " .. name .. " got banned for " .. MSync.FormatTime(duration_minutes * 60) .. " for reason: " .. reason .. " by: " .. staff_name)
			end
		end
		transaction.onError = function(Q, E) print("[MBSync] Error while banning: " .. E) end
		transaction:start()
	end

	function MSync.RemoveBan(steamid, staff)
		local staffName = MSync:IsValidPlayer(staff) and staff:GetName() or "(Console)"
		local QremBan = MSync.DB:prepare([[
			UPDATE `]] .. MSync.TableNameBans .. [[`
			SET `duration` = (UNIX_TIMESTAMP() - `ban_date`)
			WHERE `steamid` = ? AND
			(`ban_date` + `duration` > UNIX_TIMESTAMP() OR `duration` = 0)
			ORDER BY `ban_date` DESC LIMIT 1
		]])
		QremBan:setString(1, steamid)
		QremBan.onSuccess = function(q)
			if (q:affectedRows() > 0) then
				MSync.PrintToAll(Color(33,255,0), "Player " .. steamid .. " got unbanned by: " .. staffName)
			else
				MSync.Print(staff, Color(160,160,0), ("Cannot unban " .. steamid .. " - not banned."))
			end
		end
		QremBan:start()
	end

	function MSync.CheckBan(steamid, staff)
		local QcheckBan = MSync.DB:prepare("SELECT * FROM `" .. MSync.TableNameBans .. "` WHERE `steamid` = ? AND (`ban_date` + `duration` > UNIX_TIMESTAMP() OR `duration` = 0) ORDER BY `ban_date` DESC LIMIT 1")
		QcheckBan:setString(1, steamid)

		QcheckBan.onError = function(Q,E) print("Q1") print(E) end
		QcheckBan.onSuccess = function (q, data)

			if data[1] ~= nil then

				banTable = data[1]
				if (banTable.duration <= 0) then
					MSync.Print(staff, Color(160,160,0), "Player " .. steamid .. " got banned for reason " .. banTable.reason .. " by " .. banTable.staff_name .. " permanently")
				elseif(banTable.duration + banTable.ban_date >= os.time()) then
					MSync.Print(staff, Color(160,160,0), ("Player " .. steamid .. " got banned for reason " .. banTable.reason .. " by " .. banTable.staff_name .. " until " .. MSync.FormatDateTime(banTable.duration + banTable.ban_date)))
				end
			else
				MSync.Print(staff, Color(160,160,0), ("Player " .. steamid .. " is not banned."))
			end
		end
		QcheckBan:start()
	end

	function MSync.GetBans()
		local q = MSync.DB:prepare("SELECT * FROM `" .. MSync.TableNameBans .. "`")
		q.onSuccess = function(q, data)
			MSync.Bans = data
		end
		q:start()
		-- TODO refactor this so we don't have to wait here
		q:wait()
	end

	-- Asynchronous version of CheckIfBanned. Calls the callback after finishing,
	-- passing the ban data if the player is banned and false if they aren't.
	function MSync.CheckIfBanned(ply, callback)
		local QcheckIfBan = MSync.DB:prepare([[
			SELECT * FROM `]] .. MSync.TableNameBans .. [[`
			WHERE `steamid` = ? AND
			(`ban_date` + `duration` > UNIX_TIMESTAMP() OR `duration` = 0)
			ORDER BY `ban_date` DESC LIMIT 1]]
		)
		QcheckIfBan:setString(1, ply)

		local banTable = nil
		print("[MBSync] Checking if " .. ply .. " is banned...")

		QcheckIfBan.onError = function(q, err) print("Q1: " .. err) end
		-- Call the callback with the ban data on success, false if no active ban found
		QcheckIfBan.onSuccess = function(q, data)
			if data ~= nil and data[1] ~= nil then
				print("[MBSync] Player " .. ply .. " is banned.")
				callback(data[1])
			else
				print("[MBSync] Player " .. ply .. " is not banned.")
				callback(false)
			end
		end
		QcheckIfBan:start()
	end

	-- Synchronous version, only used when we absolutely need the result before continuing
	-- This waits until the query finishes, so it freezes the server in the meantime
	function MSync.CheckIfBannedSync(ply)
		local QcheckIfBan = MSync.DB:prepare([[
			SELECT * FROM `]] .. MSync.TableNameBans .. [[`
			WHERE `steamid` = ? AND
			(`ban_date` + `duration` > UNIX_TIMESTAMP() OR `duration` = 0)
			ORDER BY `ban_date` DESC LIMIT 1]]
		)
		QcheckIfBan:setString(1, ply)

		local banTable = nil
		print("[MBSync] Checking if " .. ply .. " is banned...")

		QcheckIfBan.onError = function(q, err) print("Q1: " .. err) end

		QcheckIfBan:start()
		QcheckIfBan:wait()

		if QcheckIfBan:getData() ~= nil and QcheckIfBan:getData()[1] ~= nil then
			print("[MBSync] Player " .. ply .. " is banned.")
			return QcheckIfBan:getData()[1]
		end
		return false
	end
	print("[MBSync] Loading completed!")
end
