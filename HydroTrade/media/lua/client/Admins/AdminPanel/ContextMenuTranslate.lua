-- Хук для перевода админ контекстного меню
local old_ISContextMenu_addDebugOption = ISContextMenu.addDebugOption
local old_ISContextMenu_addOption = ISContextMenu.addOption

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
    ["Radius: 500"] = "IGUI_Radius_500"
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