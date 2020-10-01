local function InitAutorun(path,param)
	--if not file.Exists(string.sub(path,1,-2),"LUA") then return end
	local files, directories = file.Find( path.."*", "LUA" )
	if files then
		if SERVER then
			for k,v in pairs(files) do
				local content = file.Read(path..v,"LUA")
				if content:find("%a") then
					continue
				else
					files[k] = nil MsgC(Color( 255, 0, 0 ),"File "..path..v.." is empty. It will not be included.\n")
				end
			end
			if param == "sh" or param == "sv" then
				for k,v in pairs(files) do
					MsgC(color_0_255_0,"including "..path..v.." by TheFulDeep's autorun\n")
					include(path..v) 
				end
			end
			if param == "sh" or param == "cl" then
				for k,v in pairs(files) do
					AddCSLuaFile(path..v)
					MsgC(Color( 255, 255, 0 ),"added "..path..v.." to download to clients by TheFulDeep's autorun\n")
				end
			end
		end
		
		if CLIENT and (param == "sh" or param == "cl") then
			for k,v in pairs(files) do
				include(path..v)
				MsgC(color_0_255_0,"included "..path..v.." by TheFulDeep's autorun\n")
			end
		end
	end
	
	if directories then 
		for k,v in pairs(directories) do
			InitAutorun(path..v.."/",param)
		end
	end
end
print("TheFulDeep's autorun initializing")
local optimization = "thefuldeep_autorun/color_optimization.lua"
if SERVER then AddCSLuaFile(optimization)end
include(optimization)

if SERVER then
	include("lanes/lanes_functions.lua")
end

InitAutorun("thefuldeep_autorun/","sh")				-- same as next line
InitAutorun("thefuldeep_autorun_sh/","sh")
InitAutorun("thefuldeep_autorun_cl/","cl")
InitAutorun("thefuldeep_autorun_sv/","sv")
print("TheFulDeep's autorun initialized")

--TODO сделать тут все глобальные переменные + написать IsValid2