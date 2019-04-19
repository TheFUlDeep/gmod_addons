--[[============================= ФУНКЦИЯ ПОИСКА СОВПАДЕНИЯ СТРИНГОВ ==========================]]
function stringfind(where, what, lowerr, startpos, endpos)
	local Exeption = false
	if not where or not what then --[[print("[STRINGFIND EXEPTION] cant find required arguments")]] return false end
	if type(where) ~= "string" or type(what) ~= "string" then --[[print("[STRINGFIND EXEPTION] not string")]] return false
	elseif string.len(what) > string.len(where) then --[[print("[STRINGFIND EXEPTION] string what you want to find bigger than string where you want to find it")]] Exeption = true 
	end
	if startpos and type(startpos) ~= "number" then startpos = tonumber(startpos) end
	if endpos and type(endpos) ~= "number" then endpos = tonumber(endpos) end
	local strlen1 = string.len(where)
	local strlen2 = string.len(what)
	if not startpos or startpos == 0 then startpos = 1 end
	if startpos < 1 then startpos = strlen1 + startpos + 1 end
	if not endpos or endpos == 0 then endpos = strlen1 end
	if endpos < 1 then endpos = strlen1 + endpos + 1 end
	if endpos > strlen1 then --[[print("[STRINGFIND EXEPTION] end position bigger then source string (source string size = "..#where..")")]] Exeption = true end
	if endpos < startpos then --[[print("[STRINGFIND EXEPTION] end position smaller then start position")]] Exeption = true end
	if startpos > strlen1 - strlen2 + 1 then --[[print("[STRINGFIND EXEPTION] string from your start position smaller then string what you want to find")]] Exeption = true end
	if endpos - startpos + 1 < strlen2 then --[[print("[STRINGFIND EXEPTION] section for finding smaller than string what you want to find")]] Exeption = true end
	if Exeption then return false end
	if lowerr then 
		where = bigrustosmall(where)
		what = bigrustosmall(what)
	end
	for i = startpos, endpos do
		if i + strlen2 - 1 > endpos then return false
		elseif string.sub(where, i, i + strlen2 - 1) == what then return i
		end
	end
	return false
end



--функция bigrustosmall в другом файле