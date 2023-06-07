require('AgroUtils')

local old_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu
function ISVehicleMenu.showRadialMenu(playerObj)
    old_ISVehicleMenu_showRadialMenu(playerObj)

    local vehicle = playerObj:getVehicle()
    if vehicle then
        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())

        if menu:isReallyVisible() then
            if menu.joyfocus then
                setJoypadFocus(playerObj:getPlayerNum(), nil)
            end
            menu:undisplay()
            return
        end

        if AgroUtils.isTractor(vehicle) then
            local trailer = vehicle:getVehicleTowing()
            if AgroUtils.isPlow(trailer) then
                if AgroUtils.canUsePlow(trailer) then
                    if vehicle:isEngineRunning() then
                        local newState = AgroUtils.isTrailerActivated(trailer) and "Off" or "On"
                        menu:addSlice(
                                getText("IGUI_Agro_Plow_Turn" .. newState),
                                getTexture("media/ui/vehicles/Plow" .. newState .. ".png"),
                                ISVehicleMenu.onToggleAgroTrailer,
                                playerObj, vehicle, trailer)
                    else
                        menu:addSlice(
                                getText("IGUI_Agro_Trailer_RequireEngine"),
                                getTexture("media/ui/vehicles/PlowNull.png"),
                                nil, nil)
                    end
                else
                    menu:addSlice(
                            getText("IGUI_Agro_Trailer_Broken"),
                            getTexture("media/ui/vehicles/PlowNull.png"),
                            nil, trailer)
                end
            elseif AgroUtils.isSeeder(trailer) then
                if AgroUtils.canUseSeeder(trailer) then
                    if vehicle:isEngineRunning() then
                        local newState = AgroUtils.isTrailerActivated(trailer) and "Off" or "On"
                        menu:addSlice(
                                getText("IGUI_Agro_Seeder_Turn" .. newState),
                                getTexture("media/ui/vehicles/Seeder" .. newState .. ".png"),
                                ISVehicleMenu.onToggleAgroTrailer,
                                playerObj, vehicle, trailer)
                    else
                        menu:addSlice(
                                getText("IGUI_Agro_Trailer_RequireEngine"),
                                getTexture("media/ui/vehicles/SeederNull.png"),
                                nil, nil)
                    end
                else
                    menu:addSlice(
                            getText("IGUI_Agro_Trailer_Broken"),
                            getTexture("media/ui/vehicles/SeederNull.png"),
                            nil, trailer)
                end
            end
        end
        menu:addToUIManager()
    end
end

function ISVehicleMenu.onToggleAgroTrailer(playerObj, vehicle, trailer)
    ISTimedActionQueue.add(AgroToggleTrailerAction:new(playerObj, vehicle, trailer))
end