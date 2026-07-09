if isServer() then return end

require "ISUI/ISPanel"

local HydroHUDVehicle = require "HydroHUDVehicle"
local Control        = require "HydroNV/Control"
local Inventory      = require "HydroNV/Inventory"
local ItemUtil       = require "HydroNV/ItemUtil"
local ItemMenuApply  = require "NVAPI/ui/menu/MenuItemApply"
local ItemNightVision = require "NVAPI/item/ItemNightVision"

local ChargeHUD = {
  HOTBAR_GAP = 4,
  slots      = {},
}

HydroNVChargeSlot = ISPanel:derive("HydroNVChargeSlot")

local function getChargeBarColor(charge)
  if charge < 0.25 then
    return 0.78, 0.18, 0.12
  end
  if charge < 0.5 then
    return 0.82, 0.68, 0.14
  end
  return 0.34, 0.62, 0.18
end

local function getFlipLabel(item)
  local options = item:getClothingItemExtraOption()
  if options == nil or options:size() == 0 then
    return nil
  end

  local key = options:get(0)
  local label = getText("ContextMenu_" .. key)
  if label == "ContextMenu_" .. key then
    label = getText(key)
  end
  if label == key or label == nil or label == "" then
    return getText("IGUI_HydroNV_Context_Flip")
  end
  return label
end

local function hasClothingExtra(item)
  local extras = item:getClothingItemExtra()
  return extras ~= nil and extras:size() > 0
end

local function getFlipExtraType(item)
  if item == nil or not hasClothingExtra(item) then
    return nil
  end

  local extras = item:getClothingItemExtra()
  return moduleDotType(item:getModule(), extras:get(0))
end

function HydroNVChargeSlot:new(playerNum)
  local o = ISPanel:new(0, 0, 50, 50)
  setmetatable(o, self)
  self.__index = self
  o.playerNum = playerNum
  o.charge = 1
  o.nvItem = nil
  o.slotWidth = 46
  o.slotHeight = 46
  o.margins = 2
  o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
  o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
  return o
end

function HydroNVChargeSlot:initialise()
  ISPanel.initialise(self)
  self:setAnchorLeft(false)
  self:setAnchorRight(false)
  self:setAnchorTop(false)
  self:setAnchorBottom(false)
  self.toolTip = ISToolTip:new()
  self.toolTip:initialise()
  self.toolTip:setVisible(false)
  self.toolTip:addToUIManager()
  self.toolTip:setOwner(self)
end

function HydroNVChargeSlot:syncHotbarMetrics(hotbar)
  if not hotbar then
    return
  end
  if hotbar.slotWidth then self.slotWidth = hotbar.slotWidth end
  if hotbar.slotHeight then self.slotHeight = hotbar.slotHeight end
  if hotbar.margins then self.margins = hotbar.margins end
  self:setWidth(self.slotWidth + self.margins * 2)
  self:setHeight(self.slotHeight + self.margins * 2)
end

function HydroNVChargeSlot:getWornNightVisionItem(player)
  return Inventory.findWornNvDisplayItem(player)
end

function HydroNVChargeSlot:prerender()
  if not self:isVisible() then
    return
  end

  local charge = self.charge or 0
  local slotX = self.margins
  local slotY = self.margins
  local w = self.slotWidth
  local h = self.slotHeight
  local isActive = Control:isOn()
    and self.nvItem ~= nil
    and Control:getActiveItem() == self.nvItem
  local isRaised = self.nvItem ~= nil and not ItemUtil.canActivateNv(self.nvItem)

  local borderR, borderG, borderB = 0.38, 0.38, 0.38
  local borderA = 0.95
  if isActive then
    borderR, borderG, borderB = 0.28, 0.62, 0.28
  elseif isRaised then
    borderR, borderG, borderB = 0.32, 0.32, 0.32
    borderA = 0.7
  end
  if charge < 0.2 then
    local pulse = 0.65 + 0.35 * math.sin((getTimestamp() or 0) / 400)
    borderA = borderA * pulse
  end

  self:drawRect(slotX, slotY, w, h, 0.75, 0.06, 0.06, 0.06)
  self:drawRectBorderStatic(slotX, slotY, w, h, borderA, borderR, borderG, borderB)

  if self.nvItem then
    local tex = self.nvItem:getTexture()
    if tex then
      local iconW = tex:getWidth()
      local iconH = tex:getHeight()
      local maxIcon = math.min(w - 8, h - 14)
      local scale = math.min(maxIcon / iconW, maxIcon / iconH, 1.0)
      local drawW = iconW * scale
      local drawH = iconH * scale
      local ix = slotX + (w - drawW) / 2
      local iy = slotY + (h - drawH) / 2 - 2
      local alpha = isActive and 1 or (isRaised and 0.45 or 0.82)
      self:drawTextureScaled(tex, ix, iy, drawW, drawH, alpha, 1, 1, 1)
    end
  end

  local barH = 5
  local barX = slotX + 1
  local barY = slotY + h - barH - 1
  local innerW = w - 2
  self:drawRect(barX, barY, innerW, barH, 0.85, 0.12, 0.12, 0.12)
  local fillW = math.max(1, math.floor(innerW * charge))
  local r, g, b = getChargeBarColor(charge)
  self:drawRect(barX, barY, fillW, barH, 0.95, r, g, b)

  local pctText = math.floor(charge * 100) .. "%"
  local textW = getTextManager():MeasureStringX(UIFont.Small, pctText)
  self:drawText(pctText, slotX + (w - textW) / 2, slotY + 2, 0.95, 0.95, 0.9, 1, UIFont.Small)

  if self.toolTip and self:isMouseOver() then
    local status
    if isRaised then
      status = getText("IGUI_HydroNV_StatusRaised")
    else
      status = isActive and getText("IGUI_HydroNV_StatusOn") or getText("IGUI_HydroNV_StatusOff")
    end
    self.toolTip.description = getText("IGUI_HydroNV_ChargeTooltip", pctText)
      .. "\n" .. status
    if not isRaised then
      self.toolTip.description = self.toolTip.description .. "\n" .. getText("IGUI_HydroNV_SlotClickHint")
    end
    self.toolTip:setVisible(true)
    self.toolTip:bringToTop()
  elseif self.toolTip then
    self.toolTip:setVisible(false)
  end
end

function HydroNVChargeSlot:isVehicleHudMode(player)
  return HydroHUDVehicle.isVehicleGearHudMode(self.playerNum, player)
end

function HydroNVChargeSlot:shouldShow()
  if self.playerNum > 0 or JoypadState.players[self.playerNum + 1] then
    return false
  end

  local player = getSpecificPlayer(self.playerNum)
  if not player then
    return false
  end

  local vehicleMode = self:isVehicleHudMode(player)
  if not vehicleMode and HydroHUDVehicle.shouldHideInVehicle(self.playerNum, player) then
    return false
  end

  if not vehicleMode then
    local hotbar = getPlayerHotbar(self.playerNum)
    if not hotbar or not hotbar:getIsVisible() then
      return false
    end
  end

  local nvItem = self:getWornNightVisionItem(player)
  if nvItem == nil then
    return false
  end

  self.nvItem = nvItem
  self.charge = ItemUtil.getCharge(nvItem)
  return true
end

function HydroNVChargeSlot:setSizeAndPosition()
  local player = getSpecificPlayer(self.playerNum)
  if player and self:isVehicleHudMode(player) then
    HydroHUDVehicle.syncStandardSlotMetrics(self.playerNum, self)
    HydroHUDVehicle.layoutGearHudSlots(self.playerNum)
    return
  end

  local hotbar = getPlayerHotbar(self.playerNum)
  if not hotbar then
    return
  end

  self:syncHotbarMetrics(hotbar)

  local maskSlot = TZoneMaskFilterHUD and TZoneMaskFilterHUD.getSlot and TZoneMaskFilterHUD.getSlot(self.playerNum)
  if maskSlot and maskSlot:isVisible() then
    self:setX(maskSlot:getX() - self:getWidth() - ChargeHUD.HOTBAR_GAP)
    self:setY(maskSlot:getY())
  else
    self:setX(hotbar:getX() - self:getWidth() - ChargeHUD.HOTBAR_GAP)
    self:setY(hotbar:getY())
  end
end

function HydroNVChargeSlot:update()
  ISPanel.update(self)
  if not self:shouldShow() then
    self:setVisible(false)
    if self.toolTip then
      self.toolTip:setVisible(false)
    end
    return
  end

  self:setVisible(true)
  self:setSizeAndPosition()
end

function HydroNVChargeSlot:onMouseMoveOutside(dx, dy)
  if self.toolTip then
    self.toolTip:setVisible(false)
  end
end

function HydroNVChargeSlot:toggleNightVision()
  local item = self.nvItem
  if item == nil then
    return
  end

  if Control:isOn() and Control:isActiveItem(item) then
    Control:turnOff()
    return
  end

  Control:turnOn(item)
end

function HydroNVChargeSlot:onMouseUp(x, y)
  if not self:isMouseOver() or not self.nvItem then
    return
  end

  self:toggleNightVision()
end

function HydroNVChargeSlot:buildContextMenu(player)
  local item = self.nvItem
  if item == nil then
    return
  end

  local context = ISContextMenu.get(self.playerNum, getMouseX(), getMouseY())
  local flipLabel = getFlipLabel(item)
  local flipExtra = getFlipExtraType(item)
  if flipLabel ~= nil and flipExtra ~= nil then
    context:addOption(flipLabel, player, function()
      ISTimedActionQueue.add(ISClothingExtraAction:new(player, item, flipExtra))
    end)
  end

  local nvitem = ItemNightVision.wrap(item)
  if not nvitem.charge:isFull() then
    local hasBattery = player:getInventory():getFirstTypeRecurse("Battery") ~= nil
    local chargeOpt = context:addOption(getText("IGUI_HydroNV_Context_Charge"), player, function()
      ItemMenuApply.recharge(player, nvitem)
    end)
    if not hasBattery then
      chargeOpt.notAvailable = true
      local tip = ISToolTip:new()
      tip:initialise()
      tip:setVisible(false)
      tip.description = getText("IGUI_HydroNV_ChargeNoBattery")
      chargeOpt.toolTip = tip
    end
  end

  context:addOption(getText("IGUI_HydroNV_Context_Unequip"), player, function()
    if Control:isActiveItem(item) then
      Control:turnOff(false)
    end
    ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50))
  end)
end

function HydroNVChargeSlot:onRightMouseUp(x, y)
  if not self:isMouseOver() or not self.nvItem then
    return
  end

  local player = getSpecificPlayer(self.playerNum)
  if player == nil then
    return
  end

  self:buildContextMenu(player)
end

function ChargeHUD.getSlot(playerNum)
  return ChargeHUD.slots[playerNum]
end

local function createSlot(playerNum)
  if ChargeHUD.slots[playerNum] then
    return
  end

  local slot = HydroNVChargeSlot:new(playerNum)
  slot:initialise()
  slot:addToUIManager()
  slot:setVisible(false)
  ChargeHUD.slots[playerNum] = slot
end

function ChargeHUD.install()
  Events.OnCreatePlayer.Add(createSlot)
  Events.OnGameStart.Add(function()
    createSlot(0)
  end)
end

HydroNVChargeHUD = ChargeHUD

return ChargeHUD
