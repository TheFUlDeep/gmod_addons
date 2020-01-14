if SERVER then return end

local FPSLimit = 20
local TimeLimit = 10 * FPSLimit
local i = 0
hook.Add("Think","RecomendHideTrains",function()
	if not system.HasFocus() then return end
	local fps = 1 / RealFrameTime()
	if fps < FPSLimit then i = i + 1 else i = 0 end
	if i > TimeLimit then
		hook.Remove("Think","RecomendHideTrains")
		chat.AddText(
			Color(255,0,0),"Обнаружена низкая производительность. Для повышения fps попробуйте консольные команды ", 
			Color(255,255,0), "hideothertrains 1", 
			Color(255,0,0), " или ", 
			Color(255,255,0), "hidealltrains 1", 
			Color(255,0,0), ". А также убедитесь, что режим съемки выключен (", 
			Color(255,255,0), "metrostroi_screenshotmode 0", 
			Color(255,0,0), ")!"
		)
	end
end)

local Lastply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar

hook.Add("CalcView", "Get_Metrostroi_TrainView", function(ply,pos,ang,fov,znear,zfar)
	Lastply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar = ply,pos,ang,fov,znear,zfar
end)

--поиск инициализированных значений
local ViewPos,ViewAng,ViewFunction
local ply
local C_ScreenshotMode,hidealltrains,hideothertrains,hidetrains_behind_props,hidetrains_behind_player
local DefaultShouldRenderClientEntsFunction
timer.Simple(0,function()
	--прогружаю ply только тут один раз. Надеюсь, что во время игры эта переменная не изменится
	ply = LocalPlayer()

	C_ScreenshotMode      = GetConVar("metrostroi_screenshotmode")		-- прогружаю конвары здесь, чтобы случайно не прогрузить Nil
	hidealltrains = GetConVar("hidealltrains")
	hideothertrains = GetConVar("hideothertrains")
	hidetrains_behind_props = GetConVar("hidetrains_behind_props")
	hidetrains_behind_player = GetConVar("hidetrains_behind_player")
	
	local base = scripted_ents.Get("gmod_subway_base")
	DefaultShouldRenderClientEntsFunction = base.ShouldRenderClientEnts

	local HooksTbl = hook.GetTable()
	if not HooksTbl.CalcView or not HooksTbl.CalcView.Metrostroi_TrainView then return end
	print("Found metrostroi view changer hook")
	ViewFunction = HooksTbl.CalcView.Metrostroi_TrainView
end)

local PlyInTrain
local PlyInSeat
timer.Create("PlyInTrainForHideCheck",1,0,function()
	if not ply.InVehicle then return end
	if ply:InVehicle() then
		PlyInSeat = ply:GetVehicle()
		if not IsValid(PlyInSeat) then PlyInSeat = nil end
		PlyInTrain = PlyInSeat and PlyInSeat:GetNW2Entity("TrainEntity",nil) or nil
		if not IsValid(PlyInTrain) then PlyInTrain = nil end
	else
		PlyInSeat = nil
		PlyInTrain = nil
	end
end)

local tracelinesetup = {
	mask = MASK_VISIBLE_AND_NPCS,--MASK_BLOCKLOS_AND_NPCS
	output = {},
	filter = function(ent)
		if ent == LocalPlayer() or ent == PlyInSeat or ent == PlyInTrain or IsValid(ent) and PlyInTrain and PlyInTrain == ent:GetNW2Entity("TrainEntity") then return false end
		return true
	end
}

--[[local ENTS = Metrostroi.TrainClasses or {}
table.insert(ENTS,1,"gmod_metrostroi_mirror")

hook.Add("MetrostroiLoaded","CreateCustomEntsTbl for hidetrains",function()
	ENTS = Metrostroi.TrainClasses
	table.insert(ENTS,1,"gmod_metrostroi_mirror")
end)]]

local function SaveOBBMaxs(ent)
	local val = ent:OBBMaxs()
	ent.WagonSize = val
	--print("saving max size")
	return val
end

local function SaveOBBMins(ent)
	local val = ent:OBBMins()
	ent.WagonSize2 = val
	--print("saving min size")
	return val
end

local function ShouldRenderEnts(self)
	--Всегда прогружать, если режим съемки
	if C_ScreenshotMode:GetBool() then return true end

	--если игрок сидит в составе, то всегда прогружать его
	if PlyInTrain == self then return true end
	
	--проверка, находится ли состав за пропом и находится ли игрок рядом с диагоналями
	--ViewFunction - определение вида игрока
	if ViewFunction then
		local ViewTbl = ViewFunction(ply,ply:EyePos(),ply:GetAngles(),Lastfov,Lastznear,Lastzfar)
		if ViewTbl then
			ViewPos,ViewAng = ViewTbl.origin,ViewTbl.angles
		else
			ViewPos,ViewAng = nil,nil
		end
	end
	tracelinesetup.start = ViewPos or ply:EyePos()
	local TrainSize = self.WagonSize or SaveOBBMaxs(self)
	local TrainSize2 = self.WagonSize2 or SaveOBBMins(self)
	local step = 0.1
	local hidetrains_behind_props_bool = hidetrains_behind_props:GetBool()
	local ShouldRender = false
	--прохожу 4 диагонали
	for j = 1,4 do
		local startvec = j == 1 and TrainSize or j == 2 and TrainSize * Vector(1,1,-1) or j == 3 and TrainSize * Vector(1,-1,-1) or TrainSize * Vector(-1,-1,-1)
		local endvec = j == 1 and TrainSize2 or j == 2 and TrainSize2 * Vector(1,1,-1) or j == 3 and TrainSize2 * Vector(1,-1,-1)  or TrainSize2 * Vector(-1,-1,-1)
		startvec = self:LocalToWorld(startvec)
		endvec = self:LocalToWorld(endvec)
		for i = 0,1,step do
			local curvec = LerpVector(i, startvec, endvec)
			--если игрок рядом с составом, то прогружать
			if ply:GetPos():DistToSqr(curvec) < 22500--[[22500 ето 150^2]] then return true end
			
			--если надо проверять, за пропами ли вагон
			if not hidetrains_behind_props_bool then continue end
			tracelinesetup.endpos = curvec
			local output = util.TraceLine(tracelinesetup)
			--если состав не за пропом, то однозначно прогрузить
			if output.Fraction == 1 or output.Entity == self or output.Entity:GetNW2Entity("TrainEntity",nil) == self then ShouldRender = true end
		end
	end

	--метростроевские проверки
	if DefaultShouldRenderClientEntsFunction and not DefaultShouldRenderClientEntsFunction(self) then return false end
	
	--не прогружать, когда не вызывается Draw функция
	if hidetrains_behind_player:GetBool() and self.LastDrawCall and CurTime() - self.LastDrawCall > 1 then return false end--при фризах ето условие будет срабатывать часто. Можно либо детектить фриз, либо увеличить интервал

	--если надо скрыть все составы
	if hidealltrains:GetBool() then return false end

	--если надо скрыть все чужие составы
	if hideothertrains:GetBool() then
		local Owner = CPPI and self:CPPIGetOwner() or nil
		if Owner ~= ply then return false end
	end
	
	--если надо скрыть за пропами
	if hidetrains_behind_props_bool then return ShouldRender end
	
	return true
end

local function ChangeDrawFunctions(ent)
	if not ent.Draw or not ent.ShouldRenderClientEnts then return end
	local Draw = ent.Draw
	ent.Draw = function(self)
		self.LastDrawCall = CurTime()
		Draw(self)
	end
	ent.LaastShouldRenderClientEntsBool = false
	ent.LaastShouldRenderClientEntsTime = CurTime()
	ent.ShouldRenderClientEnts = function(self)
		local CurTime = CurTime()
		if CurTime - self.LaastShouldRenderClientEntsTime > 0.5 then --добавил микроинтервал, чтобы поднять фпс
			self.LaastShouldRenderClientEntsTime = CurTime
			self.LaastShouldRenderClientEntsBool = ShouldRenderEnts(self)
		end
		return self.LaastShouldRenderClientEntsBool
	end
end

Metrostroi = Metrostroi or {}
Metrostroi.ShouldHideTrain = ShouldRenderEnts

hook.Add("OnEntityCreated","UpdateTrainsDrawFunction",function(ent) timer.Simple(2,function()
	if not IsValid(ent) or ent.Base ~= "gmod_subway_base" or not table.HasValue(Metrostroi.TrainClasses, ent:GetClass()) then return end
	print("changing drawing ClientEnts function on "..tostring(ent))
	ChangeDrawFunctions(ent)
end)end)

