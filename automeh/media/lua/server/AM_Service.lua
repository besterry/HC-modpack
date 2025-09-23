-- mods\PlayerMenu\media\lua\server\UserDataFromJson.lua
require "mods/PlayerMenu/media/lua/server/UserDataFromJson"
AM_Service = {}
PlayerMenuAPI = PlayerMenuAPI or {}
local function debug(msg)
    -- print(msg)
end
 
local function getPriceServiceSandbox(service)
    if service == "REMOVE_RUST" then
        return SandboxVars.NPC.RustPriceMoney
    end
    if service == "IMPROVE_QUALITY" then
        return SandboxVars.NPC.EngineQualityPriceMoney
    end
    if service == "INCREASE_POWER" then
        return SandboxVars.NPC.EnginePowerPriceMoney
    end
    return 0
end

AM_Service.Service = function(player, args)
    debug("AM_Service.Service")
    local nickname = player:getUsername() -- Имя игрока
    local filename = "users/" .. nickname .. ".json" -- Файл игрока
    UserData = PlayerMenuAPI.LoadJsonItems(filename)
    local vehicleId = args.vehicleId
    local vehicle = getVehicleById(vehicleId) -- Получаем автомобиль
    if not vehicle then return end
    local service = args.service -- Услуга
    local payment = args.payment -- Оплата
    local percent = args.percent -- Процент
    local costMoney = getPriceServiceSandbox(service) -- Стоимость (на всякий случай получаем заново, а не доверяем клиенту)
    local costMoneyClient = args.costMoney -- Стоимость (от клиента)
    local status = false -- Статус оплаты
    if payment == "balance" then
        local balance = UserData.balance -- Баланс
        if balance >= costMoney and costMoney == costMoneyClient then -- Если денег достаточно и стоимость совпадает с стоимостью от клиента
            local saveData = {}
            saveData.delta = costMoney
            saveData.balance = balance
            saveData.action = "Service: " .. service
            status = true
            PlayerMenuAPI.saveUserData(player, saveData)
            sendServerCommand(player, 'BalanceAndSH', 'onGetData', {UserData = UserData}) -- Отправляем данные игроку
        end
    end
    if status then
        -- TODO: Добавить логику обслуживания автомобиля
        if service == "REMOVE_RUST" then -- Удаление ржавчины сколько хочет игрок
            debug("AM_Service.Service: service == REMOVE_RUST")
            local rust = vehicle:getRust()
            rust = rust - percent/100 -- Ржавчина 1 ~ 100%
            if rust < 0 then
                rust = 0
            end
            vehicle:setRust(rust)
            vehicle:transmitRust()
            sendServerCommand('AM_Service', 'ServiceComplete', {vehicleId = vehicleId})
        end
        if service == "IMPROVE_QUALITY" then -- Лимит 90%
            debug("AM_Service.Service: service == IMPROVE_QUALITY")
            local engineLoudness = vehicle:getEngineLoudness() -- Громкость - не меняем
            local engineForce = vehicle:getEnginePower() -- Мощность - не меняем
            local engineQuality = vehicle:getEngineQuality() -- Под установку
            engineQuality = engineQuality + percent
            if engineQuality > 90 then
                engineQuality = 90 -- Максимальное увеличение качества до 90%
            end
            vehicle:setEngineFeature(engineQuality, engineLoudness, engineForce)
            vehicle:transmitEngine()
            local modData = vehicle:getModData()
            if modData.engineQualityIncreased then -- Если уже было увеличение качества, то увеличиваем счетчик
                modData.engineQualityIncreased = modData.engineQualityIncreased + 1 -- запись на сервере
            else
                modData.engineQualityIncreased = 1 -- запись на сервере
            end
            sendServerCommand('AM_Service', 'ServiceComplete', {vehicleId = vehicleId, modData = modData}) -- Отправляем моддату авто на клиенты (всем)
        end
        if service == "INCREASE_POWER" then -- setEngineFeature(int quality, int loudness, int engineForce) - Лимит 10% (1 раз)
            debug("AM_Service.Service: service == INCREASE_POWER")
            local engineLoudness = vehicle:getEngineLoudness() -- Громкость - не меняем
            local enginePower = vehicle:getEnginePower() -- Мощность
            local engineQuality = vehicle:getEngineQuality() -- не меняем
            enginePowerNew = enginePower + enginePower*percent/100 -- (мощность 5750 ~ 575 л.с.) +5% = 5750 + 5750*5/100 = 5750 + 287.5 = 6037.5
            if enginePowerNew > enginePower*1.1 then
                enginePowerNew = enginePower*1.1 -- Максимальное увеличение мощности на 10%
            end
            vehicle:setEngineFeature(engineQuality, engineLoudness, enginePowerNew)
            vehicle:transmitEngine()
            -- Моддата не трансмитится, поэтому необходимо отправлять отдельно
            local modData = vehicle:getModData()
            modData.enginePowerIncreased = true -- запись на сервере (1 раз)
            sendServerCommand('AM_Service', 'ServiceComplete', {vehicleId = vehicleId, modData = modData}) -- Отправляем моддату авто на клиенты (всем)
        end
    end
end

AM_Service.OnClientCommand = function(module, command, player, args)
    if module ~= "AM_Service" then return end
    if command == "Service" then
        AM_Service.Service(player, args)
    end
end
Events.OnClientCommand.Add(AM_Service.OnClientCommand)