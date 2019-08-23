TOOL.Category		= "Metro"
TOOL.Name			= "Mirror Tool"
TOOL.Command		= nil
TOOL.ConfigName		= nil

function TOOL:LeftClick( trace )
	if CLIENT then return end
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end
	
	local MirrorDistance = ply:GetNW2Int("mirror_distance",0)
	local MirrorAngleP = ply:GetNW2Int("mirror_angle_p",0)
	local MirrorAngleY = ply:GetNW2Int("mirror_angle_y",0)
	local MirrorAngleR = ply:GetNW2Int("mirror_angle_r",0)
	local MirrorScale = ply:GetNW2Int("mirror_scale",1)
	
	local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
	local mirror = THEFULDEEP.SpawnMirror(
		ply:LocalToWorld(Vector(MirrorDistance,0,0))+Vector(0,0,60),
		Angle(plyang.r+MirrorAngleP,plyang.y+90+MirrorAngleY,plyang.p+MirrorAngleR),
		MirrorScale
	)
	
	undo.Create("Mirror")
		undo.AddEntity( mirror )
		undo.SetPlayer( ply )
	undo.Finish()
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
		Label = "Превью", 
		Command = "mirror_preview"
	} )
	
	panel:AddControl( "slider", { 
		Label = "Дальность",
		Command = "mirror_distance",
		type = "float",
		min = 0,
		max = 1000
	} )
	
	panel:AddControl( "slider", { 
		Label = "Angle P",
		Command = "mirror_angle_p",
		type = "float",
		min = 0,
		max = 180
	} )
	
	panel:AddControl( "slider", { 
		Label = "Angle Y",
		Command = "mirror_angle_y",
		type = "float",
		min = -90,
		max = 90
	} )
	
	panel:AddControl( "slider", { 
		Label = "Angle R",
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
	
	panel:AddControl( "label", { --TODO
		text = "Все, что ниже - пока не исопльзуется",
	} )
	
	panel:AddControl( "textbox", { --TODO
		Label = "Модель",
		Command = "mirror_model",
	} )
end