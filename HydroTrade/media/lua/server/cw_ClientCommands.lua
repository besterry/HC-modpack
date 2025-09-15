if isClient() then return end
CW_fueltankPartNames = {"1000FuelTank","500FuelTank"}
local CWCommands = {}
local Commands = {}

function Commands.spawnVehicle(player, args)
    writeLog("vehicle", "[CarWanna]: Spawning Vehicle : "..args.type.." at "..player:getX().." x "..player:getY().." for "..player:getUsername())    
    local sq = getCell():getGridSquare(player:getX(), player:getY(), 0)
    
    if args.dir == nil then
        if player then
            args.dir = player:getDir();
        else
            args.dir = IsoDirections.S;
        end
    end 
    
    
    local car = addVehicleDebug(args.type, args.dir, nil, sq)
    
    --car:setDir(args.dir)
    
    --This repairs all parts on vehicles and also adds all upgrades since "missing" upgrades are parts with 0 health...    
    if args.upgrade then
        car:repair()
    end
    
    --Clear out part inventories of random items that spawn in when we spawn vehicles in. 
    if args.clear then    
        for i = 0, car:getPartCount() -1 
        do
            local part = car:getPartByIndex(i)
            --print(part:getId())
            local container = part:getItemContainer()
            if container then
                --print("Is container")
                if container:getItems():size() ~= 0 then
                    --print("Has items")
                    container:removeAllItems()
                end
            end
        end
    end
    
    --Repair parts that actually exist on the vehicle
    if (type(args.condition) == "number") then
        for i = 0, car:getPartCount() -1 
        do
            local part = car:getPartByIndex(i)
            if part:getCondition() > 0 then
                part:setCondition(args.condition)
            end
        end       
    end
    
    local engineLoudness = car:getEngineLoudness() -- Получение громкости двигателя (не меняем)
    local enginePower = car:getEnginePower() -- Получение мощности двигателя (не меняем)
    if args.engineFeature then -- Если передали качество двигателя
        car:setEngineFeature(args.engineFeature, engineLoudness, enginePower) -- Установка качества двигателя (качество, громкость, мощность)
        car:transmitEngine() -- Рассылка текущего состояния двигателя на клиенты
    elseif args.condition then -- Если нет качества двигателя, то устанавливаем качество из condition
        car:setEngineFeature(args.condition, engineLoudness, enginePower)
        car:transmitEngine()
    end

    --Установка заряда батареи
    if args.battery then
        local battery = car:getPartById("Battery")
        if battery then
            battery:getInventoryItem():setUsedDelta(args.battery);
        end
    end
    
    --Создание ключа и отправка его игроку
    if args.makekey then 
        local newCarKey = car:createVehicleKey()
        if newCarKey then
            player:sendObjectChange("addItem", { item = newCarKey })
            --sq:AddWorldInventoryItem(newCarKey, ZombRand(1, 5), ZombRand(1, 5), 0)
        end
        
    end
    
    --Изменение уровня топлива бензобака
    --Если нет уровня топлива бензобака, то ТС запускается с случайным уровнем топлива
    if args.gastank then
        local gastank = car:getPartById("GasTank")     
        if gastank then 
            gastank:setContainerContentAmount(args.gastank)
        end
    end    
    
    --Изменение уровня топлива цистерны
    if args.fueltank then
        for i=1, #CW_fueltankPartNames
        do          
          local fueltank = car:getPartById(CW_fueltankPartNames[i])
          if fueltank then 
             fueltank:setContainerContentAmount(args.fueltank)
          end
        end 
    end    
    
    --Уровень ржавчины
    if args.rust then
        car:setRust(args.rust)
        car:transmitRust()
    end

    --Цвет автомобиля
    if args.HSV then
        car:setColorHSV(args.HSV)
        car:transmitColorHSV()
    end    
    
end

CWCommands.OnClientCommand = function(module, command, player, args)
	if module == 'CW' and Commands[command] then
		local argStr = ''
		args = args or {}
		for k,v in pairs(args) do
			argStr = argStr..' '..k..'='..tostring(v)
		end
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(CWCommands.OnClientCommand)