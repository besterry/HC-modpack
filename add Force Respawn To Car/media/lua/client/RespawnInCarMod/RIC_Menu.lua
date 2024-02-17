---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RICaction = require("RespawnInCarMod/RIC_Action")
local Utils = require("RespawnInCarMod/RIC_Utils")
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--						                                                                     DEBUG MENU and PLAYER MENU
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RICmenu = {}
-------------------------------------------------------------------------------------------------
RICmenu.adminMenu = {
    {"PrintInfos"},
    {"CheckPlayersNames"},
    {"ExpulsePlayersFromVehicle",false,true},
    {"VehicleWithoutTriggerOnExit",true},
    {"VehicleWithoutTriggerOnEnter",true},
    {"RedefineVehicleNamelist",true},
    {"ResetPlayerListFromVehicle",false,true},
    {"VehicleNumberRef",true},
    {"MySeatNumber",true},
    {"ResetMyposition",true,true},
    {"SavePlayer",true,true},
    {"PreTeleportPlayer",true,true},
    {"RemovePlayerIsNotRespawn",false,true},
    {"ResetModData",true,true}
}
-------------------------------------------------------------------------------------------------
function RICmenu.dialogYesNo(player,command)
-------------------------------------------------------------------------------------------------
    local function confirm(this,button)
        if button.internal == "YES" then
            RICmenu[command](player,command)
        end
    end
    local txt = getText("IGUI_RIC_Admindialog")--_"..command
    local dialog = ISModalDialog:new(0,0, 250, 150, txt, true, nil, confirm, 0)
    dialog:initialise()
    dialog:addToUIManager()
end
-------------------------------------------------------------------------------------------------
function RICmenu.GetExpulseMenu(player,args)
-------------------------------------------------------------------------------------------------
local len = #args
local vehicle   = getVehicleById(args[len])
if not vehicle then return end
    local maxSeat = vehicle:getMaxPassengers()
    local counter = 0
    for i = 1,maxSeat do
        counter = counter+1
        local command = "ExpulsePlayer"
        RICmenu.subMenu:addOption(args[counter],player,RICmenu[command],vehicle,counter,command)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RICmenu.onFillWorldObjectContextMenu = function(playerId, context, worldobjects, test)
-------------------------------------------------------------------------------------------------
    if test or getCore():getGameMode() == 'LastStand' then return end
    local player = getSpecificPlayer(playerId)
    if not player then return end 

    local vehicleInside = player:getVehicle()
    ------------------------------------------------
    if vehicleInside then
        local seat = vehicleInside:getSeat(player)
        local boat = RIC.GetBoat(vehicleInside)
        local yacht = boat == "yacht" and (seat ~= 1 and seat ~= 0)
        local boatMotor = boat == "boatMotor" and (seat ~= 4 and seat ~= 5)
        local menu = not boat or yacht or boatMotor 
        if menu then
            local command = "CheckPlayersNames"
            local KeyMenu = context:addOptionOnTop(getText("IGUI_RIC_"..command), player, RICmenu[command],command)
            local toolTip = ISToolTip:new();
            toolTip:initialise();
            toolTip:setVisible(false);
            KeyMenu.toolTip = toolTip;
            if not boat then
                KeyMenu.toolTip.description = getText("IGUI_RIC_kick_the_disconnected_players_info")
            else
                KeyMenu.toolTip.description = getText("IGUI_RIC_kick_the_disconnected_players_info_Boat")
            end
        end
    end
    ------------------------------------------------
    if RIC.IsAdmin(player) or getCore():getDebug() then
        local KeyMenu = context:addDebugOption( getText("IGUI_RespawnToCar"));
        local subMenu = ISContextMenu:getNew(context);
        context:addSubMenu(KeyMenu, subMenu);
        for _,v in pairs(RICmenu.adminMenu) do
            if not v[2] or getCore():getDebug() then
                local choice = v[1]
                if v[3] then choice = "dialogYesNo" end
                local KeyMenu = subMenu:addOption(getText('IGUI_RIC_AdminMenu_'..v[1]),player,RICmenu[choice],v[1])
                local toolTip = ISToolTip:new();
                toolTip:initialise();
                toolTip:setVisible(false);
                KeyMenu.toolTip = toolTip;
                KeyMenu.toolTip.description = getText("IGUI_RIC_AdminTooltip_"..v[1])
            end
        end
    end
    ------------------------------------------------
    local vehicle = player:getVehicle()
    if not vehicle then
        vehicle = player:getUseableVehicle()
        if vehicle then
            local part = vehicle:getUseablePart(player)
            if not part or not part:getDoor() then return end
            if not part:getDoor():isOpen() or part:getId() == "EngineDoor" then return end --or part:getDoor():isLocked() or (part:getId() ~= "TrunkDoor" and part:getId() ~= "DoorRear")
        else
            return
        end
    elseif vehicle then
        local seat = vehicle:getSeat(player)
        local boat = RIC.GetBoat(vehicle)
        if not RIC.GetBoat(vehicle) then
            return
        elseif boat == "yacht" and (seat == 1 or seat == 0) then   
            return
        elseif boat == "boatMotor" and (seat == 4 or seat == 5) then
            return
        end
    end
    ------------------------------------------------
    local KeyMenu = context:addOptionOnTop(getText("IGUI_RIC_Expulse_player_to"))
    local subMenu = ISContextMenu:getNew(context)
    RICmenu.subMenu = subMenu
    context:addSubMenu(KeyMenu, subMenu)
    if not RICmenu.MenuIsRefreshed and isClient() then
        local function setActiveMenu(IsActive)
            RICmenu.MenuIsRefreshed = IsActive
            if IsActive then
                Utils.delayedFunction(function()
                RICmenu.MenuIsRefreshed = false
                end, 500);
            end
        end
        subMenu:addOption(getText('IGUI_RIC_context_RefreshExpulseMenu'),true,setActiveMenu)
    else    
        RIC.SendClientCommand(player,"GetExpulseMenu",{vehicle:getId()})
    end
end
-----------------------------------------------------------------------------
Events.OnFillWorldObjectContextMenu.Add(RICmenu.onFillWorldObjectContextMenu) --OnPreFillWorldObjectContextMenu
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                            -- FUNCTIONS MENU
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RICmenu.SendCommandFromVehicle = function(player,command)
local vehicle = player:getVehicle()
local square = player:getCurrentSquare()
if not vehicle and square then     
vehicle = square:getVehicleContainer()
end
if vehicle then RIC.SendClientCommand(player,command,{vehicle:getId()}) end
end
-------------------------------------------------------------------------------------------------
RICmenu.PreTeleportPlayer           = function (player,command) RIC.SendClientCommand(player,command,{}) end
-------------------------------------------------------------------------------------------------
RICmenu.SavePlayer                  = function (player,command) RIC.SendClientCommand(player,command,{true}) end
-------------------------------------------------------------------------------------------------
RICmenu.ResetModData                = function (player,command) RIC.SendClientCommand(player,command,{}) end
-------------------------------------------------------------------------------------------------
RICmenu.PrintInfos                  = function (player,command) RIC.SendClientCommand(player,command,{}) end
-------------------------------------------------------------------------------------------------
RICmenu.CheckPlayersNames           = function (player,command) RICmenu.SendCommandFromVehicle(player,command) end
-------------------------------------------------------------------------------------------------
RICmenu.ExpulsePlayersFromVehicle   = function (player,command) RICmenu.SendCommandFromVehicle(player,command) end
-------------------------------------------------------------------------------------------------
RICmenu.RedefineVehicleNamelist     = function (player,command) RICmenu.SendCommandFromVehicle(player,command) end
-------------------------------------------------------------------------------------------------
RICmenu.VehicleNumberRef            = function (player,command) RICmenu.SendCommandFromVehicle(player,command) end
-------------------------------------------------------------------------------------------------
RICmenu.RemovePlayerIsNotRespawn = function (player,command)
if getActivatedMods():contains("AvatarOffline") or getActivatedMods():contains("Avatar USER") then
player:Say(getText("IGUI_RIC_Say_takeAvatarOption_RemovePlayerIsNotRespawn"))
else
RIC.SendClientCommand(player,command,{})
end
end
-------------------------------------------------------------------------------------------------
RICmenu.ResetMyposition = function (player)
local command = "SavePlayer"
local args = {false}
RIC.SendClientCommand(player,command,args)
end
-------------------------------------------------------------------------------------------------
RICmenu.ExpulsePlayer = function(player,vehicle,numSeat,command)
local vehicleTestBoat = player:getVehicle()
if vehicleTestBoat and not RIC.GetBoat(vehicleTestBoat) then 
player:Say(getText("IGUI_RIC_You_should_getout_vehicle"))
return 
end
local vehicleTest = player:getUseableVehicle()
if (not vehicleTest and not vehicleTestBoat) or (vehicleTest ~= vehicle and vehicleTestBoat ~= vehicle) then player:Say(getText("IGUI_RIC_You_should_get_near_vehicle")) return end
ISTimedActionQueue.add(RICaction:new(player,vehicle,numSeat,command))    
end  
-------------------------------------------------------------------------------------------------
RICmenu.ResetPlayerListFromVehicle = function (player,command)
local vehicleInside = player:getVehicle()
if vehicleInside then player:Say(getText("IGUI_RIC_You_should_getout_vehicle")) return end
local square = player:getCurrentSquare()
if not square then return end
local vehicle = square:getVehicleContainer()
if vehicle then RIC.SendClientCommand(player,command,{vehicle:getId()}) end
end
-------------------------------------------------------------------------------------------------
RICmenu.VehicleWithoutTriggerOnEnter = function (player)
local vehicleInside = player:getVehicle()
if vehicleInside then player:Say(getText("IGUI_RIC_You_should_getout_vehicle")) return end
local square = player:getCurrentSquare()
if not square then return end
local vehicle = square:getVehicleContainer()
if vehicle then 
vehicle:enter(0, player) 
getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(vehicle)
end
end
-------------------------------------------------------------------------------------------------
RICmenu.VehicleWithoutTriggerOnExit = function (player)
local vehicle = player:getVehicle()
if not vehicle then player:Say(getText("IGUI_RIC_You_should_getout_vehicle")) return end
local seat = vehicle:getSeat(player)
getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(nil)
vehicle:exit(player)
vehicle:setCharacterPosition(player, seat, "outside")
player:PlayAnim("Idle")
vehicle:updateHasExtendOffsetForExitEnd(player)
end
-------------------------------------------------------------------------------------------------
RICmenu.MySeatNumber = function (player)
local vehicle = player:getVehicle()
if not vehicle then return end
local seat = vehicle:getSeat(player)
player:Say(getText("IGUI_RIC_Say_myNumberSeatIs").. seat)
end
-------------------------------------------------------------------------------------------------

return RICmenu