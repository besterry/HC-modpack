-- Общий конфиг автосбора (клиент)

PM = PM or {}
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {}
PM.AutolootCustomItems = PM.AutolootCustomItems or {} -- [fullType] = true, макс AUTOLOOT_CUSTOM_MAX
PM.InventorySelected = PM.InventorySelected or {}
PM.AutoLootMessage = PM.AutoLootMessage or {}

AUTOLOOT_CUSTOM_MAX = 10

function AutoLoot_CountCustomItems()
	local n = 0
	for _ in pairs(PM.AutolootCustomItems) do
		n = n + 1
	end
	return n
end

function AutoLoot_GetCustomItemList()
	local list = {}
	for fullType, on in pairs(PM.AutolootCustomItems) do
		if on then
			table.insert(list, fullType)
		end
	end
	table.sort(list)
	return list
end

function AutoLoot_GetItemDisplayName(fullType)
	if not fullType then return "?" end
	local sm = getScriptManager()
	if not sm then return fullType end
	local script = sm:getItem(fullType) or sm:FindItem(fullType)
	if script and script.getDisplayName then
		return script:getDisplayName()
	end
	return fullType
end

function AutoLoot_IsShopSellItem(fullType)
	return fullType and PM.desiredItemsSet and PM.desiredItemsSet[fullType] == true
end

function AutoLoot_AddCustomItem(fullType)
	if not fullType or fullType == "" then
		return false, "bad"
	end
	if PM.AutolootCustomItems[fullType] then
		return false, "dup"
	end
	if AutoLoot_CountCustomItems() >= AUTOLOOT_CUSTOM_MAX then
		return false, "full"
	end
	PM.AutolootCustomItems[fullType] = true
	AutoLoot_SaveConfig()
	return true
end

function AutoLoot_RemoveCustomItem(fullType)
	if not fullType then return false end
	PM.AutolootCustomItems[fullType] = nil
	AutoLoot_SaveConfig()
	return true
end

function AutoLoot_ClearCustomItems()
	PM.AutolootCustomItems = {}
	AutoLoot_SaveConfig()
end

local function bagNameForSave()
	if not PM.InventorySelected or type(PM.InventorySelected) == "table" then
		return getText("IGUI_Main_Inventory")
	end
	local player = getPlayer()
	if PM.InventorySelected == player then
		return getText("IGUI_Main_Inventory")
	end
	if PM.InventorySelected.getName then
		return tostring(PM.InventorySelected:getName())
	end
	return getText("IGUI_Main_Inventory")
end

function AutoLoot_SaveConfig()
	local fileWriterObj = getFileWriter("AutoLoot_Config.txt", true, false)
	fileWriterObj:write("PM.Autoloot = " .. tostring(PM.Autoloot) .. "\n")
	fileWriterObj:write("PM.AutoLootMessage = " .. tostring(PM.AutoLootMessage) .. "\n")
	fileWriterObj:write("PM.InventorySelected = " .. bagNameForSave() .. "\n")
	fileWriterObj:write("PM.AutolootDisplayCategory = {")
	for category, isEnabled in pairs(PM.AutolootDisplayCategory) do
		if isEnabled then
			fileWriterObj:write(string.format('["%s"]=true,', category))
		end
	end
	fileWriterObj:write("}\n")
	fileWriterObj:write("PM.AutolootCustomItems = {")
	for fullType, on in pairs(PM.AutolootCustomItems) do
		if on then
			fileWriterObj:write(string.format('["%s"]=true,', fullType))
		end
	end
	fileWriterObj:write("}\n")
	fileWriterObj:close()
end

local function setInventorySelectedByName(value)
	local player = getPlayer()
	if not player then return end
	if value == getText("IGUI_Main_Inventory") or value == "" then
		PM.InventorySelected = player
		return
	end
	local containers = player:getInventory():getItemsFromCategory("Container")
	for i = 0, containers:size() - 1 do
		local bag = containers:get(i)
		if bag:isEquipped() and tostring(bag:getName()) == value then
			PM.InventorySelected = bag
			return
		end
	end
	PM.InventorySelected = player
end

local function parseTrueMap(value)
	local out = {}
	local categoriesString = string.match(value, "{(.+)}") or value
	local parts = string.split(categoriesString, ",")
	for _, part in ipairs(parts) do
		local key = string.match(part, '%[%"(.+)%"%]=true')
		if key then
			out[key] = true
		end
	end
	return out
end

function AutoLoot_LoadConfig()
	local fileReaderObj = getFileReader("AutoLoot_Config.txt", false)
	if not fileReaderObj then return end
	local line = fileReaderObj:readLine()
	while line do
		local key, value = string.match(line, "(.-)%s*=%s*(.+)")
		if key and value then
			if key == "PM.Autoloot" then
				PM.Autoloot = value == "true"
			elseif key == "PM.AutoLootMessage" then
				PM.AutoLootMessage = value == "true"
			elseif key == "PM.InventorySelected" then
				setInventorySelectedByName(value)
			elseif key == "PM.AutolootDisplayCategory" then
				PM.AutolootDisplayCategory = parseTrueMap(value)
			elseif key == "PM.AutolootCustomItems" then
				PM.AutolootCustomItems = parseTrueMap(value)
			end
		end
		line = fileReaderObj:readLine()
	end
	fileReaderObj:close()
end

Events.OnLoad.Add(AutoLoot_LoadConfig)
