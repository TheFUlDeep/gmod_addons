TOOL.Category		= "Metro"
TOOL.Name			= "Mirror Tool"
TOOL.Command		= nil
TOOL.ConfigName		= nil

function TOOL:LeftClick( trace )
	if SERVER then return end
	if self.LastUse and os.time() - self.LastUse < 5 then return end
	self.LastUse = os.time()
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end
	
	local MirrorDistance = GetConVar("mirror_distance"):GetFloat()
	local MirrorAngleP = GetConVar("mirror_angle_p"):GetFloat()
	local MirrorAngleY = GetConVar("mirror_angle_y"):GetFloat()
	local MirrorAngleR = GetConVar("mirror_angle_r"):GetFloat()
	local MirrorScale = GetConVar("mirror_scale"):GetFloat()
	
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
	net.SendToServer()

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