--взято из скрипта межвагонки ShadowBonnie
timer.Simple(0,function()
	for k,v in pairs(Metrostroi.TrainClasses) do
		local ENT = scripted_ents.GetStored(v)
		if ENT and ENT.t and ENT.t.Spawner then
			local cont = false
			for k,v in pairs(ENT.t.Spawner) do
				if istable(v) and v[1]=="RandomFailure" then cont = true break end
			end
			if cont then continue end
		
			table.insert(ENT.t.Spawner,{"RandomFailure","Случайные неисправности","Boolean"})
		end
	end
end)

if CLIENT then return end

local function Rand()
	local k = 60
	return math.random(5*k,15*k)
end

local function TimerFunction()
	local Trains = {}
	for _,class in pairs(Metrostroi.TrainClasses) do
		for _,wag in pairs(ents.FindByClass(class)) do
			if not wag:GetNW2Bool("RandomFailure",false) then continue end
			wag:UpdateWagonList()
			if not wag.WagonList then continue end
			local HasWagInTrain
			for _,trainwag in pairs(wag.WagonList) do
				if table.HasValue(Trains,trainwag) then HasWagInTrain = true break end
			end
			if HasWagInTrain then continue end
			table.insert(Trains,wag)
		end
	end
	for _,wag in pairs(Trains) do
		local wag1 = table.Random(wag.WagonList)
		print("Generating random failure in",tostring(wag1))
		wag1:TriggerInput("FailSimFail",1)
	end
	timer.Create("MetrostroiRandomFailure",Rand(),0,TimerFunction)
end

timer.Create("MetrostroiRandomFailure",Rand(),0,TimerFunction)