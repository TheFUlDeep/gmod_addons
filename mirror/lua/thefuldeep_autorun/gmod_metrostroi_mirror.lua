--TODO фикс конфликта с камерами метростроя
local models = {
	"models/thefuldeeps_models/mirror_square.mdl",
	"models/thefuldeeps_models/mirror_rectangle.mdl"
}
local function GetModelByType(int)
	return models[int]
end

local function GetTypeByModel(model)
	return table.KeyFromValue(models, model)
end


if SERVER then
	util.AddNetworkString("SpawnMirror")
	

	local function SpawnMirror(pos,ang,scale,model,stickdown)
		local mirror = ents.Create("gmod_metrostroi_mirror")
		if not IsValid(mirror) then print("ERROR with createin mirror") return end
		mirror.Model = GetModelByType(model) or GetModelByType(1)
		mirror:SetModelScale(scale or 1)
		mirror:SetNW2Bool("StickDown",stickdown)
		--timer.Simple(0.3,function()
			mirror:SetPos(pos)
			mirror:SetAngles(ang)
			mirror:Spawn()
		--end)
		print("Mirror spawned")
		return mirror
	end
	
	net.Receive("SpawnMirror", function(len,ply)
		if not ply:IsSuperAdmin() then return end
		local a,b,c,d,e,f,g,h,i = net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadBool()
		local Mirror = SpawnMirror(Vector(a,b,c),Angle(d,e,f),g,h,i)
		
		undo.Create("Mirror")
			undo.AddEntity( Mirror )
			undo.SetPlayer( ply )
		undo.Finish()
	end)
	
	if not THEFULDEEP then THEFULDEEP = {} end
	THEFULDEEP.SpawnMirror = SpawnMirror
	
	--[[hook.Add("Think","DisableMirrors",function()
		local RTCam = GetGlobalEntity("MirrorRTCam")
		if IsValid(RTCam) then
			RTCam:SetKeyValue( "GlobalOverride", RTCam:GetNW2Bool("GlobalOverride",false) and 1 or 0 )
		end
	end)
	hook.Remove("Think","DisableMirrors")]]
	
	concommand.Add("mirrors_save", function(ply)
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end
		local File = file.Read("mirrors.txt")
		local Mirrors = File and util.JSONToTable(File) or {}
		local Map = game.GetMap()
		Mirrors[Map] = {}
		for _,ent in pairs(ents.FindByClass("gmod_metrostroi_mirror")) do
			if IsValid(ent) then table.insert(Mirrors[Map],1,{ent:GetPos(),ent:GetAngles(),ent:GetModelScale(),GetTypeByModel(ent:GetModel()),ent:GetNW2Bool("StickDown")}) end
		end
		--if #Mirrors[Map] < 1 then print("no mirrors") ply:ChatPrint("no mirrors") return end
		file.Write("mirrors.txt", util.TableToJSON(Mirrors,true))
		print("mirrors saved")
		if IsValid(ply) then ply:ChatPrint("saved "..#Mirrors[Map].." mirrors") end
	end)
	
	concommand.Add("mirrors_load", function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		local File = file.Read("mirrors.txt")
		local Mirrors = File and util.JSONToTable(File) or {}
		local Map = game.GetMap()
		Mirrors = Mirrors[Map]
		
		for k,v in pairs(ents.FindByClass("gmod_metrostroi_mirror")) do
			print("removed mirror")
			v:Remove()
		end
		timer.Simple(1,function()
		if not Mirrors or #Mirrors < 1 then 
			File = file.Read("mirrors_data/mirrors_"..Map..".lua","LUA")
			Mirrors = File and util.JSONToTable(File) or {}
			
			if not Mirrors or #Mirrors < 1 then
				print("no mirrors for this map") 
				if IsValid(ply) then ply:ChatPrint("no mirrors for this map") end
				return 
			else
				for _,mirror in ipairs(Mirrors) do
					SpawnMirror(mirror[1],mirror[2],mirror[3],mirror[4],mirror[5])
				end
			end
		else
			for _,mirror in ipairs(Mirrors) do
				SpawnMirror(mirror[1],mirror[2],mirror[3],mirror[4],mirror[5])
			end
		end
		print("loaded "..#Mirrors.." mirrors")
		if IsValid(ply) then ply:ChatPrint("loaded "..#Mirrors.." mirrors") end
		end)
	end)
	
	hook.Add("PlayerInitialSpawn","SpawnMirrors",function() 
		hook.Remove("PlayerInitialSpawn","SpawnMirrors")
		RunConsoleCommand("mirrors_load")
	end)
	
	if game.SinglePlayer() then	
		hook.Add("PlayerButtonDown","Mirror_preview_toggle",function(ply, button )
			local MirrorPreviewHotkey1 = GetConVar("mirror_preview_hotkey"):GetInt()
			if MirrorPreviewHotkey1 and MirrorPreviewHotkey1 ~= 0 and button == MirrorPreviewHotkey1 then 
				RunConsoleCommand("mirror_preview",GetConVar("mirror_preview"):GetBool() and 0 or 1)
			end
		end)
	end
	
end
if SERVER then return end

local Lastply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar
hook.Add("CalcView", "Get_Metrostroi_TrainView1", function(ply,pos,ang,fov,znear,zfar)
	Lastply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar = ply,pos,ang,fov,znear,zfar
end)
local ViewPos,ViewAng,ViewFunction
timer.Create("FindMetrostroiCameras1",1,0,function()
	local HooksTbl = hook.GetTable()
	if not HooksTbl.CalcView or not HooksTbl.CalcView.Metrostroi_TrainView then return end
	print("Found metrostroi view changer hook")
	timer.Remove("FindMetrostroiCameras1")
	ViewFunction = HooksTbl.CalcView.Metrostroi_TrainView
end)

local MetrostroiDrawCams--,C_CabFOV,C_FovDesired
timer.Simple(0,function()
	MetrostroiDrawCams = GetConVar("metrostroi_drawcams")
	--C_CabFOV              = GetConVar("metrostroi_cabfov")
	--C_FovDesired          = GetConVar("fov_desired")
end)
if not THEFULDEEP then THEFULDEEP = {} end
THEFULDEEP.MirrorDraw = function(self)
	if MetrostroiDrawCams and not MetrostroiDrawCams:GetBool() then return end
	--if not self:ShouldRenderClientEnts() then return end
	if not IsValid(self.RTCam) then self.RTCam = GetGlobalEntity("MirrorRTCam") return end

	self:DrawModel()
	--[[if #Metrostroi.CamQueue > 0 then
		if self.RTCam.GlobalOverride1 then
			self.RTCam:SetNW2Bool("GlobalOverride",false)
			self.RTCam.GlobalOverride1 = false
		end
		print("a")
		return 
	end
	print("b")
	
	if not self.RTCam.GlobalOverride1 then
		self.RTCam:SetNW2Bool("GlobalOverride",true)
		self.RTCam.GlobalOverride1 = true
	end]]
	
	local MirrorPos = self:LocalToWorld(self:OBBCenter())
	if self.RTCam:GetPos() ~= self:GetPos() then
		self.RTCam:SetPos(self:GetPos())
	end
	--if self.RTCam:GetPos():DistToSqr(MirrorPos) > 300*300 then return end
	local ply = LocalPlayer()
	
	if ViewFunction then
		local ViewTbl = ViewFunction(ply,ply:EyePos(),Lastang,Lastfov,Lastznear,Lastzfar)
		if ViewTbl then
			ViewPos,ViewAng = ViewTbl.origin,ViewTbl.angles
		else
			ViewPos,ViewAng = nil,nil
		end
	end
	
	local plypos = ViewPos or ply:EyePos()
	local ang = (plypos - MirrorPos):Angle()
	local mirrorang = self:GetAngles()
	local worldmirrorang = self:LocalToWorldAngles(mirrorang)
	ang = -ang + Angle(-mirrorang.r*2,worldmirrorang.y+180,-mirrorang.p*2)
	self.RTCam:SetAngles(ang)
	
	--[[local FOV
	local Dist = plypos:DistToSqr(MirrorPos)
	local veh = ply:GetVehicle()
	if IsValid(veh) then
		veh = veh:GetNW2Entity("TrainEntity")
	end
	if IsValid(veh) then
		FOV = C_CabFOV:GetFloat()
	else
		FOV = C_FovDesired:GetFloat()
	end]]
end

local MirrorPreview = CreateClientConVar("mirror_preview", "0", false)
local MirrorDistance = CreateClientConVar("mirror_distance", "50", false)
local MirrorAngleP = CreateClientConVar("mirror_angle_p", "0", false)
local MirrorAngleY = CreateClientConVar("mirror_angle_y", "0", false)
local MirrorAngleR = CreateClientConVar("mirror_angle_r", "0", false)
local MirrorScale = CreateClientConVar("mirror_scale", "1", false)
local MirrorModel = CreateClientConVar("mirror_model_type", "1", false)
local MirrorPreviewHotkey = CreateClientConVar("mirror_preview_hotkey", "", true)
local MirrorSrickDown = CreateClientConVar("mirror_stick_down", "0", false)

if not game.SinglePlayer() then
	hook.Add("PlayerButtonDown","Mirror_preview_toggle",function(ply, button )
		local MirrorPreviewHotkey1 = MirrorPreviewHotkey:GetInt()
		if MirrorPreviewHotkey1 and MirrorPreviewHotkey1 ~= 0 and button == MirrorPreviewHotkey1 then 
			RunConsoleCommand("mirror_preview",MirrorPreview:GetBool() and 0 or 1)
		end
	end)
end

local MirrorEnt

hook.Add("Think","MirrorPreview",function()
	if not MirrorPreview:GetBool() or not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" then
		if IsValid(MirrorEnt) then 
			MirrorEnt:Remove() 
		end
		return 
	end
	
	
	if not IsValid(GetGlobalEntity("MirrorRTCam")) then return end
	
	if not IsValid(MirrorEnt) then 
		MirrorEnt = ents.CreateClientProp(GetModelByType(MirrorModel:GetInt()))
		MirrorEnt:Spawn()
	end
	
	if MirrorEnt:GetModel() ~= GetModelByType(MirrorModel:GetInt()) then MirrorEnt:SetModel(GetModelByType(MirrorModel:GetInt())) end
	
	local ply = LocalPlayer()
	MirrorEnt:SetModelScale(MirrorScale:GetFloat())
	MirrorEnt:SetPos(ply:LocalToWorld(Vector(MirrorDistance:GetFloat()))+Vector(0,0,60))
	
	local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
	MirrorEnt:SetAngles(Angle(plyang.r+MirrorAngleP:GetFloat(),plyang.y+90+MirrorAngleY:GetFloat(),plyang.p+MirrorAngleR:GetFloat()))
	
	THEFULDEEP.MirrorDraw(MirrorEnt)
end)

