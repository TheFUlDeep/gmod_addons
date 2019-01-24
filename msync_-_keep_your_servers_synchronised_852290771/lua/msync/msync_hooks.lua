if(table.HasValue(MSync.Settings.EnabledModules, "MRSync")) then
	hook.Add("PlayerInitialSpawn", "MRSyncSyncUser", MSync.LoadRank)
--	hook.Add("PlayerDisconnected", "MRSyncSaveUser", function(ply)
	--	MSync.SaveRank(ply:SteamID64(), ply:GetUserGroup())
	--end)
	--hook.Add("ShutDown", "MRSyncSaveAllUsers", MSync.SaveAllRanks)
end

if(table.HasValue(MSync.Settings.EnabledModules, "MBSync")) then
	hook.Add( "CheckPassword", "MSyncBanCheck", function(steamID64)
		local MBSyncTbl = MSync.CheckIfBannedSync(util.SteamIDFrom64(steamID64))
		if MBSyncTbl then
			return false, (MSync.GetBannedMessage(MBSyncTbl.reason, MBSyncTbl.ban_date, MBSyncTbl.duration, MBSyncTbl.staff_name))
		end
	end)

	hook.Add( "PlayerInitialSpawn", "MSyncBanCheckBackup", function(ply)
		local MBSyncTbl = MSync.CheckIfBanned(ply:SteamID(), function(banTable)
			if banTable then
				print("[MBSync] Backup check: " .. ply:GetName() .. " is banned!")
				ply:Kick(MSync.GetBannedMessage(MBSyncTbl.reason, MBSyncTbl.ban_date, MBSyncTbl.duration, MBSyncTbl.staff_name))
			end
		end)
	end)
end
