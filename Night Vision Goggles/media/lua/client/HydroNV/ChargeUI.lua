require "ISUI/ISToolTipInv"

local CONFIG    = require "HydroNV/CONFIG"
local ItemUtil  = require "HydroNV/ItemUtil"

local ChargeUI = {}

function ChargeUI.getPercentText(item)
  if item == nil then
    return "0%"
  end
  return string.format("%.0f%%", ItemUtil.getCharge(item) * 100)
end

function ChargeUI.getChargeColor(charge)
  if charge < 0.25 then
    return 1, 0.35, 0.35
  end
  if charge < 0.5 then
    return 1, 0.85, 0.35
  end
  return 0.55, 1, 0.55
end

function ChargeUI.isNightVisionItem(item)
  return item ~= nil and item:hasTag(CONFIG.ITEM_TAG)
end

function ChargeUI.buildMenuTooltip(player, percentText, isFull, hasBattery)
  local tip = ISToolTip:new()
  tip:initialise()
  tip:setVisible(false)
  tip:setName(getText("IGUI_HydroNV_ChargeTipTitle"))

  if isFull then
    tip.description = getText("IGUI_HydroNV_ChargeFull")
  elseif not hasBattery then
    tip.description = getText("IGUI_HydroNV_ChargeNoBattery") .. "\n"
      .. getText("IGUI_HydroNV_ChargeTipRecharge", percentText)
  else
    tip.description = getText("IGUI_HydroNV_ChargeTipRecharge", percentText)
  end

  return tip
end

function ChargeUI.installTooltipHook()
  if ChargeUI._tooltipInstalled then
    return
  end

  ChargeUI._tooltipRender = ISToolTipInv.render
  function ISToolTipInv:render()
    ChargeUI._tooltipRender(self)

    local item = self.item
    if not ChargeUI.isNightVisionItem(item) then
      return
    end

    local percentText = ChargeUI.getPercentText(item)
    local drawFont = ISToolTip.GetFont()
    local lineHeight = getTextManager():getFontFromEnum(drawFont):getLineHeight()
    local lineSpacing = self.tooltip:getLineSpacing()
    local extraHeight = lineHeight + lineSpacing
    local th = self.tooltip:getHeight()

    self.tooltip:setHeight(th + extraHeight)
    self:setHeight(self.height + extraHeight)

    local yPos = th - lineSpacing + lineSpacing
    local charge = ItemUtil.getCharge(item)
    local r, g, b = ChargeUI.getChargeColor(charge)

    self:drawRect(0, th, self.width, extraHeight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, th, self.width, extraHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawText(getText("IGUI_HydroNV_ChargeTooltip", percentText), 15, yPos + 5, r, g, b, 1, drawFont)
  end

  ChargeUI._tooltipInstalled = true
end

function ChargeUI.install()
  ChargeUI.installTooltipHook()
  require("HydroNV/ChargeHUDSlot").install()
end

return ChargeUI
