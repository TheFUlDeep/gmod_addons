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
					files[k] = nil print("File "..path..v.." is empty. It will not be included.") 
				end
			end
			if param == "sh" or param == "sv" then
				for k,v in pairs(files) do
					print("including "..path..v.." by TheFulDeep's autorun")
					include(path..v) 
				end
			end
			if param == "sh" or param == "cl" then
				for k,v in pairs(files) do
					AddCSLuaFile(path..v)
					print("added "..path..v.." to download to clients")
				end
			end
		end
		
		if CLIENT and (param == "sh" or param == "cl") then
			for k,v in pairs(files) do
				include(path..v)
				print("included "..path..v.." by TheFulDeep's autorun")
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
InitAutorun("thefuldeep_autorun/","sh")				-- same as next line
InitAutorun("thefuldeep_autorun_sh/","sh")
InitAutorun("thefuldeep_autorun_cl/","cl")
InitAutorun("thefuldeep_autorun_sv/","sv")
print("TheFulDeep's autorun initialized")