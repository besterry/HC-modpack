require "ISUI/ISButton"

ShopCategoryButton = ISButton:derive("ShopCategoryButton")

function ShopCategoryButton:new(x, y, w, h, title, icon, clicktarget, onclick)
	local o = ISButton:new(x, y, w, h, "", clicktarget, onclick)
	setmetatable(o, self)
	self.__index = self
	o.categoryTitle = title or ""
	o.categoryIcon = icon
	o.iconSize = ShopUIMode.ICON_SLOT - 2
	o.textPad = ShopUIMode.ICON_SLOT + 4
	o.font = UIFont.Medium
	return o
end

function ShopCategoryButton:render()
	ISButton.render(self)
	if self.categoryIcon then
		local size = self.iconSize
		local iy = (self.height - size) / 2
		self:drawTextureScaledAspect(self.categoryIcon, 4, iy, size, size, 1, 1, 1, 1)
	end
	if self.categoryTitle and self.categoryTitle ~= "" then
		local fontH = getTextManager():getFontFromEnum(self.font):getLineHeight()
		local alpha = self.enable and 1 or 0.45
		self:drawText(self.categoryTitle, self.textPad, (self.height - fontH) / 2, 1, 1, 1, alpha, self.font)
	end
end
