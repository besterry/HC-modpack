local ItemMenuApply   = require "NVAPI/ui/menu/MenuItemApply"
local ItemNightVision = require "NVAPI/item/ItemNightVision"
local nvctrl          = require "NVAPI/ctrl/instance"
local Option          = require "NVAPI/lib/ui/Option"


-- Create [NV] Brightness Menu
--------------------------------------------------------------------------------
local function addFilterOptionToMenu( context, player, nvitem )

  local label        = "[NV] Filter"
  local filterOption = context:addOption( label, nvitem:getBoundItem(), nil )
  local submenu      = ISContextMenu:getNew( context )
  context:addSubMenu( filterOption, submenu )


  for _, filter in ipairs( nvitem.param:getAvailableFilters() ) do
    local label    = filter[1]
    local tex      = filter[2]
    local callback = function() ItemMenuApply.filter( nvitem, label ) end

    submenu:addOption( label, player, callback )
  end

end



-- Create [NV] Brightness Menu
--------------------------------------------------------------------------------
local function addBrightnessOptionToMenu( context, player, nvitem )

  local label   = "[NV] Brightness"
  local option  = context:addOption( label, nvitem:getBoundItem(), nil )
  local submenu = ISContextMenu:getNew( context )
  context:addSubMenu( option, submenu )


  for label, intensity in pairs( nvitem.param:getAvailableBrightness() ) do

    local callback = function() ItemMenuApply.brightness( nvitem, intensity ) end
    submenu:addOption( label, player, callback )

  end

end


-- Create [NV] Charge Menu
--------------------------------------------------------------------------------
local function buildChargeMenuTooltip(percent, isFull, hasBattery)
  local tip = ISToolTip:new()
  tip:initialise()
  tip:setVisible(false)
  tip:setName(getText("IGUI_HydroNV_ChargeTipTitle"))

  if isFull then
    tip.description = getText("IGUI_HydroNV_ChargeFull")
  elseif not hasBattery then
    tip.description = getText("IGUI_HydroNV_ChargeNoBattery") .. "\n"
      .. getText("IGUI_HydroNV_ChargeTipRecharge", percent)
  else
    tip.description = getText("IGUI_HydroNV_ChargeTipRecharge", percent)
  end

  return tip
end


local function addRechargeOptionToMenu( context, player, nvitem )

  local percent = nvitem.charge:getPercent()
  local label   = getText("IGUI_HydroNV_ChargeLabel", percent)
  local action  = function() ItemMenuApply.recharge( player, nvitem ) end
  local item    = nvitem:getBoundItem()
  local option  = context:addOption( label, player, action, item )
  local hasBattery = player:getInventory():getFirstTypeRecurse("Battery") ~= nil

  option.toolTip = buildChargeMenuTooltip(
    percent,
    nvitem.charge:isFull(),
    hasBattery
  )

  if nvitem.charge:isFull() then
    option.notAvailable = true
    option.onSelect = nil
  elseif not hasBattery then
    option.notAvailable = true
    option.onSelect = nil
  end

end


-- Create [NV] Repair Menu
--------------------------------------------------------------------------------
local function addRepairOptionToMenu( context, player, nvitem )

  local label  = getText("IGUI_HydroNV_Repair")
  local action = function() ItemMenuApply.repair( player, nvitem ) end


  local notBroken = function()
    return not nvitem:isBroken()
  end

  local cannotBeRepaired = function()
    return not nvitem:canBeRepaired()
  end

  local opt = Option:new( label, action )
  opt:check( notBroken       , "item is not broken" )
  opt:check( cannotBeRepaired, nvitem.recipe.repair:displayRecipes() )
  opt:renderTo( context, nvitem:getBoundItem() )

end



-- Fill menu options if the selected item is nv capable
---------------------------------------------------------------------------
local function OnFillInventoryObjectContextMenu( _player, context, _items )

  local player   = getSpecificPlayer( _player )
  local itemList = ISInventoryPane.getActualItems( _items )

  -- multiple selection not allowed
  ---------------------------------
  local isMultipleSelection = itemList[2] ~= nil
  if isMultipleSelection then
    return
  end

  -- wrap the selected item to access nv functions
  ------------------------------------------------
  local selectedItem = itemList[1]
  local nvitem       = ItemNightVision.wrap( selectedItem )

  -- do nothing if the item is not a nv item
  ------------------------------------------
  if nvitem:isnotNightVision() then
    return
  end

  -- if the selected item is attached to the controller,
  -- then create specific menu options
  ------------------------------------------------------
  addRechargeOptionToMenu  ( context, player, nvitem )
  if nvitem:isBroken() then
    addRepairOptionToMenu    ( context, player, nvitem )
  end

end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
