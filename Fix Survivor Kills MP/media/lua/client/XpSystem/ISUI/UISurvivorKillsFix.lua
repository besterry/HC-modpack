--**********************************************************
--**                    CHRISTIAN LEMOS                   **
--**     Adds survivors kills to the UI stats panel       **
--**********************************************************

require "ISUI/ISCharacterScreen"

local old_fn = ISCharacterScreen.render

function ISCharacterScreen:render()
	old_fn(self)

	local textWid1 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Favourite_Weapon"))
	local textWid2 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Zombies_Killed"))
	local textWid3 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Survived_For"))
	local textWid4 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Survivor_Killed"))
	local x = 20 + math.max(textWid1, math.max(textWid2, textWid3, textWid4))
	local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	local z = self.height - 10

	self:drawTextRight(getText("IGUI_char_Survivor_Killed"), x, z, 1,1,1,1, UIFont.Small);
	self:drawText(self.char:getSurvivorKills() .. "", x + 10, z, 1,1,1,0.5, UIFont.Small);
	z = z + smallFontHgt + 10
	self:setHeightAndParentHeight(z)
end