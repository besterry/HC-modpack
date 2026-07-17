-- Clothing damage overlay for Mini Health Panel.
-- Injury keeps red and always wins on limbs.
-- Clothing button + badge: only while hovering (footer below body, no feet overlap).

local CLOTHING_COLOR = {
    mild = { r = 0.95, g = 0.85, b = 0.2 },
    bad = { r = 0.95, g = 0.55, b = 0.18 },
    severe = { r = 0.72, g = 0.35, b = 0.92 },
}

local function clothingColorForSeverity(severity)
    if severity >= 0.7 then
        return CLOTHING_COLOR.severe
    end
    if severity >= 0.4 then
        return CLOTHING_COLOR.bad
    end
    return CLOTHING_COLOR.mild
end

local function isLimbInjured(bodyPart)
    if not bodyPart then
        return false
    end
    return bodyPart:HasInjury() or bodyPart:stitched() or bodyPart:bandaged() or bodyPart:scratched() or
               bodyPart:deepWounded() or bodyPart:bitten() or bodyPart:bleeding() or bodyPart:isBurnt() or
               bodyPart:haveGlass() or bodyPart:haveBullet()
end

local function openClothingUI()
    if myClothingUI and myClothingUI.toggle then
        myClothingUI.toggle()
    end
end

local CLOTHING_BAR_H = 32

local function drawBadgeOnButton(btn, count)
    if not count or count <= 0 then
        return
    end
    local label = tostring(count)
    if count > 9 then
        label = "9+"
    end
    local textW = getTextManager():MeasureStringX(UIFont.Small, label)
    local textH = getTextManager():getFontHeight(UIFont.Small)
    local padX, padY = 3, 1
    local badgeW = math.max(16, textW + padX * 2)
    local badgeH = textH + padY * 2
    local badgeX = btn.width - badgeW - 4
    local badgeY = 4
    local col = clothingColorForSeverity(0.5)
    btn:drawRect(badgeX, badgeY, badgeW, badgeH, 0.95, col.r * 0.85, col.g * 0.85, col.b * 0.85)
    btn:drawRectBorder(badgeX, badgeY, badgeW, badgeH, 1, col.r, col.g, col.b)
    btn:drawText(label, badgeX + (badgeW - textW) / 2, badgeY + padY, 1, 1, 1, 1, UIFont.Small)
end

local function ensureClothingBar(mhp)
    if not mhp or mhp.cuiClothingBar then
        return
    end

    local utils = require "utils/utils"
    mhp.cuiBodyHeight = mhp.baseHeight or 271
    local barW = mhp.width or mhp.baseWidth or 120

    local bar = ISPanel:new(0, mhp.cuiBodyHeight, barW, CLOTHING_BAR_H)
    bar.backgroundColor = { r = 0, g = 0, b = 0, a = 0.65 }
    bar.borderColor = { r = 0.45, g = 0.45, b = 0.45, a = 0.9 }
    bar.moveWithMouse = false

    local btn = ISButton:new(0, 0, barW, CLOTHING_BAR_H, "", mhp, function()
        openClothingUI()
    end)
    btn:initialise()
    btn.backgroundColor = { r = 0.12, g = 0.12, b = 0.12, a = 0.4 }
    btn.backgroundColorMouseOver = { r = 0.3, g = 0.3, b = 0.3, a = 0.75 }
    btn.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    btn.tooltip = getText("UI_CUI_open_from_health")
    btn.cuiOwner = mhp

    local tex = utils.getClothingToggleTexture()
    if tex then
        btn:setImage(tex)
        btn:forceImageSize(26, 26)
    else
        btn:setTitle("C")
    end

    local originalBtnRender = btn.render
    function btn:render()
        originalBtnRender(self)
        local owner = self.cuiOwner
        drawBadgeOnButton(self, owner and owner.cuiDamagedCount or 0)
    end

    bar:addChild(btn)
    mhp:addChild(bar)
    mhp.cuiClothingBar = bar
    mhp.cuiClothingBtn = btn
    bar:setVisible(false)
end

local function syncClothingBarLayout(mhp)
    ensureClothingBar(mhp)
    if not mhp or not mhp.cuiClothingBar then
        return
    end

    local bodyH = mhp.cuiBodyHeight or 271
    -- Full panel width (incl. HP bar column when enabled).
    local barW = mhp.width or mhp.baseWidth or 120
    local show = mhp.isHover and not mhp.player_isDead

    if show then
        local targetH = bodyH + CLOTHING_BAR_H
        if mhp.height ~= targetH then
            mhp:setHeight(targetH)
        end
        mhp.cuiClothingBar:setX(0)
        mhp.cuiClothingBar:setY(bodyH)
        mhp.cuiClothingBar:setWidth(barW)
        mhp.cuiClothingBar:setHeight(CLOTHING_BAR_H)
        if mhp.cuiClothingBtn then
            mhp.cuiClothingBtn:setWidth(barW)
            mhp.cuiClothingBtn:setHeight(CLOTHING_BAR_H)
        end
        mhp.cuiClothingBar:setVisible(true)
    else
        if mhp.height ~= bodyH then
            mhp:setHeight(bodyH)
        end
        mhp.cuiClothingBar:setVisible(false)
    end
end

local function applyMiniHealthClothingPatch()
    if not ISMiniHealth or ISMiniHealth.cuiClothingPatched then
        return ISMiniHealth ~= nil and ISMiniHealth.cuiClothingPatched == true
    end
    ISMiniHealth.cuiClothingPatched = true

    local originalUpdate = ISMiniHealth.update
    function ISMiniHealth:update()
        originalUpdate(self)
        syncClothingBarLayout(self)

        self.cuiClothingDamaged = self.cuiClothingDamaged or {}
        self.cuiDamagedCount = 0

        if not myClothingUI or not myClothingUI.getDamagedLimbState then
            return
        end

        local limbState, damagedCount = myClothingUI.getDamagedLimbState(self.player)
        self.cuiClothingDamaged = limbState or {}
        self.cuiDamagedCount = damagedCount or 0

        -- Panel visibility stays health-driven. Clothing does not force the panel open.
    end

    local originalPrerender = ISMiniHealth.prerender
    function ISMiniHealth:prerender()
        originalPrerender(self)
        syncClothingBarLayout(self)
    end

    local originalRender = ISMiniHealth.render
    function ISMiniHealth:render()
        originalRender(self)

        local limbState = self.cuiClothingDamaged
        if not limbState or not self.mhpBodyParts then
            return
        end

        local bodyParts = nil
        if self.player and self.player:getBodyDamage() then
            bodyParts = self.player:getBodyDamage():getBodyParts()
        end

        -- Clothing tint only on healthy limbs. Injury colors always win.
        for idx, info in pairs(limbState) do
            local limb = self.mhpBodyParts[idx]
            if limb and limb.texture and info.damaged then
                local injured = false
                if bodyParts then
                    local bp = bodyParts:get(idx - 1)
                    injured = isLimbInjured(bp)
                end
                if not injured then
                    local col = clothingColorForSeverity(info.severity or 0.4)
                    local a = (0.35 + math.min(info.severity or 0.4, 1) * 0.35) * (self.alpha or 1)
                    self:drawTexture(limb.texture[self.isFemale], 0, 0, a, col.r, col.g, col.b)
                end
            end
        end
    end

    -- LMB on body still opens health. Clothing opens only via footer button.

    print("CUI - MiniHealth clothing overlay patched")
    return true
end

local tickTries = 0
local function tryPatchOnTick()
    if applyMiniHealthClothingPatch() then
        Events.OnTick.Remove(tryPatchOnTick)
        return
    end
    tickTries = tickTries + 1
    if tickTries > 600 then
        Events.OnTick.Remove(tryPatchOnTick)
    end
end

Events.OnGameStart.Add(function()
    applyMiniHealthClothingPatch()
end)
Events.OnCreatePlayer.Add(function()
    applyMiniHealthClothingPatch()
end)
Events.OnTick.Add(tryPatchOnTick)
