-- Система защиты для новичков 
-- NOTE: временно реализована на основе времени выживания
local textManager = getTextManager();
local screenX = 150; --65
local screenY = 5; --13
local protectionTime = SandboxVars.UdderlySafeLogin.Protection or 1
local protectionDeactivated = false

local function newPlayerDeffenceCheck() --Проверка на время защиты
    local player = getPlayer()
    if player then
        local hoursSurvived = player:getHoursSurvived()
        if hoursSurvived > protectionTime then
            player:setZombiesDontAttack(false)
            if not protectionDeactivated then
                player:setHaloNote(getText("IGUI_Protection_deactivated"), 236, 131, 190, 50)
                protectionDeactivated = true
            end
        else
            player:setZombiesDontAttack(true)
            if protectionDeactivated then
                player:setHaloNote(getText("IGUI_Protection_will_activated"), 236, 131, 190, 50)
                protectionDeactivated = false
            end
        end
    end
end


local function ShowProtectionTime()
    if isAdmin() then return end
    local player = getPlayer()
    local hoursSurvived = player:getHoursSurvived()
    newPlayerDeffenceCheck()
    -- if not player or isAdmin() then return end
    local time = protectionTime - hoursSurvived --Часы 0.125122231, нужны часы и минуты
    local hours = math.floor(time)
    local minutes = math.floor((time - hours) * 60)
    local timeString = hours .. ":" .. minutes

    if time >= 0 then
        textManager:DrawString(UIFont.Large, screenX+1, screenY+1, getText("IGUI_Protection_activated") .. timeString, 0, 0, 0, 1);
        textManager:DrawString(UIFont.Large, screenX, screenY, getText("IGUI_Protection_activated") .. timeString, 1.0, 1.0, 0.0, 1.0);
    end
end

Events.OnGameStart.Add(function()
	Events.OnPostUIDraw.Add(ShowProtectionTime);
end)


-- local function newPlayerDeffence() --Включение защиты для нового игрока
--     local player = getPlayer()
--     if player then
--         local modData = player:getModData()
--         -- Добавляем в моддату игрока время, когда он зашел в игру
--         if not modData.newPlayerDeffence then
--             modData.newPlayerDeffence = true
--             modData.newPlayerDeffenceTime = getGameTime():getWorldAgeHours()
--             player:setZombiesDontAttack(true)
--             player:transmitModData()
--         end
--         Events.OnPlayerUpdate.Remove(newPlayerDeffence)
--     end
-- end
-- -- Events.OnGameStart.Add(newPlayerDeffence)
-- Events.OnPlayerUpdate.Add(newPlayerDeffence)