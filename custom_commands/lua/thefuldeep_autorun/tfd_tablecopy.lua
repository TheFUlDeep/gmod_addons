function tfdTableCopy(tbl)--нерекурсивная фнукция копирования таблицы. Не съедает стэк, работает с рекурсивными таблицами
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
	for k,v in pairs(tbl)do
		layers[1][#layers[1]+1] = {k,v}
	end
	while CanGoDown(layers[#layers])do
		local valuesCount = #(layers[#layers][1])
		layers[#layers+1] = {}
		local newlayer = layers[#layers]
		for k,val in pairs(layers[#layers-1])do
			local v = val[valuesCount]
			if istable(v) then
				if not copuiedAddresses[v] then
					copuiedAddresses[v] = true
					for k1,v1 in pairs(v)do
						newlayer[#newlayer+1] = {k,k1,v1}
					end
				end
			end
		end
	end
	layers[#layers] = nil
	
	for i = #layers,2,-1 do
		for k,v in pairs(layers[i])do
			if layers[i-1][v[1]][3] then
				layers[i-1][v[1]][3][v[2]] = v[3]
			else
				layers[i-1][v[1]][2][v[2]] = v[3]
			end
		end
		layers[i] = nil--освобождаю память kek
	end
	
	local res = {}
	for k,v in pairs(layers[1])do
		res[v[1]] = v[2]
	end
	
	return res
end