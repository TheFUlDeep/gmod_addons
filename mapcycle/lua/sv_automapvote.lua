-- Automapvote by -)BDB(-DrTight
-- Create an empty textfile named mapcycle.txt to your data folder.
-- Add maps to the mapcycle.txt this way--
-- Edited and impoved by AlexALX
/*
gm_flatgrass sandbox
gm_construct DarkRp
gm_mobenix_v3 prop_hunt
gm_botmap sandbox
*/
-- To add a map ingame use automap_addnextmap <map> <gamemode> for example automap_addnextmap gm_freespace09 sandbox
--Have Fun
-- visit www.bdb-community.de

-- Server convars
local svAutoMapVoteTime = CreateConVar("sv_automap_votetime", "120", {FCVAR_NEVER_AS_STRING}) -- How many minutes to first Vote
local svextendtime = CreateConVar("sv_automap_extendtime", "60", {FCVAR_NEVER_AS_STRING}) -- Extend Map for x Minutes
local svretry = CreateConVar("sv_automap_retry", "3", {FCVAR_NEVER_AS_STRING}) -- Retrys if nobody voted
local svminvoteneed = CreateConVar("sv_automap_minvoteneed", "0.65", {FCVAR_NEVER_AS_STRING}) -- In percent
local svmaxextend = CreateConVar("sv_automap_maxextend", "4", {FCVAR_NEVER_AS_STRING}) -- Maximum Extend do -1 to deactivate
local svminvotes = CreateConVar("sv_automap_minmaps", "4", {FCVAR_NEVER_AS_STRING}) -- How many maps should be in the vote
local svrocksneeded = CreateConVar("sv_automap_rocksneeded", "0.6", {FCVAR_NEVER_AS_STRING}) -- in % how many rockvotes are needed to force a mapvote
local svchangetime = CreateConVar("sv_automap_changetime", "60", {FCVAR_NEVER_AS_STRING}) -- In seconds
local svdefaultgmode = CreateConVar("sv_automap_defaultgmode", "sandbox", {}) -- Change default gamemode
local svblocktime = CreateConVar("sv_automap_blocktime", "180", {FCVAR_NEVER_AS_STRING}) -- In seconds
local svblockloadtime = CreateConVar("sv_automap_loadtime", "300", {FCVAR_NEVER_AS_STRING}) -- In seconds
local svadvertise = CreateConVar("sv_automap_advertise", "1", {FCVAR_NEVER_AS_STRING}) -- Enable/Disable advertise

local AutoMapVoteTime = 120 -- How many minutes to first Vote
local extendtime = 60 -- Extend Map for x Minutes
local retry = 3 -- Retrys if nobody voted
local minvoteneed = 0.65 -- In percent
local maxextend = 4 -- Maximum Extend do -1 to deactivate
local minvotes = 4 -- How many maps should be in the vote
local rocksneeded = 0.6 -- in % how many rockvotes are needed to force a mapvote
local changetime = 60 -- In seconds
local defaultgmode = "sandbox" -- Change default gamemode
local blocktime = 180;
local blockloadtime = 300;
local advertise = true;

local function load_convars()
	AutoMapVoteTime = svAutoMapVoteTime:GetInt();
	extendtime = svextendtime:GetInt();
	retry = svretry:GetInt();
	minvoteneed = svminvoteneed:GetFloat();
	maxextend = svmaxextend:GetInt();
	minvotes = svminvotes:GetInt();
	if (minvotes>9) then
		minvotes = 9;
		print("sv_automap_minmaps value error! min - 1, max - 9");
	end
	rocksneeded = svrocksneeded:GetFloat();
	changetime = svchangetime:GetInt();
	defaultgmode = svdefaultgmode:GetString();
	blocktime = svblocktime:GetInt();
	blockloadtime = svblockloadtime:GetInt();
	advertise = svadvertise:GetBool();
end

-- should be small delay before all convars loaded
timer.Create("AutoVoteMapInit", 1, 1, function() load_convars() end)

---------------------DONT EDIT UNDER THIS LINE-----------------------------------
-- Tables
NextMapTable = {}
local Nominated = {}
local RockTheVote = {}
--Stuff
local LastVote = CurTime()
local extendvotes = 0
local doextend = true
local nextmap
local changingmap
local blockrtv = false
local blockrtvtime = 0
local rtvloadtime = CurTime()

util.AddNetworkString("_startvotemap");
util.AddNetworkString("_updatevotemap");
util.AddNetworkString("_hidevotemaphud");

local function TableHasMap(tbl,map,gmode)
	for k,v in pairs(tbl) do
		if string.lower(v.map) == string.lower(map) and string.lower(v.gmode) == string.lower(gmode) then return true end
	end
	return false
end

local function GamemodeExists(str)
	for k,v in pairs(engine.GetGamemodes()) do
		if string.lower(v.name) == string.lower(str) then return v.name end
	end
	return false
end

function AVMS.AddNextMap(ply, cmd, args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	local function PrintMessage(ply, msg)
		if !msg or type(msg) != "string" then return end
		if !ply then
			-- nothing to show while starting
		elseif !ply:IsValid() then
			print(msg)
		else
			ply:PrintMessage(HUD_PRINTCONSOLE,msg)
		end
	end

	if not args[1] then
		PrintMessage(ply, "Please enter a valid map")
		return
	end

	local map = args[1]
	local gmode = GamemodeExists(args[2] or defaultgmode)

	if not file.Exists( "maps/" .. map .. ".bsp", "GAME" ) then
		PrintMessage(ply, "Карта недоступна")
		return
	elseif !gmode then
		PrintMessage(ply, "Игровой режим "..args[2].." недоступен")
		return
	end
	if TableHasMap(NextMapTable,map,gmode) then PrintMessage(ply, "Карта уже в списке (in cycle)") return end

	PrintMessage(ply, "Карта "..map.." ("..gmode..") добавлена в список (cycle)")

	table.insert(NextMapTable,{map = map,gmode = gmode})
	if ply then
		local tbl = {}
		for k,v in pairs(NextMapTable) do
			table.insert(tbl,v.map.." "..v.gmode)
		end
		local mapcycle = string.Implode("\r\n", tbl)
		file.Write("mapcycle.txt", mapcycle)
	end
end
concommand.Add("automap_addnextmap",AVMS.AddNextMap)

function AVMS.UpdatePlayers(ply)
	local left = (AutoMapVoteTime * 60) - (CurTime() - LastVote)
	if changingmap then left = changingmap - CurTime() end
	local map = nextmap or game.GetMap().." ("..gmod.GetGamemode().FolderName..")"
	local votesleft = maxextend - extendvotes
	local change = nextmap != nil
	for k,v in pairs(player.GetAll()) do
		if (not ply or ply == v) then
			umsg.Start("UpdateTimeLeft",v)
				umsg.String(tostring(math.ceil(left)))
				umsg.Long(votesleft)
				umsg.String(map)
				umsg.Bool(change)
			umsg.End()
		end
	end
end

local function MessageAll(str)
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:ChatPrint(str)
		end
	end
end

function AVMS.StartVote(maps,title,lenght,recallfunc)
	if timer.Exists("VoteMap") then return end
	AVMS.Votes = {}
	AVMS.Maps = maps
	AVMS.Func = recallfunc
	AVMS.Currentmaps = table.Count(maps)
	AVMS.Voters = #player.GetAll()
	local tbl = {title = title,maps = maps}
	net.Start("_startvotemap");
	net.WriteTable(tbl);
	net.Broadcast();
	timer.Create("VoteMap",lenght,1,function()
		AVMS.EndVote()
	end)
end

function AVMS.DoVote(ply,cmd,args)
	if !IsValid(ply) or !args[1] or !AVMS.Votes then return end
	if AVMS.Votes[ply:EntIndex()] then return end
	local voted = tonumber(args[1])
	if voted > AVMS.Currentmaps then return end
	AVMS.Votes[ply:EntIndex()] = voted
	AVMS.UpdateVote()
	if table.Count(AVMS.Votes) >= #player.GetAll() then AVMS.EndVote() end
end
concommand.Add("_votefor",AVMS.DoVote)

function AVMS.UpdateVote()
	if !AVMS.Votes then return end
	local maps = AVMS.Maps
	local tbl = {}
	for k,v in pairs(AVMS.Votes) do
		if !tbl[v] then tbl[v] = 0 end
		tbl[v] = tbl[v] + 1
	end
	net.Start("_updatevotemap");
	net.WriteTable(tbl);
	net.Broadcast();
end

function AVMS.EndVote()
	local tbl = {}
	local recallfunc = AVMS.Func
	tbl.options = AVMS.Maps
	tbl.results = {}
	tbl.votes = table.Count(AVMS.Votes)
	tbl.voters = AVMS.Voters
	for id,votearg in pairs(AVMS.Votes) do
		if !tbl.results[votearg] then tbl.results[votearg] = 1 end
		tbl.results[votearg] = tbl.results[votearg] + 1
	end
	pcall(recallfunc,tbl)
	AVMS.Votes = nil
	AVMS.Currentmaps = nil
	AVMS.Maps = nil
	AVMS.Func = nil
	AVMS.Voters = nil
	timer.Remove("VoteMap")
	umsg.Start("_closevote")
	umsg.End()
	table.Empty(Nominated)
	table.Empty(RockTheVote)
end

local trys = 0
function AVMS.VoteFinished(t)
	local winner
	local winnernum = 0
	local resultsnum = table.Count(t.options)
	local dontwanttochange = t.results[resultsnum] or 0 -- people who dont want to change the map
	local wanttochange = t.voters - dontwanttochange

	for id, numvotes in pairs( t.results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local str
	local timerun = 0
	local map,gmode
	if not winner then

		if trys >= retry then
			local winnertbl = t.options[math.random(1, #t.options - 1)]
			map,gmode = winnertbl.map,winnertbl.gmode
			str = "Никто не проголосовал. Смена карты на "..map.." через "..AVMS.timeToStr( changetime ).." !abort для админов"
			timer.Create("VoteMapTimer",changetime,1, function() game.ConsoleCommand("ulx map "..map.."\n") end)
			hook.Add("PlayerSay", "VoteMapAbort", function(ply,txt)
				txt = string.lower(txt)
				local texttbl = string.Explode(" ",txt)
				if texttbl[1] == "!abort" then
					AVMS.Abort(ply)
				end
			end)
		else
			timer.Create("AutoVoteMap",300,1, function() AVMS.VoteNextMap() end )
			trys = trys + 1
			local left = retry - trys + 1
			str = "Никто не проголосовал "..left.." votes осталось."
		end
	elseif winner == resultsnum and doextend then
		AutoMapVoteTime = extendtime
		extendvotes = extendvotes + 1
		str = "Карта будет продлена на "..extendtime.." Minutes ("..maxextend - extendvotes.." продлений осталось)"
		blockrtvtime = CurTime()
	elseif wanttochange / t.votes < minvoteneed and doextend then
		AutoMapVoteTime = extendtime
		extendvotes = extendvotes + 1
		str = "Недостаточно игроков проголосовало. Продление карты "..extendtime.." Minutes ("..maxextend - extendvotes.." продлений осталось)"
		blockrtvtime = CurTime()
	else
		map,gmode = t.options[winner].map,t.options[winner].gmode
		str = "Следущая карта "..map.." ("..gmode.."). Смена через "..AVMS.timeToStr( changetime )..". Admin write !abort to abort the mapchange."
		timer.Create("VoteMapTimer",changetime,1, function() game.ConsoleCommand("ulx map "..map.."\n") end)
		hook.Add("PlayerSay", "VoteMapAbort", function(ply,txt)
			txt = string.lower(txt)
			local texttbl = string.Explode(" ",txt)
			if texttbl[1] == "!abort" then
				AVMS.Abort(ply)
			end
		end)
		blockrtv = true
	end
	if map and gmode then
		changingmap = CurTime() + changetime
		timer.Create("AutoVoteMapMessage", 1,0, function()
			if !changingmap then timer.Remove("AutoVoteMapMessage"); timer.Remove("VoteMapTimer") return end
			local count = math.Round(changingmap - CurTime())
			if count == 60 then
				MessageAll( "Смена карты на "..map.." ("..gmode..") через "..AVMS.timeToStr( count ))
			elseif count < 60 and string.find(count, 0) and count != 0 then
				MessageAll( "Смена карты на "..map.." ("..gmode..") через "..AVMS.timeToStr( count ))
			elseif count <= 5 then
				MessageAll( "Смена карты через "..AVMS.timeToStr( count ))
			end
		end)
	else
		nextmap = nil
		changingmap = nil
	end
	if str then
		MessageAll( str )
		Msg( str .. "\n" )
	end
	nextmap = map.." ("..gmode..")"
	AVMS.UpdatePlayers()
end

local function PlayerOnServer(id)
	for k,v in pairs(player.GetAll()) do
		if v:UniqueID() == id then return true end
	end
	return false
end

local function GetValidMap(map,gmode)
	if !map then return false end
	gmode = gmode or defaultgmode
	for k,v in pairs(NextMapTable) do
		if v.map and string.find(string.lower(v.map),string.lower(map)) and string.find(string.lower(v.gmode),string.lower(gmode)) then
			return v.map,v.gmode
		end
	end
	return false
end

function AVMS.VoteNextMap(no_extend)
	local maps = {}
	local num
	local curmap = game.GetMap()
	local curgmode = gmod.GetGamemode().FolderName
	local max = #NextMapTable
	LastVote = CurTime()
	if max <= 0 then print("No map to vote") return end
	for k,v in pairs(Nominated) do
		if PlayerOnServer(k) then
			if !TableHasMap(maps,v.map,v.gmode) then table.insert(maps,{map = v.map,gmode = v.gmode}) end
		end
	end

	if max <= minvotes then
		for i = 1, max do
			if #maps < minvotes and NextMapTable[i].map != curmap and !TableHasMap(maps,NextMapTable[i].map,NextMapTable[i].gmode) then
				table.insert(maps,{map = NextMapTable[i].map,gmode=NextMapTable[i].gmode})
			end
		end
	else
		while #maps < minvotes do
			num = math.random(1, max)
			if #maps < minvotes and NextMapTable[num].map != curmap and !TableHasMap(maps,NextMapTable[num].map,NextMapTable[num].gmode) then
				table.insert(maps,{map = NextMapTable[num].map,gmode=NextMapTable[num].gmode})
			end
		end
	end
	if extendvotes >= maxextend and maxextend > -1 or no_extend then
		doextend = false
	else
		table.insert(maps, {map = "Продлить на "..extendtime.." Minutes",gmode = curgmode,ext=true})
	end
	local str = "Mapvote started"
	Msg( str .. "\n" )
	AVMS.StartVote(maps,"Голосование за карту",30,AVMS.VoteFinished)
end

local function load_cycle()
	if file.Exists("mapcycle.txt","DATA") then
		local maps = file.Read("mapcycle.txt","DATA")
		local mapcycle = string.Explode("\n", maps:Replace("\r\n","\n"))
		for k,line in pairs(mapcycle) do
			local tbl = string.Explode(" ", line)
			AVMS.AddNextMap(_, _, { tbl[1],tbl[2] or defaultgmode,false})
		end
		print("//  Mapcycle Loaded          //")
	else
		print("//  No mapcycle found        //")
	end
end
load_cycle()

timer.Create("AutoVoteMapTimer",1.2, 0, function()
	if CurTime() - LastVote > AutoMapVoteTime * 60 then
		AVMS.VoteNextMap()
	end
end)
concommand.Add("automap_startmapvote",function(ply,cmd,args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	local extend = tobool(args[1]) or false
	AVMS.VoteNextMap(extend)
end)
concommand.Add("automap_setextend",function(ply,cmd,args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	if !args[1] then return end
	local num = tonumber(args[1])
	RunConsoleCommand("sv_automap_maxextend",num)
	maxextend = num
	extendvotes = 0
	AVMS.UpdatePlayers()
end)
timer.Create("UpdatePlayerClocks",10,0,AVMS.UpdatePlayers)

hook.Add( "PlayerInitialSpawn", "AVMS.PlayerInit", function(ply) AVMS.UpdatePlayers(ply) end )

function AVMS.ReloadConf(ply,cmd,args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	load_convars();
end
concommand.Add("automap_reload_settings",AVMS.ReloadConf)

function AVMS.ReloadCycle(ply,cmd,args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	NextMapTable = {};
	load_cycle();
end
concommand.Add("automap_reload_cycle",AVMS.ReloadCycle)

function AVMS.Abort(ply,cmd,args)
	if IsValid(ply) and not ply:IsAdmin() then return end

	timer.Remove("VoteMapTimer")
	timer.Remove("AutoVoteMapMessage")
	AutoMapVoteTime = extendtime
	nextmap = nil
	changingmap = nil
	AVMS.UpdatePlayers()
	MessageAll("Mapchange aborted!")
	hook.Remove("PlayerSay", "VoteMapAbort")
	blockrtvtime = CurTime()
	blockrtv = false
	file.Write( "lastmap.txt", game.GetMap() )
end
concommand.Add("automap_abort",AVMS.Abort)

hook.Add("PlayerSay", "NominateOrRockTheVote", function(ply,txt)
	if !IsValid(ply) then return "" end
	txt = string.lower(txt)
	local texttbl = string.Explode(" ",txt)
	local id = ply:UniqueID()
	if texttbl[1] == "!nominate" then
		if #NextMapTable <= minvotes then
			ply:ChatPrint("There are not enough maps in the cycle to enable nominate.")
			return ""
		end
		local map,gmode = GetValidMap(texttbl[2],texttbl[3])
		if !map then
			ply:ChatPrint("Эта карта недоступна!\nДоступные карты отобразились в твоей консоли")
			for k,v in pairs(NextMapTable) do
				ply:PrintMessage(HUD_PRINTCONSOLE,v.map .." "..v.gmode)
			end
			return ""
		end
		Nominated[id] = {map = map,gmode = gmode}
		ply:ChatPrint("Nominated map: "..map.." ("..gmode..")")
	elseif texttbl[1] == "!rtv" or texttbl[1] == "!rockthevote" then
		if AVMS.Votes then return "" end
		if (blockrtvtime>0 and blocktime>0 and blockrtvtime + blocktime > CurTime()) then
			ply:ChatPrint( "Ты не можешь голосовать сразу после предыдущего голосования. Подожди "..AVMS.timeToStr( blockrtvtime + blocktime - CurTime() ))
			return "";
		end
		if (blockloadtime>0 and rtvloadtime + blockloadtime > CurTime()) then
			ply:ChatPrint( "Ты не можешь голосовать сразу после смены карты. Подожди "..AVMS.timeToStr( rtvloadtime + blockloadtime - CurTime() ))
			return "";
		end
		if (blockrtv) then
			ply:ChatPrint( "Нельзя голосовать во время смены карты!" )
			return "";
		end
		if !table.HasValue(RockTheVote,id) then
			table.insert(RockTheVote,id)
		end
		if (table.Count(RockTheVote) / #player.GetAll()) >= rocksneeded then
			AVMS.VoteNextMap()
		else
			local have,need = table.Count(RockTheVote), math.ceil(#player.GetAll() * rocksneeded)
			MessageAll(have.." / "..need.." проголосовал(и) за смену карты.")
		end
	elseif texttbl[1] == "!hidevotehud" then
		net.Start("_hidevotemaphud");
		net.WriteBit(true);
		net.Send(ply);
	end
end)

--[[timer.Create("Advertise",300,0,function()
	if (advertise) then
		MessageAll("Type !nominate to add your favorite map to the next mapvote!");
		MessageAll("Type !rtv to vote for the start of the next mapvote!");
		MessageAll("Type !hidevotehud to hide or unhide votemap hud!");
	end
end)]]
/* doesn't exists in gmod13
--Add Server Tag and keep the old one
local _tagstart = CurTime()
local _tagadded = false
local _version = "mapvote_1.6"
hook.Add("Think","AddNewTag",function()
	local oldtags = GetConVarString("sv_tags")
	if _tagadded or (!oldtags and CurTime() - _tagstart >= 10) then return end
	if !string.find(oldtags,_version) then
		RunConsoleCommand("sv_tags",oldtags..",".._version)
	end
	_tagadded = true
	hook.Remove("Think","AddNewTag")
end)*/