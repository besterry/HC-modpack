ISMiniScoreboardUI = ISPanel:derive("ISMiniScoreboardUI");
ISMiniScoreboardUI.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISMiniScoreboardUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 80
    local btnHgt = FONT_HGT_SMALL + 2

    local y = 10 + FONT_HGT_SMALL + 10
    self.playerList = ISScrollingListBox:new(10, y, self.width - 20, self.height - (5 + btnHgt + 5) - y);
    self.playerList:initialise();
    self.playerList:instantiate();
    self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.playerList.selected = 0;
    self.playerList.joypadParent = self;
    self.playerList.font = UIFont.NewSmall;
    self.playerList.doDrawItem = self.drawPlayers;
    self.playerList.drawBorder = true;
    self.playerList.onRightMouseUp = ISMiniScoreboardUI.onRightMousePlayerList;
    -- Улучшенная настройка для длинных ников
    self.playerList.horizontalScroll = true;
    self.playerList:setScrollWidth(math.max(self.width - 20, 400)); -- Минимальная ширина для длинных ников
    self:addChild(self.playerList);

    self.no = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, getText("UI_btn_close"), self, ISMiniScoreboardUI.onClick);
    self.no.internal = "CLOSE";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=0.6, g=0.6, b=0.6, a=0.9};
    self.no.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0.9};
    self.no.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=0.95};
    self.no.backgroundColorPressed = {r=0.15, g=0.15, b=0.15, a=0.95};
    self.no.borderColorMouseOver = {r=0.8, g=0.8, b=0.8, a=1.0};
    self.no.borderColorPressed = {r=0.4, g=0.4, b=0.4, a=1.0};
    -- Добавляем эффект свечения для кнопки
    self.no.drawBorder = true;
    self.no.drawBackground = true;
    self:addChild(self.no);

    scoreboardUpdate()
end

function ISMiniScoreboardUI:onRightMousePlayerList(x, y)
    local row = self:rowAt(x, y)
    if row < 1 or row > #self.items then return end
    self.selected = row
    local scoreboard = self.parent
    scoreboard:doPlayerListContextMenu(self.items[row].item, self:getX() + x, self:getY() + y)
end

function ISMiniScoreboardUI:doPlayerListContextMenu(player, x,y)
    local playerNum = self.admin:getPlayerNum()
    local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    context:addOption(getText("UI_Scoreboard_Teleport"), self, ISMiniScoreboardUI.onCommand, player, "TELEPORT");
    context:addOption(getText("UI_Scoreboard_TeleportToYou"), self, ISMiniScoreboardUI.onCommand, player, "TELEPORTTOYOU");
    context:addOption(getText("UI_Scoreboard_Invisible"), self, ISMiniScoreboardUI.onCommand, player, "INVISIBLE");
    context:addOption(getText("UI_Scoreboard_GodMod"), self, ISMiniScoreboardUI.onCommand, player, "GODMOD");
    context:addOption(getText("UI_Check_Stats"), self, ISMiniScoreboardUI.onCommand, player, "STATS");
    context:addOption(getText("UI_Check_Health"), self, ISMiniScoreboardUI.onCommand, player, "CHECK_HEALTH");
end

function ISMiniScoreboardUI:onCommand(player, command)
    if command == "TELEPORT" then
        SendCommandToServer("/teleport \"" .. player.displayName .. "\"");
    elseif command == "TELEPORTTOYOU" then
        SendCommandToServer("/teleport \"" .. player.displayName .. "\" \"" .. self.admin:getDisplayName() .. "\"");
    elseif command == "INVISIBLE" then
        SendCommandToServer("/invisible \"" .. player.displayName .. "\"");
    elseif command == "GODMOD" or command == "GODMODE" then
        SendCommandToServer("/godmod \"" .. player.displayName .. "\"");
    elseif command == "STATS" then
        local playerObj = getPlayerFromUsername(player.username)
        if not playerObj then return end -- player hasn't been encountered yet
        local ui = ISPlayerStatsUI:new(50,50,800,800, playerObj, self.admin)
        ui:initialise();
        ui:addToUIManager();
        ui:setVisible(true);
    elseif command == "CHECK_HEALTH" then
        local playerObj = getPlayerFromUsername(player.username)
        if not playerObj then return end -- player hasn't been encountered yet
        AdminHealthPanel.openFor(playerObj)
    end
end

function ISMiniScoreboardUI:populateList()
    self.playerList:clear();
    if not self.scoreboard then return end
    for i=1,self.scoreboard.usernames:size() do
        local username = self.scoreboard.usernames:get(i-1)
        local displayName = self.scoreboard.displayNames:get(i-1)
        if username ~= self.admin:getUsername() then
            local item = {}
            local name = displayName
            
            -- Получаем время выживания игрока
            local survivalHours = 0
            if username then
                local playerObj = getPlayerFromUsername(username)
                if playerObj then
                    survivalHours = playerObj:getHoursSurvived()
                end
            end
            
            -- Форматируем время выживания
            local survivalText = ""
            local years = survivalHours / 24 / 30 / 12 -- 12 = 1 year
            local months = survivalHours /24 / 30 -- 30 = 1 month -745/24/30 = 1
            local days = survivalHours / 24 -- 24 = 1 day
            local hours = survivalHours -- 1 = 1 hour (% - остаток от деления) 25 % 24 = 1 (целое от деления?) 
            local minutes = survivalHours*60 --0.45 часа = 27 минут (0.45*60 = 27)
            -- print("years ",years, "months ", months, "days ", days, "hours ", hours, "minutes ", minutes, "survivalHours ", survivalHours)
            -- years 	5.250876747427187E-5	months 	6.301052096912625E-4	
            -- days 	0.018903156290737872	hours 	0.018903156290737872	
            -- minutes 	0.007561262516295149	survivalHours 	0.45367575097770896.
            if years >= 1 then
                survivalText = string.format(" [%.1fy]", years)
            elseif months >= 1 then
                survivalText = string.format(" [%.1fm]", months)
            elseif days >= 1 then
                survivalText = string.format(" [%dd]", days)
            elseif hours >= 1 then
                survivalText = string.format(" [%dh]", hours)
            elseif minutes > 0 then
                survivalText = string.format(" [%dmin]", minutes)
            end
            
            -- Обрабатываем длинные ники
            local maxNickLength = 20
            local processedName = displayName
            if string.len(displayName) > maxNickLength then
                processedName = string.sub(displayName, 1, maxNickLength - 3) .. "..."
            end
            
            name = processedName .. survivalText
            item.username = username
            item.text = name
            item.displayName = displayName
            item.survivalHours = survivalHours
            item.originalName = displayName -- Сохраняем оригинальное имя для тултипа
--            if username ~= displayName then
--                name = displayName .. " (" .. username .. ")";
--            end
            local item0 = self.playerList:addItem(name, item);
            if username ~= displayName then
                item0.tooltip = username
            end
            -- Добавляем тултип с полным именем если оно было обрезано
            if string.len(displayName) > maxNickLength then
                item0.tooltip = displayName .. (item0.tooltip and (" | " .. item0.tooltip) or "")
            end
        end
    end
end

function ISMiniScoreboardUI:drawPlayers(y, item, alt)
    local a = 0.9;

    -- Улучшенная граница элемента с закругленными углами
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, 0.5, 0.5, 0.5);
    
    -- Фон элемента с легким свечением
    self:drawRect(1, (y + 1), self:getWidth() - 2, self.itemheight - 3, 0.1, 0.08, 0.08, 0.05);

    if self.selected == item.index then
        -- Улучшенное выделение с градиентом и свечением
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.4, 0.6, 0.4, 0.2);
        self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.8, 0.8, 0.8, 0.6);
        
        -- Эффект свечения вокруг выбранного элемента
        self:drawRectBorder(1, (y + 1), self:getWidth() - 2, self.itemheight - 3, 0.3, 0.8, 0.6, 0.4);
        self:drawRectBorder(2, (y + 2), self:getWidth() - 4, self.itemheight - 5, 0.2, 0.9, 0.7, 0.2);
        
        -- Дополнительный внутренний фон для выбранного элемента
        self:drawRect(2, (y + 2), self:getWidth() - 4, self.itemheight - 5, 0.2, 0.8, 0.6, 0.1);
    end
    
    -- Адаптивное позиционирование текста
    local textX = 10
    local textY = y + 2
    local textColor = {r=1, g=1, b=1, a=a}
    -- Проверяем, нужно ли обрезать текст из-за ширины
    local availableWidth = self:getWidth() - 20 -- 10px отступы с каждой стороны
    local textWidth = getTextManager():MeasureStringX(self.font, item.text)
    
    if textWidth > availableWidth then
        -- Обрезаем текст с многоточием
        local truncatedText = item.text
        while textWidth > availableWidth and string.len(truncatedText) > 5 do
            truncatedText = string.sub(truncatedText, 1, -2) .. "..."
            textWidth = getTextManager():MeasureStringX(self.font, truncatedText)
        end
        -- Тень для обрезанного текста
        self:drawText(truncatedText, textX + 1, textY + 1, 0, 0, 0, 0.3, self.font);
        self:drawText(truncatedText, textX, textY, textColor.r, textColor.g, textColor.b, textColor.a, self.font);
    else
        -- Текст помещается, отображаем полностью с тенью
        self:drawText(item.text, textX + 1, textY + 1, 0, 0, 0, 0.3, self.font);
        self:drawText(item.text, textX, textY, textColor.r, textColor.g, textColor.b, textColor.a, self.font);
    end

    return y + self.itemheight;
end

function ISMiniScoreboardUI:prerender()
    local z = 10;
    
    -- Эффект свечения вокруг всей панели
    self:drawRectBorder(-2, -2, self.width + 4, self.height + 4, 0.2, 0.4, 0.6, 0.3);
    self:drawRectBorder(-1, -1, self.width + 2, self.height + 2, 0.1, 0.6, 0.8, 0.2);
    
    -- Основной фон с улучшенной прозрачностью
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    
    -- Градиентный заголовок с улучшенным переходом
    local headerHeight = FONT_HGT_SMALL + 20
    for i = 0, headerHeight do
        local alpha = 0.9 - (i / headerHeight) * 0.3
        local color = 0.1 + (i / headerHeight) * 0.15
        local purpleTint = (i / headerHeight) * 0.05
        self:drawRect(0, i, self.width, 1, alpha, color + purpleTint, color, color + purpleTint * 0.5);
    end
    
    -- Улучшенная тень для заголовка
    self:drawRect(2, 2, self.width - 4, headerHeight, 0.4, 0, 0, 0);
    self:drawRect(4, 4, self.width - 8, headerHeight, 0.2, 0, 0, 0);
    
    -- Улучшенная граница панели с двойным эффектом
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRectBorder(1, 1, self.width - 2, self.height - 2, 0.3, 0.7, 0.7, 0.7);
    
    -- Дополнительная внутренняя граница для заголовка
    self:drawRectBorder(0, 0, self.width, headerHeight, 0.8, 0.6, 0.6, 0.6);
    
    -- Заголовок с улучшенным стилем и тенью
    self:drawText(getText("IGUI_AdminPanel_MiniScoreboard"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_AdminPanel_MiniScoreboard")) / 2), z, 1, 1, 1, 1, UIFont.Small);
    
    -- Многослойная тень для текста заголовка
    self:drawText(getText("IGUI_AdminPanel_MiniScoreboard"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_AdminPanel_MiniScoreboard")) / 2) + 2, z + 2, 0, 0, 0, 0.3, UIFont.Small);
    self:drawText(getText("IGUI_AdminPanel_MiniScoreboard"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_AdminPanel_MiniScoreboard")) / 2) + 1, z + 1, 0, 0, 0, 0.5, UIFont.Small);
    
    -- Декоративные элементы в углах заголовка
    local cornerSize = 3
    self:drawRect(0, 0, cornerSize, cornerSize, 0.8, 0.8, 0.6, 0.6);
    self:drawRect(self.width - cornerSize, 0, cornerSize, cornerSize, 0.8, 0.8, 0.6, 0.6);
    
    -- Декоративная линия под заголовком
    self:drawRect(10, headerHeight - 2, self.width - 20, 1, 0.6, 0.6, 0.6, 0.4);
    
    -- Дополнительные декоративные элементы по бокам заголовка
    local sideElementWidth = 4
    local sideElementHeight = 2
    self:drawRect(5, headerHeight - 5, sideElementWidth, sideElementHeight, 0.7, 0.7, 0.5, 0.6);
    self:drawRect(self.width - 9, headerHeight - 5, sideElementWidth, sideElementHeight, 0.7, 0.7, 0.5, 0.6);
    
    -- Вертикальные декоративные линии по бокам
    self:drawRect(0, headerHeight + 5, 1, self.height - headerHeight - 10, 0.4, 0.4, 0.4, 0.3);
    self:drawRect(self.width - 1, headerHeight + 5, 1, self.height - headerHeight - 10, 0.4, 0.4, 0.4, 0.3);
end

function ISMiniScoreboardUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    end
end

function ISMiniScoreboardUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISMiniScoreboardUI.instance = nil
end

--************************************************************************--
--** ISMiniScoreboardUI:new
--**
--************************************************************************--
function ISMiniScoreboardUI:new(x, y, width, height, admin)
    local o = {}
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end
    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end
    o.borderColor = {r=0.5, g=0.5, b=0.5, a=1};
    o.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.9};
    o.width = width;
    o.height = height;
    o.admin = admin;
    o.moveWithMouse = true;
    o.scoreboard = nil
    ISMiniScoreboardUI.instance = o;
    return o;
end

function ISMiniScoreboardUI.onScoreboardUpdate(usernames, displayNames, steamIDs)
    if ISMiniScoreboardUI.instance then
        ISMiniScoreboardUI.instance.scoreboard = {}
        ISMiniScoreboardUI.instance.scoreboard.usernames = usernames
        ISMiniScoreboardUI.instance.scoreboard.displayNames = displayNames
        ISMiniScoreboardUI.instance.scoreboard.steamIDs = steamIDs
        ISMiniScoreboardUI.instance:populateList();
    end
end

ISMiniScoreboardUI.OnMiniScoreboardUpdate = function()
    if ISMiniScoreboardUI.instance then
        scoreboardUpdate()
    end
end

-- Events.EveryTenMinutes.Add(ISMiniScoreboardUI.onScoreboardUpdate)
Events.OnScoreboardUpdate.Add(ISMiniScoreboardUI.onScoreboardUpdate)
Events.OnMiniScoreboardUpdate.Add(ISMiniScoreboardUI.OnMiniScoreboardUpdate)
