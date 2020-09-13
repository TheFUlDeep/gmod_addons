if SERVER then return end

concommand.Add("multi_thread_rendering", function()
	RunConsoleCommand("cl_threaded_client_leaf_system","1")
	RunConsoleCommand("mat_queue_mode","-1")
	RunConsoleCommand("cl_threaded_bone_setup","1")
	RunConsoleCommand("gmod_mcore_test","1")
	RunConsoleCommand("r_threaded_renderables","1")
	RunConsoleCommand("r_threaded_particles","1")
	RunConsoleCommand("r_queued_ropes","1")
	RunConsoleCommand("studio_queue_mode","1")
	chat.AddText("Многопоточный рендеринг включен.")
end)

CreateClientConVar("metrostroi_custom_time", "3", true, false, "" )

CreateClientConVar("hideothertrains", "0", true, false, "" )

CreateClientConVar("hidealltrains","0",true,false,"")

CreateClientConVar("hidetrains_behind_props","1",true,false,"")

CreateClientConVar("hidetrains_behind_player","1",true,false,"")

CreateClientConVar("draw_signal_routes","1",true,false,"")

CreateClientConVar("metrostroi_custom_passengers","0",true,false,"")

hook.Add( "PopulateToolMenu", "MetrostroiCustomPanel", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Metrostroi", "metrostroi_client_panel2", "Клиент2", "", "", function(panel)
		panel:ClearControls()
		panel:CheckBox("Показывать интервальные часы","showintervalclocks")
		panel:CheckBox("Режим съемки","metrostroi_screenshotmode")
		panel:CheckBox("Не прогружать все составы","hidealltrains")
		panel:CheckBox("Не прогружать чужие составы","hideothertrains")
		panel:CheckBox("Не прогружать составы за спиной","hidetrains_behind_player")
		panel:CheckBox("Не прогружать составы за пропами","hidetrains_behind_props")
		panel:CheckBox("Отображать команды светофоров","draw_signal_routes")
		panel:CheckBox("Кастомные пассажиры","metrostroi_custom_passengers")
		panel:Button("Вкл. многопоточный рендеринг", "multi_thread_rendering")
		panel:NumSlider("Часовой пояс","metrostroi_custom_time",-12, 12,0)
	end)
end)