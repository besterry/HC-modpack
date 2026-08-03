--***********************************************************
--**                ALEKSANDR OPEKUNOV | ZUU               **
--***********************************************************

if isServer() then
    return
end

local ipairs = ipairs

if not getT15KKillboardInstance then
    require "shared/T15KKillboardUtils"
end

local T15KKillboard = getT15KKillboardInstance()

---------- SAVE PLAYER DATA ----------

-- после смерти игнорим обычные апдейты, пока не будет живого персонажа с киллами
local suppressRankUpdates = false

local function updatePlayerRank(onDead)
    -- staff не шлём апдейты, кроме когда CountAdmins включён для теста
    if isAdmin() and not T15KKillboard.getSandboxVar("CountAdmins") then
        return
    end
    local _player = getPlayer()
    if not _player then
        return
    end

    if onDead then
        suppressRankUpdates = true
        sendClientCommand("T15KKillboardModule", "playerUpdate", { _player:getUsername(), 0, 0 })
        return
    end

    if suppressRankUpdates then
        -- новый персонаж: снимаем блок только когда киллы уже с нуля/малые, либо просто при первом валидном апдейте
        if _player:isAlive() then
            suppressRankUpdates = false
        else
            return
        end
    end

    if not _player:isAlive() then
        return
    end

    if _player:getZombieKills() < T15KKillboard.getSandboxVar("MinKills") then
        return
    end

    local zmbKll = _player:getZombieKills()
    local srvKll = _player:getSurvivorKills()
    sendClientCommand("T15KKillboardModule", "playerUpdate", { _player:getUsername(), zmbKll, srvKll })
end

Events.OnGameStart.Add(function()
    suppressRankUpdates = false
    updatePlayerRank(false)
end)

local serverUpdateTickRate = T15KKillboard.getSandboxVar("ServerTickRate")
if serverUpdateTickRate == 1 or T15KKillboard.isSinglePlayer() then
    Events.EveryTenMinutes.Add(updatePlayerRank)
elseif serverUpdateTickRate == 2 then
    Events.EveryHours.Add(updatePlayerRank)
else
    Events.EveryDays.Add(updatePlayerRank)
end

---------- ADD TOOLBAR BTN ----------
local textureOff = getTexture("media/textures/Icon_T15KRank_off.png")
local textureOn = getTexture("media/textures/Icon_T15KRank_on.png")

local window = nil
local toolbarButton = nil

local function showKillboard()
    if window and window:getIsVisible() then
        window:close()
        toolbarButton:setImage(textureOff)
    else
        toolbarButton:setImage(textureOn)
        local w, h = 320, 620
        if getCore():getDebug() or isAdmin() then
            h = 720
        end
        local x = toolbarButton:getAbsoluteX() + toolbarButton:getWidth() + 8
        local y = toolbarButton:getAbsoluteY()
        local screenW = getCore():getScreenWidth()
        local screenH = getCore():getScreenHeight()
        if x + w > screenW then
            x = toolbarButton:getAbsoluteX() - w - 8
        end
        if x < 0 then
            x = 0
        end
        if y + h > screenH then
            y = screenH - h - 10
        end
        if y < 0 then
            y = 0
        end
        window = IST15KKillboardUI:new(x, y, w, h, function()
            toolbarButton:setImage(textureOff)
        end)
        window:initialise()
        window:addToUIManager()
        window:setRankData(T15KKillboard.RankData)
        window:setPendingRewards(T15KKillboard.PendingRewards)
        sendClientCommand("T15KKillboardModule", "requestPending", {})
        sendClientCommand("T15KKillboardModule", "requestRank", {})
    end
end

local function moveSideButton(button, offset)
    if button then
        button:setY(button:getY() + offset)
    end
end

local function expandSidePanelHeight(inst)
    if not inst then
        return
    end
    local bottom = 0
    if toolbarButton then
        bottom = math.max(bottom, toolbarButton:getY() + toolbarButton:getHeight())
    end
    if inst.clientBtn then
        bottom = math.max(bottom, inst.clientBtn:getBottom())
    end
    if inst.adminBtn then
        bottom = math.max(bottom, inst.adminBtn:getBottom())
    end
    if inst.debugBtn then
        bottom = math.max(bottom, inst.debugBtn:getBottom())
    end
    if bottom > 0 then
        inst:setHeight(math.max(inst:getHeight(), bottom + 5))
    end
end

local function calcMagnetY(inst)
    local skip = {
        [inst.clientBtn] = true,
        [inst.adminBtn] = true,
        [inst.debugBtn] = true,
    }
    if toolbarButton then
        skip[toolbarButton] = true
    end

    local y = -1
    for _, child in ipairs(inst:getChildren()) do
        if child and not skip[child] and child.getBottom then
            y = math.max(y, child:getBottom() + 5)
        end
    end

    if y < 0 then
        if inst.movableBtn then
            y = inst.movableBtn:getBottom() + 5
        end
        if inst.searchBtn then
            y = math.max(y, inst.searchBtn:getBottom() + 5)
        end
        if inst.mapBtn then
            y = math.max(y, inst.mapBtn:getBottom() + 5)
        end
    end

    if y < 0 then
        y = 50
    end
    return y
end

local function addToolbarButton()
    local inst = ISEquippedItem and ISEquippedItem.instance
    if not inst then
        return false
    end

    if toolbarButton then
        for _, child in ipairs(inst:getChildren()) do
            if child and child.name == "T15KRankButton" then
                toolbarButton:setY(calcMagnetY(inst))
                expandSidePanelHeight(inst)
                return true
            end
        end
        toolbarButton = nil
    end

    local y = calcMagnetY(inst)
    local btnSize = 50

    toolbarButton = ISButton:new(0, y, btnSize, btnSize, "", nil, showKillboard)
    toolbarButton:setImage(textureOff)
    toolbarButton:setDisplayBackground(false)
    toolbarButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    toolbarButton.name = "T15KRankButton"

    local shift = btnSize + 5
    moveSideButton(inst.debugBtn, shift)
    moveSideButton(inst.clientBtn, shift)
    moveSideButton(inst.adminBtn, shift)

    inst:addChild(toolbarButton)
    expandSidePanelHeight(inst)
    return true
end

local magnetAttempts = 0
local function onMagnetTick()
    magnetAttempts = magnetAttempts + 1
    if addToolbarButton() or magnetAttempts >= 60 then
        Events.OnTick.Remove(onMagnetTick)
    end
end

Events.OnCreatePlayer.Add(function()
    magnetAttempts = 0
    if not addToolbarButton() then
        Events.OnTick.Add(onMagnetTick)
    end
end)

local function OnPlayerDeath()
    if window and window:getIsVisible() then
        window:close()
        if toolbarButton then
            toolbarButton:setImage(textureOff)
        end
    end
    updatePlayerRank(true)
end
Events.OnPlayerDeath.Add(OnPlayerDeath)

---------- UPDATE KILLBOARD DATA ------------
local function playMonthEndSound()
    local player = getPlayer()
    if player then
        local ok = pcall(function()
            player:playSoundLocal("T15KKillboardMonthEnd")
        end)
        if not ok and getSoundManager then
            pcall(function()
                getSoundManager():playUISound("UIActivateButton")
            end)
        end
    elseif getSoundManager then
        pcall(function()
            getSoundManager():playUISound("UIActivateButton")
        end)
    end
end

local function clientRank(module, command, arguments)
    if module ~= "T15K_Rank_From_Server" then
        return
    end

    if command == "monthAnnounce" then
        playMonthEndSound()
        return
    end

    if command == "rewardsGranted" then
        local player = getPlayer()
        T15KKillboard.PendingRewards = {}
        if arguments and player then
            for i = 1, #arguments do
                local r = arguments[i]
                local name = T15KKillboard.formatRewardLine(r.item, r.count)
                local msg = getText("IGUI_T15KKillboard_Reward_Received", tostring(r.place), name)
                player:setHaloNote(msg, 255, 215, 0, 500)
                print("[T15KKillboard] " .. msg)
                if r.item and string.find(r.item, "PinkSlip.", 1, true) == 1 then
                    local tip = getText("IGUI_T15KKillboard_Reward_PinkSlip_Tip")
                    if tip and tip ~= "" and tip ~= "IGUI_T15KKillboard_Reward_PinkSlip_Tip" then
                        player:setHaloNote(tip, 200, 220, 255, 600)
                    end
                end
            end
            pcall(function()
                player:playSoundLocal("Notification")
            end)
        end
        if window then
            window:setPendingRewards({})
        end
        return
    end

    if command == "claimEmpty" then
        local player = getPlayer()
        if player then
            local tip = getText("IGUI_T15KKillboard_Claim_Empty")
            player:setHaloNote(tip, 220, 180, 80, 400)
        end
        return
    end

    if command == "claimLog" then
        IST15KKillboardUI.showClaimLog(arguments)
        return
    end

    if command == "pendingRewards" then
        T15KKillboard.PendingRewards = arguments or {}
        if window then
            window:setPendingRewards(T15KKillboard.PendingRewards)
        end
        return
    end

    -- legacy payload со старого сервера: all-time как есть, месяц пустой
    if arguments and arguments[1] and type(arguments[1]) == "table" and arguments[1][1] and not arguments.monthly then
        T15KKillboard.RankData = {
            monthKey = nil,
            serverNow = nil,
            monthEndTs = nil,
            monthly = {},
            allTime = arguments,
            rewards = T15KKillboard.getRewardConfig(),
            nextRewards = T15KKillboard.getNextRewardConfig(),
        }
    else
        T15KKillboard.RankData = arguments
        if T15KKillboard.RankData and not T15KKillboard.RankData.rewards then
            T15KKillboard.RankData.rewards = T15KKillboard.getRewardConfig()
        end
    end

    if T15KKillboard.RankData then
        T15KKillboard.RankData._clientRecvTs = getTimestamp()
    end

    T15KKillboard.ZombieRankClientTable = T15KKillboard.RankData and T15KKillboard.RankData.monthly or nil

    if window then
        window:setRankData(T15KKillboard.RankData)
    end
end

Events.OnServerCommand.Add(clientRank)
