--TODO shortEverySword сокращает каждое слово, а не только с конца (либо с фиксированными словами, либо без)
--TODO не проверено
include("thefuldeep_autorun/string_tools/bigrustusmall.lua")

local buffer = {}

local defShorts = {
	["улица"] = "л.",
	["проспект"] = "р-кт",
	["площадь"] = "л-дь",
}

local sogltbl = {["б"]=true,["в"]=true,["г"]=true,["д"]=true,["ж"]=true,["з"]=true,["к"]=true,["л"]=true,["м"]=true,["н"]=true,["п"]=true,["р"]=true,["с"]=true,["т"]=true,["ф"]=true,["х"]=true,["ц"]=true,["ч"]=true,["ш"]=true,["щ"]=true,["Б"]=true,["В"]=true,["Г"]=true,["Д"]=true,["Ж"]=true,["З"]=true,["К"]=true,["Л"]=true,["М"]=true,["Н"]=true,["П"]=true,["Р"]=true,["С"]=true,["Т"]=true,["Ф"]=true,["Х"]=true,["Ц"]=true,["Ч"]=true,["Ш"]=true,["Щ"]=true}

local gltbl = {["а"]=true,["е"]=true,["ё"]=true,["и"]=true,["о"]=true,["у"]=true,["ы"]=true,["э"]=true,["ю"]=true,["я"]=true,["А"]=true,["Е"]=true,["Ё"]=true,["И"]=true,["О"]=true,["У"]=true,["Ы"]=true,["Э"]=true,["Ю"]=true,["Я"]=true}

local utf8sub = utf8.sub
local utf8len = utf8.len

local function JustShortFromEnd(str,maxlen)
	if maxlen >= utf8len(str) then return str end
	
	--если граница оканчивается на согласную, а дальше идет гласная, то сразу подходит
	if sogltbl[utf8sub(str,maxlen,maxlen)] and gltbl[utf8sub(str,maxlen+1,maxlen+1)] then return utf8sub(str,1,maxlen).."." end
	
	local IsPrevGl = gltbl[utf8sub(str,maxlen,maxlen)]
	for i = maxlen - 1,1,-1 do
		local cursymbol = utf8sub(str,i,i)
		if sogltbl[cursymbol] and IsPrevGl then
			return utf8sub(str,1,i).."."
		end
		IsPrevGl = gltbl[cursymbol]
	end
	
	--если не вернул ничего, то ищу первую найденую согласную и сокращаю по мней
	for i = maxlen,1,-1 do
		local cursymbol = utf8sub(str,i,i)
		if sogltbl[cursymbol] then
			return utf8sub(str,1,i).."."
		end
	end
	
	--если не вернул по первой найденной согласной, то сокращаю просто по длине
	return utf8sub(str,1,maxlen).."."
end


local defShortsString = ""
for k,v in pairs(defShorts)do
	defShortsString = defShortsString..tostring(k)..tostring(v)
end

local function TableToString(tbl)
	if not tbl then return "false" end
	if not istable(tbl) then return defShortsString end
	local res = ""
	for k,v in pairs(tbl)do
		res = res..tostring(k)..tostring(v)
	end
	return res
end

local function CreateID(str,maxlen,currentShorts,saveLoadBuffer,shortEverySword)
	return str..maxlen..TableToString(currentShorts)..(saveLoadBuffer and "true" or "false")..(shortEverySword and "true" or "false")
end

--currentShorts надо ли сокращять конкретные слова. Если true, то возьмется стандартное значение, иначе своя таблица в нижнем регистре
--saveLoadBuffer не будет заного сокращать стринг, а найдет/сделает сохраненную версию по своему уникальному айди, составленному из аргументов
local function ShortString(str,maxlen,currentShorts,saveLoadBuffer,shortEverySword)
	if saveLoadBuffer then
		local res = buffer[CreateID(str,maxlen,currentShorts,saveLoadBuffer,shortEverySword)]
		if res then return res end
	end
	local res = str
	local strlow = bigrustusmall(str)
	if currentShorts then
		currentShorts = istable(currentShorts) and currentShorts or defShorts
		for word,neword in pairs(currentShorts)do
			local start = strlow:find(word,1,true)
			while start do
				local wordlen = utf8len(word)
				res = utf8sub(res,1,start)..neword..utf8sub(res,start + wordlen)
				strlow = utf8sub(strlow,1,start)..neword..utf8sub(strlow,start + wordlen)
				start = strlow:find(word,1,true)
			end
		end
	end
	
	if utf8len(res) > maxlen then
		if shortEverySword then
			local kek
		else
			res = JustShortFromEnd(res,maxlen)
		end
	end
	
	if saveLoadBuffer then
		buffer[CreateID(str,maxlen,currentShorts,saveLoadBuffer,shortEverySword)] = res
	end
	
	return res
end