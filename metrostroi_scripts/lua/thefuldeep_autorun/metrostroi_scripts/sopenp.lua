if CLIENT then return end
local function OpenRoute(sig,nextsigname)
	if not sig.Routes or #sig.Routes == 1 and not sig.Routes[1].Manual then return end
	local route
	
	for k,v in pairs(sig.Routes)do
		if v.NextSignal == nextsigname then
			route = k
		end
	end
	
	if not route then
		for k,v in pairs(sig.Routes)do
			if v.NextSignal == "*" then
				route = k
			end
		end
	end
	
	if route then
		sig:OpenRoute(route)
		--for k,v in pairs(ents.FindByClass("gmod_track_signal"))do
			--if v.SayHook then
				--v:SayHook(nil,sig.Routes[route])
			--end
		--end
		return true
	end
	
end

local function SopenP(ply,comm)
	if comm:sub(1,8):lower() ~= "!sopenp " then return end
	comm = comm:sub(9)
	ply = IsValid(ply) and ply
	local startsig,endsig = unpack(string.Explode("-",comm))
	startsig = startsig and Metrostroi.GetSignalByName(startsig:upper())
	endsig = endsig and Metrostroi.GetSignalByName(endsig:upper())
	if not IsValid(startsig) then 
		if ply then
			ply:ChatPrint("Не удалось найти стартовый сигнал.")
		end
		return ""
	end
	local needdprintends
	if not IsValid(endsig) then 
		if ply then
			ply:ChatPrint("Не удалось найти конечный сигнал.")
			ply:ChatPrint("Все возможные варианты конечного сигнала выведены в консоль.")
		end
		needdprintends = true
	end
	local was = {} -- чтобы случайно не уйти в рекурсию
	local prevsignals = {}
	local cursigs = {}
	cursigs[startsig] = true
	while table.Count(cursigs) > 0 do
		for sig,bool in pairs(cursigs)do
			if not was[sig] --[[and table.Count(sig.NextSignals) > 0]] then
				was[sig] = true
				for _,nextsig in pairs(sig.NextSignals)do
					cursigs[nextsig] = true
					prevsignals[nextsig] = prevsignals[nextsig] or {}
					--prevsignals[nextsig][sig] = sig
					prevsignals[nextsig][#prevsignals[nextsig]+1] = sig
				end
			end
			cursigs[sig] = nil
		end
	end
	
	if needdprintends then
		was[startsig] = nil
		for k,v in pairs(was)do
			if ply then
				ply:SendLua("print('"..k.Name.."')")
			end
		end
		return ""
	end
	--if not ends[endsig] then return end--TODO ошибка в чат
	
	--TODO если у сигнала несколько предыдущих сигналов, то хз как сделать. Но я это пока не обрабатываю
	
	local cursig = prevsignals[endsig] and prevsignals[endsig][1]
	if not cursig then
		ply:ChatPrint("Не удалось открыть маршрут к сигналу.")
		return ""
	end
	local name = endsig.Name
	while cursig do
		local needprint
		if cursig.Close then 
			cursig.Close = false
			needprint = true
		end
		
		needprint = needprint or OpenRoute(cursig,name)

		if needprint then
			local a = cursig.Name
			timer.Simple(0.1,function()
				for _,ply in pairs(player.GetHumans()) do
					ply:ChatPrint("Opening "..a)
				end
			end)
		end
		name = cursig.Name
		cursig = prevsignals[cursig] and prevsignals[cursig][1]
	end
end


hook.Add("PlayerSay","Metrostroi !sopenP",SopenP)