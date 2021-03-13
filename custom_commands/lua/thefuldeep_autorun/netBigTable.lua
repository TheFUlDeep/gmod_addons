local networkStringName = "bigtables"
BigNetTables = BigNetTables or {}

if CLIENT then	
	net.Receive(networkStringName, function()
		local tableid = net.ReadUInt(32)
		local tablepart = net.ReadUInt(32)
		local isLastPart = net.ReadBool()
		local dataLen = net.ReadUInt(32)
		local data = net.ReadData(dataLen)		
		BigNetTables[tableid] = BigNetTables[tableid] or {}
		BigNetTables[tableid].partscount = BigNetTables[tableid].partscount and BigNetTables[tableid].partscount + 1 or 1
		if isLastPart then
			BigNetTables[tableid].lastpart = tablepart
		end
		BigNetTables[tableid][tablepart] = data
		if BigNetTables[tableid].lastpart and BigNetTables[tableid].partscount == BigNetTables[tableid].lastpart then
			local json = ""
			for i = 1, BigNetTables[tableid].lastpart do
				json = json .. BigNetTables[tableid][i]
			end
			BigNetTables[tableid] = nil --для очистки памяти
			hook.Run("BigNetTablesReceive",util.JSONToTable(util.Decompress(json)))
		end
	end)
end
if CLIENT then return end


BigNetTables.SendedTables = BigNetTables.SendedTables or 0
local empty_table = {}
local maxsize = 60000
util.AddNetworkString(networkStringName)
function SendBigNetTable(tbl,ply)
	if BigNetTables.SendedTables == 4294967295 then BigNetTables.SendedTables = 0 end--потому что это максимальное число, которое можно в 32 бита
	BigNetTables.SendedTables = BigNetTables.SendedTables + 1
	local IsValidPly = IsValid(ply)
	local tbl = util.Compress(util.TableToJSON(tbl or empty_table))
	local sendscount = #tbl / maxsize
	local floor = math.floor(sendscount)
	if floor ~= sendscount then sendscount = floor + 1 end

	for i = 1, sendscount do
		local str = tbl:sub(maxsize*(i-1) + 1, maxsize*i)
		net.Start(networkStringName)
			net.WriteUInt(BigNetTables.SendedTables,32)
			net.WriteUInt(i,32)
			net.WriteBool(i == sendscount)
			net.WriteUInt(#str,32)
			net.WriteData(str)
		if IsValidPly then net.Send(ply) else net.Broadcast() end
	end
end

