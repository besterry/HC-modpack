require "ISUI/ISToolTipInv"

function ISToolTipInv:render()
	-- we render the tool tip for inventory item only if there's no context menu showed
	if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then

     local mx = getMouseX() + 24;
     local my = getMouseY() + 24;
     if not self.followMouse then
        mx = self:getX()
        my = self:getY()
        if self.anchorBottomLeft then
            mx = self.anchorBottomLeft.x
            my = self.anchorBottomLeft.y
        end
     end

        self.tooltip:setX(mx+11);
        self.tooltip:setY(my);

        self.tooltip:setWidth(50)
        self.tooltip:setMeasureOnly(true)
        self.item:DoTooltip(self.tooltip);
        self.tooltip:setMeasureOnly(false)

     -- clampy x, y

     local myCore = getCore();
     local maxX = myCore:getScreenWidth();
     local maxY = myCore:getScreenHeight();

     local tw = self.tooltip:getWidth();
     local th = self.tooltip:getHeight();
	 local extraHeight = 0;
	 local drawFont = ISToolTip.GetFont();
	local lineHeight = getTextManager():getFontFromEnum(drawfont):getLineHeight()
	local lineSpacing = self.tooltip:getLineSpacing()
	 if self.item and self.item:getModData().customTooltip then
		local customTooltip = self.item:getModData().customTooltip
		extraHeight = (lineSpacing) * 1; --#customTooltip
	 end
     
     self.tooltip:setX(math.max(0, math.min(mx + 11, maxX - tw - 1)));
    if not self.followMouse and self.anchorBottomLeft then
        self.tooltip:setY(math.max(0, math.min(my - th, maxY - th - 1)));
    else
        self.tooltip:setY(math.max(0, math.min(my, maxY - th - 1)));
    end

     self:setX(self.tooltip:getX() - 11);
     self:setY(self.tooltip:getY());
     self:setWidth(tw + 11);
     self:setHeight(th);

	if self.followMouse then
		self:adjustPositionToAvoidOverlap({ x = mx - 24 * 2, y = my - 24 * 2, width = 24 * 2, height = 24 * 2 })
	end

     self:drawRect(0, 0, self.width, self.height + extraHeight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
     self:drawRectBorder(0, 0, self.width, self.height + extraHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
     self.item:DoTooltip(self.tooltip);
	
		local tooltip = self.tooltip;
		local itemObj = self.item;
		if itemObj then
			if instanceof(itemObj, "Clothing") and itemObj:getModData().percent then
				local percent = itemObj:getModData().percent;
				local drawFont = ISToolTip.GetFont();
				local lineHeight = getTextManager():getFontFromEnum(drawfont):getLineHeight()
				local labelWidth = getTextManager():MeasureStringX(drawFont, getText("Tooltip_clothing_Filter"));
				local labelWidth2 = getTextManager():MeasureStringX(drawFont, getText("Tooltip_item_Windresist"));
				local labelWidth3 = getTextManager():MeasureStringX(drawFont, getText("Tooltip_item_Waterresist"));
				local labelMaxWidth = math.max(labelWidth, labelWidth2, labelWidth3)
				local toolhieght = tooltip:getHeight() + 2;
				local layout = tooltip:beginLayout();
				local layoutItem = layout:addItem();
				layoutItem:reset();
				layoutItem:setLabel(getText("Tooltip_clothing_Filter"), 1, 1, 0.8, 1);
				layoutItem:setProgress(percent, 0, 0.42, 0, 1)
				layoutItem:calcSizes();
				layoutItem:render(5, th - (lineSpacing / 2), labelMaxWidth + 15, 80, tooltip) --100 + (15 - lineHeight) / 2
			end;
		end;
	
	
	end
end
