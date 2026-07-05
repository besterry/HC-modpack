local MOD_NAME = 'ZipContainer'
local ZIP_CONTAINER_TYPE = MOD_NAME
local TILE_NAME_START = ZIP_CONTAINER_TYPE
local utils = require 'ZipContainer_utils'
local zlog = utils.zlog
local zipCoordsFromObj = utils.zipCoordsFromObj

---@type whiteListType
local whiteListArr = nil

---@class ItemTable
---@field id integer
---@field condition number
---@field age number
---@field delta number
---@field hunger number
---@field weight number
---@field actualWeight number
---@field isBroken boolean
---@field isCooked boolean
---@field cookedString string
---@field isBurnt boolean
---@field burntString string
---@field haveBeenRepaired integer
---@field capacity integer | nil
---@field maxCapacity integer | nil
---@field isCustomWeight boolean | nil
---@field isAlarmSet boolean | nil
---@field hour integer | nil
---@field minute integer | nil
---@field keyId integer | nil
---@field displayName string | nil
---@field mediaData MediaData | nil
---@field modData ModData | nil
---@field customPages HashMap | nil

---@alias zipTable table<string, ItemTable[]>

---@class ZipContainer
local ZipContainer = {}

---@param container ItemContainer
---@return ZipContainer | nil
function ZipContainer:new(container)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if not ZipContainer.isValid(container) then
        return
    end
    ---@type ItemContainer
    o.itemContainer = container
    ---@type function
    o.base_isItemAllowed = container.isItemAllowed
    ---@type IsoObject
    o.isoObject = container:getParent()
    if not o.isoObject:getModData()[MOD_NAME] then
        o.isoObject:getModData()[MOD_NAME] = {}
    end
    ---@type zipTable
    o.modData = o.isoObject:getModData()[MOD_NAME]
    return o
end

---@param container ItemContainer
function ZipContainer.isValid(container)
    if not container then
        return false
    end
    return luautils.stringStarts(container:getType(), ZIP_CONTAINER_TYPE)
    --return container:getType() == ZIP_CONTAINER_TYPE
end

---@param containersArr ArrayList | nil
---@return boolean
function ZipContainer.isValidInArray(containersArr)
    if not containersArr then
        return false
    end
    local hasZip = false
    for i = 0, containersArr:size() - 1 do
        local zipContainer = ZipContainer.isValid(containersArr:get(i))
        if zipContainer then
            hasZip = true
        end
    end
    return hasZip
end

---@param item InventoryItem
-- -@param whiteList? string[]
function ZipContainer.isWhiteListed(item)
    if not whiteListArr then
        whiteListArr = {}
        sendClientCommand(getPlayer(), MOD_NAME, 'getWhiteList', {})
    end
    local debug_list = {}
    -- if AUD then
    --     debug_list['Base.EngineDoor1'] = true
    --     debug_list['Hydrocraft.HCBookcover'] = true
    --     debug_list['Base.DodgeRTtire3'] = true
    --     debug_list['Base.CUDAtire3'] = true
    --     debug_list['Base.NormalTire1'] = true

    --     print('item:getFullType()', item:getFullType())
    -- end
    local itemType = item:getFullType()
    return debug_list[itemType] or whiteListArr[itemType] or false
    
end

---@param items InventoryItem[]
function ZipContainer:removeForbiddenTypeFromItemList(items)
    for i = #items, 1, -1
	do
		if not ZipContainer.isWhiteListed(items[i])
		then
			table.remove(items, i);
		end
	end

	return items;
end

---@return integer
local function generateUniqueItemId(usedIds)
    local id
    repeat
        id = ZombRand(100000000, 2147483646)
    until not usedIds[id]
    usedIds[id] = true
    return id
end

---@return integer fixed count
function ZipContainer:repairDuplicateIds()
    local seen = {}
    local fixed = 0
    local coords = zipCoordsFromObj(self.isoObject)

    for itemType, typeTables in pairs(self.modData) do
        for idx, typeTable in pairs(typeTables) do
            if typeTable and typeTable.id then
                local id = typeTable.id
                if seen[id] then
                    local newId = generateUniqueItemId(seen)
                    zlog('repairIds', string.format('coords=%s type=%s oldId=%d newId=%d', coords, itemType, id, newId))
                    typeTable.id = newId
                    fixed = fixed + 1
                else
                    seen[id] = true
                end
            end
        end
    end

    if fixed > 0 then
        zlog('repairIds', string.format('coords=%s fixed=%d', coords, fixed))
        self:setModData()
    end
    return fixed
end

---@param id integer
---@return boolean
function ZipContainer:modDataHasId(id)
    for _, typeTables in pairs(self.modData) do
        for _, typeTable in pairs(typeTables) do
            if typeTable and typeTable.id == id then
                return true
            end
        end
    end
    return false
end

function ZipContainer:setModData()
    local coords = zipCoordsFromObj(self.isoObject)
    local count = self:countItems()
    zlog('setModData', string.format('coords=%s modDataCount=%d', coords, count))
    self.isoObject:getModData()[MOD_NAME] = self.modData
    self.isoObject:transmitModData()
end
---@return InventoryItem[]
function ZipContainer:getItems()
    local resultList = {}
    local coords = zipCoordsFromObj(self.isoObject)
    for type, typeTables in pairs(self.modData) do
        for idx, typeTable in pairs(typeTables) do
            local item = InventoryItemFactory.CreateItem(type);
            if item then
                item:setID(typeTable.id)
                item:setCondition(typeTable.condition)
                item:setAge(typeTable.age)
                item:setBroken(typeTable.isBroken)
                item:setCustomWeight(typeTable.isCustomWeight or false)
                if typeTable.weight then
                    item:setWeight(typeTable.weight)
                end
                if typeTable.actualWeight then
                    item:setActualWeight(typeTable.actualWeight)
                end
                if typeTable.capacity then
                    item:setItemCapacity(typeTable.capacity)
                end
                if typeTable.maxCapacity then
                    item:setMaxCapacity(typeTable.maxCapacity)
                end
                if typeTable.haveBeenRepaired then
                    item:setHaveBeenRepaired(typeTable.haveBeenRepaired)
                end
                if typeTable.isCooked then
                    item:setCooked(typeTable.isCooked)
                    item:setCookedString(typeTable.cookedString)
                end
                if typeTable.isBurnt then
                    item:setBurnt(typeTable.isBurnt)
                    item:setBurntString(typeTable.burntString)
                end
                if typeTable.delta then
                    item = item  --[[@as DrainableComboItem]]
                    item:setDelta(typeTable.delta)
                end
                if typeTable.hunger then
                    item = item  --[[@as Food]]
                    item:setHungChange(typeTable.hunger)
                end
                if typeTable.isAlarmSet ~= nil then
                    item = item  --[[@as AlarmClock]]
                    item:setAlarmSet(typeTable.isAlarmSet)
                    item:setHour(typeTable.hour)
                    item:setMinute(typeTable.minute)
                end
                if typeTable.keyId then
                    item:setKeyId(typeTable.keyId)
                end
                if typeTable.displayName then
                    item:setName(typeTable.displayName)
                end
                if typeTable.mediaData ~= nil then
                    item:setRecordedMediaData(typeTable.mediaData)
                end
                if typeTable.modData ~= nil then
                    item:copyModData(typeTable.modData)
                end
                if typeTable.customPages then
                    item = item  --[[@as Literature]]
                    item:setCustomPages(typeTable.customPages)
                end

                table.insert(resultList, item)
            else
                zlog('getItems', string.format('coords=%s CreateItem FAILED type=%s idx=%s id=%s', coords, type, tostring(idx), typeTable and tostring(typeTable.id) or '?'))
                typeTables[idx] = nil
            end
        end
    end
    return resultList
end
---@return ItemContainer
function ZipContainer:makeItems()
    local coords = zipCoordsFromObj(self.isoObject)
    self:repairDuplicateIds()
    local beforeCount = self:countItems()
    zlog('makeItems', string.format('coords=%s modDataCount=%d containerBefore=%d', coords, beforeCount, self.itemContainer:getItems():size()))
    self.itemContainer:removeAllItems()
    local items = self:getItems()
    local usedIds = {}
    for _, item in pairs(items) do
        local id = item:getID()
        if usedIds[id] then
            local newId = generateUniqueItemId(usedIds)
            zlog('makeItems', string.format('coords=%s duplicate runtime id=%d -> %d type=%s', coords, id, newId, item:getFullType()))
            item:setID(newId)
            id = newId
        else
            usedIds[id] = true
        end
        self.itemContainer:addItem(item)
    end
    zlog('makeItems', string.format('coords=%s containerAfter=%d', coords, self.itemContainer:getItems():size()))
    -- local DoRemoveItem_base = self.itemContainer.DoRemoveItem
    -- print('DoRemoveItem_base', DoRemoveItem_base)
    -- function self.itemContainer:DoRemoveItem (item)
    --     print('DoRemoveItem')
    --     local o = DoRemoveItem_base(self, item)
    --     return o
    -- end
    -- self.itemContainer.DoRemoveItem = function (_self, item)
    --     -- local o = DoRemoveItem_base(_self, item)
    --     print('DoRemoveItem', _self, item)
    --     -- self.itemContainer.DoRemoveItem = DoRemoveItem_base
    --     -- return o
    -- end
    -- local Remove_base = self.itemContainer.Remove
    -- self.itemContainer.Remove = function (_self, item)
    --     local o = Remove_base(_self, item)
    --     print('Remove')
    --     self.itemContainer.Remove = Remove_base
    --     return o
    -- end
    -- local RemoveAll_base = self.itemContainer.RemoveAll
    -- self.itemContainer.RemoveAll = function (_self, item)
    --     local o = RemoveAll_base(_self, item)
    --     print('RemoveAll')
    --     self.itemContainer.RemoveAll = RemoveAll_base
    --     return o
    -- end
    -- local removeAllItems_base = self.itemContainer.removeAllItems
    -- self.itemContainer.removeAllItems = function (_self, item)
    --     local o = removeAllItems_base(_self, item)
    --     print('removeAllItems_base')
    --     self.itemContainer.removeAllItems = removeAllItems_base
    --     return o
    -- end
    -- local removeItemOnServer_base = self.itemContainer.removeItemOnServer
    -- self.itemContainer.removeItemOnServer = function (_self, item)
    --     local o = removeItemOnServer_base(_self, item)
    --     print('removeItemOnServer')
    --     self.itemContainer.removeItemOnServer = removeItemOnServer_base
    --     return o
    -- end
    -- local removeItemsFromProcessItems_base = self.itemContainer.removeItemsFromProcessItems
    -- self.itemContainer.removeItemsFromProcessItems = function (_self, item)
    --     local o = removeItemsFromProcessItems_base(_self, item)
    --     print('removeItemsFromProcessItems')
    --     self.itemContainer.removeItemsFromProcessItems = removeItemsFromProcessItems_base
    --     return o
    -- end
    -- local removeItemWithID_base = self.itemContainer.removeItemWithID
    -- self.itemContainer.removeItemWithID = function (_self, item)
    --     local o = removeItemWithID_base(_self, item)
    --     print('removeItemWithID')
    --     self.itemContainer.removeItemWithID = removeItemWithID_base
    --     return o
    -- end
    -- local removeItemWithIDRecurse_base = self.itemContainer.removeItemWithIDRecurse
    -- self.itemContainer.removeItemWithIDRecurse = function (_self, item)
    --     local o = removeItemWithIDRecurse_base(_self, item)
    --     print('removeItemWithIDRecurse')
    --     self.itemContainer.removeItemWithIDRecurse = removeItemWithIDRecurse_base
    --     return o
    -- end
    -- local RemoveOneOf_base = self.itemContainer.RemoveOneOf
    -- self.itemContainer.RemoveOneOf = function (_self, item)
    --     local o = RemoveOneOf_base(_self, item)
    --     print('RemoveOneOf')
    --     self.itemContainer.RemoveOneOf = RemoveOneOf_base
    --     return o
    -- end

    -- for type, typeTables in pairs(self.modData) do
    --     for idx, typeTable in pairs(typeTables) do
    --         local item = InventoryItemFactory.CreateItem(type);
    --         if item then
    --             item:setID(typeTable.id)
    --             item:setCondition(typeTable.condition)
    --             item:setAge(typeTable.age)
    --             item:setBroken(typeTable.isBroken)

    --             if typeTable.isCooked then
    --                 item:setCooked(typeTable.isCooked)
    --                 item:setCookedString(typeTable.cookedString)
    --             end
    --             if typeTable.isBurnt then
    --                 item:setBurnt(typeTable.isBurnt)
    --                 item:setBurntString(typeTable.burntString)
    --             end
    --             if typeTable.delta then
    --                 item = item  --[[@as DrainableComboItem]]
    --                 item:setDelta(typeTable.delta)
    --             end
    --             if typeTable.hunger then
    --                 item = item  --[[@as Food]]
    --                 item:setHungChange(typeTable.hunger)
    --             end
    --             self.itemContainer:addItem(item)
    --         else
    --             typeTables[idx] = nil
    --         end
    --     end
    -- end
    return self.itemContainer
end

-- local function clone(item)
--     local newItem = InventoryItemFactory.CreateItem(item:getFullType())
--     if not newItem then return end
--     -- newItem:setAge(item:getAge())
--     -- newItem:setCondition(item:getCondition(), false)
--     newItem:getVisual():copyFrom(item:getVisual()) -- !
--     -- newItem:setBroken(item:isBroken())
--     newItem:setColor(item:getColor())
--     -- if item:isCooked() then
--     --     newItem:setCooked(item:isCooked())
--     --     newItem:setCookedString(item:getCookedString())
--     -- end
--     -- if item:isBurnt() then
--     --     newItem:setBurnt(item:isBurnt())
--     --     newItem:setBurntString(item:getBurntString())
--     -- end
--     newItem:setDisplayName(item:getDisplayName())

--     if item:hasModData() then
--         newItem:copyModData(item:getModData())
--     end
--     if instanceof(item, "Clothing") then
--         item:copyPatchesTo(newItem)
--         newItem:setBloodLevel(item:getBloodLevel())
--         newItem:setDirtyness(item:getDirtyness())
--         newItem:setPalette(item:getPalette())
--         newItem:setWetness(item:getWetness())
--     end
--     if instanceof(item, "DrainableComboItem") then
--         newItem:setUsedDelta(item:getUsedDelta())
--         newItem:updateWeight()
--     end
--     if instanceof(item, "Food") then
--         newItem:setCalories(item:getCalories())
--         newItem:setCarbohydrates(item:getCarbohydrates())
--         newItem:setProteins(item:getProteins())
--         newItem:setLipids(item:getLipids())
--         newItem:setWeight(item:getWeight())
--         newItem:setHungChange(item:getHungChange())
--         newItem:setUnhappyChange(item:getUnhappyChange())
--         newItem:setBoredomChange(item:getBoredomChange())
--         newItem:setStressChange(item:getStressChange())
--         newItem:setEnduranceChange(item:getEnduranceChange())
--         newItem:setPainReduction(item:getPainReduction())
--         newItem:setThirstChange(item:getThirstChange())
--         newItem:setCookedInMicrowave(item:isCookedInMicrowave())
--         newItem:setSpices(item:getSpices())
--     end
-- end

---@param items InventoryItem[]
function ZipContainer:addItems(items)
    local coords = zipCoordsFromObj(self.isoObject)
    for _, item in pairs(items) do
        if self.itemContainer:contains(item) then
            local type = item:getFullType()
            local itemId = item:getID()
            if self:modDataHasId(itemId) then
                local usedIds = {}
                for _, typeTables in pairs(self.modData) do
                    for _, typeTable in pairs(typeTables) do
                        if typeTable and typeTable.id then
                            usedIds[typeTable.id] = true
                        end
                    end
                end
                local newId = generateUniqueItemId(usedIds)
                zlog('addItems', string.format('coords=%s duplicate id=%d -> %d type=%s', coords, itemId, newId, type))
                item:setID(newId)
                itemId = newId
            end
            local typeTable = self.modData[type] or {} --[[@as zipTable]]
            local resultTable = {
                id = itemId,
                condition = item:getCondition(),
                weight = item:getUnequippedWeight(),
                actualWeight = item:getActualWeight(),
                isCustomWeight = item:isCustomWeight(),
                age = item:getAge(),
                isBroken = item:isBroken(),
                haveBeenRepaired = item:getHaveBeenRepaired(),
            }

            local capacity = item:getItemCapacity()
            local maxCapacity = item:getMaxCapacity()

            resultTable['modData'] = item:getModData()
            resultTable['mediaData'] = item:getMediaData()
            
            if item:getFullType() == "Base.Notebook" then
                item = item --[[@as Literature]]
                resultTable['displayName'] = item:getDisplayName()
                resultTable['customPages'] = item:getCustomPages()
            end

            if item:getFullType() == "Base.SkillRecoveryJournal" then
                resultTable['displayName'] = item:getDisplayName()
            end
            if instanceof(item, 'Key') then
                resultTable['keyId'] = item:getKeyId()
                resultTable['displayName'] = item:getDisplayName()
            end
            if instanceof(item, 'AlarmClock') or instanceof(item, "AlarmClockClothing") then
                item = item --[[@as AlarmClock]]
                resultTable['isAlarmSet'] = item:isAlarmSet()
                resultTable['hour'] = item:getHour()
                resultTable['minute']= item:getMinute()
            end
            if capacity ~= -1 then
                resultTable['capacity'] = capacity
            end
            if maxCapacity ~= -1 then
                resultTable['maxCapacity'] = maxCapacity
            end
            if item:isCooked() then
                resultTable['isCooked'] = item:isCooked()
                resultTable['cookedString'] = item:getCookedString()
            end
            if item:isBurnt() then
                resultTable['isBurnt'] = item:isBurnt()
                resultTable['burntString'] = item:getBurntString()
            end
            if item:IsDrainable() then
                local drainableItem = item --[[@as DrainableComboItem]]
                resultTable['delta'] = drainableItem:getDelta()
            end
            if item:IsFood() then
                local foodItem = item --[[@as Food]]
                resultTable['hunger'] = foodItem:getHungChange()
            end
            table.insert(typeTable, resultTable)
            self.modData[type] = typeTable
            zlog('addItems', string.format('coords=%s type=%s id=%d modDataCount=%d', coords, type, item:getID(), self:countItems()))
        else
            zlog('addItems', string.format('coords=%s SKIPPED type=%s id=%d (not in container)', coords, item:getFullType(), item:getID()))
        end
    end
end

---@param items InventoryItem[]
function ZipContainer:removeItems(items)
    local coords = zipCoordsFromObj(self.isoObject)
    for _, item in pairs(items) do
        local inContainer = self.itemContainer:contains(item)
        if not inContainer then
            local type = item:getFullType()
            local id = item:getID()
            local typeTables = self.modData[type] or {}
            local removed = false
            for idx, typeTable in pairs(typeTables) do
                if typeTable and typeTable.id == id then
                    table.remove(typeTables, idx)
                    removed = true
                    break
                end
            end
            self.modData[type] = typeTables
            zlog('removeItems', string.format('coords=%s type=%s id=%d removed=%s modDataCount=%d', coords, type, id, tostring(removed), self:countItems()))
        else
            zlog('removeItems', string.format('coords=%s SKIPPED type=%s id=%d (still in container)', coords, item:getFullType(), item:getID()))
        end
    end
end

---@param items InventoryItem[]
---@param sourceContainer ItemContainer
function ZipContainer:putItems(items, sourceContainer)
    self:addItems(items)
    for _, item in pairs(items) do
        sourceContainer:DoRemoveItem(item)
    end
end

---@param items InventoryItem[]
---@param targetContainer ItemContainer
function ZipContainer:pickUpItems(items, targetContainer)
    self:removeItems(items)
    for _, item in pairs(items) do
        targetContainer:addItem(item)
    end
end

---@param itemType string | nil
---@return integer
function ZipContainer:countItems(itemType)
    local count = 0
    for _itemType, typeTables in pairs(self.modData) do
        for _, typeTable in pairs(typeTables) do
            if typeTable then
                if itemType then
                    if itemType == _itemType then
                        count = count + 1
                    end
                else
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function sortAndHash(list)
    local seen = {}
    local unique = {}
    for _, id in ipairs(list) do
        if id and not seen[id] then
            seen[id] = true
            table.insert(unique, id)
        end
    end
    table.sort(unique)
    return table.concat(unique, ',')
end

---@return boolean
function ZipContainer:needsRefresh()
    local modCount = self:countItems()
    local uiCount = self.itemContainer:getItems():size()
    if modCount ~= uiCount then
        return true
    end
    return self:getHashOfModdata() ~= self:getHashOfContains()
end

---@return string
function ZipContainer:getHashOfModdata()    local resultList = {}
    for _, typeTables in pairs(self.modData) do
        for _, typeTable in pairs(typeTables) do
            if typeTable then
                table.insert(resultList, typeTable.id)
            end
        end
    end
    return sortAndHash(resultList)
end

function ZipContainer:getHashOfContains()
    local resultList = {}
    local itemsArr = self.itemContainer:getItems();
    for i = 0, itemsArr:size()-1 do
        local item = itemsArr:get(i);
        table.insert(resultList, item:getID())
    end
    return sortAndHash(resultList)
end

---@param items InventoryItem[]
---@return string
local getItemsCountStr = function (items)
    local resultTable = {}
    for _, item in pairs(items) do
        local type = item:getFullType()
        if resultTable[type] then
            resultTable[type] = resultTable[type] + 1
        else
            resultTable[type] = 1
        end
    end
    local result = ''
    for type, count in pairs(resultTable) do
        result = result .. ('%s=%s; '):format(type, count)
    end
    return result
end

---@param items InventoryItem[]
---@param tag string
function ZipContainer:makeLog(items, tag)
    if not LogExtenderClient or not LogExtenderClient.writeLog then return; end
    local fileName = 'ZipContainer'
    -- local dateTimeStr = os.date('%d.%m.%Y %H:%M:%S')
    local position = math.floor(getPlayer():getX()) .. "," .. math.floor(getPlayer():getY()) .. "," .. math.floor(getPlayer():getZ())
    local username = getPlayer():getUsername()
    local itemsStr = getItemsCountStr(items)
    local msg = ('[%s]:[%s]:[%s]: %s'):format(username,position, tag, itemsStr)
    LogExtenderClient.writeLog(fileName, msg)
end

local receiveServerCommand = function(module, command, args)
    if module ~= MOD_NAME then return; end
    if command == 'onGetWhiteList' then
        whiteListArr = args['whiteListArr']
    end
end
Events.OnServerCommand.Add(receiveServerCommand)


return {
    MOD_NAME = MOD_NAME,
    ZipContainer = ZipContainer,
    TILE_NAME_START = TILE_NAME_START
}