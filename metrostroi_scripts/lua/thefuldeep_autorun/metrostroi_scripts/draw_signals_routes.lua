local entsFindByClass = ents.FindByClass
local signals_class = "gmod_track_signal"

if SERVER then
	--установка нетворк значения 10 раз, чтобы поставилось "наверняка"
	local function SetNW2(func,ent,name,val) for i = 1,10 do func(ent,name,val) end end


	--прокачиваю метростревскую функцию сигналки, чтобы в ней ставить сетевые значения
	timer.Simple(0,function()
		local oldpostinit = Metrostroi.PostSignalInitialize
		Metrostroi.PostSignalInitialize = function(...)
			oldpostinit(...)
			for _,signal in pairs(entsFindByClass(signals_class)) do
				if not IsValid(signal) then continue end
				--тут установка количества роутов и стринги роутов
				local routes_with_commands = 0
				for _,route in pairs(signal.Routes or {}) do
					local routeName = route.RouteName
					if not routeName or routeName == "" then continue end
					routes_with_commands = routes_with_commands + 1
					SetNW2(signal.SetNW2String,signal,"RouteCommand"..routes_with_commands,routeName)
				end
				SetNW2(signal.SetNW2Int,signal,"RoutesCountWithCommands",routes_with_commands)
			end
		end
	end)
end

if SERVER then return end

local texts = {}--ентити, позиция, угол, таблица маршрутов

local maxdist = 1000*1000

local convar
timer.Simple(0,function()
	convar = GetConVar("draw_signal_routes")
end)

timer.Create("Get signals routes for drawing",2,0,function()
	local ply = LocalPlayer and LocalPlayer()
	if not IsValid(ply) then return end
	local plypos = ply:GetPos()
	
	texts = {}
	
	for _,signal in pairs(entsFindByClass(signals_class)) do
		if not IsValid(signal) or signal:GetPos():DistToSqr(plypos) > maxdist then continue end
		--тут получение роутов
		local routesCount = signal:GetNW2Int("RoutesCountWithCommands",0)
		if routesCount < 1 then continue end
		
		texts[#texts+1] = {signal,signal:GetPos()+Vector(0,0,100),signal:GetAngles()+Angle(0,180,90),{}}
		
		local commands = texts[#texts][4]
		for i = 1,routesCount do
			commands[i] = signal:GetNW2String("RouteCommand"..i,"")
		end
	end
end)



local font = "Default"
local drawSimpleTextOutlined = draw.SimpleTextOutlined
local r,g,b = 255,255,255
local color = Color(r,g,b,255)
local color2 = Color(255-r,255-g,255-b,255)
hook.Add("PostDrawOpaqueRenderables","Draw Signals Routes",function()
	if not convar or not convar:GetBool() then return end
	for _,params in pairs(texts) do
		cam.Start3D2D( params[2],params[3],1)
			local hlast = 0
			for _,text in pairs(params[4]) do
				local w,h = drawSimpleTextOutlined(text, font, 0, hlast, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color2)
				hlast = hlast + h
			end
		cam.End3D2D()
	end
end)