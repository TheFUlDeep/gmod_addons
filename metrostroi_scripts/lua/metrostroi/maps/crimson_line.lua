local Map = game.GetMap() or ""

if Map:find("gm_mus_crimson") and Map:find("tox") then
	Metrostroi.PlatformMap = "crimson"
	Metrostroi.CurrentMap = "gm_orange_crimson"
else
	return
end

Metrostroi.AddLastStationTex("702",501,"models/metrostroi_schemes/destination_table_black/label_aeroport")
Metrostroi.AddLastStationTex("702",503,"models/metrostroi_schemes/destination_table_black/label_metrobuliders")
Metrostroi.AddLastStationTex("702",506,"models/metrostroi_schemes/destination_table_black/label_kahovskaya")
Metrostroi.AddLastStationTex("710",501,"models/metrostroi_schemes/destination_table_white/label_aeroport")
Metrostroi.AddLastStationTex("710",503,"models/metrostroi_schemes/destination_table_white/label_metrobuliders")
Metrostroi.AddLastStationTex("710",506,"models/metrostroi_schemes/destination_table_white/label_kahovskaya")
Metrostroi.AddLastStationTex("717",501,"models/metrostroi_schemes/destination_table_white/label_aeroport")
Metrostroi.AddLastStationTex("717",503,"models/metrostroi_schemes/destination_table_white/label_metrobuliders")
Metrostroi.AddLastStationTex("717",506,"models/metrostroi_schemes/destination_table_white/label_kahovskaya")
Metrostroi.AddLastStationTex("720",501,"models/metrostroi_schemes/destination_table_white/label_aeroport")
Metrostroi.AddLastStationTex("720",503,"models/metrostroi_schemes/destination_table_white/label_metrobuliders")
Metrostroi.AddLastStationTex("720",506,"models/metrostroi_schemes/destination_table_white/label_kahovskaya")


Metrostroi.TickerAdverts = {
	"МЕТРОПОЛИТЕН ИМЕНИ ВЕЛИКОГО ГЛЕБА ГРОМЦЕВА ПРИГЛАШАЕТ НА РАБОТУ РЕАЛЬНЕ МАФЕНЕСТОВ, ДИСПЕЧЕРОВ И ТРАМВАЙНЫХ РЕВИЗОРОВ, ТЕЛЕФОН ДЛЯ СПРАВОК 8 (800) 555-35-35.",
	"УВАЖАЕМЫЕ ПАССАЖИРЫ! ДАННЫЙ ВАГОН НЕ ОБОРУДОВАН СИСТЕМОЙ КОНДИЦИОНИРОВАНИЯ ВОЗДУХА. ПРИ НЕОБХОДИМОСТИ ОТКРЫВАЙТЕ ФОРТОЧКИ.",
	"ЭЛЕКТРОДЕПО КРАСНАЯ ПРЕСНЯ ПРИГЛАШАЕТ НА СЕССИЮ РЕАЛЬНЕ МАФЕНЕСТОВ ОТ 14 ЛЕТ НА ОБУЧЕНИЕ ПРОФЕССИИ 'МАШИНИСТ ЭЛЕКТРОПОЕЗДА', СПРАВКИ НА СПЕЦИАЛИЗИРОВАННОЙ КАССЕ М.АЭРОПОРТ, ЗВАТЬ УЛЬТРАГЕЯ ЛОШАДЬ.",
	"В СВЯЗИ С ВВЕДЕНИЕМ ЭЛЕКТРОПОЕЗДОВ НОВОГО ПОКОЛЕНИЯ В ЭКСПЛУАТАЦИЮ, ЭЛЕКТРОДЕПО КРАСНАЯ ПРЕСНЯ ПРИГЛАШАЕТ НА РАБОТУ СЛЕСАРЕЙ ПОДВИЖНОГО СОСТАВА.",
	"О ПОДОЗРИТЕЛЬНЫХ ПРЕДМЕТАХ СООБЩАЙТЕ МАШИНИСТУ.",
	"ПОЕЗД СЛЕДУЕТ ДО СТАНЦИИ: ОРЕХОВО ТУПИК."}


Metrostroi.AddANSPAnnouncer("ASNP Boiko + Pyaseckaya",
	{
	asnp = true,

    click1 = {"subway_announcers/asnp/boiko_new/click1.mp3",0.5},
    click2 = {"subway_announcers/asnp/boiko_new/click2.mp3",0.3},
    click3 = {"subway_announcers/asnp/boiko_new/click3.mp3",0.3},


    announcer_ready = {"subway_announcers/asnp/boiko_new/announcer_ready.mp3",3.295479},
    doors_closing_m = {"subway_announcers/asnp/boiko_new/doors_closing.mp3",3.782542},
    deadlock_m = {"subway_announcers/asnp/boiko_new/spec_attention_deadlock.mp3",9.352500},
    exit_m = {"subway_announcers/asnp/boiko_new/spec_attention_exit.mp3",5.363563},
    handrails_m = {"subway_announcers/asnp/boiko_new/spec_attention_handrails.mp3",4.221854},
    last_m = {"subway_announcers/asnp/boiko_new/spec_attention_last.mp3",4.425625},
    objects_m = {"subway_announcers/asnp/boiko_new/spec_attention_objects.mp3",4.674771},
    politeness_m = {"subway_announcers/asnp/boiko_new/spec_attention_politeness.mp3",9.057104},
    things_m = {"subway_announcers/asnp/boiko_new/spec_attention_things.mp3",4.559146},
    train_depeat_m = {"subway_announcers/asnp/boiko_new/spec_attention_train_depeat.mp3",4.633417},
    train_stop_m = {"subway_announcers/asnp/boiko_new/spec_attention_train_stop.mp3",6.501979},
    station_m = {"subway_announcers/asnp/boiko_new/station.mp3",0.943438},
    train_goes_to_m = {"subway_announcers/asnp/boiko_new/train_goes_to.mp3",2.077708},
	
	
	doors_closing_f = {"subway_announcers/asnp/pyaseckaya/doors_closing.mp3",2.340813},
    deadlock_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_deadlock.mp3",10.501979},
    exit_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_exit.mp3",5.111104},
    handrails_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_handrails.mp3",4.675083},
    last_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_last.mp3",4.878542},
    objects_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_objects.mp3",5.323146},
    politeness_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_politeness.mp3",10.685375},
    things_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_things.mp3",5.144021},
    train_depeat_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_train_depeat.mp3",4.481875},
    train_stop_f = {"subway_announcers/asnp/pyaseckaya/spec_attention_train_stop.mp3",6.395313},
	
	aeroport_m = {"subway_announcers/asnp/boiko_new/neoorange/aeroport.mp3", 1},	
	pionerskaya_m = {"subway_announcers/asnp/boiko_new/neocrimson/pionerskaya_arr.mp3",4.5},
	pionerskaya_next_m = {"subway_announcers/asnp/boiko_new/neocrimson/pionerskaya_next.mp3",2},
	litievaya_m = {"subway_announcers/asnp/boiko_new/neocrimson/litievaya_arr.mp3",3},
	litievaya_next_m = {"subway_announcers/asnp/boiko_new/neocrimson/litievaya_next.mp3",1},
	metrostroiteley_m = {"subway_announcers/asnp/boiko_new/neocrimson/metrostroiteley_arr.mp3",3},
	metrostroiteley_next_m = {"subway_announcers/asnp/boiko_new/neocrimson/metrostroiteley_next.mp3",2},
	masterskaya_m = {"subway_announcers/boiko/crimson_tox/masterskaya.mp3", 1.179},
	kahovskaya_m = {"subway_announcers/boiko/crimson_tox/kahovskaya.mp3", 0.995},
	
	arr_masterskaya_f = {"subway_announcers/peseckaya/arr_masterskaya.mp3",4},
	next_masterskaya_f = {"subway_announcers/peseckaya/next_masterskaya.mp3",3},
	arr_metrostroiteley_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/arr_metrostroiteley.mp3",4},
	next_metrostroiteley_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/next_metrostroiteley.mp3",3},
	arr_litievaya_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/arr_litievaya.mp3",4},
	next_litievaya_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/next_litievaya.mp3",3},
	arr_pionerskaya_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/arr_pionerskaya.mp3",6},
	next_pionerskaya_f = {"subway_announcers/asnp/pyaseckaya/neocrimson/next_pionerskaya.mp3",5},
	arr_aeroport_f = {"subway_announcers/asnp/pyaseckaya/neoorange/arr_aeroport.mp3",3},
	next_aeroport_f = {"subway_announcers/asnp/pyaseckaya/neoorange/next_aeroport.mp3",3},
	},
	{
		{
			LED = {5, 5, 5, 5, 5, 5},
			Name = "Линия 5 (Малиновая Линия)",
			Loop = false,
			spec_last = {"last_m",0.5,"things_m"},
			spec_wait = {{"train_stop_m"}, {"train_depeat_m"}},
			BlockDoors = true,
			{
				501,
				"Аэропорт",
				arrlast = {nil, {"arr_aeroport_f",2,"last_f",0.5,"things_f",0.5,"deadlock_f"}, "aeroport_m"},
				dep = {{"doors_closing_m","pionerskaya_next_m",0.2,"politeness_m"}, nil},
			},
			{
				502,
				"Пионерская",
				arr = { {"station_m","pionerskaya_m"}, "arr_pionerskaya_f" },
				dep = { {"doors_closing_m","litievaya_next_m"}, {"doors_closing_f","next_aeroport_f"} },
				right_doors = true
			},
			{
				503,
				"Lithium",
				arr = { {"station_m","litievaya_m"}, "arr_litievaya_f" },
				dep = { {"doors_closing_m","metrostroiteley_next_m"},{"doors_closing_f","next_pionerskaya_f"} },
			},
			{
				504,
				"Метростроителей",
				arr = { {"station_m","metrostroiteley_m",0.2,"things_m"},{"arr_metrostroiteley_f",0.2,"things_f"} },
				arrlast = { {"station_m","metrostroiteley_m",3,"last_m",0.5,"things_m",0.5,"deadlock_m"},{"arr_metrostroiteley_f",3,"last_f",0.5,"things_f",0.5,"deadlock_f"}, "metrostroiteley_next_m" },
				notlast = {3, "train_goes_to_m", "metrostroiteley_next_m"},
				dep = { {"doors_closing_m","kahovskaya_m"},{"doors_closing_f","next_litievaya_f"} },
			},
			--[[{
				505,
				"Мастерская",
				arr = { {"station_m","masterskaya_m",0.2,"exit_m"}, {"arr_masterskaya_f",0.2,"exit_f"} },
				dep = { {"doors_closing_m","kahovskaya_m"},{"doors_closing_f","next_metrostroiteley_f"} },
				right_doors = true
			},]]
			{
				506,
				"Каховская",
				arrlast = { {"station_m","kahovskaya_m",2,"last_m",0.5,"things_m",0.5,"deadlock_m"},nil,"kahovskaya_m" },
				dep = { nil,{"doors_closing_f","next_metrostroiteley_f"} },
			}
		}
	}
)

Metrostroi.AddSarmatUPOAnnouncer("UPO Boiko",
	{
		name = "UPO Boiko",
		tone = {"subway_announcers/boiko/tone.mp3", 1.001},
		
		last1 = {"subway_announcers/boiko/last1.mp3", 4.091},
		last2 = {"subway_announcers/boiko/last2.mp3", 4.271},
		odz1 = {"subway_announcers/boiko/odz1.mp3", 2.188},
		odz2 = {"subway_announcers/boiko/odz2.mp3", 2.408},
		odz3 = {"subway_announcers/boiko/odz3.mp3", 2.211},
		odz4 = {"subway_announcers/boiko/odz4.mp3", 2.180},
		
		spec_attention_doors = {"subway_announcers/boiko/spec_attention_doors.mp3", 4.853},
		spec_attention_exit = {"subway_announcers/boiko/spec_attention_exit.mp3", 4.771},
		spec_attention_handrails = {"subway_announcers/boiko/spec_attention_handrails.mp3", 3.871},
		spec_attention_last = {"subway_announcers/boiko/spec_attention_last.mp3", 9.227},
		spec_attention_objects1 = {"subway_announcers/boiko/spec_attention_objects1.mp3", 4.936},
		spec_attention_objects2 = {"subway_announcers/boiko/spec_attention_objects2.mp3", 4.268},
		spec_attention_politeness = {"subway_announcers/boiko/spec_attention_politeness.mp3", 8.538},
		spec_attention_things = {"subway_announcers/boiko/spec_attention_things.mp3", 4.305},
		to_orange = {"subway_announcers/boiko/to_orange.mp3", 1.969},
		train_goes_to = {"subway_announcers/boiko/train_goes_to.mp3", 1.905},
		
		arr_aeroport = {"subway_announcers/boiko/crimson_tox/arr_aeroport.mp3", 1.729},
		arr_kahovskaya = {"subway_announcers/boiko/crimson_tox/arr_kahovskaya.mp3", 1.687},
		arr_litievaya = {"subway_announcers/boiko/crimson_tox/arr_litievaya.mp3", 1.683},
		arr_masterskaya = {"subway_announcers/boiko/crimson_tox/arr_masterskaya.mp3", 1.813},
		arr_metrostroiteley = {"subway_announcers/boiko/crimson_tox/arr_metrostroiteley.mp3", 2.000},
		arr_pionerskaya = {"subway_announcers/boiko/crimson_tox/arr_pionerskaya.mp3", 1.921},
		
		next_aeroport = {"subway_announcers/boiko/crimson_tox/next_aeroport.mp3", 2.129},
		next_kahovskaya = {"subway_announcers/boiko/crimson_tox/next_kahovskaya.mp3", 2.181},
		next_litievaya = {"subway_announcers/boiko/crimson_tox/next_litievaya.mp3", 2.277},
		next_masterskaya = {"subway_announcers/boiko/crimson_tox/next_masterskaya.mp3", 2.259},
		next_metrostroiteley = {"subway_announcers/boiko/crimson_tox/next_metrostroiteley.mp3", 2.466},
		next_pionerskaya = {"subway_announcers/boiko/crimson_tox/next_pionerskaya.mp3", 2.353},
		
		aeroport = {"subway_announcers/boiko/crimson_tox/aeroport.mp3", 0.989},
		kahovskaya = {"subway_announcers/boiko/crimson_tox/kahovskaya.mp3", 0.995},
		litievaya = {"subway_announcers/boiko/crimson_tox/litievaya.mp3", 1.027},
		masterskaya = {"subway_announcers/boiko/crimson_tox/masterskaya.mp3", 1.179},
		metrostroiteley = {"subway_announcers/boiko/crimson_tox/metrostroiteley.mp3", 1.314},
		pionerskaya = {"subway_announcers/boiko/crimson_tox/pionerskaya.mp3", 0.986},
	},
	{
		{
			LED = {6, 5, 5 ,5, 5, 6},
			Name = "Линия 5",
			{
				501,
				"Аэропорт","Airport",
				arrlast = {nil, {"arr_aeroport", "to_orange", "last1", "spec_attention_last"}},
				dep = {{"next_pionerskaya", "spec_attention_politeness"}, nil},
				odz = "odz1",
				dist = 20,
			},
			{
				502,
				"Пионерская","Pioneer",
				arr = {"arr_pionerskaya", "arr_pionerskaya"},
				dep = {{"next_litievaya", "spec_attention_objects1"}, {"next_aeroport"}},
				odz = "odz2",
				dist = 20,
			},
			{
				503,
				"Литиевая","Lithium",
				arr = {{"arr_litievaya", "to_orange"}, {"arr_litievaya", "to_orange"}},
				dep = {{"next_metrostroiteley"}, {"next_pionerskaya", "spec_attention_objects2"}},
				odz = "odz3",
				dist = 20,
			},
			{
				504,
				"Метростроителей","Metrobuilders",
				arr = {"arr_metrostroiteley", "arr_metrostroiteley"},
				dep = {{"next_masterskaya", "spec_attention_handrails"}, {"next_litievaya", "spec_attention_doors"}},
				arrlast = {{"arr_metrostroiteley", "last2", "spec_attention_last"}, {"arr_metrostroiteley", "last1", "spec_attention_last"}},
				odz = "odz4",
				dist = 20,
			},
			{
				505,
				"Мастерская","Workshop","masterskaya",
				arr = {{"arr_masterskaya", "spec_attention_exit"}, {"arr_masterskaya", "spec_attention_exit"}},
				dep = {{"next_kahovskaya"}, {"next_metrostroiteley", "spec_attention_politeness"}},
				odz = "odz1",
				dist = 10,
			},
			{
				506,
				"Каховская","Kakhovskaya","kahovskaya",
				arrlast = {{"arr_kahovskaya", "last2", "spec_attention_things", "spec_attention_last"}, nil},
				dep = {nil, {"next_masterskaya", "spec_attention_politeness"}},
				odz = "odz3",
				dist = 20,
			}
		}
	}
)

Metrostroi.SetUPOAnnouncer (
	{
		tone = {"subway_announcers/boiko/tone.mp3", 1.001},
		click1 = {"subway_announcers/boiko/click3.mp3", 0.417},
		click2 = {"subway_announcers/boiko/click4.mp3", 0.313},
		
		last1 = {"subway_announcers/boiko/last1.mp3", 4.091},
		last2 = {"subway_announcers/boiko/last2.mp3", 4.271},
		odz1 = {"subway_announcers/boiko/odz1.mp3", 2.188},
		odz2 = {"subway_announcers/boiko/odz2.mp3", 2.408},
		odz3 = {"subway_announcers/boiko/odz3.mp3", 2.211},
		odz4 = {"subway_announcers/boiko/odz4.mp3", 2.180},
		
		spec_attention_doors = {"subway_announcers/boiko/spec_attention_doors.mp3", 4.853},
		spec_attention_exit = {"subway_announcers/boiko/spec_attention_exit.mp3", 4.771},
		spec_attention_handrails = {"subway_announcers/boiko/spec_attention_handrails.mp3", 3.871},
		spec_attention_last = {"subway_announcers/boiko/spec_attention_last.mp3", 9.227},
		spec_attention_objects1 = {"subway_announcers/boiko/spec_attention_objects1.mp3", 4.936},
		spec_attention_objects2 = {"subway_announcers/boiko/spec_attention_objects2.mp3", 4.268},
		spec_attention_politeness = {"subway_announcers/boiko/spec_attention_politeness.mp3", 8.538},
		spec_attention_things = {"subway_announcers/boiko/spec_attention_things.mp3", 4.305},
		to_orange = {"subway_announcers/boiko/to_orange.mp3", 1.969},
		train_goes_to = {"subway_announcers/boiko/train_goes_to.mp3", 1.905},
		
		arr_aeroport = {"subway_announcers/boiko/crimson_tox/arr_aeroport.mp3", 1.729},
		arr_kahovskaya = {"subway_announcers/boiko/crimson_tox/arr_kahovskaya.mp3", 1.687},
		arr_litievaya = {"subway_announcers/boiko/crimson_tox/arr_litievaya.mp3", 1.683},
		arr_masterskaya = {"subway_announcers/boiko/crimson_tox/arr_masterskaya.mp3", 1.813},
		arr_metrostroiteley = {"subway_announcers/boiko/crimson_tox/arr_metrostroiteley.mp3", 2.000},
		arr_pionerskaya = {"subway_announcers/boiko/crimson_tox/arr_pionerskaya.mp3", 1.921},
		
		next_aeroport = {"subway_announcers/boiko/crimson_tox/next_aeroport.mp3", 2.129},
		next_kahovskaya = {"subway_announcers/boiko/crimson_tox/next_kahovskaya.mp3", 2.181},
		next_litievaya = {"subway_announcers/boiko/crimson_tox/next_litievaya.mp3", 2.277},
		next_masterskaya = {"subway_announcers/boiko/crimson_tox/next_masterskaya.mp3", 2.259},
		next_metrostroiteley = {"subway_announcers/boiko/crimson_tox/next_metrostroiteley.mp3", 2.466},
		next_pionerskaya = {"subway_announcers/boiko/crimson_tox/next_pionerskaya.mp3", 2.353},
		
		aeroport = {"subway_announcers/boiko/crimson_tox/aeroport.mp3", 0.989},
		kahovskaya = {"subway_announcers/boiko/crimson_tox/kahovskaya.mp3", 0.995},
		litievaya = {"subway_announcers/boiko/crimson_tox/litievaya.mp3", 1.027},
		masterskaya = {"subway_announcers/boiko/crimson_tox/masterskaya.mp3", 1.179},
		metrostroiteley = {"subway_announcers/boiko/crimson_tox/metrostroiteley.mp3", 1.314},
		pionerskaya = {"subway_announcers/boiko/crimson_tox/pionerskaya.mp3", 0.986},
	},
	{
		{
			501,
			"Аэропорт",
			arrlast = {nil, {"arr_aeroport", "to_orange", "last1", "spec_attention_last"}},
			dep = {{"odz1", "next_pionerskaya", "spec_attention_politeness"}, nil},
			tone = "tone", dist = 20,
			noises = {1,2,3},noiserandom = 0.2,
		},
		{
			502,
			"Пионерская",
			arr = {"arr_pionerskaya", "arr_pionerskaya"},
			dep = {{"odz2", "next_litievaya", "spec_attention_objects1"}, {"odz3", "next_aeroport"}},
			tone = "tone", dist = 20,
			noises = {1,2,3},noiserandom = 0.1,
		},
		{
			503,
			"Литиевая",
			arr = {{"arr_litievaya", "to_orange"}, {"arr_litievaya", "to_orange"}},
			dep = {{"odz3", "next_metrostroiteley"}, {"odz4", "next_pionerskaya", "spec_attention_objects2"}},
			tone = "tone", dist = 20,
			noises = {2,3},noiserandom = 0.2,
		},
		{
			504,
			"Метростроителей",
			arr = {"arr_metrostroiteley", "arr_metrostroiteley"},
			dep = {{"odz4", "next_masterskaya", "spec_attention_handrails"}, {"odz3", "next_litievaya", "spec_attention_doors"}},
			tone = "tone", dist = 20,
			noises = {1,3},noiserandom = 0.1,
		},
		{
			505,
			"Мастерская",
			arr = {{"arr_masterskaya", "spec_attention_exit"}, {"arr_masterskaya", "spec_attention_exit"}},
			dep = {{"odz3", "next_kahovskaya"}, {"odz2", "next_metrostroiteley", "spec_attention_politeness"}},
			tone = "tone", dist = 10,
			noises = {1,2},noiserandom = 0.2,
		},
		{
			506,
			"Каховская",
			arrlast = {{"arr_kahovskaya", "last2", "spec_attention_things", "spec_attention_last"}, nil},
			dep = {nil, {"odz1", "next_masterskaya", "spec_attention_politeness"}},
			tone = "tone", dist = 20,
			noises = {1,2,3},noiserandom = 0.1,
		}
	}
)

Metrostroi.StationConfigurations = {
	[501] = {
		names = {"Аэропорт","Airport"},
		positions = {
			{Vector(-10870,770,2200-56),Angle(0,90,0)}
		}
	},
	[502] = {
		names = {"Пионерская","Pioneer"},
		positions = {
			{Vector(11450,-1170,2200-56),Angle(0,0,0)}
		}
	},
	[503] = {
		names = {"Литиевая","Lithium"},
		positions = {
			{Vector(-14360,-3980,610-56),Angle(0,90,0)}
		}
	},
	[504] = {
		names = {"Метростроителей","Metrobuilders"},
		positions = {
			{Vector(165,2635,980-56),Angle(0,180,0)}
		}
	},
	[505] = {
		names = {"Мастерская","Workshop","masterskaya"},
		positions = {
			{Vector(7820,-14210,-54-56),Angle(0,180,0)}
		}
	},
	[506] = {
		names = {"Каховская","Kakhovskaya","kahovskaya"},
		positions = {
			{Vector(2790,-11135,-1090-56),Angle(0,180,0)}
		}
	},
	pto = {
		names = {"ПТО"},
		positions = {
			{Vector(1720,-15540,2180-54),Angle(0,180,0)}
		}
	},
	tupik1 = {
		names = {"Тупик Аэропорт"},
		positions = {
			{Vector(-10894, -13311, 2212),Angle(0,90,0)}
		}
	}
}
