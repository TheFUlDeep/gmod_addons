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

local tracelinesetup = {mask = MASK_ALL,output = {},filter = function(ent)
	if ent == LocalPlayer() then return false end
	
	--если игрок в составе, то его первый вагон пропускается, чтобы тут же за окном не было некрасиво
	local PlyInSeatTrain = PlyInSeat and PlyInSeat:GetNW2Entity("TrainEntity",nil)
	if not IsValid(PlyInSeatTrain) then PlyInSeatTrain = nil end
	
	local entTrain = ent:GetNW2Entity("TrainEntity",nil)
	if not IsValid(entTrain) then entTrain = nil end
	
	if PlyInSeat and (PlyInSeat == ent or PlyInSeatTrain and (PlyInSeatTrain == ent or entTrain and entTrain == PlyInSeatTrain)) then
		return false 
	end
	
	return true
end}

hook.Add("CalcView", "Get_Metrostroi_TrainView", function(ply,pos,ang,fov,znear,zfar)
	Lastply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar = ply,pos,ang,fov,znear,zfar
end)

local ViewPos,ViewAng,ViewFunction
timer.Create("FindMetrostroiCameras",1,0,function()
	local HooksTbl = hook.GetTable()
	if not HooksTbl.CalcView or not HooksTbl.CalcView.Metrostroi_TrainView then return end
	print("Found metrostroi view changer hook")
	timer.Remove("FindMetrostroiCameras")
	ViewFunction = HooksTbl.CalcView.Metrostroi_TrainView
end)

local PlyInTrain
local PlyInSeat

timer.Create("PlyInTrainForHideCheck",1,0,function()
	local ply = LocalPlayer()
	if not ply.InVehicle then return end
	if ply:InVehicle() then
		PlyInSeat = ply:GetVehicle()
		if not IsValid(PlyInSeat) then PlyInSeat = nil end
		PlyInTrain = PlyInSeat and PlyInSeat:GetNW2Entity("TrainEntity",nil) or nil
		if PlyInTrain and not IsValid(PlyInTrain) then PlyInTrain = nil end
	else
		PlyInTrain = nil
	end
end)

local ENTS = Metrostroi.TrainClasses or {}
table.insert(ENTS,1,"gmod_metrostroi_mirror")

hook.Add("MetrostroiLoaded","CreateCustomEntsTbl for hidetrains",function()
	ENTS = Metrostroi.TrainClasses
	table.insert(ENTS,1,"gmod_metrostroi_mirror")
end)

local C_ScreenshotMode,C_CabFOV,C_FovDesired,C_MinimizedShow,hidealltrains,hideothertrains,hidetrains_behind_props,hidetrains_behind_player
timer.Simple(0,function() 
	C_ScreenshotMode      = GetConVar("metrostroi_screenshotmode")		-- прогружаю конвары здесь, чтобы случайно не прогрузить Nil
	C_CabFOV              = GetConVar("metrostroi_cabfov")
	C_FovDesired          = GetConVar("fov_desired")
	C_MinimizedShow       = GetConVar("metrostroi_minimizedshow")
	hidealltrains = GetConVar("hidealltrains")
	hideothertrains = GetConVar("hideothertrains")
	hidetrains_behind_props = GetConVar("hidetrains_behind_props")
	hidetrains_behind_player = GetConVar("hidetrains_behind_player")
end)

--TODO если игрок в составе, то не прогружается соседний состав
--TODO в идеале смотреть не по двум диагоналям, а по двум диагоналям каждой плоскости и по всем граням
timer.Create("HideTrainClientEnts",10,0,function()		-- каждые 10 секунд я сканирую ентити, и если вижу ентити, в котором функция не изменена - изменяю ее
	if not C_ScreenshotMode or not hidealltrains then timer.Remove("HideTrainClientEnts") print("HIDETRAINS ERROR") return end
	local ply = LocalPlayer()
	if not Metrostroi then return end
	for _k,class in pairs(ENTS) do
		for k,ent in pairs(ents.FindByClass(class)) do
			if not IsValid(ent) or ent.CustomRenderClientEntsLoaded or not ent.ShouldRenderClientEnts then continue end
			ent.CustomRenderClientEntsLoaded = true
			ent.LastDrawCheckClientEnts = os.time()
			print("changing draw function on "..tostring(ent))
			ent.ShouldRenderClientEnts = function(ent)
				local asd = !Metrostroi or !Metrostroi.ReloadClientside
				if not asd then return false elseif os.time() - ent.LastDrawCheckClientEnts > 0 then ent.LastDrawCheckClientEnts = os.time() else return ent.DrawResult or false end
				if PlyInTrain == ent then ent.DrawResult = true return ent.DrawResult end
				
				if ViewFunction then
					local ViewTbl = ViewFunction(ply,ply:EyePos(),ply:GetAngles(),Lastfov,Lastznear,Lastzfar)
					if ViewTbl then
						ViewPos,ViewAng = ViewTbl.origin,ViewTbl.angles
					else
						ViewPos,ViewAng = nil,nil
					end
				end
				
				if not C_ScreenshotMode:GetBool() then
					if hidealltrains:GetBool() then
						if not PlyInTrain or PlyInTrain ~= ent then ent.DrawResult = false return ent.DrawResult end
					else
						if hideothertrains:GetBool() then
							local Owner = CPPI and ent:CPPIGetOwner() or nil
							if not (IsValid(Owner) and Owner == ply or PlyInTrain and PlyInTrain == ent) then ent.DrawResult = false return ent.DrawResult end
						end
					end
				end
				
				--metrostroi default
				ent.DrawResult = !ent:IsDormant() and math.abs(ply:EyePos().z-ent:GetPos().z)<500 and (system.HasFocus() or C_MinimizedShow:GetBool()) and LocalPlayer():EyePos():DistToSqr(ent:GetPos())
				
				if ent.DrawResult and (hidetrains_behind_props:GetBool() or hidetrains_behind_player:GetBool()) and not C_ScreenshotMode:GetBool() then
					tracelinesetup.start = ViewPos or ply:EyePos()
					
					local TrainSize,Result = ent:OBBMins() / 1
					local CanSee
					local step = 0.1
					for j = 1,2 do
						local startvec = j == 1 and TrainSize or TrainSize * Vector(1,-1,-1)
						local endvec = startvec * Vector(-1,-1,-1)
						startvec = ent:LocalToWorld(startvec)
						endvec = ent:LocalToWorld(endvec)
						for i = 0,1,step do
							local curvec = LerpVector(i, startvec, endvec)
							tracelinesetup.endpos = curvec
							output = util.TraceLine(tracelinesetup)
							
							if output.Fraction == 1 or output.Entity == ent or IsValid(output.Entity:GetNW2Entity("TrainEntity",nil)) and output.Entity:GetNW2Entity("TrainEntity",nil) == ent then Result = true end
							
							FoV = ViewAng and 0.7 * C_CabFOV:GetFloat() or 0.7 * C_FovDesired:GetFloat() -- TODO возможно для вертикали нужно уменьшить коэффициент
							tracelinesetup.endpos = ent:GetPos()
							local ang = output.Normal:Angle()
							local PlyAngle = ViewAng or ply:GetEyeTrace().Normal:Angle()
							ang:Normalize()
							PlyAngle:Normalize()
							local ResultAngle = (ang - PlyAngle)
							ResultAngle:Normalize()
							if not CanSee and ResultAngle.y < FoV and ResultAngle.y > -FoV and ResultAngle.p < FoV and ResultAngle.p > -FoV then
								CanSee = true
							end
						end
					end
					if hidetrains_behind_props:GetBool() then
						ent.DrawResult = Result or false
					end
					
					if hidetrains_behind_player:GetBool() then
						if not CanSee then ent.DrawResult = false end
					end
				end

				return ent.DrawResult
			end
		end
	end
end)