if CLIENT or file.Exists("igs/launcher.lua","LUA") then return end

local function notif(pl,text)
	if IsValid(pl) then
		pl:ChatPrint(text)
	end
end

local function openURL(pl,url)
	if IsValid(pl) then
		pl:SendLua([[gui.OpenURL("]] .. url .. [[")]])
	end
end

hook.Add("PlayerInitialSpawn","IGSFail",function(pl)
	timer.Simple(10,function()
		timer.Create("IGSFail",1,60,function()
			notif(pl,"[IGS] Для работы автодоната нужно установить сам АВТОДОНАТ (gm-donate.ru/instructions)")
		end)

		timer.Simple(5,function()
			openURL(pl,"https://gm-donate.ru/instructions")
		end)
	end)
end)
