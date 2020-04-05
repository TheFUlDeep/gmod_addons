if CLIENT then
	net.Receive( "tfd_play_url", function()
		local tbl = net.ReadTable()
		sound.PlayURL(tbl.url, tbl.flags, function(asd)
			if not IsValid(asd) then return end
			if tbl.pos then asd:SetPos(tbl.pos) end
			asd:SetVolume(tbl.volume)
			asd:Set3DFadeDistance(tbl.dist, 1000000000)
		end)
	end)

end
if CLIENT then return end


util.AddNetworkString("tfd_play_url")
function tfd_play_url(url,flags,pos,volume,dist)
	local tbl = {
		url = url,
		flags = flags or "3d",
		pos = pos,
		volume = volume or 1,
		dist = dist or 1500
	}
	net.Start("tfd_play_url")
	net.WriteTable(tbl)
	net.Broadcast()
end