--[[============================= string.lower ДЛЯ РУССКИХ СИМВОЛОВ ==========================]]
local BIGRUS = {"А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я"}
local smallrus = {"а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"}
local BIG_to_small = {}
for k, v in next, BIGRUS do
   
	BIG_to_small[v] = smallrus[k]
   
end
function bigrustosmall(str)
   
	local strlow = ""
   
	for v in string.gmatch(str, "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*") do
		strlow = strlow .. (BIG_to_small[v] or v)
	end
   
	return string.lower(strlow) --жтобы англ буквы тоже занижалис
   
end