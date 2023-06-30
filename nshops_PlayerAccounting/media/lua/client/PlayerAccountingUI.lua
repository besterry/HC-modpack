require "ISUI/ISUIElement"
local main = require "PlayerAccountingClient"

local PlayerAccountingUI = ISUIElement:derive("PlayerAccountingUI")

local makeColor = ETOMARAT.Utils.makeColor
local EVENT_TYPES = ETOMARAT.PlayerAccounting.EVENT_TYPES
local BLACK = ' <RGB:0,0,0> '
local DGREEN = makeColor(0, 114, 54)
local DRED = makeColor(158, 11, 15)
local SPACE = ' <SPACE> '

local UI_CLOSE = 'x'
function PlayerAccountingUI:new()
    local o = {}
    local core = getCore()
    local textureBg = getTexture('media/ui/receipt _bg.png')
    local width = textureBg:getWidth()
    local height = textureBg:getHeight()
    local screenWidth = core:getScreenWidth()
    local screenHeight = core:getScreenHeight()
    local x = (screenWidth / 2) - (width /2)
    local y = (screenHeight / 2) - (height /2)
	o = ISUIElement:new(x, y, width, height)
	setmetatable(o, self)
    o.textureBg = textureBg
    -- o.closeButtonTexture = getTexture("media/ui/Dialog_Titlebar_CloseIcon.png");
    -- o.closeButtonTexture = getTexture("media/ui/emote/no.png");
    o.closeButtonTexture = getTexture("media/ui/LootableMaps/map_x.png");
    o.width = width
    o.height = height
    o.playerObj = getPlayer()
    return o
end

function PlayerAccountingUI:initialise()
	ISUIElement.initialise(self)
	ISUIElement.instantiate(self)
	self:setVisible(true)
	-- self.javaObject:setWantKeyEvents(false)
	-- self.javaObject:setConsumeMouseEvents(false)

    local offsetTop = 30
    local offsetBottom = 34
    local offsetSide = 14
    local margin = 16
    self.margin = margin
    -- local fontHeight = getTextManager():getFontHeight(UIFont.Small)
    -- local closeWidth = getTextManager():MeasureStringX(UIFont.Small, UI_CLOSE)
    local y = offsetTop + 8

    self.closeBtn = ISButton:new(self.width - margin - offsetSide - 20, y, 20, 20, UI_CLOSE, self, self.btnHandler);
    self.closeBtn.internal = UI_CLOSE;
    self.closeBtn:initialise();
	self.closeBtn:instantiate();
	self.closeBtn.borderColor.a = 0.0;
	self.closeBtn.backgroundColor.a = 0;
	self.closeBtn.backgroundColorMouseOver.a = 0;
    self.closeBtn:setTextureRGBA(0, 0, 0, 0.8)
	self.closeBtn:setImage(self.closeButtonTexture);
    self:addChild(self.closeBtn);

    y = y + 20

    self.heading = ISRichTextPanel:new(offsetSide + margin, y, self.width - (offsetSide * 2) - (margin * 2), 0)
    self:setHeading()

    y = y + self.heading.height

    self.footer = ISRichTextPanel:new(offsetSide + margin, y, self.width - (offsetSide * 2) - (margin * 2), 0)
    local footerY = self:setFooter(offsetBottom)

    -- print('self.height - footerY', self.height - footerY, self.height, footerY, self.height - y - offsetBottom - margin)

    local logDimension = {
        x = offsetSide + margin,
        y = y + margin,
        width = self.width - (offsetSide * 2) - (margin * 2),
        -- height = self.height - y - offsetBottom - margin
        height = footerY - y - (margin*2)
    }
    self.logText = ISRichTextPanel:new(logDimension.x, logDimension.y, logDimension.width, logDimension.height)
    self:setLog()

    self.closeBtn:bringToTop()
    
	self:addToUIManager()

end

function PlayerAccountingUI:setHeading()
    local text = ' <H1> '..BLACK..'Nox Bank <LINE> <TEXT> <CENTRE> '..'Accounting: '..SPACE..BLACK..self.playerObj:getUsername()
    self.heading:initialise()
    self.heading.background = false;
    self.heading:setMargins(0, 0, 0, 0)
    self.heading:setText(text)
    self.heading:paginate();
    
    self:addChild(self.heading);
end

---@param offsetBottom integer
---@return integer
function PlayerAccountingUI:setFooter(offsetBottom)
    local balance = main.getTotal()
    local text = (
        ' <H2> <CENTRE> =================== TOTAL ================= <BR> <LEFT>'..BLACK..'Coins: ' ..
        balance.coin .. '$' .. ' <LINE> Specials: ' .. balance.specialCoin .. '$$ <BR> '
    )
    self.footer:initialise()
    self.footer.background = false;
    self.footer:setMargins(0, 0, 0, 0)
    self.footer:setText(text)
    self.footer:paginate();

    self:addChild(self.footer);

    local y = self.height - self.footer.height - offsetBottom - self.margin
    self.footer:setY(y)
    print(self.footer.height)
    return y
end

function PlayerAccountingUI.processLog()
    local logData = copyTable(main.getLog())
    local reverseData = {}
    for i=#logData, 1, -1 do
        reverseData[#reverseData+1] = logData[i]
    end
    local text = ''
    for _, v in ipairs(reverseData) do
        local dt, event_type, coin, specialCoin, recipient = unpack(v)
        coin = Currency.format(tostring(coin))
        specialCoin = Currency.format(tostring(specialCoin))
        local indentX = getTextManager():MeasureStringX(UIFont.Small, dt .. ' : ') + 2 -- Прибито к дате
        -- local indentX = 300 -- Справа
        local line = ' <TEXT> ' .. dt .. BLACK..SPACE..': '
        if event_type == EVENT_TYPES.Linked then
            line = line .. ' Linked wallet '
        end
        if event_type == EVENT_TYPES.TransferIn then
            local coinStr = DGREEN .. ' +'
            if coin then
                coinStr = coinStr .. coin .. '$'
            end
            if coin and specialCoin then
                coinStr = coinStr .. SPACE
            end
            if specialCoin then
                coinStr = coinStr .. specialCoin .. '$$'
            end
            line = line .. 'Incoming transfer from: ' .. recipient .. ' <LINE> <TEXT> <SETX:'..indentX..'> '.. BLACK .. coinStr
        end
        if event_type == EVENT_TYPES.TransferOut then
            local coinStr = DRED .. ' -'
            if coin then
                coinStr = coinStr .. coin .. '$'
            end
            if coin and specialCoin then
                coinStr = coinStr .. SPACE
            end
            if specialCoin then
                coinStr = coinStr .. specialCoin .. '$$'
            end
            line = line .. 'Outgoing transfer to: ' .. recipient .. ' <LINE> <TEXT> <SETX:'..indentX..'> '.. BLACK .. coinStr
        end
        if event_type == EVENT_TYPES.Deposit then
            local coinStr = DGREEN .. ' +'
            if coin then
                coinStr = coinStr .. coin .. '$'
            end
            if coin and specialCoin then
                coinStr = coinStr .. SPACE
            end
            if specialCoin then
                coinStr = coinStr .. specialCoin .. '$$'
            end
            line = line .. 'Deposit: ' .. ' <LINE> <TEXT> <SETX:'..indentX..'> '.. BLACK .. coinStr
        end
        if event_type == EVENT_TYPES.Withdraw then
            local coinStr = DRED .. ' -'
            if coin then
                coinStr = coinStr .. coin .. '$'
            end
            if coin and specialCoin then
                coinStr = coinStr .. SPACE
            end
            if specialCoin then
                coinStr = coinStr .. specialCoin .. '$$'
            end
            line = line .. 'Withdraw: ' .. ' <LINE> <TEXT> <SETX:'..indentX..'> '.. BLACK .. coinStr
        end
        text = text .. line .. '<BR>'
        print(dt, event_type, coin, specialCoin, recipient)
    end
    return text
end
function PlayerAccountingUI:setLog()
    self.logText:initialise()
    self.logText.background = false;
    self.logText:setMargins(0, 0, 0, 0)
    self.logText.anchorLeft = true;
	self.logText.anchorRight = true;
	self.logText.anchorTop = true;
	self.logText.anchorBottom = true;
    self.logText.autosetheight = false;
    self.logText.render = PlayerAccountingUI.logRender
    self.logText:addScrollBars();
    self.logText:paginate();
    local text = PlayerAccountingUI.processLog()
    self.logText:setText(text)

    self:addChild(self.logText);
end

function PlayerAccountingUI:onMouseWheel(del)
    ISRichTextPanel.onMouseWheel(self.logText, del)
    return true
end

function PlayerAccountingUI:logRender()
    self:setStencilRect(0, 0, self.width, self.height)
    ISRichTextPanel.render(self)
    self:clearStencilRect()
end

function PlayerAccountingUI:btnHandler(button)
    if button.internal == UI_CLOSE then
        self:destroy()
    end
end

function PlayerAccountingUI:destroy()
    self:setVisible(false);
    self:removeFromUIManager();
end

function PlayerAccountingUI:prerender()
    local texture = self.textureBg
    self:drawTexture(texture, 0, 0, 1)
end

---@param playerIndex int
---@param context ISContextMenu
---@param items table
local onPreFillInventoryObjectContextMenu = function (playerIndex, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items or #items > 1 then return end
    local item = items[1]
    if not item then return end
    local itemType = item:getFullType()
    if not Currency.Wallets[itemType] then return end
    if not item:isInPlayerInventory() then return end
    local player = getSpecificPlayer(playerIndex)
    local username = player:getUsername()
    if not (item:getModData().belongsTo == username) then return end

    local ui = PlayerAccountingUI:new()
    
    context:addOption('Show Accounting', ui, ui.initialise);
end

Events.OnPreFillInventoryObjectContextMenu.Add(onPreFillInventoryObjectContextMenu);

DShowPlayerAccountingUI = function ()
    local ui = PlayerAccountingUI:new()
    ui:initialise()
end