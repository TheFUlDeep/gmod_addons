if CLIENT then return end

for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
    if not v.Routes or not v.Name then continue end
    for k1,v1 in pairs(v.Routes) do
		if not v1.RouteName then continue end
        hook.Remove("PlayerSay","PSNotAllowed on "..v.Name.." route "..v1.RouteName)
    end
end

local function PSNotAllowed(SignalName,Route)
    local NameExists = false
    for k,v in pairs(ents.FindByClass("gmod_track_signal")) do
        if v.Name == SignalName then NameExists = v break end
    end
    if not NameExists then error("SignalName not exists") end
    
    if not NameExists.Routes then error("no one route on your SignalName: "..SignalName) end
    local Added
    for k,v in pairs(NameExists.Routes) do
        if v.RouteName == Route then
            hook.Add("PlayerSay","PSNotAllowed on "..SignalName.." route "..Route,function(ply,text)
                if string.lower(string.sub(text,1,7)) == "!sopps " and string.lower(string.sub(text,8)) == string.lower(SignalName) then
                    if NameExists.Routes[NameExists.Route].RouteName == Route then
                        if NameExists.InvationSignal then NameExists.InvationSignal = false end
                        return ""
                    end
                end
            end)
            Added = true
            print("Disabled PS on signal "..NameExists.Name..", route "..Route)
            break
        end
    end
    if not Added then error("cant find route "..Route.." on signal "..SignalName) end
end

if false then--отключил, потому что пока не нужно
	hook.Add("PlayerInitialSpawn","PSNotAllowed Load",function()
		hook.Remove("PlayerInitialSpawn","PSNotAllowed Load")
		--PSNotAllowed("KB112","KB2-2")
	end)
end