include( "player_infocard.lua" )

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

local texGradient = surface.GetTextureID( "gui/center_gradient" )

--[[local texRatings = {}
texRatings[ 'none' ] 		= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'smile' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'lol' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'gay' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'stunter' ] 	= surface.GetTextureID( "gui/inv_corner16" )
texRatings[ 'god' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'curvey' ] 		= surface.GetTextureID( "gui/corner16" )
texRatings[ 'best_landvehicle' ]	= surface.GetTextureID( "gui/faceposer_indicator" )
texRatings[ 'best_airvehicle' ] 		= surface.GetTextureID( "gui/arrow" )
texRatings[ 'naughty' ] 	= surface.GetTextureID( "gui/silkicons/exclamation" )
texRatings[ 'friendly' ]	= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'informative' ]	= surface.GetTextureID( "gui/info" )
texRatings[ 'love' ] 		= surface.GetTextureID( "gui/silkicons/heart" )
texRatings[ 'artistic' ] 	= surface.GetTextureID( "gui/silkicons/palette" )
texRatings[ 'gold_star' ] 	= surface.GetTextureID( "gui/silkicons/star" )
texRatings[ 'builder' ] 	= surface.GetTextureID( "gui/silkicons/wrench" )

surface.GetTextureID( "gui/silkicons/emoticon_smile" )]]

local PANEL = {}

--[[---------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:Paint( w, h )
	if not IsValid( self.Player ) then
		self:Remove()
		SCOREBOARD:InvalidateLayout()
		return 
	end 
	
	local color = Color( 100, 100, 100, 255 )

	if self.Armed then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Selected then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Player:Team() == TEAM_CONNECTING then
		color = Color( 100, 100, 100, 155 )
	elseif IsValid( self.Player ) then
		if self.Player:Team() == TEAM_UNASSIGNED then
			color = Color( 100, 100, 100, 255 )
		else	
			color = team.GetColor( self.Player:Team() )
		end
	elseif self.Player:IsAdmin() then
		color = Color( 255, 155, 0, 255 )
	end
	
	if self.Player == LocalPlayer() then
		color = team.GetColor( self.Player:Team() )
	end
	
	if self.Player:GetPlayerInfo().guid == "STEAM_0:1:50996836" then
		color = Color( 255,127,127, 255 )
	end

	if self.Open or self.Size ~= self.TargetSize then
		draw.RoundedBox( 4, 18, 16, self:GetWide() - 36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide() - 40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawTexturedRect( 20, 16, self:GetWide() - 40, self:GetTall() - 18 )
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide() - 36, 38, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 150 )
	surface.DrawTexturedRect( 0, 0, self:GetWide() - 36, 38 ) 
	
	--[[surface.SetTexture( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.DrawTexturedRect( 20, 4, 16, 16 )
	surface.DrawTexturedRect( 56, 3, 16, 16 )]]
	
	return true
end

--[[---------------------------------------------------------
   Name: SetPlayer
---------------------------------------------------------]]
function PANEL:SetPlayer( ply )
	self.Player = ply
	self.infoCard:SetPlayer( ply )
	self:UpdatePlayerData()
	self.imgAvatar:SetPlayer( ply )
end

--[[function PANEL:CheckRating( name, count )
	if self.Player:GetNetworkedInt( "Rating." .. name, 0 ) > count then
		count = self.Player:GetNetworkedInt( "Rating." .. name, 0 )
		self.texRating = texRatings[ name ]
	end
	return count
end]]

----[[---------------------------------------------------------
   --Name: UpdatePlayerData
---------------------------------------------------------]]\
local function GetNickUntilSpace(str)
	local start = string.find(str," ")
	if start then return string.sub(str,1,start - 1) end
	return str
end

local DataTBL = {}
net.Receive("ScoreBoardAdditional",function()
	local Pos,Train,SteamID,Path,Owner = net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString()
	if not DataTBL[SteamID] then DataTBL[SteamID] = {} end
	DataTBL[SteamID] = {Pos,Train,Path,Owner}
end)

function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid( ply ) then return end
	
	self.lblName:SetText( ply:Nick() )
	self.lblMetadninLink:SetText("БД")
	self.lblMetadninLink.DoClick = function()
		gui.OpenURL( "http://metrostroi.net/profile/" .. self.Player:GetPlayerInfo().guid )
	end
	if ulibcheck then self.lblTeam:SetText( ScrW() > 1020 and team.GetName( ply:Team() ) or string.sub(team.GetName(ply:Team()),1,2)..".") end
	
	if self.Player:GetPlayerInfo().guid == "STEAM_0:1:50996836" then
		if ulibcheck then self.lblTeam:SetText( "Плейгокс" ) end
	end
	if utimecheck then self.lblHours:SetText( math.floor( ply:GetUTimeTotalTime() / 3600 ) ) end
	self.lblHealth:SetText( ply:Health() )
	self.lblFrags:SetText( ply:Frags() )
	self.lblDeaths:SetText( ply:Deaths() )
	self.lblPing:SetText( ply:Ping() )
	
	local SteamID = ply:SteamID()
	--if SteamID == "NULL" then SteamID = "BOT" end			-- это для ботов, но у всех ботов одинаковый стимайди и там надо еще по нику проверять, так что на ботов забить
	local Pos = ""
	local Train = ""
	local Path = ""
	if DataTBL[SteamID] then
		Pos = DataTBL[SteamID][1]
		Train = DataTBL[SteamID][2]
		Path = DataTBL[SteamID][3]
	end
	if ScrW() < 1800 then
		if string.sub(Pos,1,15) == "перегон " then
			Pos = "перегон "
		end
	end
	self.lblPos:SetText(Pos ~= "" and Pos..Path or "-")
	self.lblInTrain:SetText(Train ~= "" and Train or "-")
	
	-- Change the icon of the mute button based on state
	if  self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
		self.Muted = self.Player:IsMuted()
		if self.Muted then
			self.lblMute:SetImage( "icon32/muted.png" )
		else
			self.lblMute:SetImage( "icon32/unmuted.png" )
		end

		self.lblMute.DoClick = function() self.Player:SetMuted( not self.Muted ) end
	end
	
	self.lblInTrain.DoClick = function() 
		if self.lblInTrain:GetText() == "-" or not DataTBL[SteamID] or not DataTBL[SteamID][4] or DataTBL[SteamID][4] == "" then return end
		RunConsoleCommand("ulx","traintp",GetNickUntilSpace(DataTBL[SteamID][4]))
		--print("тп в состав игрока")
	end
	
	self.lblName.DoClick = function() 
		if ply:SteamID() == LocalPlayer():SteamID() then return end
		RunConsoleCommand("ulx","goto",GetNickUntilSpace(ply:Nick()))
		--print("тп к игроку")
	end
	
	self.lblPos.DoClick = function()
		local text = self.lblPos:GetText()
		if text == "-" then return end
		if string.sub(text,1,11) == "тупик " then text = string.sub(text,12) end
		if string.sub(text,1,15) == "перегон " then
			if string.sub(text,-13,-3) == " (путь " then
				local start = stringfind(text," - ")
				if start then
					text = string.sub(text,start + 4,-14)
				end
			end
		if string.sub(text,1,14) == "перегон" then return end
		end
		RunConsoleCommand("ulx","station",GetNickUntilSpace(text))
		--print("тп на станцию")
	end

	local k = ply:Frags()
	local d = ply:Deaths()
	local kdr = "--   "
	if d ~= 0 then
	   kdr = k / d
	   local y, z = math.modf( kdr )
	   z = string.sub( z, 1, 5 )
	   if y ~= 0 then kdr = string.sub( y + z, 1, 5 ) else kdr = z end
	   kdr = kdr .. ":1"
	   if k == 0 then kdr = k .. ":" .. d end
	end

	
	// Work out what icon to draw
	--[[self.texRating = surface.GetTextureID( "gui/silkicons/emoticon_smile" )

	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'smile', count )
	count = self:CheckRating( 'love', count )
	count = self:CheckRating( 'artistic', count )
	count = self:CheckRating( 'gold_star', count )
	count = self:CheckRating( 'builder', count )
	count = self:CheckRating( 'lol', count )
	count = self:CheckRating( 'gay', count )
	count = self:CheckRating( 'curvey', count )
	count = self:CheckRating( 'god', count )
	count = self:CheckRating( 'stunter', count )
	count = self:CheckRating( 'best_landvehicle', count )
	count = self:CheckRating( 'best_airvehicle', count )
	count = self:CheckRating( 'friendly', count )
	count = self:CheckRating( 'informative', count )
	count = self:CheckRating( 'naughty', count )]]
end

--[[---------------------------------------------------------
   Name: Init
---------------------------------------------------------]]
function PANEL:Init()
	self.Size = 38
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "suiscoreplayerinfocard", self )
	
	self.lblName 	= vgui.Create( "DButton", self )
	self.lblMetadninLink 	= vgui.Create( "DButton", self )
	if ulibcheck then self.lblTeam 	= vgui.Create( "DLabel", self ) end
	if utimecheck then  self.lblHours 	= vgui.Create( "DLabel", self ) end
	self.lblHealth 	= vgui.Create( "DLabel", self )
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblInTrain 	= vgui.Create( "DButton", self )
	self.lblPos 	= vgui.Create( "DButton", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	self.lblMute = vgui.Create( "DImageButton", self)
	self.lblPing:SetText( "9999" )
	
	self.btnAvatar = vgui.Create( "DButton", self )
	self.btnAvatar.DoClick = function() self.Player:ShowProfile() end
	
	self.imgAvatar = vgui.Create( "AvatarImage", self.btnAvatar )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( true )
	self.lblMetadninLink:SetMouseInputEnabled( true )
	if ulibcheck then self.lblTeam:SetMouseInputEnabled( false ) end
	if utimecheck then self.lblHours:SetMouseInputEnabled( false ) end
	self.lblHealth:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblInTrain:SetMouseInputEnabled( true )
	self.lblPos:SetMouseInputEnabled( true )
	self.lblPing:SetMouseInputEnabled( false )
	self.imgAvatar:SetMouseInputEnabled( false )
	self.lblMute:SetMouseInputEnabled( true )
end

--[[---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------]]
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont( "suiscoreboardplayername" )
	self.lblMetadninLink:SetFont( "suiscoreboardplayername" )
	if ulibcheck then self.lblTeam:SetFont( "suiscoreboardplayername" ) end
	if utimecheck then self.lblHours:SetFont( "suiscoreboardplayername" ) end
	self.lblHealth:SetFont( "suiscoreboardplayername" )
	self.lblFrags:SetFont( "suiscoreboardplayername" )
	self.lblDeaths:SetFont( "suiscoreboardplayername" )
	self.lblInTrain:SetFont( "suiscoreboardplayername" )
	self.lblPos:SetFont( "suiscoreboardplayername" )
	self.lblPing:SetFont( "suiscoreboardplayername" )
	
	self.lblName:SetTextColor( color_black )
	self.lblMetadninLink:SetTextColor( color_black )
	if ulibcheck then self.lblTeam:SetTextColor( color_black ) end
	if utimecheck then self.lblHours:SetTextColor( color_black ) end
	self.lblHealth:SetTextColor( color_black )
	self.lblFrags:SetTextColor( color_black )
	self.lblDeaths:SetTextColor( color_black )
	self.lblInTrain:SetTextColor( color_black )
	self.lblPos:SetTextColor( color_black )
	self.lblPing:SetTextColor( color_black )
end

--[[---------------------------------------------------------
   Name: OpenInfo
   ---------------------------------------------------------]]
function PANEL:OpenInfo( open )
	if open then
		self.TargetSize = 154
	else
		self.TargetSize = 38
	end
	self.Open = open
end

--[[---------------------------------------------------------
   Name: Think
---------------------------------------------------------]]
function PANEL:Think()
	if self.Size ~= self.TargetSize then
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end
	
	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

--[[---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:PerformLayout()
	self:SetSize( self:GetWide(), self.Size )
	
	self.btnAvatar:SetPos( 21, 4 )
	self.btnAvatar:SetSize( 32, 32 )
	
 	self.imgAvatar:SetSize( 32, 32 )
	self.lblMute:SetSize(32,32)
	
	self.lblName:SizeToContents()
	self.lblMetadninLink:SizeToContents()
	local k = 1/(ScrW()/70000)
	local res = ScrW()
	if res > 1500 then
		res = 0
		k = 0 
	else
		res = -9999
	end
	self.lblMetadninLink:SetPos( self:GetParent():GetWide() / 4 - 35 + k, 10 )
	if ulibcheck then self.lblTeam:SizeToContents() end
	if utimecheck then self.lblHours:SizeToContents() end
	self.lblHealth:SizeToContents()
	self.lblFrags:SizeToContents()
	self.lblDeaths:SizeToContents()
	self.lblInTrain:SizeToContents()
	self.lblPos:SizeToContents()
	self.lblPing:SizeToContents()
	self.lblPing:SetWide( 100 )
	
	self.lblName:SetPos( 60, 10)
	self.lblMute:SetPos( self:GetParent():GetWide() - 45 - 8, 2)
	self.lblPing:SetPos( self:GetParent():GetWide() - 85, 10)
	if utimecheck then self.lblHours:SetPos( self:GetParent():GetWide() - 85 - 34, 10) end
	self.lblHealth:SetPos( self:GetParent():GetWide() - 85 - 34 - 54, 10)
	self.lblDeaths:SetPos( self:GetParent():GetWide() - 85 - 34 - 54 - 48, 10)
	self.lblFrags:SetPos( self:GetParent():GetWide() - 85 - 34 - 54 - 48 - 64, 10)
	self.lblInTrain:SetPos( self:GetParent():GetWide() - 85 - 34 - 54 - 48 - 64 - 198 - res + 80 + 6, 10)
	local j = 0
	if ScrW() > 1800 then
		j = 120
	end
	self.lblPos:SetPos( self:GetParent():GetWide() - 85 - 34 - 54 - 48 - 64 - 198 - 234 - res + 80 + 6 - 68 - 20 - j, 10)
	if ulibcheck then self.lblTeam:SetPos( self:GetParent():GetWide() / 4 - 3 + k, 10) end
	
	
	if self.Open or self.Size ~= self.TargetSize then
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 27 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() + 5 )
	else
		self.infoCard:SetVisible( false )
	end
	
end

--[[---------------------------------------------------------
   Name: HigherOrLower
---------------------------------------------------------]]
function PANEL:HigherOrLower( row )
	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end
	
	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() < row.Player:Team()
	end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()
end

vgui.Register( "suiscoreplayerrow", PANEL, "DButton" )