--[[-------------------------------------------------------------------------
Набросок фрейма: https://pp.vk.me/c638927/v638927381/2115a/mMr6sQsbWlw.jpg
---------------------------------------------------------------------------]]

local function addTab(activity,sidebar)
	local bg = sidebar:AddPage("Описания чартов")

	local categs = ui.Create("panels_layout_list",bg) -- center panel
	--categs:DisableAlignment(true)
	categs:SetWide(activity:GetWide())
	categs:Dock(FILL)

	for _,CHART in pairs(IGS.CHARTS.GetMap()) do
		categs:Add( ui.Create("ui_table",function(pnl)
			pnl:SetSize(280,215)
			pnl:SetTitle(CHART:Name())
			pnl:AddColumn("#",20) -- место

			for _,column in ipairs(CHART:Columns()) do
				pnl:AddColumn(column)
			end

			for i,cells in ipairs(CHART:Data()) do
				pnl:AddLine(i,unpack(cells))
			end
		end),"Информация обновляется при рестарте сервера").title:SetTextColor(IGS.col.TEXT_HARD) -- http://joxi.ru/Y2LqqyBh5BODA6

		-- сетка элементов
		-- https://img.qweqwe.ovh/1487023074990.png
		IGS.AddTextBlock(bg.side, CHART:Name(), CHART:Description())
	end

	activity:AddTab("Чарты",bg,"materials/vgui/icons/fa32/bar-chart.png")
end


hook.Add("IGS.CatchActivities","charts",function(activity,sbar)
	if os.time() - IGS.CHARTS.LastUpdate >= 60 * 5 then -- обновлялись как минимум, 5 мин назад
		IGS.CHARTS.Update(function()
			if !IsValid(activity) then return end

			addTab(activity,sbar)
		end)
	else
		addTab(activity,sbar)
	end
end)

-- IGS.UI()