if CLIENT then return end

local function PSNotAllowed(SignalName,Route)
	SignalName = string.lower(SignalName)
    local foundByNames = {}
    for _,v in pairs(ents.FindByClass("gmod_track_signal")) do
        if IsValid(v) and v.Routes and v.SayHook and v.Name and string.lower(v.Name) == SignalName then table.insert(foundByNames,v) end
    end
    
	if #foundByNames < 1 then print("cant find signals with name",SignalName) return end
	
	Route = string.lower(Route)
	
	for _,v in pairs(foundByNames) do
		local oldhook = v.SayHook
		v.SayHook = function(self,ply,comm,...)
			if string.sub(comm,1,7) == "!sopps " and string.lower(v.Routes[v.Route] and v.Routes[v.Route].RouteName or "") == Route then return end
			oldhook(self,ply,comm,...)
		end
		print("Disabled PS on signal "..v.Name..", route "..Route)
	end
end

if false then--отключил, потому что пока не нужно
	hook.Add("PlayerInitialSpawn","PSNotAllowed Load",function()
		hook.Remove("PlayerInitialSpawn","PSNotAllowed Load")
		--PSNotAllowed("KB112","KB2-2")
	end)
end