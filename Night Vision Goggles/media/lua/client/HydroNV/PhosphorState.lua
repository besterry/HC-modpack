local Profiles = require "HydroNV/Profiles"

local PhosphorState = {
  _mode = "green",
}

function PhosphorState:setFromItem(item)
  self._mode = Profiles.get(item).phosphor or "green"
end

function PhosphorState:clear()
  self._mode = "green"
end

function PhosphorState:get()
  return self._mode
end

function PhosphorState:isWhite()
  return self._mode == "white"
end

return PhosphorState
