TOOL.Category		= "Metro"
TOOL.Name			= "Mirror Tool"
TOOL.Command		= nil
TOOL.ConfigName		= nil

function TOOL:LeftClick( trace )
	if game.SinglePlayer() then
		--будет вызываться только на сервере (в одиночке)
		local ply = self:GetOwner()
		if not ply:IsSuperAdmin() then return end
		
		local MirrorDistance = GetConVar("mirror_distance"):GetFloat()
		local MirrorAngleP = GetConVar("mirror_angle_p"):GetFloat()
		local MirrorAngleY = GetConVar("mirror_angle_y"):GetFloat()
		local MirrorAngleR = GetConVar("mirror_angle_r"):GetFloat()
		local MirrorScale = GetConVar("mirror_scale"):GetFloat()
		local MirrorModel = GetConVar("mirror_model_type"):GetInt()
		local StickDown = GetConVar("mirror_stick_down"):GetBool()
		
		local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
		local pos = ply:LocalToWorld(Vector(MirrorDistance,0,0))+Vector(0,0,60)
		local ang = Angle(plyang.r+MirrorAngleP,plyang.y+90+MirrorAngleY,plyang.p+MirrorAngleR)
		
		local Mirror = THEFULDEEP.SpawnMirror(pos,ang,MirrorScale,MirrorModel,StickDown)
		
		undo.Create("Mirror")
			undo.AddEntity( Mirror )
			undo.SetPlayer( ply )
		undo.Finish()
		
		return true
	end
	if SERVER then return end
	if self.LastUse and os.time() - self.LastUse < 1 then return end
	self.LastUse = os.time()
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end
	
	local MirrorDistance = GetConVar("mirror_distance"):GetFloat()
	local MirrorAngleP = GetConVar("mirror_angle_p"):GetFloat()
	local MirrorAngleY = GetConVar("mirror_angle_y"):GetFloat()
	local MirrorAngleR = GetConVar("mirror_angle_r"):GetFloat()
	local MirrorScale = GetConVar("mirror_scale"):GetFloat()
	local MirrorModel = GetConVar("mirror_model_type"):GetInt()
	local StickDown = GetConVar("mirror_stick_down"):GetBool()
	
	local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
	
	net.Start("SpawnMirror")
		local pos = ply:LocalToWorld(Vector(MirrorDistance,0,0))+Vector(0,0,60)
		net.WriteFloat(pos.x)
		net.WriteFloat(pos.y)
		net.WriteFloat(pos.z)
		net.WriteFloat(plyang.r+MirrorAngleP)
		net.WriteFloat(plyang.y+90+MirrorAngleY)
		net.WriteFloat(plyang.p+MirrorAngleR)
		net.WriteFloat(MirrorScale)
		net.WriteFloat(MirrorModel)
		net.WriteBool(StickDown)
	net.SendToServer()
	
	return true

end

function TOOL:RightClick( trace )
	if CLIENT then return end
	if not self:GetOwner():IsSuperAdmin() then return end
	
	local Ents = ents.FindInSphere(trace.HitPos, 300 ) or {}
	
	local mirrors = {}
	
	for _,ent in pairs(Ents) do
		if ent:GetClass() == "gmod_metrostroi_mirror" then table.insert(mirrors,1,ent) end
	end
	
	local CurDist,MinDist,NearestMirror
	for _,mirror in pairs(mirrors) do
		CurDist = trace.HitPos:DistToSqr(mirror:GetPos())
		if not MinDist or MinDist > CurDist then MinDist = CurDist NearestMirror = mirror end
	end
	
	if NearestMirror then NearestMirror:Remove() return true end
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "header", { 
		description = 'Перед нажатием на "Превью" заставни и удали зеркало в любом место (ЛКМ + Z), потом жми на галку'
	} )

	panel:AddControl( "button", { 
		Label = "Сохранить зеркала", 
		Command = "mirrors_save"
	} )
	
	panel:AddControl( "button", { 
		Label = "Загрузить зеркала", 
		Command = "mirrors_load"
	} )
	
	panel:AddControl( "Checkbox", { 
		Label = "Отображение зеркал", 
		Command = "metrostroi_drawcams"
	} )
	
	panel:AddControl( "Checkbox", { 
		Label = "Превью", 
		Command = "mirror_preview"
	} )
	
	panel:AddControl( "numpad", {
		command = "mirror_preview_hotkey",
		label = "Хоткей переключения превью",
	} )
	
	panel:AddControl( "slider", { 
		Label = "Дальность",
		Command = "mirror_distance",
		type = "float",
		min = 0,
		max = 1000
	} )
	
	panel:AddControl( "slider", { 
		Label = "Угол P",
		Command = "mirror_angle_p",
		type = "float",
		min = 0,
		max = 180
	} )
	
	panel:AddControl( "slider", { 
		Label = "Угол Y",
		Command = "mirror_angle_y",
		type = "float",
		min = -90,
		max = 90
	} )
	
	panel:AddControl( "slider", { 
		Label = "Угол R",
		Command = "mirror_angle_r",
		type = "float",
		min = -90,
		max = 90
	} )
	
	panel:AddControl( "slider", { 
		Label = "Размер",
		Command = "mirror_scale",
		type = "float",
		min = 0.01,
		max = 100
	} )
	
	panel:AddControl( "slider", { 
		label = "Тип модели",
		command = "mirror_model_type",
		min = 1,
		max = 2
	})
	
	panel:AddControl( "Checkbox", { 
		label = "Палка сверху/снизу",
		command = "mirror_stick_down",
	})
end