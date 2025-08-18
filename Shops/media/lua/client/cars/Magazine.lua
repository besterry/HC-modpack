-- media/lua/client/UI/CarMagazine.lua
local CarMagazine = {}

local function getVehicleDisplayName(vehicleType)
    if vehicleType then
        local scriptName = vehicleType:gsub("Base.", vehicleType)
        return getText("IGUI_VehicleName" .. getText(scriptName))
    end
    return nil
end

local function createNewspaperStyle()
    -- Палитра в стиле старой газеты (тёмно-коричневая)
    local COL_BG    = {r=0.78,g=0.68,b=0.58,a=1.0}
    local COL_MARK  = {r=0.75,g=0.65,b=0.55,a=1.0}
    local COL_PANEL = {r=0.82,g=0.72,b=0.62,a=1.0}
    local COL_RULE  = {r=0.50,g=0.40,b=0.30,a=0.15}
    local COL_CARD1 = {r=0.80,g=0.70,b=0.60,a=1.0}
    local COL_CARD2 = {r=0.76,g=0.66,b=0.56,a=1.0}
    local COL_SELLER= {r=0.45,g=0.35,b=0.25,a=1.0}
    local COL_PRICE = {r=0.10,g=0.40,b=0.20,a=1.0}
    local COL_TAG   = {r=0.72,g=0.62,b=0.52,a=1.0}
    local COL_MUTED = {r=0.0,g=0.0,b=0.0,a=1.0}
    local COL_INK   = {r=0.0,g=0.0,b=0.0,a=1.0}
    local COL_HEADER = {r=0.25,g=0.15,b=0.05,a=1.0}
    local COL_SUBHEADER = {r=0.35,g=0.25,b=0.15,a=1.0}
    
    -- Палитра для статусов
    local COL_GOOD = {r=0.12,g=0.55,b=0.27,a=1.0}  -- зелёный для хорошего
    local COL_WARN = {r=0.75,g=0.55,b=0.15,a=1.0}  -- оранжевый для среднего
    local COL_BAD  = {r=0.70,g=0.20,b=0.20,a=1.0}  -- красный для плохого

    local SEP = " · "

    -- Helper-функция для раздельного рендера текста
    local function drawInline(self, x, y, font, chunks)
        local tm = getTextManager()
        local dx = x
        for _, ch in ipairs(chunks) do
            local txt, col = ch[1], ch[2]
            self:drawText(txt, dx, y, col.r, col.g, col.b, 1, font)
            dx = dx + tm:MeasureStringX(font, txt)
        end
    end

    local function fmt1000(n)
        local s = tostring(math.floor(tonumber(n) or 0))
        s = s:reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")
        return s
    end
    local function sanitizePrice(p)
        if p == nil then return nil end
        local s = tostring(p)
        local digits = s:gsub("%D", "")
        if digits == "" then return nil end
        return tonumber(digits) or nil
    end

    local screenW, screenH = getCore():getScreenWidth(), getCore():getScreenHeight()

    -- «Лист»
    local panel = ISPanel:new(0, 0, 860, 610)
    panel:initialise()
    panel:setX((screenW - panel.width) / 2)
    panel:setY((screenH - panel.height) / 2)
    panel.backgroundColor = COL_BG
    panel.borderColor = {r=0.35,g=0.32,b=0.28,a=1}
    panel.moveWithMouse = true

    -- Заголовок (в стиле старой газеты, жирный)
    local title = ISLabel:new(0, 18, 26, getText("IGUI_CarMarket_Title"), COL_HEADER.r, COL_HEADER.g, COL_HEADER.b, 1, UIFont.Large, true)
    title:initialise(); title:setX((panel.width - title:getWidth())/2)
    panel:addChild(title)

    -- Подзаголовок (в стиле старой газеты, жирный)
    local subtitle = ISLabel:new(0, 48, 20, getText("IGUI_CarMarket_Subtitle"), COL_SUBHEADER.r, COL_SUBHEADER.g, COL_SUBHEADER.b, 1, UIFont.Medium, true)
    subtitle:initialise(); subtitle:setX((panel.width - subtitle:getWidth())/2)
    panel:addChild(subtitle)

    -- Линейка
    local rule = ISPanel:new(40, 76, panel.width-80, 1)
    rule:initialise()
    function rule:prerender()
        self:drawRect(0,0,self.width,1, COL_RULE.a, COL_RULE.r, COL_RULE.g, COL_RULE.b)
    end
    panel:addChild(rule)

    -- Список (компактный режим)
    local inset = 24
    local list = ISScrollingListBox:new(inset, 92, panel.width - inset*2, panel.height - 140)
    list:initialise()
    list.backgroundColor = COL_PANEL
    list.itemheight = 72
    list:setHeight(list.height)
    list.font = UIFont.Small
    panel:addChild(list)

    -- Отрисовка карточки (добавляем гос. знак)
    function list:doDrawItem(y, item, alt)
        local h   = self.itemheight or 72
        local w   = self.width
        local pad = 14
    
        -- фон карточки (тёмно-коричневые полосы)
        local bg = ((item.index % 2) == 0) and COL_CARD2 or COL_CARD1
        self:drawRect(6, y + 6, w - 12, h - 12, 1, bg.r, bg.g, bg.b)
    
        local data   = item.item or {}
        local lot    = (data.lot and tostring(data.lot)) or ""
        local model  = tostring(data.model or item.text or "—")
        local seller = tostring(data.seller or "")
        local price  = tostring(data.price or "")
        local carId  = tostring(data.carid or "")
        local hp     = data.hp -- лошадиные силы
        local date   = data.date -- дата выставления
        local condition = data.condition -- состояние в %
        local typeCar = data.typeCar -- тип автомобиля

        -- название (чёрный для лучшей читаемости)
        self:drawText(model, pad, y + 8, COL_INK.r, COL_INK.g, COL_INK.b, 1, UIFont.Medium)
    
        -- гос. знак (если есть) - с заголовком
        if carId ~= "" and carId ~= "nil" then
            self:drawText(getText("IGUI_CarMarket_CarId")..": H " .. carId .. " KT", pad, y + 28, COL_SELLER.r, COL_SELLER.g, COL_SELLER.b, 1, UIFont.Small)
        end
    
        -- продавец - с заголовком
        if seller ~= "" and seller ~= "nil" then
            local sellerY = carId ~= "" and carId ~= "nil" and y + 44 or y + 28
            self:drawText(getText("IGUI_CarMarket_Seller")..": "..seller, pad, sellerY,
                COL_SELLER.r, COL_SELLER.g, COL_SELLER.b, 1, UIFont.Small)
        end

        -- Дополнительная информация в центре карточки с цветовым кодированием
        local centerY = y + 35 -- середина карточки по вертикали
        local centerX = pad + 200 -- отступ от левого края для центра
        local chunks = {} -- { {"текст", color}, {" | ", color}, ... }

        -- Лошадиные силы
        if hp and hp ~= "" and hp ~= "nil" then
            local hpNum = tonumber(hp) or 0
            local hpCol = (hpNum >= 400) and COL_GOOD or (hpNum >= 250 and COL_WARN or COL_BAD)
            table.insert(chunks, {getText("IGUI_CarMarket_HP")..": ", COL_MUTED})
            table.insert(chunks, {tostring(hpNum).."hp", hpCol})
            table.insert(chunks, {" | ", COL_MUTED})
        end

        -- Состояние
        if condition and condition ~= "" and condition ~= "nil" then
            local cNum = tonumber(condition) or 0
            local cCol = (cNum >= 70) and COL_GOOD or (cNum >= 45 and COL_WARN or COL_BAD)
            table.insert(chunks, {getText("IGUI_CarMarket_Condition")..": ", COL_MUTED})
            table.insert(chunks, {string.format("%.0f%%", cNum), cCol})
            table.insert(chunks, {" | ", COL_MUTED})
        end

        -- Тип автомобиля
        if typeCar and typeCar ~= "" and typeCar ~= "nil" then
            local typeText = (typeCar == "1" or typeCar == 1) and getText("IGUI_CarMarket_TypeStandard")
                          or (typeCar == "2" or typeCar == 2) and getText("IGUI_CarMarket_TypeHeavy")
                          or (typeCar == "3" or typeCar == 3) and getText("IGUI_CarMarket_TypeElite")
                          or ""
            if typeText ~= "" then
                table.insert(chunks, {getText("IGUI_CarMarket_Type")..": ", COL_MUTED})
                table.insert(chunks, {typeText, COL_MUTED})
                table.insert(chunks, {" | ", COL_MUTED})
            end
        end

        -- Дата выставления
        if date and date ~= "" and date ~= "nil" then
            table.insert(chunks, {getText("IGUI_CarMarket_Date")..": ", COL_MUTED})
            table.insert(chunks, {date, COL_MUTED})
        end

        -- Рисуем с цветовым кодированием
        if #chunks > 0 then
            -- убираем возможный завершающий разделитель
            if chunks[#chunks][1] == " | " then table.remove(chunks, #chunks) end
            drawInline(self, centerX, centerY, UIFont.Small, chunks)
        end
    
        -- цена в плашке
        if price ~= "" and price ~= "nil" then
            local text  = price .. " $"
            local textW = getTextManager():MeasureStringX(UIFont.Medium, text)
            local tagW, tagH = textW + 20, 24
            local tagX = w - 14 - tagW
            local tagY = y + 8
            self:drawRect(tagX, tagY, tagW, tagH, 1, COL_TAG.r, COL_TAG.g, COL_TAG.b)
            self:drawText(text, tagX + 10, tagY + 5, COL_PRICE.r, COL_PRICE.g, COL_PRICE.b, 1, UIFont.Medium)
    
            -- Лот (исправляем позиционирование чтобы не уходил за границу)
            if lot ~= "" then
                local lotText = getText("IGUI_CarMarket_Lot")..lot
                local lotW = getTextManager():MeasureStringX(UIFont.Small, lotText)
                local lotX = math.min(tagX + 8, w - 20 - lotW)
                self:drawText(lotText, lotX, tagY + tagH + 10, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Small)
            end
        end
    
        return y + h
    end
    
    
    
    
    -- Счётчик лотов
    local counter = ISLabel:new(inset, panel.height - 46, 18, "", COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Small, false)
    counter:initialise()
    panel:addChild(counter)
    local function updateCounter()
        local text = tostring(#list.items) .. " " .. getText("IGUI_CarMarket_Listings")
        counter.name = text
        local tw = getTextManager():MeasureStringX(UIFont.Small, text)
        counter:setX( (panel.width - tw)/2 )
    end

    -- ===== Наполнение (минимум: vehicleKeyId + price; username опционален) + отладка =====
    local items = {}
    local totalInTable, added, skipped = 0, 0, 0

    local carShopData = ModData.get("CarShop")
    if type(carShopData) == "table" then
        for vehicleKeyId, carInfo in pairs(carShopData) do
            totalInTable = totalInTable + 1
            if type(carInfo) ~= "table" then
                skipped = skipped + 1
            else
                local lotId  = carInfo.vehicleKeyId or vehicleKeyId
                local priceN = sanitizePrice(carInfo.price)
                local seller = carInfo.username or getText("IGUI_CarMarket_Anonymous")

                if not lotId then
                    skipped = skipped + 1
                elseif not priceN then
                    skipped = skipped + 1
                else
                    local name = getVehicleDisplayName(carInfo.carname) or 
                                getVehicleDisplayName(carInfo.model) or 
                                carInfo.carname or 
                                carInfo.model or 
                                carInfo.type
                    
                    if not name or name == "" then 
                        name = getText("IGUI_CarMarket_Vehicle") .. " " .. tostring(lotId) 
                    end

                    local metaParts = {}
                    if carInfo.year     then table.insert(metaParts, tostring(carInfo.year)) end
                    if carInfo.color    then table.insert(metaParts, tostring(carInfo.color)) end
                    if carInfo.mileage  then
                        local km = sanitizePrice(carInfo.mileage) or carInfo.mileage
                        table.insert(metaParts, fmt1000(km) .. " km")
                    end
                    if carInfo.condition then table.insert(metaParts, tostring(carInfo.condition)) end
                    if carInfo.note and carInfo.note ~= "" then table.insert(metaParts, tostring(carInfo.note)) end
                    local metaText = table.concat(metaParts, " • ")

                    table.insert(items, {
                        _sortPrice = priceN,
                        text = name,
                        data = {
                            id     = lotId,
                            lot    = tostring(lotId),
                            model  = name,
                            price  = fmt1000(priceN),
                            seller = seller,
                            carid  = carInfo.carid,
                            hp     = carInfo.hp, -- добавляем лошадиные силы
                            date   = carInfo.date, -- добавляем дату
                            condition = carInfo.condition, -- добавляем состояние
                            typeCar = carInfo.typeCar, -- добавляем тип автомобиля
                            meta   = metaText,
                            raw    = carInfo
                        }
                    })
                    added = added + 1
                end
            end
        end
    end

    -- Сортировка по цене (дороже ниже) — можно убрать
    table.sort(items, function(a,b) return (a._sortPrice or 0) < (b._sortPrice or 0) end)

    list:clear()
    for _, it in ipairs(items) do
        local row = list:addItem(it.text or ("Vehicle " .. tostring(it.data.lot or "")), it.data)
        row.height = list.itemheight or 72
    end
    
    if #list.items == 0 then
        local row = list:addItem(getText("IGUI_CarMarket_NoListings"), {model=getText("IGUI_CarMarket_NoListings")})
        row.height = list.itemheight or 72
    end
    
    -- пересчёт скролла
    if list.vscroll and list.vscroll.setValues then
        local rowH   = list.itemheight or 72
        local page   = list.height
        local content= (#list.items) * rowH
        local maxPos = math.max(content - page, 0)
    
        list.vscroll:setValues(0, page, 0, maxPos)
        list.vscroll:setSmallChange(rowH)
        list.vscroll:setLargeChange(page)
        list.vscroll:setScrollPosition(0)
        if list.vscroll.setVisible then
            list.vscroll:setVisible(maxPos > 0)
        end
    end
    
    updateCounter()

    -- Закрыть (исправляем локализацию)
    local closeBtn = ISButton:new(panel.width - 96, panel.height - 40, 80, 28, getText("IGUI_Close"), nil, function()
        panel:removeFromUIManager()
    end)
    closeBtn:initialise()
    closeBtn.backgroundColor = {r=0.70,g=0.68,b=0.62,a=1}
    closeBtn.borderColor     = {r=0.45,g=0.42,b=0.38,a=1}
    panel:addChild(closeBtn)

    return panel
end

function CarMagazine:show()
    if getCore():isDedicated() then return end
    
    -- Проверяем, не открыто ли уже окно
    if CarMagazine.instance then
        CarMagazine.instance:removeFromUIManager()
        CarMagazine.instance = nil
        return
    end
    
    local panel = createNewspaperStyle()
    CarMagazine.instance = panel -- Сохраняем ссылку на открытое окно
    panel:addToUIManager()
    
    -- на всякий случай запросим актуальную моддату
    if ModData and ModData.request then ModData.request("CarShop") end
end

function CarMagazine:close()
    if CarMagazine.instance then
        CarMagazine.instance:removeFromUIManager()
        CarMagazine.instance = nil
    end
end

-- При старте клиента попросим CarShop
Events.OnGameStart.Add(function()
    if getCore():isDedicated() then return end
    if ModData and ModData.request then
        ModData.request("CarShop")
    end
end)

return CarMagazine
