--- Settings for the odometer
OdometerSettings = {
    backgroundImage = "media/ui/vehicles/vehicle_odometer.png",
    odometerY = 93,
    odometerTextY = 98.5,
    colors = {
        odometer = {
            green = 1,
            red = 1,
            blue = 1,
            alpha = 0.8,
        },
        tripOdometer = {
            green = 0.8,
            red = 0.8,
            blue = 1,
            alpha = 0.8,
        }
    },
    font = UIFont.Small,
}

---@type ISContextMenu|nil
local odometerContext

--- Override ISVehicleDashboard.new to load textures
local _ISVehicleDashboard_new = ISVehicleDashboard.new
function ISVehicleDashboard:new(playerNum, chr)
    local o = _ISVehicleDashboard_new(self, playerNum, chr)
	o.odometerTexture = getTexture("media/ui/vehicles/vehicle_odometer.png")
    return o
end

--- Override ISVehicleDashboard.createChildren to do nothing
local _ISVehicleDashboard_createChildren = ISVehicleDashboard.createChildren
function ISVehicleDashboard:createChildren()
    _ISVehicleDashboard_createChildren(self)

    self.odometerTex = ISImage:new((self.backgroundTex:getWidth() / 2) - (self.odometerTexture:getWidthOrig() / 2), OdometerSettings.odometerY, self.odometerTexture:getWidthOrig(), self.odometerTexture:getHeightOrig(), self.odometerTexture)
	self.odometerTex:initialise()
	self.odometerTex:instantiate()
    self.odometerTex.onclick = ISVehicleDashboard.onClickOdometer
	self.odometerTex.target = self;
	self:addChild(self.odometerTex)
end

--- Override ISVehicleDashboard.render to draw the odometer
local _ISVehicleDashboard_render = ISVehicleDashboard.render
function ISVehicleDashboard:render()
    _ISVehicleDashboard_render(self)

    ---@type BaseVehicle
    local vehicle = self.vehicle

    if not vehicle then return end

    if vehicle:isKeysInIgnition() or vehicle:isEngineRunning() then
        local odometer
        
        local modData = vehicle:getModData()
        if modData.showTripOdometer then
            odometer = MileageExpansionAPI.getTripOdometerValue(vehicle)
        else
            odometer = MileageExpansionAPI.getVehicleOdometerValue(vehicle)
        end
        odometer = math.floor(math.min(odometer, 999999))

        local color = OdometerSettings.colors.odometer
        if modData.showTripOdometer then
            color = OdometerSettings.colors.tripOdometer
        end

        if not modData.useMetricOdometer then
            local mile = 0.6213711922 -- 1 kilometer = 0.6213711922 mile
            local miles = odometer * mile
            local mileString = getSandboxOptions():getOptionByName('MileageExpansion.Miles_Short_Name'):getValue() or "mi"
            self:drawTextCentre(string.format("%06d", math.floor(miles)) .. " " .. mileString, (self.backgroundTex:getWidth() / 2), OdometerSettings.odometerTextY, color.red, color.green, color.blue, color.alpha, OdometerSettings.font);
        else
            local kilometerString = getSandboxOptions():getOptionByName('MileageExpansion.Kilometer_Short_Name'):getValue() or "km"
            self:drawTextCentre(string.format("%06d", math.floor(odometer)) .. " " .. kilometerString, (self.backgroundTex:getWidth() / 2), OdometerSettings.odometerTextY, color.red, color.green, color.blue, color.alpha, OdometerSettings.font);
        end
    end
end

--- Create context menu for the odometer right-click
function ISVehicleDashboard:onClickOdometer()
    if self.vehicle and self.vehicle:isEngineRunning() then
        ---@type ISContextMenu
        odometerContext = ISContextMenu.get(self.playerNum, getMouseX(), getMouseY())
        if not odometerContext then return end

        local modData = self.vehicle:getModData()

        if not modData.useMetricOdometer then
            --- Toggle metric
            odometerContext:addOption(getText("ContextMenu_Use_Metric"), nil, function()
                ISTimedActionQueue.add(SwitchOdometerMetricAction:new(self.playerNum, true))
            end)
        else
            --- Toggle imperial
            odometerContext:addOption(getText("ContextMenu_Use_Imperial"), nil, function()
                ISTimedActionQueue.add(SwitchOdometerMetricAction:new(self.playerNum, false))
            end)
        end

        --- Toggle trip odometer
        odometerContext:addOption(getText(modData.showTripOdometer and getText("ContextMenu_Hide_Trip_Odometer") or getText("ContextMenu_Show_Trip_Odometer")), nil, function()
            ISTimedActionQueue.add(ToggleTripOdometerAction:new(self.playerNum))
        end)

        if modData.showTripOdometer then
            --- Reset trip odometer
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = getText("Tooltip_Reset_Trip_Odometer")
            local option = odometerContext:addOption(getText("ContextMenu_Reset_Trip_Odometer"), self.vehicle, function()
                ISTimedActionQueue.add(ResetTripOdometerAction:new(self.playerNum))
            end)
            option.tooltip = tooltip
        end

        odometerContext:setVisible(true)
        odometerContext.mouseOver = 1
        setJoypadFocus(self.playerNum, odometerContext)
    end
end

--- Preload textures
local function onGameStart()
	local textures = {}
    textures.odometerTexture = getTexture("media/ui/vehicles/vehicle_odometer.png")
end
Events.OnGameStart.Add(onGameStart)

--- Remove context menu when exiting vehicle
local function onExitVehicle()
    if odometerContext then
        odometerContext:setVisible(false)
        odometerContext = nil
    end
end
Events.OnExitVehicle.Add(onExitVehicle)
