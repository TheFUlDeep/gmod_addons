if Metrostroi == nil then return end

local metrotrainstable = {
"gmod_subway_81-717_lvz",
"gmod_subway_81-714_lvz",
"gmod_subway_81-717_mvm",
"gmod_subway_81-714_mvm",
"gmod_subway_81-722",
"gmod_subway_81-723",
"gmod_subway_81-724",
"gmod_subway_81-720",
"gmod_subway_81-721",
"gmod_subway_81-703",
"gmod_subway_81-703_2",
"gmod_subway_ezh",
"gmod_subway_ezh1",
"gmod_subway_ezh3",
"gmod_subway_em508t",
"gmod_subway_em508",
"gmod_subway_em508_int",
"gmod_subway_ema",
"gmod_subway_em",
"gmod_subway_81-717_6",
"gmod_subway_81-714_6",
"gmod_subway_81-718",
"gmod_subway_81-719"
}

local function MezhvagLoadSystem(ent,systemname)
	if not IsValid(ent) then return end
	if not ent.LoadSystem then
		timer.Simple(0.1,function()
			MezhvagLoadSystem(ent,systemname)
		end)
	else
		ent:LoadSystem(systemname)
	end
end


hook.Add("OnEntityCreated","MezhvagAddSystem",function(ent)
	if table.HasValue(metrotrainstable,ent:GetClass()) then
		timer.Simple(0,function() MezhvagLoadSystem(ent,"MEZHVAG") end)
	end
end)