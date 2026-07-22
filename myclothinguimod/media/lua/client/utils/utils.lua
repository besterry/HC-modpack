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

--- Real unpatched holes (matches garment inspection).
--- Vanilla getHolesNumber() can stay > 0 after a patch is applied (ghost hole under patch).
function utils.getItemHoles(item)
    if not item then
        return 0
    end

    local visual = item.getVisual and item:getVisual() or nil
    if visual and item.getBloodClothingType and BloodClothingType and BloodClothingType.getCoveredParts then
        local covered = BloodClothingType.getCoveredParts(item:getBloodClothingType())
        if covered and covered:size() > 0 then
            local holes = 0
            for i = 0, covered:size() - 1 do
                local part = covered:get(i)
                local holeVal = visual:getHole(part)
                if holeVal and holeVal ~= 0 then
                    local patched = false
                    if item.getPatchType then
                        patched = item:getPatchType(part) ~= nil
                    end
                    if not patched then
                        holes = holes + 1
                    end
                end
            end
            return holes
        end
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
