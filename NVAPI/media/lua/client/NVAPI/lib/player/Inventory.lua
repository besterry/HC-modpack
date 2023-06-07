local module = {}

--------------------------------------------------------------------------------
--
-- This is a generic function to find a worn item by using a callback
--
--------------------------------------------------------------------------------
module.findFirstWornItemByCallback = function( player, callback )

  local items = player:getWornItems()

  for i = 0, items:size()-1 do
    local wornitem = items:get(i)
    local invitem  = wornitem:getItem()

    if callback( invitem ) then
      return invitem
    end
  end

  return nil

end

module.findFirstWornItemByTag = function( player, tag )

  return module.findFirstWornItemByCallback(
    player,
    function( item ) return item:hasTag( tag ) end
  )

end


module.overWornItems = function( player, callback )

  local items = player:getWornItems()

  for i = 0, items:size()-1 do
    local wornitem = items:get(i)
    local invitem  = wornitem:getItem()
    callback( invitem )
  end

end


module.findAllWornItemsByTag = function( player, tag )

  local list = {}

  module.overWornItems( player, function(item)
    if item:hasTag( tag ) then
      table.insert( list, item )
    end
  end )

  return list

end



--------------------------------------------------------------------------------
--
-- This is a generic function to find an inventory item by using a callback
--
--------------------------------------------------------------------------------
module.findFirstInventoryItemByCallback = function( player, callback )

  local items = player:getInventory():getItems()

  for i = 0, items:size()-1 do
    local invitem = items:get(i)

    if callback( invitem ) then
      return invitem
    end
  end

  return nil

end

module.findFirstInventoryItemByTag = function( player, tag )

  return module.findFirstInventoryItemByCallback(
    player,
    function( item ) return item:hasTag( tag ) end
  )

end


module.overInventoryItems = function( player, callback )

  local items = player:getInventory():getItems()

  for i = 0, items:size()-1 do
    local invitem = items:get(i)
    callback( invitem )
  end

end



--------------------------------------------------------------------------------
--
-- This is a generic function to find an attached item by using a callback
--
--------------------------------------------------------------------------------
module.findFirstAttachedItemByCallback = function( player, callback )

  local items = player:getAttachedItems()

  for i = 0, items:size()-1 do
    local atitem  = items:get(i)
    local invitem = atitem:getItem()

    if callback( invitem ) then
      return invitem
    end
  end

  return nil

end

module.findFirstAttachedItemByTag = function( player, tag )

  return module.findFirstAttachedItemByCallback(
    player,
    function( item ) return item:hasTag( tag ) end
  )

end

--------------------------------------------------------------------------------
--
-- This is a generic function to find an item where possible
--
--------------------------------------------------------------------------------
module.findFirstItemWithinByTag = function( player, tag )

  local item = module.findFirstWornItemByTag( player, tag )
  if item then
    return item
  end

  item = module.findFirstInventoryItemByTag( player, tag )
  if item then
    return item
  end

  return module.findFirstAttachedItemByTag( player, tag )

end


module.overInventoryItemByTag = function( player, tag, callback )

  local items = player:getInventory():getItems()
  for i = 0, items:size()-1 do
    local invitem = items:get(i)

    if invitem:hasTag( tag ) then
      callback( invitem )
    end
  end

end



return module
