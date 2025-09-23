-- Author: FD -- AutoMeh Service UI
require "ISUI/ISPanel"

AM_ServiceCar = ISPanel:derive("AM_ServiceCar")
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local icon_money = getTexture("media/textures/pm_money.png")
local function getSandboxNPC(key, defaultValue)
	if SandboxVars and SandboxVars.NPC and SandboxVars.NPC[key] ~= nil then
		return SandboxVars.NPC[key]
	end
	return defaultValue
end

function AM_ServiceCar:initialise()
	ISPanel.initialise(self)
	self:instantiate()
	self.noBackground = false
	self.backgroundColor = { r = 0.12, g = 0.12, b = 0.12, a = 0.98 }
	self.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 }
	self.moveWithMouse = true

    local x = 12
    local y = 12
    local contentWid = self.width - 24
    local btnWid = math.max(160, contentWid)
    local btnHgt = math.max(28, FONT_HGT_SMALL + 6)

    local function styleButton(btn)
        btn.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 0.9 }
        btn.backgroundColor = { r = 0.18, g = 0.18, b = 0.18, a = 0.95 }
        btn.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.25, a = 1 }
        btn.backgroundColorPressed = { r = 0.32, g = 0.32, b = 0.32, a = 1 }
        btn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }
        btn.font = UIFont.Small
    end

	-- Title
	self.titleLbl = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_AM_Service_Title"), 0.9, 0.9, 0.9, 1, UIFont.Medium, true)
	self.titleLbl:initialise()
	self.titleLbl:instantiate()
	self:addChild(self.titleLbl)
	y = y + FONT_HGT_MEDIUM + 8

    -- Balance panel background
    local balancePanelH = 32
    self.balancePanel = ISPanel:new(x, y, contentWid, balancePanelH)
    self.balancePanel.backgroundColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 }
    self.balancePanel.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 }
    self.balancePanel:initialise(); self.balancePanel:instantiate(); self:addChild(self.balancePanel)

    -- Balance panel
    local balTextY = y + 8
    self.balanceLblTitle = ISLabel:new(x + 6, balTextY, FONT_HGT_SMALL, getText("IGUI_AM_Balance"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
	self.balanceLblTitle:initialise(); self.balanceLblTitle:instantiate(); self:addChild(self.balanceLblTitle)
    self.balanceLbl = ISLabel:new(x + 80, balTextY - 1, FONT_HGT_SMALL, "...", 1, 0.8, 0.2, 1, UIFont.Small, true)
	self.balanceLbl:initialise(); self.balanceLbl:instantiate(); self:addChild(self.balanceLbl)

    self.refreshBtn = ISButton:new(self.width - 12 - 80, y + 4, 80, btnHgt, getText("IGUI_AM_Refresh"), self, AM_ServiceCar.onClick)
	self.refreshBtn.internal = "REFRESH"
    self.refreshBtn.anchorLeft = false; self.refreshBtn.anchorRight = true
    self.refreshBtn:initialise(); self.refreshBtn:instantiate(); styleButton(self.refreshBtn); self:addChild(self.refreshBtn)
	self.refreshCooldown = 0

    y = y + balancePanelH + 8

    -- Vehicle status panel background
    local statusPanelH = 24
    self.statusPanel = ISPanel:new(x, y, contentWid, statusPanelH)
    self.statusPanel.backgroundColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 }
    self.statusPanel.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 }
    self.statusPanel:initialise(); self.statusPanel:instantiate(); self:addChild(self.statusPanel)

    -- Vehicle status labels - все в одну строку
    local statusTextY = y + 6
    local statusSpacing = contentWid / 3
    
    self.rustLbl = ISLabel:new(x + 6, statusTextY, FONT_HGT_SMALL, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.rustLbl:initialise(); self.rustLbl:instantiate(); self:addChild(self.rustLbl)
    
    self.qualityLbl = ISLabel:new(x + statusSpacing, statusTextY, FONT_HGT_SMALL, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.qualityLbl:initialise(); self.qualityLbl:instantiate(); self:addChild(self.qualityLbl)
    
    self.powerLbl = ISLabel:new(self.width - statusSpacing - x, statusTextY, FONT_HGT_SMALL, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.powerLbl:initialise(); self.powerLbl:instantiate(); self:addChild(self.powerLbl)

    y = y + statusPanelH + 8

    -- Services panel background
    local servicesPanelY = y

    -- Services panel background
    local servicesPanelY = y
    local servicesH = btnHgt * 3 + 6 * 2 + 12
    self.servicesPanel = ISPanel:new(x, servicesPanelY, contentWid, servicesH)
    self.servicesPanel.backgroundColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.95 }
    self.servicesPanel.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 }
    self.servicesPanel:initialise(); self.servicesPanel:instantiate(); self:addChild(self.servicesPanel)

    local innerY = servicesPanelY + 6
    -- Service buttons
    self.removeRustBtn = ISButton:new(x + 3, innerY, contentWid - 6, btnHgt, "", self, AM_ServiceCar.onClick)
	self.removeRustBtn.internal = "REMOVE_RUST"
    self.removeRustBtn:initialise(); self.removeRustBtn:instantiate(); styleButton(self.removeRustBtn); self:addChild(self.removeRustBtn)
    innerY = innerY + btnHgt + 6

    self.engineQualityBtn = ISButton:new(x + 3, innerY, contentWid - 6, btnHgt, "", self, AM_ServiceCar.onClick)
	self.engineQualityBtn.internal = "IMPROVE_QUALITY"
    self.engineQualityBtn:initialise(); self.engineQualityBtn:instantiate(); styleButton(self.engineQualityBtn); self:addChild(self.engineQualityBtn)
    innerY = innerY + btnHgt + 6

    self.enginePowerBtn = ISButton:new(x + 3, innerY, contentWid - 6, btnHgt, "", self, AM_ServiceCar.onClick)
	self.enginePowerBtn.internal = "INCREASE_POWER"
    self.enginePowerBtn:initialise(); self.enginePowerBtn:instantiate(); styleButton(self.enginePowerBtn); self:addChild(self.enginePowerBtn)

    y = servicesPanelY + servicesH + 8

	-- Close button
    local closeBtnWid = 100
    self.closeBtn = ISButton:new(self.width/2 - closeBtnWid/2, self.height - 12 - btnHgt, closeBtnWid, btnHgt, getText("UI_Close"), self, AM_ServiceCar.onClick)
	self.closeBtn.internal = "CLOSE"
	self.closeBtn.anchorTop = false; self.closeBtn.anchorBottom = true
    self.closeBtn:initialise(); self.closeBtn:instantiate(); styleButton(self.closeBtn); self:addChild(self.closeBtn)

    -- Draw coin icon near balance during render
    self.render = function(panel)
        ISPanel.render(panel)
        if icon_money then
            local iconX = x + 65
            local iconY = balTextY
            panel:drawTextureScaledAspect(icon_money, iconX, iconY, 12, 12, 1, 1, 1, 1)
        end
    end

	-- Initial content
	self:updateBalanceLabels(true)
	self:updateServiceButtons()
	self:startTick()
end

function AM_ServiceCar:updateVehicleStatus()
    if not self.vehicle then return end
    
    local rust = math.floor(self.vehicle:getRust() * 100)
    local quality = self.vehicle:getEngineQuality()
    local power = math.floor(self.vehicle:getEnginePower() / 10)
    if self.vehicle:getRust() > 0 and rust == 0 then
        rust = 1 -- Если ржавчина больше 0, но на клиенте 0, то устанавливаем 1%
    end
    self.rustLbl.name = string.format("%s: %d%%", getText("IGUI_AM_Rust"), rust)
    self.qualityLbl.name = string.format("%s: %d%%", getText("IGUI_AM_Quality"), quality)
    self.powerLbl.name = string.format("%s: %d %s", getText("IGUI_AM_Power"), power, getText("IGUI_AM_HP"))
end

function AM_ServiceCar:update()
	if AutoMeh.CheckDistance(self.geoX,self.geoY) then
        self:setVisible(false)
		self:removeFromUIManager()
		AM_ServiceCar.instance = nil
    end
end

function AM_ServiceCar:startTick()
	if self._tickAdded then return end
	self._tickAdded = true
	Events.OnTick.Add(AM_ServiceCar.onTick)
end

function AM_ServiceCar:stopTick()
	if not self._tickAdded then return end
	self._tickAdded = nil
	Events.OnTick.Remove(AM_ServiceCar.onTick)
end

function AM_ServiceCar.onTick()
	if not AM_ServiceCar.instance then return end
	local ui = AM_ServiceCar.instance
	if not ui:isVisible() then return end
	ui:updateBalanceLabels(false)
	ui:updateServiceButtons()
	if ui.refreshCooldown and ui.refreshCooldown > 0 then
		ui.refreshCooldown = ui.refreshCooldown - 1
	end
end

function AM_ServiceCar:updateBalanceLabels(triggerRequest)
	local b = PM.Balance
    if not b then
		if triggerRequest then LoadBalanceAndSafeHousePlayer() end
	end
	self.balanceLbl.name = tostring(b or "...")
end

function AM_ServiceCar:getServiceConfig()
	local cfg = {}
	cfg.RustPercent = getSandboxNPC("RustRestorePercent", 20) -- SandboxVars.NPC.RustRestorePercent (сколько % ржавчины убирается)
	cfg.RustPriceMoney = getSandboxNPC("RustPriceMoney", 100) -- SandboxVars.NPC.RustPriceMoney (сколько стоит услуга ржавчины)
	cfg.RustPriceBonus = getSandboxNPC("RustPriceBonus", 10) -- SandboxVars.NPC.RustPriceBonus (сколько стоит услуга ржавчины)

	cfg.QualityPercent = getSandboxNPC("EngineQualityIncrease", 10) -- SandboxVars.NPC.EngineQualityIncrease (сколько % качества увеличивается)
	cfg.QualityPriceMoney = getSandboxNPC("EngineQualityPriceMoney", 150) -- SandboxVars.NPC.EngineQualityPriceMoney (сколько стоит услуга качества)
	cfg.QualityPriceBonus = getSandboxNPC("EngineQualityPriceBonus", 15) -- SandboxVars.NPC.EngineQualityPriceBonus (сколько стоит услуга качества)

	cfg.PowerPercent = getSandboxNPC("EnginePowerIncrease", 5) -- SandboxVars.NPC.EnginePowerIncrease (сколько % мощности увеличивается)
	cfg.PowerPriceMoney = getSandboxNPC("EnginePowerPriceMoney", 200) -- SandboxVars.NPC.EnginePowerPriceMoney (сколько стоит услуга мощности)
	cfg.PowerPriceBonus = getSandboxNPC("EnginePowerPriceBonus", 20) -- SandboxVars.NPC.EnginePowerPriceBonus (сколько стоит услуга мощности)
	return cfg
end

function AM_ServiceCar:formatPrice(money)
    return string.format("%s %s", getText("IGUI_AM_Cost"), tostring(money))
end

function AM_ServiceCar:updateServiceButtons()
	self:updateVehicleStatus()
	local cfg = self:getServiceConfig()
    local balance = tonumber(PM.Balance or 0) or 0

    local rustCost = cfg.RustPriceMoney
    local qCost = cfg.QualityPriceMoney
    local pCost = cfg.PowerPriceMoney

    local rustText = string.format("%s (-%d%%) — %s", getText("IGUI_AM_RemoveRust"), cfg.RustPercent, self:formatPrice(cfg.RustPriceMoney))
    local qText = string.format("%s (+%d%%) — %s", getText("IGUI_AM_ImproveEngineQuality"), cfg.QualityPercent, self:formatPrice(cfg.QualityPriceMoney))
    local pText = string.format("%s (+%d%%) — %s", getText("IGUI_AM_IncreaseEnginePower"), cfg.PowerPercent, self:formatPrice(cfg.PowerPriceMoney))

	self.removeRustBtn:setTitle(rustText)
	self.engineQualityBtn:setTitle(qText)
	self.enginePowerBtn:setTitle(pText)

    local canPayRust = balance >= rustCost
    local canPayQ = balance >= qCost
    local canPayP = balance >= pCost

	local hasPlayer = self.player ~= nil
	local hasVehicle = self.vehicle ~= nil

	local modData = self.vehicle:getModData() -- Моддата авто
	local engineQuality = self.vehicle:getEngineQuality() -- Качество двигателя
	local maxEngineQuality = getSandboxNPC("MaxEngineQuality", 90) -- Максимальное количество увеличений качества двигателя
	local enginePowerIncreased = modData.enginePowerIncreased or false -- Увеличили ли мощность двигателя
	local rust = self.vehicle:getRust() -- Ржавчина
	-- print("engineQuality: " .. engineQuality)
	-- print("EnginePower:" .. self.vehicle:getEnginePower())
	self.removeRustBtn:setEnable(canPayRust and hasPlayer and hasVehicle and rust > 0)
	self.engineQualityBtn:setEnable(canPayQ and hasPlayer and hasVehicle and engineQuality < maxEngineQuality)
	self.enginePowerBtn:setEnable(canPayP and hasPlayer and hasVehicle and not enginePowerIncreased)
end

function AM_ServiceCar:sendService(serviceKey)
	if not self.player or not self.vehicle then return end
	local cfg = self:getServiceConfig()
	local args = {
		vehicleId = self.vehicle:getId(),
		service = serviceKey,
        payment = "balance",
		percent = (serviceKey == 'REMOVE_RUST' and cfg.RustPercent)
			or (serviceKey == 'IMPROVE_QUALITY' and cfg.QualityPercent)
			or (serviceKey == 'INCREASE_POWER' and cfg.PowerPercent) or 0,
		costMoney = (serviceKey == 'REMOVE_RUST' and cfg.RustPriceMoney)
			or (serviceKey == 'IMPROVE_QUALITY' and cfg.QualityPriceMoney)
			or (serviceKey == 'INCREASE_POWER' and cfg.PowerPriceMoney) or 0
	}
	if PM.Balance and PM.Balance >= args.costMoney then
		-- print("rust: " .. self.vehicle:getRust())
		sendClientCommand(self.player, 'AM_Service', 'Service', args)
	else
		self.player:Say(getText("IGUI_AM_No_Money"))
	end
end

function AM_ServiceCar:onClick(button)
	if button.internal == "CLOSE" then
		self:close()
		return
	end
	if button.internal == "REFRESH" then
		if self.refreshCooldown <= 0 then
			LoadBalanceAndSafeHousePlayer()
			self.refreshCooldown = 200
		end
		return
	end
	if button.internal == "REMOVE_RUST" then
		self:sendService('REMOVE_RUST')
		return
	end
	if button.internal == "IMPROVE_QUALITY" then
		self:sendService('IMPROVE_QUALITY')
		return
	end
	if button.internal == "INCREASE_POWER" then
		self:sendService('INCREASE_POWER')
		return
	end
end

function AM_ServiceCar:close()
	self:stopTick()
	self:setVisible(false)
	self:removeFromUIManager()
	AM_ServiceCar.instance = nil
end

function AM_ServiceCar:new(x, y, width, height, player, vehicle, geoX, geoY)
    -- Проверка на дублирование окна
    if AM_ServiceCar.instance then
        AM_ServiceCar.instance:close()
    end
    
    local o = ISPanel:new(x, y, width or 320, height or 260)
	setmetatable(o, self)
	self.__index = self
	o.player = player
	o.vehicle = vehicle
    o.width = width or 320
    o.height = height or 260
    o.geoX = geoX
    o.geoY = geoY
	AM_ServiceCar.instance = o
	return o
end

local function ServiceComplete(args)
    local vehicle = getVehicleById(args.vehicleId)
    if vehicle then
		if args.modData and args.modData.engineQualityIncreased then
			vehicle:getModData().engineQualityIncreased = args.modData.engineQualityIncreased
		end
		if args.modData and args.modData.enginePowerIncreased then
			vehicle:getModData().enginePowerIncreased = args.modData.enginePowerIncreased
		end
    end
	if AM_ServiceCar.instance then
		AM_ServiceCar.instance:updateServiceButtons()
		LoadBalanceAndSafeHousePlayer()
	end
end

local OnServerCommand = function(module, command, args)
    if module ~= "AM_Service" then return end
    if command == "ServiceComplete" then
        ServiceComplete(args)
    end
end
Events.OnServerCommand.Add(OnServerCommand)