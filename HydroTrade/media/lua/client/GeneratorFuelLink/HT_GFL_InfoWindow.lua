require "GeneratorFuelLink/HT_GFL_Shared"

-- Ставим патч после загрузки всех модов (в т.ч. Generator Time Remaining).
local function installInfoPatch()
    local _prev = ISGeneratorInfoWindow.getRichText

    function ISGeneratorInfoWindow.getRichText(object, displayStats)
        if not displayStats or not object then
            return _prev(object, displayStats)
        end

        HT_GFL.ensureModData(object)
        local reserve = HT_GFL.getReserve(object)
        local links = HT_GFL.getLinks(object)
        local tank = math.ceil(object:getFuel())
        local reservePct = HT_GFL.litresToPercent(reserve)
        local totalPct = tank + reservePct

        local fuelLeft = ""
        if object:isActivated() then
            local ok, GTR = pcall(require, "gtr_options")
            if ok and GTR and type(GTR.toString) == "function" then
                fuelLeft = GTR:toString(object, totalPct) or ""
            end
        end

        local text = getText("IGUI_Generator_FuelAmount", tank) .. fuelLeft .. " <LINE> "
        text = text .. getText("IGUI_HT_GFL_Reserve", tostring(math.floor(reserve + 0.5)), string.format("%.1f", reservePct)) .. " <LINE> "
        text = text .. getText("IGUI_HT_GFL_Total", string.format("%.1f", totalPct)) .. " <LINE> "
        if #links > 0 then
            text = text .. getText("IGUI_HT_GFL_Links", tostring(#links)) .. " <LINE> "
        end
        text = text .. getText("IGUI_Generator_Condition", object:getCondition()) .. " <LINE> "

        if object:isActivated() then
            text = text .. " <LINE> " .. getText("IGUI_PowerConsumption") .. ": <LINE> "
            text = text .. " <INDENT:10> "
            local items = object:getItemsPowered()
            for i = 0, items:size() - 1 do
                text = text .. "   " .. items:get(i) .. " <LINE> "
            end
            text = text .. getText("IGUI_Total") .. ": " .. luautils.round(object:getTotalPowerUsing(), 2) .. " L/h <LINE> "
        end

        local square = object:getSquare()
        if square and not square:isOutside() and square:getBuilding() then
            text = text .. " <LINE> <RED> " .. getText("IGUI_Generator_IsToxic")
        end

        return text
    end
end

Events.OnGameStart.Add(installInfoPatch)
