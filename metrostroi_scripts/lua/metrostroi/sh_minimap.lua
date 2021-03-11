hook.Add("MetrostroiLoaded",function()
-- hook.Add("InitPostEntity","asd",function()
-- timer.Simple(0,function()
	if CLIENT then
	-- if false then
		Metrostroi.Minimap = Metrostroi.Minimap or {}
		local Minimap = Metrostroi.Minimap
		Minimap.SignsEnts = Minimap.SignsEnts or {}
		local SignsEnts = Minimap.SignsEnts
		for _,ent in pairs(SignsEnts)do
			SafeRemoveEntity(ent)
		end
		
		local color_green = Color(0,255,0)
		local color_white = Color(255,255,255)
		local color_black = Color(0,0,0)
		local color_red = Color(255,0,0)
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
		
		--TODO при загрузке сигналки отправляется инфа о каждом сигнале со всеми параметрами, также отправляются все таблички (сигны)
		
		--TODO постоянно обновляются: 
			--сигналы: какие линзы должны гореть (и мрашрутные указатели), закрыт ли сигнал вручную, занятость сигнала, какой сейчас выбран маршрут, состояние автостопа. 
			--составы: их местоположение, модельки кузовов
		local LinesRaw = {}
		local StationNamesRaw = {}
		local Lines = {}
		local StationNames = {}
		local SignsRaw = {}
		local Signs = {}
		
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
			
			
			Signs = {}
			for _,ent in pairs(SignsEnts)do
				SafeRemoveEntity(ent)
			end
			SignsEnts = {}
			local sigsEnt = scripted_ents.GetStored("gmod_track_signs").t
			for k,params in pairs(SignsRaw)do
				local model = sigsEnt.SignModels[params[1]-1]
				if not model then continue end
				--TODO у оффсета беру только z, потому что с y какая-то беда
				--TODO рейки вешаются под кривым углом
				local pos,ang = LocalToWorld(params[2],params[4], not params[5] and (params[3]+model.pos*Vector(0,0,1)) or (params[3]+model.pos*Vector(0,0,1)) * Vector(1,-1,1),params[5] and model.rotate and model.angles - Angle(0,180,0) or model.angles)
				local modelname
				if params[5] and not model.noleft then
					local r,rc = model.model:gsub("_r.mdl","_l.mdl")
					if rc > 0 then
						modelname = r
					else
						modelname = model.model:gsub("_l.mdl","_r.mdl")
					end
				else
					modelname = model.model
				end
				Signs[k] = {modelname,pos * Scale + Pos, ang}
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
				for _,ent in pairs(SignsEnts)do
					SafeRemoveEntity(ent)
				end
		end
		
		cvars.AddChangeCallback(ScaleCName, function(name,old,new)SetScale(new)end)
		cvars.AddChangeCallback(MaxAngCName, function(name,old,new)SetMaxAng(new)end)
		SetScale(ScaleC:GetFloat())
		SetMaxAng(MaxAngC:GetInt())
		
		hook.Add("BigNetTablesReceive","metrostori minimap info",function(tbl)
			if tbl.type ~= "Minimap Info" then return end
			local data = tbl.data
			LinesRaw = data.Lines

			StationNamesRaw = data.PlatformsNames
			
			SignsRaw = data.Signs
			
			CalcPositions()
		end)
		
		local OccupiedLines = {}
		timer.Create("MetrostroiMinimapThink",1,0,function()
			if not Pos then return end
			--TODO это должен отправлять сервер, так как клиент может прогрузить не все составы
			OccupiedLines = {}
			for _,wag in pairs(ents.FindByClass("gmod_subway_*"))do
				table.insert(OccupiedLines,{wag:LocalToWorld(VectorHalfThousand) * Scale + Pos, wag:LocalToWorld(Vector(-VectorHalfThousand,0,0)) * Scale +  Pos})
			end
			
			
			--так как при лаге сервера клиентсайд модели могут удалиться, делаю в таймере
			for k,params in pairs(Signs)do
				if not IsValid(SignsEnts[k]) then
					if SignsEnts[k] then SafeRemoveEntity(SignsEnts[k]) end
					local cent = ClientsideModel(params[1])
					cent:SetModelScale(Scale*4)
					SignsEnts[k] = cent
					cent:SetPos(params[2])
					cent:SetAngles(params[3])
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
		
		SendBigNetTable(Tbl,ply)
	end
	
	local oldload = Metrostroi.Load
	Metrostroi.Load = function()
		oldload()
		SavePlatformsTrackNodes()
		SendMinimapinfo()
	end
	
	local MinimapStatuses = {}
	hook.Add("PlayerInitialSpawn","Metrostroi Minimap",function(ply)
		SavePlatformsTrackNodes()
		SendMinimapinfo(ply)
		MinimapStatuses[ply] = nil
	end)
	
	concommand.Add("metrostroi_minimap_toggle", function(ply)
		ply:SendLua("Metrostroi.Minimap.Toggle()")
		MinimapStatuses[ply] = not MinimapStatuses[ply]
	end)
	
	-- SavePlatformsTrackNodes()
	-- SendMinimapinfo()
end)

