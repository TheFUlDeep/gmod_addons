local cpu_load_str = "cpu_load"
local empty_str = ""
if SERVER then
    require("cpu_info")
    local count = GetProcessorsCount()
    timer.Create(cpu_load_str,1,0,function()
        local str = empty_str
        for core = 1,count do
            local load = GetProcessorLoad(core)
            if load == -2147483648 then continue end
            str = str..load.."\t"
        end
        SetGlobalString(cpu_load_str,str)
    end)
end
if SERVER then return end


--local c_developer = GetConVar("developer")
--timer.Create("cpu_load",1,0,function()
    --if not c_developer:GetBool() then return end
    --print(GetGlobalString("cpu_load"))
--end)

local c_net_graph = GetConVar("net_graph")

local textdata = {text = empty_str,pos = {0,0}}
hook.Add("HUDDrawScoreBoard", cpu_load_str, function()
    if not c_net_graph:GetBool() then return end
    textdata.text = GetGlobalString(cpu_load_str,empty_str)
    draw.Text(textdata)
end)
