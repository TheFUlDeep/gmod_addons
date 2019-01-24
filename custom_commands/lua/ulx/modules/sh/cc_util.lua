---------------------------------------------------
--  This file holds client and server utilities  --
---------------------------------------------------
--lastused = nil

function ulx.give( calling_ply, target_plys, entity, should_silent )

	for k,v in pairs( target_plys ) do

		if ( not v:Alive() ) then -- Is the player dead?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
	
		elseif v:IsFrozen() then -- Is the player frozen?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
	
		elseif v:InVehicle() then -- Is the player in a vehicle?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is in a vehicle.", true )
		
		else 
	
			v:Give( entity )
			
		end
		
	end
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A gave #T #s", target_plys, entity )
		
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A gave #T #s", target_plys, entity )
	
	end

end
local give = ulx.command( "Utility", "ulx give", ulx.give, "!give" )
give:addParam{ type=ULib.cmds.PlayersArg }
give:addParam{ type=ULib.cmds.StringArg, hint="entity" }
give:addParam{ type=ULib.cmds.BoolArg, invisible=true }
give:defaultAccess( ULib.ACCESS_ADMIN )
give:help( "Give a player an entity" )
give:setOpposite ( "ulx sgive", { _, _, _, true }, "!sgive", true )

function ulx.maprestart( calling_ply )

    timer.Simple( 1, function() -- Wait 1 second so players can see the log
	
		game.ConsoleCommand( "changelevel " .. game.GetMap() .. "\n" ) 
		
	end ) 
	
    ulx.fancyLogAdmin( calling_ply, "#A forced a mapchange" )
	
end
local maprestart = ulx.command( "Utility", "ulx maprestart", ulx.maprestart, "!maprestart" )
maprestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
maprestart:help( "Forces a mapchange to the current map." )

function ulx.stopsounds( calling_ply )

	for _,v in ipairs( player.GetAll() ) do 
	
		v:SendLua([[RunConsoleCommand("stopsound")]]) 
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A stopped sounds" )
	
end
local stopsounds = ulx.command("Utility", "ulx stopsounds", ulx.stopsounds, {"!ss", "!stopsounds"} )
stopsounds:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopsounds:help( "Stops sounds/music of everyone in the server." )

function ulx.multiban( calling_ply, target_ply, minutes, reason )

	local affected_plys = {}
	
	for i=1, #target_ply do
    local v = target_ply[ i ]

	
	if v:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	table.insert( affected_plys, v )
	
	ULib.kickban( v, minutes, reason, calling_ply )
    
	end
	
	local time = "for #i minute(s)"
	
		if minutes == 0 then time = "permanently" end
	
	local str = "#A banned #T " .. time
	
		if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, affected_plys, minutes ~= 0 and minutes or reason, reason )
	
	
end
local multiban = ulx.command( "Utility", "ulx multiban", ulx.multiban )
multiban:addParam{ type=ULib.cmds.PlayersArg }
multiban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
multiban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
multiban:defaultAccess( ULib.ACCESS_ADMIN )
multiban:help( "Bans multiple targets." )

if ( CLIENT ) then

local on = false -- default off

local function toggle()

	on = !on

	if on == true then

		print( 'enabled' )
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode enabled." )

	else

		print( 'disabled')
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode disabled." )

	end

end


hook.Add( "ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function()

	if on and LocalPlayer():Alive() then

		return true

	end

end )

hook.Add( "CalcView", "ThirdPersonView", function( ply, pos, angles, fov )

	if on and ply:Alive() then

		local view = {}
		view.origin = pos - ( angles:Forward() * 70 ) + ( angles:Right() * 20 ) + ( angles:Up() * 5 )
		--view.origin = pos - ( angles:Forward() * 70 )
		view.angles = ply:EyeAngles() + Angle( 1, 1, 0 )
		view.fov = fov

		return GAMEMODE:CalcView( ply, view.origin, view.angles, view.fov )

	end

end )

concommand.Add( "thirdperson_toggle", toggle )


--[[	local function ulx.discotdgui()
	gui.OpenURL( https://discord.gg/p4mJVKr )
	end	
	local discordgui = ulx.command( "Menus", "ulx discordgui", ulx.discordgui, "!discordgui" )
	discordgui:defaultAccess( ULib.ACCESS_SUPERADMIN )
	discordgui:help( "открыть дискорд" )]]
	

end

if ( SERVER ) then

function ulx.thirdperson( calling_ply )

	calling_ply:SendLua([[RunConsoleCommand("thirdperson_toggle")]])	

end
local thirdperson = ulx.command( "Utility", "ulx thirdperson", ulx.thirdperson, {"!thirdperson", "!3p"}, true )
thirdperson:defaultAccess( ULib.ACCESS_ALL )
thirdperson:help( "Toggles third person mode" )

end -- end serverside

function ulx.timedcmd( calling_ply, command, seconds, should_cancel )

	ulx.fancyLogAdmin( calling_ply, true, "#A will run command #s in #i seconds", command, seconds )

	timer.Create( "timedcommand", seconds, 1, function()

		calling_ply:ConCommand( command )
	
	end)

	timer.Create( "halftime", ( seconds/2 ), 1, function() -- Print to the chat when half the time is left

		ULib.tsay( calling_ply, ( seconds/2 ) .. " seconds left" )	
	
	end)	
	
end
local timedcmd = ulx.command( "Utility", "ulx timedcmd", ulx.timedcmd, "!timedcmd", true )
timedcmd:addParam{ type=ULib.cmds.StringArg, hint="command" }
timedcmd:addParam{ type=ULib.cmds.NumArg, min=1, hint="seconds", ULib.cmds.round }
timedcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
timedcmd:defaultAccess( ULib.ACCESS_ADMIN )
timedcmd:help( "Runs the specified command after a number of seconds." )

--cancel the active timed command--
function ulx.cancelcmd( calling_ply )

	timer.Destroy( "timedcommand" )
	
	timer.Destroy( "halftime" )
	
	ulx.fancyLogAdmin( calling_ply, true, "#A cancelled the timed command" )
	
end
local cancelcmd = ulx.command( "Utility", "ulx cancelcmd", ulx.cancelcmd, "!cancelcmd", true )
cancelcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
cancelcmd:defaultAccess( ULib.ACCESS_ADMIN )
cancelcmd:help( "Runs the specified command after a number of seconds." )

function ulx.cleardecals( calling_ply )

	for _,v in ipairs( player.GetAll() ) do
		
		v:ConCommand("r_cleardecals")
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A cleared decals" )
	
end
local cleardecals = ulx.command( "Utility", "ulx cleardecals", ulx.cleardecals, "!cleardecals" )
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clear decals for all players." )

function ulx.fix( calling_ply, command )

	game.CleanUpMap()
	
	local fix = "metrostroi_load"

	ULib.consoleCommand( fix.. "\n" )

	ulx.fancyLogAdmin( calling_ply, "[SERVER] #A ВОССТАНОВИЛ КАРТУ")
end
local fix = ulx.command( "Utility", "ulx fix", ulx.fix, "!fix", true, false, true )
fix:defaultAccess( ULib.ACCESS_SUPERADMIN )
fix:help( "Восстанавливает карту и сигналку. Все составы удалятся." )

function ulx.reloadsignals( calling_ply, command )

	local fix = "metrostroi_load"

	ULib.consoleCommand( fix.. "\n" )

	ulx.fancyLogAdmin( calling_ply, "[SERVER] #A ПЕРЕЗАГРУЗИЛ СИГНАЛКУ")
end
local reloadsignals = ulx.command( "Signals", "ulx reloadsignals", ulx.reloadsignals, "!reloadsignals", true, false, true )
reloadsignals:defaultAccess( ULib.ACCESS_SUPERADMIN )
reloadsignals:help( "Перезагружает сигналку" )

function ulx.savesignals( calling_ply, command )

	local fix = "metrostroi_save"

	ULib.consoleCommand( fix.. "\n" )

	ulx.fancyLogAdmin( calling_ply, "[SERVER] #A СОХРАНИЛ СИГНАЛКУ")
end
local savesignals = ulx.command( "Signals", "ulx savesignals", ulx.savesignals, "!savesignals", true, false, true )
savesignals:defaultAccess( ULib.ACCESS_SUPERADMIN )
savesignals:help( "Сохраняет сигналку" )

function ulx.restart_server( calling_ply)	
local i = 0
for i = 0, 60 do
	timer.Simple( i, function()		
		ulx.fancyLog(false, "Рестарт через #i seconds", 60 - i)
		--ULib.tsay(nil, "Рестарт через " .. math.Round(60 - i) .. " секунд(у)" , true)
		--ulx.tsayError(nil, "Рестарт через " .. math.Round(60 - i) .. " секунд(у)" , true )       --не работет
		if i == 60 then
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[LocalPlayer():ConCommand('retry]]..[[')]])
			end
			RunConsoleCommand( "_restart" ) end
		end ) 
end
end
local restart_server = ulx.command( "Utility", "ulx restart_server", ulx.restart_server, "!restart_server", true, false, true )
restart_server:defaultAccess( ULib.ACCESS_SUPERADMIN )
restart_server:help( "ВЫРУБАЕТ СЕРВЕР НАХООООООООООЙ (перезапускает)" )
	
function ulx.discord(calling_ply)
	local discord = "https://discord.gg/p4mJVKr"
	--local ply = tostring(calling_ply:Nick())
	ulx.fancyLog(false, "Наш дискорд: #s", discord)
	--ULib.tsayColor(nil, true, discord, Color(255,255,255,255))
	--ULib.tsay(nil, "Наш дискорд: https://discord.gg/p4mJVKr", true)
end
local discord = ulx.command( "Menus", "ulx discord", ulx.discord, "!discord" )
discord:defaultAccess( ULib.ACCESS_SUPERADMIN )
discord:help( "Показать в чате ссылку на дискорд" )

--[[	local function ulx.discotdgui()
	gui.OpenURL( https://discord.gg/p4mJVKr )
	end	
	local discordgui = ulx.command( "Menus", "ulx discordgui", ulx.discordgui, "!discordgui" )
	discordgui:defaultAccess( ULib.ACCESS_SUPERADMIN )
	discordgui:help( "открыть дискорд" )]]

function ulx.updateulx(calling_ply)	
	--timer.Simple( 1, function()	
	--local command = "ulx adduser " .. calling_ply:Nick() .. " " .. calling_ply:GetUserGroup()
	--RunConsoleCommand( command ) 		
	--game.ConsoleCommand( command )
	ULib.ucl.addUser(calling_ply:SteamID(),nil,nil, calling_ply:GetUserGroup())
	--end ) 
	ulx.fancyLogAdmin(calling_ply, true, "#A обновил ulx")
end
local updateulx = ulx.command( "Utility", "ulx updateulx", ulx.updateulx, "!updateulx", true, false, true )
updateulx:defaultAccess( ULib.ACCESS_SUPERADMIN )
updateulx:help( "Обновляет меню (не нужно обычным игрокам)" )









function ulx.resetmap( calling_ply )

	game.CleanUpMap()
	
	ulx.fancyLogAdmin( calling_ply, "#A reset the map to its original state" )
	
end
local resetmap = ulx.command( "Utility", "ulx resetmap", ulx.resetmap, "!resetmap" )
resetmap:defaultAccess( ULib.ACCESS_SUPERADMIN )
resetmap:help( "Resets the map with signals to its original state." )

function ulx.bot( calling_ply, number, should_kick )

	if ( not should_kick ) then
	
		if number == 0 then
			
			for i=1, 256 do 
			
				RunConsoleCommand("bot")
				
			end
			
		elseif number > 0 then
		
			for i=1, number do
		
				RunConsoleCommand("bot")
				
			end
			
		end
		
		if number == 0 then

			ulx.fancyLogAdmin( calling_ply, "#A filled the server with bots" )
			
		elseif number == 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bot", number )
			
		elseif number > 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bots", number )
			
		end
		
	elseif should_kick then

		for k,v in pairs( player.GetAll() ) do
		
			if v:IsBot() then
			
				v:Kick("") 
				
			end
			
		end

		ulx.fancyLogAdmin( calling_ply, "#A kicked all bots from the server" )
		
	end
	
end
local bot = ulx.command( "Utility", "ulx bot", ulx.bot, "!bot" )
bot:addParam{ type=ULib.cmds.NumArg, default=0, hint="number", ULib.cmds.optional }
bot:addParam{ type=ULib.cmds.BoolArg, invisible=true }
bot:defaultAccess( ULib.ACCESS_ADMIN )
bot:help( "Spawn or remove bots." )
bot:setOpposite( "ulx kickbots", { _, _, true }, "!kickbots" )

function ulx.banip( calling_ply, minutes, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	local plys = player.GetAll()
	
	for i=1, #plys do
	
		if string.sub( tostring( plys[ i ]:IPAddress() ), 1, string.len( tostring( plys[ i ]:IPAddress() ) ) - 6 ) == ip then
			
			ip = ip .. " (" .. plys[ i ]:Nick() .. ")"
			
			break
			
		end
		
	end

	RunConsoleCommand( "addip", minutes, ip )
	RunConsoleCommand( "writeip" )

	ulx.fancyLogAdmin( calling_ply, true, "#A banned ip address #s for #i minutes", ip, minutes )
	
	if ULib.fileExists( "cfg/banned_ip.cfg" ) then
		ULib.execFile( "cfg/banned_ip.cfg" )
	end
	
end
local banip = ulx.command( "Utility", "ulx banip", ulx.banip )
banip:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.allowTimeString, min=0 }
banip:addParam{ type=ULib.cmds.StringArg, hint="address" }
banip:defaultAccess( ULib.ACCESS_SUPERADMIN )
banip:help( "Bans ip address." )

hook.Add( "Initialize", "banips", function()
	if ULib.fileExists( "cfg/banned_ip.cfg" ) then
		ULib.execFile( "cfg/banned_ip.cfg" )
	end
end )

function ulx.unbanip( calling_ply, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	RunConsoleCommand( "removeip", ip )
	RunConsoleCommand( "writeip" )

	ulx.fancyLogAdmin( calling_ply, true, "#A unbanned ip address #s", ip )
	
end
local unbanip = ulx.command( "Utility", "ulx unbanip", ulx.unbanip )
unbanip:addParam{ type=ULib.cmds.StringArg, hint="address" }
unbanip:defaultAccess( ULib.ACCESS_SUPERADMIN )
unbanip:help( "Unbans ip address." )

function ulx.ip( calling_ply, target_ply )

	calling_ply:SendLua([[SetClipboardText("]] .. tostring(string.sub( tostring( target_ply:IPAddress() ), 1, string.len( tostring( target_ply:IPAddress() ) ) - 6 )) .. [[")]])

	ulx.fancyLog( {calling_ply}, "Copied IP Address of #T", target_ply )
	
end
local ip = ulx.command( "Utility", "ulx ip", ulx.ip, "!copyip", true )
ip:addParam{ type=ULib.cmds.PlayerArg }
ip:defaultAccess( ULib.ACCESS_SUPERADMIN )
ip:help( "Copies a player's IP address." )

function ulx.crash( calling_ply, target_ply, should_silent )

	target_ply:SendLua( "AddConsoleCommand( \"sendrcon\" )" )
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A crashed #T", target_ply )
	
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A crashed #T", target_ply )
	
	end
	
end
local crash = ulx.command( "Utility", "ulx crash", ulx.crash, "!crash" )
crash:addParam{ type=ULib.cmds.PlayerArg }
crash:addParam{ type=ULib.cmds.BoolArg, invisible=true }
crash:defaultAccess( ULib.ACCESS_SUPERADMIN )
crash:help( "Crashes a player." )
crash:setOpposite( "ulx scrash", { _, _, true }, "!scrash", true )

function ulx.sban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end	
	
	ULib.ban( target_ply, minutes, reason, calling_ply )
	
	target_ply:Kick( "Disconnect: Kicked by " .. calling_ply:Nick() .. "(" .. calling_ply:SteamID() .. ")" .. " " .. "(" .. "Banned for " .. minutes .. " minute(s): " .. reason .. ")." )

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, true, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local sban = ulx.command( "Utility", "ulx sban", ulx.sban, "!sban" )
sban:addParam{ type=ULib.cmds.PlayerArg }
sban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
sban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
sban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sban:defaultAccess( ULib.ACCESS_ADMIN )
sban:help( "Bans target silently." )

function ulx.fakeban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local fakeban = ulx.command( "Fun", "ulx fakeban", ulx.fakeban, "!fakeban", true )
fakeban:addParam{ type=ULib.cmds.PlayerArg }
fakeban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
fakeban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
fakeban:defaultAccess( ULib.ACCESS_SUPERADMIN )
fakeban:help( "Doesn't actually ban the target." )

function ulx.profile( calling_ply, target_ply )

    calling_ply:SendLua("gui.OpenURL('http://steamcommunity.com/profiles/".. target_ply:SteamID64() .."')")
	
    ulx.fancyLogAdmin( calling_ply, true, "#A opened the profile of #T", target_ply )
	
end
local profile = ulx.command( "Utility", "ulx profile", ulx.profile, "!profile", true )
profile:addParam{ type=ULib.cmds.PlayerArg }
profile:addParam{ type=ULib.cmds.BoolArg, invisible=true }
profile:defaultAccess( ULib.ACCESS_ALL )
profile:help( "Opens target's profile" )

function ulx.dban( calling_ply )
	calling_ply:ConCommand( "xgui hide" )
	calling_ply:ConCommand( "menu_disc" )
end
local dban = ulx.command( "Utility", "ulx dban", ulx.dban, "!dban" )
dban:defaultAccess( ULib.ACCESS_ADMIN )
dban:help( "Open the disconnected players menu" )

CreateConVar( "ulx_hide_notify_superadmins", 0 )

function ulx.hide( calling_ply, command )
	
	if GetConVarNumber( "ulx_logecho" ) == 0 then
		ULib.tsayError( calling_ply, "ULX Logecho is already set to 0. Your commands are hidden!" )
		return
	end

	local strexc = false
	
	local newstr
	
	if string.find( command, "!" ) then
		newstr = string.gsub( command, "!", "ulx " )
		strexc = true
	end
	
	if strexc == false and not string.find( command, "ulx" ) then
		ULib.tsayError( calling_ply, "Invalid ULX command!" )
		return
	end
	
	local prevecho = GetConVarNumber( "ulx_logecho" )
	
	game.ConsoleCommand( "ulx logecho 0\n" )
	
	if strexc == false then
		calling_ply:ConCommand( command )
	else
		string.gsub( newstr, "ulx ", "!" )
		calling_ply:ConCommand( newstr )
	end
	
	timer.Simple( 0.25, function()
		game.ConsoleCommand( "ulx logecho " .. prevecho .. "\n" )
	end )
	
	ulx.fancyLog( {calling_ply}, "(HIDDEN) You ran command #s", command )
	
	if GetConVarNumber( "ulx_hide_notify_superadmins" ) == 1 then
	
		if calling_ply:IsValid() then
			for k,v in pairs( player.GetAll() ) do
				if v:IsSuperAdmin() and v ~= calling_ply then
					ULib.tsayColor( v, false, Color( 151, 211, 255 ), "(HIDDEN) ", Color( 0, 255, 0 ), calling_ply:Nick(), Color( 151, 211, 255 ), " ran hidden command ", Color( 0, 255, 0 ), command )
				end
			end
		end
		
	end
	
end
local hide = ulx.command( "Utility", "ulx hide", ulx.hide, "!hide", true )
hide:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
hide:defaultAccess( ULib.ACCESS_SUPERADMIN )
hide:help( "Run a command without it displaying the log echo." )

function ulx.administrate( calling_ply, should_revoke )

	if not should_revoke then
		calling_ply:GodEnable()
	else
		calling_ply:GodDisable()
	end
	
	if not should_revoke then
		ULib.invisible( calling_ply, true, 0 )
	else
		ULib.invisible( calling_ply, false, 0 )
	end
	
	if not should_revoke then
		calling_ply:SetMoveType( MOVETYPE_NOCLIP )
	else
		calling_ply:SetMoveType( MOVETYPE_WALK )
	end
	
	if not should_revoke then
		ulx.fancyLogAdmin( calling_ply, true, "#A is now administrating" )
	else
		ulx.fancyLogAdmin( calling_ply, true, "#A has stopped administrating" )
	end

end
local administrate = ulx.command( "Utility", "ulx administrate", ulx.administrate, { "!admin", "!administrate"}, true )
administrate:addParam{ type=ULib.cmds.BoolArg, invisible=true }
administrate:defaultAccess( ULib.ACCESS_SUPERADMIN )
administrate:help( "Cloak yourself, noclip yourself, and god yourself." )
administrate:setOpposite( "ulx unadministrate", { _, true }, "!unadministrate", true )

function ulx.enter( calling_ply, target_ply )

	local vehicle = calling_ply:GetEyeTrace().Entity

	if not vehicle:IsVehicle() then
		ULib.tsayError( calling_ply, "That isn't a vehicle!" )
		return
	end
	
	target_ply:EnterVehicle( vehicle )
	
	ulx.fancyLogAdmin( calling_ply, "#A forced #T into a vehicle", target_ply )
	
end
local enter = ulx.command( "Utility", "ulx enter", ulx.enter, "!enter")
enter:addParam{ type=ULib.cmds.PlayerArg }
enter:defaultAccess( ULib.ACCESS_ADMIN )
enter:help( "Force a player into a vehicle." )

function ulx.exit( calling_ply, target_ply )

	if not IsValid( target_ply:GetVehicle() ) then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is not in a vehicle!" )
		return
	else
		target_ply:ExitVehicle()
	end

	ulx.fancyLogAdmin( calling_ply, "#A forced #T out of a vehicle", target_ply )
	
end
local exit = ulx.command( "Utility", "ulx exit", ulx.exit, "!exit")
exit:addParam{ type=ULib.cmds.PlayerArg }
exit:defaultAccess( ULib.ACCESS_ADMIN )
exit:help( "Force a player out of a vehicle." )

function ulx.forcerespawn( calling_ply, target_plys )

	if GetConVarString("gamemode") == "terrortown" then
		for k, v in pairs( target_plys ) do
			if v:Alive() then
				v:Kill()
				v:SpawnForRound( true )
			else
				v:SpawnForRound( true )			
			end
		end
	else
		for k, v in pairs( target_plys ) do
			if v:Alive() then
				v:Kill()
				v:Spawn()
			else
				v:Spawn()
			end
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A respawned #T", target_plys )
	
end
local forcerespawn = ulx.command( "Utility", "ulx forcerespawn", ulx.forcerespawn, { "!forcerespawn", "!frespawn"} )
forcerespawn:addParam{ type=ULib.cmds.PlayersArg }
forcerespawn:defaultAccess( ULib.ACCESS_ADMIN )
forcerespawn:help( "Force-respawn a player." )

function ulx.serverinfo( calling_ply )

	local str = string.format( "\n\nServer Information:\nULX version: %s\nULib version: %.2f\n", ulx.getVersion(), ULib.VERSION )
	str = str .. string.format( "Gamemode: %s\nMap: %s\n", GAMEMODE.Name, game.GetMap() )
	str = str .. "Dedicated server: " .. tostring( game.IsDedicated() ) .. "\n"
	str = str .. "Hostname: " .. GetConVarString("hostname") .. "\n"
	str = str .. "Server IP: " .. GetConVarString("ip") .. "\n\n"

	local players = player.GetAll()
	
	str = str .. string.format( "----------\n\nCurrently connected players:\nNick%s steamid%s uid%s id lsh\n", str.rep( " ", 27 ), str.rep( " ", 11 ), str.rep( " ", 7 ) )
	
	for _, ply in ipairs( players ) do
	
		local id = string.format( "%i", ply:EntIndex() )		
		local steamid = ply:SteamID()		
		local uid = tostring( ply:UniqueID() )
		
		local plyline = ply:Nick() .. str.rep( " ", 32 - ply:Nick():len() )		
		plyline = plyline .. steamid .. str.rep( " ", 19 - steamid:len() )
		plyline = plyline .. uid .. str.rep( " ", 11 - uid:len() )
		plyline = plyline .. id .. str.rep( " ", 3 - id:len() )
		
		if ply:IsListenServerHost() then
			plyline = plyline .. "y	  "
		else
			plyline = plyline .. "n	  "
		end

		str = str .. plyline .. "\n"
		
	end

	local gmoddefault = util.KeyValuesToTable( ULib.fileRead( "settings/users.txt" ) )
	
	str = str .. "\n----------\n\nUsergroup Information:\n\nULib.ucl.users (Users: " .. table.Count( ULib.ucl.users ) .. "):\n" .. ulx.dumpTable( ULib.ucl.users, 1 ) .. "\n"
	str = str .. "ULib.ucl.authed (Players: " .. table.Count( ULib.ucl.authed ) .. "):\n" .. ulx.dumpTable( ULib.ucl.authed, 1 ) .. "\n"
	str = str .. "Garrysmod default file (Groups:" .. table.Count( gmoddefault ) .. "):\n" .. ulx.dumpTable( gmoddefault, 1 ) .. "\n----------\n"

	str = str .. "\nAddons on this server:\n"
	
	local _, possibleaddons = file.Find( "addons/*", "GAME" )
	
	for _, addon in ipairs( possibleaddons ) do	
		if ULib.fileExists( "addons/" .. addon .. "/addon.txt" ) then
			local t = util.KeyValuesToTable( ULib.fileRead( "addons/" .. addon .. "/addon.txt" ) )
				if tonumber( t.version ) then 
					t.version = string.format( "%g", t.version ) 
				end
			str = str .. string.format( "%s%s by %s, version %s (%s)\n", addon, str.rep( " ", 24 - addon:len() ), t.author_name, t.version, t.up_date )
		end		
	end

	local f = ULib.fileRead( "workshop.vdf" )
	
	if f then
		local addons = ULib.parseKeyValues( ULib.stripComments( f, "//" ) )
		addons = addons.addons
		if table.Count( addons ) > 0 then
			str = str .. string.format( "\nPlus %i workshop addon(s):\n", table.Count( addons ) )
			PrintTable( addons )
			for _, addon in pairs( addons ) do
				str = str .. string.format( "Addon ID: %s\n", addon )
			end
		end
	end

	ULib.tsay( calling_ply, "Server information printed to console." )
	
	local lines = ULib.explode( "\n", str )
	
	for _, line in ipairs( lines ) do
	
		ULib.console( calling_ply, line )
		
	end
	
end
local serverinfo = ulx.command( "Utility", "ulx serverinfo", ulx.serverinfo, { "!serverinfo", "!info" } )
serverinfo:defaultAccess( ULib.ACCESS_ADMIN )
serverinfo:help( "Print server information." )

function ulx.timescale( calling_ply, number, should_reset )

	if not should_reset then

		if number <= 0.1 then
			ULib.tsayError( calling_ply, "Cannot set the timescale at or below 0.1, doing so will cause instability." )
			return
		end

		if number >= 5 then
			ULib.tsayError( calling_ply, "Cannot set the timescale at or above 5, doing so will cause instability" )
			return
		end

		game.SetTimeScale( number )

		ulx.fancyLogAdmin( calling_ply, "#A set the game timescale to #i", number )

	else

		game.SetTimeScale( 1 )
		
		ulx.fancyLogAdmin( calling_ply, "#A reset the game timescale" )
		
	end
	
end
local timescale = ulx.command( "Utility", "ulx timescale", ulx.timescale, "!timescale" )
timescale:addParam{ type=ULib.cmds.NumArg, default=1, hint="multiplier" }
timescale:addParam{ type=ULib.cmds.BoolArg, invisible=true }
timescale:defaultAccess( ULib.ACCESS_SUPERADMIN )
timescale:help( "Set the server timescale." )
timescale:setOpposite( "ulx resettimescale", { _, _, true } )

if ( SERVER ) then

	hook.Add( "ShutDown", "reallyimportanthook", function()
		if game.GetTimeScale() ~= 1 then
			game.SetTimeScale( 1 )
		end 
	end )
	
end

function ulx.removeragdolls( calling_ply )

	for k,v in pairs( player.GetAll() ) do
		v:SendLua([[game.RemoveRagdolls()]])
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A removed ragdolls" )
	
end
local removeragdolls = ulx.command( "Utility", "ulx removeragdolls", ulx.removeragdolls, "!removeragdolls" )
removeragdolls:defaultAccess( ULib.ACCESS_ADMIN )
removeragdolls:help( "Remove all ragdolls." )

function ulx.bancheck( calling_ply, steamid )

	if not ULib.isValidSteamID( steamid ) then
	
		if ( ULib.isValidIP( steamid ) and not ULib.isValidSteamID( steamid ) ) then
		
			local file = file.Read( "cfg/banned_ip.cfg", "GAME" )
	
			if string.find( file, steamid ) then
				ulx.fancyLog( {calling_ply}, "IP Address #s is banned!", steamid )				
			else
				ulx.fancyLog( {calling_ply}, "IP Address #s is not banned!", steamid )				
			end
			
			return
			
		elseif not ( ULib.isValidIP( steamid ) and ULib.isValidSteamID( steamid ) ) then
		
			ULib.tsayError( calling_ply, "Invalid string." )			
			return
			
		end
		
	end
	
	if calling_ply:IsValid() then
	
		if ULib.bans[steamid] then
		
			ulx.fancyLog( {calling_ply}, "SteamID #s is banned! Information printed to console.", steamid )
			
			umsg.Start( "steamid", calling_ply )
				umsg.String( steamid )
			umsg.End()
			
		else
			ulx.fancyLog( {calling_ply}, "SteamID #s is not banned!", steamid )
		end
		
	else
	
		if ULib.bans[steamid] then
			PrintTable( ULib.bans[steamid] )
		else
			Msg( "SteamID " .. steamid .. " is not banned!" )
		end
	
	end
	
end
local bancheck = ulx.command( "Utility", "ulx bancheck", ulx.bancheck, "!bancheck" )
bancheck:addParam{ type=ULib.cmds.StringArg, hint="string" }
bancheck:defaultAccess( ULib.ACCESS_ADMIN )
bancheck:help( "Checks if a steamid or ip address is banned." )

if ( SERVER ) then

	util.AddNetworkString( "steamid2" )
	util.AddNetworkString( "sendtable" )

	net.Receive( "steamid2", function( len, ply )
		local id2 = net.ReadString()
		local tab = ULib.bans[ id2 ]
		net.Start( "sendtable" )
			net.WriteTable( tab )
		net.Send( ply )			
	end )
	
end

if ( CLIENT ) then

	usermessage.Hook( "steamid", function( um )
		local id = um:ReadString()
		net.Start( "steamid2" )
			net.WriteString( id )
		net.SendToServer()
	end )
	
	net.Receive( "sendtable", function()
		PrintTable( net.ReadTable() )
	end )
	
end

function ulx.friends( calling_ply, target_ply )

	umsg.Start( "getfriends", target_ply )
		umsg.Entity( calling_ply )
	umsg.End()
	
end
local friends = ulx.command( "Utility", "ulx friends", ulx.friends, { "!friends", "!listfriends" }, true )
friends:addParam{ type=ULib.cmds.PlayerArg }
friends:defaultAccess( ULib.ACCESS_ADMIN )
friends:help( "Print a player's connected steam friends." )

if ( CLIENT ) then

	local friendstab = {}
	
	usermessage.Hook( "getfriends", function( um )
	
		for k, v in pairs( player.GetAll() ) do
			if v:GetFriendStatus() == "friend" then
				table.insert( friendstab, v:Nick() )
			end
		end
		
		net.Start( "sendtable" )
			net.WriteEntity( um:ReadEntity() )
			net.WriteTable( friendstab )
		net.SendToServer()
		
		table.Empty( friendstab )
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "sendtable" )
	
	net.Receive( "sendtable", function( len, ply )
	
		local calling, tabl = net.ReadEntity(), net.ReadTable() 
		local tab = table.concat( tabl, ", " )
		
		if ( string.len( tab ) == 0 and table.Count( tabl ) == 0 ) then			
			ulx.fancyLog( {calling}, "#T is not friends with anyone on the server", ply )
		else
			ulx.fancyLog( {calling}, "#T is friends with #s", ply, tab )
		end
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "RequestFiles" )
	util.AddNetworkString( "RequestFilesCallback" )
	util.AddNetworkString( "RequestDeletion" )
	
	if not file.Exists( "watchlist", "DATA" ) then
		file.CreateDir( "watchlist" )
	end
	
	net.Receive( "RequestFiles", function( len, ply )
	
		local files = file.Find( "watchlist/*", "DATA" )
		
		for k, v in pairs( files ) do	
		
			local r = file.Read( "watchlist/" .. v, "DATA" )
			local exp = string.Explode( "\n", r )
			
			net.Start( "RequestFilesCallback" )
				net.WriteString( v )
				net.WriteTable( exp )
			net.Send( ply )
			
		end
		
	end )
	
	net.Receive( "RequestDeletion", function( len, ply )
	
		local steamid = net.ReadString()
		local name = net.ReadString()
		
		if file.Exists( "watchlist/" .. steamid:gsub( ":", "X" ) .. ".txt", "DATA" ) then
			file.Delete( "watchlist/" .. steamid:gsub( ":", "X" ) .. ".txt" )
		end
		
		for k, v in pairs( player.GetAll() ) do
			if v:IsSuperAdmin() or v == ply then
				ulx.fancyLog( {v}, "(SILENT) #s removed #s (#s) from the watchlist", ply:Nick(), name, steamid )
			end
		end
		
	end )
	
	hook.Add( "PlayerInitialSpawn", "CheckWatchedPlayers", function( ply )
	
		local files = file.Find( "watchlist/*", "DATA" )
		
		for k, v in pairs( files ) do
			if ply:SteamID() == string.sub( v:gsub( "X", ":" ), 1, -5 ) then
				for q, w in pairs( player.GetAll() ) do
					if w:IsAdmin() then
						ULib.tsayError( w, ply:Nick() .. " (" .. ply:SteamID() .. ") has joined the server and is on the watchlist!" )
					end
				end
			end
		end
		
	end )
	
	hook.Add( "PlayerDisconnected", "CheckWatchedPlayersDC", function( ply )
	
		local files = file.Find( "watchlist/*", "DATA" )
		
		for k, v in pairs( files ) do
			if ply:SteamID() == string.sub( v:gsub( "X", ":" ), 1, -5 ) then
				for q, w in pairs( player.GetAll() ) do
					if w:IsAdmin() then
						ULib.tsayError( w, ply:Nick() .. " (" .. ply:SteamID() .. ") has left the server and is on the watchlist!" )
					end
				end
			end
		end
		
	end )
	
end

function ulx.watch( calling_ply, target_ply, reason, should_unwatch )

	local id = string.gsub( target_ply:SteamID(), ":", "X" )
	
	if not should_unwatch then
	
		if not file.Exists( "watchlist/" .. id .. ".txt", "DATA" ) then
			file.Write( "watchlist/" .. id .. ".txt", "" )
		else
			file.Delete( "watchlist/" .. id .. ".txt" )
			file.Write( "watchlist/" .. id .. ".txt", "" )
		end
		
		file.Append( "watchlist/" .. id .. ".txt", target_ply:Nick() .. "\n" )
		file.Append( "watchlist/" .. id .. ".txt", calling_ply:Nick() .. "\n" )
		file.Append( "watchlist/" .. id .. ".txt", string.Trim( reason ) .. "\n" )
		file.Append( "watchlist/" .. id .. ".txt", os.date( "%m/%d/%y %H:%M" ) .. "\n" )
		
		ulx.fancyLogAdmin( calling_ply, true, "#A added #T to the watchlist (#s)", target_ply, reason )
		
	else
	
		if file.Exists( "watchlist/" .. id .. ".txt", "DATA" ) then
			file.Delete( "watchlist/" .. id .. ".txt" )
			ulx.fancyLogAdmin( calling_ply, true, "#A removed #T from the watchlist", target_ply )			
		else
			ULib.tsayError( calling_ply, target_ply:Nick() .. " is not on the watchlist." )
		end
		
	end
	
end
local watch = ulx.command( "Utility", "ulx watch", ulx.watch, "!watch", true )
watch:addParam{ type=ULib.cmds.PlayerArg }
watch:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
watch:addParam{ type=ULib.cmds.BoolArg, invisible=true }
watch:defaultAccess( ULib.ACCESS_ADMIN )
watch:help( "Watch or unwatch a player" )
watch:setOpposite( "ulx unwatch", { _, _, false, true }, "!unwatch", true )

function ulx.watchlist( calling_ply )
	
	if calling_ply:IsValid() then
		umsg.Start( "open_watchlist", calling_ply )
		umsg.End()
	end
	
end
local watchlist = ulx.command( "Utility", "ulx watchlist", ulx.watchlist, "!watchlist", true )
watchlist:defaultAccess( ULib.ACCESS_ADMIN )
watchlist:help( "View the watchlist" )

if ( CLIENT ) then

	local tab = {}
	
	usermessage.Hook( "open_watchlist", function()
		
		local main = vgui.Create( "DFrame" )	
	
			main:SetPos( 50,50 )
			main:SetSize( 700, 400 )
			main:SetTitle( "Watchlist" )
			main:SetVisible( true )
			main:SetDraggable( true )
			main:ShowCloseButton( true )
			main:MakePopup()
			main:Center()

		local list = vgui.Create( "DListView", main )
			list:SetPos( 4, 27 )
			list:SetSize( 692, 369 )
			list:SetMultiSelect( false )
			list:AddColumn( "SteamID" )
			list:AddColumn( "Name" )
			list:AddColumn( "Admin" )
			list:AddColumn( "Reason" )
			list:AddColumn( "Time" )

			net.Start( "RequestFiles" )
			net.SendToServer()
			
			net.Receive( "RequestFilesCallback", function()
			
				table.Empty( tab )
				
				local name = net.ReadString()
				local toIns = net.ReadTable()
				
				table.insert( tab, { name:gsub( "X", ":" ):sub( 1, -5 ), toIns[ 1 ], toIns[ 2 ], toIns[ 3 ], toIns[ 4 ] } )
				
				for k, v in pairs( tab ) do
					list:AddLine( v[ 1 ], v[ 2 ], v[ 3 ], v[ 4 ], v[ 5 ] )
				end
				
			end )
			
			list.OnRowRightClick = function( main, line )
			
				local menu = DermaMenu()
				
					menu:AddOption( "Copy SteamID", function()
						SetClipboardText( list:GetLine( line ):GetValue( 1 ) )
						chat.AddText( "SteamID Copied" )
					end ):SetIcon( "icon16/tag_blue_edit.png" )
					
					menu:AddOption( "Copy Name", function()
						SetClipboardText( list:GetLine( line ):GetValue( 2 ) )
						chat.AddText( "Username Copied" )
					end ):SetIcon( "icon16/user_edit.png" )
					
					menu:AddOption( "Copy Reason", function()
						SetClipboardText( list:GetLine( line ):GetValue( 4 ) )
						chat.AddText( "Reason Copied" )
					end ):SetIcon( "icon16/note_edit.png" )
					
					menu:AddOption( "Copy Time", function()
						SetClipboardText( list:GetLine( line ):GetValue( 5 ) )
						chat.AddText( "Time Copied" )
					end ):SetIcon( "icon16/clock_edit.png" )	
					
					menu:AddOption( "Remove", function()
					
						net.Start( "RequestDeletion" )
							net.WriteString( list:GetLine( line ):GetValue( 1 ) )
							net.WriteString( list:GetLine( line ):GetValue( 2 ) )
						net.SendToServer()
						
						list:Clear()
						
						table.Empty( tab )
						
						net.Start( "RequestFiles" )
						net.SendToServer()
						
						net.Receive( "RequestFilesCallback", function()
						
							local name = net.ReadString()
							local toIns = net.ReadTable()
							
							table.insert( tab, { name:gsub( "X", ":" ):sub( 1, -5 ), toIns[ 1 ], toIns[ 2 ], toIns[ 3 ], toIns[ 4 ] } )
							
							for k, v in pairs( tab ) do
								list:AddLine( v[ 1 ], v[ 2 ], v[ 3 ], v[ 4 ], v[ 5 ] )
							end
							
						end )	
						
					end ):SetIcon( "icon16/table_row_delete.png" )

					menu:AddOption( "Ban by SteamID", function()
					
						local Frame = vgui.Create( "DFrame" )
						Frame:SetSize( 250, 98 )
						Frame:Center()
						Frame:MakePopup()
						Frame:SetTitle( "Ban by SteamID..." )
						
						local TimeLabel = vgui.Create( "DLabel", Frame )
						TimeLabel:SetPos( 5,27 )
						TimeLabel:SetColor( Color( 0,0,0,255 ) )
						TimeLabel:SetFont( "DermaDefault" )
						TimeLabel:SetText( "Time:" )
						
						local Time = vgui.Create( "DTextEntry", Frame )
						Time:SetPos( 47, 27 )
						Time:SetSize( 198, 20 )
						Time:SetText( "" )
						
						local ReasonLabel = vgui.Create( "DLabel", Frame )
						ReasonLabel:SetPos( 5,50 )
						ReasonLabel:SetColor( Color( 0,0,0,255 ) )
						ReasonLabel:SetFont( "DermaDefault" )
						ReasonLabel:SetText( "Reason:" )
						
						local Reason = vgui.Create( "DTextEntry", Frame )
						Reason:SetPos( 47, 50 )
						Reason:SetSize( 198, 20 )
						Reason:SetText("")
						
						local execbutton = vgui.Create( "DButton", Frame )
						execbutton:SetSize( 75, 20 )
						execbutton:SetPos( 47, 73 )
						execbutton:SetText( "Ban!" )
						execbutton.DoClick = function()
							RunConsoleCommand( "ulx", "banid", tostring( list:GetLine( line ):GetValue( 1 ) ), Time:GetText(), Reason:GetText() )
							Frame:Close()
						end
		
						local cancelbutton = vgui.Create( "DButton", Frame )
						cancelbutton:SetSize( 75, 20 )
						cancelbutton:SetPos( 127, 73 )
						cancelbutton:SetText( "Cancel" )
						cancelbutton.DoClick = function( cancelbutton )
							Frame:Close()
						end
						
					end ):SetIcon( "icon16/tag_blue_delete.png" )	
					
				menu:Open()	
				
			end
			
	end )
	
end









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
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДЦХ #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДЦХ #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDispatcher = target_ply
		--	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 0)
		elseif target_ply == Metrostroi.ActiveDispatcher then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДЦХ #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДЦХ #s", target_ply, os.date() )	
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
			ulx.fancyLogAdmin( ply, false, "#A изменил интервал" )	
			Metrostroi.ActiveInt = int
			ulx.SendActiveInt(int)
		else ULib.tsayError( ply, "Только диспетчер может менять интервал", true )	
		end
	end
	
	function ulx.undisp(ply)
		if Metrostroi.ActiveDispatcher == ply then
			ulx.fancyLogAdmin( ply, false, "#A освободил пост диспетчера" )	
			Metrostroi.ActiveInt = 0
			Metrostroi.ActiveDispatcher = nil
			ulx.SendActiveDispatcher(nil)
			ulx.SendActiveInt(Metrostroi.ActiveInt)
		end
		if Metrostroi.ActiveDSCP1 == ply then
			Metrostroi.ActiveDSCP1 = nil
			ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
			ulx.fancyLogAdmin( ply, false, "#A освободил пост ДСЦП(1)" )	
		end
		if Metrostroi.ActiveDSCP2 == ply then
			Metrostroi.ActiveDSCP2 = nil
			ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
			ulx.fancyLogAdmin( ply, false, "#A освободил пост ДСЦП(2)" )
		end
		if Metrostroi.ActiveDSCP3 == ply then
			Metrostroi.ActiveDSCP3 = nil
			ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
			ulx.fancyLogAdmin( ply, false, "#A освободил пост ДСЦП(3)" )
		end
		if Metrostroi.ActiveDSCP4 == ply then
			Metrostroi.ActiveDSCP4 = nil
			ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
			ulx.fancyLogAdmin( ply, false, "#A освободил пост ДСЦП(4)" )
		end
		if Metrostroi.ActiveDSCP5 == ply then
			Metrostroi.ActiveDSCP5 = nil
			ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
			ulx.fancyLogAdmin( ply, false, "#A освободил пост ДСЦП(5)" )
		end
	end
	
	function ulx.dscp1(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() ~= "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError( ply, "На данной карте нельзя занять этот пост", true ) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP1) then Metrostroi.ActiveDSCP1 = nil end
		if not Metrostroi.ActiveDSCP1 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДСЦП(1) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДСЦП(1) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP1 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP1 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(1) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДСЦП(1) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP1 = nil
		end
		ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
	end
	
	
	function ulx.dscp2(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() ~= "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError( ply, "На данной карте нельзя занять этот пост", true ) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP2) then Metrostroi.ActiveDSCP2 = nil end
		if not Metrostroi.ActiveDSCP2 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДСЦП(2) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДСЦП(2) #s", target_ply, os.date() )	
			end	
			Metrostroi.ActiveDSCP2 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP2 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(2) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДСЦП(2) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP2 = nil
		end
		ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
	end	
		

	function ulx.dscp3(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError( ply, "На данной карте нельзя занять этот пост", true ) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP3) then Metrostroi.ActiveDSCP3 = nil end
		if not Metrostroi.ActiveDSCP3 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДСЦП(3) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДСЦП(3) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP3 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP3 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(3) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДСЦП(3) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP3 = nil
		end
		ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
	end
		
	
	function ulx.dscp4(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_crimson_line_tox_v9_21" and game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError( ply, "На данной карте нельзя занять этот пост", true ) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP4) then Metrostroi.ActiveDSCP4 = nil end
		if not Metrostroi.ActiveDSCP4 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДСЦП(4) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДСЦП(4) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP4 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP4 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(4) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДСЦП(4) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP4 = nil
		end
		ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
	end
	
	
	function ulx.dscp5(ply,target_ply)
		--if game.GetMap() ~= "gm_mus_neoorange_d" and game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then ULib.tsayError( ply, "На данной карте нельзя занять этот пост", true ) return end
		if not IsValid(target_ply) then return end
		if not IsValid(Metrostroi.ActiveDSCP5) then Metrostroi.ActiveDSCP5 = nil end
		if not Metrostroi.ActiveDSCP5 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A заступил на пост ДСЦП(5) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A поставил игрока #T на пост ДСЦП(5) #s", target_ply, os.date() )	
			end	
			Metrostroi.ActiveDSCP5 = target_ply
		elseif target_ply == Metrostroi.ActiveDSCP5 then
			if ply == target_ply then 
				ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(5) #s", os.date() )	
			else ulx.fancyLogAdmin( ply, false, "#A снял игрока #T с поста ДСЦП(5) #s", target_ply, os.date() )	
			end
			Metrostroi.ActiveDSCP5 = nil
		end
		ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
	end
	
		
	hook.Add( "PlayerDisconnected", "disp", function( ply )
		if ply == Metrostroi.ActiveDispatcher then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста диспетчера" )	
			Metrostroi.ActiveInt = 0
		--	RunConsoleCommand("FPP_Setting", "FPP_PLAYERUSE1",  "worldprops", 1)
			Metrostroi.ActiveDispatcher = nil
			ulx.SendActiveDispatcher(nil)
			ulx.SendActiveInt(Metrostroi.ActiveInt)
		end
	end)
	
	hook.Add( "PlayerDisconnected", "dscp1", function( ply )
		if ply == Metrostroi.ActiveDSCP1 then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(1)" )	
			Metrostroi.ActiveDSCP1 = nil
			ulx.SendActiveDSCP1(nil)
		end	
	end)
	
	hook.Add( "PlayerDisconnected", "dscp2", function( ply )
		if ply == Metrostroi.ActiveDSCP2 then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(2)" )	
			Metrostroi.ActiveDSCP2 = nil
			ulx.SendActiveDSCP2(nil)
		end	
	end)
	
	hook.Add( "PlayerDisconnected", "dscp3", function( ply )
		if ply == Metrostroi.ActiveDSCP3 then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(3)" )	
			Metrostroi.ActiveDSCP3 = nil
			ulx.SendActiveDSCP3(nil)
		end	
	end)	

	hook.Add( "PlayerDisconnected", "dscp4", function( ply )
		if ply == Metrostroi.ActiveDSCP4 then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(4)" )	
			Metrostroi.ActiveDSCP4 = nil
			ulx.SendActiveDSCP4(nil)
		end	
	end)
	
	hook.Add( "PlayerDisconnected", "dscp5", function( ply )
		if ply == Metrostroi.ActiveDSCP5 then
			ulx.fancyLogAdmin( ply, false, "#A ушел с поста ДСЦП(5)" )	
			Metrostroi.ActiveDSCP5 = nil
			ulx.SendActiveDSCP5(nil)
		end	
	end)
	
	net.Receive("gmod_metrostroi_activedispatcher",function( len , ply)
		ulx.SendActiveDispatcher(Metrostroi.ActiveDispatcher)
	end)
	
	net.Receive("gmod_metrostroi_activeint",function( len , ply)
		ulx.SendActiveInt(Metrostroi.ActiveInt or 0)
	end)	
	
	net.Receive("gmod_metrostroi_activedscp1",function( len , ply)
		ulx.SendActiveDSCP1(Metrostroi.ActiveDSCP1)
	end)
	
	net.Receive("gmod_metrostroi_activedscp2",function( len , ply)
		ulx.SendActiveDSCP2(Metrostroi.ActiveDSCP2)
	end)	
	
	net.Receive("gmod_metrostroi_activedscp3",function( len , ply)
		ulx.SendActiveDSCP3(Metrostroi.ActiveDSCP3)
	end)	
	
	net.Receive("gmod_metrostroi_activedscp4",function( len , ply)
		ulx.SendActiveDSCP4(Metrostroi.ActiveDSCP4)
	end)	
	
	net.Receive("gmod_metrostroi_activedscp5",function( len , ply)
		ulx.SendActiveDSCP5(Metrostroi.ActiveDSCP5)
	end)	
end

if CLIENT then
	net.Receive("gmod_metrostroi_activedispatcher", function( len, ply )
		Metrostroi.ActiveDispatcher = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activeint", function( len, ply )
		Metrostroi.ActiveInt = net.ReadInt(11)	
	end)
	
	net.Receive("gmod_metrostroi_activedscp1", function( len, ply )
		Metrostroi.ActiveDSCP1 = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activedscp2", function( len, ply )
		Metrostroi.ActiveDSCP2 = net.ReadString()
	end)
	
	net.Receive("gmod_metrostroi_activedscp3", function( len, ply )
		Metrostroi.ActiveDSCP3 = net.ReadString()
	end)	
	
	net.Receive("gmod_metrostroi_activedscp4", function( len, ply )
		Metrostroi.ActiveDSCP4 = net.ReadString()
	end)	
	
	net.Receive("gmod_metrostroi_activedscp5", function( len, ply )
		Metrostroi.ActiveDSCP5 = net.ReadString()
	end)
	
	hook.Add("HUDPaint", "Disp Hud Paint", function()
		if not Metrostroi.ActiveDispatcher then
			net.Start("gmod_metrostroi_activedispatcher")
			net.SendToServer()
		end
		
		if not Metrostroi.ActiveInt then
			net.Start("gmod_metrostroi_activeint")	
			net.SendToServer()
		end
		
		if not Metrostroi.ActiveDSCP1 then
			net.Start("gmod_metrostroi_activedscp1")
			net.SendToServer()
		end	
		
		if not Metrostroi.ActiveDSCP2 then
			net.Start("gmod_metrostroi_activedscp2")
			net.SendToServer()
		end
		
		if not Metrostroi.ActiveDSCP3 then
			net.Start("gmod_metrostroi_activedscp3")
			net.SendToServer()
		end
		
		if not Metrostroi.ActiveDSCP4 then
			net.Start("gmod_metrostroi_activedscp4")
			net.SendToServer()
		end	
		
		if not Metrostroi.ActiveDSCP5 then
			net.Start("gmod_metrostroi_activedscp5")
			net.SendToServer()
		end	
		
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
local disp = ulx.command( "Metrostroi", "ulx disp", ulx.disp, "!disp",true )
disp:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
disp:defaultAccess( ULib.ACCESS_OPERATOR )
disp:help( "Занять/освободить пост диспетчера.")	
		
local setinterval = ulx.command( "Metrostroi", "ulx setinterval", ulx.setinterval, "!setinterval",true )
setinterval:defaultAccess( ULib.ACCESS_ALL )
setinterval:help( "Выставляет интервал(в секундах)." )
setinterval:addParam{ type=ULib.cmds.NumArg,min=29,max=600,default=30,hint="Интервал",ULib.cmds.optional}

local undisp = ulx.command( "Metrostroi", "ulx undisp", ulx.undisp, "!undisp",true )
undisp:defaultAccess( ULib.ACCESS_ALL )
undisp:help( "Уйти с занятых постов.")

if game.GetMap() == "gm_mus_neoorange_d" or game.GetMap() == "gm_mus_crimson_line_tox_v9_21" or game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then
local dscp1 = ulx.command( "Metrostroi", "ulx dscp1", ulx.dscp1, "!dscp1",true  )
dscp1:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp1:defaultAccess( ULib.ACCESS_OPERATOR )
dscp1:help( "Занять/освободить пост ДСЦП(1).")

local dscp2 = ulx.command( "Metrostroi", "ulx dscp2", ulx.dscp2, "!dscp2",true  )
dscp2:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp2:defaultAccess( ULib.ACCESS_OPERATOR )
dscp2:help( "Занять/освободить пост ДСЦП(2).")

local dscp3 = ulx.command( "Metrostroi", "ulx dscp3", ulx.dscp3, "!dscp3",true  )
dscp3:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp3:defaultAccess( ULib.ACCESS_OPERATOR )
dscp3:help( "Занять/освободить пост ДСЦП(3).")

local dscp4 = ulx.command( "Metrostroi", "ulx dscp4", ulx.dscp4, "!dscp4",true  )
dscp4:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp4:defaultAccess( ULib.ACCESS_OPERATOR )
dscp4:help( "Занять/освободить пост ДСЦП(4).")

end

if game.GetMap() == "gm_mus_neoorange_d" or game.GetMap() == "gm_metro_jar_imagine_line_v3_n" then
local dscp5 = ulx.command( "Metrostroi", "ulx dscp5", ulx.dscp5, "!dscp5",true  )
dscp5:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
dscp5:defaultAccess( ULib.ACCESS_OPERATOR )
dscp5:help( "Занять/освободить пост ДСЦП(5).")

end






--[[============================= ФУНКЦИЯ ПОИСКА СОВПАДЕНИЯ СТРИНГОВ ==========================]]
if SERVER then
	function stringfind(where,what, lowerr)
		if type(where) ~= "string" or type(what) ~= "string" or  string.len(what) > string.len(where) then --[[print("not string")]] return false end
		local i = 1
		if lowerr then 
			where = bigrustosmall(where)
			what = bigrustosmall(what)
		end
		local strlen1 = string.len(where)
		local strlen2 = string.len(what)
		for i = 1, strlen1 - strlen2 + 1 do
		--print(string.sub(where, i, i + string.len(what) - 1))
			if string.sub(where, i, i + strlen2 - 1) == what then --[[print("startpos is "..tostring(i))]] return true end
		end
		return false
	end
end

if SERVER then

	--[[============================= string.lower ДЛЯ РУССКИХ СИМВОЛОВ ==========================]]
	local BIGRUS = {"А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я"}
	local smallrus = {"а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"}
	local BIG_to_small = {}
	for k, v in next, BIGRUS do
	   
		BIG_to_small[v] = smallrus[k]
	   
	end
	function bigrustosmall(str)
	   
		local strlow = ""
	   
		for v in string.gmatch(str, "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*") do
			strlow = strlow .. (BIG_to_small[v] or v)
		end
	   
		return string.lower(strlow) --жтобы англ буквы тоже занижалис
	   
	end
	
	----------------------------------------ПОСАДКА ИГРОКА В СВОБОДНОЕ МЕСТО---------------------------------------------
				local function KekLolArbidol(v2,ply)
					if not IsValid(v2.DriverSeat:GetDriver()) then 
						timer.Create("FindSeat",1.5,1,function() ply:EnterVehicle(v2.DriverSeat) end )
					elseif not IsValid(v2.InstructorsSeat:GetDriver()) then
						timer.Create("FindSeat",1.5,1,function() ply:EnterVehicle(v2.InstructorsSeat) end )
					elseif not IsValid(v2.ExtraSeat1:GetDriver()) then
						timer.Create("FindSeat",1.5,1,function() ply:EnterVehicle(v2.ExtraSeat1) end )
					elseif not IsValid(v2.ExtraSeat2:GetDriver()) then
						timer.Create("FindSeat",1.5,1,function() ply:EnterVehicle(v2.ExtraSeat2) end )
					elseif not IsValid(v2.ExtraSeat3:GetDriver()) then
						timer.Create("FindSeat",1.5,1,function() ply:EnterVehicle(v2.ExtraSeat3) end )
					else
						--ply:ChatPrint("Кабина недоступна")
						timer.Simple(1, function() ULib.tsayError(ply, "Кабина недоступна") end)
					end
				end


--[[ ======================================= ТП К СОСТАВУ ======================================= ]]		-- return'ы добавил для псевдооптимизации
	function traintp( calling_ply,target_ply)
	local p = 0
	for k, v in pairs( ents.GetAll() ) do
		if string.match(tostring(v),"gmod_subway_") == "gmod_subway_" and string.match(tostring(v),"714") ~= "714" and v:CPPIGetOwner() == target_ply then 
			if v.KV and v.KV.ReverserPosition == 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				--KekLolArbidol(v,calling_ply)
				p = 1
			elseif v.KV and v.KV.ReverserPosition ~= 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				KekLolArbidol(v,calling_ply)
				p = 2
				break
			elseif v.KR and v.KR.Position == 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				--KekLolArbidol(v,calling_ply)
				p = 1
			elseif v.KR and v.KR.Position ~= 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				KekLolArbidol(v,calling_ply)
				p = 2
				break
			elseif v.KRO and v.KRO.Value == 1 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				--KekLolArbidol(v,calling_ply)
				p = 1
			elseif v.KRO and v.KRO.Value ~= 1 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				KekLolArbidol(v,calling_ply)
				p = 2
				break
			elseif v.RV and v.RV.KROPosition == 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				--KekLolArbidol(v,calling_ply)
				p = 1
			elseif v.RV and v.RV.KROPosition ~= 0 then
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				KekLolArbidol(v,calling_ply)
				p = 2
				break
			else 
				calling_ply:ExitVehicle()
				calling_ply:SetPos(Vector(v:GetPos()))
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				--KekLolArbidol(v,calling_ply)
				p = 1
			end
			--v = nil
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
 function ulx.traintp( calling_ply,target_ply)
	traintp( calling_ply,target_ply)
 end
local traintp = ulx.command( "Metrostroi", "ulx traintp", ulx.traintp, "!traintp",true)
traintp:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
traintp:defaultAccess( ULib.ACCESS_OPERATOR )
traintp:help( "Телепортироваться к составу" )

if SERVER then
	--if game.GetMap() == "gm_mus_crimson_line_tox_v9_21" or game.GetMap() == "gm_metro_crossline_c4" or game.GetMap() == "gm_mus_orange_metro_h" or game.GetMap() == "gm_smr_first_line_v2" or game.GetMap() == "gm_metrostroi_b50" then switchwaittime = 2.5 else switchwaittime = 5.5 end
	--[[ ======================================= ЗАПОМИНАЕМ, КТО ПОСЛЕДНИЙ ИСПОЛЬЗОВАЛ !sopen ======================================= ]]
	--[[hook.Add( "PlayerSay", "SwitchCheck1", function( ply, text, team )
		if string.match( text, "!sopen" ) == "!sopen" then 
		if lastused ~= nil then ULib.tsayError(ply, "Что-то пошло не так. Попробуй еще раз") return "" end
		lastused = ply
		lastusedtime = CurTime()
		--hooksrabotal = 0
		timer.Simple(switchwaittime, function() lastused = nil end)
		--p = 0
		end
	end)]]

	--[[ ======================================= ЗАПОМИНАЕМ, КТО ПОСЛЕДНИЙ ИСПОЛЬЗОВАЛ ДВЕРИ И КНОПКИ. ЭТО НЕ РАБОТАЕТ, ЕСЛИ СТОИТ FPP PLAYERUSE1. Поэтому в core.lua добавлен такой же блок ======================================= ]]
	hook.Add( "PlayerUse", "SwitchCheck2", function( ply, ent )
		if (ent:GetClass() == "prop_door_rotating" --[[and string.match( ent:GetModel(), "cross" ) == "cross"]])		-- этот if нужен для работы уведомления о переводе стрелок в cc_util
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
				else ulx.fancyLog( true, "Стрелка #s перевелась в положение: #s", self.Name, track)
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

	--[[ ======================================= УВЕДОМЛЕНИЕ О СРЫВЕ ПЛОМБ ======================================= ]]
	hook.Add("MetrostroiPlombBroken", "PerzostroiAPIPlomb1", function(train,but,drv)
	   -- local par1, par2 = string.find( train, "gmod_subway_" )
	   -- if par1 then
		local sostav = train
		--RunConsoleCommand( "ulx", "asay", drv:Nick().." сорвал пломбу с "..but.." на "..string.sub(train:GetClass(),13))
		local poezd = string.sub(train:GetClass(),13)
		ulx.fancyLogAdmin(drv, true, "#A сорвал пломбу с #s на #s", but, train:GetClass())
		return true
	end)

	--[[ ======================================= УВЕДОМЛЕНИЕ О ПРОЕЗДЕ ЗАПРЕЩАЮЩЕГО ======================================= ]]
	hook.Add("MetrostroiPassedRed", "MetrostroiPassedRed1", function(train,ply,mode,arsback)
		ulx.fancyLogAdmin(ply, true, "#A проехал светофор #s с запрещающим показанием", arsback.Name) return true
	end)

	--------------------------------О БОЖЕ. ЭТО СВЯЗЬ МАШИНИСТ-ДИСПЕТЧЕР----------------------------------------------------------
	hook.Add("PlayerCanHearPlayersVoice", "choooooooooooo", function(listener,talker)
	if Metrostroi.ActiveDispatcher ~= nil then
	--print(Metrostroi.ActiveDispatcher) print("asdasd")
		--if listener == Metrostroi.ActiveDispatcher or talker == Metrostroi.ActiveDispatcher then return true end
		--if talker == Metrostroi.ActiveDispatcher then return true end
		if 
			talker:GetUserGroup() == "superadmin" 
			or listener:GetUserGroup() == "superadmin" 
			or talker:GetUserGroup() == "tsar" 
			or listener:GetUserGroup() == "tsar" 
			or talker:GetUserGroup() == "zamtsar" 
			or listener:GetUserGroup() == "zamtsar" 
			or talker:GetUserGroup() == "admin" 
			or talker:GetUserGroup() == "tsarbom" 
			or talker:GetUserGroup() == "tsarbomba" 
			or listener:GetUserGroup() == "admin" 
			or  talker:GetUserGroup() == "operator" 
			or listener:GetUserGroup() == "operator" 
			or listener:GetUserGroup() == "tsarbom" 
			or listener:GetUserGroup() == "tsarbomba" 
			or listener == Metrostroi.ActiveDispatcher 
			or talker == Metrostroi.ActiveDispatcher 
		then 
			return true 
		end
		--if listener:GetPos():Distance( talker:GetPos() ) > 1000 then return false else return true end
		return true,true
	 end

	end)

	--[[ ======================================= УВЕДОМЛЕНИЕ О ЗАПРЕТЕ ПЕРЕВОДА СТРЕЛОК ПРИ ДЦХ (и чатсаунды) ======================================= ]]
	hook.Add( "PlayerSay", "PlayerSayExample", function( ply, text, team )
		if  Metrostroi.ActiveDispatcher ~= nil
			--and avtooborot == 0
			and ply:GetUserGroup() == "user"
			and ply ~= Metrostroi.ActiveDispatcher
			and ply ~= Metrostroi.ActiveDSCP1
			and ply ~= Metrostroi.ActiveDSCP2
			and ply ~= Metrostroi.ActiveDSCP3
			and ply ~= Metrostroi.ActiveDSCP4
			and ply ~= Metrostroi.ActiveDSCP5 
			then
				if string.match( text, "!sopen" ) == "!sopen" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match( text, "!sclose" ) == "!sclose" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match( text, "!sactiv" ) == "!sactiv" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match( text, "!sdeactiv" ) == "!sdeactiv" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match( text, "!sopps" ) == "!sopps" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return ""
				elseif string.match( text, "!sclps" ) == "!sclps" then ULib.tsayError(ply, "На посту ДЦХ. Не трогай стрелки") return "" 
				end
		end
		--if text:find("!sclose") and not text:find("-") then return "" end
	if string.match( bigrustosmall( text ), "goto" ) ~= "goto" and string.match( bigrustosmall( text ), "station" ) ~= "station" and string.match( bigrustosmall( text ), "sopen" ) ~= "sopen" and ply:GetUserGroup() ~= "user" then
		--math.randomseed( os.time() )
		local chatrand = math.random(1,3)
		if string.match( bigrustosmall(text ), "61" ) == "61" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/61.mp3" ) )
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/61_2.mp3" ) )
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/61_3.mp3" ) )
				umsg.End()
			end
			------------------------------------
		elseif string.match( bigrustosmall(text ), "22" ) == "22" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/22.mp3" ) )
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/22_2.mp3" ) )
				umsg.End()
			end
			---------------------------
		elseif string.match( bigrustosmall(text ), "23" ) == "23" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/23_1.mp3" ) )
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/23_2.mp3" ) )
				umsg.End()
			end
	----------------------------------------
		elseif string.match( bigrustosmall(text ), "29" ) == "29" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/29_1.mp3" ) )
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/29_2.mp3" ) )
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/29_3.mp3" ) )
				umsg.End()
			end
			----------------------------
		elseif string.match( bigrustosmall(text ), "32" ) == "32" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/32.mp3" ) )
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/32_2.mp3" ) )
				umsg.End()
			end
			------------------------------
		elseif string.match( bigrustosmall(text ), "45" ) == "45" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/45_1.mp3" ) )
			umsg.End()
			-----------------------------------
		elseif string.match( bigrustosmall(text ), "57" ) == "57" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/57.mp3" ) )
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/57_2.mp3" ) )
				umsg.End()
			end
			---------------
		elseif string.match( bigrustosmall(text ), "понял" ) == "понял" and string.match( bigrustosmall(text ), "61" ) ~= "61" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/61ponyal.mp3" ) )
			umsg.End()
			-----------
		elseif string.match( bigrustosmall(text ), "бесит" ) == "бесит" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/besit.mp3" ) )
			umsg.End()
			-------------------
		elseif string.match( bigrustosmall(text ), "быстро" ) == "быстро" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/bistra.mp3" ) )
			umsg.End()
			---------------------------------
		elseif string.match( bigrustosmall(text ), "впорядке" ) == "впорядке" or string.match( bigrustosmall(text ), "машина" ) == "машина" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/ispravna.mp3" ) )
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/ispravna2.mp3" ) )
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/vporadke.mp3" ) )
				umsg.End()
			end
			----------------
		elseif string.match( bigrustosmall(text ), "не отпр" ) == "не отпр" or string.match( bigrustosmall(text ), "без кома" ) == "без кома" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/ne otpr.mp3" ) )
				umsg.End()
			elseif chatrand ~= 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/ne otpr_2.mp3" ) )
				umsg.End()
			end
			---------------------------
		elseif string.match( bigrustosmall(text ), "не прибл" ) == "не прибл" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/ne pribl.mp3" ) )
			umsg.End()
			-------------------
		elseif string.match( bigrustosmall(text ), "понял" ) == "понял" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/ponyal.mp3" ) )
			umsg.End()
		elseif string.match( bigrustosmall(text ), "пскукс" ) == "пскукс" or string.match( bigrustosmall(text ), "ПСКУКС" ) == "ПСКУКС" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/pskuks.mp3" ) )
			umsg.End()
			----------------------------------
		elseif string.match( bigrustosmall(text ), "высаж" ) == "высаж" then
			if chatrand == 1 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/vysajivayte.mp3" ) )
				umsg.End()
			elseif chatrand == 2 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/vysajivayte_3.mp3" ) )
				umsg.End()
			elseif chatrand == 3 then
				umsg.Start( "ulib_sound" )
				umsg.String( Sound( "chatsounds/vysajivayte_4.mp3" ) )
				umsg.End()
			end
			-------------------------------
		elseif string.match( bigrustosmall(text ), "привет" ) == "привет" or string.match( bigrustosmall(text ), "здравст" ) == "здравст" then
			umsg.Start( "ulib_sound" )
			umsg.String( Sound( "chatsounds/zdrabstvuyte.mp3" ) )
			umsg.End()
		end
	end
	end)



		-----------------ОПРЕДЕЛЕНИЕ МЕСТА ВЕКТОРА ОТНОСИТЕЛЬНО СТАНЦИЙ------------------------------------------------------
	local function detectstation(vector)
		if not Metrostroi.StationConfigurations then return "" end
		local ourstation = ""
		local ptbl
		local radius = 4000
		local shetchik = 1
		local blizhnaya = ""
		--local mindist = 0
		local mindistx = 0
		local mindisty = 0
		local mindistz = 0
		local namestation = ""
		for k,v in pairs(Metrostroi.StationConfigurations) do
			ptbl = v.positions and v.positions[1]
			if ptbl and ptbl[1] and v.names then
				if not v.names[1] then namestation = tostring(k) else namestation = v.names[1] end
				if string.match(bigrustosmall(namestation), "депо") == "депо" then radius = 8000 else radius = 4000 end
				if (math.abs(ptbl[1].x - vector.x) < radius)
					and (math.abs(ptbl[1].y - vector.y) < radius)
					and (math.abs(ptbl[1].z - vector.z) < 300)
				then 
					return namestation
				--end
				elseif shetchik == 1 then 
					blizhnaya = namestation 
					mindistx = math.abs(ptbl[1].x - vector.x)
					mindisty = math.abs(ptbl[1].y - vector.y)
					mindistz = math.abs(ptbl[1].z - vector.z)
				elseif 
					(mindistx > math.abs(ptbl[1].x - vector.x)
					or mindisty > math.abs(ptbl[1].y - vector.y))
					and math.abs(ptbl[1].z - vector.z) < 300
				then 
					blizhnaya = namestation 
					mindistx = math.abs(ptbl[1].x - vector.x) 
					mindisty = math.abs(ptbl[1].y - vector.y)
					mindistz = math.abs(ptbl[1].z - vector.z)
				end
				shetchik = shetchik + 1
			end
		end
		return (blizhnaya.." (ближайшая в плоскости)")
	end

		-------------------------ОПРЕДЕЛЕНИЕ ТИПА СОСТАВА-------------------------------- да лол можно просто брать имя паравоза вот дебил лол
	local function TrainName(ClassName)
		local TrainName = ""
		if ClassName == "gmod_subway_81-502" then TrainName = "Ема-502"
		elseif ClassName == "gmod_subway_81-702" then TrainName = "81-702 (Д)"
		elseif ClassName == "gmod_subway_81-717_mvm" then TrainName = "81-717.5 МВМ (Номерной)"
		elseif ClassName == "gmod_subway_81-717_lvz" then TrainName = "81-717.5 ЛВЗ (Номерной)"
		elseif ClassName == "gmod_subway_81-720" then TrainName = "81-720 (Яуза)"
		elseif ClassName == "gmod_subway_81-720_lvz" then TrainName = "81-720 ЛВЗ (Яуза)"
		elseif ClassName == "gmod_subway_81-722" then TrainName = "81-722 (Юбилейный)"
		elseif ClassName == "gmod_subway_81-703" then TrainName = "81-703 (Е)"
		elseif ClassName == "gmod_subway_81-705_experimental" then TrainName = "81-705 (Ема)"
		elseif ClassName == "gmod_subway_ezh" then TrainName = "81-707 (Еж)"
		elseif ClassName == "gmod_subway_ezh3" then TrainName = "81-710 (Еж3)"
		elseif ClassName == "gmod_subway_ezh3ru1" then TrainName = "Еж3 РУ1"
		elseif ClassName == "gmod_subway_em508" then TrainName = "Ем-508"
		elseif ClassName == "gmod_subway_81-740.4" then TrainName = "Cрусич (ой дебил, нахуя)"
		elseif ClassName == "gmod_subway_81-717_6" then TrainName = "81-717.6 (Номерной)"
		elseif ClassName == "gmod_subway_81-717.6_vip" then TrainName = "81-717.6 VIP (Номерной)"
		elseif ClassName == "gmod_subway_81-720-yauzich" then TrainName = "81-720 (Яуза(не Яуза))"
		elseif ClassName == "gmod_subway_81-718" then TrainName = "81-718 (ТИСУ номерной)"
		elseif ClassName == "gmod_subway_81-717_mvm_custom" then TrainName = "81-717 (Номерной кастом)"
		else TrainName = ""
		end
		return TrainName
	end

	-------------------------УВЕДОМЛЕНИЕ О СПАВНЕ СОСТАВА В ЧАТ (само использование функции нужно прописать в trains_spawner.lua)--------------------------------
	function SpawnNotif(ply, ClassName, vector, WagNum)	-- SpawnNotif(ply, self.Train.ClassName, trace.HitPos, self.Settings.WagNum) в функции TOOL:SpawnWagon
		local TrainName = TrainName(ClassName)
		if TrainName == "" then TrainName = ClassName end
		ulx.fancyLogAdmin(ply, true, "#A заспавнил #s", TrainName--[[, self.Train.ClassName, self.Train.Spawner.interim]])
		
		local ourstation = detectstation(vector)
		if ourstation == "" or ourstation == nil 
		then ulx.fancyLog(true, "Вагонов: #i", WagNum)
		else ulx.fancyLog(true, "Станция: #s. Вагонов: #i", ourstation, WagNum)
		end
		timer.Simple( 3, function() AutoInterval() end)
	end

	--------------------------------------ПОДСЧЕТ ИНТЕРВАЛА ОТ ВРЕМЕНИ КРУГА НА КАРТЕ сама функция используется в модуле выше------------------------------------
	function AutoInterval()
	if Metrostroi.ActiveDispatcher ~= nil then return end
	local krugtime = 0
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
		
		if game.GetMap() == "gm_mus_crimson_line_tox_v9_21" then krugtime = 20 * 60
		elseif game.GetMap() == "gm_smr_first_line_v2" then krugtime = 35 * 60
		elseif game.GetMap() == "gm_metro_crossline_c4" then krugtime = 35 * 60	
		elseif game.GetMap() == "gm_metrostroi_b50" then krugtime = 70*60
		end
		krugtime = krugtime / trains_n
		if krugtime > 1023 then krugtime = 0 end
		
		if SERVER then
		ulx.SendActiveInt(krugtime)
		end
		--print(trains_n)
	end
	hook.Add( "PlayerDisconnected", "AutoInterval1", AutoInterval())
	hook.Add( "PlayerConnect", "AutoInterval2", AutoInterval())
	hook.Add( "PlayerInitialSpawn", "AutoInterval3", AutoInterval())

	--[[============================= РАЗРЕШЕНИЕ СПАВНА ТОЛЬКО В ОПРЕДЕЛЕННЫХ МЕСТАХ ==========================]]
	hook.Add("CanTool", "AllowSpawnTrain", function(ply, tr, tool)
		if tool ~= "train_spawner" then return end
		local ourstation = bigrustosmall(detectstation(tr.HitPos))
		if Metrostroi.ActiveDispatcher ~= nil
			and string.match(ourstation, "пто") ~= "пто"
			and string.match(ourstation, "депо") ~= "депо"
			and string.match(ourstation, "ближайшая") ~= "ближайшая"
			and not ourstation:find("depo")
			then 
				if SERVER then ply:LimitHit( "Запрещено спавнить на станциях" ) end return false
		end
	end)


	--[[============================= РЕДИРЕКТ ==========================]]
	function redirect(ply)
	local redirectip = ""
		if GetHostName() == "metrostroi norank 2" then redirectip = "metronorank.ddns.net:27016"
		elseif GetHostName() == "metrostroi norank 1" then redirectip = "metronorank.ddns.net:27017" 
		else return
		end
		ulx.fancyLogAdmin(ply, true, "#A был перенаправлен на другой сервер")
		ply:SendLua([[LocalPlayer():ConCommand('connect ]]..tostring(redirectip)..[[')]])
		--print(GetHostName())
		--print(redirectip)
	end
end
function ulx.redirect(ply)
	redirect(ply)
end
local redirect = ulx.command( "Utility", "ulx redirect", ulx.redirect, "!redirect", true, false, true )
redirect:defaultAccess( ULib.ACCESS_ALL )
redirect:help( "Перейти на другой сервер" )

if SERVER then
	hook.Add( "PlayerInitialSpawn", "autoredirect", function( ply )
	timer.Simple(1, function()
	if ply:GetUserGroup() == "superadmin" then return
	elseif game.MaxPlayers() == #player.GetAll() then ulx.redirect(ply) end
	--print(game.MaxPlayers())
	end)
	end)

	--[[============================= СТАРОЕ РАССТОЯНИЕ МЕЖДУ ВАГОНАМИ НА НВЛ ==========================]]
	if string.find(game.GetMap(), "nvl") then Metrostroi.BogeyOldMap = 1 end
end

timer.Simple(5, function()
--[[============================= Новая функция смены карты для того, чтобы она сохранялась в файл ==========================]]
function ulx.map( calling_ply, map, gamemode )
	if not gamemode or gamemode == "" then
		ulx.fancyLogAdmin( calling_ply, "#A changed the map to #s", map )
	else
		ulx.fancyLogAdmin( calling_ply, "#A changed the map to #s with gamemode #s", map, gamemode )
	end
	if gamemode and gamemode ~= "" then
		game.ConsoleCommand( "gamemode " .. gamemode .. "\n" )
	end
	file.Write( "lastmap.txt", map )
	game.ConsoleCommand( "changelevel " .. map ..  "\n" )
end
local map = ulx.command( "Utility", "ulx map", ulx.map, "!map" )
map:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="map", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes }
map:addParam{ type=ULib.cmds.StringArg, completes=ulx.gamemodes, hint="gamemode", error="invalid gamemode \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.optional }
map:defaultAccess( ULib.ACCESS_ADMIN )
map:help( "Changes map and gamemode." )
end)

--[[============================= НОВАЯ КОМАНДА !TRAINS ==========================]]
if SERVER then
	function wagons()
	local Class1
	local tbl = {}
	local i = 1 
	local NA = "N/A"
	local Class
	for k,v in pairs (Metrostroi.TrainClasses) do							--переношу все найденные паравозы в отдельную таблицу, чтобы потом уже редактировать ее
		local ents = ents.FindByClass(v)
		for k2,v2 in pairs(ents) do
			tbl[i] = {v2, Class}
			i = i + 1
		end
	end
	for k,v in pairs(tbl) do	--беру один вагон, смотрю все сцепленные с ним вагоны (они уже есть в таблице) и удаляю все вагоны (кроме первого), если там нет водителя
		Class = v[1].SubwayTrain.Name
		for _k, _v in pairs(v[1].WagonList) do
			if Class ~= _v.SubwayTrain.Name and not string.find(Class, "/") then Class = Class.."/".._v.SubwayTrain.Name end	--уточнение вагонов в составе
		end
			for k1,v1 in pairs(v[1].WagonList) do
				if v[1] ~= v1 and not v1:GetDriver() then
					for k2,v2 in pairs(tbl) do
						if v1 == v2[1] then tbl[k2] = nil end
					end
				end
			end
		v[2] = Class
	end
	--PrintTable(tbl)
	ulx.fancyLog("Вагонов на сервере: #s", Metrostroi.TrainCount())
	ulx.fancyLog("Составов на сервере: #i", table.Count(tbl))
	for k,v in pairs(tbl) do
	local routenumber = 0
	local routenumber1 = ""
			for k1,v1 in pairs(v[1].WagonList) do
				if string.find(v1.SubwayTrain.Name, "722") or string.find(v1.SubwayTrain.Name, "Ema") or (string.find(v1.SubwayTrain.Name, "717") and not string.find(v1.SubwayTrain.Name, "5m")) or string.find(v1.SubwayTrain.Name, ".6") then routenumber = v1:GetNW2Int("RouteNumber") else routenumber = v1:GetNW2Int("RouteNumber") / 10 end
				if routenumber ~= 0 then
					if routenumber1 == "" then routenumber1 = tostring(routenumber)
					elseif routenumber1 ~= tostring(routenumber) then routenumber1 = routenumber1.."/"..tostring(routenumber)
					end
				end
			end
		if routenumber1 == "" then routenumber1 = "0" end
		if not v[1]:GetDriver() then
			ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец: #A, состав: #s, вагонов: #i, маршрут: #s, машинист: #s",v[2], table.Count(v[1].WagonList), routenumber1, NA)
		elseif v[1]:GetDriver() == v[1]:CPPIGetOwner() then
				ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец/машинист: #A, состав: #s, вагонов: #i, маршрут: #s",v[2], table.Count(v[1].WagonList), routenumber1)
		else
				ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец: #A, состав: #s, вагонов: #i, маршрут: #s, машинист: #T",v[2], table.Count(v[1].WagonList), routenumber1, v[1]:GetDriver())
		end
	end
	end
end
timer.Simple(5, function()
	function ulx.wagons(ply)
		if IsValid(ply) and ply:Nick() then
			ulx.fancyLogAdmin(ply,true,"#A вызвал !trains")
		end
		wagons()
	end
	local wagons = ulx.command( "Metrostroi", "ulx trains", ulx.wagons, "!trains",true )
	wagons:defaultAccess( ULib.ACCESS_ALL )
	wagons:help( "Shows you the current wagons." )
end)

--[[============================= ПОИСК ОДИНАКОВЫХ МАРШРУТОВ ==========================]]
if SERVER then
	function findroutes()
	local Class1
	local tbl = {}
	local i = 1 
	local NA = "N/A"
	local Class
	for k,v in pairs (Metrostroi.TrainClasses) do							--переношу все найденные паравозы в отдельную таблицу, чтобы потом уже редактировать ее
		local ents = ents.FindByClass(v)
		for k2,v2 in pairs(ents) do
			tbl[i] = {v2, Class}
			i = i + 1
		end
	end
	for k,v in pairs(tbl) do	--беру один вагон, смотрю все сцепленные с ним вагоны (они уже есть в таблице) и удаляю все вагоны (кроме первого), если там нет водителя
		Class = v[1].SubwayTrain.Name
		for _k, _v in pairs(v[1].WagonList) do
			if Class ~= _v.SubwayTrain.Name and not string.find(Class, "/") then Class = Class.."/".._v.SubwayTrain.Name end	--уточнение вагонов в составе
		end
			for k1,v1 in pairs(v[1].WagonList) do
				if v[1] ~= v1 and not v1:GetDriver() then
					for k2,v2 in pairs(tbl) do
						if v1 == v2[1] then tbl[k2] = nil end
					end
				end
			end
		v[2] = Class
	end
	--PrintTable(tbl)
	--ulx.fancyLog("Вагонов на сервере: #s", Metrostroi.TrainCount())
	--ulx.fancyLog("Составов на сервере: #i", table.Count(tbl))
	local i = 1
	local routes = {}
	for k,v in pairs(tbl) do
	local routenumber = 0
	local routenumber1 = ""
			for k1,v1 in pairs(v[1].WagonList) do
				if string.find(v1.SubwayTrain.Name, "722") or string.find(v1.SubwayTrain.Name, "Ema") or (string.find(v1.SubwayTrain.Name, "717") and not string.find(v1.SubwayTrain.Name, "5m")) or string.find(v1.SubwayTrain.Name, ".6") then routenumber = v1:GetNW2Int("RouteNumber") else routenumber = v1:GetNW2Int("RouteNumber") / 10 end
				if routenumber ~= 0 then
					if routenumber1 == "" then routenumber1 = tostring(routenumber)
					elseif routenumber1 ~= tostring(routenumber) then routenumber1 = routenumber1.."/"..tostring(routenumber)
					end
				end
			end
		if routenumber1 == "" then routenumber1 = "0" end
		--[[if not v[1]:GetDriver() then
			ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец: #A, состав: #s, вагонов: #i, маршрут: #s, машинист: #s",v[2], table.Count(v[1].WagonList), routenumber1, NA)
		elseif v[1]:GetDriver() == v[1]:CPPIGetOwner() then
				ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец/машинист: #A, состав: #s, вагонов: #i, маршрут: #s",v[2], table.Count(v[1].WagonList), routenumber1)
		else
				ulx.fancyLogAdmin(v[1]:CPPIGetOwner(),"Владелец: #A, состав: #s, вагонов: #i, маршрут: #s, машинист: #T",v[2], table.Count(v[1].WagonList), routenumber1, v[1]:GetDriver())
		end]]
		local entity = v[1]
		routes[i] = {routenumber1, v[1]:CPPIGetOwner(), entity}
		i = i + 1
	end
		for k,v in pairs(routes) do																	-- разделение маршрутов со знаком /
			if string.find(v[1], "/") then
				local slashpos = string.find(v[1], "/") 
				routes[table.Count(routes) + 1] = {(string.sub(v[1],1, slashpos-1)),v[2], (table.Count(routes) + 1)}
				v[1] = string.sub(v[1],slashpos+1)
			end
		end
	--PrintTable(routes)
		for k,v in pairs(routes) do
			for k1,v1 in pairs(routes) do
				if v1[1] == v[1] and v1[3] ~= v[3] and v1[1] ~= "0" then 
					ulx.fancyLogAdmin(v1[2],"#A и #T имеют одинаковые номера маршрутов!", v[2])
					print(v1[2]:Nick().." i "..v[2]:Nick())
					for k2,v2 in pairs(routes) do
						if v2[1] == v1[1] then routes[k2] = nil break
						elseif v2[1] == v[1] then routes[k2] = nil break
						end
					end
				end
			end
		end
	end
	local routeswait = 1
	hook.Add( "PlayerSay", "routes", function( ply, text, team )
		if routeswait == 10 then findroutes() routeswait = 0
		else routeswait = routeswait + 1
		end
	end)

	--[[============================= NOCLIP ПРИ ПОПЫТКЕ ТЕЛЕПОРТА НА СТАНЦИЮ ==========================]]
	hook.Add( "PlayerSay", "stationnoclip", function( ply, text, team )
	local text = string.lower(text)
		if string.find(text, "!station") or string.find(text, "!goto") or string.find(text, "!return") then ply:SetMoveType( MOVETYPE_NOCLIP ) end
	end)

--[[============================= ТЕЛЕПОРТ К СИГНАЛУ ==========================]]
	function tpsig( calling_ply, command)
		if not command or command == "" then
			for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
				if v.Name ~= nil then ULib.tsayError( calling_ply, ""..tostring(v.Name), true ) end
			end
		return
		end
	local command = string.upper(command)
	local command1 = string.lower(command)
		for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
			if v.Name == command or v.Name == command1 then
				if calling_ply:InVehicle() then calling_ply:ExitVehicle() end
				calling_ply.ulx_prevpos = calling_ply:GetPos()
				calling_ply.ulx_prevang = calling_ply:EyeAngles()
				calling_ply:SetMoveType( MOVETYPE_NOCLIP )
				calling_ply:SetPos(Vector(v:GetPos()))
				return
			end
		end
		ULib.tsayError( calling_ply, "Не найдено светофора с таким именем", true )
	end
end
function ulx.tpsig(calling_ply, command)
	tpsig(calling_ply, command)
end
local tpsig = ulx.command( "Metrostroi", "ulx tpsig", ulx.tpsig, "!tpsig", true )
tpsig:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.optional }
tpsig:defaultAccess( ULib.ACCESS_ALL )
tpsig:help( "Телепортирует к светофору.\nОставь пустым, чтобы увидеть весь список имен." )



if SERVER then
	--[[============================= ВОССТАНОВЛЕНИЕ УДОЧЕК ==========================]]
	local udochkitbl = {}
	local i = 1
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == "gmod_track_udochka" or v:GetClass() == "func_physbox" or v:GetClass() == "func_tracktrain" then
			udochkitbl[i] = {v,v:GetPos()}
			i = i + 1
		end
	end
	
	function resetudochki()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "gmod_track_udochka" or v:GetClass() == "func_physbox" or v:GetClass() == "func_tracktrain" then
				for k1,v1 in pairs(udochkitbl) do
					if v1[1] == v then v:SetPos(v1[2]) end
			end
			end
		end
	end

end
function ulx.resetudochki(ply)
	resetudochki()
	ulx.fancyLogAdmin(ply,"#A восстановил удочки")
end
local resetudochki = ulx.command( "Metrostroi", "ulx resetudochki", ulx.resetudochki, "!resetudochki", true )
resetudochki:defaultAccess( ULib.ACCESS_OPERATOR )
resetudochki:help( "Восстанавливает удочки на карте." )

--[[============================= ТЕЛЕПОРТ НА СТАНЦИЮ ==========================]]
if SERVER then
	function tps(ply,comm)
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
			ply:SetMoveType( MOVETYPE_NOCLIP )
            ply:SetPos(stationstbl[1][4])
		else
			ULib.tsayError(ply,"По запросу не найдено совпадений",true)
		end
	end
end
timer.Simple(5, function()
	function ulx.station(ply,comm)
		tps(ply,comm)
	end
	local station = ulx.command( "Metrostroi", "ulx station", ulx.station, "!station",true)
	station:defaultAccess( ULib.ACCESS_OPERATOR )
	station:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.optional }
	station:help( "Телепортация к станции." )
end)

--[[============================= ПРИНУДИТЕЛЬНОЕ ОТКРЫТИЕ ГЛОБАЛЬНОГО ЧАТА ПРИ ОТКРЫТИИ КОМАНДНОГО ==========================]]
if CLIENT then
	hook.Add( "StartChat", "DisableTeamChat", function( isTeamChat )
		if isTeamChat then chat.Close() chat.Open(1) end
	end)
end

--[[============================= Скрытие дефолтного уведомления о коннекте ==========================]]
hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
	if ( typ == "joinleave" ) then return true end
end )

--[[============================= ФОНАРИК В КАБИНЕ ==========================]]
if SERVER then
	hook.Add("PlayerButtonDown", "Flashlight", function(ply,key)
		if ply:InVehicle() then
			 if key == KEY_8 then
				if	ply:FlashlightIsOn() then ply:Flashlight(false)
				else ply:Flashlight(true)
				end
			end
		end
	end)
end

--[[============================= Перегрузка !menu ==========================]]
timer.Simple(5, function()
	function ulx.menu(ply)
		if IsValid(ply) then ply:ConCommand("xgui") end
	end
	
	local menu = ulx.command( "Metrostroi", "ulx menu", ulx.menu, "!menu",true)
	menu:defaultAccess( ULib.ACCESS_ALL )
	menu:help( "Телепортация к станции." )
end)


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
end
--ply.InMetrostroiTrain
--[[============================= УДАЛЕНИЕ НЕНУЖНЫХ ВКЛАДОК ИЗ SPAWNMENU ==========================]]
--[[local function testkek(panel)
    panel:ClearControls()
    panel:SetPadding(0)
    panel:SetSpacing(0)
end

spawnmenu.AddCreationTab( "Spawnlists	")
hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption( "Utilities", "Admin", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption( "Tools", "Player", "", "", "", "", testkek)
	spawnmenu.AddToolMenuOption( "Tools", "Posing", "", "", "", "", testkek)
end )]]
--[[hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Stuff", "Custom_Menu", "My Custom Menu", "", "", function( panel )
		panel:ClearControls()
		panel:NumSlider( "Gravity", "sv_gravity", 0, 600 )
		-- Add stuff here
	end )
end )]]
--spawnmenu.AddToolMenuOption( "Utilities", "Metrostroi", "metrostroi_client_panel2", Metrostroi.GetPhrase( "Panel.Client" ) .. "2", "", "", ClientPanel )


--metrostroi_signal_debug 1
--hook.Add("PlayerSpawnSENT", "PerzKek16", function(ply, class)							-- для проверки, если игрок спавнит что-то не треинспавнером
--hook.Add("OnEntityCreated", "Perzpidor2281337123", function(ent)			-- можно использовать это для уведомления о спавне состава не в спавнере. А ограничение по вагонам можно сделать через cantool