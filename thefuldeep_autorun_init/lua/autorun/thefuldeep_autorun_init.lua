local function InitAutorun(path,param)
	--if not file.Exists(string.sub(path,1,-2),"LUA") then return end
	local files, directories = file.Find( path.."*", "LUA" )
	--PrintTable(files)
	if files then
		for k,v in pairs(files) do
			--local content = file.Read(path..v, "LUA")
			--if not content or content == "" then continue end
			print("including "..path..v.."by TheFulDeep's autorun")
			include(path..v)
			if SERVER and (param == "sh" or param == "cl") then AddCSLuaFile(path..v) print("added "..path..v.." to download to clients") end
		end
	end
	if directories then 
		for k,v in pairs(directories) do
			InitAutorun(path..v.."/",param)
		end
	end
end
print("TheFulDeep's autorun initializing")
InitAutorun("thefuldeep_autorun/","sh")				-- same as next line
InitAutorun("thefuldeep_autorun_sh/","sh")
InitAutorun("thefuldeep_autorun_cl/","cl")
InitAutorun("thefuldeep_autorun_sv/","sv")
print("TheFulDeep's autorun initialized")