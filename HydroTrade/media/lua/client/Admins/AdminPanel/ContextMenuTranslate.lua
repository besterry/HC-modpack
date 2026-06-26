-- Хук для перевода админ контекстного меню
local old_ISContextMenu_addDebugOption = ISContextMenu.addDebugOption
local old_ISContextMenu_addOption = ISContextMenu.addOption
local old_ISVehicleMechanics_doPartContextMenu = ISVehicleMechanics.doPartContextMenu
local old_ISVehicleMechanics_onRightMouseUp = ISVehicleMechanics.onRightMouseUp

-- Словарь переводов
local translations = {
    ["Tools"] = "IGUI_Tools",
    ["Teleport"] = "IGUI_Teleport", 
    ["Remove item tool"] = "IGUI_RemoveItemTool",
    ["Spawn Vehicle"] = "IGUI_SpawnVehicle",
    ["Horde Manager"] = "IGUI_HordeManager",
    ["Trigger Thunder"] = "IGUI_TriggerThunder",
    ["Make noise"] = "IGUI_MakeNoise",
    ["Remove all zombies"] = "IGUI_RemoveAllZombies",
    ["Vehicle:"] = "IGUI_Vehicle:",
    ["HSV & Skin UI"] = "IGUI_HSV_Skin_UI",
    ["Blood UI"] = "IGUI_Blood_UI",
    ["Remove"] = "IGUI_Remove",
    ["Door"] = "IGUI_Door",
    ["Get Door Key"] = "IGUI_GetDoorKey",
    ["Door Unlock"] = "IGUI_DoorUnlock",
    ["Door Lock"] = "IGUI_DoorLock",
    ["Set Door Key ID"] = "IGUI_SetDoorKeyID",
    ["Set Door Building Key ID"] = "IGUI_SetDoorBuildingKeyID",
    ["Set Door Random Key ID"] = "IGUI_SetDoorRandomKeyID",
    ["Set force lock"] = "IGUI_SetForceLock",
    ["Radius: 10"] = "IGUI_Radius_10",
    ["Radius: 20"] = "IGUI_Radius_20", 
    ["Radius: 50"] = "IGUI_Radius_50",
    ["Radius: 100"] = "IGUI_Radius_100",
    ["Radius: 200"] = "IGUI_Radius_200",
    ["Radius: 500"] = "IGUI_Radius_500",

    -- Чит-опции из ISVehicleMechanics
    ["CHEAT: Get Key"] = "IGUI_CHEAT_GetKey",
    ["CHEAT: Remove Hotwire"] = "IGUI_CHEAT_RemoveHotwire",
    ["CHEAT: Hotwire"] = "IGUI_CHEAT_Hotwire",
    ["CHEAT: Repair Part"] = "IGUI_CHEAT_RepairPart",
    ["CHEAT: Repair Vehicle"] = "IGUI_CHEAT_RepairVehicle",
    ["CHEAT: Set Rust"] = "IGUI_CHEAT_SetRust",
    ["CHEAT: Set Part Condition"] = "IGUI_CHEAT_SetPartCondition",
    ["CHEAT: Set Content Amount"] = "IGUI_CHEAT_SetContentAmount",
    ["CHEAT: Remove Vehicle"] = "IGUI_CHEAT_RemoveVehicle",
    ["CHEAT: Set Odometer in KM"] = "IGUI_CHEAT_SetOdometerInKM",
    ["DBG: ISVehicleMechanics.cheat=false"] = "IGUI_DBG_ISVehicleMechanics_cheat_false",
    ["DBG: ISVehicleMechanics.cheat=true"] = "IGUI_DBG_ISVehicleMechanics_cheat_true",
}

-- Соответствие чит-опций ключам SandboxVars.Admins (с дефолтом = 4)
local cheatThresholds = {
    ["CHEAT: Get Key"] = "vehicleCheatGetKey",
    ["CHEAT: Remove Hotwire"] = "vehicleCheatRemoveHotwire",
    ["CHEAT: Hotwire"] = "vehicleCheatHotwire",
    ["CHEAT: Repair Part"] = "vehicleCheatRepairPart",
    ["CHEAT: Repair Vehicle"] = "vehicleCheatRepairVehicle",
    ["CHEAT: Set Rust"] = "vehicleCheatSetRust",
    ["CHEAT: Set Part Condition"] = "vehicleCheatSetPartCondition",
    ["CHEAT: Set Content Amount"] = "vehicleCheatSetContentAmount",
    ["CHEAT: Remove Vehicle"] = "vehicleCheatRemoveVehicle",
    ["CHEAT: Set Odometer in KM"] = "vehicleCheatSetOdometerInKM",    
}

function ISContextMenu:addDebugOption(text, worldobjects, param1, param2, param3, param4, param5)
    if translations[text] then
        text = getText(translations[text])
    end
    return old_ISContextMenu_addDebugOption(self, text, worldobjects, param1, param2, param3, param4, param5)
end

function ISContextMenu:addOption(text, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
    if translations[text] then
        text = getText(translations[text])
    end
    return old_ISContextMenu_addOption(self, text, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
end

local function getAccessLevelNumber(level)
    if level == "observer" then
        return 1
    elseif level == "gm" then
        return 2
    elseif level == "moderator" then
        return 3
    elseif level == "admin" then
        return 4
    end
    return 0
end

local function hasCheatAccess(text)
    local key = cheatThresholds[text]
    if not key then return true end

    local required = 4
    if SandboxVars and SandboxVars.Admins and SandboxVars.Admins[key] ~= nil then
        required = SandboxVars.Admins[key]
    end

    local lvlStr = getAccessLevel and getAccessLevel() or "None"
    local lvlNum = getAccessLevelNumber(lvlStr)
    return lvlNum >= required
end

local function removeDisallowedCheatsFromContext(ctx)
    if not ctx or ctx:isEmpty() then return end
    for engLabel, _ in pairs(cheatThresholds) do
        if not hasCheatAccess(engLabel) then
            -- удалить локализованное имя (если было переведено)
            local i18nKey = translations[engLabel]
            if i18nKey then
                local ru = getText(i18nKey)
                if ru and ru ~= "" and ru ~= i18nKey then
                    ctx:removeOptionByName(ru)
                end
            end
            -- и на всякий случай оригинал
            ctx:removeOptionByName(engLabel)
        end
    end
end

function ISVehicleMechanics:onCheatSetCarQuality(playerObj, vehicle)
    if not isAdmin() then return end
    if not vehicle then return end
    print("vehicle: " .. tostring(vehicle))
    local Quality = vehicle:getEngineQuality()
    local modal = ISModalDialog:new(0, 0, 350, 150, getText("Car Quality?"), true, nil, ISVehicleMechanics.onCheatSetCarQualityAux, playerObj:getPlayerNum(), playerObj, vehicle)
    modal:initialise()
    modal.prevFocus = getPlayerMechanicsUI(playerObj:getPlayerNum())
    modal.moveWithMouse = true
    modal:addToUIManager()
end

function ISVehicleMechanics:onCheatSetCarQualityAux(target, button, playerObj, vehicle)
    if button.internal ~= "OK" then return end
    local text = button.parent.entry:getText()
    local carQuality = tonumber(text)
    if not carQuality then return end
    sendClientCommand(playerObj, "vehicle", "setNewEngineQuality", { vehicle = vehicle:getId(), carQuality = carQuality })
end

function ISVehicleMechanics:doPartContextMenu(part, x, y)
    old_ISVehicleMechanics_doPartContextMenu(self, part, x, y)
    removeDisallowedCheatsFromContext(self.context)
    if part:getId() == "Engine" and isAdmin() then
        self.context:addOption(getText("IGUI_CHEAT_SetCarQuality"), getPlayer(), ISVehicleMechanics.onCheatSetCarQuality, self.vehicle)
    end
end

function ISVehicleMechanics:onRightMouseUp(x, y)
    old_ISVehicleMechanics_onRightMouseUp(self, x, y)
    removeDisallowedCheatsFromContext(self.context)
end