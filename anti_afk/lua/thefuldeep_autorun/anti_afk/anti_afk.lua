--TODO CUserCmd, StartCommand

if CLIENT then return end

local AntiAfkTimeConVar = CreateConVar("antiafk_ply",300,{FCVAR_ARCHIVE},"время до кика игрока в секундах")
local AntiAfkTimeConVar1 = CreateConVar("antiafk_train",600,{FCVAR_ARCHIVE},"время до удаления поезда в секундах")

local function UpdatePlayerAntiAfk(ply)
	--ply.AntiAfk.Pos = ply:GetPos()
	--ply.AntiAfk.Ang = Ang
	ply.AntiAfk.LastChange = CurTime()
	ply.AntiAfk.NotifShowed = nil
	if ply.AntiAfk.Afk then
		ply.AntiAfk.Afk = nil
		print(ply:Nick().." not afk")
		for k,ply1 in pairs(player.GetHumans()) do
			if not IsValid(ply1) then continue end
			ply1:ChatPrint(ply:Nick().." not afk")
		end
	end
end

timer.Create("AntiAfk",10,0,function()
	local AntiAfkTime = AntiAfkTimeConVar:GetInt()
	for n,ply in pairs(player.GetHumans()) do
		if not IsValid(ply) then continue end
		if not ply.AntiAfk then ply.AntiAfk = {} end
		--local Ang = ply:GetAngles() --ply:EyeAngles()
		if --[[not ply.AntiAfk.Pos or ply.AntiAfk.Pos ~= ply:GetPos() or]] ply.AntiAfk.AfkBlock
		--or not ply.AntiAfk.Ang or ply.AntiAfk.Ang ~= Ang 
		then
			UpdatePlayerAntiAfk(ply)
			--print("PlayerPosChanged")
		end
		
		if ply.AntiAfk.LastChange then
			local Delta = CurTime() - ply.AntiAfk.LastChange
			if Delta >= 180 and not ply.AntiAfk.Afk then
				ply.AntiAfk.Afk = true
				print(ply:Nick().." afk")
				for k,ply1 in pairs(player.GetHumans()) do
					if not IsValid(ply1) then continue end
					ply1:ChatPrint(ply:Nick().." afk")
				end
			end
			if not ply.AntiAfk.NotifShowed and AntiAfkTime > 120 and AntiAfkTime - Delta < 60 then ply:ChatPrint("Вас кикнет менее чем через минуту, если вы не пошевелнётесь!") ply.AntiAfk.NotifShowed = true end
			if Delta > AntiAfkTime then ply:Kick("AntiAfk") end
		end
	end
	
	AntiAfkTime = AntiAfkTimeConVar1:GetInt()
	if Metrostroi and Metrostroi.TrainClasses then
		for k,TrainClass in pairs(Metrostroi.TrainClasses) do
			for n,wag in pairs(ents.FindByClass(TrainClass)) do
				if not IsValid(wag) then continue end
				if not wag.AntiAfk then wag.AntiAfk = {} end
				local Pos = wag:GetPos()
				--local Ang = wag:GetAngles() --wag:EyeAngles()
				if not wag.AntiAfk.Pos or wag.AntiAfk.Pos:DistToSqr(Pos) > 15*15 --я не уверен в этом числе
				--or not wag.AntiAfk.Ang or wag.AntiAfk.Ang ~= Ang 
				then
					wag.AntiAfk.Pos = Pos
					--wag.AntiAfk.Ang = Ang
					wag.AntiAfk.LastChange = CurTime()
					wag.AntiAfk.NotifShowed = nil
					--print("PlayerPosChanged")
				end
				
				if wag.AntiAfk.LastChange then
					local Delta = CurTime() - wag.AntiAfk.LastChange
					if not wag.AntiAfk.NotifShowed and AntiAfkTime > 120 and AntiAfkTime - Delta < 60 and CPPI and IsValid(wag:CPPIGetOwner()) then
						wag:CPPIGetOwner():ChatPrint("Ваш состав удлится менее чем через минуту, если он не сдвинется!") 
						if wag.WagonList then
							for i,wag1 in pairs(wag.WagonList) do
								if not wag1.AntiAfk then wag1.AntiAfk = {} end
								wag1.AntiAfk.NotifShowed = true
							end
						else
							wag.AntiAfk.NotifShowed = true 
						end
					end
					if Delta > AntiAfkTime then
						local Owner = CPPI and wag:CPPIGetOwner()
						if IsValid(Owner) then Owner:ChatPrint("Удаляю "..tostring(wag)) end
						wag:Remove() 
					end
				end
			end
		end
	end
end)

hook.Add("PlayerInitialSpawn","AnfiAfk",function(ply) 
	if not ply.AntiAfk then ply.AntiAfk = {} end
	ply.AntiAfk.AfkBlock = true
end)

hook.Add("PlayerButtonDown","AnfiAfk1",function(ply) 
	if not ply.AntiAfk then ply.AntiAfk = {} end
	UpdatePlayerAntiAfk(ply)
end)

hook.Add("PlayerButtonUp","AnfiAfk2",function(ply) 
	if not ply.AntiAfk then ply.AntiAfk = {} end
	UpdatePlayerAntiAfk(ply)
end)
