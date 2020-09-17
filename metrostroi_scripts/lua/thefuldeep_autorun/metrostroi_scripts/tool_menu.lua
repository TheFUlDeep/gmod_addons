if SERVER then return end

local multithread_enabled = CreateClientConVar("multi_thread_rendering_enabled", "1", true, false, "", 0, 1)

local disabling
local function Enable()
	if disabling then
		timer.Create("enable multithread rendering",1,0,function()
			if disabling then 
				return
			else
				if multithread_enabled:GetBool()then Enable()end
				timer.Remove("enable multithread rendering")
			end
		end)
		--chat.AddText("Происходит отключение многопотока, подожди несоклько секунд.")
		return
	end
	RunConsoleCommand("cl_threaded_client_leaf_system","1")
	RunConsoleCommand("mat_queue_mode","-1")
	RunConsoleCommand("cl_threaded_bone_setup","1")
	RunConsoleCommand("gmod_mcore_test","1")
	RunConsoleCommand("r_threaded_renderables","1")
	RunConsoleCommand("r_threaded_particles","1")
	RunConsoleCommand("r_queued_ropes","1")
	RunConsoleCommand("studio_queue_mode","1")
	RunConsoleCommand("r_threaded_client_shadow_manager","1")
	chat.AddText("Многопоточный рендеринг включен.")
end

local function Disable()
	if disabling then return end
	disabling = true
	timer.Simple(0.5,function()
		RunConsoleCommand("cl_threaded_client_leaf_system","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("mat_queue_mode","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("cl_threaded_bone_setup","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("gmod_mcore_test","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("r_threaded_renderables","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("r_threaded_particles","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("r_queued_ropes","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("studio_queue_mode","0")
	timer.Simple(0.5,function()
		RunConsoleCommand("r_threaded_client_shadow_manager","0")
		chat.AddText("Многопоточный рендеринг выключен.")
		disabling = false
	end)end)end)end)end)end)end)end)end)
end

local function EnableOrDisable()
	if multithread_enabled:GetBool()then Enable()else Disable()end
end

cvars.AddChangeCallback("multi_thread_rendering_enabled", EnableOrDisable)

timer.Simple(0,EnableOrDisable)

if not GetConVar("metrostroi_custom_time") then
CreateClientConVar("metrostroi_custom_time", "3", true, false, "" )
end

if not GetConVar("hideothertrains") then
CreateClientConVar("hideothertrains", "0", true, false, "" )
end


if not GetConVar("hidealltrains") then
CreateClientConVar("hidealltrains","0",true,false,"")
end


if not GetConVar("hidetrains_behind_props") then
CreateClientConVar("hidetrains_behind_props","1",true,false,"")
end


if not GetConVar("hidetrains_behind_player") then
CreateClientConVar("hidetrains_behind_player","1",true,false,"")
end


if not GetConVar("draw_signal_routes") then
CreateClientConVar("draw_signal_routes","1",true,false,"")
end


if not GetConVar("metrostroi_custom_passengers") then
CreateClientConVar("metrostroi_custom_passengers","0",true,false,"")
end

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
		panel:CheckBox("Вкл. многопоточный рендеринг","multi_thread_rendering_enabled")
		panel:NumSlider("Часовой пояс","metrostroi_custom_time",-12, 12,0)
	end)
end)