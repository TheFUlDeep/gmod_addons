if CLIENT then return end

CreateConVar("antiafk_ply",300,{FCVAR_ARCHIVE},"время до кика игрока в секундах")
CreateConVar("antiafk_train",600,{FCVAR_ARCHIVE},"время до удаления поезда в секундах")

local AntiAfkTimeConVar = GetConVar("antiafk_ply")
local AntiAfkTimeConVar1 = GetConVar("antiafk_train")

timer.Create("AntiAfk",10,0,function()
	local AntiAfkTime = AntiAfkTimeConVar:GetInt()
	for n,ply in pairs(player.GetHumans()) do
		if not IsValid(ply) then continue end
		if not ply.AntiAfk then ply.AntiAfk = {} end
		local Pos = ply:GetPos()
		--local Ang = ply:GetAngles() --ply:EyeAngles()
		if not ply.AntiAfk.Pos or ply.AntiAfk.Pos ~= Pos 
		--or not ply.AntiAfk.Ang or ply.AntiAfk.Ang ~= Ang 
		then
			ply.AntiAfk.Pos = Pos
			--ply.AntiAfk.Ang = Ang
			ply.AntiAfk.LastChange = CurTime()
			ply.AntiAfk.NotifShowed = nil
			--print("PlayerPosChanged")
		end
		
		if ply.AntiAfk.LastChange then
			local Delta = CurTime() - ply.AntiAfk.LastChange
			if not ply.AntiAfk.NotifShowed and AntiAfkTime - Delta < 60 then ply:ChatPrint("Вас кикнет менее чем через минуту, если вы не пошевелнётесь!") ply.AntiAfk.NotifShowed = true end
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
				if not wag.AntiAfk.Pos or wag.AntiAfk.Pos:DistToSqr(Pos) > 50*50 --я не уверен в этом числе
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
					if not wag.AntiAfk.NotifShowed and AntiAfkTime - Delta < 60 and CPPI and IsValid(wag:CPPIGetOwner()) then
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
				if Delta > AntiAfkTime then wag:Remove() end
				end
			end
		end
	end
end)

