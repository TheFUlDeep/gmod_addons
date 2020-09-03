local entsFindByClass = ents.FindByClass
local signals_class = "gmod_track_signal"
local tableinsert = table.insert

if SERVER then
	util.AddNetworkString("SignalsRoutesForDrawing")

	local function SendRoutesInfo(ply)
		timer.Simple(1,function()
			local signalsCommands = {}
			for _,signal in pairs(entsFindByClass(signals_class)) do
				if not IsValid(signal) then continue end
				local commands = {}
				
				for _,route in pairs(signal.Routes or {}) do
					local routeName = route.RouteName
					if not routeName or routeName == "" then
						if route.Manual then
							routeName = signal.Name or ""
						else
							continue
						end
					end
					routeName = '"'..routeName..'"'
					if route.Emer then routeName = "Emergency "..routeName end
					tableinsert(commands,1,routeName)--мне тут надо в обратном порядке, потому что я рисую текста снизу вверх
				end
				if #commands < 1 then continue end
				
				signalsCommands[signal:EntIndex()] = commands
			end
				
			net.Start("SignalsRoutesForDrawing")
				net.WriteTable(signalsCommands)
			if ply then 
				net.Send(ply)
			else
				net.Broadcast()
			end
		end)
	end

	
	timer.Simple(0,function()
		local oldload = Metrostroi.Load
		Metrostroi.Load = function(...)
			oldload(...)
			SendRoutesInfo()
		end
	end)
	
	hook.Add("PlayerInitialSpawn","Send routes info for drawing",SendRoutesInfo)
	
	timer.Create("Update Close NW2 value for signals",2,0,function()
		for _,v in pairs(entsFindByClass(signals_class)) do
			if not IsValid(v) then continue end
			v:SetNW2Bool("Close",v.Close)
		end
	end)
end

if SERVER then return end

local texts = {}--ентити, позиция, угол, таблица маршрутов, закрыт ли вручную

local signalsCommands = {}
net.Receive("SignalsRoutesForDrawing", function()
	signalsCommands = net.ReadTable()
end)


local C_Enabled
local C_Distance
timer.Simple(0,function()
	C_Enabled = GetConVar("draw_signal_routes")
	if not C_Enabled then C_Enabled = CreateClientConVar("draw_signal_routes","1",true,false,"") end
	
	C_Distance = GetConVar("draw_signal_routes_distance")
	if not C_Distance then C_Distance = CreateClientConVar("draw_signal_routes_distance","2000",true,false,"") end
end)


local maxdistDef = 2000*2000
--методом os.clock было вычислено, что постоянный потсоянный по таблице из 200 элементов медленнее, чем потсоянный проход по таблице из 10ти элементов при постоянной ее очистке и обращении к таблице из 200 по ключу раз в секунду
--разница в производительности примерно в 10 раз
--короче чем больше таблица, тем медленнее работает. Поэтому в таймере я делаю маленькую таблицу, из которой уже ресуются текста
THEFULDEEP = THEFULDEEP or {}
local THEFULDEEP = THEFULDEEP
THEFULDEEP.RealViewPos = Vector(0)
timer.Create("Get signals routes for drawing",1,0,function()
	texts = {}
	if C_Enabled and C_Enabled:GetBool() then		
		local maxdist = C_Distance and C_Distance:GetInt()^2 or maxdistDef
		local viewpos = THEFULDEEP.RealViewPos
		
		for _,signal in pairs(entsFindByClass(signals_class)) do
			if not IsValid(signal) or signal:GetPos():DistToSqr(viewpos) > maxdist then continue end
			
			local commands = signalsCommands[signal:EntIndex()] or {}
			
			local IsClosedManually = signal:GetNW2Bool("Close")
			
			if #commands < 1 and not IsClosedManually then continue end
			
			texts[#texts+1] = {signal,signal:GetPos()+Vector(0,0,80),signal:GetAngles()+Angle(0,180,90),commands,IsClosedManually}
		end
	end
end)



local font = "Default"
local drawSimpleTextOutlined = draw.SimpleTextOutlined
local r,g,b = 255,255,255
local color = Color(r,g,b,255)
local color2 = Color(255-r,255-g,255-b,255)
local EyePos = EyePos
hook.Add("PostDrawEffects","Draw Signals Routes",function()
	THEFULDEEP.RealViewPos = EyePos()
	
	for _,params in pairs(texts) do
		cam.Start3D2D(params[2],params[3],1)
			local hlast = 0
			for _,text in pairs(params[4]) do
				local w,h = drawSimpleTextOutlined(text, font, 0, hlast, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color2)
				hlast = hlast - h
			end
			if params[5] then drawSimpleTextOutlined("закрыт вручную", font, 0, hlast, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color2) end
		cam.End3D2D()
	end
end)

