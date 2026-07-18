require "GeneratorFuelLink/HT_GFL_Shared"

local function sendCmd(command, args)
    sendClientCommand(HT_GFL.MOD_CMD, command, args)
end

local function genArgs(gen)
    local sq = gen:getSquare()
    return { gx = sq:getX(), gy = sq:getY(), gz = sq:getZ() }
end

local function barrelArgs(barrel)
    local sq = barrel:getSquare()
    return { bx = sq:getX(), by = sq:getY(), bz = sq:getZ() }
end

local function mergeArgs(a, b)
    local t = {}
    for k, v in pairs(a) do t[k] = v end
    for k, v in pairs(b) do t[k] = v end
    return t
end

local function onLinkBarrelToGen(playerObj, barrel, gen)
    if not luautils.walkAdj(playerObj, barrel:getSquare()) then return end
    sendCmd("link", mergeArgs(genArgs(gen), barrelArgs(barrel)))
end

local function onUnlinkBarrel(playerObj, barrel, gen)
    if not luautils.walkAdj(playerObj, gen:getSquare()) then return end
    sendCmd("unlink", mergeArgs(genArgs(gen), barrelArgs(barrel)))
end

local function onUnlinkAll(playerObj, gen)
    if not luautils.walkAdj(playerObj, gen:getSquare()) then return end
    sendCmd("unlink", genArgs(gen))
end

local function onTransferNow(playerObj, gen, barrel)
    if barrel then
        if not luautils.walkAdj(playerObj, barrel:getSquare()) then return end
        sendCmd("transfer", mergeArgs(genArgs(gen), barrelArgs(barrel)))
    else
        if not luautils.walkAdj(playerObj, gen:getSquare()) then return end
        sendCmd("transfer", genArgs(gen))
    end
end

--- Показать реальное содержимое бочки (share или долитое поверх).
local function getBarrelDisplayLitres(barrel, gen)
    local amount = HT_GFL.getBarrelFuelAmount(barrel)
    if gen then
        local linked, idx = HT_GFL.isLinked(gen, barrel)
        if linked then
            local links = HT_GFL.getLinks(gen)
            local share = HT_GFL.getLinkShare(links[idx])
            if amount > share then
                return math.floor(amount + 0.5)
            end
            return math.floor(share + 0.5)
        end
    end
    return math.floor(amount + 0.5)
end

local function buildStatusTooltip(generator)
    local tip = ISToolTip:new()
    tip:setName(getText("ContextMenu_HT_GFL_FuelLink"))
    -- getText в PZ принимает максимум 4 аргумента (%1..%4), %5 не подставляется.
    tip.description = getText("Tooltip_HT_GFL_Status",
        string.format("%.1f%%", generator:getFuel()),
        tostring(math.floor(HT_GFL.getReserve(generator) + 0.5)),
        string.format("%.1f%%", HT_GFL.getTotalFuelPercent(generator)),
        tostring(#HT_GFL.getLinks(generator)))
    tip.description = tip.description .. " <LINE> " .. getText("Tooltip_HT_GFL_MaxSystem", tostring(HT_GFL.getMaxReserve()))
    tip.description = tip.description .. " <LINE> " .. getText("Tooltip_HT_GFL_PhantomHint")
    return tip
end

local function addGeneratorOptions(player, context, generator)
    local playerObj = getSpecificPlayer(player)
    if not playerObj or not generator then return end

    HT_GFL.ensureModData(generator)
    local links = HT_GFL.getLinks(generator)
    local reserve = HT_GFL.getReserve(generator)
    local barrels = HT_GFL.findNearbyBarrels(generator:getSquare())

    local sub = context:addOption(getText("ContextMenu_HT_GFL_FuelLink"), nil, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(sub, menu)

    local infoOpt = menu:addOption(getText("ContextMenu_HT_GFL_Status",
        tostring(math.floor(reserve + 0.5)),
        tostring(#links),
        tostring(HT_GFL.getMaxLinks())), nil, nil)
    infoOpt.toolTip = buildStatusTooltip(generator)

    for i = 1, #barrels do
        local barrel = barrels[i]
        local linked = HT_GFL.isLinked(generator, barrel)
        local fuelAmt = getBarrelDisplayLitres(barrel, generator)
        if linked then
            menu:addOption(getText("ContextMenu_HT_GFL_UnlinkBarrel", tostring(fuelAmt)), playerObj, onUnlinkBarrel, barrel, generator)
        else
            menu:addOption(getText("ContextMenu_HT_GFL_LinkBarrel", tostring(fuelAmt)), playerObj, onLinkBarrelToGen, barrel, generator)
        end
    end

    if #links > 0 then
        menu:addOption(getText("ContextMenu_HT_GFL_TransferNow"), playerObj, onTransferNow, generator, nil)
        menu:addOption(getText("ContextMenu_HT_GFL_UnlinkAll"), playerObj, onUnlinkAll, generator)
    end
end

local function addBarrelOptions(player, context, barrel)
    local playerObj = getSpecificPlayer(player)
    if not playerObj or not barrel then return end

    local gens = HT_GFL.findNearbyGenerators(barrel:getSquare())
    if #gens == 0 then return end

    local sub = context:addOption(getText("ContextMenu_HT_GFL_FuelLink"), nil, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(sub, menu)

    for i = 1, #gens do
        local gen = gens[i]
        local linked = HT_GFL.isLinked(gen, barrel)
        local fuelAmt = getBarrelDisplayLitres(barrel, gen)
        if linked then
            menu:addOption(getText("ContextMenu_HT_GFL_TransferToGen", tostring(fuelAmt)), playerObj, onTransferNow, gen, barrel)
            menu:addOption(getText("ContextMenu_HT_GFL_UnlinkFromGen", tostring(fuelAmt)), playerObj, onUnlinkBarrel, barrel, gen)
            local tipOpt = menu:addOption(getText("ContextMenu_HT_GFL_PhantomStatus", tostring(fuelAmt)), nil, nil)
            local tip = ISToolTip:new()
            tip:setName(getText("ContextMenu_HT_GFL_FuelLink"))
            tip.description = getText("Tooltip_HT_GFL_PhantomHint")
            tipOpt.toolTip = tip
        else
            menu:addOption(getText("ContextMenu_HT_GFL_LinkToGen", tostring(fuelAmt)), playerObj, onLinkBarrelToGen, barrel, gen)
        end
    end
end

local function stripTakeFuelIfPhantom(context, barrel)
    if not barrel or not HT_GFL.isPhantomBarrel(barrel) then return end
    local takeName = getText("ContextMenu_TakeGasFromPump")
    if context and context.removeOptionByName then
        context:removeOptionByName(takeName)
    elseif context and context.options then
        for i = #context.options, 1, -1 do
            local opt = context.options[i]
            if opt and opt.name == takeName then
                table.remove(context.options, i)
            end
        end
    end
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then return end

    local generator = nil
    local barrel = nil

    for _, obj in ipairs(worldobjects) do
        if not generator and instanceof(obj, "IsoGenerator") then
            generator = obj
        end
        if not barrel and HT_GFL.isBarrelObject(obj) then
            barrel = obj
        end
    end

    if not generator or not barrel then
        for _, obj in ipairs(worldobjects) do
            local sq = obj:getSquare()
            if sq then
                if not generator then
                    generator = HT_GFL.getGeneratorOnSquare(sq)
                end
                if not barrel then
                    barrel = HT_GFL.findBarrelOnSquare(sq)
                end
            end
        end
    end

    if barrel then
        stripTakeFuelIfPhantom(context, barrel)
    end

    if generator then
        addGeneratorOptions(player, context, generator)
    end
    if barrel then
        addBarrelOptions(player, context, barrel)
    end
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)

-- После заливки в связанную бочку сразу отправить топливо в систему гена.
local function hookFuelApiAdd()
    local ok, AddFuelCustomObject = pcall(require, "FuelAPI/AddFuelCustomObject")
    if not ok or not AddFuelCustomObject or not AddFuelCustomObject.perform then
        return
    end
    if AddFuelCustomObject._HT_GFL_hooked then
        return
    end
    AddFuelCustomObject._HT_GFL_hooked = true

    local oldPerform = AddFuelCustomObject.perform
    function AddFuelCustomObject:perform()
        oldPerform(self)
        local barrel = self.customFuelObject and self.customFuelObject.isoObject
        if not barrel or not HT_GFL.isBarrelObject(barrel) then
            return
        end
        if not HT_GFL.isPhantomBarrel(barrel) then
            return
        end
        local gens = HT_GFL.findNearbyGenerators(barrel:getSquare())
        for i = 1, #gens do
            if HT_GFL.isLinked(gens[i], barrel) then
                sendCmd("transfer", mergeArgs(genArgs(gens[i]), barrelArgs(barrel)))
                break
            end
        end
    end
end

Events.OnGameStart.Add(hookFuelApiAdd)
