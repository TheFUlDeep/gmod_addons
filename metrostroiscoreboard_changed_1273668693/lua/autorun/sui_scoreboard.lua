if SERVER then
 
	AddCSLuaFile( "autorun/sui_scoreboard.lua" )
	AddCSLuaFile( "sui_scoreboard/admin_buttons.lua" )
	AddCSLuaFile( "sui_scoreboard/cl_tooltips.lua" )
	AddCSLuaFile( "sui_scoreboard/player_frame.lua" )
	AddCSLuaFile( "sui_scoreboard/player_infocard.lua" )
	AddCSLuaFile( "sui_scoreboard/player_row.lua" )
	AddCSLuaFile( "sui_scoreboard/scoreboard.lua" )
	AddCSLuaFile( "sui_scoreboard/vote_button.lua" )

	include( "sui_scoreboard/rating.lua" )
	
	/*resource.AddFile("materials/gui/silkicons/exclamation.vmt")
	resource.AddFile("materials/gui/silkicons/heart.vmt")
	resource.AddFile("materials/gui/silkicons/palette.vmt")
	resource.AddFile("materials/gui/silkicons/star.vmt")
	resource.AddFile("materials/gui/silkicons/user.vmt")*/
	
else
	include( "sui_scoreboard/scoreboard.lua" )

	SuiScoreBoard = nil
	
	timer.Simple( 1.5, function()
		function GAMEMODE:CreateScoreboard()
			if ( ScoreBoard ) then
			
				ScoreBoard:Remove()
				ScoreBoard = nil
				
			end
			
			SuiScoreBoard = vgui.Create( "suiscoreboard" )
			
			return true
		end

		function GAMEMODE:ScoreboardShow()
			if not SuiScoreBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SuiScoreBoard:UpdateScoreboard( true )
			SuiScoreBoard:SetVisible( true )
			
			return true
		end
		
		function GAMEMODE:ScoreboardHide()
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )
			if SuiScoreBoard then
				SuiScoreBoard:SetVisible( false )
			end
			return true
		end
	end )
end