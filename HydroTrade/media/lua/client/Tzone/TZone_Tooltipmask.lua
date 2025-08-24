require "ISUI/ISToolTipInv"

-- Сохраняем оригинальную функцию render
local ISToolTipInv_render_original = ISToolTipInv.render

-- Создаем новую функцию render, которая расширяет оригинальную
function ISToolTipInv:render()
    -- Сначала вызываем оригинальную функцию
    ISToolTipInv_render_original(self)
    
    -- Затем добавляем нашу функциональность для масок
    if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
        local itemObj = self.item
        if itemObj and instanceof(itemObj, "Clothing") and itemObj:getModData().percent then
            local percent = itemObj:getModData().percent
            local drawFont = ISToolTip.GetFont()
            local lineHeight = getTextManager():getFontFromEnum(drawFont):getLineHeight()
            local lineSpacing = self.tooltip:getLineSpacing()
            
            -- Увеличиваем высоту тултипа для новой строки
            local extraHeight = lineHeight + lineSpacing
            local th = self.tooltip:getHeight()
            self.tooltip:setHeight(th + extraHeight)
            
            -- Увеличиваем высоту самого контейнера тултипа
            self:setHeight(self.height + extraHeight)
            
            -- Позиционируем новую строку выше, чтобы не перекрывать существующий текст
            local yPos = th - (lineSpacing) + lineSpacing
            
            -- Рисуем дополнительный фон для новой строки
            self:drawRect(0, th, self.width, extraHeight, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
            self:drawRectBorder(0, th, self.width, extraHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
            
            -- Рисуем текст фильтра в стиле тултипа (слегка желтоватый)
            local filterText = getText("Tooltip_clothing_Filter") or "Filter"
            self:drawText(filterText, 15, yPos+5, 1, 0.95, 0.95, 0.9, drawFont)
            
            -- Рисуем полосу прогресса
            local barWidth = 80
            local barHeight = 12
            local barX = getTextManager():MeasureStringX(drawFont, filterText) + 25
            local barY = yPos+7
            
            -- Фон полосы в стиле тултипа (темно-серый)
            self:drawRect(barX, barY, barWidth, barHeight, 0.3, 0.2, 0.2, 0.2)
            
            -- Полоса прогресса с цветовой индикацией в стиле игры
            local progressWidth = math.floor(barWidth * percent)
            if progressWidth > 0 then
                local r, g, b = 0, 1, 0 -- зеленый для высокого состояния
                if percent < 0.5 then
                    r, g, b = 1, 1, 0 -- желтый для среднего
                end
                if percent < 0.2 then
                    r, g, b = 1, 0, 0 -- красный для низкого
                end
                self:drawRect(barX, barY, progressWidth, barHeight, 0.8, r, g, b)
            end
            
            -- Граница полосы в стиле тултипа (светло-серый)
            self:drawRectBorder(barX, barY, barWidth, barHeight, 1, 0.6, 0.6, 0.6)
            
            -- Процент текстом в стиле тултипа (чисто белый как цифры)
            local percentText = math.floor(percent * 100) .. "%"
            self:drawText(percentText, barX + barWidth + 5, barY, 1, 1, 1, 1, drawFont)
        end
    end
end
