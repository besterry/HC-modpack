local onServerCommandSafehouse = function(module, command, player, args)
    if module ~= "SafehouseFD" then
        return
    end
    if command == "ResetSafehouseTime" then
        local currentTime = getTimeInMillis() 
        for i=0,SafeHouse.getSafehouseList():size()-1 do
            local sh = SafeHouse.getSafehouseList():get(i);
            if sh:getOwner() == args[1] then
            sh:setLastVisited(currentTime)
            sh:syncSafehouse()
            end
        end        
    end
end

Events.OnClientCommand.Add(onServerCommandSafehouse)