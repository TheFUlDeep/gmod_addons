--[[============================= РЕДИРЕКТ ==========================]]
if SERVER then
	local WebServerUrl = "http://metronorank.ddns.net/sync/"
	
	local outputTBL = {}
	local function GetFromWebServer(url,typ)
		http.Fetch( 
		url.."?typ="..typ,
		function (body)
			outputTBL[typ] = {}
			if body then
				outputTBL[typ] = util.JSONToTable(body)
			end
		end,
		function()
			outputTBL[typ] = {}
		end
		)
		local tbl2 = {}
		if not outputTBL[typ] or not istable(outputTBL[typ]) then return {} end
		for k,v in pairs(outputTBL[typ]) do
			if not v.MainTable then continue end
			table.insert(tbl2,1,v.MainTable)
		end
		return tbl2
	end	
	
	function ulx.redirect(ply)
		local PlayerCount = GetFromWebServer(WebServerUrl,"PlayerCount")
		if not PlayerCount then return end
		for k,v in pairs(PlayerCount) do
			if not v.ip or not v.count or not v.maxx or v.password then continue end
			if v.ip:find("0.0.0.0") then continue end
			if v.ip ~= game.GetIPAddress() and v.count < v.maxx then 
				ply:SendLua([[LocalPlayer():ConCommand('connect ]]..tostring(v.ip)..[[')]])
				ulx.fancyLogAdmin(ply, true, "#A был перенаправлен на другой сервер")
				break
			end
		end
		--print(GetHostName())
		--print(redirectip)
	end
	
end
local redirect = ulx.command( "Utility", "ulx redirect", ulx.redirect, "!redirect", true)
redirect:defaultAccess( ULib.ACCESS_ALL )
redirect:help( "Перейти на другой сервер" )