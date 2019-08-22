TOOL.Category		= "Metro"
TOOL.Name			= "Mirror Tool"
TOOL.Command		= nil
TOOL.ConfigName		= nil

function TOOL:LeftClick( trace )
	if CLIENT then return end
	local ply = self:GetOwner()
	if not ply:IsSuperAdmin() then return end
	local pos = ply:EyePos()
	local ang = ply:GetEyeTrace().Normal:Angle()
	local mirror = THEFULDEEP.SpawnMirror(ply:EyePos(),Angle(0,ang.y+90,ang.r))
	
	undo.Create("Mirror")
		undo.AddEntity( mirror )
		undo.SetPlayer( ply )
	undo.Finish()
end
