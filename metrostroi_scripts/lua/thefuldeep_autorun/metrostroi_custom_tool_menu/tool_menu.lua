if SERVER then return end

CreateClientConVar("metrostroi_custom_time", "3", true, false, "" )

CreateClientConVar("hideothertrains", "0", true, false, "" )

CreateClientConVar("hidealltrains","0",true,false,"")

CreateClientConVar("hidetrains_behind_props","1",true,false,"")

CreateClientConVar("hidetrains_behind_player","1",true,false,"")

hook.Add( "PopulateToolMenu", "MetrostroiCustomPanel", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Metrostroi", "metrostroi_client_panel2", "Клиент2", "", "", function(panel)
		panel:ClearControls()
		panel:CheckBox("Показывать интервальные часы","showintervalclocks")
		panel:CheckBox("Режим съемки","metrostroi_screenshotmode")
		panel:CheckBox("Не прогружать все составы","hidealltrains")
		panel:CheckBox("Не прогружать чужие составы","hideothertrains")
		panel:CheckBox("Не прогружать составы за спиной","hidetrains_behind_player")
		panel:CheckBox("Не прогружать составы за пропами","hidetrains_behind_props")
		panel:NumSlider("Часовой пояс","metrostroi_custom_time",-12, 12,0)
	end)
end)