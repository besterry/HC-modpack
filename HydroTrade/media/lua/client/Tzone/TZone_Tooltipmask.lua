require "ISUI/ISToolTipInv"

function ISToolTipInv:render()
	-- мы рендерим тултип для предмета в инвентаре только если нет контекстного меню
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
	local lineHeight = getTextManager():getFontFromEnum(drawFont):getLineHeight()
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
				local lineHeight = getTextManager():getFontFromEnum(drawFont):getLineHeight()
				local lineSpacing = self.tooltip:getLineSpacing()
				
				-- Увеличиваем высоту тултипа для новой строки
				local extraHeight = lineHeight + lineSpacing;
				self.tooltip:setHeight(th + extraHeight);
				
				-- Увеличиваем высоту самого контейнера тултипа
				self:setHeight(self.height + extraHeight);
				
				-- Позиционируем новую строку выше, чтобы не перекрывать существующий текст
				local yPos = th - (lineSpacing) + lineSpacing;
				
                self:drawRect(0, th, self.width, extraHeight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
				self:drawRectBorder(0, th, self.width, extraHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
				-- Рисуем текст фильтра в стиле тултипа (слегка желтоватый)
				local filterText = getText("Tooltip_clothing_Filter") or "Filter";
				self:drawText(filterText, 15, yPos+5, 1, 0.95, 0.95, 0.9, drawFont); -- слегка желтый
				
				-- Рисуем полосу прогресса
				local barWidth = 80;
				local barHeight = 12;
				local barX = getTextManager():MeasureStringX(drawFont, filterText) + 25; -- сразу за текстом
				local barY = yPos+7;
				
				-- Фон полосы в стиле тултипа (темно-серый)
				self:drawRect(barX, barY, barWidth, barHeight, 0.3, 0.2, 0.2, 0.2);
				
				-- Полоса прогресса с цветовой индикацией в стиле игры
				local progressWidth = math.floor(barWidth * percent);
				if progressWidth > 0 then
					local r, g, b = 0, 1, 0; -- зеленый для высокого состояния
					if percent < 0.5 then
						r, g, b = 1, 1, 0; -- желтый для среднего
					end
					if percent < 0.2 then
						r, g, b = 1, 0, 0; -- красный для низкого
					end
					self:drawRect(barX, barY, progressWidth, barHeight, 0.8, r, g, b);
				end
				
				-- Граница полосы в стиле тултипа (светло-серый)
				self:drawRectBorder(barX, barY, barWidth, barHeight, 1, 0.6, 0.6, 0.6);
				
				-- Процент текстом в стиле тултипа (чисто белый как цифры)
				local percentText = math.floor(percent * 100) .. "%";
				self:drawText(percentText, barX + barWidth + 5, barY, 1, 1, 1, 1, drawFont);
			end;
		end;
	
	
	end
end
