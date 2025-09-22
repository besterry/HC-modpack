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
	self.backgroundColor = { r = 0.08, g = 0.1, b = 0.15, a = 0.98 }
	self.borderColor = { r = 0.3, g = 0.5, b = 0.8, a = 0.8 }
	self.moveWithMouse = true

    local x = 18
    local y = 16
    local contentWid = self.width - 36
    local btnWid = math.max(180, contentWid)
    local btnHgt = math.max(34, FONT_HGT_SMALL + 10)

    local function styleButton(btn)
        btn.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 }
        btn.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 }
        btn.backgroundColorMouseOver = { r = 0.18, g = 0.22, b = 0.28, a = 1 }
        btn.backgroundColorPressed = { r = 0.25, g = 0.3, b = 0.35, a = 1 }
        btn.textColor = { r = 0.95, g = 0.95, b = 0.95, a = 1 }
        btn.font = UIFont.Medium
    end

	-- Title
	self.titleLbl = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_AM_Service_Title") or "Auto Service", 1, 1, 1, 1, UIFont.Medium, true)
	self.titleLbl:initialise()
	self.titleLbl:instantiate()
	self:addChild(self.titleLbl)
	y = y + FONT_HGT_MEDIUM + 10

    -- Balance panel background
    local balancePanelH = 42
    self.balancePanel = ISPanel:new(x, y, contentWid, balancePanelH)
    self.balancePanel.backgroundColor = { r = 0.1, g = 0.12, b = 0.17, a = 0.95 }
    self.balancePanel.borderColor = { r = 0.35, g = 0.55, b = 0.85, a = 0.8 }
    self.balancePanel:initialise(); self.balancePanel:instantiate(); self:addChild(self.balancePanel)

    -- Balance panel
    local balTextY = y + 12
    self.balanceLblTitle = ISLabel:new(x + 8, balTextY, FONT_HGT_SMALL, getText("IGUI_AM_Balance") or "Balance:", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
	self.balanceLblTitle:initialise(); self.balanceLblTitle:instantiate(); self:addChild(self.balanceLblTitle)
    self.balanceLbl = ISLabel:new(x + 90, balTextY - 2, FONT_HGT_MEDIUM, "...", 1, 0.85, 0.3, 1, UIFont.Medium, true)
	self.balanceLbl:initialise(); self.balanceLbl:instantiate(); self:addChild(self.balanceLbl)

    self.refreshBtn = ISButton:new(self.width - 18 - 120, y + 6, 120, btnHgt, getText("IGUI_AM_Refresh") or "Refresh", self, AM_ServiceCar.onClick)
	self.refreshBtn.internal = "REFRESH"
    self.refreshBtn.anchorLeft = false; self.refreshBtn.anchorRight = true
    self.refreshBtn:initialise(); self.refreshBtn:instantiate(); styleButton(self.refreshBtn); self:addChild(self.refreshBtn)
	self.refreshCooldown = 0

    y = y + balancePanelH + 12

    -- Services panel background
    local servicesPanelY = y
    local servicesH = btnHgt * 3 + 8 * 2 + 16
    self.servicesPanel = ISPanel:new(x, servicesPanelY, contentWid, servicesH)
    self.servicesPanel.backgroundColor = { r = 0.1, g = 0.12, b = 0.17, a = 0.95 }
    self.servicesPanel.borderColor = { r = 0.35, g = 0.55, b = 0.85, a = 0.8 }
    self.servicesPanel:initialise(); self.servicesPanel:instantiate(); self:addChild(self.servicesPanel)

    local innerY = servicesPanelY + 8
    -- Service buttons
    self.removeRustBtn = ISButton:new(x + 4, innerY, contentWid - 8, btnHgt, "", self, AM_ServiceCar.onClick)
	self.removeRustBtn.internal = "REMOVE_RUST"
    self.removeRustBtn:initialise(); self.removeRustBtn:instantiate(); styleButton(self.removeRustBtn); self:addChild(self.removeRustBtn)
    innerY = innerY + btnHgt + 8

    self.engineQualityBtn = ISButton:new(x + 4, innerY, contentWid - 8, btnHgt, "", self, AM_ServiceCar.onClick)
	self.engineQualityBtn.internal = "IMPROVE_QUALITY"
    self.engineQualityBtn:initialise(); self.engineQualityBtn:instantiate(); styleButton(self.engineQualityBtn); self:addChild(self.engineQualityBtn)
    innerY = innerY + btnHgt + 8

    self.enginePowerBtn = ISButton:new(x + 4, innerY, contentWid - 8, btnHgt, "", self, AM_ServiceCar.onClick)
	self.enginePowerBtn.internal = "INCREASE_POWER"
    self.enginePowerBtn:initialise(); self.enginePowerBtn:instantiate(); styleButton(self.enginePowerBtn); self:addChild(self.enginePowerBtn)

    y = servicesPanelY + servicesH + 12

	-- Close button
    self.closeBtn = ISButton:new(x, self.height - 16 - btnHgt, 140, btnHgt, getText("UI_Close") or "Close", self, AM_ServiceCar.onClick)
	self.closeBtn.internal = "CLOSE"
	self.closeBtn.anchorTop = false; self.closeBtn.anchorBottom = true
    self.closeBtn:initialise(); self.closeBtn:instantiate(); styleButton(self.closeBtn); self:addChild(self.closeBtn)

    -- Draw coin icon near balance during render
    self.render = function(panel)
        ISPanel.render(panel)
        if icon_money then
            local iconX = x + 70
            local iconY = balTextY - 2
            panel:drawTextureScaledAspect(icon_money, iconX, iconY, 18, 18, 1, 1, 1, 1)
        end
    end

	-- Initial content
	self:updateBalanceLabels(true)
	self:updateServiceButtons()
	self:startTick()
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

function AM_ServiceCar:getPaymentType()
    return "balance"
end

function AM_ServiceCar:getServiceConfig()
	local cfg = {}
	cfg.RustPercent = getSandboxNPC("RustRestorePercent", 20)
	cfg.RustPriceMoney = getSandboxNPC("RustPriceMoney", 100)
	cfg.RustPriceBonus = getSandboxNPC("RustPriceBonus", 10)

	cfg.QualityPercent = getSandboxNPC("EngineQualityIncrease", 10)
	cfg.QualityPriceMoney = getSandboxNPC("EngineQualityPriceMoney", 150)
	cfg.QualityPriceBonus = getSandboxNPC("EngineQualityPriceBonus", 15)

	cfg.PowerPercent = getSandboxNPC("EnginePowerIncrease", 5)
	cfg.PowerPriceMoney = getSandboxNPC("EnginePowerPriceMoney", 200)
	cfg.PowerPriceBonus = getSandboxNPC("EnginePowerPriceBonus", 20)
	return cfg
end

function AM_ServiceCar:formatPrice(money)
    return string.format("%s %s", getText("IGUI_AM_Cost") or "Cost:", tostring(money))
end

function AM_ServiceCar:updateServiceButtons()
	local cfg = self:getServiceConfig()
    local balance = tonumber(PM.Balance or 0) or 0

    local rustCost = cfg.RustPriceMoney
    local qCost = cfg.QualityPriceMoney
    local pCost = cfg.PowerPriceMoney

    local rustText = string.format("%s (-%d%%) — %s", getText("IGUI_AM_RemoveRust") or "Remove Rust", cfg.RustPercent, self:formatPrice(cfg.RustPriceMoney))
    local qText = string.format("%s (+%d%%) — %s", getText("IGUI_AM_ImproveEngineQuality") or "Improve Engine Quality", cfg.QualityPercent, self:formatPrice(cfg.QualityPriceMoney))
    local pText = string.format("%s (+%d%%) — %s", getText("IGUI_AM_IncreaseEnginePower") or "Increase Engine Power", cfg.PowerPercent, self:formatPrice(cfg.PowerPriceMoney))

	self.removeRustBtn:setTitle(rustText)
	self.engineQualityBtn:setTitle(qText)
	self.enginePowerBtn:setTitle(pText)

    local canPayRust = balance >= rustCost
    local canPayQ = balance >= qCost
    local canPayP = balance >= pCost

	local hasPlayer = self.player ~= nil
	local hasVehicle = self.vehicle ~= nil

	self.removeRustBtn:setEnable(canPayRust and hasPlayer and hasVehicle)
	self.engineQualityBtn:setEnable(canPayQ and hasPlayer and hasVehicle)
	self.enginePowerBtn:setEnable(canPayP and hasPlayer and hasVehicle)
end

function AM_ServiceCar:onPayChange()
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
			or (serviceKey == 'INCREASE_POWER' and cfg.PowerPriceMoney) or 0,
        costBonus = 0
	}
	sendClientCommand(self.player, 'AutoService', 'Service', args)
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

function AM_ServiceCar:new(x, y, width, height, player, vehicle)
    local o = ISPanel:new(x, y, width or 420, height or 310)
	setmetatable(o, self)
	self.__index = self
	o.player = player
	o.vehicle = vehicle
    o.width = width or 420
    o.height = height or 310
	AM_ServiceCar.instance = o
	return o
end


