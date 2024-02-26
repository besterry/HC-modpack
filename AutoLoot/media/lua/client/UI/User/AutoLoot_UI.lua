-- Author: FD --

UI_AutoLoot = ISPanel:derive("UI_AutoLoot");
PM = PM or {} -- Глобальный контейнер PlayerMenu
Shop = Shop or {}
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {}
PM.Inventory = PM.Inventory or {}
PM.InventorySelected = PM.InventorySelected or {}
PM.TimeActivateAutoLoot = PM.TimeActivateAutoLoot or {} --Время покупки
PM.AutolootDurationAction = PM.AutolootDurationAction or {}
PM.AutoLootSandBoxBuy = PM.AutoLootSandBoxBuy or {}
PM.AutoLootMessage = PM.AutoLootMessage or {}
--local player = getPlayer()
local price
Events.EveryTenMinutes.Add(function()
	price = SandboxVars.AutoLoot.PriceAutoLoot
	PM.AutolootDurationAction = SandboxVars.AutoLoot.DurabilityAutoLoot
	PM.AutoLootSandBoxBuy = SandboxVars.AutoLoot.Buy
end)
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
--PM.Autoloot = false
local icon_money = getTexture("media/textures/pm_money.png")

local function BackpacksUser()
	local player = getPlayer()
	local containers = player:getInventory():getItemsFromCategory("Container");
	if PM.Inventory ~= nil then PM.Inventory = {} end
	for i = containers:size() - 1, 0, -1 do
		local bag = containers:get(i)
		if bag:getType() ~= "KeyRing" and bag:isEquipped() then
			table.insert(PM.Inventory, bag)
		end
	end
end

--сохранение конфигураций
local function saveConfig()
	local fileWriterObj = getFileWriter("AutoLoot_Config.txt", true, false)   
	fileWriterObj:write("PM.Autoloot = " .. tostring(PM.Autoloot) .. "\n") -- Сохранение значения вкл автолута
	fileWriterObj:write("PM.AutoLootMessage = " .. tostring(PM.AutoLootMessage) .. "\n") -- Сохранение значения сообщения автолута
	fileWriterObj:write("PM.InventorySelected = " .. tostring(PM.InventorySelected:getName()) .. "\n")--Сохранение последней сумки
	fileWriterObj:write("PM.AutolootDisplayCategory = {")-- Сохранение таблицы PM.AutolootSettings в одну строку
	for category, isEnabled in pairs(PM.AutolootDisplayCategory) do
		fileWriterObj:write(string.format('["%s"]=%s,', category, tostring(isEnabled)))
	end
	fileWriterObj:write("}\n")    
	fileWriterObj:close()
end

function UI_AutoLoot:initialise()
	ISPanel.initialise(self);
	BackpacksUser()
	local btnWid = 150
	local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
	local padBottom = 10
	local x = 10; --Горзонталь 
	local y = 15; --Вертикаль 

	--Заголовок окна
	self.ALLabel = ISLabel:new(70, 10, FONT_HGT_MEDIUM, getText("IGUI_AutoLoot"), 0, 1, 0, 1, UIFont.Medium, true)
	self.ALLabel:initialise()
	self.ALLabel:instantiate()
	self:addChild(self.ALLabel)

	--Заголовок Инвентарь
	self.IBLabel = ISLabel:new(60, 40, FONT_HGT_MEDIUM, getText("IGUI_InventoryBag"), 1, 1, 1, 1, UIFont.Medium, true)
	self.IBLabel:initialise()
	self.IBLabel:instantiate()
	self:addChild(self.IBLabel)

	--Список сумок
	self.comboBox = ISComboBox:new(20, 60, 170, 25, self,self.onClickTab);
	self.comboBox:initialise();
	self.comboBox:instantiate();
	self:addChild(self.comboBox);
	self.comboBox:clear()
	self.comboBox:addOptionWithData(getText("IGUI_Main_Inventory"), self.player);
	for _, bagName in ipairs(PM.Inventory) do
		self.comboBox:addOptionWithData(bagName:getName(),bagName)
	end
	PM.InventorySelected=self.player    

	--Заголовок категории
	self.CategoryLabel = ISLabel:new(250, 10, FONT_HGT_MEDIUM, getText("IGUI_Category"), 1, 1, 1, 1, UIFont.Medium, true)
	self.CategoryLabel:initialise()
	self.CategoryLabel:instantiate()
	self:addChild(self.CategoryLabel)

	--Заголовок время активации
	self.TimeLeftLabel = ISLabel:new(10, 90, FONT_HGT_MEDIUM, getText("IGUI_TimeLeftActivate"), 1, 1, 1, 1, UIFont.Medium, true)
	self.TimeLeftLabel:initialise()
	self.TimeLeftLabel:instantiate()
	self:addChild(self.TimeLeftLabel)

	--Время активации
	self.TimeLeftText = ISLabel:new(80, 90, FONT_HGT_MEDIUM, "", 1, 1, 1, 1, UIFont.Medium, true)
	self.TimeLeftText:initialise()
	self.TimeLeftText:instantiate()
	self:addChild(self.TimeLeftText)

	--Описание покупки
	self.BuyInfoLabel = ISLabel:new(10, 120, FONT_HGT_MEDIUM, getText("IGUI_BuyInfo") .. PM.AutolootDurationAction .. getText("IGUI_BuyInfoDay")..price, 1, 1, 1, 1, UIFont.Medium, true)
	self.BuyInfoLabel:initialise()
	self.BuyInfoLabel:instantiate()
	self:addChild(self.BuyInfoLabel)
	
	--Кнопка покупки
	self.Buy = ISButton:new(50, 150, 100, 20, getText("IGUI_Buy"), self, UI_AutoLoot.onClick)
	self.Buy.internal = "Buy"
	self.Buy.anchorTop = false
	self.Buy.anchorBottom = true
	self.Buy:initialise();
	self.Buy:instantiate();
	self.Buy.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
	self.Buy.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
	self:addChild(self.Buy)

	--Чекбокс включения\выключения автолута
	self.EnableAutoLootCheckBox = ISTickBox:new(x + 10, self:getHeight() - padBottom - btnHgt*2 - 10, 10, 10, "", self, UI_AutoLoot.onEnableAutoLootCheckbox)
	self.EnableAutoLootCheckBox:initialise()
	self.EnableAutoLootCheckBox:instantiate()
	self.EnableAutoLootCheckBox.selected[1] = PM.Autoloot
	self:addChild(self.EnableAutoLootCheckBox)
	self.EnableAutoLootCheckBox:addOption(getText("IGUI_Activate"));

	--Чекбокс включения\выключения сообщения автолута
	self.EnableAutoLootMessageCheckBox = ISTickBox:new(x + 100, self:getHeight() - padBottom - btnHgt*2 - 10, 10, 10, "", self, UI_AutoLoot.onEnableAutoLootMessageCheckbox)
	self.EnableAutoLootMessageCheckBox:initialise()
	self.EnableAutoLootMessageCheckBox:instantiate()
	self.EnableAutoLootMessageCheckBox.selected[1] = PM.AutoLootMessage or true
	self:addChild(self.EnableAutoLootMessageCheckBox)
	self.EnableAutoLootMessageCheckBox:addOption(getText("IGUI_ActivateMessage"));

	--Чекбокс аксесуары
	self.EnableAccessoriesCheckBox = ISTickBox:new(x + 240, y + 20, 10, 10, "", self, UI_AutoLoot.onEnableaccessoriesCheckbox)
	self.EnableAccessoriesCheckBox:initialise()
	self.EnableAccessoriesCheckBox:instantiate()
	self.EnableAccessoriesCheckBox.selected[1] = PM.AutolootDisplayCategory["ClothM"]
	self:addChild(self.EnableAccessoriesCheckBox)
	self.EnableAccessoriesCheckBox:addOption(getText("IGUI_Accessories"));

	--Чекбокс Tool
	self.EnableToolCheckBox = ISTickBox:new(x + 240, y + 45, 10, 10, "", self, UI_AutoLoot.onEnableToolCheckbox) --Tool
	self.EnableToolCheckBox:initialise()
	self.EnableToolCheckBox:instantiate()
	self.EnableToolCheckBox.selected[1] = PM.AutolootDisplayCategory["Tool"]
	self:addChild(self.EnableToolCheckBox)
	self.EnableToolCheckBox:addOption(getText("IGUI_Tool"));

	--Чекбокс Junk + Useless + Money (бумажники+кредитка + водительские права + монеты)
	self.EnableMoneyCheckBox = ISTickBox:new(x + 240, y + 70, 10, 10, "", self, UI_AutoLoot.onEnableMoneyCheckbox) --Money
	self.EnableMoneyCheckBox:initialise()
	self.EnableMoneyCheckBox:instantiate()
	self.EnableMoneyCheckBox.selected[1] = PM.AutolootDisplayCategory["Money"]
	self:addChild(self.EnableMoneyCheckBox)
	self.EnableMoneyCheckBox:addOption(getText("IGUI_Money"));

	--Чекбокс WepFire + Ammo
	self.EnableWepFireCheckBox = ISTickBox:new(x + 240, y + 95, 10, 10, "", self, UI_AutoLoot.onEnableWepFireCheckbox) --WepFire
	self.EnableWepFireCheckBox:initialise()
	self.EnableWepFireCheckBox:instantiate()
	self.EnableWepFireCheckBox.selected[1] = PM.AutolootDisplayCategory["WepFire"]
	self:addChild(self.EnableWepFireCheckBox)
	self.EnableWepFireCheckBox:addOption(getText("IGUI_WepFire"));

	--Чекбокс WepMelee
	self.EnableWepMeleeCheckBox = ISTickBox:new(x + 240, y + 120, 10, 10, "", self, UI_AutoLoot.onEnableWepMeleeCheckbox) --WepMelee
	self.EnableWepMeleeCheckBox:initialise()
	self.EnableWepMeleeCheckBox:instantiate()
	self.EnableWepMeleeCheckBox.selected[1] = PM.AutolootDisplayCategory["WepMelee"]
	self:addChild(self.EnableWepMeleeCheckBox)
	self.EnableWepMeleeCheckBox:addOption(getText("IGUI_WepMelee"));

	--Чекбокс WepAmmoMag
	self.EnableWepAmmoMagCheckBox = ISTickBox:new(x + 240, y + 145, 10, 10, "", self, UI_AutoLoot.onEnableWepAmmoMagCheckbox) --WepAmmoMag
	self.EnableWepAmmoMagCheckBox:initialise()
	self.EnableWepAmmoMagCheckBox:instantiate()
	self.EnableWepAmmoMagCheckBox.selected[1] = PM.AutolootDisplayCategory["WepAmmoMag"]
	self:addChild(self.EnableWepAmmoMagCheckBox)
	self.EnableWepAmmoMagCheckBox:addOption(getText("IGUI_WepAmmoMag"));

	--Чекбокс WepPart (Обвесы на оружие)
	self.EnableWepPartCheckBox = ISTickBox:new(x + 240, y + 170, 10, 10, "", self, UI_AutoLoot.onEnableWepPartCheckbox) --WepPart
	self.EnableWepPartCheckBox:initialise()
	self.EnableWepPartCheckBox:instantiate()
	self.EnableWepPartCheckBox.selected[1] = PM.AutolootDisplayCategory["WepPart"]
	self:addChild(self.EnableWepPartCheckBox)
	self.EnableWepPartCheckBox:addOption(getText("IGUI_WeaponPart"));

	--Чекбокс Одежда
	self.EnableClothCheckBox = ISTickBox:new(x + 240, y + 195, 10, 10, "", self, UI_AutoLoot.onEnableClothCheckbox)
	self.EnableClothCheckBox:initialise()
	self.EnableClothCheckBox:instantiate()
	self.EnableClothCheckBox.selected[1] = PM.AutolootDisplayCategory["Cloth"]
	self:addChild(self.EnableClothCheckBox)
	self.EnableClothCheckBox:addOption(getText("IGUI_Cloth"));

	--кнопка Закрыть
	self.cancel = ISButton:new(self:getWidth()/4 - btnWid/2, self:getHeight() - padBottom - btnHgt-5, btnWid, btnHgt, getText("UI_Close"), self, UI_AutoLoot.onClick)
	self.cancel.internal = "CANCEL"
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
	self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
	self:addChild(self.cancel)
end

local function Purchase()
	sendClientCommand(getPlayer(), 'BalanceAndSH', 'getServerTime', {})
	local receiveServerCommand
	receiveServerCommand = function(module, command, args)
		if module ~= 'BalanceAndSH' then return; end
		if command == 'onGetServerTime1' then
			PM.TimeActivateAutoLoot = args.time
			local saveData = {}
			saveData.delta = price
			saveData.balance = PM.Balance
			saveData.autoloot = PM.TimeActivateAutoLoot
			saveData.action = "buy autoloot"
			sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
			LoadBalanceAndSafeHousePlayer()
			Events.OnServerCommand.Remove(receiveServerCommand)
			GetTimeActivateAutoLootForcalculateTime()
		end
	end
	Events.OnServerCommand.Add(receiveServerCommand)
end

function UI_AutoLoot:onClick(button)
	if button.internal == "CANCEL" then
		self:setVisible(false)
		self:removeFromUIManager()
		UI_AutoLoot.instance = nil
	end
	if button.internal == "Buy" then
		if PM.Balance >= price then
			Purchase()
		else
			getPlayer():Say(getText('IGUI_NoMoney'))
		end
	end
end

function UI_AutoLoot:onEnableAutoLootCheckbox() --Чекбокс активации автолута
	PM.Autoloot = self.EnableAutoLootCheckBox.selected[1]
	if PM.Autoloot then
		getPlayer():setHaloNote(getText("IGUI_AutolootActivate"), 255, 255, 100, 300);
	else 
		getPlayer():setHaloNote(getText("IGUI_AutolootDeActivate"), 255, 255, 100, 300)
	end
	saveConfig()
end

function UI_AutoLoot:onEnableAutoLootMessageCheckbox() --Чекбокс сообщений автолута
	PM.AutoLootMessage = self.EnableAutoLootMessageCheckBox.selected[1]
	saveConfig()
	if PM.AutoLootMessage then
		getPlayer():setHaloNote(getText("IGUI_AutolootMessageActivate"), 255, 255, 100, 300);
	else
		getPlayer():setHaloNote(getText("IGUI_AutolootMessageDeActivate"), 255, 255, 100, 300);
	end
	
end

function UI_AutoLoot:onEnableClothCheckbox() --Чекбокс Cloth
	local isCheckboxSelected = self.EnableClothCheckBox.selected[1]
	saveConfig()
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["Cloth"] = true        
	else
		PM.AutolootDisplayCategory["Cloth"] = nil
	end    
end

function UI_AutoLoot:onEnableToolCheckbox() --Чекбокс Tool,FoodN
	local isCheckboxSelected = self.EnableToolCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["Tool"] = true
		PM.AutolootDisplayCategory["FoodN"] = true --Батончики
	else
		PM.AutolootDisplayCategory["Tool"] = nil
		PM.AutolootDisplayCategory["FoodN"] = nil  --Батончики
	end
	saveConfig()
end

function UI_AutoLoot:onEnableMoneyCheckbox() --Чекбокс Money
	local isCheckboxSelected = self.EnableMoneyCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["Junk"] = true
		PM.AutolootDisplayCategory["Useless"] = true
		PM.AutolootDisplayCategory["Money"] = true        
	else
		PM.AutolootDisplayCategory["Junk"] = nil
		PM.AutolootDisplayCategory["Useless"] = nil
		PM.AutolootDisplayCategory["Money"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onEnableWepFireCheckbox() --Чекбокс WepFire
	local isCheckboxSelected = self.EnableWepFireCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["WepFire"] = true
		PM.AutolootDisplayCategory["Ammo"] = true
	else
		PM.AutolootDisplayCategory["WepFire"] = nil
		PM.AutolootDisplayCategory["Ammo"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onEnableWepMeleeCheckbox() --Чекбокс WepMelee
	local isCheckboxSelected = self.EnableWepMeleeCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["WepMelee"] = true
	else
		PM.AutolootDisplayCategory["WepMelee"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onEnableWepAmmoMagCheckbox() --Чекбокс WepAmmoMag
	local isCheckboxSelected = self.EnableWepAmmoMagCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["WepAmmoMag"] = true
	else
		PM.AutolootDisplayCategory["WepAmmoMag"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onEnableaccessoriesCheckbox()--Чекбокс ClothM,ClothA
	local isCheckboxSelected = self.EnableAccessoriesCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["ClothM"] = true
		PM.AutolootDisplayCategory["ClothA"] = true
	else
		PM.AutolootDisplayCategory["ClothM"] = nil
		PM.AutolootDisplayCategory["ClothA"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onEnableWepPartCheckbox() --Чекбокс WepPart
	local isCheckboxSelected = self.EnableWepPartCheckBox.selected[1]
	if isCheckboxSelected then
		PM.AutolootDisplayCategory["WepPart"] = true
	else
		PM.AutolootDisplayCategory["WepPart"] = nil
	end
	saveConfig()
end

function UI_AutoLoot:onClickTab() --Дествие при выборе сумки
	BackpacksUser()
	self.comboBox:clear()
	self.comboBox:addOptionWithData(getText("IGUI_Main_Inventory"), self.player);
	for _, bagName in ipairs(PM.Inventory) do
		self.comboBox:addOptionWithData(bagName:getName(),bagName)
	end

	if self.comboBox:getSelectedText() then
		PM.InventorySelected=(self.comboBox.options[self.comboBox.selected].data)--:getItemContainer()
	else        
		PM.InventorySelected=self.player--:getInventory()
	end
	saveConfig()
end
local remainingTime = 0
local function calculateTime() --Расчет оставшего время действия
	local subscriptionDuration = PM.AutolootDurationAction * 24 * 60 * 60  -- 7 дней в секундах   
	--print("subscriptionDuration:",subscriptionDuration) 
	local currentDate = os.time()-- Текущая дата и время
	remainingTime = PM.TimeActivateAutoLoot + subscriptionDuration - currentDate-- Оставшееся время в секундах
	-- Расчет дней, часов, минут и секунд
	local remainingDays = math.floor(remainingTime / (24 * 60 * 60))
	local remainingHours = math.floor((remainingTime % (24 * 60 * 60)) / (60 * 60))
	local remainingMinutes = math.floor((remainingTime % (60 * 60)) / 60)
	local remainingSeconds = math.floor(remainingTime % 60)
	--print("remainingTime:",remainingTime)
	if remainingTime <=0 then return 0,0,0,0 end
	return remainingDays, remainingHours, remainingMinutes, remainingSeconds
end

function UI_AutoLoot:render()  
	local d, h, m, s    
	--print("PM.TimeActivateAutoLoot:",PM.TimeActivateAutoLoot)
	if type(PM.TimeActivateAutoLoot) ~= "table" and PM.TimeActivateAutoLoot ~= nil and PM.TimeActivateAutoLoot>=0 then --Блок отображения оставшегося времени        
		d, h, m, s = calculateTime()
	else
		d,h,m,s = 0,0,0,0
		remainingTime = 0
	end

	if remainingTime > 0 or not PM.AutoLootSandBoxBuy then self.Buy:setEnable(false) else self.Buy:setEnable(true) end
	if remainingTime <= 0 then 
		self.EnableAutoLootCheckBox:setEnabled(false) 
		self.EnableAutoLootCheckBox.selected[1]=false 
		PM.Autoloot = false
	else 
		self.EnableAutoLootCheckBox:setEnabled(true)
	end
	self.TimeLeftText.name = d.." "..getText("IGUI_Day").." "..h.." "..getText("IGUI_Hour").." "..m.." "..getText("IGUI_Minute").." "..s.." "..getText("IGUI_Second")
	self.BuyInfoLabel.name = getText("IGUI_BuyInfo") .. PM.AutolootDurationAction .. getText("IGUI_BuyInfoDay")..price
	local textWid = getTextManager():MeasureStringX( UIFont.Medium, self.BuyInfoLabel.name);
	self:drawTextureScaledAspect(icon_money,15+textWid,120,18,18,1,1,1,1) --иконка монетки 160
end

function UI_AutoLoot:new(x, y, width, height, player) --Функция создания окна
	local o = {} -- Создаем новый объект
	x = getCore():getScreenWidth() / 2 - (width / 2);
	y = getCore():getScreenHeight() / 2 - (height / 2);
	o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
	setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
	self.__index = self -- Устанавка индекса текущего объекта как self
	o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
	o.backgroundColor = {r=0, g=0, b=0, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
	o.width = width; -- Устанавка ширины окна
	o.height = height; -- Устанавка высоты окна
	o.player = player; -- Устанавка игрока
	o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
	UI_AutoLoot.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
	o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
	return o; -- Возвращаем созданный объект
end

--Восстановление сумки (последней выбранной)
local function SetInventorySelectedByName(value)
	for _, bag in ipairs(PM.Inventory) do
		if tostring(bag:getName()) == value then
			PM.InventorySelected = bag
			break
		end
	end
end


-- function TimeActivateAutoLoot() --Получение времени покупки
-- 	local player = getPlayer()
-- 	if not player then return end
-- 	sendClientCommand(player, "BalanceAndSH", "getDataALUI", nil)

-- 	local function receiveServerCommand1(module, command, args)
-- 		if module ~= 'BalanceAndSH' and command ~= 'onGetDataALUI' then return; end
-- 		print(args)
-- 		for k, v in pairs(args) do
-- 			print(k, " ", v)
-- 		end
-- 		if args and args['UserData'] and args['UserData'].autoloot and args['UserData'].autoloot>0 then
-- 			print(111)
-- 			print("ARGS:",args['UserData'].autoloot)
-- 			PM.TimeActivateAutoLoot = args['UserData'].autoloot
-- 		else
-- 			print(222)
-- 			PM.TimeActivateAutoLoot = 0
-- 		end
-- 		if type(PM.TimeActivateAutoLoot) ~= "table" and PM.TimeActivateAutoLoot ~= nil then
-- 			calculateTime()
-- 		end
-- 		Events.OnServerCommand.Remove(receiveServerCommand1)
-- 	end
-- 	Events.OnServerCommand.Add(receiveServerCommand1)
-- 	Events.OnTick.Remove(TimeActivateAutoLoot)
-- end
-- Events.OnTick.Add(TimeActivateAutoLoot)
-- TimeActivateAutoLoot()

local function onLoad() --Чтение настроек из файла (восстановление категорий и сумки)
	BackpacksUser()
	local fileReaderObj = getFileReader("AutoLoot_Config.txt", false)
	if fileReaderObj then
		local line = fileReaderObj:readLine()
		while line do
			local key, value = string.match(line, "(.-)%s*=%s*(.+)")
			if key and value then
				if key == "PM.Autoloot" then
					PM.Autoloot = value == "true"
				elseif key == "PM.AutoLootMessage" then
					PM.AutoLootMessage = value == "true"
				elseif key == "PM.InventorySelected" then
					SetInventorySelectedByName(value)
				elseif key == "PM.AutolootDisplayCategory" then
					local categoriesString = string.match(value, "{(.+)}") or value
					local categoriesArray = string.split(categoriesString, ',')
					for _, categoryItem in ipairs(categoriesArray) do
						local category, value = string.match(categoryItem, '(%b[])=(true)')
						if category then
							category = category:sub(2, -2)  -- Удаляем квадратные скобки
							PM.AutolootDisplayCategory[category:sub(2, -2)] = true
						end
					end
				end
			end
			line = fileReaderObj:readLine()
		end
		fileReaderObj:close()
	end
end
Events.OnLoad.Add(onLoad)