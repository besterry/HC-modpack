local commands = {}

commands.installPart  = function(player, args) -- args = { vehicle = self.vehicle:getId(), part = self.part:getId(), item = self.item, perks = perksTable, mechanicSkill = self.character:getPerkLevel(Perks.Mechanics) }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    local item = args.item
    local msg = "Player: " .. player:getUsername() ..  " [" .. math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0]" ..
    " vehicle: " ..  vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) ..  "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId ..
    " Install part: " .. part:getId() .. " -> Item:" .. item:getFullType() .. ", Condition:" .. args.item:getCondition()
    writeLog("vehicle-Parts", msg)
end

commands.uninstallPart  = function(player, args) --args = { vehicle = self.vehicle:getId(), part = self.part:getId(), perks = perksTable, mechanicSkill = self.character:getPerkLevel(Perks.Mechanics), contentAmount = self.part:getContainerContentAmount() }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    if not part then
        return
    end
    local item = part:getInventoryItem()
    local itemMsg = ""
    if not item then
        itemMsg = " Condition:" .. part:getCondition()
    else
        itemMsg = " -> Item:" .. item:getFullType() .. ", Condition:" .. item:getCondition()
    end
    local msg = "Player: " .. player:getUsername() .. " [" .. math.floor(player:getX()) .. "," ..  math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId ..
    " Uninstall part: " .. part:getId() .. itemMsg
    writeLog("vehicle-Parts", msg)
end

commands.setContainerContentAmount = function (player, args) -- args = { vehicle = self.vehicle:getId(), part = self.part:getId(), amount = self.tankTarget }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    if not part then
        return
    end
    local msg = "Player: " .. player:getUsername() .. " [" .. math.floor(player:getX()) .. "," ..  math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId ..
    " Part: " .. part:getId() .. " -> GASOLINE -> " .. math.floor(args.amount) .. "/" .. part:getContainerCapacity()
    writeLog("vehicle-FuelChange", msg)
end

--sendClientCommand(playerObj, "vehicle", "repairPart", { vehicle = part:getVehicle():getId(), part = part:getId() })
commands.repairPart = function(player, args) -- args = { vehicle = self.vehicle:getId(), part = self.part:getId() }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    if not part then
        return
    end
    local msg = '"' .. player:getUsername() .. '"'.. " -> REPAIR PART TO 100%" .. " [" .. math.floor(player:getX()) .. "," ..  math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId .. " Part: " .. part:getId() 
    writeLog("admin", msg)
end

-- sendClientCommand(playerObj, "vehicle", "repair", { vehicle = vehicle:getId() })
commands.repair = function(player, args) -- args = { vehicle = self.vehicle:getId() }
    local vehicle = getVehicleById(args.vehicle)
    if not vehicle then
        return
    end    
    local msg = '"' .. player:getUsername() .. '"' .. " -> REPAIR VEHICLE TO 100%" .. " [" .. math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. (vehicle:getModData().sqlId or "N/A")    
    writeLog("admin", msg)
end


local function BalanceAndSH_OnClientCommand(module, command, player, args)
    if module == "vehicle" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(BalanceAndSH_OnClientCommand)