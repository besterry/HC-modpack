if isClient() then return end

local Rmove = function(module, command, player, args)
    if module == 'vehicle' and command == "rmove" then
        -- print("Rmove")
        local vehicle = getVehicleById(args.vehicle)
        if vehicle then -- Если машина найдена, то логируем
            local msg = player:getUsername() ..  " Rmove: " ..  vehicle:getScriptName() .. " [" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" .. " server SqlId: " .. vehicle:getSqlId()
            writeLog("vehicle", msg)
        end
        args.rmove = true
        triggerEvent("OnClientCommand", module, "remove", player, args)
    end
end
Events.OnClientCommand.Add(Rmove)