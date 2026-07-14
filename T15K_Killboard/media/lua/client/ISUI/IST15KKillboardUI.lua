--********************************************************************************
--**                             ALEKSANDR OPEKUNOV | ZUU                       **
--**                BASED ON ISMiniScoreboardUI BY ROBERT JOHNSON               **
--********************************************************************************

IST15KKillboardUI = ISPanel:derive("IST15KKillboardUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

if not getT15KKillboardInstance then
    require "shared/T15KKillboardUtils"
end

local T15KKillboard = getT15KKillboardInstance()

function IST15KKillboardUI:initialise()
    ISPanel.initialise(self)
end

function IST15KKillboardUI:createChildren()
    ISPanel.createChildren(self)
    local btnWid = 70
    local btnHgt = FONT_HGT_SMALL + 2
    local titleBlock = 8 + FONT_HGT_SMALL + 2 + FONT_HGT_SMALL + 4
    local tabHgt = FONT_HGT_SMALL + 6
    local tabWid = (self.width - 30) / 2
    local tabY = titleBlock
    local headerH = FONT_HGT_SMALL + 4
    self.rewardRowH = 24
    self.nextRowH = 20
    self.lastRowH = 22
    self.btnHgt = btnHgt
    self.footerH = btnHgt + 10
    self.isAdminView = getCore():getDebug() or isAdmin()
    self.pendingRewards = T15KKillboard.PendingRewards or {}
    self.listY = tabY + tabHgt + 4 + headerH + 2

    self.mode = T15KKillboard.MODE_MONTHLY
    self.rankData = nil
    self.colHeaderY = tabY + tabHgt + 4
    self.listPadX = 10

    self.tabMonthly = ISButton:new(10, tabY, tabWid, tabHgt, getText("IGUI_T15KKillboard_Tab_Month"), self, IST15KKillboardUI.onClick)
    self.tabMonthly.internal = "TAB_MONTHLY"
    self.tabMonthly:initialise()
    self.tabMonthly:instantiate()
    self.tabMonthly.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
    self.tabMonthly.backgroundColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 }
    self.tabMonthly.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.25, a = 0.95 }
    self:addChild(self.tabMonthly)

    self.tabAllTime = ISButton:new(20 + tabWid, tabY, tabWid, tabHgt, getText("IGUI_T15KKillboard_Tab_AllTime"), self, IST15KKillboardUI.onClick)
    self.tabAllTime.internal = "TAB_ALLTIME"
    self.tabAllTime:initialise()
    self.tabAllTime:instantiate()
    self.tabAllTime.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
    self.tabAllTime.backgroundColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 }
    self.tabAllTime.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.25, a = 0.95 }
    self:addChild(self.tabAllTime)

    self.playerList = ISScrollingListBox:new(10, self.listY, self.width - 20, 100)
    self.playerList:initialise()
    self.playerList:instantiate()
    self.playerList.itemheight = 22
    self.playerList.selected = 0
    self.playerList.joypadParent = self
    self.playerList.font = UIFont.NewSmall
    self.playerList.doDrawItem = self.drawPlayers
    self.playerList.drawBorder = true
    self.playerList.onRightMouseUp = IST15KKillboardUI.onRightMousePlayerList
    self.playerList:addColumn("", 0)
    self.playerList:addColumn("", 35)
    self.playerList:addColumn("", 180)
    self:addChild(self.playerList)

    self.claimBtn = ISButton:new(10, self.height - btnHgt - 5, self.width - 20, btnHgt, getText("IGUI_T15KKillboard_ClaimReward"), self, IST15KKillboardUI.onClick)
    self.claimBtn.internal = "CLAIM_REWARD"
    self.claimBtn.anchorTop = false
    self.claimBtn.anchorBottom = true
    self.claimBtn:initialise()
    self.claimBtn:instantiate()
    self.claimBtn.borderColor = { r = 0.7, g = 0.55, b = 0.15, a = 1 }
    self.claimBtn.backgroundColor = { r = 0.25, g = 0.2, b = 0.05, a = 0.95 }
    self.claimBtn:setVisible(false)
    self:addChild(self.claimBtn)

    self.closeBtn = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.height - btnHgt - 5, btnWid, btnHgt, getText("UI_btn_close"), self, IST15KKillboardUI.onClick)
    self.closeBtn.internal = "CLOSE"
    self.closeBtn.anchorTop = false
    self.closeBtn.anchorBottom = true
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self.closeBtn.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
    self:addChild(self.closeBtn)

    if self.isAdminView then
        self.clearBtn = ISButton:new(self.playerList.x, self.height - btnHgt - 5, btnWid, btnHgt, "CLEAR", self, IST15KKillboardUI.onClick)
        self.clearBtn.internal = "CLEAR"
        self.clearBtn.anchorTop = false
        self.clearBtn.anchorBottom = true
        self.clearBtn:initialise()
        self.clearBtn:instantiate()
        self.clearBtn.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
        self:addChild(self.clearBtn)

        self.testRewardBtn = ISButton:new(self.playerList.x + btnWid + 6, self.height - btnHgt - 5, btnWid + 20, btnHgt, getText("IGUI_T15KKillboard_AdminTestReward"), self, IST15KKillboardUI.onClick)
        self.testRewardBtn.internal = "TEST_REWARD"
        self.testRewardBtn.anchorTop = false
        self.testRewardBtn.anchorBottom = true
        self.testRewardBtn:initialise()
        self.testRewardBtn:instantiate()
        self.testRewardBtn.borderColor = { r = 0.55, g = 0.45, b = 0.2, a = 0.9 }
        self:addChild(self.testRewardBtn)
    end

    self:refreshTabColors()
    self:relayout()
end

function IST15KKillboardUI:hasLastMonthData()
    local results = self.rankData and self.rankData.lastMonthResults
    if not results or not results.winners then
        return false
    end
    for place = 1, 3 do
        local w = results.winners[place]
        if w and w.user then
            return true
        end
    end
    return false
end

function IST15KKillboardUI:shouldShowLastMonth()
    if self.isAdminView then
        return true
    end
    return self:hasLastMonthData()
end

function IST15KKillboardUI:hasPendingRewards()
    return self.pendingRewards and #self.pendingRewards > 0
end

function IST15KKillboardUI:calcBottomBlocksH()
    if self.mode ~= T15KKillboard.MODE_MONTHLY then
        return 0
    end
    local h = 0
    if self:shouldShowLastMonth() then
        h = h + FONT_HGT_SMALL + 4 + (self.lastRowH or 22) * 3 + 4
    end
    h = h + FONT_HGT_SMALL + 4 + (self.rewardRowH or 24) * 3 + 4
    if self.isAdminView then
        h = h + FONT_HGT_SMALL + 4 + (self.nextRowH or 20) * 3 + 4
    end
    return h
end

function IST15KKillboardUI:relayout()
    if not self.playerList then
        return
    end
    local footerH = self.footerH or 30
    local claimH = 0
    if self:hasPendingRewards() then
        claimH = (self.btnHgt or 18) + 6
    end
    local blocksH = self:calcBottomBlocksH()
    local listH = self.height - self.listY - footerH - claimH - blocksH
    if listH < 80 then
        listH = 80
    end
    self.playerList:setHeight(listH)
    self.rewardsY = self.listY + listH + 2

    local btnY = self.height - (self.btnHgt or 18) - 5
    if self.claimBtn then
        local showClaim = self:hasPendingRewards()
        self.claimBtn:setVisible(showClaim)
        if showClaim then
            local claimY = self.listY + listH + blocksH + 4
            if claimY + (self.btnHgt or 18) > btnY - 2 then
                claimY = btnY - (self.btnHgt or 18) - 4
            end
            self.claimBtn:setY(claimY)
            local label = getText("IGUI_T15KKillboard_ClaimReward")
            if #self.pendingRewards > 1 then
                label = label .. " (" .. tostring(#self.pendingRewards) .. ")"
            end
            self.claimBtn:setTitle(label)
        end
    end
    if self.closeBtn then
        self.closeBtn:setY(btnY)
    end
    if self.clearBtn then
        self.clearBtn:setY(btnY)
    end
    if self.testRewardBtn then
        self.testRewardBtn:setY(btnY)
    end
end

function IST15KKillboardUI:setPendingRewards(pending)
    self.pendingRewards = pending or {}
    self:relayout()
end

function IST15KKillboardUI:setRankData(rankData)
    self.rankData = rankData
    self:relayout()
    self:updateList(self:getActiveTable())
end

function IST15KKillboardUI:refreshTabColors()
    local active = { r = 0.6, g = 0.6, b = 0.35, a = 1 }
    local idle = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
    if self.tabMonthly then
        self.tabMonthly.borderColor = self.mode == T15KKillboard.MODE_MONTHLY and active or idle
    end
    if self.tabAllTime then
        self.tabAllTime.borderColor = self.mode == T15KKillboard.MODE_ALLTIME and active or idle
    end
end

function IST15KKillboardUI:getActiveTable()
    if not self.rankData then
        return nil
    end
    if self.mode == T15KKillboard.MODE_ALLTIME then
        return self.rankData.allTime
    end
    return self.rankData.monthly
end

function IST15KKillboardUI:onRightMousePlayerList(x, y)
    local row = self:rowAt(x, y)
    if row < 1 or row > #self.items then
        return
    end
    self.selected = row
    local scoreboard = self.parent
    scoreboard:doPlayerListContextMenu(self.items[row].item, self:getX() + 30, self:getY() + self:getHeight() + 20)
end

function IST15KKillboardUI:doPlayerListContextMenu(player, x, y)
    if getCore():getDebug() or isAdmin() then
        local playerNum = self.admin:getPlayerNum()
        local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
        context:addOption(getText("IGUI_T15KKillboard_Delete"), self, IST15KKillboardUI.onCommand, player, "DELETE")
    end
end

function IST15KKillboardUI:onCommand(player, command)
    if command == "DELETE" then
        local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_T15KKillboard_Confirm"), true, nil, function(_, btn)
            if btn.internal == "YES" then
                print("Delete from killboard: " .. player.user)
                sendClientCommand("T15KKillboardModule", "playerRemove", { player.user })
            end
        end)
        modal:initialise()
        modal:addToUIManager()
    end
end

function IST15KKillboardUI:updateList(tableData)
    self.playerList:clear()

    if tableData == nil then
        local item = {}
        item.user = getText("IGUI_T15KKillboard_Loading")
        item.kills = nil
        self.playerList:addItem(getText("IGUI_T15KKillboard_Loading"), item)
        return
    end

    if #tableData == 0 then
        local item = {}
        item.user = getText("IGUI_T15KKillboard_Empty")
        item.kills = nil
        self.playerList:addItem(getText("IGUI_T15KKillboard_Empty"), item)
        return
    end

    for i = 1, #tableData do
        local item = {}
        item.user = tableData[i][1]
        item.kills = tableData[i][2]
        local item0 = self.playerList:addItem(item.user, item)
        if isAdmin() and tableData[i][4] then
            item0.tooltip = T15KKillboard.timeDiffInString(tableData[i][4])
        end
    end
end

function IST15KKillboardUI:drawPlayers(y, item, alt)
    local iconSize = FONT_HGT_SMALL
    local a = 0.9

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    if item.item.kills == nil then
        self:drawText(tostring(item.item.user), 3, y + 2, 0.75, 0.75, 0.75, a, self.font)
        return y + self.itemheight
    end

    self:drawText(tostring(item.index), 3, y + 2, 1, 1, 1, a, self.font)

    if item.index <= 3 then
        local texture = getTexture("media/textures/UI_Icon_Star_" .. item.index .. ".png")
        if texture then
            self:drawTextureScaledAspect2(texture, 12, y + (self.itemheight - iconSize) / 2 - 1, iconSize, iconSize, 1, 1, 1, 1)
        end
    end
    self:drawText(item.item.user, self.columns[2].size + 3, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(item.item.kills), self.columns[3].size + 3, y + 4, 1, 1, 1, a, self.font)

    return y + self.itemheight
end

function IST15KKillboardUI:drawRewardRows(rewards, startY, rowH, compact)
    local placeRgb = {
        { r = 1.00, g = 0.84, b = 0.20 },
        { r = 0.78, g = 0.80, b = 0.85 },
        { r = 0.82, g = 0.52, b = 0.22 },
    }
    local y = startY
    local iconSize = rowH - 4
    local previewSize = math.min(18, iconSize)
    local previewTex = nil
    if Shop and Shop.textures and Shop.textures.PreviewButton then
        previewTex = Shop.textures.PreviewButton.texture
    elseif getTexture then
        previewTex = getTexture("media/textures/ShopUI_Preview.png")
    end
    local bounds = {}

    for place = 1, 3 do
        local conf = rewards and rewards[place]
        local rgb = placeRgb[place]
        local rowY = y
        local alphaBg = compact and 0.10 or 0.18
        local alphaBr = compact and 0.35 or 0.55

        self:drawRect(8, rowY, self.width - 16, rowH - 1, alphaBg, rgb.r, rgb.g, rgb.b)
        self:drawRectBorder(8, rowY, self.width - 16, rowH - 1, alphaBr, rgb.r, rgb.g, rgb.b)

        local star = getTexture("media/textures/UI_Icon_Star_" .. place .. ".png")
        if star then
            self:drawTextureScaledAspect2(star, 12, rowY + (rowH - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1)
        end
        self:drawText("#" .. tostring(place), 34, rowY + (rowH - FONT_HGT_SMALL) / 2, rgb.r, rgb.g, rgb.b, 1, UIFont.Small)

        local textX = 58
        if conf and conf.item and conf.item ~= "" then
            local vehicleId = T15KKillboard.getVehicleIdFromItem(conf.item)
            local previewX = nil
            if vehicleId and previewTex then
                previewX = self.width - 12 - previewSize - 4
                self:drawTextureScaledAspect2(previewTex, previewX, rowY + (rowH - previewSize) / 2, previewSize, previewSize, 1, 1, 1, 1)
            end

            local tex = T15KKillboard.getItemTexture(conf.item)
            if tex then
                self:drawTextureScaledAspect2(tex, 56, rowY + (rowH - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1)
                textX = 56 + iconSize + 4
            end
            local line = T15KKillboard.formatRewardLine(conf.item, conf.count)
            self:drawText(line, textX, rowY + (rowH - FONT_HGT_SMALL) / 2, 0.92, 0.92, 0.92, 1, UIFont.Small)
            bounds[place] = {
                y1 = rowY,
                y2 = rowY + rowH,
                item = conf.item,
                vehicleId = vehicleId,
                previewX = previewX,
                previewSize = previewSize,
                name = T15KKillboard.getItemDisplayName(conf.item),
            }
        else
            self:drawText(getText("IGUI_T15KKillboard_Reward_None", tostring(place)), textX, rowY + (rowH - FONT_HGT_SMALL) / 2, 0.6, 0.6, 0.6, 1, UIFont.Small)
            bounds[place] = { y1 = rowY, y2 = rowY + rowH, item = nil }
        end

        y = y + rowH
    end

    return y, bounds
end

function IST15KKillboardUI:drawLastMonthBlock(startY)
    local results = self.rankData and self.rankData.lastMonthResults
    local y = startY
    local rowH = self.lastRowH or 22
    local iconSize = rowH - 4
    local placeRgb = {
        { r = 1.00, g = 0.84, b = 0.20 },
        { r = 0.78, g = 0.80, b = 0.85 },
        { r = 0.82, g = 0.52, b = 0.22 },
    }

    local title = getText("IGUI_T15KKillboard_Last_Title")
    if results and results.monthKey then
        title = title .. " (" .. tostring(results.monthKey) .. ")"
    end
    self:drawText(title, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, title) / 2), y, 0.7, 0.85, 0.7, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2

    local bounds = {}
    for place = 1, 3 do
        local w = results and results.winners and results.winners[place]
        local rgb = placeRgb[place]
        local rowY = y
        self:drawRect(8, rowY, self.width - 16, rowH - 1, 0.12, rgb.r, rgb.g, rgb.b)
        self:drawRectBorder(8, rowY, self.width - 16, rowH - 1, 0.4, rgb.r, rgb.g, rgb.b)

        local star = getTexture("media/textures/UI_Icon_Star_" .. place .. ".png")
        if star then
            self:drawTextureScaledAspect2(star, 12, rowY + (rowH - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1)
        end
        self:drawText("#" .. tostring(place), 34, rowY + (rowH - FONT_HGT_SMALL) / 2, rgb.r, rgb.g, rgb.b, 1, UIFont.Small)

        if w and w.user then
            local textX = 58
            local userLine = tostring(w.user) .. " (" .. tostring(w.kills or 0) .. ")"
            self:drawText(userLine, textX, rowY + (rowH - FONT_HGT_SMALL) / 2, 0.9, 0.9, 0.9, 1, UIFont.Small)

            if w.item and w.item ~= "" then
                local nameW = getTextManager():MeasureStringX(UIFont.Small, userLine)
                local itemX = textX + nameW + 8
                local tex = T15KKillboard.getItemTexture(w.item)
                if tex and itemX + iconSize < self.width - 20 then
                    self:drawTextureScaledAspect2(tex, itemX, rowY + (rowH - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1)
                    bounds[place] = { y1 = rowY, y2 = rowY + rowH, item = w.item }
                else
                    bounds[place] = { y1 = rowY, y2 = rowY + rowH, item = w.item }
                end
            end
        else
            self:drawText("-", 58, rowY + (rowH - FONT_HGT_SMALL) / 2, 0.55, 0.55, 0.55, 1, UIFont.Small)
        end
        y = y + rowH
    end

    return y, bounds
end

function IST15KKillboardUI:drawRewardsBlock()
    if self.mode ~= T15KKillboard.MODE_MONTHLY or not self.rewardsY then
        self.rewardLineBounds = nil
        return
    end

    self.rewardLineBounds = {}
    local y = self.rewardsY

    if self:shouldShowLastMonth() then
        local lastBounds
        y, lastBounds = self:drawLastMonthBlock(y)
        for place, b in pairs(lastBounds or {}) do
            if b and b.item then
                self.rewardLineBounds["l" .. place] = b
            end
        end
        y = y + 4
    end

    local rewards = (self.rankData and self.rankData.rewards) or T15KKillboard.getRewardConfig()
    local rowH = self.rewardRowH or 24
    local title = getText("IGUI_T15KKillboard_Rewards_Title")
    self:drawText(title, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, title) / 2), y, 0.9, 0.85, 0.55, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2

    local bounds
    y, bounds = self:drawRewardRows(rewards, y, rowH, false)
    for place, b in pairs(bounds or {}) do
        self.rewardLineBounds[place] = b
    end

    if self.isAdminView then
        y = y + 4
        local nextTitle = getText("IGUI_T15KKillboard_Next_Title")
        self:drawText(nextTitle, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, nextTitle) / 2), y, 0.55, 0.75, 0.95, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL + 2
        local nextRewards = (self.rankData and self.rankData.nextRewards) or T15KKillboard.getNextRewardConfig()
        local nextBounds
        y, nextBounds = self:drawRewardRows(nextRewards, y, self.nextRowH or 20, true)
        for place = 1, 3 do
            if nextBounds[place] and nextBounds[place].item then
                self.rewardLineBounds["n" .. place] = nextBounds[place]
            end
        end
    end
end

function IST15KKillboardUI:hideRewardTooltip()
    if self.rewardTooltip then
        self.rewardTooltip:setVisible(false)
        self.rewardTooltip:removeFromUIManager()
        self.rewardTooltip = nil
    end
    self.rewardTooltipItemType = nil
end

function IST15KKillboardUI:showRewardTooltip(fullType)
    if not fullType or fullType == "" or T15KKillboard.isPMBalanceReward(fullType) then
        self:hideRewardTooltip()
        return
    end
    if self.rewardTooltipItemType == fullType and self.rewardTooltip then
        return
    end
    self:hideRewardTooltip()
    local invItem = T15KKillboard.createInvItem(fullType)
    if not invItem then
        return
    end
    self.rewardTooltip = ISToolTipInv:new(invItem)
    self.rewardTooltip:initialise()
    self.rewardTooltip:setOwner(self)
    self.rewardTooltip:setCharacter(getPlayer())
    self.rewardTooltip:addToUIManager()
    self.rewardTooltip:setVisible(true)
    self.rewardTooltipItemType = fullType
end

function IST15KKillboardUI:getPreviewHitAt(mx, my)
    if self.mode ~= T15KKillboard.MODE_MONTHLY or not self.rewardLineBounds then
        return nil
    end
    for _, b in pairs(self.rewardLineBounds) do
        if b and b.vehicleId and b.previewX and my >= b.y1 and my < b.y2 then
            local size = b.previewSize or 18
            if mx >= b.previewX and mx <= b.previewX + size then
                return b
            end
        end
    end
    return nil
end

function IST15KKillboardUI:getHoveredRewardItem()
    if self.mode ~= T15KKillboard.MODE_MONTHLY or not self.rewardLineBounds then
        return nil
    end
    if not self:isMouseOver() then
        return nil
    end
    local mx = self:getMouseX()
    local my = self:getMouseY()
    if self:getPreviewHitAt(mx, my) then
        return nil
    end
    for _, b in pairs(self.rewardLineBounds) do
        if b and b.item and my >= b.y1 and my < b.y2 then
            return b.item
        end
    end
    return nil
end

function IST15KKillboardUI:tryOpenVehiclePreview(mx, my)
    local hit = self:getPreviewHitAt(mx, my)
    if not hit or not hit.vehicleId then
        return false
    end
    if not PreviewUI or not PreviewUI.show then
        return false
    end
    if PreviewUI.instance then
        PreviewUI.instance:close()
    end
    PreviewUI:show(hit.name or hit.item, hit.vehicleId)
    return true
end

function IST15KKillboardUI:onMouseDown(x, y)
    ISPanel.onMouseDown(self, x, y)
    if self:tryOpenVehiclePreview(x, y) then
        self:hideRewardTooltip()
    end
end

function IST15KKillboardUI:onMouseMove(dx, dy)
    ISPanel.onMouseMove(self, dx, dy)
    local itemType = self:getHoveredRewardItem()
    if itemType then
        self:showRewardTooltip(itemType)
    else
        self:hideRewardTooltip()
    end
end

function IST15KKillboardUI:onMouseMoveOutside(dx, dy)
    ISPanel.onMouseMoveOutside(self, dx, dy)
    self:hideRewardTooltip()
end

function IST15KKillboardUI:prerender()
    local z = 6
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local title
    local maxPlayers = T15KKillboard.getSandboxVar("PlayersPerPage") or 30
    if self.mode == T15KKillboard.MODE_ALLTIME then
        title = getText("IGUI_T15KKillboard_Rank_Title") .. " " .. maxPlayers .. " " .. getText("IGUI_T15KKillboard_Rank_Title_AllTime")
    else
        title = getText("IGUI_T15KKillboard_Rank_Title") .. " " .. maxPlayers .. " " .. getText("IGUI_T15KKillboard_Rank_Title_Month")
        if self.rankData and self.rankData.monthKey then
            title = title .. " (" .. self.rankData.monthKey .. ")"
        end
    end
    self:drawText(title, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, title) / 2), z, 1, 1, 1, 1, UIFont.Small)

    if self.mode == T15KKillboard.MODE_MONTHLY then
        local leftText = T15KKillboard.getMonthRemainingText(self.rankData)
        self:drawText(leftText, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, leftText) / 2), z + FONT_HGT_SMALL + 1, 0.85, 0.85, 0.7, 1, UIFont.Small)
    end

    if self.colHeaderY and self.playerList then
        local hy = self.colHeaderY
        local lx = self.listPadX or 10
        self:drawText("#", lx + 3, hy, 0.75, 0.75, 0.75, 1, UIFont.Small)
        self:drawText(getText("IGUI_T15KKillboard_Name"), lx + self.playerList.columns[2].size + 3, hy, 0.75, 0.75, 0.75, 1, UIFont.Small)
        self:drawText(getText("IGUI_T15KKillboard_Kills"), lx + self.playerList.columns[3].size + 3, hy, 0.75, 0.75, 0.75, 1, UIFont.Small)
    end

    self:drawRewardsBlock()
end

function IST15KKillboardUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    elseif button.internal == "TAB_MONTHLY" then
        self.mode = T15KKillboard.MODE_MONTHLY
        self:refreshTabColors()
        self:relayout()
        self:updateList(self:getActiveTable())
    elseif button.internal == "TAB_ALLTIME" then
        self.mode = T15KKillboard.MODE_ALLTIME
        self:hideRewardTooltip()
        self:refreshTabColors()
        self:relayout()
        self:updateList(self:getActiveTable())
    elseif button.internal == "CLAIM_REWARD" then
        sendClientCommand("T15KKillboardModule", "claimRewards", {})
    elseif button.internal == "CLEAR" then
        local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_T15KKillboard_Clear"), true, nil, function(_, btn)
            if btn.internal == "YES" then
                sendClientCommand("T15KKillboardModule", "clearKillboard", { self.mode })
            end
        end)
        modal:initialise()
        modal:addToUIManager()
    elseif button.internal == "TEST_REWARD" then
        sendClientCommand("T15KKillboardModule", "adminTestReward", {})
    end
end

function IST15KKillboardUI:close()
    self:hideRewardTooltip()
    if PreviewUI and PreviewUI.instance then
        PreviewUI.instance:close()
    end
    self:setVisible(false)
    self:removeFromUIManager()
    self:onClose()
    IST15KKillboardUI.instance = nil
end

function IST15KKillboardUI:new(x, y, width, height, onClose, player)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
    o.width = width
    o.height = height
    o.admin = getPlayer()
    o.moveWithMouse = true
    o.killboard = {}
    o.onClose = onClose
    o.mode = T15KKillboard.MODE_MONTHLY
    IST15KKillboardUI.instance = o
    return o
end
