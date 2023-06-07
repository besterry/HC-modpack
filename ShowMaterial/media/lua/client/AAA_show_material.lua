
----------Patch tooltips---------


local LOC_KEY = {
	Cotton = "IGUI_SM_Cotton",
	Denim = "IGUI_SM_Denim",
	Leather = "IGUI_SM_Leather",
}

local TYPE_COLOR = {
	Cotton = {.7,.7,.7},
	Denim = {.4,.7,1},
	Leather = {1,.6,.2},
	RED_UNKNOWN = {1,.4,.4}, -- if devs add new type of fabric, this color will be chosen
}

local cache_render_item = nil
local cache_render_text = nil
local cache_render_type = nil

local old_render = ISToolTipInv.render
function ISToolTipInv:render()
	if self.item ~= cache_render_item then
		cache_render_item = self.item
		cache_render_text = nil
		if self.item and self.item.getFabricType then
			local fabric = self.item:getFabricType()
			if fabric then
				cache_render_type = fabric
				local localization = fabric
				local key = LOC_KEY[fabric]
				if key then
					local trans = getText(key)
					if trans ~= key then --translation exists!
						localization = trans
					end
				end
				cache_render_text = getText("IGUI_SM_Fabric") .. localization
			end
		end
	end
	if not cache_render_text then --small item (or error?)
		return old_render(self)
	end
	-- Ninja double injection in injection!
	local stage = 1
	local save_th = 0
	local old_setHeight = self.setHeight
	self.setHeight = function(self, num, ...)
		if stage == 1 then
			stage = 2
			save_th = num
			num = num + 18
		else 
			stage = -1 --error
		end
		return old_setHeight(self, num, ...)
	end
	local old_drawRectBorder = self.drawRectBorder
	self.drawRectBorder = function(self, ...)
		if stage == 2 then
			local col; -- {r,g,b}
			if cache_render_type then
				local col = TYPE_COLOR[cache_render_type] or TYPE_COLOR.RED_UNKNOWN;
				local font = UIFont[getCore():getOptionTooltipFont()];
				self.tooltip:DrawText(font, cache_render_text, 5, save_th-5, col[1], col[2], col[3], 1);
			end
			stage = 3
		else
			stage = -1 --error
		end
		return old_drawRectBorder(self, ...)
	end
	old_render(self)
	self.setHeight = old_setHeight
	self.drawRectBorder = old_drawRectBorder
end







