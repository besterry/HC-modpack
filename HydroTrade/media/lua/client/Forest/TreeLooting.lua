--HCFern листья папоротника (в траву)
--HCFiddleheadfern рахисы папоротника (в траву)
-- Hydrocraft.HCRhododendron - Рододендрон (в цветы)
-- Hydrocraft.HCHawthornfruit - Плоды боярышника (в ягоды/кусты)

local treeLoot = { --Всех деревьев 8 типов (0-3 лето, 4-7 зима) 0 - молодое, 3 - старое
        --американский падуб (листовой)
        ["e_americanholly_1_0"] = {{ item = "Hydrocraft.HCBark", chance = 10 },{ item = "Hydrocraft.HCSprucebough", chance = 10 }, { item = "Hydrocraft.HCFirbough", chance = 10 }}, --Ель
        ["e_americanholly_1_1"] = {{ item = "Hydrocraft.HCFircone", chance = 15 }, { item = "Hydrocraft.HCBark", chance = 10 },{ item = "Hydrocraft.HCSprucebough", chance = 30 }, { item = "Hydrocraft.HCFirbough", chance = 20 }},
        ["e_americanholly_1_2"] = {{ item = "Hydrocraft.HCFircone", chance = 20 },{ item = "Hydrocraft.HCBark", chance = 25 },{ item = "Hydrocraft.HCSprucebough", chance = 40 }, { item = "Hydrocraft.HCFirbough", chance = 30 }}, --HCBark кора 
        ["e_americanholly_1_3"] = {{ item = "Hydrocraft.HCFircone", chance = 40 },{ item = "Hydrocraft.HCBark", chance = 35 }, { item = "Hydrocraft.HCSprucebough", chance = 50 }, { item = "Hydrocraft.HCFirbough", chance = 50 }}, --HCFircone - еловая шишка
        ["e_americanholly_1_4"] = {{ item = "Hydrocraft.HCBark", chance = 5 },{ item = "Hydrocraft.HCSprucebough", chance = 10 }, { item = "Hydrocraft.HCFirbough", chance = 5 }},
        ["e_americanholly_1_5"] = {{ item = "Hydrocraft.HCFircone", chance = 10 }, { item = "Hydrocraft.HCBark", chance = 10 },{ item = "Hydrocraft.HCSprucebough", chance = 30 }, { item = "Hydrocraft.HCFirbough", chance = 15 }}, --HCFirbough еловая ветвь (крафтовая)
        ["e_americanholly_1_6"] = {{ item = "Hydrocraft.HCFircone", chance = 15 },{ item = "Hydrocraft.HCBark", chance = 25 },{ item = "Hydrocraft.HCSprucebough", chance = 40 }, { item = "Hydrocraft.HCFirbough", chance = 25 }}, --HCSprucebough еловая ветвь
        ["e_americanholly_1_7"] = {{ item = "Hydrocraft.HCFircone", chance = 20 },{ item = "Hydrocraft.HCBark", chance = 35 }, { item = "Hydrocraft.HCSprucebough", chance = 50 }, { item = "Hydrocraft.HCFirbough", chance = 40 }},

        --Липа
        ["e_americanlinden_1_0"] = {{ item = "Hydrocraft.HCWillowbark", chance = 10 },{ item = "Hydrocraft.HCWillowbranch", chance = 20}}, --HCWillowbark кора ивы
        ["e_americanlinden_1_1"] = {{ item = "Hydrocraft.HCWillowbark", chance = 20 },{ item = "Hydrocraft.HCWillowbranch", chance = 30}}, --HCWillowbranch листья ивы
        ["e_americanlinden_1_2"] = {{ item = "Hydrocraft.HCWillowbark", chance = 30 },{ item = "Hydrocraft.HCWillowbranch", chance = 40}},
        ["e_americanlinden_1_3"] = {{ item = "Hydrocraft.HCWillowbark", chance = 40 },{ item = "Hydrocraft.HCWillowbranch", chance = 50}},
        ["e_americanlinden_1_4"] = {{ item = "Hydrocraft.HCWillowbark", chance = 20 },{ item = "Hydrocraft.HCWillowbranch", chance = 10}},
        ["e_americanlinden_1_5"] = {{ item = "Hydrocraft.HCWillowbark", chance = 30 },{ item = "Hydrocraft.HCWillowbranch", chance = 20}},
        ["e_americanlinden_1_6"] = {{ item = "Hydrocraft.HCWillowbark", chance = 30 },{ item = "Hydrocraft.HCWillowbranch", chance = 30}},
        ["e_americanlinden_1_7"] = {{ item = "Hydrocraft.HCWillowbark", chance = 40 },{ item = "Hydrocraft.HCWillowbranch", chance = 35}},

        --канадский болиголов (ель)
        ["e_canadianhemlock_1_0"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 20 },{ item = "Hydrocraft.HCHickoryleaves", chance = 10 }}, --HCHickorynuts - грецкий орех
        ["e_canadianhemlock_1_1"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 30 },{ item = "Hydrocraft.HCHickoryleaves", chance = 20 }}, --HCHickoryleaves Листья с ореха
        ["e_canadianhemlock_1_2"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 40 },{ item = "Hydrocraft.HCHickoryleaves", chance = 40 }}, 
        ["e_canadianhemlock_1_3"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 50 },{ item = "Hydrocraft.HCHickoryleaves", chance = 50 }},
        ["e_canadianhemlock_1_4"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 10 },{ item = "Hydrocraft.HCHickoryleaves", chance = 10 }},
        ["e_canadianhemlock_1_5"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 20 },{ item = "Hydrocraft.HCHickoryleaves", chance = 20 }},
        ["e_canadianhemlock_1_6"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 30 },{ item = "Hydrocraft.HCHickoryleaves", chance = 30 }},
        ["e_canadianhemlock_1_7"] = {{ item = "Hydrocraft.HCHickorynuts", chance = 40 },{ item = "Hydrocraft.HCHickoryleaves", chance = 40 }},

        --Халезия каролинская, или "Ландышевое дерево" — вид листопадных деревьев рода Халезия, семейства Стираксовые, произрастающих в Северной Америке.
        ["e_carolinasilverbell_1_0"] = {{  item = "Hydrocraft.HCBeechnut", chance = 20 },{  item = "Hydrocraft.HCYewbough", chance = 20}}, --HCBeechnut - Буковый орех
        ["e_carolinasilverbell_1_1"] = {{  item = "Hydrocraft.HCBeechnut", chance = 30 },{  item = "Hydrocraft.HCYewbough", chance = 30}}, -- Hydrocraft.HCYewbough - Тисовая ветвь
        ["e_carolinasilverbell_1_2"] = {{  item = "Hydrocraft.HCBeechnut", chance = 40 },{  item = "Hydrocraft.HCYewbough", chance = 40}},
        ["e_carolinasilverbell_1_3"] = {{  item = "Hydrocraft.HCBeechnut", chance = 50 },{  item = "Hydrocraft.HCYewbough", chance = 50}},
        ["e_carolinasilverbell_1_4"] = {{  item = "Hydrocraft.HCBeechnut", chance = 10 },{  item = "Hydrocraft.HCYewbough", chance = 20}},
        ["e_carolinasilverbell_1_5"] = {{  item = "Hydrocraft.HCBeechnut", chance = 20 },{  item = "Hydrocraft.HCYewbough", chance = 30}},
        ["e_carolinasilverbell_1_6"] = {{  item = "Hydrocraft.HCBeechnut", chance = 30 },{  item = "Hydrocraft.HCYewbough", chance = 40}},
        ["e_carolinasilverbell_1_7"] = {{  item = "Hydrocraft.HCBeechnut", chance = 40 },{  item = "Hydrocraft.HCYewbough", chance = 50}},

        --Боя́рышник пету́шья шпо́ра, или Боярышник шпо́рцевый, — дерево, вид рода Боярышник семейства Розовые.
        ["e_cockspurhawthorn_1_0"] = {{ item = "Hydrocraft.HCChestnut", chance = 20 },{ item = "Hydrocraft.HCElmbough", chance = 20 }}, -- HCChestnut --Каштан
        ["e_cockspurhawthorn_1_1"] = {{ item = "Hydrocraft.HCChestnut", chance = 30 },{ item = "Hydrocraft.HCElmbough", chance = 30 }}, -- Hydrocraft.HCElmbough - Ветвь вяза
        ["e_cockspurhawthorn_1_2"] = {{ item = "Hydrocraft.HCChestnut", chance = 40 },{ item = "Hydrocraft.HCElmbough", chance = 40 }},
        ["e_cockspurhawthorn_1_3"] = {{ item = "Hydrocraft.HCChestnut", chance = 50 },{ item = "Hydrocraft.HCElmbough", chance = 50 }},
        ["e_cockspurhawthorn_1_4"] = {{ item = "Hydrocraft.HCChestnut", chance = 10 },{ item = "Hydrocraft.HCElmbough", chance = 20 }},
        ["e_cockspurhawthorn_1_5"] = {{ item = "Hydrocraft.HCChestnut", chance = 20 },{ item = "Hydrocraft.HCElmbough", chance = 30 }},
        ["e_cockspurhawthorn_1_6"] = {{ item = "Hydrocraft.HCChestnut", chance = 30 },{ item = "Hydrocraft.HCElmbough", chance = 40 }},
        ["e_cockspurhawthorn_1_7"] = {{ item = "Hydrocraft.HCChestnut", chance = 40 },{ item = "Hydrocraft.HCElmbough", chance = 50 }},

        --Кизи́л, или Дёрен, — род растений семейства Кизиловые, включающий более 50 видов. В основном это древесные листопадные растения, жизненная форма которых — деревья или кустарники. Некоторые виды — травянистые многолетние растения, несколько видов — древесные вечнозелёные
        ["e_dogwood_1_0"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 20 }}, --HCMulberryleaf листья шелковицы
        ["e_dogwood_1_1"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 30 }},
        ["e_dogwood_1_2"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 40 }},
        ["e_dogwood_1_3"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 50 }},
        ["e_dogwood_1_4"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 10 }},
        ["e_dogwood_1_5"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 20 }},
        ["e_dogwood_1_6"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 30 }},
        ["e_dogwood_1_7"] = {{ item = "Hydrocraft.HCMulberryleaf", chance = 40 }},

        --Багрянник канадский, или Церцис канадский — деревья, вид рода Церцис семейства Бобовые
        ["e_easternredbud_1_0"] = {{ item = "Base.Cherry", chance = 30},{ item = "Hydrocraft.HCAlderboug", chance = 20}}, --Base.Cherry вишня
        ["e_easternredbud_1_1"] = {{ item = "Base.Cherry", chance = 40},{ item = "Hydrocraft.HCAlderboug", chance = 30}}, -- Hydrocraft.HCAlderboug - Ветвь ольхи
        ["e_easternredbud_1_2"] = {{ item = "Base.Cherry", chance = 50},{ item = "Hydrocraft.HCAlderboug", chance = 40}},
        ["e_easternredbud_1_3"] = {{ item = "Base.Cherry", chance = 60},{ item = "Hydrocraft.HCAlderboug", chance = 50}},
        ["e_easternredbud_1_4"] = {{ item = "Base.Cherry", chance = 20},{ item = "Hydrocraft.HCAlderboug", chance = 20}},
        ["e_easternredbud_1_5"] = {{ item = "Base.Cherry", chance = 25},{ item = "Hydrocraft.HCAlderboug", chance = 30}},
        ["e_easternredbud_1_6"] = {{ item = "Base.Cherry", chance = 30},{ item = "Hydrocraft.HCAlderboug", chance = 40}},
        ["e_easternredbud_1_7"] = {{ item = "Base.Cherry", chance = 35},{ item = "Hydrocraft.HCAlderboug", chance = 50}},

        --Клён кра́сный — листопадное дерево, одно из наиболее часто встречающихся в восточной части Северной Америки; вид рода Клён семейства Сапиндовые.
        ["e_redmaple_1_0"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 20}},--HCMapleleaf кленовый лист
        ["e_redmaple_1_1"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 40}},
        ["e_redmaple_1_2"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 50}},
        ["e_redmaple_1_3"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 60}},
        ["e_redmaple_1_4"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 20}},
        ["e_redmaple_1_5"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 30}},
        ["e_redmaple_1_6"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 40}},
        ["e_redmaple_1_7"] = {{ item = "Hydrocraft.HCMapleleaf", chance = 50}},

        --Берёза чёрная, или речна́я — вид растений рода Берёза семейства Берёзовые
        ["e_riverbirch_1_0"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 20},{ item = "Hydrocraft.HCBirchbark", chance = 20}}, --HCBirchcatkin березовая сережка
        ["e_riverbirch_1_1"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 30},{ item = "Hydrocraft.HCBirchbark", chance = 30}}, --HCBirchbark береста
        ["e_riverbirch_1_2"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 40},{ item = "Hydrocraft.HCBirchbark", chance = 40}},
        ["e_riverbirch_1_3"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 45},{ item = "Hydrocraft.HCBirchbark", chance = 45}},
        ["e_riverbirch_1_4"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 10},{ item = "Hydrocraft.HCBirchbark", chance = 10}},
        ["e_riverbirch_1_5"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 20},{ item = "Hydrocraft.HCBirchbark", chance = 20}},
        ["e_riverbirch_1_6"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 30},{ item = "Hydrocraft.HCBirchbark", chance = 30}},
        ["e_riverbirch_1_7"] = {{ item = "Hydrocraft.HCBirchcatkin", chance = 40},{ item = "Hydrocraft.HCBirchbark", chance = 40}},

        --Сосна виргинская — североамериканский вид растений рода Сосна семейства Сосновые
        ["e_virginiapine_1_0"] = {{ item = "Hydrocraft.HCPinenuts", chance = 20},{ item = "Hydrocraft.HCPinebough", chance = 20},{ item = "Base.Pinecone", chance = 20}}, --HCPinenuts - орешки
        ["e_virginiapine_1_1"] = {{ item = "Hydrocraft.HCPinenuts", chance = 30},{ item = "Hydrocraft.HCPinebough", chance = 30},{ item = "Base.Pinecone", chance = 30}}, --HCPinebough Сосновая ветвь
        ["e_virginiapine_1_2"] = {{ item = "Hydrocraft.HCPinenuts", chance = 40},{ item = "Hydrocraft.HCPinebough", chance = 40},{ item = "Base.Pinecone", chance = 40}}, --Pinecone Сосновая шишка
        ["e_virginiapine_1_3"] = {{ item = "Hydrocraft.HCPinenuts", chance = 50},{ item = "Hydrocraft.HCPinebough", chance = 50},{ item = "Base.Pinecone", chance = 50}},
        ["e_virginiapine_1_4"] = {{ item = "Hydrocraft.HCPinenuts", chance = 10},{ item = "Hydrocraft.HCPinebough", chance = 10},{ item = "Base.Pinecone", chance = 10}},
        ["e_virginiapine_1_5"] = {{ item = "Hydrocraft.HCPinenuts", chance = 20},{ item = "Hydrocraft.HCPinebough", chance = 20},{ item = "Base.Pinecone", chance = 20}},
        ["e_virginiapine_1_6"] = {{ item = "Hydrocraft.HCPinenuts", chance = 30},{ item = "Hydrocraft.HCPinebough", chance = 30},{ item = "Base.Pinecone", chance = 30}},
        ["e_virginiapine_1_7"] = {{ item = "Hydrocraft.HCPinenuts", chance = 40},{ item = "Hydrocraft.HCPinebough", chance = 40},{ item = "Base.Pinecone", chance = 40}},

        --Кладрастис кентуккийский, или жёлтый — вид реликтовых листопадных деревьев семейства Бобовые, произрастающих в юго-восточной части Северной Америки.
        ["e_yellowwood_1_0"] = {{ item = "Hydrocraft.HCAcorn", chance = 20},{ item = "Hydrocraft.HCOakleaves", chance = 20},{ item = "Base.Acorn", chance = 20},{ item = "Hydrocraft.HCOakLog", chance = 40},{ item = "Base.Apple", chance = 20}}, --HCAcorn - желудь
        ["e_yellowwood_1_1"] = {{ item = "Hydrocraft.HCAcorn", chance = 30},{ item = "Hydrocraft.HCOakleaves", chance = 30},{ item = "Base.Acorn", chance = 30},{ item = "Hydrocraft.HCOakLog", chance = 50},{ item = "Base.Apple", chance = 40}}, --HCOakleaves листья дуба
        ["e_yellowwood_1_2"] = {{ item = "Hydrocraft.HCAcorn", chance = 40},{ item = "Hydrocraft.HCOakleaves", chance = 40},{ item = "Base.Acorn", chance = 40},{ item = "Hydrocraft.HCOakLog", chance = 60},{ item = "Base.Apple", chance = 50}}, --Base.Acorn - Жёлудь (свежее)
        ["e_yellowwood_1_3"] = {{ item = "Hydrocraft.HCAcorn", chance = 50},{ item = "Hydrocraft.HCOakleaves", chance = 50},{ item = "Base.Acorn", chance = 50},{ item = "Hydrocraft.HCOakLog", chance = 70},{ item = "Base.Apple", chance = 60}}, --Hydrocraft.HCOakLog - Дубовое бревно
        ["e_yellowwood_1_4"] = {{ item = "Hydrocraft.HCAcorn", chance = 10},{ item = "Hydrocraft.HCOakleaves", chance = 10},{ item = "Base.Acorn", chance = 10},{ item = "Hydrocraft.HCOakLog", chance = 40},{ item = "Base.Apple", chance = 10}}, --Base.Apple яблоко
        ["e_yellowwood_1_5"] = {{ item = "Hydrocraft.HCAcorn", chance = 20},{ item = "Hydrocraft.HCOakleaves", chance = 20},{ item = "Base.Acorn", chance = 20},{ item = "Hydrocraft.HCOakLog", chance = 50},{ item = "Base.Apple", chance = 20}},
        ["e_yellowwood_1_6"] = {{ item = "Hydrocraft.HCAcorn", chance = 30},{ item = "Hydrocraft.HCOakleaves", chance = 30},{ item = "Base.Acorn", chance = 30},{ item = "Hydrocraft.HCOakLog", chance = 60},{ item = "Base.Apple", chance = 30}},
        ["e_yellowwood_1_7"] = {{ item = "Hydrocraft.HCAcorn", chance = 40},{ item = "Hydrocraft.HCOakleaves", chance = 40},{ item = "Base.Acorn", chance = 40},{ item = "Hydrocraft.HCOakLog", chance = 70},{ item = "Base.Apple", chance = 40}},
}

local defaultLoot = { --Лут который будет падать со всех деревьев
    { item = "Base.Log", chance = 1 },  -- % шанс выпадения бревна
    { item = "Base.TreeBranch", chance = 20 },  -- % шанс выпадения древесной ветви
    { item = "Base.Twigs", chance = 40 },   -- % шанс выпадения маленьких веток
    --{ item = "Hydrocraft.HCQuill", chance = 5 },  -- % шанс выпадения пера
    { item = "Hydrocraft.HCWhitefeathers", chance = 2 },  -- % шанс выпадения белого пера HCWhitefeathers
    { item = "Hydrocraft.HCBlackfeathers", chance = 2 },  -- % шанс выпадения черного пера  HCBlackfeathers
    { item = "Hydrocraft.HCBrownfeathers", chance = 2 },  -- % шанс выпадения коричневого пера HCBrownfeathers
    { item = "Hydrocraft.HCRedfeather", chance = 2 },  -- % шанс выпадения красного пера HCRedfeather
    { item = "Hydrocraft.HCBluejayfeather", chance = 2 },  -- % шанс выпадения синего пера HCBluejayfeather
    { item = "Hydrocraft.HCStripedfeather", chance = 2 },  -- % шанс выпадения полосатого пера HCStripedfeather
    { item = "Base.Egg", chance = 1 },  -- % шанс выпадения яйца Base.Egg
    { item = "Hydrocraft.HCGooseegg", chance = 1 },  -- % шанс выпадения гусиного яйца
    { item = "Hydrocraft.HCTurkeyegg", chance = 1 },  -- % шанс выпадения индюшачьего яйца
    { item = "Hydrocraft.HCChickenegg", chance = 1 },  -- % шанс выпадения куринного яйца
}

ISWorldObjectContextMenu.onLootTree = function(worldobjects, playerObj, tree) --Создание элемента выделения дерева для лута
    local bo = ISLootTreeCursor:new(nil, nil, playerObj)
	-- local bo = ISTreeLootAction:new(playerObj, worldobjects, 200)
	getCell():setDrag(bo, playerObj:getPlayerNum())
end


function LootingTree(obj, player)
    local lastLootTime = obj:getModData().TimeLoot or 0
    local respawnTime = obj:getModData().TimeRespawn or 0
    local currentTime = getGameTime():getWorldAgeHours()
    --print( lastLootTime + respawnTime ," <= " , currentTime)
    if lastLootTime~=0 and lastLootTime + respawnTime >= currentTime then return end

    local treeName = tostring(obj:getSprite():getName()) -- Получаем имя спрайта
    -- print("Original treeName:", treeName)
    treeName = string.gsub(treeName, "JUMBO", "")
    -- print("treeName:", treeName, " treeLoot[treeName]:" ,treeLoot[treeName])
    local lootTable = treeLoot[treeName] or {} -- Получаем таблицу лута для конкретного типа дерева или пустую таблицу
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) -- Уровень собирательства игрока
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
    for _, loot in ipairs(lootTable) do -- Лут для конкретного типа дерева
        if count >= maxCount then break end
        local adjustedChance = loot.chance + foragingLevel + luckModifier -- Модифицируем шанс в зависимости от навыка и удачи/неудачи
        local random = ZombRand(0, 100)
        -- print("SL adjustedChance:", adjustedChance,"<= ", random ,adjustedChance >= random , " item:",loot.item)
        if random <= adjustedChance then
            -- print("SL:", loot.item, " chance:", adjustedChance, " random:", random)
            player:getInventory():AddItem(loot.item)
            count = count + 1
        end
    end

    for _, loot in ipairs(defaultLoot) do -- Лут по умолчанию для всех деревьев
        if count >= maxCount then break end
        local adjustedChance = loot.chance + foragingLevel + luckModifier -- Модифицируем шанс для лута по умолчанию (если 1% шанса дропа вещи: 1% + уроень собирательства (max=10%) + удача/неудача(+-3%) = 0-13% шанса дропа вещи со всеми модификаторами)       
        local random = ZombRand(0, 100)
        --print("SL adjustedChance:", adjustedChance,"<= ", random , adjustedChance >= random , " item:",loot.item)
        if random <= adjustedChance then
            -- print("DL:", loot.item, " chance:", adjustedChance, " random:", random)
            player:getInventory():AddItem(loot.item)
            count = count + 1
        end
    end
    -- print("ALL:",count)
    local xpAmount = 0.1 * count + (foragingLevel * 0.2) -- Базовое количество опыта с учетом уровня собирательства
    if xpAmount == 0 then xpAmount = 0.2 end --Даём гарантированный опыт
    player:getXp():AddXP(Perks.PlantScavenging, xpAmount)

    -- Обновление информацию о лутании
    local interval = ZombRand(1, 2) -- Респ 6-48 часов
    obj:getModData().TimeRespawn = interval
    obj:getModData().TimeLoot = getGameTime():getWorldAgeHours() -- Получаем текущее время в игровых часах
    obj:getModData().PlayerLooter = player:getUsername()
    -- Трансмиттим моддату
    obj:transmitModData()
end

function OnTreeClick(playerNum, context, worldObjects)
    if SandboxVars.LootingSystem.TreeLooting == false then return end
    local player = getSpecificPlayer(playerNum)
    local alreadyHandled = false
    for i, obj in ipairs(worldObjects) do
        if instanceof(obj, "IsoTree") and not alreadyHandled then
            -- print("Tree: ", obj:getSprite():getName())      
            alreadyHandled = true -- Устраняем дублирование контекстного меню
            -- local lastLootTime = obj:getModData().TimeLoot or 0
            -- local respawnTime = obj:getModData().TimeRespawn or 0
            -- if lastLootTime + respawnTime > getGameTime():getWorldAgeHours() then --Если дерево уже луталось за LootTime часов
            --     local option = context:addOption(getText(getText("IGUI_Tree_Already_Looting")), obj, nil, nil)
            --     option.notAvailable = true
            --     local toolTip = ISToolTip:new()
            --     toolTip:initialise()
            --     toolTip:setVisible(false)
            --     toolTip.description = getText(getText("IGUI_You_cannot_loot_this_tree_again_so_soon_Please_wait"))
            --     option.toolTip = toolTip
            -- else
                context:addOption(getText("IGUI_Tree_Looting"), obj, ISWorldObjectContextMenu.onLootTree , player) --CreateLootAction
            -- end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(OnTreeClick)



-- local function CreateLootAction(obj, player) -- Создаём действие для выполнения анимации и лутания
--     if luautils.walkAdj(player, obj:getSquare(), true) then
--         ISTimedActionQueue.add(ISTreeLootAction:new(player, obj, 200))
--     end
-- end