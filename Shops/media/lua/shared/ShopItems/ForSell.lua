Shop.Sell = {
	
	--черный список
	["Hydrocraft.HCPenny"] = { blacklisted = true}, -- пени
	["Hydrocraft.HCNickel"] = { blacklisted = true}, -- 5 центов
	["Hydrocraft.HCDime"] = { blacklisted = true}, -- 10 центов
	["Hydrocraft.HCQuarter"] = { blacklisted = true}, -- 25 центов
	["Hydrocraft.HCHalfdollar"] = { blacklisted = true}, -- пол доллара
	["Hydrocraft.HCDollar"] = { blacklisted = true}, -- доллар
	["Hydrocraft.HCCheque"] = { blacklisted = true}, -- Пустой банковский чек
	["Hydrocraft.HCCoincopper"] = { blacklisted = true}, --медная монета 
	["Hydrocraft.HCCoinsilver"] = { blacklisted = true}, -- серебрянная монета
	["Hydrocraft.HCCoingold"] = { blacklisted = true}, --золотая монета
	["Hydrocraft.HCDirt"] = { blacklisted = true}, --земля
	["Hydrocraft.HCCompost"] = { blacklisted = true}, -- компост
	["Base.KeyRing"] = { blacklisted = true}, --Ключи
	["SM.SMCigarete"] = { blacklisted = true}, -- сигареты
	["SM.SMSmallHandfulTobacco"] = { blacklisted = true}, --  Маленькая горсть табака
	["SM.SMFilter"] = { blacklisted = true}, --фильтр
	["Base.SheetPaper2"] = { blacklisted = true}, --лист бумаги
	["Base.SheetPaper"] = { blacklisted = true}, --лист бумаги	

	--за спец монеты
	["Base.CreditCard"] = { price = 1 , specialCoin = true }, --кредитка
	["Hydrocraft.HCPokerchip"] = { price = 1 , specialCoin = true }, -- покерная фишка
	["Hydrocraft.HCDriverslicense"] = { price = 1 , specialCoin = true }, --водительское удостоверение
	["Hydrocraft.HCTungsteningot"] = { price = 4 , specialCoin = true }, --вольфрамовый слиток
	["Hydrocraft.HCWhitegoldingot"] = { price = 8 , specialCoin = true }, --Слиток белого золота
	["Hydrocraft.HCSterlingsilveringot"] = { price = 6 , specialCoin = true }, --Слиток высококачественного серебра
	["Hydrocraft.HCRosegoldingot"] = { price = 8 , specialCoin = true }, --Слиток розового золота
	["Base.GPSdayz"] = { price = 4 , specialCoin = true }, -- GPS
	

	--Драг.металлы
	["Hydrocraft.HCGoldingot"] = { price = 1850},	-- золотой слиток
	["Hydrocraft.HCSilveringot"] = { price = 1200},--серебряный слиток
	["LabItems.FrnGolgIngot"] = { price = 1850}, --золотой слиток 2
	["LabItems.FrnSilverIngot"] = { price = 1200}, -- серебряный слиток 2	

	-- деньги
	["Base.Money"] = { price = 30}, -- деньги
	["Hydrocraft.HC1dollarbill"] = { price = 1}, -- 1 доллар
	["Hydrocraft.HC10dollarbill"] = { price = 10},-- 10 доллар
	["Hydrocraft.HC100dollarbill"] = { price = 100},-- 100 доллар
	["Hydrocraft.HC2dollarbill"] = { price = 2}, --2 доллара
	["Hydrocraft.HC20dollarbill"] = { price = 20}, --20 долларов
	["Hydrocraft.HC5dollarbill"] = { price = 5}, -- 5 долларов
	["Hydrocraft.HC50dollarbill"] = { price = 50}, -- 50 доларов
	["Hydrocraft.HCDollar"] = { price = 1}, -- 1 доллар

	--драг.камни
	["Base.HCJade"] = { price = 20}, -- нефрит
	["Base.HCQuartz"] = { price = 20}, -- кварц
	["Base.HCAzurite"] = { price = 20}, -- Азурит
	["Base.HCDiamond"] = { price = 20}, -- Алмаз
	["Base.HCAmethyst"] = { price = 20}, -- Аметист	
	["Base.HCQuartzblue"] = { price = 20}, -- синий кварцевый кристалл
	["Base.HCQuartzrose"] = { price = 20}, -- розовый кварцевый кристалл
	["Base.HCQuartzsmokey"] = { price = 20}, -- дымчатый кварцевый кристалл
	["Base.HCQuartzcitrine"] = { price = 20}, -- Кварцевый кристалл цитрина
	["Base.HCQuartzrosecut"] = { price = 40}, -- неограненный розовый кварцевый кристалл
	["Base.HCQuartzsmokeycut"] = { price = 40}, -- неограненный дымчатый кварцевый кристалл	
	["Base.HCQuartzbluecut"] = { price = 40}, -- неограненный синий кварцевый кристалл
	["Base.HCQuartzcut"] = { price = 40}, -- неограненный кварцевый кристалл	
	["Base.HCQuartzcitrinecut"] = { price = 40}, -- неограненный цитриновый кварцевый кристалл	
	["Base.HCAmethystcut"] = { price = 40}, -- неограненный Аметист				
	["Base.HCAzuritecut"] = { price = 40}, -- неограненный Азурит		
	["Base.HCDiamondcut"] = { price = 40}, -- неограненный Алмаз	

	-- рыбалка
	["Hydrocraft.HCFishingbasket"] = { price = 150}, -- Корзина для рыбы
	["Base.Bass"] = { price = 250}, -- окунь	
	["Base.Perch"] = { price = 240}, -- Пресноводный окунь	
	["Base.Pike"] = { price = 330}, -- Щука
	["Base.Panfish"] = { price = 195}, -- Синежаберный солнечник
	["Base.BaitFish"] = { price = 165}, -- Живец
	["Base.Catfish"] = { price = 283}, -- Сом
	["Base.Trout"] = { price = 364}, -- форель
	["Base.Crappie"] = { price = 197}, -- краппи
	["Base.Shoes_Random"] = { price = 20}, -- туфли
	["Base.Socks_Ankle"] = { price = 5}, -- носки	

	--охота/туши
	["Hydrocraft.HCBeavermeat"] = { price = 50}, -- туша бобра
	["Hydrocraft.HCNutriameat"] = { price = 50}, -- туша болотного бобра
	["Hydrocraft.HCArmadillomeat"] = { price = 50}, -- туша броненосца
	["Hydrocraft.HCBearmeat"] = { price = 500}, -- туша гризли
	["Hydrocraft.HCPorcupinemeat"] = { price = 70}, -- туша дикобраза
	["Hydrocraft.HCRaccoonmeat"] = { price = 50}, -- туша енота
	["Hydrocraft.HCBoarmeat"] = { price = 200}, -- туша кабана
	["Hydrocraft.HCGoatmeat"] = { price = 200}, -- туша козла
	["Hydrocraft.HCCowmeat"] = { price = 300}, -- туша коровы
	["Hydrocraft.HCCowmeat2"] = { price = 300}, -- туша коровы
	["Hydrocraft.HCCatmeat"] = { price = 70}, -- туша кота
	["Hydrocraft.HCFoxmeat"] = { price = 90}, -- туша лисы
	["Hydrocraft.HCHorsemeat"] = { price = 400}, -- туша лошади
	["Hydrocraft.HCSheepmeat"] = { price = 250}, -- туша овцы
	["Hydrocraft.HCDeermeat2"] = { price = 200}, -- туша оленя
	["Hydrocraft.HCDeermeat"] = { price = 200}, -- туша оленя
	["Hydrocraft.HCOpossummeat"] = { price = 50}, -- туша опоссума
	["Hydrocraft.HCDonkeymeat"] = { price = 150}, -- туша осла
	["Hydrocraft.HCCougarmeat"] = { price = 200}, -- туша пумы
	["Hydrocraft.HCPigmeat"] = { price = 250}, -- туша свиньи
	["Hydrocraft.HCSkunkmeat"] = { price = 50}, -- туша скунса
	["Hydrocraft.HCDogmeat"] = { price = 70}, -- туша собаки
	["Hydrocraft.HCBlackbearmeat"] = { price = 750}, -- туша черного медведя	

	--Охота/шкуры
	["Hydrocraft.HCHiderawcat"] = { price = 50}, -- шкура кота
	["Hydrocraft.HCHiderawdog"] = { price = 50}, -- шкура собаки
	["Hydrocraft.HCHiderawopossum"] = { price = 50}, -- шкура опоссума
	["Hydrocraft.HCHiderawsquirrel"] = { price = 50}, -- шкура белки
	["Hydrocraft.HCHiderawbeaver"] = { price = 50}, -- шкура бобра
	["Hydrocraft.HCHiderawbull"] = { price = 200}, -- шкура буйвола
	["Hydrocraft.HCHiderawbear"] = { price = 400}, -- шкура гризли
	["Hydrocraft.HCHiderawraccoon"] = { price = 50}, -- шкура енота
	["Hydrocraft.HCHiderawboar"] = { price = 150}, -- шкура кабана
	["Hydrocraft.HCHiderawgoat"] = { price = 150}, -- шкура козла
	["Hydrocraft.HCHiderawcow"] = { price = 200}, -- шкура коровы
	["Hydrocraft.HCHiderawrabbit"] = { price = 70}, -- шкура кролика
	["Hydrocraft.HCHiderawfox"] = { price = 80}, -- шкура лисы
	["Hydrocraft.HCHiderawnutria"] = { price = 90}, -- шкура нутрии
	["Hydrocraft.HCHiderawsheep"] = { price = 130}, -- шкура овцы
	["Hydrocraft.HCHiderawdeer"] = { price = 200}, -- шкура оленя
	["Hydrocraft.HCHiderawmuskrat"] = { price = 50}, -- шкура ондатры
	["Hydrocraft.HCHiderawpig"] = { price = 200}, -- шкура свиньи
	["Hydrocraft.HCHiderawskunk"] = { price = 50}, -- шкура скунса
	["Hydrocraft.HCHiderawgroundhog"] = { price = 80}, -- шкура сурка
	["Hydrocraft.HCHiderawcougar"] = { price = 150}, -- шкура пумы
	["Hydrocraft.HCHiderawbearblack"] = { price = 650}, -- шкура черного медведя
	["Hydrocraft.HCHiderawarmadillo"] = { price = 135}, -- Сырая шкура броненосец

	-- /кишки, кости
	["Hydrocraft.HCIntestines"] = { price = 20}, -- кишки
	["Hydrocraft.HCBone"] = { price = 10}, -- кость
	["Hydrocraft.HCPorcupinequills"] = { price = 55}, -- иглы дикобраза
	["Hydrocraft.HCBoartusk"] = { price = 50}, -- клык кабана

	-- Охота/мясо
	["Base.Chicken"] = { price = 75}, -- курица
	["Hydrocraft.HCTurkeymeat"] = { price = 75}, -- мясо индейки
	["Base.Rabbitmeat"] = { price = 85}, -- мясо кролика
	["Base.FrogMeat"] = { price = 55}, -- Мясо лягушки
	["Base.Smallanimalmeat"] = { price = 45}, -- Мясо маленького животного
	["Base.Smallbirdmeat"] = { price = 45}, -- мясо птицы
	["Hydrocraft.HCVenison"] = { price = 85}, -- Оленина
	["Hydrocraft.HCDeerantlers"] = { price = 150}, -- Оленьи рога
	["Hydrocraft.HCFreshham"] = { price = 125}, -- Свежая ветчина
	["Base.PorkChop"] = { price = 95}, -- Свиная отбивная
	["Base.Steak"] = { price = 95}, -- стейк
	["Hydrocraft.HCSmallgamesteak"] = { price = 95}, -- стейк из дичи
	["Hydrocraft.HCCougarsteak"] = { price = 95}, -- стейк из пумы
	["farming.Bacon"] = { price = 135}, -- бекон
	["Hydrocraft.HCCheval"] = { price = 235}, -- конина

	--еда
	["Hydrocraft.HCJarhoney"] = { price = 200}, -- банка мёда

	
	["farming.Tomato "] = { price = 20}, -- томат
	["farming.Cabbage"] = { price = 20}, --капуста
	["farming.Potato"] = { price = 20}, -- картофель
	["farming.Strewberrie"] = { price = 20}, -- клубника
	["farming.BloomingBroccoli"] = { price = 20}, -- брокули
	["farming.RedRadish"] = { price = 20}, -- редис
	["Base.Peanuts"] = { price = 20}, -- Арахис
	["Base.GrapeLeaves"] = { price = 20}, -- Листва винограда
	["Base.Grapes"] = { price = 20}, -- виноград
	["Hydrocraft.HCCornred"] = { price = 20}, -- красная кукуруза
	["Base.Corn"] = { price = 20}, -- кукуруза
	["Base.Lettuce"] = { price = 20}, -- латук
	["Base.Lemon"] = { price = 20}, -- лемон
	["Hydrocraft.HCFlax"] = { price = 200}, -- лен
	["Base.Carrots"] = { price = 20}, -- морковь
	["Hydrocraft.HCSunflower"] = { price = 20}, -- подсолнух
	["Hydrocraft.HCWheatBundle"] = { price = 20}, -- пшеница

	 --оружие
	["Hydrocraft.HCAA12"] = { price = 950}, -- AA12
	["Base.ShotgunSawnoff"] = { price = 450}, -- обрез
	["Base.Shotgun"] = { price = 600}, -- Дробовик JS2000
	["Base.DoubleBarrelShotgun"] = { price = 400}, -- Двуствольное ружьё
	["Base.DoubleBarrelShotgunSawnoff"] = { price = 250}, -- Обрез двустволки
	["Base.AssaultRifle2"] = { price = 2400}, -- M14
	["Base.AssaultRifle"] = { price = 1800}, -- M16
	["Base.VarmintRifle"] = { price = 1400}, -- MSR700
	["Base.HuntingRifle"] = { price = 2000}, -- MSR788
	["Base.Pistol"] = { price = 170}, -- M9
	["Base.Pistol2"] = { price = 185}, -- M1911
	["Base.Pistol3"] = { price = 235}, -- D-E
	["Base.Revolver"] = { price = 198}, -- M625
	["Base.Revolver_Long"] = { price = 270}, -- Магнум
	["Base.Revolver_Short"] = { price = 190}, -- M36
	["Hydrocraft.HCUzi"] = { price = 220}, -- Uzi
	["Hydrocraft.HCShotgunSilencer"] = { price = 175}, -- Глушитель дробовика
	["Hydrocraft.HCGunParts"] = { price = 105}, -- Оружейные запчасти
	["Hydrocraft.HCMagAA12"] = { price = 80}, -- АА12 Магазин
	["Base.9mmClip"] = { price = 80}, -- Магазин от M9
	["Base.44Clip"] = { price = 80}, -- Магазин от D-E
	["Base.M14Clip"] = { price = 80}, -- Магазин от M14
	["Base.556Clip"] = { price = 80}, -- Магазин от M16
	["Base.45Clip"] = { price = 80}, -- Магазин от M1911
	["Base.223Clip"] = { price = 80}, -- Магазин от MSR700
	["Base.308Clip"] = { price = 80}, -- Магазин от MSR788	
	["Base.HCMagUZI"] = { price = 80}, -- Магазин узи

	--инструмент
	["Base.Sledgehammer"] = { price = 100}, -- Кувалда
	["Base.Sledgehammer2"] = { price = 100}, -- Кувалда	

	--часы
	["Base.WristWatch_Left_ClassicGold"] = { price = 50},	--Золотые кварцевые часы
	["Base.WristWatch_Right_ClassicMilitary"] = { price = 50},--часы
	["Base.WristWatch_Left_ClassicMilitary"] = { price = 50}, --часы
	["Base.WristWatch_Left_ClassicBlack"] = { price = 50},--часы
	["Base.WristWatch_Right_ClassicBlack"] = { price = 50},--часы
	["Base.WristWatch_Right_DigitalBlack"] = { price = 30},--часы
	["Base.WristWatch_Left_DigitalBlack"] = { price = 30},--часы
	["Base.WristWatch_Right_DigitalRed"] = { price = 30},--часы
	["Base.WristWatch_Left_DigitalRed"] = { price = 30},--часы
	["Base.WristWatch_Right_DigitalDress"] = { price = 30},--часы
	["Base.WristWatch_Left_DigitalDress"] = { price = 30},--часы
	["Base.Bracelet_RightFriendshipTINT"] = { price = 30},--часы
	["Base.Bracelet_LeftFriendshipTINT"] = { price = 30},--часы
	
	--Бижутерия
	["Base.Earring_LoopLrg_Gold"] = { price = 75}, --бижутерия
	["Base.Bracelet_ChainLeftGold"] = { price = 75},--бижутерия
	["Base.BellyButton_DangleGold"] = { price = 75},--бижутерия
	["Base.BellyButton_DangleGoldRuby"] = { price = 125},--бижутерия
	["Base.BellyButton_StudGold"] = { price = 75},--бижутерия
	["Base.BellyButton_StudGoldDiamond"] = { price = 130},--бижутерия
	["Base.Necklace_Gold"] = { price = 75},--бижутерия
	["Base.Necklace_GoldDianond"] = { price = 130},--бижутерия
	["Base.Necklace_GoldRuby"] = { price = 125},--бижутерия
	["Base.NecklaceLong_Gold"] = { price = 75},--бижутерия
	["Base.NecklaceLong_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Right_Middle_MiddleFinger_Gold"] = { price = 75},--бижутерия
	["Base.BellyButton_RingGold"] = { price = 75},--бижутерия
	["Base.BellyButton_RingGoldDiamond"] = { price = 130},--бижутерия
	["Base.BellyButton_RingGoldRuby"] = { price = 125},--бижутерия
	["Base.Ring_Right_Right_MiddleFinger_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Right_Left_RingFinger_GoldRuby"] = { price = 125},--бижутерия
	["Base.Bracelet_BangleLeftGold"] = { price = 75},--бижутерия
	["Base.NoseStud_Gold"] = { price = 75},--бижутерия
	["Base.NoseRing_Gold"] = { price = 75},--бижутерия
	["Base.WristWatch_Right_ClassicGold"] = { price = 50},--бижутерия
	["Base.Earring_Stud_Gold"] = { price = 75},--бижутерия
	["Base.Earring_LoopMed_Gold"] = { price = 75},--бижутерия
	["Base.Earring_LoopSmall_Gold_Both"] = { price = 75},--бижутерия
	["Base.Earring_LoopSmall_Gold_Top"] = { price = 75},--бижутерия
	["Base.Bracelet_ChainRightGold"] = { price = 75},--бижутерия
	["Base.Necklace_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Left_RingFinger_Gold"] = { price = 75},--бижутерия
	["Base.Ring_Left_MiddleFinger_Gold"] = { price = 75},--бижутерия
	["Base.Ring_Right_RingFinger_Gold"] = { price = 75},--бижутерия
	["Base.Ring_Right_MiddleFinger_Gold"] = { price = 75},--бижутерия
	["Base.Ring_Right_MiddleFinger_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Left_MiddleFinger_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Left_RingFinger_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Right_RingFinger_GoldDiamond"] = { price = 130},--бижутерия
	["Base.Ring_Left_RingFinger_GoldRuby"] = { price = 125},--бижутерия
	["Base.Ring_Left_MiddleFinger_GoldRuby"] = { price = 125},--бижутерия
	["Base.Ring_Right_RingFinger_GoldRuby"] = { price = 125},--бижутерия
	["Base.Ring_Right_MiddleFinger_GoldRuby"] = { price = 125},--бижутерия
	["Base.Bracelet_BangleRightGold"] = { price = 75},--бижутерия	
	["Base.Earring_LoopLrg_Silver"] = { price = 45},--бижутерия
	["Base.Earring_LoopSmall_Silver_Both"] = { price = 43},--бижутерия
	["Base.Earring_LoopSmall_Silver_Top"] = { price = 43},--бижутерия
	["Base.Bracelet_ChainLeftSilver"] = { price = 46},--бижутерия
	["Base.Bracelet_ChainRightSilver"] = { price = 46},	--бижутерия
	["Base.BellyButton_DangleSilver"] = { price = 44},--бижутерия
	["Base.BellyButton_DangleSilverDiamond"] = { price = 69},--бижутерия
	["Base.BellyButton_StudSilver"] = { price = 43},--бижутерия
	["Base.BellyButton_StudSilverDiamond"] = { price = 73},--бижутерия
	["Base.Necklace_Silver"] = { price = 45},--бижутерия
	["Base.Necklace_SilverSapphire"] = { price = 64},--бижутерия
	["Base.NecklaceLong_Silver"] = { price = 45},--бижутерия
	["Base.NecklaceLong_SilverDiamond"] = { price = 74},--бижутерия
	["Base.NecklaceLong_SilverEmerald"] = { price = 77},--бижутерия
	["Base.NecklaceLong_SilverSapphire"] = { price = 64},--бижутерия
	["Base.Ring_Left_RingFinger_Silver"] = { price = 44},	--бижутерия
	["Base.Ring_Right_RingFinger_Silver"] = { price = 44},--бижутерия
	["Base.Ring_Right_MiddleFinger_Silver"] = { price = 44},--бижутерия
	["Base.Ring_Left_MiddleFinger_Silver"] = { price = 44},--бижутерия
	["Base.BellyButton_RingSilver"] = { price = 45},--бижутерия
	["Base.BellyButton_RingSilverAmethyst"] = { price = 67},	--бижутерия
	["Base.Ring_Right_MiddleFinger_SilverDiamond"] = { price = 77},--бижутерия
	["Base.Ring_Left_MiddleFinger_SilverDiamond"] = { price = 77},--бижутерия
	["Base.Ring_Right_Right_RingFinger_SilverDiamond"] = { price = 77},--бижутерия
	["Base.Ring_Left_Right_RingFinger_SilverDiamond"] = { price = 77},--бижутерия
	["Base.Ring_Right_Right_MiddleFinger_SilverDiamond"] = { price = 77},	--бижутерия
	["Base.NoseStud_Silver"] = { price = 45},--бижутерия
	["Base.NoseRing_Silver"] = { price = 42},--бижутерия
	["Base.BellyButton_RingSilverDiamond"] = { price = 75},--бижутерия	
	["Base.BellyButton_RingSilverRuby"] = { price = 67},--бижутерия
	["Base.Earring_Stud_Silver"] = { price = 45},--бижутерия
	["Base.Earring_LoopMed_Silver"] = { price = 44},--бижутерия
	["Base.Bracelet_BangleRightSilver"] = { price = 45},--бижутерия
	["Base.Bracelet_BangleLeftSilver"] = { price = 45},--бижутерия
	["Base.Necklace_SilverCrucifix"] = { price = 50},--бижутерия
	["Base.Necklace_SilverDiamond"] = { price = 70},--бижутерия
	["Base.Ring_Right_RingFinger_SilverDiamond"] = { price = 73},--бижутерия	
	["Base.Necklace_DogTag"] = { price = 80},--бижутерия
	["Base.WristWatch_Left_ClassicBrown"] = { price = 50},--бижутерия
	["Base.WristWatch_Right_ClassicBrown"] = { price = 50},--бижутерия
	["Base.Necklace_YingYang"] = { price = 85},	--бижутерия
	["Base.NecklaceLong_Amber"] = { price = 145},--бижутерия	
	["Base.Locket"] = { price = 50},--бижутерия
	["Base.Necklace_Crucifix"] = { price = 50},--бижутерия
	["Base.Necklace_Pearl"] = { price = 51},--бижутерия
	["Base.Ring_Left_RingFinger_SilverDiamond"] = { price = 79},--бижутерия
	["Base.Earring_Stone_Ruby"] = { price = 60},--бижутерия
	["Base.Necklace_Choker"] = { price = 40},--бижутерия
	["Base.Necklace_Choker_Sapphire"] = { price = 50},--бижутерия
	["Base.Necklace_Choker_Amber"] = { price = 50},--бижутерия
	["Base.Necklace_Choker_Diamond"] = { price = 55},--бижутерия
	["Base.Earring_Stone_Sapphire"] = { price = 60},--бижутерия
	["Base.Earring_Stone_Emerald"] = { price = 61},--бижутерия
	["Base.Earring_Dangly_Sapphire"] = { price = 62},--бижутерия
	["Base.Earring_Dangly_Emerald"] = { price = 63},--бижутерия
	["Base.Earring_Dangly_Diamond"] = { price = 67},--бижутерия
	["Base.Earring_Dangly_Ruby"] = { price = 65},--бижутерия
	["Base.Earring_Dangly_Pearl"] = { price = 65},--бижутерия
	["Base.Earring_Pearl"] = { price = 52},--бижутерия
}