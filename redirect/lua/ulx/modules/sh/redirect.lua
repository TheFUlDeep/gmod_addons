--[[============================= РЕДИРЕКТ ==========================]]
if SERVER then
	local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/metrostroi/sync/"
	
	local function GetFromWebServer(url,typ,ply)
		http.Fetch( 
		url.."?typ="..typ,
		function (body)
			local outputTBL = {}
			if body then
				outputTBL = util.JSONToTable(body)
			end
			if not outputTBL then return end
			local tbl2 = {}
			for k,v in pairs(outputTBL) do
				if not v.MainTable then continue end
				table.insert(tbl2,1,v.MainTable)
			end
			if not tbl2 then return end
			for k,v in pairs(tbl2) do
				if not v.ip or not v.count or not v.maxx or v.password then continue end
				if v.ip:find("0.0.0.0") then continue end
				if v.ip ~= game.GetIPAddress() and v.count < v.maxx then 
					ply:SendLua([[LocalPlayer():ConCommand('connect ]]..tostring(v.ip)..[[')]])
					ulx.fancyLogAdmin(ply, true, "#A был перенаправлен на другой сервер")
					break
				end
			end
		end
		)
	end	
	
	function ulx.redirect(ply)
		GetFromWebServer(WebServerUrl,"PlayerCount",ply)
		--print(GetHostName())
		--print(redirectip)
	end
	
end
local redirect = ulx.command( "Utility", "ulx redirect", ulx.redirect, "!redirect", true)
redirect:defaultAccess( ULib.ACCESS_ALL )
redirect:help( "Перейти на другой сервер" )