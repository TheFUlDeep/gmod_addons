DIR_SEP="/" --should be "/" for Unix platforms (Linux and Mac)
function browseFolder(root)
	for entity in lfs.dir(root) do
		if entity~="." and entity~=".." then
			local fullPath=root..DIR_SEP..entity
			local mode=lfs.attributes(fullPath,"mode")
			if mode=="file" then
				print(root.." > "..entity)
			elseif mode=="directory" then
				browseFolder(fullPath);
			end
		end
	end
end

browseFolder(".")
