local ItemRecipeRepair = {}

function ItemRecipeRepair:new()

  local o = {}
  setmetatable(o, self)
  self.__index  = self

  o._list = {}

  return o

end


-- count the amount of recipes available
function ItemRecipeRepair:count()

  return #self._list

end


-- add a new recipe
--------------------------------------------------------------------------------
function ItemRecipeRepair:add( list )

  for _, recipe in ipairs( list ) do
    table.insert( self._list, recipe )
  end

end


function getDescription( recipe )

  local text      = ''
  local perks     = recipe.PERKS
  local materials = recipe.MATERIALS

  for perk, level in pairs( perks ) do
    text = text .. "Need " .. perk .. " = " .. level .. "\n"
  end

  for material, amount in pairs( materials ) do
    text = text .. "Need " .. material .. " = " .. amount .. "\n"
  end

  return text

end



-- display in a textual form all recipes (perks and items)
-- needed to repair the item
--------------------------------------------------------------------------------
function ItemRecipeRepair:displayRecipes()

  local display = ''
  local count   = self:count()

  for i = 1, count - 1 do
    local recipe = self._list[i]
    display = display .. getDescription( recipe ) .. "\nor\n"
  end

  local recipe = self._list[ count ]
  local desc   = getDescription( recipe )
  display = display .. desc

  return display

end


-- get a recipe repair based on available player's item
--------------------------------------------------------------------------------
function ItemRecipeRepair:getRecipeFor( player )

  local check = function( recipe )

    local perks     = recipe.PERKS
    local materials = recipe.MATERIALS

    for perkname, level in pairs( perks ) do
      if player:getPerkLevel( Perks[perkname] ) < level then
        return false
      end
    end

    for material, amount in pairs( materials ) do
      local has = player:getInventory():getCountTypeRecurse( material )
      if has < amount then
        return false
      end
    end

    return true

  end


  for _, recipe in ipairs( self._list ) do
    if check( recipe ) then
      return recipe
    end
  end

  return nil

end

-- check if an item can be repaired by the player considering
-- his perks and inventory materials
--------------------------------------------------------------------------------
function ItemRecipeRepair:canBeRepaired( player )

  return self:getRecipeFor( player ) ~= nil

end


-- this function is private and it's being called by the repair
-- it consumes all items based on the recipe list
--------------------------------------------------------------------------------
function ItemRecipeRepair:_consume()

  local player    = getPlayer()
  local recipe    = self:getRecipeFor( player )
  local materials = recipe.MATERIALS

  for material, amount in pairs( materials ) do

    for i = 1, amount do
      local item = player:getInventory():getFirstTypeRecurse( material )
      item:getContainer():Remove( item )
    end

  end

  return recipe

end



function ItemRecipeRepair:fix( item )

  local recipe  = self:_consume()
  local player  = getPlayer()
  local level   = player:getPerkLevel( Perks.Electricity )
  local chance  = recipe.CHANCE( level )
  local roll    = ZombRand( 1, 10 )
  local success = roll >= chance

  if not success then
    item.sound:playRepairFail()    
    return
  end

  local restore = recipe.RESTORE()
  item:getBoundItem():setCondition( restore )

end





return ItemRecipeRepair
