if(table.HasValue(MSync.Settings.EnabledModules, "MRSync")) then
	print("[MRSync] Loading...")
	local serverGroup = serverGroup or MSync.Settings.Servergroup
	-- Function to load a Players Rank
	function MSync.LoadRank(ply)
		print("[MRSync] Loading player rank...")
		local queryQ = MSync.DB:query([[SELECT * FROM `]]..MSync.TableNameRanks..[[` WHERE steamid = ']] .. ply:SteamID64() .. [[' AND (`servergroup` = ']] .. MSync.Settings.Servergroup .. [[' OR `servergroup` = 'allserver')]])
		queryQ.onData = function(Q,D)
			queryQ.onSuccess = function(q)
				if checkQuery(q) then
					print("[MRSync] "..ply:GetName().." Status: "..tostring(ply:IsUserGroup(D.groups)))

					if( ply:IsUserGroup(D.groups)) then

						print("[MRSync] User "..ply:GetName().." is already in their group!")
					else
						--ply:SetUserGroup( D.groups )
						ULib.ucl.addUser( ply:SteamID(),nil,nil,D.groups)
						print("[MRSync] Adding "..ply:GetName().." to group "..D.groups)
						--MSync.PrintToAll(Color(255,255,255),"Adding "..ply:GetName().." to group "..D.groups)
					end
				end
			end
		end
		queryQ.onError = function(Q,E) print("Q1") print(E) end
		queryQ:start()

	end
	-- Function to save a Single user
	function MSync.SaveRank(SteamID64, rank)
		print("[MRSync] Saving player rank...")
		local plyTable = {
			steamid = SteamID64,
			rank = rank,
			--name = ply:GetName()
		}
		
		local transaction = MSync.DB:createTransaction()
		
		if(table.HasValue(MSync.Settings.mrsync.AllServerRanks,plyTable.rank))then
		
			serverGroup = "allserver"
			
			local preventDoubleEntrys  = MSync.DB:query([[DELETE FROM `]]..MSync.TableNameRanks..[[` WHERE steamid=']]..plyTable.steamid..[[' and not servergroup='allserver']])
			transaction:addQuery(preventDoubleEntrys)
				
		else
		
			serverGroup = MSync.Settings.Servergroup
			
			local preventDoubleEntrys  = MSync.DB:query([[DELETE FROM `]]..MSync.TableNameRanks..[[` WHERE steamid=']]..plyTable.steamid..[[' and servergroup='allserver']])
			transaction:addQuery(preventDoubleEntrys)
			
		end

		if not(table.HasValue(MSync.Settings.mrsync.IgnoredRanks,plyTable.rank)) then

			local InsertQ = MSync.DB:query([[INSERT into `]]..MSync.TableNameRanks..[[` 
				(`steamid`, `groups`, `servergroup`) 
				VALUES (']]..plyTable.steamid..[[', ']]..MSync.DB:escape(plyTable.rank)..[[',']]..MSync.DB:escape(serverGroup)..[[') 
				ON DUPLICATE KEY UPDATE groups=VALUES(groups)]]
			)
			transaction:addQuery(InsertQ)
			
			transaction.onError = function (tr, err) print("[MRSync] User creation/update failed: " .. err) end
			transaction.onSuccess = function ()
				print ("[MRSync] User "..plyTable.steamid.." got saved")
			end
			transaction:start()
			
		end

	end
	-- Function to save all users
	function MSync.SaveAllRanks()
		print("[MRSync] Saving player ranks...")
		local plyTable = player.GetAll()
		
		for k,v in pairs(plyTable) do
			
			local transaction = MSync.DB:createTransaction()
			
			if(table.HasValue(MSync.Settings.mrsync.AllServerRanks,v:GetUserGroup()))then
				serverGroup = "allserver"
				
				local preventDoubleEntrys  = MSync.DB:query([[DELETE FROM `]]..MSync.TableNameRanks..[[` WHERE steamid=']]..v:SteamID64()..[[' and not servergroup='allserver']])
				transaction:addQuery(preventDoubleEntrys)
				
			else
				serverGroup = MSync.Settings.Servergroup
				
				local preventDoubleEntrys  = MSync.DB:query([[DELETE FROM `]]..MSync.TableNameRanks..[[` WHERE steamid=']]..v:SteamID64()..[[' and servergroup='allserver']])
				transaction:addQuery(preventDoubleEntrys)
				
			end

			if not(table.HasValue(MSync.Settings.mrsync.IgnoredRanks,plyTable.rank)) then

				local InsertQ = MSync.DB:query([[INSERT into `]]..MSync.TableNameRanks..[[` 
					(`steamid`, `groups`, `servergroup`) 
					VALUES (']]..v:SteamID64()..[[', ']]..MSync.DB:escape(v:GetUserGroup())..[[',']]..MSync.DB:escape(serverGroup)..[[') 
					ON DUPLICATE KEY UPDATE groups=VALUES(groups)]]
				)
				transaction:addQuery(InsertQ)
			
				transaction.onError = function (tr, err) print("[MRSync] User creation/update failed: " .. err) end
				transaction.onSuccess = function ()
					print ("[MRSync] User "..v:GetName().." got saved")
				end
				transaction:start()
				
			end
		end

	end
	print("[MRSync] Loading completed")

end
