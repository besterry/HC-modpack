local function seekShopTiles(worldobject, spritePrefix)
    local wo = worldobject
    local found = false
    local sprite = wo:getSprite()
    local spriteName = sprite:getName()
    if spriteName and string.find(spriteName, spritePrefix) then
        found = true
    end
    return wo, found, spriteName, sprite
end

local function repairMeh(worldobjects,playerNum,sprites)
    local activate = SandboxVars.NPC.AutomehRepairActivate
    local playerObj = getPlayer()
    if activate then
        if not AM_RepairCar.instance then
            local geoX = worldobjects[1]:getX()
            local geoY = worldobjects[1]:getY()
            local x = 420
            local y = 260
            local ui = AM_RepairCar:new(0, 0, x, y, playerObj, geoX, geoY); --((getCore():getScreenWidth())/2)+x/2, (getCore():getScreenHeight())/2-y/2
            ui:initialise();
            ui:addToUIManager();
        end
    else
        playerObj:Say(getText("IGUI_AM_Close"))
    end
end

local function Register(worldobjects,playerNum,sprites)
    local activate = SandboxVars.NPC.AutomehRegistration
    local playerObj = getPlayer()
    if activate then
        if not RegisterCar.instance then
            local geoX = worldobjects[1]:getX()
            local geoY = worldobjects[1]:getY()
            local x = 0
            local y = 0
            local ui = RegisterCar:new(0, 0, 350, 200, playerObj, geoX, geoY);
            ui:initialise();
            ui:addToUIManager();
        end
    else
        playerObj:Say(getText("IGUI_AM_Close"))
    end
end

local function AdminPage(worldobjects,playerNum,sprites)
    local geoX = worldobjects[1]:getX()
    local geoY = worldobjects[1]:getY()
    local playerObj = getPlayer()    
    local ui = AM_AdminPage:new(0, 0, 500, 500, playerObj, geoX, geoY);
    ui:initialise();
    ui:addToUIManager();
end

local function Penalty(worldobjects,playerNum,sprites)
    local playerObj = getPlayer()
    if SandboxVars.NPC.ParkingPenaltyActivate then
        if not PenaltyParkingUI.instance then
            local geoX = worldobjects[1]:getX()
            local geoY = worldobjects[1]:getY()
            local ui = PenaltyParkingUI:new(0, 0, 400, 150, playerObj, geoX, geoY)
            ui:initialise();
            ui:addToUIManager();
        end
    else
        playerObj:Say(getText("IGUI_AM_Close"))
    end
end

local function blackmarketAuto(worldobjects,playerNum,sprites)
    local playerObj = getPlayer()
    if SandboxVars.NPC.BlackmarketAuto then
        if not PenaltyParkingUI.instance then
            local geoX = worldobjects[1]:getX()
            local geoY = worldobjects[1]:getY()
            local x = 350
            local y = 200
            local ui = BlackMarketAuto:new(0, 0, x, y, playerObj, geoX, geoY)
            ui:initialise();
            ui:addToUIManager();
        end
    else
        playerObj:Say(getText("IGUI_AM_Close"))
    end
end

local function PenaltyContext(worldobjects,vehicle,register)
    sendClientCommand(getPlayer(),"AutoMeh","saveCar",{vehicle = vehicle:getId()})
end

local function AutomehContextMenu(playerNum, context, worldobjects)
    --if not (isClient() and isAdmin()) then return end
    local wo, found, spriteName, sprite = seekShopTiles(worldobjects[1], "automex")
    local wo2, found2, spriteName2, sprite2 = seekShopTiles(worldobjects[1], "blackmarket")
    if found2 then
        local blackmarketOption = context:addOption(getText("IGUI_BlackMarket"), worldobjects, nil)
        local subMenu = context:getNew(context)
        context:addSubMenu(blackmarketOption, subMenu)
        subMenu:addOption(getText("IGUI_BlackMarketMenu"), worldobjects, blackmarketAuto, playerNum, spriteName, sprite)
    end
    if found then
        local automehOption = context:addOption(getText("IGUI_Automeh"), worldobjects, nil)
        local subMenu = context:getNew(context)
        context:addSubMenu(automehOption, subMenu)
        subMenu:addOption(getText("IGUI_RegistrAuto"), worldobjects, Register, playerNum, spriteName, sprite)
        subMenu:addOption(getText("IGUI_AutoMehAuto"), worldobjects, repairMeh, playerNum, spriteName, sprite)
        subMenu:addOption(getText("IGUI_ParkingPenalty"), worldobjects, Penalty, playerNum, spriteName, sprite)
        if isAdmin() then 
            subMenu:addOption(getText("IGUI_AM_ParkingPenalty_Admin_List"), worldobjects, AdminPage, playerNum, spriteName, sprite)
        end
    end
    if not isAdmin() then return
    else
        local square = nil;
        for i,v in ipairs(worldobjects) do
            square = v:getSquare();
            break;
        end
        local vehicle = square:getVehicleContainer()
        if vehicle ~= nil then
            local register
            if vehicle:getModData().register then register = vehicle:getModData().register end
            if register then
                local automehOption = context:addOption(getText("IGUI_Automeh"), worldobjects, nil)
                local subMenu = context:getNew(context)
                context:addSubMenu(automehOption, subMenu)                
                subMenu:addOption(getText("IGUI_CarAddParkingPenalty").." "..vehicle:getModData().sqlId, worldobjects, PenaltyContext, vehicle, register)
            end
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(AutomehContextMenu)