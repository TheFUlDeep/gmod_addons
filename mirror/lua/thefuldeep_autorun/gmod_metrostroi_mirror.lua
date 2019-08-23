--TODO модели
--TODO фикс конфликта с камерами метростроя


if SERVER then
	util.AddNetworkString("SpawnMirror")

	local function SpawnMirror(pos,ang,scale,model)
		local mirror = ents.Create("gmod_metrostroi_mirror")
		if not IsValid(mirror) then print("ERROR with createin mirror") return end
		if model and not model:find("%a") then model = nil end
		mirror.Model = model
		mirror:Spawn()
		mirror:SetModelScale(scale or 1)
		timer.Simple(0.3,function()
			mirror:SetPos(pos)
			mirror:SetAngles(ang)
		end)
		print("Mirror spawned")
		return mirror
	end
	
	net.Receive("SpawnMirror", function(len,ply)
		if not ply:IsSuperAdmin() then return end
		local a,b,c,d,e,f,g = net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat()
		local Mirror = SpawnMirror(Vector(a,b,c),Angle(d,e,f),g)
		
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
			if IsValid(ent) then table.insert(Mirrors[Map],1,{ent:GetPos(),ent:GetAngles(),ent:GetModelScale()}) end
		end
		--if #Mirrors[Map] < 1 then print("no mirrors") ply:ChatPrint("no mirrors") return end
		file.Write("mirrors.txt", util.TableToJSON(Mirrors,true))
		print("mirrors saved")
		ply:ChatPrint("saved "..#Mirrors[Map].." mirrors")
	end)
	
	concommand.Add("mirrors_load", function(ply)
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end
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
				print("no mirrors for this map") ply:ChatPrint("no mirrors for this map")
				return 
			else
				for _,mirror in ipairs(Mirrors) do
					SpawnMirror(mirror[1],mirror[2],mirror[3])
				end
			end
		else
			for _,mirror in ipairs(Mirrors) do
				SpawnMirror(mirror[1],mirror[2],mirror[3])
			end
		end
		print("loaded "..#Mirrors.." mirrors")
		ply:ChatPrint("loaded "..#Mirrors.." mirrors")
		end)
	end)
	
	hook.Add("PlayerInitialSpawn","SpawnMirrors",function() 
		hook.Remove("PlayerInitialSpawn","SpawnMirrors")
		RunConsoleCommand("mirrors_load")
	end)
	
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
	self.RTCam:SetPos(MirrorPos)
	--if self.RTCam:GetPos():DistToSqr(MirrorPos) > 300*300 then return end
	local ply = LocalPlayer()
	
	if ViewFunction then
		local ViewTbl = ViewFunction(ply,Lastpos,Lastang,Lastfov,Lastznear,Lastzfar)
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
local MirrorModel = CreateClientConVar("mirror_model", "", false) --TODO

local w,h = 512,512
local rtTexture = surface.GetTextureID( "pp/rt" )		

local MirrorEnt

hook.Add("Think","MirrorPreview",function()
	if not MirrorPreview:GetBool() or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_tool" then
		if IsValid(MirrorEnt) then 
			MirrorEnt:Remove() 
		end
		return 
	end
	
	
	if not IsValid(GetGlobalEntity("MirrorRTCam")) then return end
	
	if not IsValid(MirrorEnt) then 
		MirrorEnt = ents.CreateClientProp("models/thefuldeeps_models/mirror.mdl")
		MirrorEnt:Spawn()
		MirrorEnt:SetMaterial("models/rendertarget")
	end
	local ply = LocalPlayer()
	MirrorEnt:SetModelScale(MirrorScale:GetFloat())
	MirrorEnt:SetPos(ply:LocalToWorld(Vector(MirrorDistance:GetFloat()))+Vector(0,0,60))
	
	local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
	MirrorEnt:SetAngles(Angle(plyang.r+MirrorAngleP:GetFloat(),plyang.y+90+MirrorAngleY:GetFloat(),plyang.p+MirrorAngleR:GetFloat()))
	
	THEFULDEEP.MirrorDraw(MirrorEnt)
	
	-- draw render target
	surface.SetTexture( rtTexture )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0 , 0, 256, 256 )
end)

