local CONFIG            = require "NVAPI/CONFIG"
local ItemCharge        = require "NVAPI/item/ItemCharge"
local ItemParam         = require "NVAPI/item/ItemParam"
local ItemCondition     = require "NVAPI/lib/item/Condition"
local ItemRecipeManager = require "NVAPI/lib/item/RecipeManager"
local Sound 					  = require "NVAPI/item/ItemSound"

local ItemNightVision = {}


function ItemNightVision:derive()

  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o

end


function ItemNightVision:new()

  local o = {}
  setmetatable(o, self)
  self.__index  = self
  return o

end

function ItemNightVision.init( o, gameitem )

  o._bound    = gameitem
  o.charge    = ItemCharge:new( o )
	o.param     = ItemParam:new( o )
  o.condition = ItemCondition:new( o )
  o.recipe    = ItemRecipeManager:new( o )
  o.sound     = Sound

  o.recipe.repair:add( CONFIG.REPAIR_RECIPES )

end

function ItemNightVision.wrap( item )

  local obj = ItemNightVision:new()
  ItemNightVision.init( obj, item )

  return obj

end



--------------------------------------------------------------------------------
--
--                           BINDING OPERATIONS
--
--------------------------------------------------------------------------------
function ItemNightVision:getBoundItem()

  return self._bound

end


function ItemNightVision:isBoundTo( gameitem )

	return self:getBoundItem() == gameitem

end


function ItemNightVision:isBound()

  return self:getBoundItem() ~= nil

end


function ItemNightVision:isnotBound()

  return not self:isBound()

end




--------------------------------------------------------------------------------
--
--                         GENERAL CONDITION
--
--------------------------------------------------------------------------------



function ItemNightVision:isNightVision()

	return self._bound:hasTag( CONFIG.ITEM_TAG )

end


function ItemNightVision:isnotNightVision()

	return not self:isNightVision()

end


function ItemNightVision:hasFallen()

	return self:getBoundItem():getContainer() ~= getPlayer():getInventory()

end


function ItemNightVision:isBroken()

  return self.condition:isBroken()

end

function ItemNightVision:isnotBroken()

  return not self:isBroken()

end



function ItemNightVision:isRepairable()

  return self.recipe.repair:count() > 0

end

function ItemNightVision:isnotRepairable()

  return not self:isRepairable()

end


function ItemNightVision:canBeRepaired()

  return self:isRepairable() and self.recipe.repair:canBeRepaired( getPlayer() )

end


function ItemNightVision:cannotBeRepaired()

  return not self:canBeRepaired()

end


function ItemNightVision:repair()

  self.recipe.repair:_fix( self._item )

end


return ItemNightVision
