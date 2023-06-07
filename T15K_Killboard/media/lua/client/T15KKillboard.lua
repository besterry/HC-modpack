--***********************************************************
--**                ALEKSANDR OPEKUNOV | ZUU               **
--***********************************************************

if isServer() then
    return
end
local ipairs = ipairs

if not getT15KKillboardInstance then
    require('shared/T15KillboardUtils')
end

local T15KKillboard = getT15KKillboardInstance()

---------- SAVE PLAYER DATA ----------

-- send updated player rank
local function updatePlayerRank(onDead)
    local _player = getPlayer()
    if _player:getZombieKills() < T15KKillboard.getSandboxVar("MinKills") and not onDead then
        return
    end

    local zmbKll = 0
    local srvKll = 0

    if not onDead then
        zmbKll = _player:getZombieKills()
        srvKll = _player:getSurvivorKills()
    end

    local _args = { _player:getUsername(), zmbKll, srvKll }
    sendClientCommand("T15KKillboardModule", "playerUpdate", _args)

    -- Create TEST PLAYERS. Comment before production
    -- local _testArgs = { ZombRand(1, 1000) .. _player:getUsername() .. ZombRand(1, 1000), ZombRand(1, 30000), _player:getSurvivorKills() }
    -- sendClientCommand("T15KKillboardModule", "playerUpdate", _testArgs)
    -- Create TEST PLAYERS
end

-- save player data on game start
Events.OnGameStart.Add(updatePlayerRank)

-- save player data by tick
local serverUpdateTickRate = T15KKillboard.getSandboxVar("ServerTickRate")
if serverUpdateTickRate == 1 or T15KKillboard.isSinglePlayer() then
    Events.EveryTenMinutes.Add(updatePlayerRank) -- Отправка данных игрокам
elseif serverUpdateTickRate == 2 then
    Events.EveryHours.Add(updatePlayerRank) -- Отправка данных игрокам
else
    Events.EveryDays.Add(updatePlayerRank) -- Отправка данных игрокам
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
        window = IST15KKillboardUI:new(getCore():getScreenWidth() - 250, getCore():getScreenHeight() - 650, 250, 350, function()
            toolbarButton:setImage(textureOff)
        end)
        window:initialise()
        window:addToUIManager()
        window:updateList(T15KKillboard.ZombieRankClientTable)
    end
end

local function addToolbarButton()

    if toolbarButton then
        for _, child in ipairs(ISEquippedItem.instance:getChildren()) do
            if child and child.name == "T15KRankButton" then
                return
            end
        end
    end

    toolbarButton = ISButton:new(0, ISEquippedItem.instance.movableBtn:getY() + ISEquippedItem.instance.movableBtn:getHeight() + 300, 50, 50, "", nil, showKillboard)
    toolbarButton:setImage(textureOff)
    toolbarButton:setDisplayBackground(false)
    toolbarButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    toolbarButton.name = "T15KRankButton"

    ISEquippedItem.instance:addChild(toolbarButton)
    ISEquippedItem.instance:setHeight(math.max(ISEquippedItem.instance:getHeight(), toolbarButton:getY() + 400))

end

Events.OnCreatePlayer.Add(addToolbarButton)

local function OnPlayerDeath()
    if window and window:getIsVisible() then
        window:close()
        toolbarButton:setImage(textureOff)
    end
    updatePlayerRank(true)
end
Events.OnPlayerDeath.Add(OnPlayerDeath)


---------- UPDATE KILLBOARD DATA ------------
local function clientRank(module, command, arguments)
    if module ~= "T15K_Rank_From_Server" then
        return
    end
    T15KKillboard.ZombieRankClientTable = arguments
    if window then
        window:updateList(T15KKillboard.ZombieRankClientTable)
    end
end

Events.OnServerCommand.Add(clientRank)
