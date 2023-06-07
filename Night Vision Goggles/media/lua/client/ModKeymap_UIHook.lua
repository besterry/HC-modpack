local CONFIG = require "ModKeymap_CONFIG"
local panel  = require "ModKeymap_UIPanel"
--local panel  = require "ModConfig_UIPanel"


local HOOK = {
  createChildren = ISCharacterInfoWindow.createChildren,
  onTabTornOff   = ISCharacterInfoWindow.onTabTornOff,
  SaveLayout     = ISCharacterInfoWindow.SaveLayout
}




ISCharacterInfoWindow.createChildren = function(self)

  HOOK.createChildren( self )
  --ModConfigPanel:new( 0, 8, self.width, self.height-8, self.playerNum )
  panel:initialise()
  panel.infoText = getText( CONFIG.APPNAME )
  self.modConfigPanel = panel
  self.panel:addView( getText( CONFIG.APPNAME ), panel )

end




ISCharacterInfoWindow.onTabTornOff = function( self, view, window )

  if self.playerNum == 0 and view == self.modConfigPanel then
		ISLayoutManager.RegisterWindow('charinfowindow.' .. CONFIG.APPNAME, ISCollapsableWindow, window)
	end
  HOOK.onTabTornOff(self, view, window)

end



ISCharacterInfoWindow.SaveLayout = function(self, name, layout)

  HOOK.SaveLayout( self, name, layout)

  local tabs = {}
  if self.modConfigPanel.parent == self.panel then
      table.insert( tabs, CONFIG.APPNAME )
      if self.modConfigPanel == self.panel:getActiveView() then
          layout.current = CONFIG.APPNAME
      end
  end

  if not layout.tabs then layout.tabs = "" end

  layout.tabs = layout.tabs .. table.concat(tabs, ',')

end



return panel
