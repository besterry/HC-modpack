---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Robotex140.
--- Based on Zomboid RainCollectorBarrel
--- DateTime: 16-Jan-22 16:10
---


require "Map/CGlobalObjectSystem"

CBeehiveSystem = CGlobalObjectSystem:derive("CBeehiveSystem")

function CBeehiveSystem:new()
    local o = CGlobalObjectSystem.new(self, "Beehive")
    return o
end

function CBeehiveSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "beehive_global"
end

function CBeehiveSystem:newLuaObject(globalObject)
    return CBeehiveGlobalObject:new(self, globalObject)
end

CGlobalObjectSystem.RegisterSystemClass(CBeehiveSystem)

-- Попытки исправления

-- function CBeehiveSystem:getLuaObjectOnSquare(square)
-- 	if not square then return nil end
--     print(square:getX(),",", square:getY(),",", square:getZ())
-- 	return self:getLuaObjectAt(square:getX(), square:getY(), square:getZ())
-- end

-- function CBeehiveSystem:getLuaObjectAt(x, y, z)
-- 	local globalObject = CBeehiveSystem.instance:getObjectAt(x, y, z)
--     print("globalObject:",globalObject)
-- 	return globalObject and globalObject:getModData() or nil
-- end

-- Попытки исправления

local function DoSpecialTooltip(tooltipUI, square)

    local beehive = CBeehiveSystem.instance:getIsoObjectOnSquare(square)
    if not beehive or not beehive:getModData()["honeyMax"] then return end

    local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    tooltipUI:setHeight(6 + smallFontHgt + 6 + smallFontHgt + 12)

    local textX = 12
    local textY = 6 + smallFontHgt + 6

    local barX = textX + getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpanel_Remaining")) + 12
    local barWid = 80
    local barHgt = 4
    local barY = textY + (smallFontHgt - barHgt) / 2 + 2

    tooltipUI:setWidth(barX + barWid + 12)
    tooltipUI:DrawTextureScaledColor(nil, 0, 0, tooltipUI:getWidth(), tooltipUI:getHeight(), 0, 0, 0, 0.75)
    tooltipUI:DrawTextCentre('beehive menu', tooltipUI:getWidth() / 2, 6, 1, 1, 1, 1)
    tooltipUI:DrawText(getText("IGUI_invpanel_Remaining") .. ":", textX, textY, 1, 1, 1, 1)

    local f = beehive:getModData()['honeyAmount'] / beehive:getModData()["honeyMax"]
    local fg = { r=0.0, g=0.6, b=0.0, a=0.7 }
    if f < 0.0 then f = 0.0 end
    if f > 1.0 then f = 1.0 end
    local done = math.floor(barWid * f)
    if f > 0 then done = math.max(done, 1) end
    tooltipUI:DrawTextureScaledColor(nil, barX, barY, done, barHgt, fg.r, fg.g, fg.b, fg.a)
    local bg = {r=0.15, g=0.15, b=0.15, a=1.0}
    tooltipUI:DrawTextureScaledColor(nil, barX + done, barY, barWid - done, barHgt, bg.r, bg.g, bg.b, bg.a)
end

-- Events.DoSpecialTooltip.Add(DoSpecialTooltip)

