local timeleft = 0
local votesleft = 0
local nextmap = ""
local votedone = false

CreateClientConVar("cl_votemap_hud",1,true,false);

surface.CreateFont( "VoteMapFont",
{
	font		= "Helvetica",
	size		= 20,
	weight		= 800
})

surface.CreateFont("VoteMapScoreboard", {
	font = "Tahoma",
	size = 16,
	weight = 1000,
	antialias = true,
	additive = false,
})

local function recvdata(um)
	timeleft = tonumber(um:ReadString())
	votesleft = um:ReadLong()
	nextmap = um:ReadString()
	votedone = um:ReadBool()
	timer.Create("MapLeftTimer",1,0,function() if timeleft > 0 then timeleft = timeleft - 1 end end)
end
usermessage.Hook("UpdateTimeLeft", recvdata)

net.Receive("_hidevotemaphud",function(len)
	if (util.tobool(LocalPlayer():GetInfo("cl_votemap_hud"))) then
		LocalPlayer():ChatPrint("Votemap hud was successfully disabled!");
		LocalPlayer():ConCommand("cl_votemap_hud 0");
	else
		LocalPlayer():ChatPrint("Votemap hud was successfully enabled!");
		LocalPlayer():ConCommand("cl_votemap_hud 1");
	end
end)

local function DrawClock()
	if (not util.tobool(LocalPlayer():GetInfo("cl_votemap_hud"))) then return end
	local str = AVMS.timeToStr(timeleft)
	local nxtmp = "Next Map: "..nextmap
	local votestr = "Changing in: "..str
	if !votedone then
		nxtmp = "Current Map: "..nextmap
		votestr = "Next Vote: "..str
	end
	local w,h = 300,60

	surface.SetFont("VoteMapScoreboard")
	local mapsize = surface.GetTextSize(nxtmp)
	w = mapsize + 18;

	local x,y = (ScrW() / 2) - (w/2),ScrH() - h

	--surface.SetDrawColor( 255, 255, 255, 120 )
	--surface.DrawRect( x+1,y+1,w-2,h-2)
	--surface.SetDrawColor( 100, 100, 255, 240 )
	--surface.DrawOutlinedRect( x,y,w,h )
	--draw.SimpleText(votestr,"VoteMapScoreboard",x+10,y+5,Color(100,0,0,200))
	--draw.SimpleText("Votes Left: "..votesleft,"VoteMapScoreboard",x+10,y+20,Color(0,0,0,200))
	--draw.SimpleText(nxtmp,"VoteMapScoreboard",x+10,y+35,Color(0,0,0,200))
end
hook.Add("HUDPaint","DrawVoteClock",DrawClock)

local maps = {}
local title = ""
local voted = false
local countvotes = {}
local myvote = 0
local function DrawVoteOptions()
	local maxwide = 0
	local y = 5
	local height = 0
	local maxheight = 20
	local alpha = 230
	if voted then alpha = 80 end
	surface.SetFont( "VoteMapFont" )
	for k,v in pairs(maps) do
		local size,h = surface.GetTextSize(v)
		size = size + 12
		if size > maxwide then maxwide = size end
		height = h
		maxheight = maxheight + h + 3
	end
	surface.SetFont( "VoteMapFont" )
	local titlesize = surface.GetTextSize(title)
	if titlesize > maxwide then maxwide = titlesize end

	local Wide = maxwide + 20
	local ypos = (ScrH() / 2) - (maxheight / 2)
	draw.RoundedBox( 6, 5, ypos, Wide, maxheight + 10, Color(200,200,200,alpha) )
	draw.DrawText(title,"VoteMapFont", 15, ypos + .5, Color(51,102,255,230), 0 ) --Title
	y = y + 18
	for k,v in pairs(maps) do
		local votes = countvotes[k] or 0
		local color = Color(0,0,0,230)
		if myvote == k then color = Color(250,200,10,230) end
		draw.DrawText(v.." ("..votes..")","VoteMapFont", 10, ypos + y, color, 0 )
		y = y + height + 3
	end
end

net.Receive("_updatevotemap",function(len)
	countvotes = net.ReadTable();
end)

local function StartVote( len )
	local decoded = net.ReadTable();
	title = decoded.title
	local str = "%i: %s (%s)"
	for k,v in pairs(decoded.maps) do
		if (v.ext) then
			if (k==10) then
				maps[k] = string.format("%i: %s",0,v.map,v.gmode)
			else
				maps[k] = string.format("%i: %s",k,v.map,v.gmode)
			end
		else
			maps[k] = string.format(str,k,v.map,v.gmode)
		end
	end
	hook.Add("HUDPaint","DrawVotes",DrawVoteOptions)
	hook.Add("PlayerBindPress", "BindVoteButtons", function(ply,bind,pressed)
		if string.Left(bind,4) == "slot" and pressed and !voted then
			local tbl = string.ToTable(bind)
			local votearg = tonumber(tbl[5])
			if (votearg==0) then votearg = 10 end
			if votearg != 0 and votearg <= table.Count(maps) then
				RunConsoleCommand("_votefor",votearg)
				voted = true
				myvote = votearg
				--CloseVote()
			end
			return true
		end
	end)
end
net.Receive("_startvotemap",StartVote)

function CloseVote()
	hook.Remove("HUDPaint","DrawVotes")
	hook.Remove("PlayerBindPress", "BindVoteButtons")
	table.Empty(maps)
	table.Empty(countvotes)
	voted = false
	myvote = 0
end
usermessage.Hook("_closevote", CloseVote)