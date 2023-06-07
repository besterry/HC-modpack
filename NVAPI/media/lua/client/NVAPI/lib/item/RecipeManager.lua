local RecipeRepair = require "NVAPI/lib/item/RecipeRepair"

local ItemRecipe = {}

function ItemRecipe:new()

  local o = {}
  setmetatable(o, self)
  self.__index  = self

  o.repair = RecipeRepair:new()
  --o.make = ItemRecipeMake:new()

  return o

end


return ItemRecipe
