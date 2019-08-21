if SERVER then
	util.AddNetworkString("tfd_SendLua")
	
	if not THEFULDEEP then THEFULDEEP = {} end
	
	THEFULDEEP.SendLua = function(str,ply)
		net.Start("tfd_SendLua")
			local data = util.Compress(str)
			local dataN = #data
			net.WriteUInt(dataN,32)
			net.WriteData(data, dataN)
		if ply then net.Send(ply) else net.Broadcast() end
	end
	
end
if SERVER then return end

net.Receive( "tfd_SendLua", function()
	local N = net.ReadUInt(32)
	local data = util.Decompress(net.ReadData(N))
	RunString( data, "tfd_SendLua", true )
end)