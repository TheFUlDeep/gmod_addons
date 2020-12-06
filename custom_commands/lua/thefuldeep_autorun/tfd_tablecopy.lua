-- вместо # для производительности лучше использовать локальные индексы
local function ConvertValue(v,tonormal)
	if tonormal == false then
		if isvector(v) then
			return {lanesTableType="Vector",v[1],v[2],v[3]}
		elseif isangle(v) then
			return {lanesTableType="Angle",v[1],v[2],v[3]}
		elseif IsEntity(v) then
			return {lanesTableType="Entity",IsValid(v) and v:EntIndex() or -1}
		else
			return v
		end
	elseif tonormal then
		if istable(v) then
			local typ = v.lanesTableType
			if typ == "Vector" then
				return Vector(v[1],v[2],v[3])
			elseif typ == "Angle" then
				return Angle(v[1],v[2],v[3])
			elseif typ == "Entity" then
				return Entity(v[1])
			else
				return v
			end
		else
			return v
		end
	else
		return v
	end
end

local function tfdTableToLayers1(tbl,tonormal)--копирование содержимоого таблицы по слоям
	if tonormal or tonormal == false then
		tbl = tbl or {}
		tbl = istable(tbl) and tbl or {tbl}
	end
	local copuiedAddresses = {}--запоминаю уже скопированные адресы, чтобы не войти в бесконечную рекурсию (если таблица рекурсивна)
	local layers = {}--запоминаю каждый уровень глубины
	local function CanGoDown(tbl)
		for _,v in pairs(tbl)do
			if istable(v) and not copuiedAddresses[v] then return true end
		end
	end
	--layer[1] = {{1,2},{1,2},{1,2},...}--1 - ключ в своей таблице, 2 - значение
	--или
	--layer[2] = {{1,2,3},{1,2,3},{1,2,3},...}-- 1 - ключ таблицы в предыдущем слое, 2 - ключ в своей таблице, 3 - значение
	layers[1] = {}
	local t = layers[1]
	local index = 0
	for k,v in pairs(tbl)do
		index = index + 1
		t[index] = {k,ConvertValue(v,tonormal)}
	end
	local index2 = 1
	while CanGoDown(layers[index2])do
		local newindex = index2 + 1
		local valuesCount = #(layers[index2][1])
		layers[newindex] = {}
		local newlayer = layers[newindex]
		for k,val in pairs(layers[index2])do
			local index = 0
			local v = val[valuesCount]
			if istable(v) and not copuiedAddresses[v] then
				copuiedAddresses[v] = true
				for k1,v1 in pairs(v)do
					index = index + 1
					newlayer[index] = {k,k1,ConvertValue(v1,tonormal)}
				end
			end
		end
		index2 = newindex
	end
	layers[index2] = nil
	return layers
end

function tfdTableCopy1(tbl,tonormal)--нерекурсивная фнукция копирования таблицы. Не съедает стэк, работает с рекурсивными таблицами
	local layers = tfdTableToLayers1(tbl,tonormal)
	
	local c = #layers
	if c > 2 then
		for i = c,3,-1 do
			for k,v in pairs(layers[i])do
				layers[i-1][v[1]][3][v[2]] = v[3]
			end
		end
	end
	
	if layers[1] and layers[2] then
		for k,v in pairs(layers[2])do
			layers[1][v[1]][2][v[2]] = v[3]
		end
	end
	
	local res = {}
	for k,v in pairs(layers[1] or {})do
		res[v[1]] = v[2]
	end
	
	return res
end









local function tfdTableToLayers2(tbl,tonormal)--копирование содержимоого таблицы по слоям
	if tonormal or tonormal == false then
		tbl = tbl or {}
		tbl = istable(tbl) and tbl or {tbl}
	end
	local copuiedAddresses = {}--запоминаю уже скопированные адресы, чтобы не войти в бесконечную рекурсию (если таблица рекурсивна)
	local layers = {}--запоминаю каждый уровень глубины
	local function CanGoDown(tbl)
		for _,v in pairs(tbl)do
			if istable(v) and not copuiedAddresses[v] then return true end
		end
	end
	--layer[1] = {{1,2,3,...},{1,2,3,...}}--1 таблица - ключи в своей таблице, 2 - значения
	--или
	--layer[2] = {{1,2,3,...},{1,2,3,...},{1,2,3,...}}-- 1 таблица - ключи таблицы в предыдущем слое, 2 - ключи в своей таблице, 3 - значения
	layers[1] = {{},{}}
	local index = 0
	local a = layers[1][1]
	local b = layers[1][2]
	for k,v in pairs(tbl)do
		index = index + 1
		a[index] = k
		b[index] = ConvertValue(v,tonormal)
	end
	
	local index2 = 1
	while CanGoDown(layers[index2])do
		local newindex = index2 + 1
		layers[newindex] = {}
		local newlayer = layers[newindex]
		local a = layers[index2]
		local b = a[3] or a[2]
		for k,v in pairs(b)do
			if istable(v) and not copuiedAddresses[v] then
				local index = 0
				copuiedAddresses[v] = true
				for c = 1,3 do
					newlayer[c] = {}
				end
				for k1,v1 in pairs(v)do
					index = index + 1
					newlayer[1][index] = k
					newlayer[2][index] = k1
					newlayer[3][index] = ConvertValue(v1,tonormal)
				end
			end
		end
		index2 = newindex
	end
	layers[index2] = nil
	return layers
end

--этот метод работает быстрее, чем первый, если в таблице на одном уровне много элементов
--но для маленьких таблиц он медленнее
function tfdTableCopy2(tbl,tonormal)--нерекурсивная фнукция копирования таблицы. Не съедает стэк, работает с рекурсивными таблицами
	local layers = tfdTableToLayers2(tbl,tonormal)
	
	local c = #layers
	if c > 2 then
		for i = c,3,-1 do
			local a = layers[i-1][3]
			local b = layers[i][1]
			local c = layers[i][2]
			local d = layers[i][3]
			for j = 1, #b do
				a[b[j]][c[j]] = d[j]
			end
		end
	end
	if layers[1] and layers[2] then
		local a = layers[1][2]
		local b = layers[2][1]
		local c = layers[2][2]
		local d = layers[2][3]
		for j = 1, #b do	
			a[b[j]][c[j]] = d[j]
		end
	end
	local Tbl = layers[1]
	--PrintTable(Tbl)
	local res = {}
	for i = 1, #Tbl[1] do
		res[Tbl[1][i]] = Tbl[2][i]
	end
	return res
end