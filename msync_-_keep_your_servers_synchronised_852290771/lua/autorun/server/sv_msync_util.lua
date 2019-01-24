MSync = MSync or {}
MSync.Bans = MSync.Bans or {}
MSync.Settings = MSync.Settings or {}
MSync.ULX = MSync.ULX or {}
MSync.AllowedGroups = MSync.AllowedGroups or {}
MSync.version = "A 1.5"
MSync.DBVersion = 1.5
MSync.RDBVersion = 1.4
MSync.BDBVersion = 1.4
MSync.MBsyncVersion = "A 1.2"
MSync.MRsyncVersion = "B 1.6"
MSync.xgui_panelVersion = "A 1.5"

concommand.Add( "msync_version", function( ply, cmd, args )
	print(
		"[MSync] Version:\n" ..
		"MSync version: " .. MSync.version .. "\n" ..
		"MBSync version: " .. MSync.MBsyncVersion .. "\n" ..
		"MRSync version: " .. MSync.MRsyncVersion .. "\n" ..
		"MSync XGUI version: " .. MSync.xgui_panelVersion
	)
end)

-- Load Function on Enable of the Addon
function MSync.load()

	if not (file.Exists( "msync/settings.txt", "DATA" )) then
		print("[MSync] Writting settings file")
		file.CreateDir( "msync" )

		MSync.Settings = {
			Servergroup = "Default",
			EnabledModules = {
				"MRSync"
			},
			DisabledModules = {
				"MBSync"
			},
			mysql = {
				Host = "127.0.0.1",
				Port = 3306,
				Database = "",
				Username = "root",
				Password = ""
			},
			mrsync = {
				AllServerRanks = {
					"owner",
					"superadmin",
					"admin"
				},
				IgnoredRanks = {
					"drp_donator",
					"drp_admin"
				}
			},
			DBVersion = 0,
			RDBVersion = 0,
			BDBVersion = 0
		}

		file.Write( "msync/settings.txt", util.TableToJSON( MSync.Settings, true ))

	else
		print("[MSync] Getting settings file")
		MSync.Settings = util.JSONToTable( file.Read( "msync/settings.txt", "DATA" ))
	end

	util.AddNetworkString( "MSyncRevertSettings" )
	util.AddNetworkString( "MSyncTableSend" )
	util.AddNetworkString( "MSyncGetSettings" )
	util.AddNetworkString( "MSyncChatPrint" )
	util.AddNetworkString( "MSyncGetBans" )
	util.AddNetworkString( "MSyncRevertBans" )
	include( "autorun/server/sv_msync_modules.lua" )
	include( "msync/mysql_main.lua" )
	if(table.HasValue(MSync.Settings.EnabledModules,"MBSync")) then
		MSync.GetBans()
	end
end

function MSync.SaveSettings()
	file.Write( "msync/settings.txt", util.TableToJSON( MSync.Settings, true ))
end

-- Read Groups for Permissions

-- TODO duplicate code here

-- Send Settings to Players
net.Receive("MSyncGetSettings", function( len, ply )
	if(ULib.ucl.query(ply, "xgui_msync")) then
		net.Start("MSyncRevertSettings")
			net.WriteTable(MSync.Settings)
		net.Send(ply)
	else
		MSync.SendMessageToAdmins(Color(255,255,255), "WARNING: Player: " .. ply:GetName() .. " tried to exploit the server and got kicked! (A2)")
		ply:Kick("[MSync] CSLua: Tried to force-get server settings table (A2)")
	end

end)

-- Get The Ban Table
net.Receive("MSyncGetBans", function( len, ply )
	MSync.GetBans()
	if(ULib.ucl.query(ply, "xgui_msync")) then
		net.Start("MSyncRevertBans")
			net.WriteTable(MSync.Bans)
		net.Send(ply)
	else
		MSync.SendMessageToAdmins(Color(255,255,255), "WARNING: Player: " .. ply:GetName() .. " tried to exploit the server and got kicked! (A2)")
		ply:Kick("[MSync] CSLua: Tried to force get server settings table (A2)")
	end
end)
-- Get Table and save the Settings
net.Receive("MSyncTableSend", function( len, ply )
	if(ULib.ucl.query(ply,"xgui_msync")) then
		MSync.Settings = net.ReadTable()
		MSync.SaveSettings()
	else
		MSync.SendMessageToAdmins(Color(255,255,255), "WARNING: Player: " .. ply:GetName() .. " tried to exploit the server and got kicked! (A2)")
		ply:Kick("[MSync] CSLua: Tried to force-send settings table (A2)")
	end
end)

function MSync.SendMessageToAdmins(col,text)
	for k, v in pairs( player.GetAll() ) do
		if(v:IsAdmin())then
			net.Start("MSyncChatPrint")
				net.WriteColor(col)
				net.WriteString(text)
			net.Send(v)
		end
	end
end

function MSync.PrintToAll(col, text)
	print(text)
	net.Start("MSyncChatPrint")
		net.WriteColor(col)
		net.WriteString(text)
	net.Broadcast()
end

function MSync.Print(ply, col, text)
	if ply.IsValid == nil or not ply:IsValid() then
		print(text)
	end
	net.Start("MSyncChatPrint")
		net.WriteColor(col)
		net.WriteString(text)
	net.Send(ply)
end

-- Builds and returns ban message for displaying to the player
function MSync.GetBannedMessage(reason, ban_timestamp, duration_seconds, staffName)
	return
	"You are banned!\n" ..
	"------------------------\n" ..
	"Reason: " .. reason .. "\n" ..
	"Banned by: " .. staffName .. "\n" ..
	"Duration: " .. MSync.FormatTime(duration_seconds) .. "\n" ..
	"Lifted in: " .. MSync.FormatTime((ban_timestamp + duration_seconds) - os.time()) .. "\n" ..
	"------------------------" 
end

-- Converts seconds to human-readable string
-- Example: 2 years 8 months 16 days 3 hours 43 minutes 12 seconds
function MSync.FormatTime(seconds)

	if tonumber(seconds) <= 0 then
		return "Permanent";
	else
		local secondsInYear = 31556926
		local secondsInMonth = 2629744
		local secondsInDay = 86400
		local secondsInHour = 3600
		local secondsInMinute = 60
		local result = ""
		local remainder = tonumber(seconds)
		if remainder >= secondsInYear then
			years = math.floor(remainder/secondsInYear)
			result = result .. string.format("%d years ", years);
			remainder = remainder - years * secondsInYear
		end
		if remainder >= secondsInMonth then
			months = math.floor(remainder/secondsInMonth)
			result = result .. string.format("%d months ", months);
			remainder = remainder - months * secondsInMonth
		end
		if remainder >= secondsInDay then
			days = math.floor(remainder/secondsInDay)
			result = result .. string.format("%d days ", days);
			remainder = remainder - days * secondsInDay
		end
		if remainder >= secondsInHour then
			hours = math.floor(remainder/secondsInHour)
			result = result .. string.format("%d hours ", hours);
			remainder = remainder - hours * secondsInHour
		end
		if remainder >= secondsInMinute then
			minutes = math.floor(remainder/secondsInMinute)
			result = result .. string.format("%d minutes ", minutes);
			remainder = remainder - minutes * secondsInMinute
		end
		if remainder > 0 then
			result = result .. string.format("%d seconds", remainder);
		end

		return result
	end
end

-- Converts seconds to human-readable date and time
-- TODO find if this has any usages
function MSync.FormatDateTime(timestamp)
	return os.date("%d/%m/%Y %H:%M", timestamp)
end

-- Returns whether or not ply is a valid player
function MSync.IsValidPlayer(ply)
	return ply.IsValid ~= nil and ply:IsValid()
end

hook.Add( "Initialize", "MSync_Load", MSync.load )
hook.Add("ShutDown", "MRSyncSaveAllUsers", MSync.SaveSettings)
