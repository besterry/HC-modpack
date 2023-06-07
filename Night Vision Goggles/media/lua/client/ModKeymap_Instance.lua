local FileDatabase = require "ModKeymap_FileDatabase"
local panel        = require "ModKeymap_UIPanel"

local module = {}



--------------------------------------------------------------------------------
--
-- Create a new Mod Keymap Instance
-- The database will be open and read
--
--------------------------------------------------------------------------------
function module:new( modname )

  local o     = {}
  o.name      = modname
  o.db        = FileDatabase.open( modname, true, true )
  o.keymap    = {}

  setmetatable(o, self)
  self.__index = self

  return o

end



--------------------------------------------------------------------------------
--
-- Add keymap
--
--------------------------------------------------------------------------------
function module:add( label, callback, key )

  -- stored key overwrites default set
  ------------------------------------
  local storedkey = self.db:get( label )
  if storedkey then
    key = storedkey
  end

  panel:addKeymapEntry( self, label, callback, key )

end




--------------------------------------------------------------------------------
--
-- Attach a callback to a key
--
--------------------------------------------------------------------------------
function module:assign( key, callback )

  local entry = {
    enabled  = true,
    callback = callback
  }
  self.keymap[ key ] = entry

end




--------------------------------------------------------------------------------
--
-- Detach a callback to a key
--
--------------------------------------------------------------------------------
function module:deassign( key )

  self.keymap[ key ] = nil

end




--------------------------------------------------------------------------------
--
-- Activate a callback on a key
--
--------------------------------------------------------------------------------
function module:activate( key )

  local entry = self.keymap[ key ]
  if entry then
    entry.enabled = true
  end

end





--------------------------------------------------------------------------------
--
-- Deactivate a callback on a key
--
--------------------------------------------------------------------------------
function module:deactivate( key )

  local entry = self.keymap[ key ]
  if entry then
    entry.enabled = false
  end

end


--------------------------------------------------------------------------------
--
-- Get a callback from a key
--
--------------------------------------------------------------------------------
function module:get( key )

  local entry = self.keymap[ key ]
  if entry and entry.enabled then
    return entry.callback
  end

  return nil

end



return module
