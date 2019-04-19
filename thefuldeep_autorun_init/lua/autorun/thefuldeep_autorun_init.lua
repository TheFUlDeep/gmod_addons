local function InitAutorun(path)
	local files, directories = file.Find( path.."*", "LUA" )
	--PrintTable(files)
	if files then
		for k,v in pairs(files) do
			local content = file.Read(path..v, "LUA")
			if not content then continue end
			print("including "..path..v.." by TheFulDeep's autorun")
			include(path..v)
			AddCSLuaFile(path..v)
		end
	end
	if directories then 
		for k,v in pairs(directories) do
			InitAutorun(path..v.."/")
		end
	end
end
print("TheFulDeep's autorun initializing")
InitAutorun("thefuldeep_autorun/")
print("TheFulDeep's autorun initialized")