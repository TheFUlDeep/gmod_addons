--TODO фикс конфликта с камерами метростроя
if 1 then return end
THEFULDEEP = THEFULDEEP or {}
local THEFULDEEP = THEFULDEEP

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
	local MirrorsCount = 0
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
		MirrorsCount = #Mirrors
		if IsValid(ply) then ply:ChatPrint("loaded "..#Mirrors.." mirrors") end
		end)
	end)
	
	hook.Add("PlayerInitialSpawn","SpawnMirrors",function() 
		hook.Remove("PlayerInitialSpawn","SpawnMirrors")
		RunConsoleCommand("mirrors_load")
	end)
	
	hook.Add("OnEntityCreated", "DisableVideoCameras in subway", function(ent)
		timer.Simple(3, function()
			if not IsValid(ent) or MirrorsCount < 1 or not ent:GetClass():find("81-76",1,true) or not ent.SF19 or not ent.SF19.TriggerInput then return end
			ent.SF19:TriggerInput("Set",0)
		end)
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

local MetrostroiDrawCams--,C_CabFOV,C_FovDesired
timer.Simple(0,function()
	MetrostroiDrawCams = GetConVar("metrostroi_drawcams")
	--C_CabFOV              = GetConVar("metrostroi_cabfov")
	--C_FovDesired          = GetConVar("fov_desired")
end)
local lastdraw = CurTime()
local preview
THEFULDEEP.MirrorDraw = function(self)
	if not preview and (not self.ShouldDraw or MetrostroiDrawCams and not MetrostroiDrawCams:GetBool()) then return end
	lastdraw = CurTime()
	--if not self:ShouldRenderClientEnts() then return end
	local RTCam = GetGlobalEntity("MirrorRTCam")
	if not IsValid(RTCam) then return end
	
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
	
	local MirrorPos = self:GetPos()
	if RTCam:GetPos() ~= MirrorPos then
		RTCam:SetPos(MirrorPos)
	end
	--if self.RTCam:GetPos():DistToSqr(MirrorPos) > 300*300 then return end
	--local ply = LocalPlayer()
	
	--local plypos = THEFULDEEP.RealViewPos--эта переменная задается в файле draw_signals_routes.lua
	local mirrorang = self:GetAngles()
	RTCam:SetAngles(-((THEFULDEEP.RealViewPos - MirrorPos):Angle()) + Angle(-mirrorang.r*2,self:LocalToWorldAngles(mirrorang).y+180,-mirrorang.p*2))
	
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
local DrawFunc = THEFULDEEP.MirrorDraw

local classesToSkip = {prop_vehicle_prisoner_pod = true}

timer.Simple(0,function()
	for _,class in pairs(Metrostroi.TrainClasses or {})do
		classesToSkip[class] = true
	end
end)


local tracelinesetup = {
	mask = MASK_VISIBLE_AND_NPCS,--MASK_BLOCKLOS_AND_NPCS
	output = {},
	filter = function(ent)
		if ent == LocalPlayer() or IsValid(ent) and classesToSkip[ent:GetClass()] then return false end
		return true
	end
}

--вершины
local angles = {
	Vector(1,1,1),
	Vector(1,-1,1),
	Vector(1,-1,-1),
	Vector(1,1,-1),
	
	Vector(-1,1,1),
	Vector(-1,-1,1),
	Vector(-1,-1,-1),
	Vector(-1,1,-1)
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
	{angles[4],angles[8]}
}


timer.Simple(0,function()
	local utilTraceLine = util.TraceLine
	local entsFindByClass = ents.FindByClass
	local mathabs = math.abs
	timer.Create("check if player can see mirror",1,0,function()
		--local ply = LocalPlayer()
		--local StartPos = ViewPos or ply:EyePos()
		tracelinesetup.start = THEFULDEEP.RealViewPos
		--local plyang = ply:EyeAngles()
		for _,ent in pairs(entsFindByClass("gmod_metrostroi_mirror")) do
			if not IsValid(ent) then continue end
			
			--[[local AngToMirror = (ent:GetPos()-StartPos):Angle()
			local deltaang = AngToMirror - plyang
			deltaang:Normalize()
			if mathabs(deltaang[2]) > 70 or mathabs(deltaang[1]) > 70 then 
				ent.ShouldDraw = false
				continue
			end]]
			
			local mins = ent:OBBMins()+Vector(0,0,-150*ent:GetModelScale())--дополнитльная высота для палки
			ent.ShouldDraw = false
			for k,points in pairs(lines) do
				local startvec = ent:LocalToWorld(points[1]*mins)
				local endvec = ent:LocalToWorld(points[2]*mins)
				for i = 0,1,0.2 do					
					tracelinesetup.endpos = LerpVector(i, startvec, endvec)
					local output = utilTraceLine(tracelinesetup)
					local resEnt = output.Entity
					--print(resEnt,output.Fraction)
					if output.Fraction == 1 or resEnt == ent or resEnt == ent.Frame or resEnt == ent.Stick then
						ent.ShouldDraw = true
						goto CONTINUE
					end
				end
			end
			::CONTINUE::
		end
		
		if CurTime() - lastdraw > 0.5 and IsValid(GetGlobalEntity("MirrorRTCam")) then
			GetGlobalEntity("MirrorRTCam"):SetPos(Vector(0,0,-99999))
		end
	end)
end)

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
	local ply = LocalPlayer()
	if not MirrorPreview:GetBool() or not IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() ~= "gmod_tool" then
		if IsValid(MirrorEnt) then 
			MirrorEnt:Remove() 
		end
		preview = false
		return 
	end
	
	preview = true
	
	if not IsValid(GetGlobalEntity("MirrorRTCam")) then return end
	
	if not IsValid(MirrorEnt) then 
		MirrorEnt = ents.CreateClientProp(GetModelByType(MirrorModel:GetInt()))
		MirrorEnt:Spawn()
	end
	
	if MirrorEnt:GetModel() ~= GetModelByType(MirrorModel:GetInt()) then MirrorEnt:SetModel(GetModelByType(MirrorModel:GetInt())) end
	
	MirrorEnt:SetModelScale(MirrorScale:GetFloat())
	MirrorEnt:SetPos(ply:LocalToWorld(Vector(MirrorDistance:GetFloat()))+Vector(0,0,60))
	
	local plyang = ply:GetEyeTraceNoCursor().Normal:Angle()
	MirrorEnt:SetAngles(Angle(plyang.r+MirrorAngleP:GetFloat(),plyang.y+90+MirrorAngleY:GetFloat(),plyang.p+MirrorAngleR:GetFloat()))
	
	DrawFunc(MirrorEnt)
end)

