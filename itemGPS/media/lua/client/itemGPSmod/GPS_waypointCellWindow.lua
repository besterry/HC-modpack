--***********************************************************
--**              	  ROBERT JOHNSON                       **
--**            UI display with a question or text         **
--**          can display a yes/no button or ok btn        **
--***********************************************************

require "ISUI/ISPanelJoypad"

GPS_WaypointCell_window = ISPanelJoypad:derive("GPS_WaypointCell_window");


--************************************************************************--
--** GPS_WaypointCell_window:initialise
--**
--************************************************************************--

function GPS_WaypointCell_window:ApplyModData(player, device, waypointNbr, text, code)
    if text == "Set Cell X Coordinate" then
        local modData = device:getModData()
        --if waypointNbr == 1 then
            if device then device:getModData()["waypointGPS"..waypointNbr] = {code, 0} end--; if isClient() and device:getType() == "GPS_H800" then device:transmitCompleteItemToServer() end end
            local modal = GPS_WaypointCell_window:new(player, device, waypointNbr, "Set Cell Y Coordinate");
            modal:initialise();
            modal:addToUIManager();
        --elseif waypointNbr == 2 then
        --    if device then device:getModData()["waypointGPS2"] = {code, 0}end
        --    local modal = GPS_WaypointCell_window:new(player, device, waypointNbr, "Set Y Coordinate");
        --    modal:initialise();
        --    modal:addToUIManager();
        --end
    else
        local modData = device:getModData()
       --if waypointNbr == 1 then
            local x = modData["waypointGPS"..waypointNbr][1]
             if device then device:getModData()["waypointGPS"..waypointNbr] = {x, code} end--; if isClient() and device:getType() == "GPS_H800" then device:transmitCompleteItemToServer() end end
        --elseif waypointNbr == 2 then
        --    local x = modData["waypointGPS2"][1]
        --    if device then device:getModData()["waypointGPS2"] = {x, code}end
        --end
    end
    if itemGPSmod.gps and itemGPSmod.gps:getType() and getPlayer() then itemGPSmod.playSoundGPS(getPlayer(), itemGPSmod.gps:getType().."_Beep_toneUP") end
end

function GPS_WaypointCell_window:initialise()
	ISPanel.initialise(self);
    self.button1p = ISButton:new((self:getWidth() / 2) - 20, (self:getHeight() / 2) - 25, 16, 16, getText("^"), self, GPS_WaypointCell_window.onClick);
    self.button1p.internal = "B1PLUS";
    self.button1p:initialise();
    self.button1p:instantiate();
    self.button1p.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.button1p);

    self.number1 = ISTextEntryBox:new("0", self:getWidth() / 2 - 20, self:getHeight() / 2 -5, 18, 18);
    self.number1:initialise();
    self.number1:instantiate();
    self:addChild(self.number1);

    self.button1m = ISButton:new(self:getWidth() / 2 - 20, (self:getHeight() / 2) + 16, 16, 16, getText("v"), self, GPS_WaypointCell_window.onClick);
    self.button1m.internal = "B1MINUS";
    self.button1m:initialise();
    self.button1m:instantiate();
    self.button1m.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.button1m);

    --
    self.button2p = ISButton:new(self:getWidth() / 2 , (self:getHeight() / 2) - 25, 16, 16, getText("^"), self, GPS_WaypointCell_window.onClick);
    self.button2p.internal = "B2PLUS";
    self.button2p:initialise();
    self.button2p:instantiate();
    self.button2p.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.button2p);

    self.number2 = ISTextEntryBox:new("0", self:getWidth() / 2 , self:getHeight() / 2 -5, 18, 18);
    self.number2:initialise();
    self.number2:instantiate();
    self:addChild(self.number2);

    self.button2m = ISButton:new(self:getWidth() / 2 , (self:getHeight() / 2) + 16, 16, 16, getText("v"), self, GPS_WaypointCell_window.onClick);
    self.button2m.internal = "B2MINUS";
    self.button2m:initialise();
    self.button2m:instantiate();
    self.button2m.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.button2m);

    --
    self.ok = ISButton:new((self:getWidth() / 2) - 13, self:getHeight() - 20, 26, 15, getText("UI_Ok"), self, GPS_WaypointCell_window.onClick);
    self.ok.internal = "OK";
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    self:insertNewLineOfButtons(self.button1p, self.button2p, self.button3p, self.button4p, self.button5p)
    self:insertNewLineOfButtons(self.button1m, self.button2m, self.button3m, self.button4m, self.button5m)
    self:insertNewLineOfButtons(self.ok)
end

function GPS_WaypointCell_window:destroy()
	UIManager.setShowPausedMessage(true);
	self:setVisible(false);
	self:removeFromUIManager();
	if UIManager.getSpeedControls() then
		UIManager.getSpeedControls():SetCurrentGameSpeed(1);
	end
	self.code = self:getCode()
	self:ApplyModData(self.player, self.device, self.waypointNbr, self.text, self.code)
end

function GPS_WaypointCell_window:onClick(button)
	
    if button.internal == "OK" then
        self:destroy();
        if JoypadState.players[self.player+1] then
            setJoypadFocus(self.player, nil)
        end
    end
    self.gpsType = false
    if itemGPSmod.gps and itemGPSmod.gps:getType() then self.gpsType = itemGPSmod.gps:getType() end
    if button.internal == "B1PLUS" then
        self:increment(self.number1);
        if self.gpsType then itemGPSmod.playSoundGPS(getPlayer(), self.gpsType.."_Beep_toneMIDLE") end
    end
    if button.internal == "B1MINUS" then
        self:decrement(self.number1);
        if self.gpsType then itemGPSmod.playSoundGPS(getPlayer(), self.gpsType.."_Beep_toneDOWN") end
    end
    if button.internal == "B2PLUS" then
        self:increment(self.number2);
        if self.gpsType then itemGPSmod.playSoundGPS(getPlayer(), self.gpsType.."_Beep_toneMIDLE") end
    end
    if button.internal == "B2MINUS" then
        self:decrement(self.number2);
        if self.gpsType then itemGPSmod.playSoundGPS(getPlayer(), self.gpsType.."_Beep_toneDOWN") end
    end
end

function GPS_WaypointCell_window:increment(number)
    local newNumber = tonumber(number:getText()) + 1;
    if newNumber > 9 then
        newNumber = 0;
    end
    number:setText(newNumber .. "");
end

function GPS_WaypointCell_window:decrement(number)
    local newNumber = tonumber(number:getText()) - 1;
    if newNumber < 0 then
        newNumber = 9;
    end
    number:setText(newNumber .. "");
end

function GPS_WaypointCell_window:prerender()
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

        self:drawTextCentre(getText(self.text), self:getWidth()/2, 10, 1, 1, 1, 1, UIFont.Small);

end

--************************************************************************--
--** GPS_WaypointCell_window:render
--**
--************************************************************************--
--function GPS_WaypointCell_window:render()
--
--end
--
--function GPS_WaypointCell_window:update()
--    ISPanelJoypad.update(self)
--   -- if self.character:getX() ~= self.playerX or self.character:getY() ~= self.playerY then
--   --     self:destroy()
--   -- end
--end

function GPS_WaypointCell_window:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self.joypadIndexY = 1
	self.joypadIndex = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
end

function GPS_WaypointCell_window:onJoypadDown(button)
	ISPanelJoypad.onJoypadDown(self, button)
	if button == Joypad.BButton then
		self:onClick(self.ok)
	end
end

function GPS_WaypointCell_window:getCode()
    local n1 = tonumber(self.number1:getText()) * 10
	--print(tostring(n1))
    local n2 = tonumber(self.number2:getText()) 
	--print(tostring(n2))
    local n = ((n1 + n2)*300)-150 
    return n
end

--************************************************************************--
--** GPS_WaypointCell_window:new
--**
--************************************************************************--
function GPS_WaypointCell_window:new(player, device, waypointNbr, text)
	local x = 0
	local y = 0
	local width = 230
	local height = 120
	local o = {}
	o = ISPanelJoypad:new(x, y, width, height);
	setmetatable(o, self)
    self.__index = self
	local playerObj = player and getSpecificPlayer(0) or nil
	local player = getPlayer() 
    local playerNum = player:getPlayerNum()
    o.character = playerObj;
	o.name = nil;
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    if y == 0 then
		o.y = getPlayerScreenTop(playerNum) + (getPlayerScreenHeight(playerNum) - height) / 2
        o:setY(o.y)
    end
    if x == 0 then
		o.x = getPlayerScreenLeft(playerNum) + (getPlayerScreenWidth(playerNum) - width) / 2
        o:setX(o.x)
    end
	o.width = width;
	o.height = height;
	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;
	o.target = target;
	o.onclick = onclick;
    o.player = playerNum;
    o.playerX = getPlayer():getX()
    o.playerY = getPlayer():getY()
    o.new = new;
	o.code = nil
	o.text = text
	o.device = device
    o.waypointNbr = waypointNbr
    return o;
end
