local remove = table.remove
local function tableValuesToKeys(tbl,defvalue,isDeep)
	if defvalue == nil then defvalue = true end
	local res = {}
	for k,v in pairs(tbl)do
		res[v] = defvalue
	end
	return res
end

