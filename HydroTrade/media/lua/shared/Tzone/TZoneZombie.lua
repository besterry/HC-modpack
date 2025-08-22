if isServer() then return end
TZone = TZone or {}
local ZombieSprinter = SandboxVars.ToxicZone.ZombieSprinter or false -- настройка песочницы: будут ли зомби спринтеры
local ZombieSprinterChance = SandboxVars.ToxicZone.SprinterChance or 1 -- настройка песочницы: шанс появления спринтера при ударе
local ZombieSprinterRadius = SandboxVars.ToxicZone.SprinterRadius or 30 -- настройка песочницы: радиус привлечения зомби спринтером
local ZombieSprinterMax = SandboxVars.ToxicZone.SprinterMax or 1 -- настройка песочницы: максимум спринтеров за удар
local tickCounter = 0   
local unicalLoot = {
    --предмет и шанс выпадения 1 * 1/500 = 0.2%
    {"Base.EventCoin", 15}, -- монета 3%
    {"Hydrocraft.GasFilterUsed", 5}, -- использованный фильтр для газа 1%
    {"Base.HazmatSuit", 0.1}, -- хим костюм 0.2%
    {"Base.ShotgunShellsBox", 2}, -- коробка с патронами для дробовика 0.4%
    {"injectorItems.injector_adrenaline", 0.5}, -- адреналин 0.2%
    {"injectorItems.injector_ahf1", 0.5}, -- аф1 0.2%
    {"injectorItems.injector_btg2a2", 0.5}, -- бтг2а2 0.2%
    {"injectorItems.injector_btg3", 0.5}, -- бтг3 0.2%
    {"injectorItems.injector_etg", 0.5}, -- этг 1%
    {"injectorItems.injector_meldonin", 0.5}, -- мелдонин 0.2%
    {"injectorItems.injector_morphine", 0.5}, -- морфин 0.2%
    {"injectorItems.injector_mule", 0.5}, -- муле 0.2%
    {"injectorItems.injector_norepinephrine", 0.5}, -- норепинефрин 0.2%
    {"injectorItems.injector_obdolbos", 0.5}, -- обдолбос 0.2%
    {"injectorItems.injector_obdolbos2", 0.5}, -- обдолбос2 0.2%
    {"injectorItems.injector_p22", 0.5}, -- п22 0.2%
    {"injectorItems.injector_perfotoran", 0.5}, -- перфоторан 0.2%
    {"injectorItems.injector_pnb", 0.5}, -- пнб 0.2%
    {"injectorItems.injector_propital", 0.5}, -- пропитал 1%
    {"injectorItems.injector_sj1", 0.5}, -- сж1 0.2%
    {"injectorItems.injector_sj6", 0.5}, -- сж6 0.2%
    {"injectorItems.injector_sj9", 0.5}, -- сж9 0.2%
    {"injectorItems.injector_sj12", 0.5}, -- сж12 0.2%
    {"injectorItems.injector_trimadol", 0.5}, -- тримадол 0.2%
    {"injectorItems.injector_xtg", 0.5}, -- этг 0.2%
    {"injectorItems.injector_zagustin", 0.5} -- загустин 0.2%
}

local function OnHitZombie(player, zombie, bodyPart, damage) -- При ударе по зомби в зоне
    ZombieSprinter = SandboxVars.ToxicZone.ZombieSprinter or false -- Повторная проверка включено ли в настройках песочницы (если админ изменил настройку)
    if not ZombieSprinter then return end -- проверка включено ли в настройках песочницы
    if TZone.isPlayerInTZone(zombie) then
        ZombieSprinterChance = SandboxVars.ToxicZone.SprinterChance or 1 -- Повторная проверка шанса срабатывания при ударе (если админ изменил настройку)
        if ZombRand(100) < ZombieSprinterChance then -- 1% шанс срабатывания при ударе
            local cell = getCell()
            local zombies = cell:getZombieList()
            local playerX = player:getX()
            local playerY = player:getY()       
            -- Ограничиваем количество спринтеров
            ZombieSprinterMax = SandboxVars.ToxicZone.SprinterMax or 1
            local maxSprinters = ZombieSprinterMax -- максимум 2 спринтера
            local currentSprinters = 0
            for i = 0, zombies:size() - 1 do
                -- Оптимизация: проверяем лимит в начале
                if currentSprinters >= maxSprinters then break end
                
                local nearbyZombie = zombies:get(i)
                if nearbyZombie and nearbyZombie:isAlive() then
                    local zombieX = nearbyZombie:getX()
                    local zombieY = nearbyZombie:getY()
                    local distance = math.sqrt((playerX - zombieX)^2 + (playerY - zombieY)^2)
                    -- Только зомби в радиусе 8 тайлов
                    if distance >= 2 and distance <= 10 then -- 2-10 тайлов от игрока, что бы игрок успел срегагировать
                        nearbyZombie:setTarget(player) -- Делаем игрока целью зомби
                        nearbyZombie:playSound("Sprinter_Screech_" .. ZombRand(1, 6)) -- Делаем звук спринтера
                        nearbyZombie:setWalkType("sprint"..tostring(ZombRand(1, 5))) -- Делаем зомби спринтером                        
                        nearbyZombie:getModData().sprinterActivated = true -- вешаем флаг на зомби, что он спринтер
                        currentSprinters = currentSprinters + 1 -- увеличиваем счетчик спринтеров
                        -- Привлекаем зомби к игроку
                        ZombieSprinterRadius = SandboxVars.ToxicZone.SprinterRadius or 30
                        addSound(player, playerX, playerY, 0, ZombieSprinterRadius, 90)                        
                        -- Создаем отложенные звуки для повторения звука спринтера
                        local function createDelayedSound(delay)
                            local tickCount = 0
                            local function delayedSound()
                                tickCount = tickCount + 1
                                if tickCount == delay then
                                    addSound(player, playerX, playerY, 0, ZombieSprinterRadius, 90)
                                    Events.OnTick.Remove(delayedSound)
                                end
                            end
                            Events.OnTick.Add(delayedSound)
                        end                        
                        -- Добавляем отложенные звуки
                        createDelayedSound(30)
                        createDelayedSound(60)
                    end
                end
            end
        end
    end
end

local function onZombieUpdate(zombie)
    tickCounter = tickCounter + 1
    if tickCounter < 500 then
        return
    end
    tickCounter = 0    
    if TZone.isPlayerInTZone(zombie) then
        local modData = zombie:getModData()
        if modData.sprinterActivated then            
            if zombie:isAlive() and not zombie:getTarget() then
                zombie:setWalkType("slow"..tostring(ZombRand(1, 4)))
                modData.sprinterActivated = nil
            end
        end
    end
end

local function SpawnLoot(zombie)
    if TZone.isPlayerInTZone(zombie) then -- проверяем, находится ли зомби в зоне
        local lootCount = ZombRand(0, #unicalLoot) -- выбираем случайное количество предметов        
        for i = 1, lootCount do
            local randomIndex = ZombRand(1, #unicalLoot + 1)
            local lootData = unicalLoot[randomIndex]
            if lootData then
                local itemType = lootData[1] -- название предмета
                local chance = lootData[2] -- шанс выпадения
                if ZombRand(1, 100) <= chance then -- Шанс выпадения в 0.2%
                    local item = itemType
                    if item then
                        zombie:getInventory():AddItem(item)
                    end
                end
            end
        end
    end
end

Events.OnHitZombie.Add(OnHitZombie)
Events.OnZombieDead.Add(SpawnLoot)
Events.OnZombieUpdate.Add(onZombieUpdate)