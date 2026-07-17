require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanelJoypad"
require "ISUI/ISLabel"
json = require "libs/json"
local config = require "config";
local clothingCategories = require "clothingCategories";
local utils = require "utils/utils";
local BodyPartMap = require "bodyPartMap";

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local TITLE_BAR = 20
local PAD = 10
local SECTION_GAP = 8
local HEADER_H = FONT_HGT_SMALL + 6

local instance = nil;

myClothingUI = ISCollapsableWindow:derive("myClothingUI");

function myClothingUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.82 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.categoryButtons = {};
    o.sectionOrder = {};
    return o
end

local function isBandageLocation(itemBodyLocation)
    return itemBodyLocation == "Bandage" or itemBodyLocation == "ZedDmg" or itemBodyLocation == "Wound";
end

function myClothingUI.collectEquippedClothing(playerObj)
    local playerInv = playerObj:getInventory();
    local playerItems = playerInv:getItems();
    local currentlyEquipped = {};
    currentlyEquipped.items = {};
    currentlyEquipped.count = 0;
    currentlyEquipped.damagedCount = 0;

    local threshold = config.damaged_condition_threshold or 0.5;

    for i = 0, playerItems:size() - 1 do
        local loopitem = playerItems:get(i);
        local itemBodyLocation = loopitem:getBodyLocation();
        local shouldBeDisplayed = ((loopitem:IsClothing()) or (itemBodyLocation and (itemBodyLocation ~= "")))
                                      and not isBandageLocation(itemBodyLocation);

        if loopitem:isEquipped() and shouldBeDisplayed then
            currentlyEquipped.items[itemBodyLocation] = loopitem;
            currentlyEquipped.count = currentlyEquipped.count + 1;
            if utils.isItemDamaged(loopitem, threshold) then
                currentlyEquipped.damagedCount = currentlyEquipped.damagedCount + 1;
            end
        end
    end

    return currentlyEquipped;
end

local function getSortedCategories()
    local list = {};
    for k, v in pairs(clothingCategories) do
        table.insert(list, { key = k, data = v, row = v.displayRow or 99 });
    end
    table.sort(list, function(a, b)
        return a.row < b.row
    end)
    return list;
end

function myClothingUI:update()
    if instance == nil then
        return
    end

    local playerObj = getPlayer();
    if not playerObj then
        return
    end

    local currentlyEquipped = myClothingUI.collectEquippedClothing(playerObj);
    instance.lastDamagedCount = currentlyEquipped.damagedCount;
    instance.lastEquippedItems = currentlyEquipped.items;

    if not instance:getIsVisible() then
        return
    end

    if currentlyEquipped.count == 0 then
        myClothingUI:removeItemButtons();
        myClothingUI:clearSectionHeaders();
        instance.itemCount = 0;
        instance.displayedSlots = {};
        return;
    end

    if instance.itemCount then
        if instance.itemCount ~= currentlyEquipped.count then
            myClothingUI:drawButtonsFromItems(currentlyEquipped.items, currentlyEquipped.count);
            return;
        end

        local needsFullRedraw = false;
        for k, v in pairs(currentlyEquipped.items) do
            if (not instance.displayedSlots[k]) or (instance.displayedSlots[k].item ~= v) then
                needsFullRedraw = true;
                break;
            end
        end
        for k, _ in pairs(instance.displayedSlots or {}) do
            if not currentlyEquipped.items[k] then
                needsFullRedraw = true;
                break;
            end
        end

        if needsFullRedraw then
            myClothingUI:drawButtonsFromItems(currentlyEquipped.items, currentlyEquipped.count);
            return;
        end

        for bodyLocation, item in pairs(currentlyEquipped.items) do
            local slot = instance.displayedSlots[bodyLocation];
            if slot then
                slot.slotItem = item;
                slot.item = item;
            end
        end

        myClothingUI:refreshCategoryWarnings(currentlyEquipped.items);
    end
end

function myClothingUI:refreshCategoryWarnings(equippedItems)
    if not instance or not instance.categoryButtons then
        return
    end

    local threshold = config.damaged_condition_threshold or 0.5;
    for category, button in pairs(instance.categoryButtons) do
        local hasDamaged = false;
        local locations = clothingCategories[category];
        if locations and equippedItems then
            for bodyLocation, item in pairs(equippedItems) do
                if locations[bodyLocation] and utils.isItemDamaged(item, threshold) then
                    hasDamaged = true;
                    break;
                end
            end
        end
        button.hasDamagedItems = hasDamaged;
    end
end

function myClothingUI:getBodyLocationIndex(bodyLocations, bodyLocation)
    local location = 0;
    for key, value in pairs(bodyLocations) do
        if key == bodyLocation then
            return location;
        else
            location = location + 1;
        end
    end
    return location;
end

function myClothingUI:getClothingItemCategory(itemBodyLocation)
    local itemCategory = nil;
    local locationIdx = 0;

    for k, v in pairs(clothingCategories) do
        if v[itemBodyLocation] then
            itemCategory = k;
            locationIdx = myClothingUI:getBodyLocationIndex(v, itemBodyLocation);
            break;
        end;
    end

    return locationIdx, itemCategory;
end

local function addClothingCategory(category, bodyLocation, inClothingCategories)
    if inClothingCategories[category] then
        inClothingCategories[category][bodyLocation] = true;
    end
end

function myClothingUI:clearSectionHeaders()
    if not instance or not instance.categoryButtons then
        return
    end
    for key, button in pairs(instance.categoryButtons) do
        instance:removeChild(button);
    end
    instance.categoryButtons = {};
end

function myClothingUI:removeItemButtons()
    if not instance or not instance.displayedSlots then
        return;
    end
    for k, v in pairs(instance.displayedSlots) do
        instance:removeChild(instance.displayedSlots[k]);
    end
    instance.displayedSlots = {};
end

--- Compact section layout: header + row of slots per non-empty category
function myClothingUI:drawButtonsFromItems(itemSet, itemCount)
    myClothingUI:removeItemButtons();
    myClothingUI:clearSectionHeaders();
    instance.displayedSlots = {};
    instance.itemCount = itemCount;

    local byCategory = {};
    for bodyLocation, item in pairs(itemSet) do
        local locationIndex, itemCategory = myClothingUI:getClothingItemCategory(bodyLocation);
        if itemCategory == nil then
            addClothingCategory("ACC", bodyLocation, clothingCategories);
            locationIndex, itemCategory = myClothingUI:getClothingItemCategory(bodyLocation);
        end
        if not byCategory[itemCategory] then
            byCategory[itemCategory] = {};
        end
        table.insert(byCategory[itemCategory], {
            index = locationIndex,
            itemData = item,
            bodyLocation = bodyLocation
        });
    end

    for cat, list in pairs(byCategory) do
        table.sort(list, function(a, b)
            return a.index < b.index
        end)
    end

    local slotSize = config.slot_button_size
    local slotGap = config.slot_button_horizontal_spacing
    local labelExtra = 0
    if config.display_slot_labels then
        labelExtra = (config.slot_label_margin or 15) + 2
    end

    local y = TITLE_BAR + PAD
    local maxRowWidth = 0
    local sortedCats = getSortedCategories()

    for _, catInfo in ipairs(sortedCats) do
        local list = byCategory[catInfo.key]
        if list and #list > 0 then
            local rowWidth = PAD * 2 + (#list * slotSize) + (math.max(#list - 1, 0) * slotGap)
            if rowWidth > maxRowWidth then
                maxRowWidth = rowWidth
            end

            local header = myCategoryButton:new(PAD, y, math.max(rowWidth - PAD * 2, 80), HEADER_H, catInfo.key,
                catInfo.data);
            instance.categoryButtons[catInfo.key] = header;
            instance:addChild(header);

            y = y + HEADER_H + 4 + labelExtra

            local x = PAD
            for i = 1, #list do
                local entry = list[i]
                local slot = myClothingSlot:new(x, y, slotSize, slotSize, entry.bodyLocation, entry.itemData);
                slot.item = entry.itemData;
                instance.displayedSlots[entry.bodyLocation] = slot;
                instance:addChild(slot);
                x = x + slotSize + slotGap
            end

            y = y + slotSize + SECTION_GAP
        end
    end

    local contentW = math.max(maxRowWidth, 180)
    local contentH = y + PAD
    instance:setWidth(contentW)
    instance:setHeight(contentH)

    -- stretch headers to full width
    for _, button in pairs(instance.categoryButtons) do
        button:setWidth(contentW - PAD * 2)
    end

    myClothingUI:refreshCategoryWarnings(itemSet);
end

function myClothingUI:handleToggle()
    if self:getIsVisible() then
        self:setVisible(false);
    else
        self:setVisible(true);
        self.itemCount = 0;
    end
end

function myClothingUI.toggle()
    if instance == nil then
        myClothingUI.ensureInstance();
    end
    if instance then
        instance:handleToggle();
    end
end

function myClothingUI.show()
    if instance == nil then
        myClothingUI.ensureInstance();
    end
    if instance then
        instance:setVisible(true);
        instance.itemCount = 0;
    end
end

function myClothingUI.hide()
    if instance then
        instance:setVisible(false);
    end
end

function myClothingUI.getDamagedLimbState(playerObj)
    local equipped = myClothingUI.collectEquippedClothing(playerObj or getPlayer());
    local threshold = config.damaged_condition_threshold or 0.5;
    return BodyPartMap.buildDamagedLimbState(equipped.items, threshold, clothingCategories), equipped.damagedCount;
end

function myClothingUI.ensureInstance()
    if instance then
        return instance
    end
    local loadedParams = myClothingUI:loadSavedParameters();
    loadedParams = myClothingUI:checkParameters(loadedParams);
    instance = myClothingUI:new(loadedParams["instance"].x, loadedParams["instance"].y, 220, 320);
    instance:addToUIManager();
    instance.itemCount = 0;
    instance:setTitle(getText("UI_CUI_window_title"));
    instance:setVisible(false);
    return instance
end

function myClothingUI:onGameStart()
    local loadedParams = myClothingUI:loadSavedParameters();
    loadedParams = myClothingUI:checkParameters(loadedParams);
    config.triggerConfigLoad();

    instance = myClothingUI:new(loadedParams["instance"].x, loadedParams["instance"].y, loadedParams["instance"].width,
        loadedParams["instance"].height);
    instance:addToUIManager();
    instance.itemCount = 0;
    instance:setTitle(getText("UI_CUI_window_title"));
    instance:setVisible(false);
end

function myClothingUI:checkParameters(paramIn)
    local xres = getCore():getScreenWidth()
    local yres = getCore():getScreenHeight()

    if not paramIn["instance"] then
        paramIn["instance"] = {
            x = 300,
            y = 300,
            width = 220,
            height = 320
        };
    end

    if paramIn["instance"].x > xres then
        paramIn["instance"].x = xres * 0.5;
    end
    if paramIn["instance"].y > yres then
        paramIn["instance"].y = yres * 0.5;
    end

    return paramIn;
end

function myClothingUI:loadSavedParameters()
    local reader = getFileReader("clothingui.ini", false);
    local parameters = {};
    local loadDefaults = false;

    if reader then
        local line = reader:readLine();
        reader:close();
        if not line or line == "" then
            loadDefaults = true;
        else
            parameters = json.parse(line);
            if not parameters["instance"] then
                loadDefaults = true;
            elseif not (parameters["instance"].x and parameters["instance"].y and parameters["instance"].width and
                parameters["instance"].height) then
                loadDefaults = true;
            end
        end
    else
        loadDefaults = true;
    end

    if loadDefaults then
        parameters["instance"] = {
            x = 300,
            y = 300,
            width = 220,
            height = 320
        };
    end

    return parameters
end

function myClothingUI:createSavedParameters()
    local parameters = {};
    if instance then
        parameters["instance"] = {
            x = instance.x,
            y = instance.y,
            width = instance.width,
            height = instance.height
        };
    else
        parameters["instance"] = {
            x = 300,
            y = 300,
            width = 220,
            height = 320
        };
    end
    return parameters
end

function myClothingUI:onSave()
    if instance then
        local writer = getFileWriter("clothingui.ini", true, false)
        local savedParameters = myClothingUI:createSavedParameters();
        writer:write(json.stringify(savedParameters));
        writer:close();
    end
end

Events.OnSave.Add(myClothingUI.onSave);
Events.OnGameStart.Add(myClothingUI.onGameStart);

-- Fallback floating button only if MiniHealth is not available.
local fallbackTries = 0
local function maybeCreateFallbackToggle()
    if ISMiniHealth then
        Events.OnTick.Remove(maybeCreateFallbackToggle)
        return
    end
    fallbackTries = fallbackTries + 1
    if fallbackTries < 120 then
        return
    end
    Events.OnTick.Remove(maybeCreateFallbackToggle)

    if myClothingUI._fallbackToggle then
        return
    end

    local panel = ISPanel:new(getCore():getScreenWidth() - 70, getCore():getScreenHeight() - 120, 44, 44)
    panel.moveWithMouse = true
    panel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.65 }
    panel.borderColor = { r = 0.55, g = 0.55, b = 0.55, a = 0.9 }
    local btn = ISButton:new(7, 7, 30, 30, "C", nil, function()
        myClothingUI.toggle()
    end)
    panel:addChild(btn)
    panel:addToUIManager()
    myClothingUI._fallbackToggle = panel
    print("CUI - MiniHealth not found, fallback clothing button created")
end

Events.OnGameStart.Add(function()
    Events.OnTick.Add(maybeCreateFallbackToggle)
end)
