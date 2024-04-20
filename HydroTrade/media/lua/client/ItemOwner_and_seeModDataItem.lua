if not isClient() then return end

local function setOwner(item)
    if isAdmin() then return; end
    local owner = item:getModData()["Owner"]
    local currentUser = getOnlineUsername()
    if owner == currentUser then return; end
    item:getModData()["Owner"] = currentUser
end

local function checkContainer(item)
    if isAdmin() then return; end
    -- print(item:getModData()["Owner"])
    if item:getModData()["Owner"] == getOnlineUsername() then return; end    
    local container = item:getContainer()
    if container and container:isInCharacterInventory(getPlayer()) then
        setOwner(item)
    end
end

-- local function tooltipInfo(item)    
--         local tooltip = item:getTooltip() or ""
--         local owner = item:getModData()["_O"]
--         local ownerInfo = getText("owner")..": "..owner
--         -- Проверяем, есть ли уже информация о владельце в tooltip
--         if not string.match(tooltip, ownerInfo) and owner then
--             tooltip = tooltip .. "\n" .. ownerInfo
--         end
--         return tooltip
-- end

local oldRender = ISToolTipInv.render
function ISToolTipInv:render()
    if (not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck) then
        local item = self.item
        checkContainer(item)
        -- if isAdmin() then
        --     self.item:setTooltip(tooltipInfo(item))
        -- end
    end
    oldRender(self)
end

local oldPerfom = ISInventoryTransferAction.perform
function ISInventoryTransferAction:perform()
    setOwner(self.item)
    oldPerfom(self)
end

local dropItem = ISInventoryPaneContextMenu.dropItem
ISInventoryPaneContextMenu.dropItem = function(item, player)
    setOwner(item)
    dropItem(item,player)
end


local function onShowData(item)
    if not isAdmin() then return; end
    -- for key, value in pairs(item[1]) do
    --     if key=="items" then
    --         for key, value in pairs(value) do
    --             -- print(value:getModData())
    --             print(key, value)
    --         end
    --     end
    -- end

    -- print(item) --0
    -- print(item:getWorldItem())
    -- print(item.items[1]:getModData())
    -- for key, value in pairs(item.items) do
    --     print(value:getModData())
    --     -- print(key, value)
    -- end
    -- print("Item:",item)
    -- if item and item:getModData() then
    --     ItemModDataPanel.OnOpenPanel(item)
    -- end
    if item and item.items and item.items[1] then
        local itemfind = item.items[1]
        if ItemModDataPanel.OnOpenPanel then
            ItemModDataPanel.OnOpenPanel(itemfind)
        else
            print("item No mod data")
        end
    elseif  item and item:hasModData() then
        ItemModDataPanel.OnOpenPanel(item)
    end
end

local function AddShowDataOption(player, context, items)
    if not isAdmin() then return; end
    -- for key, value in pairs(items[1]) do
    --     if key=="items" then
    --         for key, value in pairs(value) do
    --             print(value:getModData())
    --         end
    --     end
    -- end
    for i, item in ipairs(items) do
        if item and item.items and item.items[1] and item.items[1]:hasModData() then
            local owner = ""
            if item.items[1]:getModData() and item.items[1]:getModData()["Owner"] then
                owner = " ["..item.items[1]:getModData()["Owner"] .."]"
            end
            context:addOption(getText("IGUI_Show_Data_Item")..": "..item.items[1]:getDisplayName() .. owner, player, function() onShowData(item) end)
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(AddShowDataOption)