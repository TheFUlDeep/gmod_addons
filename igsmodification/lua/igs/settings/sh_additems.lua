--[[-------------------------------------------------------------------------
	Обязательные методы:
		:SetPrice()
		:SetTerm()
		:SetDescription()

	Популярные:
		:SetStackable()
		:SetCategory()
		:SetIcon()
		:SetOnActivate()
		:SetNetworked()
		:SetHighlightColor()
		:SetDiscountedFrom()

	Подробнее и все остальные:
		gm-donate.ru/docs

	Бесплатная быстрая помощь и настройка:
		gm-donate.ru/support
---------------------------------------------------------------------------]]


/****************************************************************************
	Разрешаем покупать отмычку только донатерам (DarkRP)
	Доступ навсегда за 1 рубль
	https://img.qweqwe.ovh/1493244432112.png -- частичное объяснение
****************************************************************************/

-- IGS("Отмычка", "otmichka") -- второй параметр ДОЛЖЕН!!!!!!!! быть уникальным(Не повторяться с другими итемамы!) и на латиннице
-- 	-- 1 рубль
-- 	:SetPrice(1)
--
-- 	-- 0 - одноразовое (Т.е. купил, выполнилось OnActivate и забыл. Полезно для валюты)
-- 	-- 30 - месяц, 7 - неделя и т.д. :SetPerma() вместо :SetTerm() чтобы услуга была навсегда
-- 	:SetTerm(30)
--
-- 	-- тут пишем реальный КЛАСС ЭНТИТИ, который указан в shipments.lua
-- 	:SetDarkRPItem("lockpick")
--
-- 	-- ОПИСАНИЕ отобразится в подробностях донат итема
-- 	:SetDescription("Разрешает вам покупать отмычку")
--
-- 	-- КАТЕГОРИЯ в магазине
-- 	:SetCategory("Оружие")
--
-- 	-- квадратная ИКОНКА (Не обязательно). Отобразится на главной странице. Может быть с прозрачностью
-- 	:SetIcon("http://i.imgur.com/4zfVs9s.png")
--
-- 	-- БАННЕР 1000х400 (Не обязательно). Отобразится в подробностях итема
-- 	:SetImage("http://i.imgur.com/RqsP5nP.png")

 IGS("81-717.6 Pass Moscow Brand", "1")
 	:SetPrice(15)
	:SetPerma()
	--[[:SetCanActivate(function(pl, global, invDbID)
		return "Скины активировать нельзя. Достаточно хранить их в инвентаре"
	end)]]
 	:SetDescription("Разрешает использовать скин салона московского бренда на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Moscow Brand]]")
 	:SetCategory("Скины на составы")
 	--:SetIcon("https://steamuserimages-a.akamaihd.net/ugc/966473786649407360/9F100E008C88850906EFA211B385FD448DFE2D9B/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true")
-- 	-- БАННЕР 1000х400 (Не обязательно). Отобразится в подробностях итема
-- 	:SetImage("http://i.imgur.com/RqsP5nP.png")


 IGS("81-717.6 Train Moscow Brand", "2")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова московского бренда на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Moscow Brand]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-717.6 Train Кузьма Минин", "3")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Кузьма Минин на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Кузьма Минин]]")
 	:SetCategory("Скины на составы")
	
 --IGS("81-717.6 Pass Кузьма Минин", "4")
 	--:SetPrice(15)
	--:SetPerma()
 	--:SetDescription("Разрешает использовать скин салона Кузьма Минин на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Кузьма Минин]]")
 	--:SetCategory("Скины на составы")
	
	
	
 IGS("81-717.6 Train 81-717.2k", "5")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова 81-717.2k на составе 81-717.6\n[[gmod_subway_81-717_6 Texture 81-717.2k]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-717.6 Pass 81-717.2k", "6")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона 81-717.2k на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture 81-717.2k]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-702 (Д) Train Blue", "7")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Blue на составе 81-702\n[[gmod_subway_81-702 Texture Blue]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-702 (Д) Train Green", "8")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Green на составе 81-702\n[[gmod_subway_81-702 Texture Green]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-702 (Д) Train Д-806 (путеизмеритель)", "9")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Д-806 (путеизмеритель) на составе 81-702\n[[gmod_subway_81-702 Texture Д-806 (путеизмеритель)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-702 (Д) Train Izmailo [TCH-3]", "10")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Izmailo [TCH-3] на составе 81-702\n[[gmod_subway_81-702 Texture Izmailo [TCH-3]]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-703 (Е) Train Line 1 (Blue)", "11")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 1 (Blue) на составе 81-703\n[[gmod_subway_81-703 Texture Line 1 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-703 (Е) Train Line 2 (Green)", "12")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 2 (Green) на составе 81-703\n[[gmod_subway_81-703 Texture Line 2 (Green)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-703 (Е) Train Line 3 (Green)", "13")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 3 (Green) на составе 81-703\n[[gmod_subway_81-703 Texture Line 3 (Green)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-703 (Е) Train Line 4 (Blue)", "14")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 4 (Blue) на составе 81-703\n[[gmod_subway_81-703 Texture Line 4 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-703 (Е) Train SPB", "15")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова SPB на составе 81-703\n[[gmod_subway_81-703 Texture SPB]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-707 (Еж) Train Defectoscope 1", "16")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Defectoscope 1 на составе 81-707\n[[gmod_subway_ezh Texture Defectoscope 1]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Defectoscope 2", "17")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Defectoscope 2 на составе 81-707\n[[gmod_subway_ezh Texture Defectoscope 2]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Ezh-6 (81-712)", "18")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Ezh-6 (81-712) на составе 81-707\n[[gmod_subway_ezh Texture Ezh-6 (81-712)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Line 4 - Izmaylovo", "19")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 4 - Izmaylovo на составе 81-707\n[[gmod_subway_ezh Texture Line 4 - Izmaylovo]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Line1 (Blue)", "20")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line1 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line1 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Line2 (Green)", "21")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line2 (Green) на составе 81-707\n[[gmod_subway_ezh Texture Line2 (Green)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Line3 (Blue)", "22")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line3 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line3 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Line4 (Blue)", "23")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line4 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line4 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Planernoe", "24")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Planernoe на составе 81-707\n[[gmod_subway_ezh Texture Planernoe]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Train Very old", "25")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Very old на составе 81-707\n[[gmod_subway_ezh Texture Very old]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-707 (Еж) Pass Blue interior 1970", "26")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Blue interior 1970 на составе 81-707\n[[gmod_subway_ezh PassTexture Blue interior 1970]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Pass Dark Wood 1990", "27")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Dark Wood 1990 на составе 81-707\n[[gmod_subway_ezh PassTexture Dark Wood 1990]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Pass Green interior 1971", "28")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Green interior 1971 на составе 81-707\n[[gmod_subway_ezh PassTexture Green interior 1971]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Pass White plastic 1972", "29")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона White plastic 1972 на составе 81-707\n[[gmod_subway_ezh PassTexture White plastic 1972]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Pass Wood interior 1980", "30")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior 1980 на составе 81-707\n[[gmod_subway_ezh PassTexture Wood interior 1980]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-707 (Еж) Pass Wood interior classic", "31")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior classic на составе 81-707\n[[gmod_subway_ezh PassTexture Wood interior classic]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-710 (Еж3) Train Budapest Ev (Dark Blue)", "32") --TODO проверить, есть ли пробел
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Budapest Ev (Dark Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Budapest Ev (Dark Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Budapest Ev3 (Blue)", "33")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Budapest Ev3 (Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Budapest Ev3 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Echs (81-709)", "34")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Echs (81-709) на составе 81-710\n[[gmod_subway_ezh3 Texture Echs (81-709)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Line 7 (Blue)", "35")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Blue)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Line 7 (Dark)", "36")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Dark) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Dark)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Line 7 (Green)", "37")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Green) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Green)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train Line 1 (Green)", "38")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 1 (Green) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 1 (Green)]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Train New Year", "39")
 	:SetPrice(20)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова New Year на составе 81-710\n[[gmod_subway_ezh3 Texture New Year]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-710 (Еж3) Pass Dark-Wood interior", "40")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Dark-Wood interior на составе 81-710\n[[gmod_subway_ezh3 PassTexture Dark-Wood interior]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Pass White plastic", "41")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона White plastic на составе 81-710\n[[gmod_subway_ezh3 PassTexture White plastic]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Pass Wood 1980", "42")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood 1980 на составе 81-710\n[[gmod_subway_ezh3 PassTexture Wood 1980]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Pass Wood KVR", "43")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood KVR на составе 81-710\n[[gmod_subway_ezh3 PassTexture Wood KVR]]")
 	:SetCategory("Скины на составы")
	
	
	
 IGS("81-710 (Еж3) Cab Classic", "44")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Classic на составе 81-710\n[[gmod_subway_ezh3 CabTexture Classic]]")
 	:SetCategory("Скины на составы")
	
 IGS("81-710 (Еж3) Cab Wood", "45")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Wood на составе 81-710\n[[gmod_subway_ezh3 CabTexture Wood]]")
 	:SetCategory("Скины на составы")
	


 --IGS("81-717 МСК Train MosBrend (blue doors)", "999")
 --	:SetPrice(15)
--	:SetPerma()
 	--:SetDescription("Разрешает использовать скин кузова MosBrend (blue doors) на составе 81-717 МСК (кастом)\n[[gmod_subway_81-717_mvm_custom Texture MosBrend (blue doors)]]")
 	--:SetCategory("Скины на составы")


/****************************************************************************
	Игровая валюта для DarkRP
	Срок нет смысла указывать
	Для удобства суммы объединены в группу (Не категорию)
****************************************************************************/
-- local GROUP = IGS.NewGroup("Игровая валюта")
--
-- GROUP:AddItem(
-- 	IGS("100 тысяч", "100k_deneg"):SetDarkRPMoney(100000)
-- 	:SetPrice(200) -- руб
-- )
--
-- GROUP:AddItem(
-- 	IGS("500 тысяч", "500k_deneg"):SetDarkRPMoney(500000)
-- 	:SetPrice(450) -- руб
-- )



/****************************************************************************
	Донат группы ULX
	Обратите внимание, иконка и баннер здесь не указаны
	Так делать можно, они просто не будут отображены
****************************************************************************/
-- IGS("VIP на месяц", "vip_na_mesyac"):SetULXGroup("vip")
-- 	:SetPrice(150)
-- 	:SetTerm(30) -- 30 дней
-- 	:SetCategory("Группы")
-- 	:SetDescription("С этой покупкой вы станете офигенными, потому что в ней воооот такая куча крутых возможностей")

-- IGS("PREMIUM навсегда", "premium_navsegda"):SetULXGroup("premium")
-- 	:SetPrice(400)
-- 	:SetPerma() -- навсегда
-- 	:SetCategory("Группы")
-- 	:SetDescription("А с этой покупкой еще офигеннее, чем с покупкой VIP")

-- IGS("Тестовая операторка", "demo_operator"):SetULXGroup("operator")
-- 	:SetPrice(30)
-- 	:SetTerm(0) -- одноразовое. Можно ввобще убрать строку
-- 	:SetCategory("Группы")
-- 	:SetDescription("С этой покупкой вы можете попробовать себя в роли оператора. Права исчезнут после перезахода")


/****************************************************************************
	Донат группы FAdmin
	Здесь цена указана третьим аргументом, вместо :SetPrice
	Так делать не обязательно, это лишь микровозможность
****************************************************************************/
-- IGS("Фадмин VIP","fa_vip_30d",228):SetFAdminGroup("vip")
-- 	:SetTerm(30)
-- 	:SetDescription("Повысит вас до випа на 30 дней")



/****************************************************************************
	Продажа поинтов для Поинтшоп 2
	https://www.gmodstore.com/scripts/view/596
****************************************************************************/
-- IGS("100 донат поинтов","100_points_don"):SetPremiumPoints(100) -- дон поинты
-- 	:SetPrice(100) -- руб
--
-- IGS("1000 обычных поинтов","1000_points"):SetPoints(1000) -- обычные поинты
-- 	:SetPrice(100)



/****************************************************************************
	Продажа уровней и опыта для Leveling System
	https://github.com/vrondakis/Leveling-System
****************************************************************************/
-- IGS("5 уровней","lvl_5"):SetLevels(5)
-- 	:SetPrice(25) -- руб

-- IGS("100 опыта","exp_100"):SetEXP(100)
-- 	:SetPrice(20)



/****************************************************************************
	Доступ к энтити, оружию и машинам через спавнменю
****************************************************************************/
--[[IGS("Арбалет с HL", "wep_arbalet"):SetWeapon("weapon_crossbow")
	:SetPrice(100)
	:SetTerm(30)
	:SetDescription("Разрешает спавнить Арбалет через спавн меню в любое время")
	:SetIcon("models/weapons/w_crossbow.mdl", true) -- true значит, что указана моделька, а не ссылка

IGS("Джип с HL", "veh_jeep"):SetVehicle("Jeep")
	:SetPrice(100500)
	:SetTerm(30)
	:SetDescription("Разрешает спавнить джип с халвы через спавн меню в любое время")]]



/****************************************************************************
	Использование инструментов
****************************************************************************/
--[[IGS("Доступ к Веревке","verevka_na_mesyac"):SetTool("rope")
	:SetPrice(50)
	:SetTerm(30) -- 30 дней
	:SetDescription("Для соединения двух объектов или написания матов на стенах :)")

IGS("Доступ к Лебёдке","lebedka_navsegda"):SetTool("winch")
	:SetPrice(100)
	:SetPerma()
	:SetDescription("Лебёдка это веревка, способная становиться короче или длиннее")]]
