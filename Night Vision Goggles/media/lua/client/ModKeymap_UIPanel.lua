local module = ISPanelJoypad:derive("ModConfig")

local instance


local bound = nil

--
-- User has chosen a key for keymap. We must register and save it
--
function onRegisterKeymap( key )

  local button = bound
  local keymap = button._keymap

  -- clear event data
  -------------------
  bound = nil
  Events.OnKeyPressed.Remove( onRegisterKeymap )

  -- [ESC] clears keymap associated
  ---------------------------------
  local title;

  keymap.mki:deassign( keymap.key )
  local isUserClearingKeymap = key == 1
  if isUserClearingKeymap then

    title = "NO KEY"

  else

    keymap.mki:assign( key, keymap.callback )
    title = Keyboard.getKeyName( key )

  end

  -- set keymap
  -------------
  button.title = "[" .. title .. "]"
  keymap.key = key

  keymap.mki.db:put( keymap.label, key )
  keymap.mki.db:commit()

end


--
-- User has clicked to register a keymap
-- we create a key press listener to get its key
--
function onWaitKeydown( panel, button )

  button.title = "..."
  Events.OnKeyPressed.Add( onRegisterKeymap )
  bound = button

end



function addHorizontalCentralizedLabel( panel, y, text, font )

  local fonth  = getTextManager():getFontHeight(font)
  local x      = panel.width/2 - ( getTextManager():MeasureStringX( font, text ) / 2)

  local label  = ISLabel:new( x, y, y, text, 1, 1, 1, 1, font, true)
  label.center = true
  label:initialise()
  label:instantiate()
  panel:addChild(label)

  return label

end


--------------------------------------------------------------------------------
--
-- we make sure that mod header is only added once
--
--------------------------------------------------------------------------------
function addModHeader( panel, mki )

  local rowinfo = panel._rows

  local needAddModHeader = rowinfo.mod[ mki.name ] == nil
  if not needAddModHeader then
    return
  end

  rowinfo.mod[ mki.name ] = true

  local pad    = 10
  local height = ( rowinfo.count * 30 ) + pad
  rowinfo.count = rowinfo.count + 1

  local text = getText(mki.name .. " Keymap Entries")
  local font = UIFont.Medium
  addHorizontalCentralizedLabel( panel, height, text, font )

end


function addKeymapRow( panel, mki, label, callback, key )

  local height = panel._rows.count * 30
  panel._rows.count = panel._rows.count + 1

  local keylabel
  if key then
    keylabel = "[ " .. Keyboard.getKeyName( key ) .. " ]"
  else
    keylabel = "[ NO KEY ]"
  end


  local text   = label
  local font   = UIFont.Small
  local fonth  = getTextManager():getFontHeight(font)
  local x      = getTextManager():MeasureStringX( font, text )
  local y      = height + 3

  local lbl  = ISLabel:new( x, y, fonth, text, 1, 1, 1, 1, font, true)
  lbl.center = true
  lbl:initialise()
  lbl:instantiate()
  panel:addChild(lbl)


  local input = ISButton:new( 200, height, 60, 20, keylabel, self, onWaitKeydown )
  input:initialise()
  input:instantiate()
  local entry   = { mki = mki, label = label, callback = callback, key = key }
  input._keymap = entry
  panel:addChild(input)

  if key then
    mki:assign( key, callback )
  end

  return input

end



module.addKeymapEntry = function( self, mki, label, callback, key )

  addModHeader( self, mki )
  addKeymapRow( self, mki, label, callback, key )

end


module.new = function( self, x, y, width, height, playerNum)

  local o = {}
  o = ISPanelJoypad:new(x, y, width, height)
  setmetatable(o, self)
  self.__index = self

  o:noBackground()

  o.playerNum       = playerNum
  o.char            = getSpecificPlayer(playerNum)
  o.borderColor     = {r=0.4, g=0.4, b=0.4, a=1};
  o.backgroundColor = {r=0, g=0, b=0, a=0.8};
  o._rows = {
    count   = 0,
    mod     = {},
    widgets = {}
  }

  return o

end
print("SCRIPTPANELUI")

instance = module:new( 0, 8, 500, 500, 0 )
return instance
