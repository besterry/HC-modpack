require 'XpSystem/ISUI/ISCharacterScreen'

local old_loadTraits = ISCharacterScreen.loadTraits
local old_loadProfession = ISCharacterScreen.loadProfession

ISCharacterScreen.loadTraits = function(self)
	old_loadTraits(self);

	for _, image in ipairs(self.traits) do
		image:setMouseOverText(image.trait:getDescription())

		image.tooltipUI = ISToolTip:new()
		image.tooltipUI:setOwner(image)
		image.tooltipUI:setAlwaysOnTop(true)
		image.tooltipUI.name = image.trait:getLabel()
		image.tooltipUI.maxLineWidth = 1000
	end
end

ISCharacterScreen.loadProfession = function(self)
	old_loadProfession(self);

	if self.profession and self.profImage and self.profImage.tooltipUI then
		local profession = ProfessionFactory.getProfession(self.char:getDescriptor():getProfession())

		self.profImage.tooltipUI.name = profession:getName()
		self.profession = profession:getDescription()
	end
end