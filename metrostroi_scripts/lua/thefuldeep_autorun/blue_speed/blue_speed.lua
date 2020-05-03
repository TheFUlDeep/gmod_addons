local nomerogg = "gmod_subway_81-717_mvm"
timer.Simple(0,function()
	local ENT = scripted_ents.GetStored(nomerogg.."_custom")
	if not ENT or not ENT.t then return end
	for _,v in pairs(ENT.t.Spawner or {}) do
		if type(v) == "table" and v[1] == "BlueSpeed" then return end
	end
	table.insert(ENT.t.Spawner,{"BlueSpeed","Синий скоростемер","Boolean"})
end)

if SERVER then return end

timer.Simple(0,function()
	local ENT = scripted_ents.GetStored(nomerogg)--замена моделей пропов
	if not ENT or not ENT.t then return else ENT = ENT.t end
	
	for name,cprop in pairs(ENT.ClientProps or {}) do
		if name == "SSpeed1" or name == "SSpeed2" then 
			local oldcallback = cprop.callback or function(wag,...) end
			cprop.callback = function(wag,cent)
				if wag:GetNW2Bool("BlueSpeed") then cent:SetColor(Color(0,0,255))end
				oldcallback(wag,cent)
			end
		end
	end
	
	if ENT.UpdateWagonNumber then
		local oldupdate = ENT.UpdateWagonNumber
		ENT.UpdateWagonNumber = function(wag,...)
				local CEnts = wag.ClientEnts or {}
				if CEnts.SSpeed1 then SafeRemoveEntity(CEnts.SSpeed1) end
				if CEnts.SSpeed2 then SafeRemoveEntity(CEnts.SSpeed2) end
			oldupdate(wag,...)
		end
	end
end)