include( "player_row.lua" )
include( "player_frame.lua" )

// checking for utime for the hours
utimecheck = false
if file.Exists("autorun/cl_utime.lua", "LUA") then 
	utimecheck = true
end


// checking for ulib for the team names
ulibcheck = false
if file.Exists("ulib/cl_init.lua", "LUA") then 
	ulibcheck = true
end

surface.CreateFont( "suiscoreboardheader", {
	font = "coolvetica",
	size = 28,
	weight = 100
})
surface.CreateFont( "suiscoreboardsubtitle", {
	font = "coolvetica",
	size = 20,
	weight = 100
 })
surface.CreateFont( "suiscoreboardlogotext", {
	font = "coolvetica",
	size = 75,
	weight = 100
})
surface.CreateFont( "suiscoreboardsuisctext", {
	font = "verdana",
	size = 12,
	weight = 100
})
surface.CreateFont( "suiscoreboardplayername", {
	font = "verdana",
	size = 16,
	weight = 100
})

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local function ColorCmp( c1, c2 )
	if( !c1 || !c2 ) then return false end
	
	return (c1.r == c2.r) && (c1.g == c2.g) && (c1.b == c2.b) && (c1.a == c2.a)
end

local PANEL = {}

--[[---------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
local CurrentMap = ""
timer.Simple(0,function()CurrentMap=game.GetMap()end)
function PANEL:Init()
	SCOREBOARD = self

	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetHostName() )

	self.Logog = vgui.Create( "DLabel", self )
	self.Logog:SetText( "" )
--	self.Logog:SetImage( "icon16/user.png" )	

	self.SuiSc = vgui.Create( "DLabel", self )
	self.SuiSc:SetText( "SUI Scoreboard v2.6 PolarWolf edited" )
	
	self.Description = vgui.Create( "DLabel", self )
	self.Description:SetText("Карта: "..CurrentMap.." Вагонов: "..(GetGlobalInt("metrostroi_train_count") or 0).."/"..(GetGlobalInt("metrostroi_maxwagons") or 0))
	
	self.PlayerFrame = vgui.Create( "suiplayerframe", self )
	
	self.PlayerRows = {}

	self:UpdateScoreboard()
	
	// Update the scoreboard every 1 second
	timer.Create( "SuiScoreboardUpdater", 1, 0, function() SCOREBOARD:UpdateScoreboard() end )
	
	self.lblPing = vgui.Create( "DLabel", self )
	self.lblPing:SetText( "Пинг" )
	
	self.lblKills = vgui.Create( "DLabel", self )
	self.lblKills:SetText( "Пассажиры" )
	
	self.lblDeaths = vgui.Create( "DLabel", self )
	self.lblDeaths:SetText( "Энергия" )
	
	self.lblInTrain = vgui.Create( "DLabel", self )
	self.lblInTrain:SetText( "В составе (маршрут)" )
	
	self.lblPos = vgui.Create( "DLabel", self )
	self.lblPos:SetText( "Местоположение" )

	self.lblHealth = vgui.Create( "DLabel", self )
	self.lblHealth:SetText( "Вагоны" )

	if utimecheck then self.lblHours = vgui.Create( "DLabel", self ) end
	if utimecheck then self.lblHours:SetText( "Часы" ) end
	
	if ulibcheck then self.lblTeam = vgui.Create( "DLabel", self ) end
	if ulibcheck then self.lblTeam:SetText( "Должность" ) end
end

--[[---------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:AddPlayerRow( ply )
	local button = vgui.Create( "suiscoreplayerrow", self.PlayerFrame:GetCanvas() )
	button:SetPlayer( ply )
	button:SetCursor("user")
	self.PlayerRows[ ply ] = button
end

--[[---------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:GetPlayerRow( ply )
	return self.PlayerRows[ ply ]
end

--[[---------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:Paint( w, h )
	draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 50, 50, 205 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 100, 100, 100, 155 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() ) 
	
	// White Inner Box
	draw.RoundedBox( 6, 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 6, Color( 230, 230, 230, 100 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 8 )
	
	// Sub Header
	draw.RoundedBox( 6, 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8, Color( 100, 100, 100, 155 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8 ) 
	
	// Logo!
	--if ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 ) ) then
	--	tColor = Color( 255, 155, 0, 255 )
	--else
  		tColor = Color( 0, 155, 255, 255 )--team.GetColor(21)
 	--end
	
	if (tColor.r < 255) then
		tColorGradientR = tColor.r + 15
	else 
		tColorGradientR = tColor.r
	end
	if (tColor.g < 255) then
		tColorGradientG = tColor.g + 15
	else 
		tColorGradientG = tColor.g
	end
	if (tColor.b < 255) then
		tColorGradientB = tColor.b + 15
	else 
		tColorGradientB = tColor.b
	end
	draw.RoundedBox( 8, 24, 12, 80, 80, color_white )
	surface.SetTexture( surface.GetTextureID("gui/metrostroi") )
	surface.SetDrawColor( 255, 255, 255, 127 )
	surface.DrawTexturedRect( 24, 12, 80, 80 ) 
	
	-- draw.RoundedBox( 4, 20, self.Description.y + self.Description:GetTall() + 6, self:GetWide() - 40, 12, Color( 0, 0, 0, 50 ) )
end


--[[---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:PerformLayout()
	self:SetSize( ScrW() * 0.75, ScrH() * 0.65 )
	
	self:SetPos( (ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2 )
	
	self.Hostname:SizeToContents()
	self.Hostname:SetPos( 115, 17 )
	
	self.Logog:SetSize( 80, 80 )
	self.Logog:SetPos( 45, 5 )
	self.Logog:SetColor( Color( 0, 0, 0, 255 ) )
	--self.Logog:SetColor( color_white )

	self.SuiSc:SetSize( 400, 15 )
	self.SuiSc:SetPos( self:GetWide() - 250, self:GetTall() - 15 )
	
	self.Description:SizeToContents()
	self.Description:SetPos( 115, 60 )
	self.Description:SetColor( Color( 30, 30, 30, 255 ) )
	
	self.PlayerFrame:SetPos( 5, self.Description.y + self.Description:GetTall() + 20 )
	self.PlayerFrame:SetSize( self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 20 )
	
	local y = 0
	
	local PlayerSorted = {}
	
	for k, v in pairs( self.PlayerRows ) do
		if IsValid( k ) then table.insert( PlayerSorted, v ) end
	end
	
	table.sort( PlayerSorted, function ( a , b ) return a:HigherOrLower( b ) end )
	
	for k, v in ipairs( PlayerSorted ) do
		v:SetPos( 0, y )	
		v:SetSize( self.PlayerFrame:GetWide(), v:GetTall() )
		
		self.PlayerFrame:GetCanvas():SetSize( self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall() )
		
		y = y + v:GetTall() + 1
	end
	
	if self.lblPing then
		self.lblPing:SizeToContents()
	else
		self.lblPing = vgui.Create( "DLabel", self )
		self.lblPing:SetText( "Пинг" )
		self.lblPing:SizeToContents()
	end
	
	self.lblKills:SizeToContents()
	self.lblDeaths:SizeToContents()
	
	self.lblInTrain:SizeToContents()
	self.lblPos:SizeToContents()
	
	self.lblHealth:SizeToContents()
	if utimecheck then self.lblHours:SizeToContents() end
	if ulibcheck then self.lblTeam:SizeToContents() end
	
	
	self.lblPing:SetPos( self:GetWide() - 90, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	local xpos = self.lblPing:GetPos()
	local space = 10
	local k = 1/(ScrW()/70000)
	local res = ScrW()
	if res > 1500 then
		res = 0
		k = 0
	else
		res = -9999
	end
	if utimecheck then 
		self.lblHours:SetPos( xpos - self.lblHours:GetWide() - space, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
		xpos = self.lblHours:GetPos()
		self.lblHealth:SetPos( xpos - self.lblHealth:GetWide() - space, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
		xpos = self.lblHealth:GetPos()
		self.lblDeaths:SetPos(xpos - self.lblDeaths:GetWide() - space, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
		xpos = self.lblDeaths:GetPos()
		self.lblKills:SetPos( xpos - self.lblKills:GetWide() - space, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
		xpos = self.lblKills:GetPos()
		self.lblInTrain:SetPos( xpos - self.lblInTrain:GetWide() - res - 72 + 60, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
		--xpos = self.lblInTrain:GetPos()
		local j = 0
		if ScrW() > 1800 then
			j = 120
		end
		self.lblPos:SetPos(  xpos - self.lblInTrain:GetWide() - res - 72 + 60 - 300 - 20 - j, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	end
	if ulibcheck then  self.lblTeam:SetPos( self:GetWide() / 4 + k, self.PlayerFrame.y - self.lblPing:GetTall() - 3  ) end
	
end

--[[---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------]]
function PANEL:ApplySchemeSettings()
	--if ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 )) then
	--	tColor = Color( 255, 155, 0, 255 )
	--else
  	--	tColor = team.GetColor(21) 		
 	--end
	-- tColor = Color( 0, 155, 255, 255 )
	
	self.Hostname:SetFont( "suiscoreboardheader" )
	self.Description:SetFont( "suiscoreboardsubtitle" )
	self.Logog:SetFont( "suiscoreboardlogotext" )
	self.SuiSc:SetFont( "suiscoreboardsuisctext" )
	
	if self.lblPing then
		self.lblPing:SetFont( "DefaultSmall" )
	else
		self.lblPing = vgui.Create( "DLabel", self )
		self.lblPing:SetText( "Пинг" )
		self.lblPing:SizeToContents()
		self.lblPing:SetFont( "DefaultSmall" )
	end
	
	
	
	self.lblKills:SetFont( "DefaultSmall" )
	self.lblDeaths:SetFont( "DefaultSmall" )
	if ulibcheck then self.lblTeam:SetFont( "DefaultSmall" ) end
	self.lblHealth:SetFont( "DefaultSmall" )
	if utimecheck then self.lblHours:SetFont( "DefaultSmall" ) end
	
	self.lblInTrain:SetFont( "DefaultSmall" )
	self.lblPos:SetFont( "DefaultSmall" )
	
	-- self.Hostname:SetTextColor( tColor )
	self.Hostname:SetTextColor( Color( 230, 230, 230, 200 ) )
	self.Description:SetTextColor( Color( 55, 55, 55, 255 ) )
	self.Logog:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.SuiSc:SetTextColor( Color( 200, 200, 200, 200 ) )
	self.lblPing:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblKills:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetTextColor( Color( 0, 0, 0, 255 ) )
	if ulibcheck then self.lblTeam:SetTextColor( Color( 0, 0, 0, 255 ) ) end
	self.lblHealth:SetTextColor( Color( 0, 0, 0, 255 ) )
	if utimecheck then self.lblHours:SetTextColor( Color( 0, 0, 0, 255 ) ) end
	
	self.lblInTrain:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblPos:SetTextColor( Color( 0, 0, 0, 255 ) )
end


function PANEL:UpdateScoreboard( force )
	if not self or ( not force and not self:IsVisible() ) then return end
	for k, v in pairs( self.PlayerRows ) do
		if not IsValid( k ) then
			v:Remove()
			self.PlayerRows[ k ] = nil
		end
	end
	
	local PlayerList = player.GetAll()	
	for id, pl in pairs( PlayerList ) do
		if not self:GetPlayerRow( pl ) then
			self:AddPlayerRow( pl )
		end
	end
	
	if self.Description then
		self.Description:SetText("Карта: "..CurrentMap.." Вагонов: "..(GetGlobalInt("metrostroi_train_count") or 0).."/"..(GetGlobalInt("metrostroi_maxwagons") or 0))
	end
	
	// Always invalidate the layout so the order gets updated
	self:InvalidateLayout()
end
vgui.Register( "suiscoreboard", PANEL, "Panel" )