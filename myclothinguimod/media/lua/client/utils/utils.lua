local utils = {};

function utils.getBodySlotText(bodySlot)

    local localizedText = getText("UI_CUI_" .. bodySlot);
    if string.find(localizedText, "UI_CUI_") then
        return bodySlot;
    else
        return localizedText;
    end

end

function utils.getCategoryButtonText(category)
    return getText("UI_CUI_Category_" .. category);
end

function utils.toBoolean(str)
    local bool = false
    if str == "true" then
        bool = true
    end
    return bool
end

--- Condition ratio 0..1. Returns 1 if item has no condition scale.
function utils.getItemConditionRatio(item)
    if not item then
        return 1
    end
    local maxCond = item:getConditionMax()
    if not maxCond or maxCond <= 0 then
        return 1
    end
    local ratio = item:getCondition() / maxCond
    if ratio < 0 then
        return 0
    end
    if ratio > 1 then
        return 1
    end
    return ratio
end

--- Collect BloodBodyPartType entries for clothing (B41-safe). Returns Lua array.
--- Prefer BloodClothingType.getCoveredParts (same source as garment inspection).
--- Clothing:getCoveredParts() can include extra parts (e.g. Back) that inspection never shows,
--- which creates fake unpatched holes that cannot be fixed in the inspect UI.
local function getClothingCoveredPartsList(item)
    local list = {}
    local seen = {}

    local function addParts(parts)
        if not parts or not parts.size then
            return
        end
        for i = 0, parts:size() - 1 do
            local part = parts:get(i)
            local key = tostring(part)
            if part and not seen[key] then
                seen[key] = true
                table.insert(list, part)
            end
        end
    end

    if not item then
        return list
    end

    if BloodClothingType and BloodClothingType.getCoveredParts and item.getBloodClothingType then
        local bct = item:getBloodClothingType()
        if bct then
            -- Pass full getBloodClothingType() result (ArrayList or enum).
            -- Per-element getCoveredParts(bct:get(i)) throws "No implementation found".
            local ok, parts = pcall(function()
                return BloodClothingType.getCoveredParts(bct)
            end)
            if ok then
                addParts(parts)
            end
        end
    end

    if #list > 0 then
        return list
    end

    if item.getCoveredParts then
        local ok, parts = pcall(function()
            return item:getCoveredParts()
        end)
        if ok then
            addParts(parts)
        end
    end

    return list
end

local function partHasPatch(item, part)
    if not item or not item.getPatchType then
        return false
    end
    local ok, patch = pcall(function()
        return item:getPatchType(part)
    end)
    return ok and patch ~= nil
end

local function partHasHole(visual, part)
    if not visual or not visual.getHole then
        return false
    end
    local ok, holeVal = pcall(function()
        return visual:getHole(part)
    end)
    if not ok or holeVal == nil then
        return false
    end
    return holeVal > 0
end

--- Unpatched Back is a common ghost hole: present in visual/getHolesNumber and in
--- Clothing.getCoveredParts, but garment inspect UI often does not list/repair it
--- (shirts, jackets, and many other items after the visible zones were patched).
local function isInspectHiddenHolePart(item, part)
    if not item or not part or not BloodBodyPartType then
        return false
    end
    if part ~= BloodBodyPartType.Back then
        return false
    end
    -- Patched Back is not an open hole.
    if partHasPatch(item, part) then
        return false
    end
    return true
end

--- Real unpatched holes (matches garment inspection).
--- Vanilla getHolesNumber() often counts ghost holes under patches / hidden Back.
function utils.getItemHoles(item)
    if not item then
        return 0
    end

    local visual = item.getVisual and item:getVisual() or nil
    local covered = getClothingCoveredPartsList(item)
    if visual and #covered > 0 then
        local holes = 0
        for i = 1, #covered do
            local part = covered[i]
            if partHasHole(visual, part) and not partHasPatch(item, part) and not isInspectHiddenHolePart(item, part) then
                holes = holes + 1
            end
        end
        return holes
    end

    if item.getHolesNumber then
        return item:getHolesNumber() or 0
    end
    return 0
end

--- Damaged = holes > 0 or condition below threshold (default 0.5).
function utils.isItemDamaged(item, threshold)
    if not item then
        return false
    end
    threshold = threshold or 0.5
    if utils.getItemHoles(item) > 0 then
        return true
    end
    return utils.getItemConditionRatio(item) < threshold
end

--- Border color by condition; holes force at least yellow.
function utils.getConditionBorderColor(item)
    local ratio = utils.getItemConditionRatio(item)
    local holes = utils.getItemHoles(item)
    local r, g, b, a = 0.5, 0.9, 0.5, 0.7

    if ratio < 0.2 then
        r, g, b = 0.9, 0.25, 0.2
    elseif ratio < 0.4 then
        r, g, b = 0.95, 0.55, 0.15
    elseif ratio < 0.7 then
        r, g, b = 0.95, 0.85, 0.2
    end

    if holes > 0 and ratio >= 0.7 then
        r, g, b = 0.95, 0.85, 0.2
    end

    return { r = r, g = g, b = b, a = a }
end

--- Progress bar color (same thresholds as border).
function utils.getConditionBarColor(item)
    local border = utils.getConditionBorderColor(item)
    return { r = border.r, g = border.g, b = border.b, a = 0.95 }
end

function utils.getClothingToggleTexture()
    local candidates = {
        "Base.Tshirt_DefaultTEXTURE",
        "Base.Tshirt_White",
        "Base.Shirt_FormalWhite",
        "Base.Trousers_DefaultTEXTURE"
    }
    local sm = getScriptManager()
    if not sm then
        return nil
    end
    for i = 1, #candidates do
        local scriptItem = nil
        if sm.getItem then
            scriptItem = sm:getItem(candidates[i])
        end
        if not scriptItem and sm.FindItem then
            scriptItem = sm:FindItem(candidates[i])
        end
        if scriptItem then
            if scriptItem.getNormalTexture then
                local tex = scriptItem:getNormalTexture()
                if tex then
                    return tex
                end
            end
            if scriptItem.getIcon then
                local icon = scriptItem:getIcon()
                if icon then
                    local tex = getTexture("Item_" .. icon)
                    if tex then
                        return tex
                    end
                end
            end
        end
    end
    return nil
end

return utils;
