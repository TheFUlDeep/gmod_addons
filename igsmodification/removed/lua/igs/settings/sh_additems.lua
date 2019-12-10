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

 IGS("Все скины на месяц", "9999")
 	:SetPrice(100)
	:SetTerm(30)
	--:SetStackable(false) --это не нужно, так как инвентаря нет, и все айтемы можно купить только 1 раз
 	:SetDescription("Разрешает использовать все скины на месяц")
 	:SetCategory("Скины на все составы")

 IGS("81-717.6 Pass Moscow Brand", "1")
 	:SetPrice(15)
	:SetPerma()
	--[[:SetCanActivate(function(pl, global, invDbID)
		return "Скины активировать нельзя. Достаточно хранить их в инвентаре"
	end)]]
 	:SetDescription("Разрешает использовать скин салона московского бренда на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Moscow Brand]]")
 	:SetCategory("Скины на 81-717.6")
 	--:SetIcon("https://steamuserimages-a.akamaihd.net/ugc/966473786649407360/9F100E008C88850906EFA211B385FD448DFE2D9B/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true")
-- 	-- БАННЕР 1000х400 (Не обязательно). Отобразится в подробностях итема
-- 	:SetImage("http://i.imgur.com/RqsP5nP.png")


 IGS("81-717.6 Train Moscow Brand", "2")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова московского бренда на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Moscow Brand]]")
 	:SetCategory("Скины на 81-717.6")
	
	
	
 IGS("81-717.6 Train Кузьма Минин", "3")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Кузьма Минин на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Кузьма Минин]]")
 	:SetCategory("Скины на 81-717.6")
		
	
	
 IGS("81-717.6 Train 81-717.2k", "5")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова 81-717.2k на составе 81-717.6\n[[gmod_subway_81-717_6 Texture 81-717.2k]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717.6 Pass 81-717.2k", "6")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона 81-717.2k на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture 81-717.2k]]")
 	:SetCategory("Скины на 81-717.6")
	
	
	
 IGS("81-702 (Д) Train Blue", "7")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Blue на составе 81-702\n[[gmod_subway_81-702 Texture Blue]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
 IGS("81-702 (Д) Train Green", "8")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Green на составе 81-702\n[[gmod_subway_81-702 Texture Green]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
 IGS("81-702 (Д) Train Д-806 (путеизмеритель)", "9")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Д-806 (путеизмеритель) на составе 81-702\n[[gmod_subway_81-702 Texture Д-806 (путеизмеритель)]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
 IGS("81-702 (Д) Train Izmailo [TCH-3]", "10")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Izmailo [TCH-3] на составе 81-702\n[[gmod_subway_81-702 Texture Izmailo [TCH-3]]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
	
	
 IGS("81-703 (Е) Train Line 1 (Blue)", "11")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 1 (Blue) на составе 81-703\n[[gmod_subway_81-703 Texture Line 1 (Blue)]]")
 	:SetCategory("Скины на 81-703 (Е)")
	
 IGS("81-703 (Е) Train Line 2 (Green)", "12")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 2 (Green) на составе 81-703\n[[gmod_subway_81-703 Texture Line 2 (Green)]]")
 	:SetCategory("Скины на 81-703 (Е)")
	
 IGS("81-703 (Е) Train Line 3 (Green)", "13")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 3 (Green) на составе 81-703\n[[gmod_subway_81-703 Texture Line 3 (Green)]]")
 	:SetCategory("Скины на 81-703 (Е)")
	
 IGS("81-703 (Е) Train Line 4 (Blue)", "14")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 4 (Blue) на составе 81-703\n[[gmod_subway_81-703 Texture Line 4 (Blue)]]")
 	:SetCategory("Скины на 81-703 (Е)")
	
 IGS("81-703 (Е) Train SPB", "15")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова SPB на составе 81-703\n[[gmod_subway_81-703 Texture SPB]]")
 	:SetCategory("Скины на 81-703 (Е)")
	
	
	
 IGS("81-707 (Еж) Train Defectoscope 1", "16")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Defectoscope 1 на составе 81-707\n[[gmod_subway_ezh Texture Defectoscope 1]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Defectoscope 2", "17")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Defectoscope 2 на составе 81-707\n[[gmod_subway_ezh Texture Defectoscope 2]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Ezh-6 (81-712)", "18")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Ezh-6 (81-712) на составе 81-707\n[[gmod_subway_ezh Texture Ezh-6 (81-712)]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Line 4 - Izmaylovo", "19")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 4 - Izmaylovo на составе 81-707\n[[gmod_subway_ezh Texture Line 4 - Izmaylovo]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Line1 (Blue)", "20")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line1 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line1 (Blue)]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Line2 (Green)", "21")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line2 (Green) на составе 81-707\n[[gmod_subway_ezh Texture Line2 (Green)]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Line3 (Blue)", "22")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line3 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line3 (Blue)]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Line4 (Blue)", "23")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line4 (Blue) на составе 81-707\n[[gmod_subway_ezh Texture Line4 (Blue)]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Planernoe", "24")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Planernoe на составе 81-707\n[[gmod_subway_ezh Texture Planernoe]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Very old", "25")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Very old на составе 81-707\n[[gmod_subway_ezh Texture Very old]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
	
	
 IGS("81-707 (Еж) Pass Blue interior 1970", "26")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Blue interior 1970 на составе 81-707\n[[gmod_subway_ezh PassTexture Blue interior 1970]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Pass Dark Wood 1990", "27")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Dark Wood 1990 на составе 81-707\n[[gmod_subway_ezh PassTexture Dark Wood 1990]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Pass Green interior 1971", "28")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Green interior 1971 на составе 81-707\n[[gmod_subway_ezh PassTexture Green interior 1971]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Pass White plastic 1972", "29")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона White plastic 1972 на составе 81-707\n[[gmod_subway_ezh PassTexture White plastic 1972]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Pass Wood interior 1980", "30")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior 1980 на составе 81-707\n[[gmod_subway_ezh PassTexture Wood interior 1980]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Pass Wood interior classic", "31")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior classic на составе 81-707\n[[gmod_subway_ezh PassTexture Wood interior classic]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
	
	
 IGS("81-710 (Еж3) Train Budapest Ev (Dark Blue)", "32")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Budapest Ev (Dark Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Budapest Ev (Dark Blue)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Budapest Ev3 (Blue)", "33")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Budapest Ev3 (Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Budapest Ev3 (Blue)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Echs (81-709)", "34")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Echs (81-709) на составе 81-710\n[[gmod_subway_ezh3 Texture Echs (81-709)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Line 7 (Blue)", "35")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Blue) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Blue)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Line 7 (Dark)", "36")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Dark) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Dark)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Line 7 (Green)", "37")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 7 (Green) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 7 (Green)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train Line 1 (Green)", "38")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 1 (Green) на составе 81-710\n[[gmod_subway_ezh3 Texture Line 1 (Green)]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Train New Year", "39")
 	:SetPrice(20)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова New Year на составе 81-710\n[[gmod_subway_ezh3 Texture New Year]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
	
	
 IGS("81-710 (Еж3) Pass Dark-Wood interior", "40")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Dark-Wood interior на составе 81-710\n[[gmod_subway_ezh3 PassTexture Dark-Wood interior]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Pass White plastic", "41")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона White plastic на составе 81-710\n[[gmod_subway_ezh3 PassTexture White plastic]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Pass Wood 1980", "42")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood 1980 на составе 81-710\n[[gmod_subway_ezh3 PassTexture Wood 1980]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Pass Wood KVR", "43")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood KVR на составе 81-710\n[[gmod_subway_ezh3 PassTexture Wood KVR]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
	
	
 IGS("81-710 (Еж3) Cab Classic", "44")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Classic на составе 81-710\n[[gmod_subway_ezh3 CabTexture Classic]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
 IGS("81-710 (Еж3) Cab Wood", "45")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Wood на составе 81-710\n[[gmod_subway_ezh3 CabTexture Wood]]")
 	:SetCategory("Скины на 81-710 (Еж3")
	
	
	
 IGS("81-717 МСК (номерной) Train 81-570", "46")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова 81-570 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture 81-570]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Ахегао", "47")
 	:SetPrice(20)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Ахегао на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Admin]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Belarus Bank", "48")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Belarus Bank на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Belarus Bank]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Condensed milk", "49")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Condensed milk на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Condensed milk]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Dark Blue", "50")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Dark Blue на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Dark Blue]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Kyiv", "51")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Kyiv на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Kyiv]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train LGBT", "52")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова LGBT на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture LGBT]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Line 1", "53")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 1 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Line 1]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Line 5", "54")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Line 5 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Line 5]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Minsk", "55")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Minsk на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Minsk]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train MosBrend (blue doors)", "56")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова MosBrend (blue doors) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture MosBrend (blue doors)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train MosBrend (yellow doors)", "57")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова MosBrend (yellow doors) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture MosBrend (yellow doors)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Nizniy Novgotod", "58")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Nizniy Novgotod на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Nizniy Novgotod]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Novosibirsk", "59")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Novosibirsk на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Novosibirsk]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Prague", "60")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Prague на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Prague]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Reading Moscow (Line 6)", "61")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Reading Moscow (Line 6) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Reading Moscow (Line 6)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Red Arrow [New]", "62")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Red Arrow [New] на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Red Arrow [New]]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Samara", "63")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Samara на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Samara]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Sofia OLD", "64")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Sofia OLD на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Sofia OLD]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train uklon", "65")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова uklon на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture uklon]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Красная Стрела (75 лет)", "66")
 	:SetPrice(20)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Красная Стрела (75 лет) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Красная Стрела (75 лет)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Пришелец", "67")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Пришелец на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Пришелец]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Синергия", "68")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Синергия на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Синергия]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train ЭС-720", "69")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова ЭС-720 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture ЭС-720]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train ЭС-720 (настоящий цвет)", "70")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова ЭС-720 (настоящий цвет) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture ЭС-720 (настоящий цвет)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
	
	
 IGS("81-717 МСК (номерной) Pass Blue interior", "71")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Blue interior на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Blue interior]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass Light-Wood interior", "72")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Light-Wood interior на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Light-Wood interior]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass MosBrend interior", "73")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона MosBrend interior на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture MosBrend interior]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass MosBrend interior 2", "74")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона MosBrend interior 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture MosBrend interior 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass White interior", "75")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона White interior на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture White interior]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass Wood interior 1", "76")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior 1 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Wood interior 1]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass Wood interior 2", "77")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Wood interior 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass Wood interior 3", "78")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood interior 3 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Wood interior 3]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Pass Красная Стрела (салон)", "79")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Красная Стрела (салон) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom PassTexture Красная Стрела (салон)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
	
	
 IGS("81-717 МСК (номерной) Cab MosBrend + Blue body", "80")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины MosBrend + Blue body на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture MosBrend + Blue body]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab MosBrend + Yellow body", "81")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины MosBrend + Yellow body на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture MosBrend + Yellow body]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab MosBrend New Metallic", "82")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины MosBrend New Metallic на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture MosBrend New Metallic]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab MosBrend New Yellow", "83")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины MosBrend New Yellow на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture MosBrend New Yellow]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Variant 1", "84")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Variant 1 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Variant 1]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Variant 2", "85")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Variant 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Variant 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Variant 3", "86")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Variant 3 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Variant 3]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Variant 4", "87")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Variant 4 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Variant 4]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
	
	
 IGS("81-717.6 Train Default", "88")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Default на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Default]]")
 	:SetCategory("Скины на 81-717.6")
	
	
	
 IGS("81-717.6 Pass Default", "89")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Default на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Default]]")
 	:SetCategory("Скины на 81-717.6")
	
	
	
 IGS("81-718 (ТИСУ) Train Default", "90")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Default на составе 81-718\n[[gmod_subway_81-718 Texture Default]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Train Old", "91")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Old на составе 81-718\n[[gmod_subway_81-718 Texture Old]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Train Tashkent Blue", "92")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Tashkent Blue на составе 81-718\n[[gmod_subway_81-718 Texture Tashkent Blue]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Train Tashkent Green", "93")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Tashkent Green на составе 81-718\n[[gmod_subway_81-718 Texture Tashkent Green]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Train Tashkent Green with line", "94")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Tashkent Green with line на составе 81-718\n[[gmod_subway_81-718 Texture Tashkent Green with line]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
	
	
 IGS("81-718 (ТИСУ) Pass Blue plastic", "95")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Blue plastic на составе 81-718\n[[gmod_subway_81-718 PassTexture Blue plastic]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Pass Dark Wood", "96")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Dark Wood на составе 81-718\n[[gmod_subway_81-718 PassTexture Dark Wood]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-718 (ТИСУ) Pass Wood", "97")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Wood на составе 81-718\n[[gmod_subway_81-718 PassTexture Wood]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
	
	
 IGS("81-722 (Юбилейный) Train Default", "98")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Default на составе 81-722\n[[gmod_subway_81-722 Texture Default]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Train Moscow 2019 Skin (81-765.4)", "99")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Moscow 2019 Skin (81-765.4) на составе 81-722\n[[gmod_subway_81-722 Texture Moscow 2019 Skin (81-765.4)]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Train Moscow Skin (81-765)", "100")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Moscow Skin (81-765) на составе 81-722\n[[gmod_subway_81-722 Texture Moscow Skin (81-765)]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Train NeVa Skin (81-556)", "101")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова NeVa Skin (81-556) на составе 81-722\n[[gmod_subway_81-722 Texture NeVa Skin (81-556)]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Train NeVa Skin (81-556.2)", "102")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова NeVa Skin (81-556.2) на составе 81-722\n[[gmod_subway_81-722 Texture NeVa Skin (81-556.2)]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Train Original", "103")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Original на составе 81-722\n[[gmod_subway_81-722 Texture Original]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
	
	
 IGS("81-722 (Юбилейный) Pass Original", "104")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Original на составе 81-722\n[[gmod_subway_81-722 PassTexture Original]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Pass Default", "105")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Default на составе 81-722\n[[gmod_subway_81-722 PassTexture Default]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Pass Moscow 2019 Skin (81-765.4) Interior", "106")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Moscow 2019 Skin (81-765.4) Interior на составе 81-722\n[[gmod_subway_81-722 PassTexture Moscow 2019 Skin (81-765.4) Interior]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Pass Moscow Skin (81-765) Interior", "107")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Moscow Skin (81-765) Interior на составе 81-722\n[[gmod_subway_81-722 PassTexture Moscow Skin (81-765) Interior]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Pass NeVa Skin (81-556) Interior", "108")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона NeVa Skin (81-556) Interior на составе 81-722\n[[gmod_subway_81-722 PassTexture NeVa Skin (81-556) Interior]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Pass NeVa Skin (81-556.2) Interior", "109")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона NeVa Skin (81-556.2) Interior на составе 81-722\n[[gmod_subway_81-722 PassTexture NeVa Skin (81-556.2) Interior]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
	
	
 IGS("81-722 (Юбилейный) Cab Default", "110")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Default на составе 81-722\n[[gmod_subway_81-722 CabTexture Default]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Cab Original", "111")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Original на составе 81-722\n[[gmod_subway_81-722 CabTexture Original]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Cab Moscow Skin (81-765) Cabin", "112")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Moscow Skin (81-765) Cabin на составе 81-722\n[[gmod_subway_81-722 CabTexture Moscow Skin (81-765) Cabin]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
 IGS("81-722 (Юбилейный) Cab NeVa Skin (81-556) Cabin", "113")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины NeVa Skin (81-556) Cabin на составе 81-722\n[[gmod_subway_81-722 CabTexture NeVa Skin (81-556) Cabin]]")
 	:SetCategory("Скины на 81-722 (Юбилейный)")
	
--81-720 (Яуза)
 IGS("81-720 (Яуза) Train Default", "120")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Default на составе 81-720\n[[gmod_subway_81-720 Texture Default]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train Default", "121")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Default на составе 81-720\n[[gmod_subway_81-720 PassTexture Default]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train 81-740 Skin", "122")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова 81-740 Skin на составе 81-720\n[[gmod_subway_81-720 Texture 81-740 Skin]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train 81-740 Interior", "123")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Train 81-740 Interior на составе 81-720\n[[gmod_subway_81-720 PassTexture 81-740 Interior]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train Northbound Downtown Railways - Black", "124")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Northbound Downtown Railways - Black на составе 81-720\n[[gmod_subway_81-720 Texture Northbound Downtown Railways - Black]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train Northbound Downtown Railways", "125")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Northbound Downtown Railways - Black на составе 81-720\n[[gmod_subway_81-720 PassTexture Northbound Downtown Railways]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
 IGS("81-720 (Яуза) Train Northbound Downtown Railways - Grey", "126")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Northbound Downtown Railways - Grey на составе 81-720\n[[gmod_subway_81-720 Texture Northbound Downtown Railways - Grey]]")
 	:SetCategory("Скины на 81-720 (Яуза)")
	
	
	
 IGS("81-502 (Ема) Train Default", "127")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Default на составе 81-502\n[[gmod_subway_81-502 Texture Default]]")
 	:SetCategory("Скины на 81-502 (Ема)")
	
 IGS("81-502 (Ема) Pass Default", "128")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Default на составе 81-502\n[[gmod_subway_81-502 PassTexture Default]]")
 	:SetCategory("Скины на 81-502 (Ема)")
	
 IGS("81-502 (Ема) Cab Default", "129")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Default на составе 81-502\n[[gmod_subway_81-502 CabTexture Default]]")
 	:SetCategory("Скины на 81-502 (Ема)")
	
 IGS("81-717 МСК (номерной) Train U Got That", "130")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова U Got That на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture U Got That]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-702 (Д) Train Kiev", "131")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Kiev на составе 81-702\n[[gmod_subway_81-702 Texture Kiev]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
 IGS("81-707 (Еж) Train Lakden fun skin", "132")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Lakden fun skin на составе 81-707\n[[gmod_subway_ezh Texture Lakden fun skin]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-707 (Еж) Train Kiev", "133")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Kiev на составе 81-707\n[[gmod_subway_ezh Texture Kiev]]")
 	:SetCategory("Скины на 81-707 (Еж)")
	
 IGS("81-717 МСК (номерной) Cab Pult (№725)", "134")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Pult (№725) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Pult (№725)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Pult (№725) Variant 2", "135")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Pult (№725) Variant 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Pult (№725) Variant 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Pult (№725) Variant 3", "136")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Pult (№725) Variant 3 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Pult (№725) Variant 3]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Pult Blue", "137")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Pult Blue на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Pult Blue]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Xray (ostorojno bla)", "138")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Xray (ostorojno bla) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Xray (ostorojno bla)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Pult Old", "139")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Pult Old на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Pult Old]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Metal-Pult (OLD)", "140")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Metal-Pult (OLD) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Metal-Pult (OLD)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Metal-Pult (NEW)", "141")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Metal-Pult (NEW) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Metal-Pult (NEW)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Kolhoz 1", "142")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Kolhoz 1 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Kolhoz 1]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Cab Kolhoz 2", "143")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кабины Kolhoz 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom CabTexture Kolhoz 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train RGW", "144")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова RGW на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture RGW]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Tashkent", "145")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Tashkent на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Tashkent]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Kharkov Biscuit", "146")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Kharkov Biscuit на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Kharkov Biscuit]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Крюковец (Харьков)", "147")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Крюковец (Харьков) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Крюковец (Харьков)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Крюковец (Киев)", "148")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Крюковец (Киев) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Крюковец (Киев)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Brand (Kajdiy Den')", "149")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Brand (Kajdiy Den') на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Brand (Kajdiy Den')]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717.6 Train 81-717.6_1945", "150")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова 81-717.6_1945 на составе 81-717.6\n[[gmod_subway_81-717_6 Texture 81-717.6_1945]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717.6 Pass 81-717.6_1945", "151")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона 81-717.6_1945 на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture 81-717.6_1945]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717 МСК (номерной) Train Нижний Новгород (герб)", "152")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новгород (герб) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Нижний Новгород (герб)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Нижний Новгород (старый)", "153")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новгород (старый) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Нижний Новгород (старый)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Нижний Новгород (ПИОНЕР)", "154")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новгород (ПИОНЕР) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Нижний Новгород (ПИОНЕР)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Нижний Новгород (новый)", "155")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новгород (новый) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Нижний Новгород (новый)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717.6 Train Нижний Новогород (К.Минин)", "156")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новогород (К.Минин) на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Нижний Новогород (К.Минин)]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717.6 Pass Нижний Новогород (К.Минин)", "157")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Нижний Новогород (К.Минин) на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Нижний Новогород (К.Минин)]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717.6 Train Нижний Новогород (герб)", "158")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижний Новогород (герб) на составе 81-717.6\n[[gmod_subway_81-717_6 Texture Нижний Новогород (герб)]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717.6 Pass Нижний Новогород (герб)", "159")
 	:SetPrice(5)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин салона Нижний Новогород (герб) на составе 81-717.6\n[[gmod_subway_81-717_6 PassTexture Нижний Новогород (герб)]]")
 	:SetCategory("Скины на 81-717.6")
	
 IGS("81-717 МСК (номерной) Train Народный ополченец", "160")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Народный ополченец на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Народный ополченец]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Згущёнка", "161")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Згущёнка на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Згущёнка]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Самарский", "162")
 	:SetPrice(10)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Самарский на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Самарский]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train София (старый)", "163")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова София на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture София (старый)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-718 (ТИСУ) Train LGBT", "164")
 	:SetPrice(0)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова LGBT на составе 81-718\n[[gmod_subway_81-718 Texture LGBT]]")
 	:SetCategory("Скины на 81-718 (ТИСУ)")
	
 IGS("81-717 МСК (номерной) Train Blue Toshkent", "165")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Blue Toshkent на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Blue Toshkent]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Toshkent", "166")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Toshkent на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Toshkent]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Toshkent 2", "167")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Toshkent 2 на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Toshkent 2]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Красная Стрела (Новый тип)", "168")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Красная Стрела (Новый тип) на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Красная Стрела (Новый тип)]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-717 МСК (номерной) Train Нижнегородский", "169")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова Нижнегородский на составе 81-717 mvm\n[[gmod_subway_81-717_mvm_custom Texture Нижнегородский]]")
 	:SetCategory("Скины на 81-717 МСК (номерной)")
	
 IGS("81-702 (Д) Train LGBT", "170")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова LGBT на составе 81-702\n[[gmod_subway_81-702 Texture LGBT]]")
 	:SetCategory("Скины на 81-702 (Д)")
	
 IGS("81-710 (Еж3) Train kyev", "171")
 	:SetPrice(15)
	:SetPerma()
 	:SetDescription("Разрешает использовать скин кузова kyev на составе 81-710\n[[gmod_subway_ezh3 Texture kyev]]")
 	:SetCategory("Скины на 81-710 (Еж3")



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
