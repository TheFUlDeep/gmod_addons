if true then return end

if SERVER then

	--смена освещения, но оно грустно работает
	--[[local al = {"a","b","c","d","e","f","g","h","i","j","k","l","m"}
	local alCount = #al
	local mathClamp = math.Clamp
	local mathfloor = math.floor
	local percent = 100
	local res = al[mathClamp(mathfloor((alCount/100)*mathClamp(percent, 0, 100)),1,alCount)]
	engine.LightStyle( 0, res)]]
	
	RunConsoleCommand("sv_skyname","painted")--!!!!
	--local env_sun,env_skypaint,dawn,dusk
	--dawn - горизонт со стороны солнца
	--dusk - ареал солнца
	
	timer.Simple(0,function()	
		local osdate = os.date	
		local entsFindByClass = ents.FindByClass
		local stringExplode = string.Explode
		--env_sun
		--env_sun = entsFindByClass("env_sun")[1]
		--if IsValid(env_sun) then print("setting env_sun") env_sun:SetKeyValue("size","10") end
		--self.m_EnvSun:Fire( "TurnOff", "", 0 )
		--self.m_EnvSun:Fire( "TurnOn", "", 0 )
		
		
		--env_skypaint
		local env_skypaint = entsFindByClass("env_skypaint")[1]
		if not IsValid(env_skypaint) then
			env_skypaint = ents.Create("env_skypaint")
			env_skypaint:Spawn()
			env_skypaint:Activate()
		end
		
		--dawn = entsFindByClass("dawn")[1]
		--dusk = entsFindByClass("dusk")[1]
		
		env_skypaint:SetTopColor(vector_origin)
		env_skypaint:SetBottomColor(Vector(1,1,1))
		env_skypaint:SetFadeBias(0)--горизонт со всех скорон
		env_skypaint:SetHDRScale(0)--?
		
		env_skypaint:SetDrawStars(true)
		env_skypaint:SetStarTexture("skybox/starfield")
		env_skypaint:SetStarLayers(1)
		env_skypaint:SetStarScale(3)
		env_skypaint:SetStarFade(0.5)--при маленьких значениях видно только над головой
		env_skypaint:SetStarSpeed(0.01)
		
		env_skypaint:SetDuskIntensity(1)--горизонт со стороны солнца
		env_skypaint:SetDuskScale(1.4)--TODO подобрать
		env_skypaint:SetDuskColor(Vector(1,0.2,0.2))--TODO оранжевый
		
		env_skypaint:SetSunSize(0.01)--ареал солнца
		env_skypaint:SetSunColor(Vector(1,1,0.2))
		
		local TopColor1 = Vector(0.09,0.09,1)
		local TopColor2 = Vector(0.3,0.3,0.776)
		local TopColor3 = Vector(0,0,0.01)
		
		local DunkColor1 = Vector(1,1,0.4)
		local DunkColor2 = Vector(1,0.2,0.2)
		
		--local currtime = 0
		local function ThinkParams()
			if not IsValid(env_skypaint) then return end
			local curtime = Metrostroi.GetSyncTime()
			--currtime = currtime + 600
			--curtime = 13*60*60
			--curtime = currtime
			curtime = osdate("!%X",curtime)
			curtime = stringExplode(":",curtime)
			local h,m,s = tonumber(curtime[1]),tonumber(curtime[2]),tonumber(curtime[3])
			local secs = h*60*60+m*60+s
			--print(secs-19*60*60)
			
			local TopColor,StarFade,DuskIntensity
			
			--от 13 до 19 SetTopColor должен меняться от 64,64,255 до 77,77,198
			--от 19 до 01 SetTopColor должен меняться от 77,77,198 до 30,30,127
			if h >= 13 and h < 19 then
				local percent = (secs-46800)/21600--(h*60*60-13*60*60)/(6*60*60)
				env_skypaint:SetTopColor(LerpVector(percent,TopColor1,TopColor2))
				env_skypaint:SetFadeBias(0)
				env_skypaint:SetStarFade(0)
				env_skypaint:SetDuskIntensity(Lerp(percent,0.7,1))
				env_skypaint:SetDuskColor(LerpVector(percent,DunkColor1,DunkColor2))
				env_skypaint:SetSunSize(0.01)
			elseif h >=19 or h < 1 then
				local percent = h >=19 and (secs-68400)/21600 --[[(secs-19*60*60)/21600]] or (secs+18000)/21600--(secs+5*60*60)/21600
				env_skypaint:SetTopColor(LerpVector(percent,TopColor2,TopColor3))
				env_skypaint:SetFadeBias(Lerp(percent,0,0.005))
				env_skypaint:SetStarFade(Lerp(percent,0,1))
				env_skypaint:SetDuskIntensity(Lerp(percent,1,0))
				env_skypaint:SetDuskColor(DunkColor2)
				env_skypaint:SetSunSize(Lerp(percent,0.01,0))
			elseif h >=1 and h < 7 then
				local percent = (secs-3600)/21600--(h*60*60-1*60*60)/(6*60*60)
				env_skypaint:SetTopColor(LerpVector(percent,TopColor3,TopColor2))
				env_skypaint:SetFadeBias(Lerp(percent,0.005,0))
				env_skypaint:SetStarFade(Lerp(percent,1,0))
				env_skypaint:SetDuskIntensity(Lerp(percent,0,0.7))
				env_skypaint:SetDuskColor(LerpVector(percent,DunkColor2,DunkColor1))
				env_skypaint:SetSunSize(Lerp(percent,0,0.01))
			elseif h >=7 and h < 13 then
				local percent = (secs-25200)/21600--(h*60*60-7*60*60)/(6*60*60)
				env_skypaint:SetTopColor(LerpVector(percent,TopColor2,TopColor1))
				env_skypaint:SetFadeBias(0)
				env_skypaint:SetStarFade(0)
				env_skypaint:SetDuskIntensity(0.7)
				env_skypaint:SetDuskColor(DunkColor1)
				env_skypaint:SetSunSize(0.01)
			end
		end
		
		timer.Create("Day and Night Sky",1,0,ThinkParams)
		
	end)
	--env_skypaint:SetStarTexture("skybox/starfield")
	
	
	
	--env_skypaint:SetSunNormal(env_sun:GetInternalVariable("m_vDirection"))
	
	
end

if CLIENT then
	--render.RedownloadAllLightmaps() -- это относится к смене освещения
end