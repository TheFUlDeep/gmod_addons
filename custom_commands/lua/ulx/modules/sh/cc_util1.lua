if not THEFULDEEP then THEFULDEEP = {} end
local TrackIDsPaths = {}
local NoSignals = true


if SERVER then
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		if IsValid(v) then NoSignals = false break end
	end

	function ulx.reloadsignals(calling_ply)
		RunConsoleCommand("metrostroi_load")
		ulx.fancyLogAdmin(calling_ply, "[SERVER] #A ПЕРЕЗАГРУЗИЛ СИГНАЛКУ")
	end
end
local reloadsignals = ulx.command("Metrostroi", "ulx reloadsignals", ulx.reloadsignals, "!reloadsignals", true, false, true)
reloadsignals:defaultAccess(ULib.ACCESS_SUPERADMIN)
reloadsignals:help("Перезагружает сигналку")

if SERVER then
	function ulx.savesignals(calling_ply)
		RunConsoleCommand("metrostroi_save")
		ulx.fancyLogAdmin(calling_ply, "[SERVER] #A СОХРАНИЛ СИГНАЛКУ")
	end
end
local savesignals = ulx.command("Metrostroi", "ulx savesignals", ulx.savesignals, "!savesignals", true, false, true)
savesignals:defaultAccess(ULib.ACCESS_SUPERADMIN)
savesignals:help("Сохраняет сигналку")

if SERVER then
	function ulx.restart_server(calling_ply)	
		local i = 0
		for i = 0, 60 do
			timer.Simple(i, function()		
				ulx.fancyLog(false, "Рестарт через #i seconds", 60 - i)
				--ULib.tsay(nil, "Рестарт через " .. math.Round(60 - i) .. " секунд(у)" , true)
				if i == 60 then
					for k,v in pairs(player.GetAll()) do
						v:ConCommand("retry")
					end
					timer.Simple(0.1, function() RunConsoleCommand("_restart") end)
				end
			end)
		end
	end
end
local restart_server = ulx.command("Utility", "ulx restart_server", ulx.restart_server, "!restart_server", true, false, true)
restart_server:defaultAccess(ULib.ACCESS_SUPERADMIN)
restart_server:help("ВЫРУБАЕТ СЕРВЕР НАХООООООООООЙ (перезапускает)")
	
if SERVER then
	function ulx.discord(calling_ply)
		local discord = "https://discord.gg/wZp4EzT"
		--local ply = tostring(calling_ply:Nick())
		ulx.fancyLogAdmin(calling_ply, false, "#A, вот ссылка на наш дискорд: #s", discord)
		--ULib.tsayColor(nil, true, discord, Color(255,255,255,255))
		--ULib.tsay(nil, "Наш дискорд: https://discord.gg/p4mJVKr", true)
	end
end
local discord = ulx.command("Menus", "ulx discord", ulx.discord, "!discord")
discord:defaultAccess(ULib.ACCESS_ALL)
discord:help("Показать в чате ссылку на дискорд")

--[[	local function ulx.discotdgui()
	gui.OpenURL(https://discord.gg/p4mJVKr)
	end	
	local discordgui = ulx.command("Menus", "ulx discordgui", ulx.discordgui, "!discordgui")
	discordgui:defaultAccess(ULib.ACCESS_SUPERADMIN)
	discordgui:help("открыть дискорд")]]
if SERVER then
	function ulx.updateulx(calling_ply)
		ULib.ucl.addUser(calling_ply:SteamID(),nil,nil, calling_ply:GetUserGroup())
		ulx.fancyLogAdmin(calling_ply, true, "#A обновил ulx")
	end
end
local updateulx = ulx.command("Utility", "ulx updateulx", ulx.updateulx, "!updateulx", true, false, true)
updateulx:defaultAccess(ULib.ACCESS_SUPERADMIN)
updateulx:help("Обновляет меню (не нужно обычным игрокам)")



-------------------------	DISPATHER SCRIPT  -----------------------------------------
if SERVER then
	Metrostroi.ActiveDispatcher,Metrostroi.ActiveInt,Metrostroi.ActiveDSCP1,Metrostroi.ActiveDSCP2,Metrostroi.ActiveDSCP3,Metrostroi.ActiveDSCP4,Metrostroi.ActiveDSCP5 = nil,0,nil,nil,nil,nil,nil
	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 1)
	
	util.AddNetworkString("gmod_metrostroi_activedispatcher")
	function ulx.SendActiveDispatcher(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedispatcher")
		net.WriteString(name)
		net.Broadcast()
	end
	
	util.AddNetworkString("gmod_metrostroi_activeint")		
	function ulx.SendActiveInt(int)
		net.Start("gmod_metrostroi_activeint")
		net.WriteInt(int,11)
		net.Broadcast()
	end
	
	util.AddNetworkString("gmod_metrostroi_activedscp1")	
	function ulx.SendActiveDSCP1(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedscp1")
		net.WriteString(name)
		net.Broadcast()
	end
	
		util.AddNetworkString("gmod_metrostroi_activedscp2")		
	function ulx.SendActiveDSCP2(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedscp2")
		net.WriteString(name)
		net.Broadcast()
	end
	
	util.AddNetworkString("gmod_metrostroi_activedscp3")	
	function ulx.SendActiveDSCP3(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedscp3")
		net.WriteString(name)
		net.Broadcast()
	end
	
	util.AddNetworkString("gmod_metrostroi_activedscp4")
	function ulx.SendActiveDSCP4(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedscp4")
		net.WriteString(name)
		net.Broadcast()
	end
	
	util.AddNetworkString("gmod_metrostroi_activedscp5")
	function ulx.SendActiveDSCP5(ply)
		local name = IsValid(ply) and ply:Nick() or "отсутствует"
		net.Start("gmod_metrostroi_activedscp5")
		net.WriteString(name)
		net.Broadcast()
	end
	
	function ulx.disp(ply, target_ply)
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDispatcher) then Metrostroi.ActiveDispatcher = nil end
		if not Metrostroi.ActiveDispatcher then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДЦХ #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДЦХ #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDispatcher = target_ply
		--	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 0)
		elseif target_ply == Metrostroi.ActiveDispatcher then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДЦХ #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДЦХ #s", target_ply, os.date())	
			end
			Metrostroi.ActiveInt = 0
			Metrostroi.ActiveDispatcher = nil
		--	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 1)
		end
		ulx.SendActiveDispatcher(Metrostroi.ActiveDispatcher)
		ulx.SendActiveInt(Metrostroi.ActiveInt)
	end
	
	function ulx.setinterval(ply,int)
		if not int then return end
		if--[[ not Metrostroi.ActiveDispatcher or]] ply == Metrostroi.ActiveDispatcher then
			ulx.fancyLogAdmin(ply, false, "#A изменил интервал")	
			Metrostroi.ActiveInt = int
			ulx.SendActiveInt(int)
		else ULib.tsayError(ply, "Только диспетчер может менять интервал", true)	
		end
	end
	
	function ulx.undisp(ply)
		if Metrostroi.ActiveDispatcher == ply then
			ulx.fancyLogAdmin(ply, false, "#A освободил пост диспетчера")	
			Metrostroi.ActiveInt = 0
			Metrostroi.ActiveDispatcher = nil
			ulx.SendActiveDispatcher(nil)
			ulx.SendActiveInt(Metrostroi.ActiveInt)
		end
		if Metrostroi.ActiveDSCP1 == ply then
			Metrostroi.ActiveDSCP1 = nil
			ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
			ulx.fancyLogAdmin(ply, false, "#A освободил пост ДСЦП(1)")	
		end
		if Metrostroi.ActiveDSCP2 == ply then
			Metrostroi.ActiveDSCP2 = nil
			ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
			ulx.fancyLogAdmin(ply, false, "#A освободил пост ДСЦП(2)")
		end
		if Metrostroi.ActiveDSCP3 == ply then
			Metrostroi.ActiveDSCP3 = nil
			ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
			ulx.fancyLogAdmin(ply, false, "#A освободил пост ДСЦП(3)")
		end
		if Metrostroi.ActiveDSCP4 == ply then
			Metrostroi.ActiveDSCP4 = nil
			ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
			ulx.fancyLogAdmin(ply, false, "#A освободил пост ДСЦП(4)")
		end
		if Metrostroi.ActiveDSCP5 == ply then
			Metrostroi.ActiveDSCP5 = nil
			ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
			ulx.fancyLogAdmin(ply, false, "#A освободил пост ДСЦП(5)")
		end
	end
	
	function ulx.dscp1(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() ~= "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError(ply, "На данной карте нельзя занять этот пост", true) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP1) then Metrostroi.ActiveDSCP1 = nil end
		if not Metrostroi.ActiveDSCP1 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДСЦП(1) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДСЦП(1) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP1 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP1 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(1) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДСЦП(1) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP1 = nil
		end
		ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
	end
	
	
	function ulx.dscp2(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() ~= "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError(ply, "На данной карте нельзя занять этот пост", true) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP2) then Metrostroi.ActiveDSCP2 = nil end
		if not Metrostroi.ActiveDSCP2 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДСЦП(2) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДСЦП(2) #s", target_ply, os.date())	
			end	
			Metrostroi.ActiveDSCP2 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP2 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(2) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДСЦП(2) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP2 = nil
		end
		ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
	end	
		

	function ulx.dscp3(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError(ply, "На данной карте нельзя занять этот пост", true) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP3) then Metrostroi.ActiveDSCP3 = nil end
		if not Metrostroi.ActiveDSCP3 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДСЦП(3) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДСЦП(3) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP3 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP3 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(3) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДСЦП(3) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP3 = nil
		end
		ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
	end
		
	
	function ulx.dscp4(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError(ply, "На данной карте нельзя занять этот пост", true) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP4) then Metrostroi.ActiveDSCP4 = nil end
		if not Metrostroi.ActiveDSCP4 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДСЦП(4) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДСЦП(4) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP4 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP4 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(4) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДСЦП(4) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP4 = nil
		end
		ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
	end
	
	
	function ulx.dscp5(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError(ply, "На данной карте нельзя занять этот пост", true) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP5) then Metrostroi.ActiveDSCP5 = nil end
		if not Metrostroi.ActiveDSCP5 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A заступил на пост ДСЦП(5) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A поставил игрока #T на пост ДСЦП(5) #s", target_ply, os.date())	
			end	
			Metrostroi.ActiveDSCP5 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP5 then
			if ply == target_ply then 
				ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(5) #s", os.date())	
			else ulx.fancyLogAdmin(ply, false, "#A снял игрока #T с поста ДСЦП(5) #s", target_ply, os.date())	
			end
			Metrostroi.ActiveDSCP5 = nil
		end
		ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
	end
	
		
	hook.Add("PlayerDisconnected", "disp", function(ply)
		if ply == Metrostroi.ActiveDispatcher then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста диспетчера")	
			Metrostroi.ActiveInt = 0
		--	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 1)
			Metrostroi.ActiveDispatcher = nil
			ulx.SendActiveDispatcher(Metrostroi.ActiveDispatcher)
			ulx.SendActiveInt(Metrostroi.ActiveInt)
		end
	end)
	
	hook.Add("PlayerDisconnected", "dscp1", function(ply)
		if ply == Metrostroi.ActiveDSCP1 then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(1)")	
			Metrostroi.ActiveDSCP1 = nil
			ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
		end	
	end)
	
	hook.Add("PlayerDisconnected", "dscp2", function(ply)
		if ply == Metrostroi.ActiveDSCP2 then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(2)")	
			Metrostroi.ActiveDSCP2 = nil
			ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
		end	
	end)
	
	hook.Add("PlayerDisconnected", "dscp3", function(ply)
		if ply == Metrostroi.ActiveDSCP3 then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(3)")	
			Metrostroi.ActiveDSCP3 = nil
			ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
		end	
	end)	

	hook.Add("PlayerDisconnected", "dscp4", function(ply)
		if ply == Metrostroi.ActiveDSCP4 then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(4)")	
			Metrostroi.ActiveDSCP4 = nil
			ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
		end	
	end)
	
	hook.Add("PlayerDisconnected", "dscp5", function(ply)
		if ply == Metrostroi.ActiveDSCP5 then
			ulx.fancyLogAdmin(ply, false, "#A ушел с поста ДСЦП(5)")	
			Metrostroi.ActiveDSCP5 = nil
			ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
		end	
	end)
	
	hook.Add("PlayerInitialSpawn","DispatcherSpawn", function(ply) 
		timer.Simple(2, function()
			ulx.SendActiveDispatcher(Metrostroi.ActiveDispatcher)
			ulx.SendActiveInt(Metrostroi.ActiveInt)
			ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
			ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
			ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
			ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
			ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
		end)
	end)
	
end

if CLIENT then
	net.Receive("gmod_metrostroi_activedispatcher", function(len, ply)
		Metrostroi.ActiveDispatcher = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activeint", function(len, ply)
		Metrostroi.ActiveInt = net.ReadInt(11)	
	end)
	
	net.Receive("gmod_metrostroi_activedscp1", function(len, ply)
		Metrostroi.ActiveDSCP1 = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activedscp2", function(len, ply)
		Metrostroi.ActiveDSCP2 = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activedscp3", function(len, ply)
		Metrostroi.ActiveDSCP3 = net.ReadString()
	end)	
	
	net.Receive("gmod_metrostroi_activedscp4", function(len, ply)
		Metrostroi.ActiveDSCP4 = net.ReadString()
	end)	
	
	net.Receive("gmod_metrostroi_activedscp5", function(len, ply)
		Metrostroi.ActiveDSCP5 = net.ReadString()
	end)
	
	hook.Add("HUDPaint", "Disp Hud Paint", function()		
		local text3 = ""
		local text4 = ""
		local text5 = ""
		local text6 = ""
		local text7 = ""
		if game.GetMap() == "gm_mus_crimson_line_tox_v9_21" then 
			text3 = "ДСЦП(1) ПТО: " .. (Metrostroi.ActiveDSCP1 or "отсутствует")
			text4 = "ДСЦП(2) Аэропорт: " .. (Metrostroi.ActiveDSCP2 or "отсутствует")
			text5 = "ДСЦП(3) Метростроителей: " .. (Metrostroi.ActiveDSCP3 or "отсутствует")
			text6 = "ДСЦП(4) Каховская: " .. (Metrostroi.ActiveDSCP4 or "отсутствует")
		end
		if game.GetMap() == "gm_mus_neoorange_d" then --северная, энергетиков, селигер
			text3 = "Блок пост депо(1): " .. (Metrostroi.ActiveDSCP1 or "отсутствует")
			text4 = "ДСЦП(2) Икарус: " .. (Metrostroi.ActiveDSCP2 or "отсутствует")
			text5 = "ДСЦП(3) Аэропорт: " .. (Metrostroi.ActiveDSCP3 or "отсутствует")
			text6 = "ДСЦП(4) Парк: " .. (Metrostroi.ActiveDSCP4 or "отсутствует")
			text7 = "ДСЦП(5) Уоллеса Брина " .. (Metrostroi.ActiveDSCP5 or "отсутствует")
		end
		if game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then 
			text3 = "Блок пост депо(1): " .. (Metrostroi.ActiveDSCP1 or "отсутствует")
			text4 = "ДСЦП(2) Проспект Метростроителей: " .. (Metrostroi.ActiveDSCP2 or "отсутствует")
			text5 = "ДСЦП(3) Северная: " .. (Metrostroi.ActiveDSCP3 or "отсутствует")
			text6 = "ДСЦП(4) Проспект Энергетиков: " .. (Metrostroi.ActiveDSCP4 or "отсутствует")
			text7 = "ДСЦП(5) Селигерская роща " .. (Metrostroi.ActiveDSCP5 or "отсутствует")
		end
		local font = "ChatFont"
		local text = "ДЦХ: " .. (Metrostroi.ActiveDispatcher or "отсутствует")
		local text2 = "Интервал: " .. (Metrostroi.ActiveInt and Metrostroi.ActiveInt >= 30 and (math.floor(Metrostroi.ActiveInt/60)..":"..Format("%02d",math.fmod(Metrostroi.ActiveInt,60))) or "не выставлен")
		surface.SetFont(font)
		local Width, Height = surface.GetTextSize(text)
		local w2,h2 = surface.GetTextSize(text2)
		local w3,h3 = surface.GetTextSize(text3)
		local w4,h4 = surface.GetTextSize(text4)
		local w5,h5 = surface.GetTextSize(text5)
		local w6,h6 = surface.GetTextSize(text6)
		local w7,h7 = surface.GetTextSize(text7)
		draw.RoundedBox(6, ScrW() - math.Max(Width,w2) - 28, (ScrH()/2 - 200) - 10, math.Max(Width,w2) + 20, Height + h2 + 6  , Color(0, 0, 0, 150))
		draw.SimpleText(text, font, ScrW() - (Width / 2) - 20, ScrH()/2 - 200, Color(255, 255, 255, 255), 1, 1)
		draw.SimpleText(text2, font, ScrW() - (w2 / 2) - 20, ScrH()/2 - 200 + Height, Color(255, 255, 255, 255), 1, 1)
		if game.GetMap() == "gm_mus_crimson_line_tox_v9_21" then 
			draw.RoundedBox(6, ScrW() - math.Max(w3,w4,w5,w6) - 28, (ScrH()/2 - 170) - 13 + Height + h2, math.Max(w3,w4,w5,w6) + 20, h3 + h4 + h5 + h6 --[[+ h6]] + 11, Color(0, 0, 0, 150))
			draw.SimpleText(text3, font, ScrW() - (w3 / 2) - 20, ScrH()/2 - 170 + Height + h2, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text4, font, ScrW() - (w4 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text5, font, ScrW() - (w5 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3 + h4, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text6, font, ScrW() - (w6 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3 + h4 + h5, Color(255, 255, 255, 255), 1, 1)
		end
		if game.GetMap() == "gm_mus_neoorange_d" or game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then 
			draw.RoundedBox(6, ScrW() - math.Max(w3,w4,w5,w6,w7) - 28, (ScrH()/2 - 170) - 13 + Height + h2, math.Max(w3,w4,w5,w6,w7) + 20, h3 + h4 + h5 + h6 + h7 --[[+ h6]] + 11, Color(0, 0, 0, 150))
			draw.SimpleText(text3, font, ScrW() - (w3 / 2) - 20, ScrH()/2 - 170 + Height + h2, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text4, font, ScrW() - (w4 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text5, font, ScrW() - (w5 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3 + h4, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text6, font, ScrW() - (w6 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3 + h4 + h5, Color(255, 255, 255, 255), 1, 1)
			draw.SimpleText(text7, font, ScrW() - (w7 / 2) - 20, ScrH()/2 - 170 + Height + h2 + h3 + h4 + h5 + h6, Color(255, 255, 255, 255), 1, 1)
		end
	end)
end
local disp = ulx.command("Metrostroi", "ulx disp", ulx.disp, "!disp",true)
disp:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
disp:defaultAccess(ULib.ACCESS_OPERATOR)
disp:help("Занять/освободить пост диспетчера.")	
		
local setinterval = ulx.command("Metrostroi", "ulx setinterval", ulx.setinterval, "!setinterval",true)
setinterval:defaultAccess(ULib.ACCESS_ALL)
setinterval:help("Выставляет интервал(в секундах).")
setinterval:addParam{ type=ULib.cmds.NumArg,min=29,max=600,default=30,hint="Интервал",ULib.cmds.optional}

local undisp = ulx.command("Metrostroi", "ulx undisp", ulx.undisp, "!undisp",true)
undisp:defaultAccess(ULib.ACCESS_ALL)
undisp:help("Уйти с занятых постов.")

if game.GetMap() == "gm_mus_neoorange_d" or game.GetMap() == "gm_mus_crimson_line_tox_v9_21" or game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then
local dscp1 = ulx.command("Metrostroi", "ulx dscp1", ulx.dscp1, "!dscp1",true )
dscp1:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp1:defaultAccess(ULib.ACCESS_OPERATOR)
dscp1:help("Занять/освободить пост ДСЦП(1).")

local dscp2 = ulx.command("Metrostroi", "ulx dscp2", ulx.dscp2, "!dscp2",true )
dscp2:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp2:defaultAccess(ULib.ACCESS_OPERATOR)
dscp2:help("Занять/освободить пост ДСЦП(2).")

local dscp3 = ulx.command("Metrostroi", "ulx dscp3", ulx.dscp3, "!dscp3",true )
dscp3:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp3:defaultAccess(ULib.ACCESS_OPERATOR)
dscp3:help("Занять/освободить пост ДСЦП(3).")

local dscp4 = ulx.command("Metrostroi", "ulx dscp4", ulx.dscp4, "!dscp4",true )
dscp4:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp4:defaultAccess(ULib.ACCESS_OPERATOR)
dscp4:help("Занять/освободить пост ДСЦП(4).")

end

if game.GetMap() == "gm_mus_neoorange_d" or game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then
local dscp5 = ulx.command("Metrostroi", "ulx dscp5", ulx.dscp5, "!dscp5",true )
dscp5:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp5:defaultAccess(ULib.ACCESS_OPERATOR)
dscp5:help("Занять/освободить пост ДСЦП(5).")

end







if SERVER then
	
	----------------------------------------ПОСАДКА ИГРОКА В СВОБОДНОЕ МЕСТО---------------------------------------------
	local seatstbl = {"DriverSeat","InstructorsSeat","ExtraSeat"}
	for i = 1,4 do
		table.insert(seatstbl,"InstructorsSeat"..i)
		table.insert(seatstbl,"ExtraSeat"..i)
	end
	function KekLolArbidol(v2,ply)
		ply:ExitVehicle()
		ply:SetMoveType(MOVETYPE_NOCLIP)
		for _,seat in pairs(seatstbl) do
			if IsValid(v2[seat]) and not IsValid(v2[seat]:GetDriver()) then timer.Simple(1,function()ply:EnterVehicle(v2[seat])end) return end
		end
		timer.Simple(1, function() ULib.tsayError(ply, "Кабина недоступна") end)
	end


--[[ ======================================= ТП К СОСТАВУ ======================================= ]]		-- return'ы добавил для псевдооптимизации
	function ulx.traintp(calling_ply,target_ply)	--TODO фикс уведомления. на некоторых составах оно некорректное
	local p = 0
	local Class = "Class"
	for k1,v1 in pairs(Metrostroi.TrainClasses) do
		for k, v in pairs(ents.FindByClass(v1)) do
			Class = v:GetClass()
			if stringfind(Class,"gmod_subway") and not stringfind(Class,"714") and v:CPPIGetOwner() == target_ply then 
				if v.KV and v.KV.ReverserPosition == 0 then
					calling_ply:ExitVehicle()
					calling_ply:SetPos(Vector(v:GetPos()))
					calling_ply:SetMoveType(MOVETYPE_NOCLIP)
					p = 1
				elseif v.KV and v.KV.ReverserPosition ~= 0 then
					KekLolArbidol(v,calling_ply)
					p = 2
					break
				elseif v.KR and v.KR.Position == 0 then
					calling_ply:ExitVehicle()
					calling_ply:SetPos(Vector(v:GetPos()))
					calling_ply:SetMoveType(MOVETYPE_NOCLIP)
					p = 1
				elseif v.KR and v.KR.Position ~= 0 then
					KekLolArbidol(v,calling_ply)
					p = 2
					break
				elseif v.KRO and v.KRO.Value == 1 then
					calling_ply:ExitVehicle()
					calling_ply:SetPos(Vector(v:GetPos()))
					calling_ply:SetMoveType(MOVETYPE_NOCLIP)
					p = 1
				elseif v.KRO and v.KRO.Value ~= 1 then
					KekLolArbidol(v,calling_ply)
					p = 2
					break
				elseif v.RV and v.RV.KROPosition == 0 then
					calling_ply:ExitVehicle()
					calling_ply:SetPos(Vector(v:GetPos()))
					calling_ply:SetMoveType(MOVETYPE_NOCLIP)
					p = 1
				elseif v.RV and v.RV.KROPosition ~= 0 then
					KekLolArbidol(v,calling_ply)
					p = 2
					break
				else 
					calling_ply:ExitVehicle()
					calling_ply:SetPos(Vector(v:GetPos()))
					calling_ply:SetMoveType(MOVETYPE_NOCLIP)
					p = 1
				end
			end
		end
	end
		if p == 0 then  
			ULib.tsayError(calling_ply, "У этого игрока нет составов")
		elseif p == 1 then
			ULib.tsayError(calling_ply, "Не удалось определить направление движения. Телепортирую к составу")
		else calling_ply:ChatPrint("Направление определено. Ищу свободные места в кабине")
		end
	end
end
local traintp = ulx.command("Metrostroi", "ulx traintp", ulx.traintp, "!traintp",true)
traintp:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
traintp:defaultAccess(ULib.ACCESS_OPERATOR)
traintp:help("Телепортироваться к составу")

if SERVER then
	local Map = game.GetMap()
	--if game.GetMap() == "gm_mus_crimson_line_tox_v9_21" or game.GetMap() == "gm_metro_crossline_c4" or game.GetMap() == "gm_mus_orange_metro_h" or game.GetMap() == "gm_smr_first_line_v2" or game.GetMap() == "gm_metrostroi_b50" then switchwaittime = 2.5 else switchwaittime = 5.5 end
	--[[ ======================================= ЗАПОМИНАЕМ, КТО ПОСЛЕДНИЙ ИСПОЛЬЗОВАЛ !sopen ======================================= ]]
	--[[hook.Add("PlayerSay", "SwitchCheck1", function(ply, text, team)
		if string.match(text, "!sopen") == "!sopen" then 
		if lastused ~= nil then ULib.tsayError(ply, "Что-то пошло не так. Попробуй еще раз") return "" end
		lastused = ply
		lastusedtime = CurTime()
		--hooksrabotal = 0
		timer.Simple(switchwaittime, function() lastused = nil end)
		--p = 0
		end
	end)]]

	--[[ ======================================= ЗАПОМИНАЕМ, КТО ПОСЛЕДНИЙ ИСПОЛЬЗОВАЛ ДВЕРИ И КНОПКИ. ЭТО НЕ РАБОТАЕТ, ЕСЛИ СТОИТ FPP PLAYERUSE1. Поэтому в core.lua добавлен такой же блок ======================================= ]]
	hook.Add("PlayerUse", "SwitchCheck2", function(ply, ent)
		if (ent:GetClass() == "prop_door_rotating" --[[and string.match(ent:GetModel(), "cross") == "cross"]])		-- этот if нужен для работы уведомления о переводе стрелок в cc_util
			or ent:GetClass() == "func_button" 
			--or ent:GetClass() == "func_door"
		then
			if ply:GetUserGroup() == "user"
				and Metrostroi.ActiveDispatcher ~= nil
				and ply ~= Metrostroi.ActiveDispatcher
				and ply ~= Metrostroi.ActiveDSCP1
				and ply ~= Metrostroi.ActiveDSCP2
				and ply ~= Metrostroi.ActiveDSCP3
				and ply ~= Metrostroi.ActiveDSCP4
				and ply ~= Metrostroi.ActiveDSCP5
				then return false 
			end
			--[[if lastused ~= nil then return false end
			lastused = ply
			lastusedtime = CurTime()
			timer.Simple(switchwaittime, function() lastused = nil end)]]
		end
	end)

	--[[ ======================================= УВЕДОМЛЕНИЕ О ПЕРЕВОДЕ СТРЕЛОК ======================================= ]]
	hook.Add("MetrostroiChangedSwitch", "MetAdminChangedSwitch", function(self,AlternateTrack)
		--hooksrabotal = 1
		if AlternateTrack then
			track = "-"
		else
			track = "+"
		end
		--[[if self.Name == "" or self.Name == nil then 
			if lastused ~= nil and (CurTime() - lastusedtime) <= switchwaittime then
				ulx.fancyLogAdmin(lastused, true, "#A перевел стрелку #s в положение #s", self.Name, track)
				else ulx.fancyLog(true, "Стрелка #s перевелась в положение: #s", self.Name, track)
			end
			else
			if lastused ~= nil and (CurTime() - lastusedtime) <= switchwaittime then 
				ulx.fancyLogAdmin(lastused, "Игрок #A перевел стрелку #s в положение #s", self.Name, track)
				else]] ulx.fancyLog("Стрелка #s перевелась в положение: #s", self.Name, track)
			--end
		--end
		--if p == 1 then lastused = nil end
		--timer.Simple(3, function () lastused = nil end)
	end)

	--------------------------------О БОЖЕ. ЭТО СВЯЗЬ МАШИНИСТ-ДИСПЕТЧЕР----------------------------------------------------------
	hook.Add("PlayerCanHearPlayersVoice", "choooooooooooo", function(listener,talker)
	if Metrostroi.ActiveDispatcher ~= nil then
	--print(Metrostroi.ActiveDispatcher) print("asdasd")
		--if listener == Metrostroi.ActiveDispatcher or talker == Metrostroi.ActiveDispatcher then return true end
		--if talker == Metrostroi.ActiveDispatcher then return true end
		local RankTalker = talker:GetUserGroup()
		local RankListener = listener:GetUserGroup()
		if 
			RankTalker ~= "user" 
			or RankListener ~= "user"
			or listener == Metrostroi.ActiveDispatcher 
			or talker == Metrostroi.ActiveDispatcher 
		then 
			return true 
		end
		--if listener:GetPos():Distance(talker:GetPos()) > 1000 then return false else return true end
		return true,true
	 end

	end)

	--[[ ======================================= УВЕДОМЛЕНИЕ О ЗАПРЕТЕ ПЕРЕВОДА СТРЕЛОК ПРИ ДЦХ (и чатсаунды) ======================================= ]]
	local SignalNamesTbl = {}
	hook.Add("PlayerSay", "SopenScloseControl", function(ply, text, team)
		if string.sub(text,1,5) == "!ср" then ply:ConCommand("ulx ch") end
		local Rank = ply:GetUserGroup()
		if  Metrostroi.ActiveDispatcher ~= nil
			--and avtooborot == 0
			and Rank == "user"
			and ply ~= Metrostroi.ActiveDispatcher
			and ply ~= Metrostroi.ActiveDSCP1
			and ply ~= Metrostroi.ActiveDSCP2
			and ply ~= Metrostroi.ActiveDSCP3
			and ply ~= Metrostroi.ActiveDSCP4
			and ply ~= Metrostroi.ActiveDSCP5 
			then
				if string.match(text, "!sopen") == "!sopen" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""--TODO это не работает через данный хук (а точнее будет работать не всегда)
				elseif string.match(text, "!sclose") == "!sclose" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match(text, "!sactiv") == "!sactiv" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match(text, "!sdeactiv") == "!sdeactiv" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match(text, "!sopps") == "!sopps" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match(text, "!sclps") == "!sclps" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return "" 
				end
		end
		if text:find("!sclose") and Rank ~= "superadmin" then	--TODO это не работает через данный хук (а точнее будет работать не всегда)
			local strsub = string.sub(text,9)
			if tonumber(strsub) then return "" end
			if tonumber(string.sub(strsub,1,-2)) then return "" end
			for k,v in pairs(SignalNamesTbl) do
				if v ~= "" and stringfind(strsub,v,true) and not stringfind(strsub,"-") then return "" end
			end
		end
	if string.match(bigrustosmall(text), "goto") ~= "goto" and string.match(bigrustosmall(text), "station") ~= "station" and string.match(bigrustosmall(text), "sopen") ~= "sopen" and ply:GetUserGroup() ~= "user" then
		--math.randomseed(os.time())
		local chatrand = math.random(1,3)
		if string.match(bigrustosmall(text), "61") == "61" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/61.mp3"))
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/61_2.mp3"))
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/61_3.mp3"))
				umsg.End()
			end
			------------------------------------
		elseif string.match(bigrustosmall(text), "22") == "22" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/22.mp3"))
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/22_2.mp3"))
				umsg.End()
			end
			---------------------------
		elseif string.match(bigrustosmall(text), "23") == "23" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/23_1.mp3"))
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/23_2.mp3"))
				umsg.End()
			end
	----------------------------------------
		elseif string.match(bigrustosmall(text), "29") == "29" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/29_1.mp3"))
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/29_2.mp3"))
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/29_3.mp3"))
				umsg.End()
			end
			----------------------------
		elseif string.match(bigrustosmall(text), "32") == "32" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/32.mp3"))
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/32_2.mp3"))
				umsg.End()
			end
			------------------------------
		elseif string.match(bigrustosmall(text), "45") == "45" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/45_1.mp3"))
			umsg.End()
			-----------------------------------
		elseif string.match(bigrustosmall(text), "57") == "57" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/57.mp3"))
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/57_2.mp3"))
				umsg.End()
			end
			---------------
		elseif string.match(bigrustosmall(text), "понял") == "понял" and string.match(bigrustosmall(text), "61") ~= "61" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/61ponyal.mp3"))
			umsg.End()
			-----------
		elseif string.match(bigrustosmall(text), "бесит") == "бесит" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/besit.mp3"))
			umsg.End()
			-------------------
		elseif string.match(bigrustosmall(text), "быстро") == "быстро" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/bistra.mp3"))
			umsg.End()
			---------------------------------
		elseif string.match(bigrustosmall(text), "впорядке") == "впорядке" or string.match(bigrustosmall(text), "машина") == "машина" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/ispravna.mp3"))
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/ispravna2.mp3"))
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/vporadke.mp3"))
				umsg.End()
			end
			----------------
		elseif string.match(bigrustosmall(text), "не отпр") == "не отпр" or string.match(bigrustosmall(text), "без кома") == "без кома" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/ne otpr.mp3"))
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/ne otpr_2.mp3"))
				umsg.End()
			end
			---------------------------
		elseif string.match(bigrustosmall(text), "не прибл") == "не прибл" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/ne pribl.mp3"))
			umsg.End()
			-------------------
		elseif string.match(bigrustosmall(text), "понял") == "понял" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/ponyal.mp3"))
			umsg.End()
		elseif string.match(bigrustosmall(text), "пскукс") == "пскукс" or string.match(bigrustosmall(text), "ПСКУКС") == "ПСКУКС" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/pskuks.mp3"))
			umsg.End()
			----------------------------------
		elseif string.match(bigrustosmall(text), "высаж") == "высаж" then
			if chatrand == 1 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/vysajivayte.mp3"))
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/vysajivayte_3.mp3"))
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start("ulib_sound")
				umsg.String(Sound("chatsounds/vysajivayte_4.mp3"))
				umsg.End()
			end
			-------------------------------
		elseif string.match(bigrustosmall(text), "привет") == "привет" or string.match(bigrustosmall(text), "здравст") == "здравст" then
			umsg.Start("ulib_sound")
			umsg.String(Sound("chatsounds/zdrabstvuyte.mp3"))
			umsg.End()
		end
	end
	end)
	
	local function FindPlatformByIndex(index)
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			if v.StationIndex == index then return v end
		end
	end
	
	local function DistanceInFlat(x,y,x2,y2)
		local Vector1 = Vector(x,y,0)
		local Vector2 = Vector(x2,y2,0)
		return Vector1:DistToSqr(Vector2)
	end
	
	local function SecondMethod(vector,arg)
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		--print("second method")
		local StationName
		local StationPos
		local NearestStation
		local MinDist
		local dist
		local defaultradius = 4000
		local wLimit = 400
		local Nearest
		for k,v in pairs(Metrostroi.StationConfigurations) do						--поиск ближайшей станции в плоскости и в ограниченной высоте
			if not v.positions or not v.positions[1] or not v.positions[1][1] then continue else StationPos = v.positions[1][1] end
			if not v.names or not v.names[1] then StationName = k else StationName = v.names[1] end
			dist = DistanceInFlat(vector.x,vector.y,StationPos.x,StationPos.y) * 2		-- почему-то длина станции считается в два раза меньше math.Distance
			local Platform = FindPlatformByIndex(k)
			if Platform then Platform = Platform.PlatformStart:Distance(Platform.PlatformEnd) ^ 2 end
			if stringfind(StationName,"депо",true) then radius = 8000 else radius = Platform or defaultradius end
			if (not MinDist or dist < MinDist) and math.abs(vector.z - StationPos.z) < wLimit then
				MinDist = dist NearestStation = StationName
				if dist > radius then Nearest = true else Nearest = false end
			end
		end
		if Nearest and not arg then Nearest = " (ближайшая в плоскости)" else Nearest = "" end
		return NearestStation and NearestStation..Nearest or ""
	end
	
	local function Okruglenie10(number)
		number = math.floor(number)
		local mod = number % 10
		if mod > 4 then
			return number + 10 - mod
		else
			return number - mod
		end
	end
	
	local function Okruglenie100(number)
		number = Okruglenie10(number)
		local mod = number % 100
		if mod > 49 then
			return number + 100 - mod
		else
			return number - mod
		end
	end
	
	function FindTrackInSquare(vector,TrackID,customraduis,customwlimit,customstep,autoscale,donotclear)		-- При большом радиусе и маленьком шаге эта функция очень тяжелая
		if customraduis and customraduis > 15000 then return nil end
		--if customwlimit and customwlimit > 1000 then return nil end		-- не знаю, нужны ли эти два условия
		--if customstep and customstep > 100 then customstep = 100 end		-- хотел добавить это, потому что при слишком большом шаге функция просто перепрыгнет трек и не найдет его
		local i,j,k
		local radius = customraduis and Okruglenie100(customraduis) or 1000
		local wLimit = customwlimit and Okruglenie100(customwlimit) or 250
		local step = customstep and Okruglenie100(customstep) or 100
		local out = {}
		local n = 0
		for i = -radius,radius,step do
			for j = -radius,radius,step do
				if not (i == 0 or j == 0 or i == j) then continue end
				for k = -wLimit,wLimit,step do
					local results = Metrostroi.GetPositionOnTrack(vector + Vector(i,j,k))
					--print(ent:GetPos() + Vector(i,j,k))
					if #results > 0 then
						if TrackID then
							if results[1]["path"]["id"] ~= TrackID then continue end
						end
						n = n + 1
						if not out[n] then out[n] = {} end
						out[n]["vector"] = Metrostroi.GetTrackPosition(results[1]["path"],results[1]["x"])
						out[n]["trakcpos"] = results[1]["x"]
						out[n]["trackid"] = results[1]["path"]["id"]
					end
				end
			end
		end
		--PrintTable(out)
		local MinDist,CurDist,Resault
		if donotclear or autoscale then
			if table.Count(out) > 1 then
				for k,v in pairs(out) do
					local MinDist1,CurDist1,MinK
					for k1,v1 in pairs(out) do
						if v1.trackid ~= v.trackid or k == k1 then continue end
						CurDist1 = v1.vector:DistToSqr(v.vector)
						if not MinDist1 or MinDist1 > CurDist1 then MinDist1 = CurDist1 MinK = k1 end
					end
					if not MinK then continue end
					for k1,v1 in pairs(out) do
						if v1.trackid ~= v.trackid then continue end
						if k1 ~= MinK then out[k1] = nil end
					end
				end
				--PrintTable(out)
			end
			if autoscale then
				if table.Count(out) < autoscale then return FindTrackInSquare(vector,TrackID or nil,radius + step,wLimit,step,autoscale) else return out end
			end
			if donotclear then return out end
		else
			if table.Count(out) < 1 then return nil end
			for k,v in pairs(out) do								-- из всех треков ищу ближайший, чтобы не зацепить те, что далеко
				CurDist = v["vector"]:DistToSqr(vector)
				if not MinDist or MinDist > CurDist then MinDist = CurDist Resault = k end
			end
			return(out[Resault])
		end
		--if out[Resault] then PrintTable(out[Resault]) end
	end
	
	local function FindNearestStation(vector)
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		local StationName,StationPos,CurDist,MinDist,NearestStationName
		for k,v in pairs(Metrostroi.StationConfigurations) do
			if not v.positions or not v.positions[1] or not v.positions[1][1] then continue else StationPos = v.positions[1][1] end
			if not v.names or not v.names[1] then StationName = k else StationName = v.names[1] end
			CurDist = vector:DistToSqr(StationPos)
			if not MinDist or MinDist > CurDist then MinDist = CurDist NearestStationName = StationName end
		end
		return NearestStationName
	end
	
	local function GetStationByIndex(index)
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		local StationName--,StationPos
		for k,v in pairs(Metrostroi.StationConfigurations) do
			--if not v.positions or not v.positions[1] or not v.positions[1][1] then continue else StationPos = v.positions[1][1] end
			if not v.names or not v.names[1] then StationName = k else StationName = v.names[1] end
			if k == index then return StationName end
		end
		return ""
	end
	
	local function CompleteTBLTrakcs(tbl)
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			local StationName = GetStationByIndex(v.StationIndex)
			if not StationName then continue end
			for k1,v1 in pairs(tbl) do
				if v1.StationName ~= StationName then continue end
				local ThisStationTracks = 0
				local MaxID = 0
				for k2,v2 in pairs(tbl) do				-- ищу количество одинаковых треков, принадлежащих к одной танции
					if v2.trackid == v1.trackid and v1.StationName == v2.StationName then 
						ThisStationTracks = ThisStationTracks + 1 
						if MaxID < v2.trackid then MaxID = v2.trackid end
					end
				end
				if ThisStationTracks < 1 then continue end
				for i = 1,MaxID do 				--для каждого трека ищу ближайший
					local CurDist,MinDist,MinK
					for k2,v2 in pairs(tbl) do
						if v2.trackid ~= i or v2.StationName ~= v1.StationName then continue end
						CurDist = v2.vector:DistToSqr(v:GetPos())
						if not MinDist or MinDist > CurDist then MinDist = CurDist MinK = k2 end
					end
					for k2,v2 in pairs(tbl) do			--на втором проходе зачищаю все, кроме ближайшего
						if v2.trackid ~= i or v2.StationName ~= v1.StationName then continue end
						if k2 ~= MinK then tbl[k2] = nil end
					end
				end
			end
		end
	end
	
	local function GetPlatformTrackData(Platform)
		local track = Metrostroi.GetPositionOnTrack(LerpVector(0.5, Platform.PlatformEnd, Platform.PlatformStart))
		if not track[1] or not track[1].path or not track[1].path.id or not track[1].x then return end
		local PosInWorld = Metrostroi.GetTrackPosition(track[1].path,track[1].x)
		return {{trackid = track[1].path.id, vector = PosInWorld, trakcpos = track[1].x}}
	end
	
	local FirstMethodTbl = {}
	local function GenerateTblForFirstMethod()
		print("Generating Tbl for FirstMethod")
		local i = 0
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			local PlatformPos = LerpVector(0.5, v.PlatformStart, v.PlatformEnd)
			local PlatformLen = v.PlatformStart:Distance(v.PlatformEnd)
			--function FindTrackInSquare(vector,TrackID,customraduis,customwlimit,customstep,autoscale,donotclear)
			local Track = GetPlatformTrackData(v)
			if not Track then Track = FindTrackInSquare(PlatformPos,nil,PlatformLen / 3,100,nil,nil,true) end
			--print(v.StationIndex)
			if not Track then continue end
			for k1,v1 in pairs(Track) do
				if not v1.trackid or not v1.trakcpos or not v1.vector then continue end
				i = i + 1
				if not FirstMethodTbl[i] then FirstMethodTbl[i] = {} end
				FirstMethodTbl[i].vector = v1.vector
				FirstMethodTbl[i].trakcpos = v1.trakcpos
				FirstMethodTbl[i].trackid = v1.trackid
				--FirstMethodTbl[i].PlatformLen = v.PlatformDir:Length()
				FirstMethodTbl[i].PlatformLen = PlatformLen		-- который из методов поиска длины платформы верный?
				FirstMethodTbl[i].PlatformPos = PlatformPos		-- который из методов поиска длины платформы верный?
				FirstMethodTbl[i].StationName = GetStationByIndex(v.StationIndex)
			end
		end
		CompleteTBLTrakcs(FirstMethodTbl)

		--if FirstMethodTbl[1] then PrintTable(FirstMethodTbl) end
	end
	if not NoSignals then GenerateTblForFirstMethod() end
	
	local function GetNearestPlatform(vector)				-- эта функция создает таблицу на 2000 элементов. Ни в коем случае не исполнять ее в рантайме!!!
		local CurDist,MinDist,NearestPlatform,PlatformPos
		local DistLimit = 500 * 500
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			PlatformPos = LerpVector(0.5, v.PlatformStart, v.PlatformEnd)
			if PlatformPos.z > vector.z and math.abs(PlatformPos.z - vector.z) > 100 then continue end		-- если платформа выше станции, то искать не выше 100
			if math.abs(PlatformPos.z - vector.z) > 500 then continue end		-- просто ограничение по высоте в обе стороны
			CurDist = vector:DistToSqr(PlatformPos)
			if CurDist > DistLimit then continue end
			if not MinDist or MinDist > CurDist then MinDist = CurDist NearestPlatform = v end
		end
		return NearestPlatform
	end
	
	local ThirdMethodTbl = {}
	local function GenerateTblForThirdMethod()						-- эта функция создает таблицу на 2000 элементов. Ни в коем случае не исполнять ее в рантайме!!!
		print("Generating Tbl for ThirdtMethod")
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		local StationName,StationPos,CurDist,MinDist,NearestStationName
		local i = 0
		for k,v in pairs(Metrostroi.StationConfigurations) do
			if not v.positions or not v.positions[1] or not v.positions[1][1] then continue else StationPos = v.positions[1][1] end
			if not v.names or not v.names[1] then StationName = k else StationName = v.names[1] end
			
			local Platform = FindPlatformByIndex(k)
			--local Platform = GetNearestPlatform(StationPos)					-- старый вариант
			local PlatformLen = Platform and Platform.PlatformStart:Distance(Platform.PlatformEnd) or ((stringfind(StationName,"депо",true) or stringfind(StationName,"depo",true)) and 24000) or 4000	--может 4000 тут сделать больше? 
			--function FindTrackInSquare(vector,TrackID,customraduis,customwlimit,customstep,autoscale,donotclear)
			local Track = FindTrackInSquare(StationPos,nil,PlatformLen / 3,250,nil,nil,true)							-- вот тут надо использовать donotclear, потому что находится только один трек, а надо два
			if not Track then continue end
			for k1,v1 in pairs(Track) do
				if not v1.trackid or not v1.trakcpos or not v1.vector then continue end
				i = i + 1
				if not ThirdMethodTbl[i] then ThirdMethodTbl[i] = {} end
				ThirdMethodTbl[i].vector = v1.vector
				ThirdMethodTbl[i].trakcpos = v1.trakcpos
				ThirdMethodTbl[i].trackid = v1.trackid
				ThirdMethodTbl[i].PlatformLen = PlatformLen
				ThirdMethodTbl[i].StationName = StationName --FindNearestStation(StationPos)			-- эм что?
			end
		end
		CompleteTBLTrakcs(ThirdMethodTbl)
	end
	if not NoSignals then GenerateTblForThirdMethod() end
	
	local function GetSignalPath(signal)
		if not signal.Name then return nil end
		local strsub1 = string.sub(signal.Name,-1)
		local strsub2 = string.sub(signal.Name,-2,-2)
		if tonumber(strsub1) then return strsub1
		elseif tonumber(strsub2) then return strsub2
		else return nil 
		end
	end
	
	local function GenerateTrackIDsPathsTbl()
		print("Generating TrackIDsPathsTbl")
		for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
			if not IsValid(v) or not v.Name or v.Name == "" or v.ARSOnly or not v.Lenses then continue end
			curtrack = v.TrackPosition and v.TrackPosition.path and v.TrackPosition.path.id or 0
			if curtrack == 0 then continue end
			if not TrackIDsPaths[curtrack] then 
				local Path = GetSignalPath(v)
				if not Path then continue end
				TrackIDsPaths[curtrack] = Path % 2 == 0 and 2 or 1 end
		end
	end
	if not NoSignals then GenerateTrackIDsPathsTbl() end
	
	hook.Add("PlayerInitialSpawn","GenerateTblsForStations",function() 
		hook.Remove("PlayerInitialSpawn","GenerateTblsForStations")
		timer.Simple(2,function()
			for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
				table.insert(SignalNamesTbl,1,v.Name or "")
				if IsValid(v) and NoSignals then NoSignals = false end
			end
			timer.Simple(1,function()
				if not NoSignals then 
					print("Generating Tbls for detectstation")
					GenerateTblForThirdMethod()
					GenerateTblForFirstMethod()
					GenerateTrackIDsPathsTbl()
				end
			end)
		end)
	end)
	
	for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
		table.insert(SignalNamesTbl,1,v.Name or "")
	end
	
	
	local function FirstMethod(PosOnTrack,TrackID,tbl)
		--print("first method")
		--if not tbl[1] then return nil end
		local CurDist,MinDist,FieldKey,PrevKey
		for k,v in pairs(tbl) do							-- ищу ближайшую станцию по позиции на треке
			if v.trackid ~= TrackID then continue end
			CurDist = math.abs(PosOnTrack - v.trakcpos)
			if not MinDist or MinDist > CurDist then MinDist = CurDist FieldKey = k end
		end
		if not FieldKey or not MinDist then return nil end
		--print(tbl[FieldKey].PlatformLen / 102 ,MinDist)
		local MinDist2,CurDist2,FieldKey2
		if MinDist > tbl[FieldKey].PlatformLen / 102 + 20 then 			-- 10 метров - небольшой запас
			MinDist = " (ближайшая по треку)" 
			for k,v in pairs(tbl) do							-- ищу вторую по близости станцию, если не в пределах платформы
				if v.trackid ~= TrackID or v.StationName == tbl[FieldKey].StationName then continue end
				CurDist2 = math.abs(PosOnTrack - v.trakcpos)
				if (not MinDist2 or MinDist2 > CurDist2) and (PosOnTrack < tbl[FieldKey].trakcpos and PosOnTrack > v.trakcpos or PosOnTrack > tbl[FieldKey].trakcpos and PosOnTrack < v.trakcpos) then MinDist2 = CurDist2 FieldKey2 = k end
			end
		else 
			MinDist = "" 
		end
		--print(tbl[FieldKey].StationName)
		return tbl[FieldKey].StationName and tbl[FieldKey].StationName..MinDist or nil, FieldKey2 and tbl[FieldKey2].StationName or nil, tbl[FieldKey].trakcpos, FieldKey2 and tbl[FieldKey2].trakcpos or nil
	end

		-----------------ОПРЕДЕЛЕНИЕ МЕСТА ВЕКТОРА ОТНОСИТЕЛЬНО СТАНЦИЙ------------------------------------------------------
	function detectstation(vector)
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		--if not FirstMethodTbl[1] then GenerateTblForFirstMethod() end
		--if not ThirdMethodTbl[1] then GenerateTblForThirdMethod() end
		local Station,Station2,Path,Posx,StationPosx,Station2Posx
		local Track = FindTrackInSquare(vector,nil,100,100,100)
		if Track then
			Station,Station2,StationPosx,Station2Posx = FirstMethod(Track.trakcpos,Track.trackid,FirstMethodTbl)
			if not Station then 
				Station,Station2,StationPosx,Station2Posx = FirstMethod(Track.trakcpos,Track.trackid,ThirdMethodTbl)
			end
			Path = TrackIDsPaths[Track.trackid]
			Posx = Track.trakcpos
		end
		--print(Station,Station2)
		if not Station then Station = SecondMethod(vector) end
		return Station or "", Station2,Path,StationPosx,Station2Posx,Posx
	end
	
	--[[for k,v in pairs(player.GetAll()) do
		print(detectstation(v:GetPos()))
	end]]


	-------------------------УВЕДОМЛЕНИЕ О СПАВНЕ СОСТАВА В ЧАТ (само использование функции нужно прописать в trains_spawner.lua)--------------------------------
	function SpawnNotif(ply, self, vector, WagNum)	-- SpawnNotif(ply, self.Train.ClassName, trace.HitPos, self.Settings.WagNum) в функции TOOL:SpawnWagon
		local TrainName = self.Train.SubwayTrain.Name
		ulx.fancyLogAdmin(ply, true, "#A заспавнил #s", TrainName--[[, self.Train.ClassName, self.Train.Spawner.interim]])
		
		local ourstation = detectstation(vector)
		if ourstation == "" or ourstation == nil 
		then ulx.fancyLog(true, "Вагонов: #i", WagNum)
		else ulx.fancyLog(true, "Станция: #s. Вагонов: #i", ourstation, WagNum)
		end
	end

	--------------------------------------ПОДСЧЕТ ИНТЕРВАЛА ОТ ВРЕМЕНИ КРУГА НА КАРТЕ сама функция используется в модуле выше------------------------------------
	function AutoInterval()
	if Metrostroi.ActiveDispatcher ~= nil then return end
	local LoopTime = 0
	local trains_n = 0
		if CPPI then
			local N = {}
			for k,v in pairs(Metrostroi.TrainClasses) do
				if  v == "gmod_subway_base" then continue end
				local ents = ents.FindByClass(v)
				for k2,v2 in pairs(ents) do
					N[v2:CPPIGetOwner() or v2:GetNetworkedEntity("Owner", "N/A") or "(disconnected)"] = (N[v2:CPPIGetOwner() or v2:GetNetworkedEntity("Owner", "N/A") or "(disconnected)"] or 0) + 1
				end
			end
			for k,v in pairs(N) do
				--ulx.fancyLog("#s wagons have #s",v,(type(k) == "Player" and IsValid(k)) and k:GetName() or k)
				trains_n = trains_n + 1
			end
		end
		
		if trains_n == 0 then trains_n = 1 end
		local Map = game.GetMap()
		if Map == "gm_mus_crimson_line_tox_v9_21" then LoopTime = 20 * 60
		elseif Map == "gm_smr_first_line_v2" then LoopTime = 35 * 60
		elseif Map == "gm_metro_crossline_c4" then LoopTime = 35 * 60	
		elseif Map == "gm_metrostroi_b50" then LoopTime = 70*60
		elseif Map:find("surface") then LoopTime = 22*60+26
		end
		LoopTime = LoopTime / trains_n
		if LoopTime > 1023 then LoopTime = 0 end
		
		if SERVER then
			ulx.SendActiveInt(LoopTime)
		end
		--print(trains_n)
	end
	hook.Add("OnEntityCreated", "AutoInterval4", function()
		timer.Simple(5,function() 
			AutoInterval()
		end)
	end)
	hook.Add("EntityRemoved", "AutoInterval5", function()
		timer.Simple(1,function() 
			AutoInterval()
		end)
	end)

	--[[============================= РАЗРЕШЕНИЕ СПАВНА ТОЛЬКО В ОПРЕДЕЛЕННЫХ МЕСТАХ ==========================]]
	--[[ULib.ucl.registerAccess("AllowSpawnTrainOnStations", ULib.ACCESS_ALL, "Разрешить спавнить на станциях", "Cmds - Metrostroi") -- временно отключил, потому что поменялась функция detectstation
	hook.Add("CanTool", "AllowSpawnTrain", function(ply, tr, tool)
		if tool ~= "train_spawner" then return end
		local ourstation = bigrustosmall(detectstation(tr.HitPos))
		if (not ULib.ucl.query(ply,"AllowSpawnTrainOnStations") or IsValid(Metrostroi.ActiveDispatcher))
			and not ourstation:find("пто") and not ourstation:find("депо") and not ourstation:find("ближайшая")
			and not ourstation:find("depo")
			and not ourstation:find("ддэ")
			then 
				ply:LimitHit("Запрещено спавнить на станциях")
				return false
		end
	end)]]

	--[[============================= СТАРОЕ РАССТОЯНИЕ МЕЖДУ ВАГОНАМИ НА НВЛ ==========================]]
	if string.find(game.GetMap(), "nvl") then Metrostroi.BogeyOldMap = 1 end
end


--[[============================= Новая функция смены карты для того, чтобы она сохранялась в файл ==========================]]
timer.Simple(1,function()
	if SERVER then
			if ulx.MapOverrided then return end
			print("overriding ulx.map")
			local OldUlxMap = ulx.map
			ulx.map = function(calling_ply, map, gamemode)
				--ulx.fancyLogAdmin( calling_ply, "#A changed the map to #s", map )
				file.Write("lastmap.txt", map)
				if ulx.map2 then ulx.map2(calling_ply, map, gamemode) end
				OldUlxMap(calling_ply, map, gamemode)
				--game.ConsoleCommand( "gamemode " .. gamemode .. "\n" )
				--for _,plyr in pairs(player.GetHumans()) do
					--plyr:SendLua("RunConsoleCommand('retry')")
				--end
				--timer.Simple(0.5,function()
					--RunConsoleCommand("_restart")
				--end)
			end
			--ulx.MapOverrided = true
	end
	local map = ulx.command( "Utility", "ulx map", ulx.map, "!map" )
	map:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="map", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes }
	map:addParam{ type=ULib.cmds.StringArg, completes=ulx.gamemodes, hint="gamemode", error="invalid gamemode \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.optional }
	map:defaultAccess( ULib.ACCESS_SUPERADMIN )
	map:help( "Changes map and gamemode." )
end)

if SERVER then
	--[[============================= NOCLIP ПРИ ПОПЫТКЕ ТЕЛЕПОРТА ==========================]]
	hook.Add("PlayerSay", "stationnoclip", function(ply, text, team)
	local text = string.lower(text)
		if string.find(text, "!return") then ply:SetMoveType(MOVETYPE_NOCLIP) end
	end)

--[[============================= ТЕЛЕПОРТ К СИГНАЛУ ==========================]]
	function ulx.tpsig(calling_ply, command)
		if not command or command == "" then
			for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
				if v.Name ~= nil then ULib.tsayError(calling_ply, ""..tostring(v.Name), true) end
			end
		return
		end
	local command = string.lower(command)
		for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
			if bigrustosmall(v.Name) == command then
				if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
				calling_ply.ulx_prevpos = calling_ply:GetPos()
				calling_ply.ulx_prevang = calling_ply:EyeAngles()
				calling_ply:SetMoveType(MOVETYPE_NOCLIP)
				calling_ply:SetPos(Vector(v:GetPos()))
				return
			end
		end
		ULib.tsayError(calling_ply, "Не найдено светофора с таким именем", true)
	end
end
local tpsig = ulx.command("Metrostroi", "ulx tpsig", ulx.tpsig, "!tpsig", true)
tpsig:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.optional }
tpsig:defaultAccess(ULib.ACCESS_ALL)
tpsig:help("Телепортирует к светофору.\nОставь пустым, чтобы увидеть весь список имен.")



if SERVER then
	--[[============================= ВОССТАНОВЛЕНИЕ УДОЧЕК ==========================]]
	local udochkitbl = {}
	hook.Add("PlayerInitialSpawn", "UdichkiTBL", function()
		print("Creating UdochkiTBL")
		hook.Remove("PlayerInitialSpawn", "UdichkiTBL")
		local i = 1
		for k,v in pairs(ents.GetAll()) do
			if stringfind(v:GetClass(),"udochka",true) or stringfind(v:GetClass(),"physbox",true) or stringfind(v:GetClass(), "tracktrain",true) then
				udochkitbl[i] = {v,v:GetPos(),v:GetAngles()}
				i = i + 1
			end
		end		
	end)
	
	local i = 1
	for k,v in pairs(ents.GetAll()) do
		if stringfind(v:GetClass(),"udochka",true) or stringfind(v:GetClass(),"physbox",true) or stringfind(v:GetClass(), "tracktrain",true) then
			udochkitbl[i] = {v,v:GetPos(),v:GetAngles()}
			i = i + 1
		end
	end	
	
	function ulx.resetudochki()
		if table.Count(udochkitbl) < 1 then return end
		for k,v in pairs(udochkitbl) do
			for k1,v1 in pairs(ents.FindByClass(v[1]:GetClass())) do
				if IsValid(v1)and v1 == v[1] and not v1:IsPlayerHolding() and not IsValid(v1.Coupled) then v1:SetPos(v[2]) v1:SetAngles(v[3]) end
			end
		end
	end
end
local resetudochki = ulx.command("Metrostroi", "ulx resetudochki", ulx.resetudochki, "!resetudochki", true)
resetudochki:defaultAccess(ULib.ACCESS_OPERATOR)
resetudochki:help("Восстанавливает удочки на карте.")

--[[============================= ТЕЛЕПОРТ НА СТАНЦИЮ ==========================]]
timer.Simple(5, function()
	if SERVER then
		function ulx.station(ply,comm)
			if not Metrostroi or not Metrostroi.StationConfigurations then ULib.tsayError(ply,"На карте не настроены станции.") return end
			comm = bigrustosmall(comm)
			local stationstbl = {}
			local i = 1
			local comm = bigrustosmall(comm)
			for k,v in pairs(Metrostroi.StationConfigurations) do
				if not v["names"] then continue end
				if not v["names"][1] then v["names"][1] = "ERROR"
				elseif not v["names"][2] then v["names"][2] = "ERROR"
				end
				if bigrustosmall(tostring(k)):find(comm) or bigrustosmall(v["names"][1]):find(comm) or bigrustosmall(v["names"][2]):find(comm) then
					stationstbl[i] = {k,v["names"][1],v["names"][2],v["positions"][1][1]}
					i = i + 1
				end
			end
			--PrintTable(stationstbl)
			if table.Count(stationstbl) > 1 then 
				ULib.tsayError(ply,"По запросу найдено несколько станций",true)
				for k,v in pairs(stationstbl) do
					ULib.tsayError(ply,""..tostring(stationstbl[k][1]).." = "..stationstbl[k][2].." or "..stationstbl[k][3],true)
				end
			elseif table.Count(stationstbl) == 1 then
				ply:ExitVehicle()
				ply.ulx_prevpos = ply:GetPos()
				ply.ulx_prevang = ply:EyeAngles()
				ply:SetMoveType(MOVETYPE_NOCLIP)
				ply:SetPos(stationstbl[1][4])
			else
				ULib.tsayError(ply,"По запросу не найдено совпадений",true)
			end
		end
	end
	local station = ulx.command("Metrostroi", "ulx station", ulx.station, "!station",true)
	station:defaultAccess(ULib.ACCESS_OPERATOR)
	station:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.optional }
	station:help("Телепортация к станции.")
end)

--[[============================= ПРИНУДИТЕЛЬНОЕ ОТКРЫТИЕ ГЛОБАЛЬНОГО ЧАТА ПРИ ОТКРЫТИИ КОМАНДНОГО ==========================]]
if CLIENT then
	hook.Add("StartChat", "DisableTeamChat", function(isTeamChat)
		if isTeamChat then chat.Close() chat.Open(1) end
	end)
end


--[[============================= Скрытие дефолтного уведомления о коннекте ==========================]]
if CLIENT then
	hook.Add("ChatText", "hide_joinleave", function(index, name, text, typ)
		if (typ == "joinleave") then return true end
	end)
end

if SERVER then
--[[============================= ФОНАРИК В КАБИНЕ ==========================]]
	hook.Add("KeyPress", "FlashlightInCabin", function(ply,key)
		if ply:InVehicle() then
			 if ply:KeyPressed(IN_WALK) and ply:KeyPressed(IN_SPEED) then
				if	ply:FlashlightIsOn() then timer.Simple(0.1,function() ply:Flashlight(false) end)
				else timer.Simple(0.1,function() ply:Flashlight(true) end)
				end
			end
		end
	end)
end

--[[============================= Перегрузка !menu ==========================]]
--[[timer.Simple(5, function()
	if SERVER then
		function ulx.menu(ply)
			ply:ConCommand("xgui")
		end
	end
	local menu = ulx.command("Metrostroi", "ulx menu", ulx.menu, "!menu",true)
	menu:defaultAccess(ULib.ACCESS_ALL)
	menu:help("Открыть ulx меню")
end)]]


--[[============================= ПЕРЕГРУЗКА ТАБЛИЦЫ КАРТ ДЛЯ MAPCYCLE ==========================]]
if SERVER then
	timer.Simple(5, function()
		--PrintTable(ulx.votemaps)
		--PrintTable(NextMapTable)
		local NewMapTable = {}
		for i = 1, table.Count(ulx.votemaps) do
			NewMapTable[i] = {map = ulx.votemaps[i], gmode = "sandbox"}
			--или NewMapTable[i].map = ulx.votemaps[i] NewMapTable[i].gmode = "sandbox" 
		end
		--PrintTable(NewMapTable)
		NextMapTable = NewMapTable
	end)
	
--[[============================= ТЕЛЕПОРТАЦИЯ В ПРОТИВОПОЛОЖНУЮ КАБИНУ ==========================]]
	function ulx.changecabin(ply)
		if not ply:InVehicle() then ULib.tsayError(ply, "Ты не в кабине.", true) return end
		local ent = ply:GetVehicle():GetNW2Entity("TrainEntity",nil)
		if not ent then ULib.tsayError(ply, "Ты не в составе.", true) return end
		local WagonList = ent.WagonList
		if not WagonList then ULib.tsayError(ply, "Ошибка.", true) return end
		local WagonListN = #WagonList
		if WagonListN == 1 then ULib.tsayError(ply, "У тебя только 1 вагон.", true) return end
		local EntClass = ent:GetClass()
		KekLolArbidol(WagonList[WagonListN],ply)
	end
end
local changecabin = ulx.command("Metrostroi", "ulx ch", ulx.changecabin, "!ch",true)
changecabin:defaultAccess(ULib.ACCESS_ALL)
changecabin:help("Телепортация в заднюю кабиную.")


--[[============================= АВТОМАТИЧЕСКАЯ УСТАНОВКА ДЕШИФРАТОРА ==========================]]
if SERVER then
	hook.Add("OnEntityCreated", "AlsFReq", function(ent)
		timer.Simple(3, function()
			if not IsValid(ent) or ent.Base ~= "gmod_subway_base" then return end
			local EntPos = ent:GetPos()
			local DistToNearest,NearestEnt
			for k,v in pairs(ents.FindByClass("gmod_track_signal") or {}) do
				if not IsValid(v) then continue end
				local DistToSignal = EntPos:DistToSqr(v:GetPos())
				if not NearestEnt or DistToSignal < DistToNearest then 
					NearestEnt = v 
					DistToNearest = DistToSignal
				end
			end
			if not NearestEnt or not NearestEnt.TwoToSix then return end
			if ent:GetClass():find("717_m",1,true) and ent.ALSFreq and ent.ALSFreq.TriggerInput then ent.ALSFreq:TriggerInput("Set",1) end
			if ent:GetClass():find("81-76",1,true) and ent.SA14 and ent.SA14.TriggerInput then ent.SA14:TriggerInput("Set",1) end
		end)
	end)
end

--[[============================= НАСТРОЙКА ЛИМИТОВ ДЛЯ СПАВНЕРА ==========================]]
--добавил просто по приколу. мне это не нужно
--[[if SERVER then
	hook.Add("MetrostroiLoaded","Create ulx trains restrictions",function() 
		for k,class in pairs(Metrostroi.TrainClasses) do
			ULib.ucl.registerAccess(class, ULib.ACCESS_ALL, "Разрешить спавнить "..class, "Cmds - Metrostroi")
		end
	end)
end]]
if SERVER then
	ULib.ucl.registerAccess("ignoremapwaglimit", ULib.ACCESS_SUPERADMIN, "Игнорировать лимит вагонов карты", "Cmds - Metrostroi")
	
	ULib.ucl.registerAccess("AllowNoARSWithTwoToSix", ULib.ACCESS_OPERATOR, "Разрешить составы без АРС при 2/6", "Cmds - Metrostroi")
	
	local LastTrainSpawned = os.time()
	hook.Add("MetrostroiSpawnerRestrict","AllowNoARSWithTwoToSix",function(ply,Settings)
		if os.time() - LastTrainSpawned < 6 then 
			ULib.tsayError( ply, "Подожди " .. math.Round(LastTrainSpawned + 6 - os.time()) .. " seconds, чтобы заспавнить состав")
			return true 
		end
		--if not ULib.ucl.query(ply,Settings.Train) then return true end--добавил просто по приколу. мне это не нужно
		if THEFULDEEP.TwoToSixInSignals then
			if Settings.Train == "gmod_subway_81-703" or Settings.Train == "gmod_subway_em508" or Settings.Train == "gmod_subway_81-702" or Settings.Train == "gmod_subway_em508" then
				if not ULib.ucl.query(ply,"AllowNoARSWithTwoToSix") then 
					--ULib.tsayError(ply, "Тебе нельзя спавнить этот состав", true)	
					return true 
				end
			end
		end
		
		LastTrainSpawned = os.time()
	end)
	
	
	hook.Add("PlayerInitialSpawn","Send ignoremapwaglimit on spawn",function(ply)
		ply:SetNW2Bool("ignoremapwaglimit",ULib.ucl.query(ply,"ignoremapwaglimit"))
	end)
	
	hook.Add("ULibGroupAccessChanged", "ignoremapwaglimit access update",function(group,access,revoke)
		for i,name in ipairs(access) do
			if name ~= "ignoremapwaglimit" then continue end
			for _,ply in pairs(player.GetHumans()) do
				if string.lower(ply:GetUserGroup()) ~= group then continue end
				ply:SetNW2Bool("ignoremapwaglimit",not revoke)
			end
		end
	end)
end

function MaximumWagons(ply,self)
	local Map = game.GetMap()
	if not ply.GetUserGroup then return 0 end
	local Rank = ply:GetUserGroup()
	local maximum = 6
	local MetrostroiTrainCount = GetGlobalInt("metrostroi_train_count")
	local MetrostroiMaxWagons = GetGlobalInt("metrostroi_maxwagons")
	if MetrostroiTrainCount <= 0 then MetrostroiTrainCount = 1 end
	if MetrostroiMaxWagons <= 0 then MetrostroiMaxWagons = 1 end
	if MetrostroiMaxWagons <= MetrostroiTrainCount then return 0 end
	local percent = MetrostroiTrainCount / MetrostroiMaxWagons 
	if percent < 0.25 then maximum = 6
	elseif percent < 0.5 then maximum = 4
	elseif percent < 0.75 then maximum = 3
	else maximum = 2
	end
	if Rank == "superadmin" then maximum = 6 end
	if maximum < 4 and (Rank == "operator" or Rank == "admin" or Rank == "SuperVIP") then maximum = 4 end
	maximum = not ply:GetNW2Bool("ignoremapwaglimit") and GetGlobalInt("MaxWagonsByPlatformLen",0) or maximum
	if SERVER and self then
		if maximum < 6 and self.Train.ClassName == "gmod_subway_81-722" then self.Settings.WagNum = 3 end
	end
	return maximum
end


--[[============================= ПОИСК 2/6 В СИГНАЛКЕ ==========================]]
if SERVER then
	hook.Add("PlayerInitialSpawn","FindTwoToSix",function()
		hook.Remove("PlayerInitialSpawn","FindTwoToSix")
		print("Seaching for TwoToSix in signals...")
		for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
			if IsValid(v) and v.TwoToSix then print("Found TwoToSix in signals!") THEFULDEEP.TwoToSixInSignals = true return end
		end
	end)
end


--[[============================= ОТОБРАЖЕНИЕ ВСЕХ ИНТЕРВАЛЬНЫХ ЧАСОВ ==========================]]
if SERVER then	

	local function SecondMethod(vector)
		if not Metrostroi or not Metrostroi.StationConfigurations then return "" end
		local StationName
		local StationPos
		local NearestStation
		local MinDist
		local dist
		local wLimit = 300
		for k,v in pairs(Metrostroi.StationConfigurations) do						--поиск ближайшей станции в плоскости и в ограниченной высоте
			if not v.positions or not v.positions[1] or not v.positions[1][1] then continue else StationPos = v.positions[1][1] end
			if not v.names or not v.names[1] then StationName = k else StationName = v.names[1] end
			dist = math.Distance(vector.x,vector.y,StationPos.x,StationPos.y)
			if (not MinDist or dist < MinDist) and math.abs(vector.z - StationPos.z) < wLimit then MinDist = dist NearestStation = StationName end
		end
		return NearestStation or ""
	end
	
	local StationsCfg = {}
	local function GenerateStationsCfg()
		print("Generating StationsCfg Table")
		local i = 0
		for k,v in pairs(ents.FindByClass("gmod_track_clock_small")) do
			if not IsValid(v) then continue end
			local vector = v:GetPos()
			local Track = FindTrackInSquare(vector,nil,100,100,100)
			if not Track then continue end
			i = i + 1
			local Station = SecondMethod(vector) or ""
			local NeedSub = stringfind(Station," (ближа")
			if NeedSub then Station = string.sub(Station,1,NeedSub - 1) end
			local Path = TrackIDsPaths[Track.trackid]
			if not Path then continue end
			if not StationsCfg[i] then StationsCfg[i] = {} end
			StationsCfg[i]["ent"] = v
			StationsCfg[i]["name"] = Station..". Путь: "..Path..". Интервал: "
		end
		for k,v in pairs(ents.FindByClass("gmod_track_clock_interval")) do
			if not IsValid(v) then continue end
			i = i + 1
			local vector = v:GetPos()
			local Track = FindTrackInSquare(vector,nil,100,100,100)
			if not Track then continue end
			local Station = SecondMethod(vector) or ""
			local NeedSub = stringfind(Station," (ближа")
			if NeedSub then Station = string.sub(Station,1,NeedSub - 1) end
			local Path = TrackIDsPaths[Track.trackid]
			if not Path then continue end
			if not StationsCfg[i] then StationsCfg[i] = {} end
			StationsCfg[i]["ent"] = v
			StationsCfg[i]["name"] = Station..". Путь: "..Path..". Интервал: "
		end
		
		local pos
		for k,v in pairs(StationsCfg) do
			pos = v["ent"]:GetPos()
			for k1,v1 in pairs(StationsCfg) do
				local CurDist = pos:DistToSqr(v1["ent"]:GetPos())
				if v1["ent"] and v1["ent"] ~= v["ent"] and CurDist < 400 * 400 and v1.ent:GetClass() == "gmod_track_clock_small" then StationsCfg[k1] = nil end
			end
		end
	end
	
	GenerateStationsCfg()

	local function GetIntervalTime(ent)
		return math.floor(Metrostroi.GetSyncTime() - (ent:GetIntervalResetTime() + GetGlobalFloat("MetrostroiTY")))
	end
	
	util.AddNetworkString("SendIntervalsNetworkString")	
	local IntervalsTbl = {}
	local IntervalsEnabled = true
	timer.Create("Send Intervals  info",5,0,function()
			if not IntervalsEnabled then return end
			if NoSignals then return end
			if (not StationsCfg or table.Count(StationsCfg) < 1) and #player.GetHumans() > 1 then GenerateStationsCfg() return end
			for i = 1, #StationsCfg do
				if not StationsCfg[i] then continue end
				IntervalsTbl[i] = GetIntervalTime(StationsCfg[i]["ent"])
			end
			net.Start("SendIntervalsNetworkString")
			--net.WriteTable(IntervalsTbl)		-- старый вариант
				local TableToSend = util.Compress(util.TableToJSON(IntervalsTbl))		--новый вариант
				local TableToSendN = #TableToSend
				net.WriteUInt(TableToSendN, 32)
				net.WriteData(TableToSend, TableToSendN)
			net.Broadcast()
	end)

	util.AddNetworkString("SendStationsCfgNetworkString")
	local function SendStationsCfgToClient(ply)
		if not IsValid(ply) then return end
		if NoSignals then return end
		if not StationsCfg or table.Count(StationsCfg) < 1 then GenerateStationsCfg() end
		if table.Count(StationsCfg) > 0 then
			local tbl = {}
			for i = 1, #StationsCfg do
				if not StationsCfg[i] then continue end
				tbl[i] = StationsCfg[i]["name"]
			end
			net.Start("SendStationsCfgNetworkString")
			net.WriteTable(tbl)
			net.Send(ply)
		end
	end
	
	hook.Add("PlayerInitialSpawn","SendStationsCfgOnSpawn",function(ply) 
			timer.Simple(4,function()
				if not NoSignals then SendStationsCfgToClient(ply) end
			end)
	end)
	
	timer.Simple(1,function()
		if not NoSignals then
			for k,v in pairs(player.GetAll()) do
				SendStationsCfgToClient(v)
			end
		end
		--[[for k,v in pairs(player.GetAll()) do
			for k1,v1 in pairs(StationsCfg) do
				v:SetPos(v1["ent"]:GetPos())
			end
		end]]
	end)
	
	function ulx.fix(calling_ply, command)
		game.CleanUpMap()
		StationsCfg = {}
		--createavtooborot()
		RunConsoleCommand("metrostroi_load")
		RunConsoleCommand("mirrors_load")
		RunConsoleCommand("auto_route_cutting_load")
		timer.Simple(2,function() GenerateStationsCfg() end)
		ulx.fancyLogAdmin(calling_ply, "[SERVER] #A ВОССТАНОВИЛ КАРТУ")
	end
end
local fix = ulx.command("Utility", "ulx fix", ulx.fix, "!fix", true, false, true)
fix:defaultAccess(ULib.ACCESS_SUPERADMIN)
fix:help("Восстанавливает карту и сигналку. Все составы удалятся.")



if CLIENT then	
	CreateClientConVar("showintervalclocks","0",false,false,"")
	local StationsCfg = {}
	local IntervalsTbl = {}
	
	net.Receive("SendIntervalsNetworkString",function() 
		--IntervalsTbl = net.ReadTable()		старый вариант
		local length = net.ReadUInt(32)			-- новый вариант
		IntervalsTbl = util.JSONToTable(util.Decompress(net.ReadData(length)))
	end)
	
	net.Receive("SendStationsCfgNetworkString",function() 
		StationsCfg = net.ReadTable()
	end)
	
	local function NumberToString(number)
		if number < 0 or number > 60 * 9 + 59 then number = 0 end
		local minutes = math.floor(number / 60)
		local seconds = math.floor(number) - minutes * 60
		if seconds < 10 then seconds = "0"..seconds end
		return minutes..":"..seconds
	end
	
	local timestamp = 0
	local h = 10
	hook.Add("HUDPaint","ShowingIntervalClocks",function()
		if not GetConVar("showintervalclocks"):GetBool() then return end
		if CurTime() - timestamp >= 1 and table.Count(IntervalsTbl) > 0 then
			timestamp = CurTime()
			for i = 1, #IntervalsTbl do
				if not IntervalsTbl[i] then continue end
				IntervalsTbl[i] = IntervalsTbl[i] + 1
			end
		end
		local j = 0
		if table.Count(StationsCfg) > 0 and table.Count(IntervalsTbl) > 0 then
			for i = 1, #StationsCfg do
				if not StationsCfg[i] --[[or stringfind(StationsCfg[i],"депо",true)]] then continue end
				j = j + 1
				draw.SimpleText(StationsCfg[i]..NumberToString(IntervalsTbl[i]),"ChatFont",0,0 + (h + 5) * j,Color(255,255,255,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
			end
		end
	end)
end


--[[============================= ВКЛЮЧЕНИЕ И ОТКЛЮЧЕНИЕ АВТОМАТИКОВ/ТУМБЛЕРОВ ==========================]]
if SERVER then
	util.AddNetworkString("RelalysInTrain")
	local function FindInTable(tbl,value)
		for k,v in pairs(tbl) do
			if v == value then return k end
		end
		return false
	end
	local tumblerstbl = {}
	for k,v in pairs(tumblerstbl) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				if not IsValid(v1) then tumblerstbl[k][k1] = nil end
			end
		end
	end
	function ulx.toggletumbler(ply,str)
		if not ply:InVehicle() then ULib.tsayError(ply, "Ты не в кабине.", true) return end
		local ent = ply:GetVehicle():GetNW2Entity("TrainEntity",false)
		if not ent then ULib.tsayError(ply, "Ты не в составе.", true) return end
		str = string.lower(str)
		local found = false
		for k,v in pairs(ent.SyncTable) do
			if not found and string.lower(v) == str then found = v end
		end
		if not found then
			ply:ChatPrint("Такой переключатель не найден. Список переключателей выведен в консоль.")
			local Relays = ""
			for k,v in pairs(ent.SyncTable) do
				if not ent[v] or not ent[v].Value or (ent[v].Value ~= 1 and ent[v].Value ~= 0) then continue end
				if Relays == "" then 
					Relays = v 
				else
					Relays = Relays..", "..v
				end
			end
			net.Start("RelalysInTrain")
				net.WriteString(Relays)
			net.Send(ply)
			return 
		end
		if not ent[found].Value or (ent[found].Value ~= 0 and ent[found].Value ~= 1) then ULib.tsayError(ply, "Не удается переключить тумблер.", true) return end
		if not tumblerstbl[found] then tumblerstbl[found] = {} end
		local Owner = "N/A"
		local OwnerSteamID = ""
		if CPPI then Owner = ent:CPPIGetOwner():Nick() OwnerSteamID = "("..ent:CPPIGetOwner():SteamID()..")" end
		local needvalue = ent[found].Value == 1 and 0 or 1
		if not FindInTable(tumblerstbl[found],ent) then 
			if ent[found].Blocked and ent[found].Blocked == 1 then ULib.tsayError(ply, "Не удается переключить тумблер.", true) return end
			ent[found]:TriggerInput("Set",needvalue) 
			ent[found]:TriggerInput("Block",true) 
			ply:ChatPrint("Тумблер "..found.." переключен и заблокирован.")
			MsgC(Color( 255, 0, 0 ), ply:Nick().."("..ply:SteamID()..") переключил и заблокировал тумблер в составе игрока "..Owner..OwnerSteamID.."\n")
			table.insert(tumblerstbl[found],1,ent)
		else
			ent[found]:TriggerInput("Block",false) 
			ent[found]:TriggerInput("Set",needvalue) 
			ply:ChatPrint("Тумблер "..found.." переключен и разблокирован.")
			MsgC(Color( 255, 0, 0 ), ply:Nick().."("..ply:SteamID()..") переключил и разблокировал тумблер в составе игрока "..Owner..OwnerSteamID.."\n")
			tumblerstbl[found][FindInTable(tumblerstbl[found],ent)] = nil
		end
	end
end
if CLIENT then
	net.Receive("RelalysInTrain",function()
		Msg(net.ReadString())
	end)
end
local toggletumbler = ulx.command("Metrostroi", "ulx toggletumbler", ulx.toggletumbler, "!toggletumbler",true)
toggletumbler:addParam{ type=ULib.cmds.StringArg, hint="имя тумблера"}
toggletumbler:defaultAccess(ULib.ACCESS_OPERATOR)
toggletumbler:help("Переключить и заблокировать тумблер в составе.")


--[[============================= ПЕРЕГРУЗКА GOTO ==========================]]
ulx.gotoOverwrited = nil
timer.Create("UlxGotoOverwrite", 5, 0, function()
	if SERVER then
		if not ulx or not ulx.goto then return end
		if ulx.gotoOverwrited then timer.Remove("UlxGotoOverwrite") return end
		timer.Remove("UlxGotoOverwrite")
		ulx.gotoOverwrited = true
		local oldgoto = ulx.goto
		function ulx.goto(calling_ply, target_ply)
			--local WasNoclip = calling_ply:GetMoveType() == MOVETYPE_NOCLIP and true or false
			calling_ply:SetMoveType(MOVETYPE_NOCLIP)
			if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
			oldgoto(calling_ply, target_ply)
		end
		print("ulx.goto overwrited")
	end
	local goto = ulx.command( "Teleport", "ulx goto", ulx.goto, "!goto" )
	goto:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
	goto:defaultAccess( ULib.ACCESS_ADMIN )
	goto:help( "Goto target." )
end)

--[[============================= ClearDecals ==========================]]
if CLIENT then
	timer.Create("ClearDecals", 180, 0, function()
		RunConsoleCommand("r_cleardecals", "")
	end)
end

--[[============================= полная информаия со всех серверов ==========================]]
if SERVER then
	util.AddNetworkString("ServersInfo")
	local WebServerUrl = "http://"..(file.Read("web_server_ip.txt") or "127.0.0.1").."/serverinfo/"
	function ulx.info(ply)
		http.Fetch(
			WebServerUrl,
			function(body)
				body1 = util.JSONToTable(body)
				if body1 then 
					if not IsValid(ply) then
						PrintTable(body1)
					else
						net.Start("ServersInfo")
							print(body)
							local DataToSend = util.Compress(body)
							local DataToSendN = #DataToSend
							net.WriteUInt(DataToSendN,32)
							net.WriteData(DataToSend,DataToSendN)
						net.Send(ply)
					end
				end
			end
		)
	end
end
local info = ulx.command("Metrostroi", "ulx info", ulx.info, "!info",true)
info:defaultAccess(ULib.ACCESS_SUPERADMIN)
info:help("Подробная информация о игроках на серверах.")
if CLIENT then
	net.Receive("ServersInfo",function()
		local Len = net.ReadUInt(32)
		local Data = net.ReadData(Len)
		Data = util.JSONToTable(util.Decompress(Data))
		if Data then 
			PrintTable(Data) 
			chat.AddText(Color( 100, 100, 255 ),"Информация о серверах выведена к консоль.")
		end
	end)
end

timer.Simple(1,function()
	print("overwriting ulx.wagons")
	if SERVER then
		ulx.wagons = function(ply)
			if not ulx.wagons2 then return end
			ulx.wagons2(ply)
		end
	end
	local wagons = ulx.command( "Metrostroi", "ulx trains", ulx.wagons, "!trains" )
	wagons:defaultAccess( ULib.ACCESS_ALL )
	wagons:help( "Shows you the current wagons." )
end)
--TODO автоподключение удочки
--for k,v in ipairs(tbl) медленнее, чем pairs(tbl), медленнее, чем next,tbl

--pairs работает быстрее, чем ipairs
--используй table.insert только если ключи не числа
--ply.InMetrostroiTrain
--[[============================= УДАЛЕНИЕ НЕНУЖНЫХ ВКЛАДОК ИЗ SPAWNMENU ==========================]]
--[[local function testkek(panel)
    panel:ClearControls()
    panel:SetPadding(0)
    panel:SetSpacing(0)
end

spawnmenu.AddCreationTab("Spawnlists	")
hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption("Utilities", "User", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption("Tools", "Player", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption("Tools", "Posing", "", "", "", "", testkek)
end)]]
--[[hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption("Utilities", "Stuff", "Custom_Menu", "My Custom Menu", "", "", function(panel)
		panel:ClearControls()
		panel:NumSlider("Gravity", "sv_gravity", 0, 600)
		-- Add stuff here
	end)
end)]]
--spawnmenu.AddToolMenuOption("Utilities", "Metrostroi", "metrostroi_client_panel2", Metrostroi.GetPhrase("Panel.Client") .. "2", "", "", ClientPanel)

--gmod_track_platform	Metrostroi.Stations[self.StationIndex]
--metrostroi_signal_debug 1
--hook.Add("PlayerSpawnSENT", "PerzKek16", function(ply, class)							-- для проверки, если игрок спавнит что-то не треинспавнером
--hook.Add("OnEntityCreated", "Perzpidor2281337123", function(ent)			-- можно использовать это для уведомления о спавне состава не в спавнере. А ограничение по вагонам можно сделать через cantool