-- TODO encapsulate os.date() formatting

if CLIENT then
	print("[MSync] Loaded")
	-- Declaring MSync Variable
	MSync = MSync or {}
	MSync.RFP = false
	-- TODO move this away into some shared file
	MSync.LocalSettings = MSync.LocalSettings or { -- Set MSync.LocalSettings to MSync.LocalSettings or to Default Settings to Prevent Empty MSync.LocalSettings
			Servergroup = "Default",
			EnabledModules = {
				"MRSync"
			},
			DisabledModules = {
				"MBSync",
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
			DBVersion = 0
	}

	-- ##NET RECIEVER##

	net.Receive("MSyncRevertSettings", function( len, ply )
			MSync.Chat(Color(255,255,255),"Retrieved data from server! (A1)")
			MSync.LocalSettings = net.ReadTable()
			MSync.RefreshPanel()

	end)

	net.Receive("MSyncChatPrint", function( len, ply )
			MSync.Chat(net.ReadColor() ,net.ReadString())
	end)

	net.Receive("MSyncRevertBans", function( len, ply )
			MSync.Chat(Color(255,255,255),"Retrieved bans from server! (A1)")
			MSync.LocalBans = net.ReadTable()
			AddBanTable()

	end)
	-- ##NET TRANSMITTER FUNCTIONS##

	function MSync.SendSettings()
		MSync.Chat(Color(255,255,255),"Sending data to server! (A1)")
		net.Start( "MSyncTableSend" )
			net.WriteTable( MSync.LocalSettings )
			net.WriteEntity( LocalPlayer() )
		net.SendToServer()
	end

	function MSync.GetBans()
		MSync.Chat(Color(255,255,255),"Retrieving bans from server! (A1)")
		net.Start( "MSyncGetBans" )
			net.WriteEntity( LocalPlayer() )
		net.SendToServer()
	end

	function MSync.GetSettings()
		MSync.Chat(Color(255,255,255),"Retrieving data from server! (A1)")
		net.Start( "MSyncGetSettings" )
			net.WriteEntity( LocalPlayer() )
		net.SendToServer()
	end

	-- ##XGUI FUNCTIONS##

	function MSync.RefreshPanel()
		if not(MSync.RFP)then
			MSync.MySQL.init()
			MSync.Modules.init()
			MSync.MRSync.init()
			MSync.MBSync.init()
			HidePanel(MSync.Modules)
			HidePanel(MSync.MRSync)
			HidePanel(MSync.MBSync)
			HidePanel(MSync.MySQL)
			MSync.settingList:Clear()
			MSync.settingList:AddLine( "MySQL" )
			MSync.settingList:AddLine( "Modules" )
			AddTable(MSync.LocalSettings.EnabledModules,MSync.settingList)
			MSync.Modules.enabledModulesList:Clear()
			MSync.Modules.disabledModulesList:Clear()
			AddTable(MSync.LocalSettings.EnabledModules,MSync.Modules.enabledModulesList)
			AddTable(MSync.LocalSettings.DisabledModules,MSync.Modules.disabledModulesList)
			MSync.MRSync.IgnoreTable:Clear()
			MSync.MRSync.AllServerTable:Clear()
			AddTable(MSync.LocalSettings.mrsync.IgnoredRanks,MSync.MRSync.IgnoreTable)
			AddTable(MSync.LocalSettings.mrsync.AllServerRanks,MSync.MRSync.AllServerTable)
			MSync.RFP = true
		else
			MSync.MySQL.Host:SetText(MSync.LocalSettings.mysql.Host)
			MSync.MySQL.Port:SetText(MSync.LocalSettings.mysql.Port)
			MSync.MySQL.Username:SetText(MSync.LocalSettings.mysql.Username)
			MSync.MySQL.Password:SetText(MSync.LocalSettings.mysql.Password)
			MSync.MySQL.Database:SetText(MSync.LocalSettings.mysql.Database)
			MSync.MySQL.Servergrp:SetText(MSync.LocalSettings.Servergroup)
			MSync.settingList:Clear()
			MSync.settingList:AddLine( "MySQL" )
			MSync.settingList:AddLine( "Modules" )
			AddTable(MSync.LocalSettings.EnabledModules,MSync.settingList)
			MSync.Modules.enabledModulesList:Clear()
			MSync.Modules.disabledModulesList:Clear()
			AddTable(MSync.LocalSettings.EnabledModules,MSync.Modules.enabledModulesList)
			AddTable(MSync.LocalSettings.DisabledModules,MSync.Modules.disabledModulesList)
			MSync.MRSync.IgnoreTable:Clear()
			MSync.MRSync.AllServerTable:Clear()
			AddTable(MSync.LocalSettings.mrsync.IgnoredRanks,MSync.MRSync.IgnoreTable)
			AddTable(MSync.LocalSettings.mrsync.AllServerRanks,MSync.MRSync.AllServerTable)
		end
	end

	-- ##UTIL FUNCTIONS##

	function MSync.Chat(col, text)
		chat.AddText(Color(255,255,255),"[",Color(120,0,0),"MSync",Color(255,255,255),"]",col,text)
	end

	function HidePanel(tbl)
		for k, v in pairs( tbl ) do
			if type(v)=="Panel" then
				v:SetVisible(false)
			end
		end
	end

	function ShowPanel(tbl)
		for k, v in pairs( tbl ) do
			if type(v)=="Panel" then
				v:SetVisible(true)
			end
		end
	end

	function AddTable(tbl,listModule)
		for k, v in pairs( tbl ) do
			if not (table.HasValue( listModule:GetLines(), v ))then
				listModule:AddLine(v)
			end
		end
	end

	function AddBanTable()
		MSync.MBSync.Table:Clear()
		for k, v in pairs( MSync.LocalBans ) do
			if not (table.HasValue( MSync.MBSync.Table:GetLines(), v ))then
				if(MSync.LocalBans[k].name=="null")then
					MSync.MBSync.Table:AddLine(MSync.LocalBans[k].steamid,MSync.LocalBans[k].staff_name,os.date( "%H:%M - %d/%m/%Y" ,(MSync.LocalBans[k].ban_date+MSync.LocalBans[k].duration)),MSync.LocalBans[k].reason)
				elseif not(MSync.LocalBans[k].name=="null")then
					MSync.MBSync.Table:AddLine(MSync.LocalBans[k].name,MSync.LocalBans[k].staff_name,os.date( "%H:%M - %d/%m/%Y" ,(MSync.LocalBans[k].ban_date+MSync.LocalBans[k].duration)),MSync.LocalBans[k].reason)
				end
			end
		end
	end

	function MSync.BanTableUnban(term)
		if not (ULib.isValidSteamID(term)) then
			for k, v in pairs( MSync.LocalBans ) do
				if(MSync.LocalBans[k].nickname==term)then
					RunConsoleCommand("ulx","unban",MSync.LocalBans[k].steamid )
				end
			end
		elseif (ULib.isValidSteamID(term)) then
			RunConsoleCommand("ulx","unban",term )
		end
	end

	function SearchBanTable(searchterm)
		MSync.MBSync.Table:Clear()
		if(ULib.isValidSteamID(string.upper( searchterm )))then
			for k, v in pairs( MSync.LocalBans ) do
				if(MSync.LocalBans[k].steamid==string.upper( searchterm ))then
					MSync.MBSync.Table:AddLine(MSync.LocalBans[k].steamid,MSync.LocalBans[k].admin,os.date( "%H:%M - %d/%m/%Y" ,(MSync.LocalBans[k].ban_date+MSync.LocalBans[k].duration)),MSync.LocalBans[k].reason)
				end
			end
		elseif not(ULib.isValidSteamID(searchterm))then
			for k, v in pairs( MSync.LocalBans ) do
				if not(string.find( MSync.LocalBans[k].nickname, searchterm)==nil)then
					MSync.MBSync.Table:AddLine(MSync.LocalBans[k].nickname,MSync.LocalBans[k].admin,os.date( "%H:%M - %d/%m/%Y" ,(MSync.LocalBans[k].ban_date+MSync.LocalBans[k].duration)),MSync.LocalBans[k].reason)
				end
			end
		end
	end


end
