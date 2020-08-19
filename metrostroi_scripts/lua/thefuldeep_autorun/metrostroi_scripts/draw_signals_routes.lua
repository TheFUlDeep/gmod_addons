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
					tableinsert(commands,1,routeName)
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

local texts = {}--ентити, позиция, угол, таблица маршрутов

local signalsCommands = {}
net.Receive("SignalsRoutesForDrawing", function()
	signalsCommands = net.ReadTable()
end)

local maxdist = 1000*1000

local convar
timer.Simple(0,function()
	convar = GetConVar("draw_signal_routes")
end)

local entsGetByIndex = ents.GetByIndex
timer.Create("Get signals routes for drawing",2,0,function()
	local ply = LocalPlayer and LocalPlayer()
	if not IsValid(ply) then return end
	local plypos = ply:GetPos()
	
	texts = {}
	
	for _,signal in pairs(entsFindByClass(signals_class)) do
		if not IsValid(signal) or signal:GetPos():DistToSqr(plypos) > maxdist then continue end
		
		local commands = signalsCommands[signal:EntIndex()] or {}
		if signal:GetNW2Bool("Close") then commands[#commands+1] = "закрыт вручную" end
		
		if #commands < 1 then continue end
		
		texts[#texts+1] = {signal,signal:GetPos()+Vector(0,0,80),signal:GetAngles()+Angle(0,180,90),commands}
	end
end)



local font = "Default"
local drawSimpleTextOutlined = draw.SimpleTextOutlined
local r,g,b = 255,255,255
local color = Color(r,g,b,255)
local color2 = Color(255-r,255-g,255-b,255)
hook.Add("PostDrawOpaqueRenderables","Draw Signals Routes",function()
	--if not convar or not convar:GetBool() then return end
	for _,params in pairs(texts) do
		cam.Start3D2D( params[2],params[3],1)
			local hlast = 0
			for _,text in pairs(params[4]) do
				local w,h = drawSimpleTextOutlined(text, font, 0, hlast, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color2)
				hlast = hlast - h
			end
		cam.End3D2D()
	end
end)