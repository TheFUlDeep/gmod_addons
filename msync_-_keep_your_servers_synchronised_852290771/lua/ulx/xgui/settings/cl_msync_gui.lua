xgui.prepareDataType( "MSync-Settings" )

include( "autorun/client/cl_msync_util.lua" )

MSync = MSync or {}
MSync.Modules = MSync.Modules or {}
MSync.MySQL	= MSync.MySQL or {}
MSync.MRSync = MSync.MRSync or {}
MSync.MBSync = MSync.MBSync or {}
local MSyncVars = {}

if(ULib.ucl.query(	LocalPlayer(),"xgui_msync"))then
	MSync.GetSettings()
end

function MSync.Modules.init()
	MSync.Modules.enabledModulesList = xlib.makelistview{ parent=MSync.back, x=180, y=30, w=150, h=200 }
	MSync.Modules.disable = xlib.makebutton{ parent=MSync.back, x=340, y=120, w=20, h=20, label="->", disabled=false }
	MSync.Modules.enable = xlib.makebutton{ parent=MSync.back, x=340, y=160, w=20, h=20, label="<-", disabled=false }
	MSync.Modules.disabledModulesList = xlib.makelistview{ parent=MSync.back, x=370, y=30, w=150, h=200 }
	MSync.Modules.enabledModulesList:AddColumn( "Enabled Modules" )
	MSync.Modules.disabledModulesList:AddColumn( "Disabled Modules" )
	MSync.Modules.enabledModulesList:SetMultiSelect( false )
	MSync.Modules.disabledModulesList:SetMultiSelect( false )
	MSync.Modules.DescriptionText = xlib.makelabel{ x=180, y=235, w=300, wordwrap=true, label="To enable a module, select the module in the Disabled modules list and press '<-'. To disable a module, select it in the Enabled Modules list and press '->'.", parent=MSync.back }
end

function MSync.MySQL.init()
	MSync.MySQL.text 			= xlib.makelabel{ x=165, y=13, label="MySQL Settings", parent=MSync.back }
	MSync.MySQL.Hosttext 		= xlib.makelabel{ x=165, y=30, label="Host/IP:", parent=MSync.back }
	MSync.MySQL.Host 	 		= xlib.maketextbox{ parent=MSync.back, x=165, y=45, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.Porttext 		= xlib.makelabel{ x=165, y=75, label="Port:", parent=MSync.back }
	MSync.MySQL.Port 	 		= xlib.maketextbox{ parent=MSync.back, x=165, y=90, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.Usernametext 	= xlib.makelabel{ x=165, y=120, label="Username:", parent=MSync.back }
	MSync.MySQL.Username 		= xlib.maketextbox{ parent=MSync.back, x=165, y=135, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.Passwordtext 	= xlib.makelabel{ x=165, y=165, label="Password:", parent=MSync.back }
	MSync.MySQL.Password 		= xlib.maketextbox{ parent=MSync.back, x=165, y=180, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.Databasetext 	= xlib.makelabel{ x=165, y=210, label="Database:", parent=MSync.back }
	MSync.MySQL.Database 		= xlib.maketextbox{ parent=MSync.back, x=165, y=225, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.Servergrptext 	= xlib.makelabel{ x=165, y=255, label="Servergroup:", parent=MSync.back }
	MSync.MySQL.Servergrp 		= xlib.maketextbox{ parent=MSync.back, x=165, y=270, w=160, h=25, disabled=false, visible=true}
	MSync.MySQL.DescriptionText = xlib.makelabel{ x=350, y=10, w=170, wordwrap=true, label="Set your MySQL settings here.\nHOST: Hostname or IP address of the SQL server.\nPORT: Port of the MySQL server.\nUSERNAME: Username for the access to the database.\nPASSWORD: Password for the MySQL user.\nDATABASE: Name of the MySQL database to use.\nSERVERGROUP: Name of the server group this server belongs to (for example DarkRP or sandbox).", parent=MSync.back }

	--[[ Currently not Working! Stay tuned for Updates!
	MSync.MySQL.connectText		= xlib.makelabel{ x=360, y=265, label="Status: Unknown", parent=MSync.back }
	MSync.MySQL.connectButton 	= xlib.makebutton{ parent=MSync.back, x=360, y=280, w=100, h=15, label="CONNECT", disabled=false }
	--]]

	MSync.MySQL.Host:SetText(MSync.LocalSettings.mysql.Host)
	MSync.MySQL.Port:SetText(MSync.LocalSettings.mysql.Port)
	MSync.MySQL.Username:SetText(MSync.LocalSettings.mysql.Username)
	MSync.MySQL.Password:SetText(MSync.LocalSettings.mysql.Password)
	MSync.MySQL.Database:SetText(MSync.LocalSettings.mysql.Database)
	MSync.MySQL.Servergrp:SetText(MSync.LocalSettings.Servergroup)
end

function MSync.MRSync.init()
	MSync.MRSync.text 					= xlib.makelabel{ x=160, y=10, label="MRSync Settings", parent=MSync.back }
	MSync.MRSync.IgnoreTable 			= xlib.makelistview{ parent=MSync.back, x=160, y=30, w=150, h=180 }
	MSync.MRSync.AllServerTable 		= xlib.makelistview{ parent=MSync.back, x=320, y=30, w=150, h=180 }

	MSync.MRSync.AddIgnoreButton 		= xlib.makebutton{ parent=MSync.back, x=280, y=220, w=15, h=25, label="+", disabled=false }
	MSync.MRSync.RemoveIgnoreButton 	= xlib.makebutton{ parent=MSync.back, x=295, y=220, w=15, h=25, label="-", disabled=false }

	MSync.MRSync.AddAllServerButton 	= xlib.makebutton{ parent=MSync.back, x=440, y=220, w=15, h=25, label="+", disabled=false }
	MSync.MRSync.RemoveAllServerButton 	= xlib.makebutton{ parent=MSync.back, x=455, y=220, w=15, h=25, label="-", disabled=false }

	MSync.MRSync.IgnoreTextBox			= xlib.maketextbox{ parent=MSync.back, x=160, y=220, w=120, h=25, disabled=false, visible=true}
	MSync.MRSync.AllServerTextBox		= xlib.maketextbox{ parent=MSync.back, x=320, y=220, w=120, h=25, disabled=false, visible=true}

	MSync.MRSync.Descriptiontext 		= xlib.makelabel{ x=475, y=30, w=100, wordwrap=true, label="Ignored ranks: This is a list of ranks which are not going to be saved in the MySQL table.\nAll servers ranks: These are ranks which ignore the Servergroup and are synced across all servers", parent=MSync.back }
	MSync.MRSync.Descriptiontext2 		= xlib.makelabel{ x=160, y=250, w=340, wordwrap=true, label="Description: Enter the rank and press '+' to add it to the list. To remove an entry, select it in the table and press '-'.", parent=MSync.back }

	MSync.MRSync.IgnoreTable:AddColumn( "Ignored ranks" )
	MSync.MRSync.AllServerTable:AddColumn( "All servers ranks" )
	MSync.MRSync.IgnoreTable:SetMultiSelect( false )
	MSync.MRSync.AllServerTable:SetMultiSelect( false )
end

function MSync.MBSync.init()
	MSync.MBSync.Table				= xlib.makelistview{ parent=MSync.back, x=160, y=35, w=400, h=220 }

	MSync.MBSync.Table:AddColumn( "Name/SteamID" )
	MSync.MBSync.Table:AddColumn( "Banned by" )
	MSync.MBSync.Table:AddColumn( "Unban date" )
	MSync.MBSync.Table:AddColumn( "Reason" )
	MSync.MBSync.SearchBox			= xlib.maketextbox{ parent=MSync.back, x=160, y=5, w=150, h=25, disabled=false, visible=true}
	MSync.MBSync.Sync				= xlib.makebutton{ parent=MSync.back, x=370, y=5, w=50, h=25, label="Sync", disabled=false }
	MSync.MBSync.SearchButton		= xlib.makebutton{ parent=MSync.back, x=315, y=5, w=50, h=25, label="Search", disabled=false }
	MSync.MBSync.Description		= xlib.makelabel{ x=425, y=5, w=150, wordwrap=true, label="Press 'Sync' to retrieve the bans.", parent=MSync.back }

end

MSync.back = xlib.makepanel{ parent=xgui.null }
MSync.settingList = xlib.makelistview{ parent=MSync.back, x=5, y=5, w=150, h=250 }
MSync.refreshbutton = xlib.makebutton{ parent=MSync.back, x=360, y=300, w=100, h=25, label="Refresh", disabled=false }
MSync.savebutton = xlib.makebutton{ parent=MSync.back, x=150, y=300, w=100, h=25, label="Save", disabled=false }
MSync.resetbutton = xlib.makebutton{ parent=MSync.back, x=255, y=300, w=100, h=25, label="Reset", disabled=false }
MSync.connectDescription = xlib.makelabel{ x=5, y=260, w=150, wordwrap=true, label="WARNING: You need to restart the server for the changes to take effect.", parent=MSync.back }

MSync.settingList:AddColumn( "MSync - Settings" )
MSync.settingList:AddLine( "MySQL" )
MSync.settingList:AddLine( "Modules" )
AddTable(MSync.LocalSettings.EnabledModules,MSync.settingList)
MSync.settingList:SetMultiSelect( false )

--------------------------------------------------------------------------------------------------------------------------------------------

MSync.settingList.OnRowSelected = function( self, lineid, line )
	if line:GetValue(1) == "MySQL" then
		HidePanel(MSync.Modules)
		HidePanel(MSync.MRSync)
		HidePanel(MSync.MBSync)
		ShowPanel(MSync.MySQL)
		MSync.MySQL.Host:SetText(MSync.LocalSettings.mysql.Host)
		MSync.MySQL.Port:SetText(MSync.LocalSettings.mysql.Port)
		MSync.MySQL.Username:SetText(MSync.LocalSettings.mysql.Username)
		MSync.MySQL.Password:SetText(MSync.LocalSettings.mysql.Password)
		MSync.MySQL.Database:SetText(MSync.LocalSettings.mysql.Database)
		MSync.MySQL.Servergrp:SetText(MSync.LocalSettings.Servergroup)

		--[[ Currently not Working! Stay tuned for Updates!
		MSync.MySQL.connectButton.DoClick = function()

		end
		--]]
	elseif line:GetValue(1) == "MRSync" then
		HidePanel(MSync.Modules)
		HidePanel(MSync.MySQL)
		HidePanel(MSync.MBSync)
		ShowPanel(MSync.MRSync)

		MSync.MRSync.AddAllServerButton.DoClick = function()
			MSync.MRSync.AllServerTable:AddLine(MSync.MRSync.AllServerTextBox:GetText())
			MSync.MRSync.AllServerTextBox:SetValue("")
		end

		MSync.MRSync.RemoveAllServerButton.DoClick = function()
			if not(MSync.MRSync.AllServerTable:GetSelected()[1]:GetValue(1)==nil)then
				MSync.MRSync.AllServerTable:RemoveLine(MSync.MRSync.AllServerTable:GetSelectedLine())
			else
				MSync.Chat(Color(255,0,0),"ERROR: No rank selected! (A3)")
			end
		end

		MSync.MRSync.AddIgnoreButton.DoClick = function()
			MSync.MRSync.IgnoreTable:AddLine(MSync.MRSync.IgnoreTextBox:GetText())
			MSync.MRSync.IgnoreTextBox:SetValue("")
		end

		MSync.MRSync.RemoveIgnoreButton.DoClick = function()
			if not(MSync.MRSync.IgnoreTable:GetSelected()[1]:GetValue(1)==nil)then
				MSync.MRSync.IgnoreTable:RemoveLine(MSync.MRSync.IgnoreTable:GetSelectedLine())
			else
				MSync.Chat(Color(255,0,0),"ERROR: No rank selected! (A3)")
			end
		end
	elseif line:GetValue(1) == "MBSync" then
		HidePanel(MSync.Modules)
		HidePanel(MSync.MySQL)
		HidePanel(MSync.MRSync)
		ShowPanel(MSync.MBSync)

		MSync.MBSync.Sync.DoClick = function()
			MSync.GetBans()
		end


		MSync.MBSync.SearchButton.DoClick = function()
			if(MSync.MBSync.SearchBox:GetText()=="")then
				AddBanTable()
			else
				SearchBanTable(MSync.MBSync.SearchBox:GetText())
			end
		end

		MSync.MBSync.Table.OnRowRightClick = function( self, LineID, line )
			local menu = DermaMenu()
			menu:SetSkin(xgui.settings.skin)
			--[[menu:AddOption( "Edit ban...", function()
				if not line:IsValid() then return end
				xgui.ShowBanWindow( nil, line:GetValue( 5 ), nil, true, xgui.data.bans.cache[LineID] )
			end )--]]
			menu:AddOption( "Remove", function()
				if not line:IsValid() then return end
				MSync.BanTableUnban(MSync.MBSync.Table:GetSelected()[1]:GetValue(1))

				MSync.MBSync.Table:RemoveLine(MSync.MBSync.Table:GetSelectedLine())
			end )
			menu:Open()
		end
	elseif line:GetValue(1) == "Modules" then
		HidePanel(MSync.MySQL)
		HidePanel(MSync.MRSync)
		HidePanel(MSync.MBSync)
		ShowPanel(MSync.Modules)
		MSync.Modules.enabledModulesList:Clear()
		MSync.Modules.disabledModulesList:Clear()
		AddTable(MSync.LocalSettings.EnabledModules,MSync.Modules.enabledModulesList)
		AddTable(MSync.LocalSettings.DisabledModules,MSync.Modules.disabledModulesList)

		MSync.Modules.enable.DoClick = function()
			if not(MSync.Modules.disabledModulesList:GetSelected()[1]:GetValue(1)==nil)then
				MSync.Modules.enabledModulesList:AddLine( MSync.Modules.disabledModulesList:GetSelected()[1]:GetValue(1))
				MSync.Modules.disabledModulesList:RemoveLine(MSync.Modules.disabledModulesList:GetSelectedLine())
			else
				print("[MSync] ERROR: No line selected! (A3)")
			end
		end

		MSync.Modules.disable.DoClick = function()
			if not(MSync.Modules.enabledModulesList:GetSelected()[1]:GetValue(1)==nil)then
				MSync.Modules.disabledModulesList:AddLine( MSync.Modules.enabledModulesList:GetSelected()[1]:GetValue(1))
				MSync.Modules.enabledModulesList:RemoveLine(MSync.Modules.enabledModulesList:GetSelectedLine())
			else
				MSync.Chat(Color(255,0,0),"ERROR: No line selected! (A3)")
			end
		end

	end
end

MSync.savebutton.DoClick = function()
	if not(MSync.settingList:GetSelectedLine()==nil)then
		if(MSync.settingList:GetSelected()[1]:GetValue(1)=="MySQL")then
			MSync.LocalSettings.mysql ={
				Host = MSync.MySQL.Host:GetText(),
				Port = tonumber(MSync.MySQL.Port:GetText()),
				Database = MSync.MySQL.Database:GetText(),
				Username = MSync.MySQL.Username:GetText(),
				Password = MSync.MySQL.Password:GetText()
			}
			MSync.LocalSettings.Servergroup = MSync.MySQL.Servergrp:GetText()
			MSync.SendSettings()
		elseif(MSync.settingList:GetSelected()[1]:GetValue(1)=="MRSync")then
			MSync.LocalSettings.mrsync.AllServerRanks = {}
			MSync.LocalSettings.mrsync.IgnoredRanks = {}

			for k, line in pairs( MSync.MRSync.IgnoreTable:GetLines()) do
				if not(table.HasValue(MSync.LocalSettings.mrsync.IgnoredRanks,line:GetValue( 1 )))then
					table.insert(MSync.LocalSettings.mrsync.IgnoredRanks, line:GetValue( 1 ))
				end
			end
			for k, line in pairs( MSync.MRSync.AllServerTable:GetLines())  do
				if not(table.HasValue(MSync.LocalSettings.mrsync.AllServerRanks,line:GetValue( 1 )))then
					table.insert(MSync.LocalSettings.mrsync.AllServerRanks, line:GetValue( 1 ))
				end
			end
			MSync.SendSettings()
		elseif(MSync.settingList:GetSelected()[1]:GetValue(1)=="MBSync")then

			MSync.SendSettings()
		elseif(MSync.settingList:GetSelected()[1]:GetValue(1)=="Modules")then
			MSync.LocalSettings.EnabledModules = {}
			MSync.LocalSettings.DisabledModules = {}

			for k, line in pairs( MSync.Modules.enabledModulesList:GetLines())  do
				if not(table.HasValue(MSync.LocalSettings.EnabledModules,line:GetValue( 1 )))then
					table.insert(MSync.LocalSettings.EnabledModules, line:GetValue( 1 ))
				end
			end
			for k, line in pairs( MSync.Modules.disabledModulesList:GetLines())  do
				if not(table.HasValue(MSync.LocalSettings.DisabledModules,line:GetValue( 1 )))then
					table.insert(MSync.LocalSettings.DisabledModules, line:GetValue( 1 ))
				end
			end
			MSync.SendSettings()
		end
	else
		MSync.SendSettings()
		MSync.Chat(Color(255,0,0),"No option selected! (A3)")
	end
end

MSync.resetbutton.DoClick = function()
	MSync.LocalSettings = {
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
		}
	}
	MSync.RefreshPanel()
	MSync.Chat(Color(255,128,64),"Reset settings (A1)")
end

MSync.refreshbutton.DoClick = function()
	MSync.GetSettings()
	MSync.Chat(Color(255,128,64),"Refreshing XGUI")
end


--[[MSync.Modules.enable.DoClick = function()
	MSync.Modules.enabledModulesList:AddLine( MSync.Modules.disabledModulesList:GetSelectedLine():GetValue(1) )
	MSync.Modules.disabledModulesList:RemoveLine(MSync.Modules.disabledModulesList:GetSelectedLine())
end

MSync.Modules.disable.DoClick = function()
	MSync.Modules.disabledModulesList:AddLine( MSync.Modules.enabledModulesList:GetSelectedLine():GetValue(1) )
	MSync.Modules.enabledModulesList:RemoveLine(MSync.Modules.disabledModulesList:GetSelectedLine())
end
]]--

xgui.addSettingModule( "MSync", MSync.back, "icon16/shield.png" )
