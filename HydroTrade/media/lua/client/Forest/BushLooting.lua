local bushLoot = {
    spring = {
        ["d_plants_1_18"] = {
            {item = "Hydrocraft.HCFern", chance = 100, comment = "Листья папоротника"},
            {item = "Hydrocraft.HCFiddleheadfern", chance = 80, comment = "Рахисы папоротника"},
        },
        ["d_plants_1_19"] = {
            {item = "Hydrocraft.HCFern", chance = 100, comment = "Листья папоротника"},
            {item = "Hydrocraft.HCFiddleheadfern", chance = 80, comment = "Рахисы папоротника"},
        },
        ["d_plants_1_59"] = {
            {item = "Base.Violets", chance = 60, comment = "Фиалки"},
            {item = "Hydrocraft.HCMagnolia", chance = 40, comment = "Магнолия"},
        },
        ["d_plants_1_63"] = {
            {item = "Hydrocraft.HCDaffodil", chance = 40, comment = "Нарцисс"},
        },
        ["d_plants_1_60"] = {
            {item = "Hydrocraft.HCTulip", chance = 20, comment = "Тюльпаны"},
        },
        ["d_plants_1_29"] = {
            {item = "Hydrocraft.HCPansy", chance = 10, comment = "Анютины глазки"},
        },
        ["d_plants_1_28"] = {
            {item = "Hydrocraft.HCIris", chance = 5, comment = "Ирисы"},
        },
        ["d_plants_1_57"] = {
            {item = "Hydrocraft.HCAnemome", chance = 2, comment = "Анемоны"},
        },
        ["d_plants_1_58"] = {
            {item = "Hydrocraft.HCAnemome", chance = 2, comment = "Анемоны"},
        },
    },
    summer = {
        ["hcFarmingSunflower06_0"] = {
            {item = "Hydrocraft.HCSunflower", chance = 100, comment = "Подсолнух"},
        },
        ["hcFarmingSunflower07_0"] = {
            {item = "Hydrocraft.HCSunflower", chance = 100, comment = "Подсолнух"},
        },
        ["d_plants_1_30"] = {
            {item = "Hydrocraft.HCCarnation", chance = 80, comment = "Гвоздика"},
            {item = "Hydrocraft.HCCamellia", chance = 20, comment = "Камелия"},
        },
        ["d_plants_1_26"] = {
            {item = "Hydrocraft.HCDaisy", chance = 60, comment = "Ромашка"},
            {item = "Hydrocraft.HCChrysanthemum", chance = 40, comment = "Хризантемы"},
            {item = "Hydrocraft.HCCinquefoils", chance = 20, comment = "Лапчатка"},
            {item = "Hydrocraft.HCCamomile", chance = 40, comment = "Ромашка"},
        },
        ["d_plants_1_27"] = {
            {item = "Hydrocraft.HCDaisy", chance = 60, comment = "Ромашка"},
            {item = "Hydrocraft.HCChrysanthemum", chance = 40, comment = "Хризантемы"},
            {item = "Hydrocraft.HCCinquefoils", chance = 20, comment = "Лапчатка"},
            {item = "Hydrocraft.HCCamomile", chance = 40, comment = "Ромашка"},
        },
        ["d_plants_1_61"] = {
            {item = "Hydrocraft.HCBluedaisy", chance = 10, comment = "Синяя маргарита"},
            {item = "Hydrocraft.HCMazus", chance = 10, comment = "Мазус"},
            {item = "Hydrocraft.HCSpeedwell", chance = 20, comment = "Вероника"},
            {item = "Hydrocraft.HCWolfsbane", chance = 10, comment = "Аконит (борец)"},
        },
        ["d_plants_1_62"] = {
            {item = "Hydrocraft.HCBluedaisy", chance = 10, comment = "Синяя маргарита"},
            {item = "Hydrocraft.HCMazus", chance = 10, comment = "Мазус"},
            {item = "Hydrocraft.HCSpeedwell", chance = 20, comment = "Вероника"},
            {item = "Hydrocraft.HCWolfsbane", chance = 10, comment = "Аконит (борец)"},
        },
        ["d_plants_1_28"] = {
            {item = "Hydrocraft.HCMorningglory", chance = 5, comment = "Ипомея"},
            {item = "Hydrocraft.HCThistle", chance = 100, comment = "Чертополох"},
        },
        ["d_plants_1_29"] = {
            {item = "Hydrocraft.HCMorningglory", chance = 5, comment = "Ипомея"},
            {item = "Hydrocraft.HCThistle", chance = 100, comment = "Чертополох"},
        },
        ["d_plants_1_24"] = {
            {item = "Hydrocraft.HCStrelitzia", chance = 2, comment = "Стрелиция"},
        },
        ["d_plants_1_25"] = {
            {item = "Hydrocraft.HCStrelitzia", chance = 2, comment = "Стрелиция"},
        },
    },
    autumn = {
        ["d_plants_1_34"] = {
            {item = "Base.Rosehips", chance = 100, comment = "Шиповник"},
        },
        ["d_plants_1_35"] = {
            {item = "Base.Rosehips", chance = 100, comment = "Шиповник"},
        },
        ["d_plants_1_36"] = {
            {item = "Hydrocraft.HCChicory", chance = 80, comment = "Цикорий"},
            {item = "Base.Sage", chance = 20, comment = "Шалфей"},
        },
        ["d_plants_1_45"] = {
            {item = "Hydrocraft.HCValerian", chance = 60, comment = "Валериана"},
        },
        ["d_plants_1_57"] = {
            {item = "Hydrocraft.HCTetterwort", chance = 5, comment = "Чистотел"},
        },
        ["d_plants_1_58"] = {
            {item = "Hydrocraft.HCTetterwort", chance = 5, comment = "Чистотел"},
        },
    },
    winter = {
        ["d_plants_1_23"] = {
            {item = "Hydrocraft.HCHolly", chance = 10, comment = "Падуб"},
        },
    },
    
    -- Ягодные кусты (все сезоны)
    berries = {
        ["d_plants_1_32"] = {
            {item = "Base.BerryGeneric1", chance = 100, comment = "Дикие ягоды"},
            {item = "Base.BerryGeneric2", chance = 80, comment = "Лесные ягоды"},
            {item = "Base.BerryGeneric3", chance = 60, comment = "Кустарниковые ягоды"},
            {item = "Base.BerryGeneric4", chance = 40, comment = "Садовые ягоды"},
        },
        ["d_plants_1_33"] = {
            {item = "Base.BerryGeneric1", chance = 100, comment = "Дикие ягоды"},
            {item = "Base.BerryGeneric2", chance = 80, comment = "Лесные ягоды"},
            {item = "Base.BerryGeneric3", chance = 60, comment = "Кустарниковые ягоды"},
            {item = "Base.BerryGeneric4", chance = 40, comment = "Садовые ягоды"},
        },
        ["d_plants_1_37"] = {
            {item = "Base.BerryGeneric1", chance = 100, comment = "Дикие ягоды"},
            {item = "Base.BerryGeneric2", chance = 80, comment = "Лесные ягоды"},
            {item = "Base.BerryGeneric3", chance = 60, comment = "Кустарниковые ягоды"},
            {item = "Base.BerryGeneric4", chance = 40, comment = "Садовые ягоды"},
        },
        ["d_plants_1_16"] = {
            {item = "Hydrocraft.HCBlackcurrant", chance = 20, comment = "Черная смородина"},
            {item = "Hydrocraft.HCRedcurrant", chance = 10, comment = "Красная смородина"},
            {item = "Hydrocraft.HCGooseberry", chance = 5, comment = "Крыжовник"},
            {item = "Hydrocraft.HCHuckleberry", chance = 2, comment = "Черника"},
            {item = "Hydrocraft.HCCranberry", chance = 10, comment = "Клюква"},
            {item = "Hydrocraft.HCHawthornfruit", chance = 5, comment = "Плоды боярышника"},
            {item = "Hydrocraft.HCSeaberry", chance = 10, comment = "Облепиха"},
        },
        ["d_plants_1_17"] = {
            {item = "Hydrocraft.HCBlackcurrant", chance = 20, comment = "Черная смородина"},
            {item = "Hydrocraft.HCRedcurrant", chance = 10, comment = "Красная смородина"},
            {item = "Hydrocraft.HCGooseberry", chance = 5, comment = "Крыжовник"},
            {item = "Hydrocraft.HCHuckleberry", chance = 2, comment = "Черника"},
            {item = "Hydrocraft.HCCranberry", chance = 10, comment = "Клюква"},
            {item = "Hydrocraft.HCHawthornfruit", chance = 5, comment = "Плоды боярышника"},
            {item = "Hydrocraft.HCSeaberry", chance = 10, comment = "Облепиха"},
        },
        ["d_plants_1_19"] = {
            {item = "Hydrocraft.HCCrabapple", chance = 2, comment = "Дикая яблоня"},
        },
    },
    -- Лекарственные травы (все сезоны)
    herbs = {
        ["d_plants_1_3"] = {
            {item = "Hydrocraft.HCClover", chance = 80, comment = "Клевер"},
        },
        ["d_plants_1_4"] = {
            {item = "Hydrocraft.HCClover", chance = 80, comment = "Клевер"},
        },
        ["d_plants_1_50"] = {
            {item = "Base.Plantain", chance = 60, comment = "Подорожник"},
        },
        ["d_plants_1_31"] = {
            {item = "Hydrocraft.HCLavender", chance = 40, comment = "Лаванда"},
        },
        ["d_plants_1_18"] = {
            {item = "Base.Rosemary", chance = 10, comment = "Розмарин"},
        },
        ["d_plants_1_19"] = {
            {item = "Base.Rosemary", chance = 10, comment = "Розмарин"},
        },
        ["d_plants_1_8"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_9"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_10"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_11"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_12"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_13"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_14"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_15"] = {
            {item = "Hydrocraft.HCMandrake", chance = 2, comment = "Мандрагора"},
        },
        ["d_plants_1_38"] = {
            {item = "Hydrocraft.HCBelladonna", chance = 10, comment = "Белладонна"},
        },
        ["d_plants_1_39"] = {
            {item = "Hydrocraft.HCBelladonna", chance = 10, comment = "Белладонна"},
        },
    },
    
    -- Грибы (все сезоны)
    mushrooms = {
        {item = "Base.MushroomGeneric1", chance = 5, comment = "Съедобный гриб"},
        {item = "Base.MushroomGeneric2", chance = 5, comment = "Лесной гриб"},
        {item = "Base.MushroomGeneric3", chance = 5, comment = "Полевой гриб"},
        {item = "Base.MushroomGeneric4", chance = 5, comment = "Луговой гриб"},
        {item = "Base.MushroomGeneric5", chance = 5, comment = "Садовый гриб"},
        {item = "Base.MushroomGeneric6", chance = 3, comment = "Горный гриб"},
        {item = "Base.MushroomGeneric7", chance = 1, comment = "Болотный гриб"},
        {item = "Hydrocraft.HCLobstershroom", chance = 5, comment = "Лобстер-гриб"},
        {item = "Hydrocraft.HCYellowmorelshroom", chance = 3, comment = "Желтый сморчок"},
        {item = "Hydrocraft.HCWitchshatshroom", chance = 2, comment = "Ведьмина шляпа"},
        {item = "Hydrocraft.HCBlewitshroom", chance = 2, comment = "Рядовка"},
        {item = "Hydrocraft.HCChantrelle", chance = 2, comment = "Лисичка"},
    },
    
    -- Кормовые и технические (все сезоны)
    basic = {
        {item = "Hydrocraft.HCGrass", chance = 60, comment = "Трава"},
        {item = "Hydrocraft.HCStraw", chance = 30, comment = "Солома"},
        {item = "Hydrocraft.HCNettles", chance = 30, comment = "Крапива"},
        {item = "Base.Twigs", chance = 15, comment = "Веточки"},
        {item = "Hydrocraft.HCFlax", chance = 10, comment = "Лен"},
        {item = "Hydrocraft.HCJutestems", chance = 5, comment = "Стебли джута"},
        {item = "Hydrocraft.HCCottonseeds", chance = 20, comment = "Семена хлопка"},
        {item = "Hydrocraft.HCHempseeds", chance = 10, comment = "Семена конопли"},
        {item = "Hydrocraft.HCCandleberry", chance = 5, comment = "Восковая ягода"},
        {item = "Hydrocraft.HCRosebud", chance = 5, comment = "Бутон розы"},
        {item = "Hydrocraft.HCFlaxflower", chance = 1, comment = "Цветы льна"},
    },
}

local bushSprites = {} -- Список кустов и растений

for i = 0, 63 do -- Генерируем автоматически все спрайты от d_plants_1_0 до d_plants_1_63 для быстрого поиска
    table.insert(bushSprites, "d_plants_1_" .. i)
end

local bushSpriteSet = {} -- Быстрая проверка через хеш-таблицу
for _, sprite in ipairs(bushSprites) do
    bushSpriteSet[sprite] = true
end

local function isBush(spriteName)
    return bushSpriteSet[spriteName] ~= nil
end

ISWorldObjectContextMenu.onLootBush = function(worldobjects, square, player) -- player - iso
    local playerObj = player:getPlayerNum()
    local bo = ISLootPlantCursor:new(player, "grass")
	getCell():setDrag(bo, playerObj)
end

local function getBushObject(square)
	if not square then return nil end
	for i=1,square:getObjects():size() do
		local o = square:getObjects():get(i-1)
		if bushSpriteSet[o:getSprite():getName()] then
			return o
		end
	end
	return nil
end

local function currentSeason()
    local currentMonth = getGameTime():getMonth() -- Текущий месяц 1 - 12
    if currentMonth >= 3 and currentMonth <= 5 then
        season = "spring"
    elseif currentMonth >= 6 and currentMonth <= 8 then
        season = "summer"
    elseif currentMonth >= 9 and currentMonth <= 11 then
        season = "autumn"
    else
        season = "winter"
    end
    return season
end

function LootingBush(obj, player)
    local bush = getBushObject(obj)
    local lastLootTime = bush:getModData().TimeLoot or 0
    local respawnTime = bush:getModData().TimeRespawn or 0
    local currentTime = getGameTime():getWorldAgeHours()
    if lastLootTime~=0 and lastLootTime + respawnTime >= currentTime then return end
    local bushName = tostring(bush:getSprite():getName()) -- Получаем имя спрайта куста    
    local season = currentSeason() -- season = spring, summer, autumn, winter
    local bushLootingSeason = bushLoot[season][bushName] or {}
    local bushLootingStables = bushLoot.berries[bushName] or {}
    local bushLootingHerbs = bushLoot.herbs[bushName] or {}
    local bushLootingMushrooms = bushLoot.mushrooms or {}
    local bushLootingBasic = bushLoot.basic or {}
    local summaryLoot = {}
    for _, loot in ipairs(bushLootingSeason) do
        table.insert(summaryLoot, loot)
    end
    for _, loot in ipairs(bushLootingStables) do
        table.insert(summaryLoot, loot)
    end
    for _, loot in ipairs(bushLootingHerbs) do
        table.insert(summaryLoot, loot)
    end
    for _, loot in ipairs(bushLootingMushrooms) do
        table.insert(summaryLoot, loot)
    end
    for _, loot in ipairs(bushLootingBasic) do
        table.insert(summaryLoot, loot)
    end
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging)
    local isLucky = player:HasTrait("Lucky")
    local isUnlucky = player:HasTrait("Unlucky")
    local luckModifier = 0
    local count = 0
    local maxCount = ZombRand(1, 4)
    if isLucky then
        luckModifier = 3 -- Увеличиваем шанс выпадения на %
        maxCount = maxCount + ZombRand(0,1)
    elseif isUnlucky then
        luckModifier = -3 -- Уменьшаем шанс выпадения на %
    end
    for _, loot in ipairs(summaryLoot) do -- Лут для конкретного типа куста
        if count >= maxCount then break end
        local adjustedChance = loot.chance + foragingLevel + luckModifier -- Модифицируем шанс в зависимости от навыка и удачи/неудачи
        local random = ZombRand(0, 100)
        -- print("SL adjustedChance:", adjustedChance,"<= ", random ,adjustedChance >= random , " item:",loot.item)
        if random <= adjustedChance then
            -- print("SL:", loot.item, " chance:", adjustedChance, " random:", random)
            local item = player:getInventory():AddItem(loot.item)
            player:Say(getText("IGUI_Tree_Looting_Item") .. item:getDisplayName())
            count = count + 1
        end
    end
    -- print("ALL:",count)
    local xpAmount = 0.1 * count + (foragingLevel * 0.2) -- Базовое количество опыта с учетом уровня собирательства
    if xpAmount == 0 then xpAmount = 0.2 end --Даём гарантированный опыт
    player:getXp():AddXP(Perks.PlantScavenging, xpAmount)

    -- Обновление информацию о лутании
    local interval = ZombRand(6, 48) -- Респ 6-48 часов
    bush:getModData().TimeRespawn = interval
    bush:getModData().TimeLoot = getGameTime():getWorldAgeHours() -- Получаем текущее время в игровых часах
    bush:getModData().PlayerLooter = player:getUsername()
    bush:transmitModData() -- Трансмиттим моддату
end



function OnBushClick(playerNum, context, worldObjects)
    if SandboxVars.LootingSystem.TreeLooting == false then return end
    local player = getSpecificPlayer(playerNum)
    local canBeRemoved = nil
    local alreadyHandled = false
    for i, obj in ipairs(worldObjects) do
        -- print("SL:", obj:getSprite():getName())
        if isBush(obj:getSprite():getName()) and not alreadyHandled then
            alreadyHandled = true -- Устраняем дублирование контекстного меню
            if obj:getSprite() and obj:getSprite():getProperties() and obj:getSprite():getProperties():Is(IsoFlagType.canBeRemoved) then
                canBeRemoved = obj:getSquare()
            end
            context:addOption(getText("IGUI_Bush_Looting"), obj, ISWorldObjectContextMenu.onLootBush , canBeRemoved,  player) --CreateLootAction
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(OnBushClick)