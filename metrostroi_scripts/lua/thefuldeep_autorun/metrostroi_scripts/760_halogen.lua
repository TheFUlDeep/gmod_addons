--TODO на серверной части трабл со всетом
do return end
if SERVER then resource.AddWorkshop("1925235871") end

if CLIENT then
	MetrostroiWagNumUpdateRecieve = MetrostroiWagNumUpdateRecieve or function(index)
		local ent = Entity(index)
		--таймер, чтобы дождаться обновления сетевых значений (ну а вдруг)
		timer.Simple(0.3,function()
			if IsValid(ent) and ent.UpdateWagNumCallBack then 
				ent:UpdateWagNumCallBack()
				--ent:UpdateTextures()
			end
		end)
	end
end

if SERVER then
	local hooks = hook.GetTable()
	if not hooks.MetrostroiSpawnerUpdate or not hooks.MetrostroiSpawnerUpdate["Call hook on clientside"] then
		hook.Add("MetrostroiSpawnerUpdate","Call hook on clientside",function(ent)
			if not IsValid(ent) then return end
			local idx = ent:EntIndex()
			for _,ply in pairs(player.GetHumans())do
				if IsValid(ply)then ply:SendLua("MetrostroiWagNumUpdateRecieve("..idx..")")end
			end
		end)
	end
end

local function RemoveEnt(wag,prop)
	local ent = wag.ClientEnts and wag.ClientEnts[prop]
	if IsValid(ent) then SafeRemoveEntity(ent)end
end

local function UpdateCpropCallBack(ENT,cprop,modelcallback,precallback,callback)	
	if not ENT.UpdateWagNumCallBack then
		function ENT:UpdateWagNumCallBack()end
	end
	
	if modelcallback then
		local oldmodelcallback = ENT.ClientProps[cprop].modelcallback or function() end
		ENT.ClientProps[cprop].modelcallback = function(wag,...)
			return modelcallback(wag) or oldmodelcallback(wag,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if precallback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			precallback(wag,cent)
			oldcallback(wag,cent,...)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
	
	if callback then
		local oldcallback = ENT.ClientProps[cprop].callback or function() end
		ENT.ClientProps[cprop].callback = function(wag,cent,...)
			oldcallback(wag,cent,...)
			callback(wag,cent)
		end
		
		local oldstartedcallback = ENT.UpdateWagNumCallBack
		ENT.UpdateWagNumCallBack = function(wag)
			oldstartedcallback(wag)
			RemoveEnt(wag,cprop)
		end
	end
end

--нет проверки на рекурсию, ну да пофиг
local function TableCopy(tbl)
	local res = {}
	for k,v in pairs(tbl or {})do
		if istable(v) then 
			res[k] = TableCopy(v)
		else
			res[k] = v
		end
	end
	return res
end

hook.Add("InitPostEntity","Metrostroi 760 halogen lights",function()
	local OCHKA = scripted_ents.GetStored("gmod_subway_81-760")
	if not OCHKA then return else OCHKA = OCHKA.t end
	
	table.insert(OCHKA.Spawner,#OCHKA.Spawner-1,{"Halogen","Галокенни","Boolean"})
	
	if SERVER then
		local deflights
		local oldinit = OCHKA.Initialize
		OCHKA.Initialize = function(wag,...)
			oldinit(wag,...)
			deflights = TableCopy(wag.Lights)
		end
		
	
		local oldupdate = OCHKA.TrainSpawnerUpdate
		OCHKA.TrainSpawnerUpdate = function(wag,...)
			if deflights then
				wag.Lights[3] = TableCopy(deflights[3])
				wag.Lights[4] = TableCopy(deflights[4])
				wag:SetLightPower(3)
				--wag:SetLightPower(3,0)
				wag:SetLightPower(4)
				--wag:SetLightPower(4,0)
			end
			oldupdate(wag,...)
			if wag:GetNW2Bool("Halogen")then
				wag.Lights[3] = {"light",Vector(513,-36,-40),Angle(0,0,0),Color(216,161, 92),brightness = 0.5,scale = 2.5} 
				wag.Lights[4] = {"light",Vector(513, 36,-40),Angle(0,0,0),Color(216,161, 92),brightness = 0.5,scale = 2.5}
				wag:SetLightPower(3)
				--wag:SetLightPower(3,0,0)
				wag:SetLightPower(4)
				--wag:SetLightPower(4,0,0)
			end
		end
	end
	
	if SERVER then return end
	
	local deflightscolor = OCHKA.Lights[1][4]
	local deflightsbrightness = OCHKA.Lights[1].brightness
	
	OCHKA.ClientProps["models/metrostroi_train/81-760/81_760_headlamps_old.mdl"] = {
		model = "models/metrostroi_train/81-760/81_760_headlamps_old.mdl",
		pos=Vector(),
		ang=Angle(),
		nohide=true
	}
	
	local function precallback(wag)
		wag.Lights[1][4] = deflightscolor
		wag.Lights[1].brightness = deflightsbrightness
		wag:SetLightPower(1)
	end
	
	local function callback(wag)
		if wag:GetNW2Bool("Halogen")then
			wag.Lights[1][4] = Color(216,161,92)
			wag.Lights[1].brightness = 5
			wag:SetLightPower(1)
		end
	end
	
	--если UpdateWagNumCallBack не вызвалась из-за того, что состав уже был
	UpdateCpropCallBack(
		OCHKA,
		"HeadLights0",
		function(wag)
			wag:ShowHide("models/metrostroi_train/81-760/81_760_headlamps_old.mdl",wag:GetNW2Bool("Halogen"))--скроется, если прогрузится, но должно быть скрыто
		end,
		precallback,
		callback
	)
	
	local oldupdate = OCHKA.UpdateWagNumCallBack
	OCHKA.UpdateWagNumCallBack = function(wag)
		oldupdate(wag)
		wag:ShowHide("models/metrostroi_train/81-760/81_760_headlamps_old.mdl",wag:GetNW2Bool("Halogen"))
	end
	
	UpdateCpropCallBack(
		OCHKA,
		"HeadLights0",
		function(wag)
			if wag:GetNW2Bool("Halogen") then return "models/metrostroi_train/81-760/81_760_headlamps_old_off.mdl" end
		end,
		precallback,
		callback
	)
	UpdateCpropCallBack(
		OCHKA,
		"HeadLights1",
		function(wag)
			if wag:GetNW2Bool("Halogen") then return "models/metrostroi_train/81-760/81_760_headlamps_old_g1.mdl" end
		end,
		precallback,
		callback
	)
	UpdateCpropCallBack(
		OCHKA,
		"HeadLights2",
		function(wag)
			if wag:GetNW2Bool("Halogen") then return "models/metrostroi_train/81-760/81_760_headlamps_old_g2.mdl" end
		end,
		precallback,
		callback
	)
	
end)
