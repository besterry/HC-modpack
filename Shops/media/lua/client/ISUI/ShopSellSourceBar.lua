require "ISUI/ISComboBox"
require "ShopSellInventory"

ShopSellSourceBar = ShopSellSourceBar or {}

local COMBO_H = 22
local LABEL_GAP = 6

function ShopSellSourceBar.ensureComboHandler(host)
	if host.onSellSourceComboChanged then return end
	function host:onSellSourceComboChanged()
		if self._sellSourceUpdating then return end
		if not self.sellSourceCombo or not self.sellSourceOnSelect then return end
		local idx = self.sellSourceCombo.selected
		if idx == self.sellSourceIndex then return end
		self.sellSourceIndex = idx
		self.sellSourceOnSelect(idx)
	end
end

function ShopSellSourceBar.destroy(host)
	if host.sellSourceCombo then
		host:removeChild(host.sellSourceCombo)
		host.sellSourceCombo = nil
	end
	if host.sellSourceLabel then
		host:removeChild(host.sellSourceLabel)
		host.sellSourceLabel = nil
	end
	if host.sellSourceButtons then
		for i = 1, #host.sellSourceButtons do
			host:removeChild(host.sellSourceButtons[i])
		end
		host.sellSourceButtons = nil
	end
end

function ShopSellSourceBar.rebuild(host, character, selectedIndex, onSelect, layout)
	ShopSellSourceBar.destroy(host)
	host.sellSources = ShopSellInventory.getSources(character)
	if #host.sellSources == 0 then
		host.sellSourceIndex = 1
		return 0
	end

	host.sellSourceIndex = selectedIndex or host.sellSourceIndex or 1
	if host.sellSourceIndex > #host.sellSources then
		host.sellSourceIndex = 1
	end
	host.sellSourceOnSelect = onSelect

	layout = layout or {}
	local x = layout.x or 0
	local y = layout.y or 0
	local maxW = layout.maxW or 200

	ShopSellSourceBar.ensureComboHandler(host)

	local labelText = getText("IGUI_Sell_Source_Label")
	local labelW = getTextManager():MeasureStringX(UIFont.Small, labelText) + 2
	host.sellSourceLabel = ISLabel:new(x, y + 3, COMBO_H, labelText, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
	host:addChild(host.sellSourceLabel)

	local comboX = x + labelW + LABEL_GAP
	local comboW = math.max(80, maxW - labelW - LABEL_GAP)
	host.sellSourceCombo = ISComboBox:new(comboX, y, comboW, COMBO_H, host, host.onSellSourceComboChanged)
	host.sellSourceCombo:initialise()
	host.sellSourceCombo:instantiate()
	host:addChild(host.sellSourceCombo)

	for i = 1, #host.sellSources do
		host.sellSourceCombo:addOption(host.sellSources[i].label)
	end

	host._sellSourceUpdating = true
	host.sellSourceCombo.selected = host.sellSourceIndex
	host._sellSourceUpdating = false

	return COMBO_H
end
