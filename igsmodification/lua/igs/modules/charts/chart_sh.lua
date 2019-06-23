IGS.CHARTS = IGS.CHARTS or setmetatable({
	MAP    = {}, -- pointers to stored
	STORED = {},

	LastUpdate = 0 -- таймштамп последнего глобального апдейта данных
},{
	__call = function(self,...)
		return self.Add(...)
	end
})

local BIT_MAX_CHARTS = 6 -- 63
local BIT_MAX_CHARTS_ID = BIT_MAX_CHARTS -- 63. Короче максимальный ID. Если не собираться пользоваться функцией удаления, то можно оставить, как есть
local BIT_MAX_COLUMNS = 4 -- 15
local BIT_MAX_RESULTS = 5 -- 31 -- линий, строк



local CHART = {}
CHART.__index = CHART

function CHART:SetDescription(sDescription)
	self.description = sDescription
	return self
end


if SERVER then
-- Данные чарта получены с БД и его можно отправлять клиентам
function CHART:SetReady(bReady)
	self.ready = bReady

	if bReady then
		IGS.CHARTS.Count = IGS.CHARTS.Count + 1
	else
		IGS.CHARTS.Count = IGS.CHARTS.Count - 1
	end
end


-- Чтобы не отсылатьь клиентам данные, пока их нет
function CHART:IsReady()
	return self.ready
end

function CHART:UpdateData(fOnFinish)
	if self:IsReady() ~= nil then -- не первое обновление данных
		self:SetReady(false)
	end

	self.func(function(dat)
		-- Предотвращаем дублирование
		self.columns = {}
		self.data = {}

		for clmn,val in pairs(dat[1] or {}) do
			table.insert(self.columns,clmn)
		end

		-- нечитаемо, но производительно. Хотя нахуй она тут нужна, в принципе.. Да похуй
		for rid,row in ipairs(dat) do
			self.data[rid] = {} -- 1 = место, 2 = ник, 3 = сумма значения колонок

			for cid,clmn_name in ipairs(self.columns) do
				self.data[rid][cid] = row[clmn_name]
			end
		end

		self:SetReady(true)
		if fOnFinish then fOnFinish() end
	end)
end

-- поможет разобраться в коде
-- https://img.qweqwe.ovh/1486856419550.png
net.Receive("IGS.SyncChart",function(_,pl)
	local ID = net.ReadUInt(BIT_MAX_CHARTS_ID)
	local OBJ = IGS.CHARTS.MAP[ID]

	net.Start("IGS.SyncChart")
	-------------------------------------------------------------------
	-- ID связанного чарта
	net.WriteUInt(ID,BIT_MAX_CHARTS_ID)

	if OBJ then
		net.WriteBool(true) -- exists

		-- Запись названия
		net.WriteString(OBJ:Name())

		-- Описания
		net.WriteString(OBJ:Description())

		-- Запись колонок
		net.WriteUInt(#OBJ:Columns(),BIT_MAX_COLUMNS)
		for clmn_id = 1,#OBJ:Columns() do
			net.WriteString(OBJ:Columns()[clmn_id])
		end

		-- Запись линий (строк, ячеек. Хз как)
		-- Упрощенная запись: https://img.qweqwe.ovh/1486859335711.png
		net.WriteUInt(#OBJ:Data(),BIT_MAX_RESULTS)
		local d = OBJ:Data()
		for line_id = 1,#d do
			--net.WriteUInt(#d[line_id],BIT_MAX_COLUMNS)
			for clmn_id = 1,#d[line_id] do
				net.WriteString(d[line_id][clmn_id])
			end
		end
	else
		net.WriteBool(false) -- not exists
	end
	-------------------------------------------------------------------
	net.Send(pl)
end)
else --------------------------------- CLIENT
function CHART:UpdateData(fOnFinish)
	net.Start("IGS.SyncChart")
		net.WriteUInt(self:ID(),BIT_MAX_CHARTS_ID)
	net.SendToServer()

	self.onUpdateFinish = fOnFinish
end

net.Receive("IGS.SyncChart",function()
	local OBJ = IGS.CHARTS.MAP[net.ReadUInt(BIT_MAX_CHARTS_ID)]

	-- с момента последнего получения данных на клиенте чарт существовал,
	-- но если бы тут было false, значит чарт удалили через IGS.CHARTS.Remove(id_or_name)
	local exists = net.ReadBool()
	if exists then
		-- Счиытваем имя
		OBJ.name = net.ReadString()
		OBJ:SetDescription(net.ReadString())

		-- Считываем колонки
		local clmns_count = net.ReadUInt(BIT_MAX_COLUMNS)
		for clmn_id = 1,clmns_count do
			OBJ.columns[clmn_id] = net.ReadString()
		end

		-- Считываем строки
		for line_id = 1,net.ReadUInt(BIT_MAX_RESULTS) do
			OBJ.data[line_id] = {}

			for related_clmn_id = 1,clmns_count do
				OBJ.data[line_id][related_clmn_id] = net.ReadString()
			end
		end
	end

	-- Если был запрошен каллбэк, то стучимся в него
	if OBJ.onUpdateFinish then
		OBJ.onUpdateFinish(exists)
		OBJ.onUpdateFinish = nil
	end

	-- Удаляем объект после каллбэка о завершении его обработки
	if !exists then
		IGS.CHARTS.Remove(OBJ:ID())
	end
end)
end

function CHART:Name()
	return self.name
end

function CHART:ID()
	return self.id
end

function CHART:Description()
	return self.description
end

-- iter, name
function CHART:Columns()
	return self.columns
end

-- iter, itervalues. # == кол-ву колонок
function CHART:Data()
	return self.data
end






if SERVER then -- на клиенте не нужно
	IGS.CHARTS.ID    = IGS.CHARTS.ID    or 1 -- для мапы
	IGS.CHARTS.Count = IGS.CHARTS.Count or 0 -- для избежания выполнения table.Count( IGS.CHARTS.GetMap() ) при записи кол-ва чатов, передавая на клиент
end
function IGS.CHARTS.Add(sName,fPickDataFunc)
	if IGS.CHARTS.STORED[sName] then return IGS.CHARTS.STORED[sName] end

	local OBJ = setmetatable({
		name = sName,
		id   = IGS.CHARTS.ID,
		func = fPickDataFunc,
		columns = {},
		data = {}
	},CHART)

	IGS.CHARTS.STORED[sName] = OBJ

	if SERVER then
		IGS.CHARTS.MAP[OBJ.id] = OBJ -- записывается при получении на клиенте

		IGS.CHARTS.ID = IGS.CHARTS.ID + 1
		-- IGS.CHARTS.Count = IGS.CHARTS.Count + 1
		--OBJ:SetReady(true)
	end

	return OBJ
end

local function upd(fOnFinish,prevId)
	local id  = prevId and prevId + 1 or 1
	local OBJ = IGS.CHARTS.MAP[id]

	if !OBJ then
		if fOnFinish then fOnFinish() end
		return
	end

	OBJ:UpdateData(function()
		upd(fOnFinish,id)
		IGS.CHARTS.LastUpdate = os.time()
	end)
end

if SERVER then
IGS.CHARTS.Update = upd
else ------------- CLIENT -------------
function IGS.CHARTS.Update(fOnFinish)
	IGS.CHARTS.RequestList(function()
		upd(fOnFinish)
	end)
end
end

function IGS.CHARTS.GetStored()
	return IGS.CHARTS.STORED
end

function IGS.CHARTS.GetMap()
	return IGS.CHARTS.MAP
end

-- Не знаю зачем такой функционал нужен, но я его сделал
-- С собой он тащит еще net.WriteBool в IGS.SyncChart
function IGS.CHARTS.Remove(id_or_name) -- на клиентах данные останутся
	local OBJ = IGS.CHARTS.MAP[id_or_name] or IGS.CHARTS.STORED[id_or_name]

	IGS.CHARTS.MAP[OBJ:ID()] = nil
	IGS.CHARTS.STORED[OBJ:Name()] = nil

	-- не знаю, нужно ли.
	-- Просто в начале OBJ = nil сделать нельзя, в таблицах остается
	-- Подозрение, что таблицу надо вручную удалять, чтобы из памяти вычистить
	OBJ = nil

	if SERVER then
		IGS.CHARTS.Count = IGS.CHARTS.Count - 1
	end
end



if SERVER then
	util.AddNetworkString("IGS.SyncChart")
	util.AddNetworkString("IGS.CHARTS.GetList")


	net.Receive("IGS.CHARTS.GetList",function(_,pl)
		net.Start("IGS.CHARTS.GetList")
			net.WriteUInt(IGS.CHARTS.Count,BIT_MAX_CHARTS)

			-- pairs, потому что какой-то чат может быть удален во время работы сервера
			-- IGS.CHARTS.Remove(id_or_name)
			for ID,OBJ in pairs( IGS.CHARTS.GetMap() ) do
				if !OBJ:IsReady() then continue end

				net.WriteString( OBJ:Name() )
				net.WriteUInt( OBJ:ID(),BIT_MAX_CHARTS_ID )
			end
		net.Send(pl)
	end)

else

	function IGS.CHARTS.RequestList(fCallback)
		net.Ping("IGS.CHARTS.GetList")

		net.Receive("IGS.CHARTS.GetList",function()
			for i = 1,net.ReadUInt(BIT_MAX_CHARTS) do
				local OBJ = IGS.CHARTS.Add(net.ReadString())
				OBJ.id = net.ReadUInt(BIT_MAX_CHARTS_ID)

				IGS.CHARTS.MAP[OBJ.id] = OBJ
			end

			if fCallback then fCallback() end
		end)
	end

end


--[[-------------------------------------------------------------------------
	Отладочная зона
---------------------------------------------------------------------------]]
-- local dev = true
-- if !dev then return end

-- if CLIENT and LocalPlayer():SteamID() ~= "STEAM_0:1:55598730" then return end
-- if SERVER then
-- 	include("igs/config_sv.lua")
-- end

-- rep(print,10,"\n\n\n")

-- timer.Simple(SERVER and 0 or 2,function()
-- 	-- PrintTable(IGS.CHARTS)
-- 	-- print(CLIENT and "CLIENT" or "SERVER")

-- 	IGS.CHARTS.Update(function()
-- 		rep(print,10,"\n")
-- 		-- PrintTable(IGS.CHARTS)
-- 		-- print(CLIENT and "CLIENT" or "SERVER")
-- 	end)
-- end)
