if SERVER then return end

THEFULDEEP = THEFULDEEP or {}
local THEFULDEEP = THEFULDEEP

local FPSLimit = 20
local TimeLimit = 15
local LagsStarted
hook.Add("Think","RecomendHideTrains",function()
	if not system.HasFocus() then return end
	local fps = 1 / RealFrameTime()
	if fps < FPSLimit then
		local CurTime = CurTime()
		if not LagsStarted then LagsStarted = CurTime end
		
		if CurTime - LagsStarted > TimeLimit then
			hook.Remove("Think","RecomendHideTrains")
			chat.AddText(
				Color(255,0,0),"Обнаружена низкая производительность. Для повышения fps попробуйте консольные команды ", 
				Color(255,255,0), "multi_thread_rendering_enable", 
				Color(255,0,0), ", ", 
				Color(255,255,0), "hideothertrains 1", 
				Color(255,0,0), " или ", 
				Color(255,255,0), "hidealltrains 1", 
				Color(255,0,0), ". А также убедитесь, что режим съемки выключен (", 
				Color(255,255,0), "metrostroi_screenshotmode 0", 
				Color(255,0,0), ")!"
			)
		end
	else
		LagsStarted = nil
	end
end)


--поиск инициализированных значений
local C_ScreenshotMode,hidealltrains,hideothertrains,hidetrains_behind_props,hidetrains_behind_player
local DefaultShouldRenderClientEntsFunction
timer.Simple(1,function()

	C_ScreenshotMode      = GetConVar("metrostroi_screenshotmode")		-- прогружаю конвары здесь, чтобы случайно не прогрузить Nil
	hidealltrains = GetConVar("hidealltrains")
	hideothertrains = GetConVar("hideothertrains")
	hidetrains_behind_props = GetConVar("hidetrains_behind_props")
	hidetrains_behind_player = GetConVar("hidetrains_behind_player")
	
	local base = scripted_ents.Get("gmod_subway_base")
	DefaultShouldRenderClientEntsFunction = base.ShouldRenderClientEnts
end)

local PlyInTrain
local PlyInSeat
timer.Create("PlyInTrainForHideCheck",1,0,function()
	local ply = LocalPlayer()
	if ply.InVehicle and ply:InVehicle() then
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

--вершины
local angles = {
	Vector(1,1,1),
	Vector(1,-1,1),
	Vector(1,-1,-1),
	Vector(1,1,-1),
	
	Vector(-1,1,1),
	Vector(-1,-1,1),
	Vector(-1,-1,-1),
	Vector(-1,1,-1),
	
	Vector(0,0,0)
}

--чуток уменьшаю
--[[for k,vector in pairs(angles)do
	for i = 1,3 do
		angles[k][i] = vector[i]*0.9
	end
end]]

--ребра
local lines = {
	{angles[1],angles[2]},
	{angles[2],angles[3]},
	{angles[3],angles[4]},
	{angles[4],angles[1]},
	
	{angles[5],angles[6]},
	{angles[6],angles[7]},
	{angles[7],angles[8]},
	{angles[8],angles[5]},
	
	{angles[1],angles[5]},
	{angles[2],angles[6]},
	{angles[3],angles[7]},
	{angles[4],angles[8]},
}

local mindist = (256+16)^2
local utilTraceLine = util.TraceLine
local function ShouldRenderEnts(self)
	--Всегда прогружать, если режим съемки
	if C_ScreenshotMode and C_ScreenshotMode:GetBool() then self.ShouldRenderClientEntsRes = true return end
	
	--метростроевские проверки
	if DefaultShouldRenderClientEntsFunction and not DefaultShouldRenderClientEntsFunction(self) then self.ShouldRenderClientEntsRes = false return end

	--если игрок сидит в составе, то всегда прогружать его
	if PlyInTrain == self then self.ShouldRenderClientEntsRes = true return end
	
	--проверка, находится ли состав за пропом и находится ли игрок рядом с диагоналями
	--local ply = LocalPlayer()
	
	local StartPos = THEFULDEEP.RealViewPos--эта переменная задается в файле draw_signals_routes.lua
	tracelinesetup.start = StartPos
	local TrainSize = self.WagonSize or SaveOBBMaxs(self)
	--local TrainSize2 = self.WagonSize2 or SaveOBBMins(self)
	--local step = 0.1
	local hidetrains_behind_props_bool = hidetrains_behind_props and hidetrains_behind_props:GetBool()
	local ShouldRender = false
	

	--прохожу по 10 точек на 12ти гранях
	--это более точный, но более ресурсоемкий алгоритм
	--[[for k,points in pairs(lines) do
		local startvec = self:LocalToWorld(points[1]*TrainSize)
		local endvec = self:LocalToWorld(points[2]*TrainSize)
		for i = 0,1,step do
			local curvec = LerpVector(i, startvec, endvec)
			--если игрок рядом с составом, то прогружать
			if ply:GetPos():DistToSqr(curvec) < 22500 then return true end ----22500 ето 150^2
			
			--если надо проверять, за пропами ли вагон
			if hidetrains_behind_props_bool then
				tracelinesetup.endpos = curvec
				local output = utilTraceLine(tracelinesetup)
				--если состав не за пропом, то однозначно прогрузить
				local resEnt = output.Entity
				if output.Fraction == 1 or  resEnt == self or IsValid(resEnt) and resEnt:GetNW2Entity("TrainEntity",nil) == self then 
					ShouldRender = true
					--использовал goto, потому что не захотел добавлять внешнюю переменную-флаг
					goto CONTINUE
				end
			end
		end
	end
	
	
	::CONTINUE::
	
	]]
	
	
	--прохожу 8 вершин и центр
	for _,point in pairs(angles)do
		local curvec = self:LocalToWorld(point*TrainSize)
		if StartPos:DistToSqr(curvec) < mindist then self.ShouldRenderClientEntsRes = true return end
		
		--если надо проверять, за пропами ли вагон
		if hidetrains_behind_props_bool then
			tracelinesetup.endpos = curvec
			local output = utilTraceLine(tracelinesetup)
			--если состав не за пропом, то однозначно прогрузить
			local resEnt = output.Entity
			if output.Fraction == 1 or  resEnt == self or IsValid(resEnt) and resEnt:GetNW2Entity("TrainEntity",nil) == self then 
				ShouldRender = true
				break
			end
		end
	end
	
	
	--не прогружать, когда не вызывается Draw функция
	if hidetrains_behind_player and hidetrains_behind_player:GetBool() and self.LastDrawCall and CurTime() - self.LastDrawCall > 1 then self.ShouldRenderClientEntsRes = false return end--при фризах ето условие будет срабатывать часто. Можно либо детектить фриз, либо увеличить интервал

	--если надо скрыть все составы
	if hidealltrains and hidealltrains:GetBool() then self.ShouldRenderClientEntsRes = false return end

	--если надо скрыть все чужие составы
	if hideothertrains and hideothertrains:GetBool() then
		local Owner = CPPI and self:CPPIGetOwner() or nil
		if Owner ~= LocalPlayer() then self.ShouldRenderClientEntsRes = false return end
	end
	
	--если надо скрыть за пропами
	if hidetrains_behind_props_bool then self.ShouldRenderClientEntsRes = ShouldRender return end
	
	self.ShouldRenderClientEntsRes = true
end

local function ChangeDrawFunctions(ent)
	local Draw = ent.Draw
	ent.Draw = function(self,...)
		self.LastDrawCall = CurTime()
		Draw(self,...)
	end
	ent.ShouldRenderClientEntsRes = false
	ent.ShouldRenderClientEnts = function(self)
		return self.ShouldRenderClientEntsRes
	end
end

local entsFindByClass = ents.FindByClass
timer.Create("Update ShouldRenderClientEntsRes variable",0.5,0,function()
	for _,ent in pairs(entsFindByClass("gmod_subway_*"))do
		if IsValid(ent) then ShouldRenderEnts(ent) end
	end
end)

Metrostroi = Metrostroi or {}
Metrostroi.ShouldHideTrain = ShouldRenderEnts

hook.Add("OnEntityCreated","UpdateTrainsDrawFunction",function(ent) timer.Simple(2,function()
	if not IsValid(ent) or ent.Base ~= "gmod_subway_base" or not table.HasValue(Metrostroi.TrainClasses, ent:GetClass()) or not ent.Draw or not ent.ShouldRenderClientEnts then return end
	print("changing drawing ClientEnts function on "..tostring(ent))
	ChangeDrawFunctions(ent)
end)end)

