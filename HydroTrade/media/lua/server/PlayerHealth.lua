if isClient() then return end
local MOD_NAME = "PlayerHealth"
local Commands = {}

Commands.onGetFullPlayerData = function(player, args)
    local playerInfo = args
    
    if writeLog then
        local msg = ""
        
        -- Базовая информация
        if playerInfo.player then
            msg = msg .. "Name: " .. tostring(playerInfo.player.username or "N/A") .. " | "
            -- msg = msg .. "SteamID: " .. tostring(playerInfo.player.steamId or "N/A") .. " | " -- Кривое отображение
        end
        
        -- Позиция
        if playerInfo.position then
            msg = msg .. "(" .. tostring(playerInfo.position.x or 0) .. ", " .. tostring(playerInfo.position.y or 0) .. ", " .. tostring(playerInfo.position.z or 0) .. ") | "
            msg = msg .. "Inside: " .. tostring(playerInfo.position.inside and "Yes" or "No") .. " | "
            msg = msg .. "Toxic: " .. tostring(playerInfo.position.toxic and "Yes" or "No") .. " | "
        end
        
        -- Основное здоровье
        if playerInfo.health then
            msg = msg .. "Health: " .. string.format("%.1f", playerInfo.health.health or 0) .. " | "
            msg = msg .. "Poison: " .. string.format("%.1f", playerInfo.health.poison or 0) .. " | "
            msg = msg .. "FoodSick: " .. string.format("%.1f", playerInfo.health.foodSick or 0) .. " | "
            
            -- Простуда
            msg = msg .. "Cold: " .. tostring(playerInfo.health.coldStr or 0) .. " (Has: " .. tostring(playerInfo.health.hasCold or 0) .. ") | "
            msg = msg .. "CatchACold: " .. string.format("%.2f", playerInfo.health.catchACold or 0) .. " | "
            msg = msg .. "ColdDamageStage: " .. string.format("%.2f", playerInfo.health.coldDamageStage or 0) .. " | "
            
            -- Температура
            msg = msg .. "TempBD: " .. string.format("%.2f", playerInfo.health.tempBD or 0) .. " | "
            msg = msg .. "Temp: " .. string.format("%.2f", playerInfo.health.temp or 0) .. " | "
            msg = msg .. "Wet: " .. string.format("%.1f", playerInfo.health.wet or 0) .. " | "
            msg = msg .. "OnFire: " .. tostring(playerInfo.health.onFire or 0) .. " | "
            
            -- Инфекция
            msg = msg .. "Infection: " .. string.format("%.2f", playerInfo.health.infectionLevel or 0) .. " | "
            msg = msg .. "FakeInfection: " .. string.format("%.2f", playerInfo.health.fakeInfectionLevel or 0) .. " | "
            msg = msg .. "IsInfected: " .. tostring(playerInfo.health.isInfected or 0) .. " | "
            msg = msg .. "ApparentInfection: " .. string.format("%.2f", playerInfo.health.apparentInfectionLevel or 0) .. " | "
            
            -- Боль
            msg = msg .. "PainReduction: " .. string.format("%.2f", playerInfo.health.painReduction or 0) .. " | "
            msg = msg .. "RemotePainLevel: " .. tostring(playerInfo.health.remotePainLevel or 0) .. " | "
            
            -- Счетчики повреждений
            msg = msg .. "Bitten: " .. tostring(playerInfo.health.numPartsBitten or 0) .. " | "
            msg = msg .. "Bleeding: " .. tostring(playerInfo.health.numPartsBleeding or 0) .. " | "
            msg = msg .. "Scratched: " .. tostring(playerInfo.health.numPartsScratched or 0) .. " | "
            
            -- Здоровье от еды
            msg = msg .. "HealthFromFood: " .. string.format("%.2f", playerInfo.health.healthFromFood or 0) .. " | "
            msg = msg .. "HealthRaw: " .. string.format("%.2f", playerInfo.health.healthRaw or 0) .. " | "
            
            -- Паника и скука
            msg = msg .. "Panic: " .. string.format("%.2f", playerInfo.health.panicIncreaseValue or 0) .. " | "
            msg = msg .. "Boredom: " .. string.format("%.2f", playerInfo.health.boredomLevel or 0) .. " | "
            msg = msg .. "Unhappiness: " .. string.format("%.2f", playerInfo.health.unhappinessLevel or 0) .. " | "
            
            -- Алкоголь
            msg = msg .. "Drunk: " .. string.format("%.2f", playerInfo.health.drunkIncreaseValue or 0) .. " | "
            
            -- Чихание
            msg = msg .. "SneezeActive: " .. tostring(playerInfo.health.sneezeCoughActive or 0) .. " | "
            msg = msg .. "TimeToSneeze: " .. tostring(playerInfo.health.timeToSneezeOrCough or 0) .. " | "
            msg = msg .. "TempTick: " .. string.format("%.2f", playerInfo.health.temperatureChangeTick or 0) .. " | "
            -- Зомби
            msg = msg .. "ZombiesVisible: " .. tostring(playerInfo.health.currentNumZombiesVisible or 0) .. " | "
            
            -- Травмы
            if playerInfo.health.injuries and #playerInfo.health.injuries > 0 then
                msg = msg .. "Injuries: " .. table.concat(playerInfo.health.injuries, "; ") .. " | "
            else
                msg = msg .. "Injuries: None | "
            end
        end
        
        -- Статистики
        if playerInfo.stats then
            msg = msg .. "Hunger: " .. string.format("%.2f", playerInfo.stats.hunger or 0) .. " | "
            msg = msg .. "Thirst: " .. string.format("%.2f", playerInfo.stats.thirst or 0) .. " | "
            msg = msg .. "Fatigue: " .. string.format("%.2f", playerInfo.stats.fatigue or 0) .. " | "
            msg = msg .. "Endurance: " .. string.format("%.2f", playerInfo.stats.endurance or 0) .. " | "
            msg = msg .. "Pain: " .. string.format("%.2f", playerInfo.stats.pain or 0) .. " | "
            msg = msg .. "Stress: " .. string.format("%.2f", playerInfo.stats.stress or 0)
        end
        
        writeLog("PlayerHealth", msg)
    end
end

local OnClientCommand = function(module, command, player, args) 
    if module == MOD_NAME and Commands[command] then
        Commands[command](player, args)
    end
end
Events.OnClientCommand.Add(OnClientCommand)

local function getPlayerInfo()
    sendServerCommand(MOD_NAME, "getFullPlayerData", {})
end
Events.EveryHours.Add(getPlayerInfo)