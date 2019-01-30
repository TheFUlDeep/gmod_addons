//Increase this if the menu shows on map change.
local DelayTime = 10

--айпи второго сервера
local secondip
if GetHostName():find("1") then 
	secondip = "metronorank.ddns.net:27017"
else
	secondip = "metronorank.ddns.net:27016"
end

//What's the title?
local Title = GetHostName()

//What is the estimated time in seconds it takes for the server to restart after a crash?
local ServerRestartTime = 15

//What message do you want to display when the server has crashed?
local Message = "Возможно это краш, рестарт или проблема с вашим подключением к сети.\nПодождите "..ServerRestartTime.. " секунд перед переподключением.\nИли выйти в главное меню."

local BackgroundColor = Color(200,200,200)

local ButtonColor = Color(236, 240, 241)
local ButtonHoverColor = Color(64,64,64)

local TitleTextColor = Color(236, 240, 241)
local MessageTextColor = Color(236, 240, 241)
local ButtonTextColor = Color(64,64,64)

//Insert the YouTube URL if you want music. Make sure you put it in quotes.
//Leave it at nil if you don't want any music.
local YouTubeURL = nil

//Server buttons(Limit 3).
local ServerNameButtons = {
	"Зайти на другой сервер"
}

//Make sure it corresponds to the server names above!
//You can also do websites. Have it start with http://
local ServerIPButtons = {
	secondip
}

//Delete the code inside the brackets of both the ServerNameButtons and ServerIPButtons if you don't need server buttons.

local CM = {}

if SERVER then
	util.AddNetworkString("CM.Pong")

	function CM.Ping(ply, cmd, args)
		if !ply.LastPing or ply.LastPing + 5 < CurTime() then
			ply.LastPing = CurTime()
			
			net.Start("CM.Pong")
			net.Send(ply)
		end
	end
	concommand.Add("checkping", CM.Ping)

	return
end

function xRes(num)
	local xMul = ScrW() / num
	return ScrW() / xMul
end

function yRes(num)
	local yMul = ScrH() / num
	return ScrH() / yMul
end

CM.LastMoveTime = CurTime() + 10
CM.Crashed = false
CM.CanSpawn = false
CM.SpawnTime = 0

function CM.CrashDetect()
	if !IsValid(LocalPlayer()) or !CM.CanSpawn or CM.Crashed or CM.SpawnTime > CurTime() or CM.LastMoveTime > CurTime() then 
		return 
	end

	if !LocalPlayer():IsFrozen() and !LocalPlayer():InVehicle() then
		return true
	end
end

function CM.Pong(len)
	CM.LastMoveTime = CurTime() + 10
end
net.Receive("CM.Pong", CM.Pong)

function CM.Move()
	CM.LastMoveTime = CurTime() + 1
end
hook.Add("Move", "CM.Move", CM.Move)

function CM.InitPostEntity()
	CM.CanSpawn = true
	CM.SpawnTime = CurTime() + 5
end
hook.Add("InitPostEntity", "CM.InitPostEntity", CM.InitPostEntity)

surface.CreateFont("CMTitle", {
	font = "Coolvetica", 
	size = xRes(150), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMFont", {
	font = "Coolvetica", 
	size = xRes(50), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMButton", {
	font = "Coolvetica", 
	size = xRes(40), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

surface.CreateFont("CMButton2", {
	font = "Coolvetica", 
	size = xRes(30), 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})


function CM.CrashMenu()
	for k, v  in ipairs(player.GetAll()) do
		v.CrashedPing = v:Ping()
	end
	
	local retryTime = CurTime() + ServerRestartTime
		
	local CMM = vgui.Create("DFrame")
	CMM:SetSize(ScrW(), ScrH())
	CMM:Center()
	CMM:SetTitle("")
	CMM:ShowCloseButton(false)
	CMM:MakePopup()
	CMM:SetDraggable(false)
	CMM.Paint = function()
		draw.RoundedBox(0, 0, 0, CMM:GetWide(), CMM:GetTall(), BackgroundColor)
		draw.SimpleText(Title, "CMTitle", xRes(200), yRes(150), TitleTextColor, TEXT_ALIGN_LEFT)
	end
	CMM:SetAlpha(0)
	CMM:AlphaTo(255, 0.5, DelayTime)

	local CMT = vgui.Create("DLabel", CMM)
	CMT:SetSize(ScrW() / 2 - xRes(200), ScrH())
	CMT:SetPos(xRes(200), yRes(150) + xRes(150) + yRes(100) - ScrH() / 2)
	CMT:SetText(Message)
	CMT:SetFont("CMFont")
	CMT:SetWrap(true)
	CMT:SetTextColor(MessageTextColor)
	
	if CMM:GetAlpha() == 255 then
		if YouTubeURL != nil then
			Song = vgui.Create("HTML")
			Song:SetPos(0,0)
			Song:SetSize(0, 0)
			Song:OpenURL(YouTubeURL)
		end
	end
	
	local bNum
	
	if ServerNameButtons != nil then
		bNum = #ServerNameButtons
	else
		bNum = 0
	end
	
	for i = 1, (bNum + 2) do	
		local CMR = vgui.Create("DButton", CMM)
		CMR:SetPos(ScrW() - (ScrW() / 2 - xRes(400)) - xRes(200), yRes(165) * i)
		CMR:SetText("")
		CMR:SetSize(ScrW() / 2 - xRes(400), yRes(100))
		
			local CMA = vgui.Create("DButton", CMM)
			CMA:SetPos(ScrW() - (ScrW() / 2 - xRes(400)) - xRes(200), yRes(165) * i)
			CMA:SetText("")
			CMA:SetSize(0, 0)
			CMR.OnCursorEntered = function()
				surface.PlaySound("buttons/lightswitch2.wav")
				CMA:SizeTo(ScrW() / 2 - xRes(400), 0, 0.5, 0, -1)
			end
			CMR.OnCursorExited = function()
				CMA:SizeTo(0, 0, 0.5, 0, -1)
			end
			CMA.Paint = function()
				draw.RoundedBox(0, 0, 0, 0, 0, Color(255, 255, 255))
			end
		
		CMR.Paint = function()	
			draw.RoundedBox(0, 0, 0, CMR:GetWide(), CMR:GetTall(), ButtonColor)
			
			draw.RoundedBox(0, 0, 0, CMA:GetWide(), yRes(100), ButtonHoverColor)
			
			local text = ""
			
			if i == (bNum + 1) then
				draw.SimpleText("Переподключение через:", "CMButton2", xRes(15), yRes(22), ButtonTextColor, TEXT_ALIGN_LEFT)
				draw.SimpleText(tostring(math.Round(retryTime - CurTime())).." секнуд!", "CMButton2", xRes(15), yRes(52), ButtonTextColor, TEXT_ALIGN_LEFT)
			elseif i == (bNum + 2) then
				text = "Выйти в главное меню!"
				
				draw.SimpleText(text, "CMButton", xRes(15), yRes(30), ButtonTextColor, TEXT_ALIGN_LEFT)
			else
				text = ServerNameButtons[i]
				
				draw.SimpleText(text, "CMButton", xRes(15), yRes(30), ButtonTextColor, TEXT_ALIGN_LEFT)
			end
		end
		
		CMR.DoClick = function()
			if i == (bNum + 2) and IsValid(LocalPlayer()) then 
				LocalPlayer():ConCommand("disconnect")
			end
			
			if i <= bNum then
				if string.find(ServerIPButtons[i], "http", 0, false) then
					gui.OpenURL(ServerIPButtons[i])
				else
					for k, v in pairs(player.GetAll()) do
						v:ConCommand("connect "..ServerIPButtons[i])
					end
				end
			end
			
			surface.PlaySound("buttons/button14.wav")
		end
	end

	local aPlay = false
	local bPlay = false
	local cPlay = false
	
	hook.Add("Think", "CrashRecover", function()
		for k, v in ipairs(player.GetAll()) do
			if v.CrashedPing != v:Ping() then
				hook.Remove("Think", "CrashRecover")
				
				CM.Crashed = false
				CM.LastMoveTime = CurTime() + 5
			end
		end
		
		if CM.Crashed and (retryTime - CurTime() - 0.5) <= 3 and CM.LastMoveTime + 5 < CurTime() then
			local a = (retryTime - CurTime() - 0.5) <= 3 and (retryTime - CurTime()) > 2
			local b = (retryTime - CurTime() - 0.5) <= 2 and (retryTime - CurTime()) > 1
			local c = (retryTime - CurTime() - 0.5) <= 1 and (retryTime - CurTime()) > 0
			if (a and aPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				aPlay = true
			elseif (b and bPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				bPlay = true
			elseif (c and cPlay == false) then
				surface.PlaySound("buttons/blip1.wav")
				
				cPlay = true
			elseif (retryTime - CurTime() - 0.5) <= 0 then
				surface.PlaySound("buttons/button3.wav")
			
				RunConsoleCommand("retry")
			end
		elseif CM.LastMoveTime > CurTime() then
			hook.Remove("Think", "CrashRecover")
			
			aPlay = false
			bPlay = false
			cPlay = false
			
			CM.Crashed = false
			
			if CMM and CMM:IsValid() then
				CMM:Close()
			end
		end
	end)
end

function CM.Think()
	if !CM.Crashed and CM.CrashDetect() then
		RunConsoleCommand("checkping")
		
		if CM.LastMoveTime < CurTime() then
			CM.Crashed = true
			
			CM.CrashMenu()
		else
			CM.Crashed = false
		end
	end
end
hook.Add("Think", "CM.Think", CM.Think)

MsgC(Color(52, 152, 219), "Loaded Server Crash Menu & Auto-Reconnection, an addon by Kalamitous.\n")