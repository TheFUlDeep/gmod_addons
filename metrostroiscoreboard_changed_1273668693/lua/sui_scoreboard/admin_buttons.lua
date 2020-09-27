local PANEL = {}

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function PANEL:DoClick()

	if ( !self:GetParent().Player || LocalPlayer() == self:GetParent().Player ) then return end

	self:DoCommand( self:GetParent().Player )
	timer.Simple( 0.1, SuiScoreBoard.UpdateScoreboard())

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint( w,h )
	
	local bgColor = Color( 200,200,200,100 )

	if ( self.Selected ) then
		bgColor = Color( 135, 135, 135, 100 )
	elseif ( self.Armed ) then
		bgColor = Color( 175, 175, 175, 100 )
	end
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), bgColor )
	
	draw.SimpleText( self.Text, "DefaultSmall", self:GetWide() / 2, self:GetTall() / 2, color_0_0_0_150, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	return true

end


vgui.Register( "suispawnmenuadminbutton", PANEL, "Button" )



/*   PlayerKickButton */

PANEL = {}
PANEL.Text = "Kick"

/*---------------------------------------------------------
   Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand( ply )

	LocalPlayer():ConCommand( "kickid ".. ply:UserID().. " Kicked By "..LocalPlayer():Nick().."\n" )
	
end

vgui.Register( "suiplayerkickbutton", PANEL, "suispawnmenuadminbutton" )



/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "PermBan"

/*---------------------------------------------------------
   Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand( ply )

	LocalPlayer():ConCommand( "banid 0 ".. self:GetParent().Player:UserID().. "\n" )
	LocalPlayer():ConCommand( "kickid ".. ply:UserID().. " Permabanned By "..LocalPlayer():Nick().."\n" )
	
end

vgui.Register( "suiplayerpermbanbutton", PANEL, "suispawnmenuadminbutton" )



/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "1hr Ban"

/*---------------------------------------------------------
   Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand( ply )

	LocalPlayer():ConCommand( "banid 60 ".. self:GetParent().Player:UserID().. "\n" )
	LocalPlayer():ConCommand( "kickid ".. ply:UserID().. " Banned for 1 hour By "..LocalPlayer():Nick().."\n" )
	
end

vgui.Register( "suiplayerbanbutton", PANEL, "suispawnmenuadminbutton" )