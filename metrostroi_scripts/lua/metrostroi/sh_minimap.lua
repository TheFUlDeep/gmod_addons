--выключено, потому что не доработано
do return end
--TODO проверить на нынещней версии метростроя, а не на dev ветке
-- hook.Add("MetrostroiLoaded",function()
local NWValuesSignalsServer = {}
hook.Add("InitPostEntity","asd",function()
-- timer.Simple(0,function()
	-- if false then
	if CLIENT then
		Metrostroi.Minimap = Metrostroi.Minimap or {}
		-- local Minimap = Metrostroi.Minimap
		
		local color_green = Color(0,255,0)
		local color_white = Color(255,255,255)
		local color_black = Color(0,0,0)
		local color_red = Color(255,0,0)
		local AngleZero = Angle(0,0,0)
		local VectorZero = Vector(0,0,0)
		local VectorHalfThousand = Vector(500,0,0)
		
		--max angle for tracks (оптимизадницы)
		local MaxAngCName = "metrostroi_minimap_maxang"
		local defaultMaxAng = 5
		local MaxAngC = GetConVar(MaxAngCName) or CreateClientConVar(MaxAngCName, defaultMaxAng, true)
		local MaxAng = defaultMaxAng
		
		--Scale
		local ScaleCName = "metrostroi_minimap_scale"
		local defaultScale = 0.01
		local ScaleC = GetConVar(ScaleCName) or CreateClientConVar(ScaleCName, defaultScale, true)
		local camScaleK = 20
		local Scale,CamScale	
		
		local Pos
		
		local LinesRaw = {}
		local StationNamesRaw = {}
		local Lines = {}
		local StationNames = {}
		local SignsRaw = {}
		local Signs = {}
		local SignalsRaw = {}
		local Signals = {}
		Signals.NWValues = {}
		local SignalsModelsMinimapPositions = {}
		local SignalsModelsScales = {}
		local empty_func = function()end
		
		local function LocalToWorldForSigns(self,pos)
			return LocalToWorld(self.params[2], self.params[4], pos, AngleZero)
		end
		
		local function LocalToWorldAnglesForSigns(self,ang)
			local pos,ang = LocalToWorld(self.params[2], self.params[4], VectorZero, ang)
			return ang
		end
		
		local function GetNWIntForSigns(self,str,def)
			return self.params[1] or def or 0
		end
		
		local function GetNWBoolForSigns(self,str,def)
			return self.params[5] or def or false
		end
		
		local function GetNWVectorForSigns(self,str,def)
			return self.params[3] or def or VectorZero
		end
		
		local function LocalToWorldForSignals(self,pos)
			return LocalToWorld(self.Position, self.Angles, pos, AngleZero)
		end
		
		local function LocalToWorldAnglesForSignals(self,ang)
			local pos,ang = LocalToWorld(self.Position, self.Angles, VectorZero, ang)
			return ang
		end

		local function GetAnglesSignals(self)
			return self.Angles
		end
		
		local function GetPosSignals(self)
			return self.Position
		end
		
		local function CalcPositions()
			if not Pos then return end
			Lines = {}
			for k,path in pairs(LinesRaw) do
				Lines[k] = {}
				for k1,lineParams in pairs(path)do
					Lines[k][k1] = {lineParams[1] * Scale + Pos, lineParams[2] * Scale + Pos, lineParams[3]}
				end
			end
			
			--оптимизация - уменьшение количества линий
			--возможность скипать линии и слепливать те, которые на маленьком углу друг от друга
			--делаю два прохода. Сначала соединяю, пропуская по одному ноуду, а на втором проходе соединяю все
			for i = 1,2 do
				local smth_removed = true
				while smth_removed do
					smth_removed = false
					for _,paths in pairs(Lines)do
						for idx, params in pairs(paths)do
							if i == 1 and idx % 2 == 0 then continue end
							if not paths[idx + 1] then continue end
							local ang1 = (params[1] - params[2]):Angle()
							local ang2 = (paths[idx+1][1] - paths[idx+1][2]):Angle()
							local maxang = MaxAng
							local maxang2 = 360-MaxAng
							if params[3] == paths[idx+1][3] and (math.abs(ang1[1] - ang2[1]) < maxang or math.abs(ang1[1] - ang2[1]) > maxang2) and (math.abs(ang1[2] - ang2[2]) < maxang or math.abs(ang1[2] - ang2[2]) > maxang2) and (math.abs(ang1[3] - ang2[3]) < maxang or math.abs(ang1[3] - ang2[3]) > maxang2) then
								params[2] = paths[idx+1][2]
								table.remove(paths,idx+1)
								smth_removed = true
							end
						end
					end
				end
			end
			
			StationNames = {}
			for index,params in pairs(StationNamesRaw)do
				StationNames[index] = {params[1] * Scale + Pos, params[2]}
			end
			
			for _,sig in pairs(Signs)do
				sig:OnRemove()
			end
			Signs = {}
			local sigsEnt = scripted_ents.GetStored("gmod_track_signs").t
			for k,params in pairs(SignsRaw)do
				Signs[k] = {}
				local SigTbl = Signs[k]
				SigTbl.params = params
				for k,v in pairs(sigsEnt)do
					SigTbl[k] = v
				end
				SigTbl.NextThink = empty_func
				SigTbl.SetNextClientThink = empty_func
				SigTbl.IsDormant = empty_func
				SigTbl.LocalToWorld = LocalToWorldForSigns
				SigTbl.LocalToWorldAngles = LocalToWorldAnglesForSigns
				SigTbl.GetNWInt = GetNWIntForSigns
				SigTbl.GetNWBool = GetNWBoolForSigns
				SigTbl.GetNWVector = GetNWVectorForSigns
			end
			
			
			SignalsModelsMinimapPositions = {}
			SignalsModelsScales = {}
			local sigEnt = scripted_ents.GetStored("gmod_track_signal").t

			for _,sig in pairs(Signals)do
				if sig.OnRemove then sig:OnRemove() end
			end
			Signals = {}
			Signals.NWValues = {}
			for idx,sig in pairs(SignalsRaw)do
				Signals[idx] = {}
				local SigTbl = Signals[idx]
				--копирую метатаблицу
				for k1,v in pairs(sigEnt)do
					SigTbl[k1] = v
				end
				
				--копирую данные
				local SigTbl = Signals[idx]
				for k1,v in pairs(sig)do
					SigTbl[k1] = v
				end
				
				local Entity = FindMetaTable("Entity")
				local funcs = {}
				for k,v in pairs(Entity)do
					if isstring(k) and k:find("GetNW2",1,true) then
						funcs[k] = v
						SigTbl[k] = function(self,str,def,...)
							-- local selfidx = self:EntIndex()
								local type = k:sub(7)
							return Signals.NWValues[type] and Signals.NWValues[type][idx] and Signals.NWValues[type][idx][str] or type == "String" and ""
						end
					end
				end
				
				SigTbl.IsDormant = empty_func
				SigTbl.LocalToWorld = LocalToWorldForSignals
				SigTbl.LocalToWorldAngles = LocalToWorldAnglesForSignals
				SigTbl.GetPos = GetPosSignals
				SigTbl.GetAngles = GetAnglesSignals
				SigTbl:Initialize()
			end
		end
		
		local function SetScale(val)
			local num = tonumber(val)
			if not num then
				print("Can't convert argument to number, setting default Scale")
				Scale = defaultScale
			else
				print("setted new Scale")
				Scale = num
			end
			CamScale = Scale*camScaleK
			CalcPositions()
		end
		
		local function SetMaxAng(val)
			local num = tonumber(val)
			if not num then
				print("Can't convert argument to number, setting default maxang")
				MaxAng = defaultMaxAng
			else
				print("setted new maxang")
				MaxAng = num
			end
			CalcPositions()
		end
		
		function Metrostroi.Minimap.Toggle()
			if not Pos then 
				Pos = LocalPlayer():GetPos()
				CalcPositions() 
			else 
				Pos = nil end
				for _,ent in pairs(Signs)do
					ent:OnRemove()
				end
				for _,sig in pairs(Signals)do
					if sig.OnRemove then sig:OnRemove() end
				end
		end
		
		cvars.AddChangeCallback(ScaleCName, function(name,old,new)SetScale(new)end)
		cvars.AddChangeCallback(MaxAngCName, function(name,old,new)SetMaxAng(new)end)
		SetScale(ScaleC:GetFloat())
		SetMaxAng(MaxAngC:GetInt())
		
		
		local OccupiedLines = {}
		hook.Add("BigNetTablesReceive","metrostori minimap info",function(tbl)
			if tbl.type == "Minimap Info Update" then
				local data = tbl.data
				for _,wag in pairs(data.wagons)do
					local pos = LocalToWorld(wag[1],wag[2],VectorHalfThousand,AngleZero)
					local pos2 = LocalToWorld(wag[1],wag[2],-VectorHalfThousand,AngleZero)
					table.insert(OccupiedLines,{wpos, pos2})
				end
				
				Signals.NWValues = data.NWValuesSignals
				
			elseif tbl.type == "Minimap Info" then
				local data = tbl.data
				LinesRaw = data.Lines

				StationNamesRaw = data.PlatformsNames
				
				SignsRaw = data.Signs
				
				SignalsRaw = data.Signals
				
				CalcPositions()
			end
		end)
		
		timer.Create("MetrostroiMinimapThink",1,0,function()
			if not Pos then return end

			OccupiedLines = {}
			for _,wag in pairs(ents.FindByClass("gmod_subway_*"))do
				table.insert(OccupiedLines,{wag:LocalToWorld(VectorHalfThousand) * Scale + Pos, wag:LocalToWorld(Vector(-VectorHalfThousand,0,0)) * Scale +  Pos})
			end
			
			--think табличек
			for _,sig in pairs(Signs)do
				sig:Think()
				if IsValid(sig.Model) then
					local ent = sig.Model
					if not sig.MinimapPos then
						sig.MinimapPos = ent:GetPos() * (Scale) + Pos
						sig.ModelScale = ent:GetModelScale()
					end
					ent:SetPos(sig.MinimapPos)
					ent:SetModelScale(sig.ModelScale*Scale)
				end
			end
			
			--think сигналов
			--TODO
			for _,sig in pairs(Signals)do
				if sig.Think then sig:Think()end
				for k,v in pairs(sig.Models or {})do
					if not istable(v) then continue end
					for k1,cent in pairs(v)do
						if IsValid(cent) then
							if not SignalsModelsMinimapPositions[cent] then
								SignalsModelsMinimapPositions[cent] = cent:GetPos() * Scale + Pos
								SignalsModelsScales[cent] = cent:GetModelScale()
							end
							cent:SetPos(SignalsModelsMinimapPositions[cent])
							cent:SetModelScale(SignalsModelsScales[cent] * Scale)
						end
					end
				end
			end
		end)
		
		hook.Add("PreDrawEffects","Metrostroi Minimap drawing",function()
			if not Pos then return end
			--отрисовка треков
			for _,path in pairs(Lines) do
				for _,lineParams in pairs(path)do
					render.DrawLine(lineParams[1], lineParams[2],lineParams[3] and color_green)
				end
			end
			
			--отрисовка имен станций
			for i,stationNamesParams in pairs(StationNames)do
				cam.Start3D2D(stationNamesParams[1], stationNamesParams[2], CamScale)
					draw.SimpleTextOutlined(i, "DermaDefault", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
				cam.End3D2D()
				cam.Start3D2D(stationNamesParams[1], stationNamesParams[2]+Angle(0,180,0), CamScale)
					draw.SimpleTextOutlined(i, "DermaDefault", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
				cam.End3D2D()
			end
			
			--отрисовка составов ввиде красных полосочек
			for _, params in pairs(OccupiedLines)do
				render.DrawLine(params[1], params[2],color_red)
			end
		end)
	end
	if CLIENT then return end
	
	local PlatformsTrackNodes = {}
	local function SavePlatformsTrackNodes()
		PlatformsTrackNodes = {}
		for _,platform in pairs(ents.FindByClass("gmod_track_platform"))do
			if IsValid(platform) and platform.PlatformStart and platform.PlatformEnd then
				local startpos = Metrostroi.GetPositionOnTrack(platform.PlatformStart,nil,{radius = 256})[1]
				local endpos = Metrostroi.GetPositionOnTrack(platform.PlatformEnd,nil,{radius = 256})[1]
				if not startpos or not endpos or startpos.path.id ~= endpos.path.id then continue end--TODO потом сделать, чтобы выделялось даже если платформа на разных треках
				PlatformsTrackNodes[platform] = {startpos.path.id,{}}
				if startpos.node1.id > endpos.node1.id then startpos,endpos = endpos,startpos end
				for i = startpos.node1.id,endpos.node1.id - 1 do-- - 1 потому что я сохраняю линии, и у меня там берется некст ноуд
					PlatformsTrackNodes[platform][2][i] = true
				end
				
			end
		end
	end

	local function SendMinimapinfo(ply)
		SavePlatformsTrackNodes()
		local Tbl = {}
		Tbl.type = "Minimap Info"
		Tbl.data = {}
		local data = Tbl.data
		
		--сохраняю линии которые надо будет рисовать
		data.Lines = {}
		local Lines = data.Lines
		for pathid,path in pairs(Metrostroi.Paths)do
			Lines[pathid] = Lines[pathid] or {}
			if #path < 2 then continue end
			for i = 1, #path-1 do
				Lines[pathid][i] = {path[i].pos,path[i+1].pos}
			end
		end
		
		--обновляю линии и сохраняю станции, которые надо будет рисовать
		data.PlatformsNames = {}
		local PlatformsNames = data.PlatformsNames
		local wasIndexes = {}
		for _,platform in pairs(ents.FindByClass("gmod_track_platform"))do
			if not IsValid(platform) then continue end
			if platform.StationIndex and platform.PlatformStart and platform.PlatformEnd and not wasIndexes[platform.StationIndex] then
				wasIndexes[platform.StationIndex] = true
				PlatformsNames[platform.StationIndex] = {platform:GetPos(), (platform.PlatformStart - platform.PlatformEnd):Angle() + Angle(0,0,90)} 
			end
			
			if PlatformsTrackNodes[platform] then
				local pathid = PlatformsTrackNodes[platform][1]
				if not Lines[pathid] then continue end
				local nodeids = PlatformsTrackNodes[platform][2]
				for nodeid in pairs(nodeids)do
					Lines[pathid][nodeid][3] = true
				end
			end
		end
		
		--сохраняю все таблички
		data.Signs = {}
		local Signs = data.Signs
		for _,sign in pairs(ents.FindByClass("gmod_track_signs"))do
			if not IsValid(sign) then continue end
			table.insert(Signs,{sign.SignType or 1,sign:GetPos(),Vector(0,sign.YOffset,sign.ZOffset),sign:GetAngles(),sign.Left})
			-- table.insert(Signs,{sign.SignType or 1,sign:GetPos()+Vector(0,0,0),sign:GetAngles(),sign.Left})
		end
		
		--сохраняю сигналы
		data.Signals = {}
		local Signals = data.Signals
		for _,signal in pairs(ents.FindByClass("gmod_track_signal"))do
			if not IsValid(signal) then continue end
			local idx = signal:EntIndex()
			Signals[idx] = {}
			local SigTbl = Signals[idx]
			SigTbl.LightType = signal.SignalType or 0
			SigTbl.Name = signal.Name or "NOT LOADED"
			SigTbl.Lenses = signal.ARSOnly and "ARSOnly" or signal.LensesStr
			SigTbl.RouteNumber =   signal.RouteNumber
			SigTbl.RouteNumberSetup =  signal.SignalType == 0 and signal.RouteNumberSetup or ""
			SigTbl.IsolateSwitches = signal.IsolateSwitches
			SigTbl.Approve0 = signal.Approve0
			SigTbl.TwoToSix = signal.TwoToSix
			SigTbl.ARSOnly = SigTbl.Lenses == "ARSOnly"
			SigTbl.NonAutoStop = not signal.NonAutoStop
			SigTbl.PassOcc = signal.PassOcc
			SigTbl.Routes = signal.Routes
			SigTbl.Left = signal.Left
			SigTbl.Double = signal.Double
			SigTbl.DoubleL = signal.DoubleL
			if not SigTbl.ARSOnly then
				SigTbl.LensesTBL = string.Explode("-",SigTbl.Lenses)
			end
			SigTbl.Position = signal:GetPos()
			SigTbl.Angles = signal:GetAngles()
		end
		
		SendBigNetTable(Tbl,ply)
	end
	
	local oldload = Metrostroi.Load
	Metrostroi.Load = function()
		oldload()
		SendMinimapinfo()
	end
	
	local MinimapStatuses = {}
	hook.Add("PlayerInitialSpawn","Metrostroi Minimap",function(ply)
		SendMinimapinfo(ply)
		MinimapStatuses[ply] = nil
	end)
	
	timer.Create("Minimap Info Update",1,0,function()
		local Tbl = {}
		Tbl.Type = "Minimap Info Update"
		Tbl.data = {}
		local data = Tbl.data
		data.wagons = {}
		local wagons = data.wagons
		for _,ent in pairs(ents.FindByClass("gmod_subway_*"))do
			if not IsValid(ent) then continue end
			wagons[ent:EntIndex()] = {ent:GetPos(), ent:GetAngles()}
		end
		
		data.NWValuesSignals = NWValuesSignalsServer
		
		--TODO отправлять только тем, у кого включена карта
		SendBigNetTable(Tbl)
	end)
	
	concommand.Add("metrostroi_minimap_toggle", function(ply)
		ply:SendLua("Metrostroi.Minimap.Toggle()")
		MinimapStatuses[ply] = not MinimapStatuses[ply]
	end)
	
	SendMinimapinfo()
end)

hook.Add("InitPostEntity","Upgrade functions for Metrostroi Minimap",function()
	if SERVER then
		local Entity = FindMetaTable("Entity")
		local funcs = {}
		for k,v in pairs(Entity)do
			if isstring(k) and k:find("SetNW2",1,true) then
				print(k)
				funcs[k] = v
				NWValuesSignalsServer[k:sub(7)] = {}
			end
		end
	
		local sigEnt = scripted_ents.GetStored("gmod_track_signal").t
		for k,v in pairs(funcs)do
			sigEnt[k] = function(self,str,val,...)
				v(self,str,val,...)
				local type = k:sub(7)
				local idx = self:EntIndex()
				NWValuesSignalsServer[type][idx] = NWValuesSignalsServer[k:sub(7)][idx] or {}
				NWValuesSignalsServer[type][idx][str] = val
			end
		end
	end
	
	if SERVER then return end
	local Entity = FindMetaTable("Entity")
	local oldSetParent = Entity.SetParent
	Entity.SetParent = function(self,ent,...)
		if not IsValid(ent) then return end
		return oldSetParent(self,ent,...)
	end
end)

