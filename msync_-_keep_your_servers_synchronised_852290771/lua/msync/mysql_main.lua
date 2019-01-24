-- Script Made by: Aperture-Hosting, edited by Princess Celestia
-- Web: www.Aperture-Hosting.de
-- Contact: webmaster@aperture-hosting.de

if(file.Exists( "bin/gmsv_mysqloo_linux.dll", "LUA" ) or file.Exists( "bin/gmsv_mysqloo_win32.dll", "LUA" ))then
	MSync = MSync or {}
	-- TODO move this into some shared config file or somewhere
	MSync.TableNameBans = "mbsync"
	MSync.TableNameRanks = "mrsync"
	local ulxsql = ulxsql or {}
	local ULXDB = ULXDB or {}

	function MSync.Connect()
		require("mysqloo")
		MSync.DB = mysqloo.connect(MSync.Settings.mysql.Host, MSync.Settings.mysql.Username, MSync.Settings.mysql.Password, MSync.Settings.mysql.Database, MSync.Settings.mysql.Port)
		MSync.DB.onConnected = MSync.checkTables
		MSync.DB.onConnectionFailed = MSync.DBError
		MSync.DB:connect()
	end

	function MSync.DBError()
		Msg("[MSync] Connection to database failed\n")
	end

	-- TODO find usages and replace them with query:hasMoreResults()
	function checkQuery(query)
		local playerInfo = query:getData()
		return playerInfo[1] ~= nil
	end

	function MSync.checkTables(server)
		print("[MSync] Connected to database")
		print("[MSync] Checking database")
		
		--Create Version Table if not Exists
		local MSync_Version_Table_create = server:query([[CREATE TABLE IF NOT EXISTS `msync_db_version` (`version` float NOT NULL)]])
		MSync_Version_Table_create.onError = function(Q,E) print("Q1") print(E) end
		--If query was successfull we call the rest
		MSync_Version_Table_create.onSuccess = function(data)
			
			--Get the Version Table
			local MSync_Version_Table  = server:query([[
				SELECT * FROM `msync_db_version`
			]])
			MSync_Version_Table.onError = function(Q,E) print("Q1") print(E) end
			MSync_Version_Table.onSuccess = function(data)
-------------------------------------------------------------------------------------------------------------------------------------------------------
				--Alter MSync DBVersion
				if (MSync.Settings.DBVersion == nil or MSync.Settings.DBVersion < 1.5) then			-- or MSync.Settings.DBVersion == nil ???????????????????
					local MSync_Version_Table  = server:query([[
							DELETE FROM `msync_db_version`;
							ALTER TABLE `msync_db_version`
								ADD version_index varchar(30) NOT NULL,
								ADD UNIQUE INDEX `unq_index` (`version_index` ASC);
						]])
					MSync_Version_Table.onError = function(Q,E) print("Q1") print(E) end
					MSync_Version_Table:start()
					
					MSync.Settings.DBVersion = MSync.DBVersion
					MSync.Settings.RDBVersion = MSync.Settings.RDBVersion or 0
					MSync.Settings.BDBVersion = MSync.Settings.BDBVersion or 0
				end
-------------------------------------------------------------------------------------------------------------------------------------------------------
				--Check if the query returned data and if so we set our local variables
				if MSync_Version_Table:getData()~=nil then
					local version_tbl = MSync_Version_Table:getData()
					
					for k,v in pairs(version_tbl) do
						MSync.Settings[(v.version_index)] = v.version
						print("[MSync] Version "..v.version_index..": "..v.version)
					end
				end
				

				local transaction = server:createTransaction()

				if(table.HasValue(MSync.Settings.EnabledModules, "MRSync")) then
				-------------------------------------------------------------------------------------------------------------------------
					if (MSync.Settings.RDBVersion < 1.0) then
						local MRSyncCT  = server:query([[
							CREATE TABLE IF NOT EXISTS `]] .. MSync.TableNameRanks .. [[` (
								`steamid` varchar(20) NOT NULL,
								`groups` varchar(30) NOT NULL,
								`servergroup` varchar(30) NOT NULL
							)
						]])
						transaction:addQuery(MRSyncCT)
					end
-------------------------------------------------------------------------------------------------------------------------					
					if(MSync.Settings.RDBVersion < 1.1)then
						local MRSyncUpdateDB  = server:query([[
							ALTER TABLE `]]..MSync.TableNameRanks..[[` 
							ADD UNIQUE INDEX `unq_user` (`steamid` ASC, `servergroup` ASC)
						]])
						transaction:addQuery(MRSyncUpdateDB)
						print("[MRSync] Going to update DB structure to v1.1")
						MSync.Settings.RDBVersion = MSync.RDBVersion
					end
				end
				

				if(table.HasValue(MSync.Settings.EnabledModules, "MBSync")) then

					if (MSync.Settings.BDBVersion < 1.0) then
						local MBSyncCT  = server:query([[
							CREATE TABLE IF NOT EXISTS `]] .. MSync.TableNameBans .. [[` (
								`steamid` varchar(20) NOT NULL,
								`nickname` varchar(30) NOT NULL,
								`admin` varchar(30) NOT NULL,
								`reason` varchar(30) NOT NULL,
								`ban_date` INT NOT NULL,
								`duration` INT NOT NULL,
								UNIQUE KEY `steamid_UNIQUE` (`steamid`)
							)
						]])
						transaction:addQuery(MBSyncCT)
						--print("[MBSync] Going to update DB structure to v1.0")
					end
					

					if (MSync.Settings.BDBVersion < 1.1) then
						-- Add `admin_sid` column if it doesn't already exist.
						local column = 'admin_sid'
						local updateQuery = server:query([[
							SET @preparedStatement = IF(
								(SELECT COUNT(*)
									FROM INFORMATION_SCHEMA.COLUMNS
									WHERE table_name = ']] .. MSync.TableNameBans .. [['
									AND table_schema = DATABASE()
									AND column_name = ']] .. column .. [['
								) > 0,
								'SELECT 1;',
								'ALTER TABLE `]] .. MSync.TableNameBans .. [[` ADD `]] .. column .. [[` VARCHAR(20) AFTER `nickname`;'
							);
							PREPARE alterIfNotExists FROM @preparedStatement;
							EXECUTE alterIfNotExists;
							DEALLOCATE PREPARE alterIfNotExists;
						]])
						transaction:addQuery(updateQuery)
						print("[MBSync] Going to update DB structure to v1.1")
						
					end

					if (MSync.Settings.BDBVersion < 1.2) then
						-- Rename some columns, allow NULLs, increase VARCHAR sizes and change INTs to unsigned
						local updateQuery = server:query([[
							ALTER TABLE `]] .. MSync.TableNameBans .. [[`
								CHANGE COLUMN `nickname` `name` VARCHAR(32),
								CHANGE COLUMN `admin` `staff_name` VARCHAR(32) NOT NULL,
								CHANGE COLUMN `admin_sid` `staff_steamid` VARCHAR(20),
								MODIFY `reason` VARCHAR(255) NOT NULL,
								MODIFY `ban_date` INT UNSIGNED NOT NULL,
								MODIFY `duration` INT UNSIGNED NOT NULL;
						]])
						transaction:addQuery(updateQuery)
						print("[MBSync] Going to update DB structure to v1.2")
					end

					if (MSync.Settings.BDBVersion < 1.3) then
						-- Drop the unique on `steamid`, add auto-incrementing `id` and set it as new PK
						local updateQuery = server:query([[
							ALTER TABLE `]] .. MSync.TableNameBans .. [[`
								DROP INDEX steamid_UNIQUE,
								ADD `id` INT PRIMARY KEY AUTO_INCREMENT FIRST,
								ADD INDEX steamid_INDEX (`steamid`);
						]])
						transaction:addQuery(updateQuery)
						print("[MBSync] Going to update DB structure to v1.3")
						MSync.Settings.BDBVersion = MSync.BDBVersion
					end
				end
				--[[if(table.HasValue(MSync.Settings.EnabledModules, "MPSync")) then
					//Ranks
					//Permissions
					//Rank ID and Permission ID
					//Servers
					//Server id and Permission ID
				end]]--

				-- Start the transaction, if any queries were added to it
				if transaction:getQueries() ~= nil then
					transaction.onError = function (tr, err) print("[MSync] Database creation/update failed: " .. err) end
					transaction.onSuccess = function ()
						MSync.SaveSettings()
						print("[MSync] Database upgrade successful, current DB schema version " .. MSync.DBVersion)
					end
					transaction:start()
				end
				
				local MSync_Version_Table  = server:query([[
					INSERT into `msync_db_version` (`version`,`version_index`) VALUES (']]..MSync.Settings.DBVersion..[[','DBVersion') ON DUPLICATE KEY UPDATE version=VALUES(version);
					INSERT into `msync_db_version` (`version`,`version_index`) VALUES (']]..MSync.Settings.RDBVersion..[[','RDBVersion') ON DUPLICATE KEY UPDATE version=VALUES(version);
					INSERT into `msync_db_version` (`version`,`version_index`) VALUES (']]..MSync.Settings.BDBVersion..[[','BDBVersion') ON DUPLICATE KEY UPDATE version=VALUES(version)
				]])
				MSync_Version_Table.onError = function(Q,E) print("Q1") print(E) end
				MSync_Version_Table:start()
				--MSync_Version_Table:wait()
			end
			MSync_Version_Table:start()
		end
		MSync_Version_Table_create:start()
	end

	MSync.Connect()

	include( "msync/mrsync_sql.lua" )
	include( "msync/mbsync_sql.lua" )
	include( "msync/mbsync_chat.lua" )
	include( "msync/msync_hooks.lua" )

else
	print('[MSync] WARNING! You need MySQLoo v9 or higher for this addon to work!')
	print('[MSync] Get it from here: https://facepunch.com/showthread.php?t=1515853')
	print('[MSync] Here are installation instructions:')
	print('[MSync] https://help.serenityservers.net/index.php?title=Garrysmod:How_to_install_mysqloo_or_tmysql')
end
