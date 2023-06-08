-------------------------------------------------
-------------------------------------------------
--
-- ISAddSHUI
--
-------------------------------------------------
-------------------------------------------------
require "ISUI/ISPanel"
require "ISUI/ISLayoutManager"
require "ISUI/UserPanel/ISUserPanelUI_New"
-------------------------------------------------
-------------------------------------------------
ISAddSHUI = ISPanel:derive("ISAddSHUI");
ISAddSHUI.instance = nil;
MaxSizeSH = 625;
-------------------------------------------------
--Подсветка зоны при создании привата
-------------------------------------------------
function ISAddSHUI:highlightZone(_x1, _x2, _y1, _y2, _fullHighlight)
	local r = (self.notIntersecting and 0.4) or 1;
	local g = (self.notIntersecting and 1) or 0;
	local b = (self.notIntersecting and 1) or 0;
	local a = 0.9;
	if _fullHighlight then
		for xVal = _x1, _x2 do
			for yVal = _y1, _y2 do
				local sqObj = getCell():getOrCreateGridSquare(xVal,yVal,0);
				if sqObj then
					for n = 0,sqObj:getObjects():size()-1 do
						local obj = sqObj:getObjects():get(n);
						obj:setHighlighted(true);
						obj:setHighlightColor(r,g,b,a);
					end;
				end;
			end;
		end;
	else
		for xVal = _x1, _x2 do
			local yVal1 = _y1;
			local yVal2 = _y2;
			local sqObj1 = getCell():getOrCreateGridSquare(xVal,yVal1,0);
			local sqObj2 = getCell():getOrCreateGridSquare(xVal,yVal2,0);
			if sqObj1 then
				for n = 0,sqObj1:getObjects():size()-1 do
					local obj = sqObj1:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end;
			end;
			if sqObj2 then
				for n = 0,sqObj2:getObjects():size()-1 do
					local obj = sqObj2:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end;
			end;
		end;
		for yVal = _y1, _y2 do
			local xVal1 = _x1;
			local xVal2 = _x2;
			local sqObj1 = getCell():getOrCreateGridSquare(xVal1,yVal,0);
			local sqObj2 = getCell():getOrCreateGridSquare(xVal2,yVal,0);
			if sqObj1 then
				for n = 0,sqObj1:getObjects():size()-1 do
					local obj = sqObj1:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end;
			end;
			if sqObj2 then
				for n = 0,sqObj2:getObjects():size()-1 do
					local obj = sqObj2:getObjects():get(n);
					obj:setHighlighted(true);
					obj:setHighlightColor(r,g,b,a);
				end;
			end;
		end;
	end;
end
-------------------------------------------------
--Создание убежища
-------------------------------------------------
local function setSafehouseData(_title, _owner, _x, _y, _w, _h)
	local playerObj = getSpecificPlayer(0);
	local safeObj = SafeHouse.addSafeHouse(_x, _y, _w, _h, _owner, false);
	safeObj:setTitle(_title);
	safeObj:setOwner(_owner);
	safeObj:updateSafehouse(playerObj);
	safeObj:syncSafehouse();
end
-------------------------------------------------
--Проверка пересечения с другими убежищами
-------------------------------------------------
function ISAddSHUI:checkIfIntersectingAnotherZone()
	self.notIntersecting = true;
	for xVal = self.X1-3, self.X2+3 do
		for yVal = self.Y1-3, self.Y2+3 do
			local sqObj = getCell():getOrCreateGridSquare(xVal,yVal,0);
			if sqObj then
				if SafeHouse.getSafeHouse(sqObj) then
					self.notIntersecting = false;
				end;
			end;
		end;
	end;
	if self.notIntersecting then
        self.ok.tooltip = nil; -- Очищаем tooltip
    else
        self.ok.tooltip = getText("IGUI_CreateSH_Intersecting");
    end
end
-------------------------------------------------
--Проверка на запрещенные комнаты
-------------------------------------------------
--restaurant,laundry,grocery,farmstorage,storage,bar,warehouse,storageunit,mechanic,clothingstore,jayschicken_dining,bakery,zippeestore,
function ISAddSHUI:checkIfIntersectingAnotherZone()
	self.notIntersecting = true;
	for xVal = self.X1-3, self.X2+3 do
		for yVal = self.Y1-3, self.Y2+3 do
			local sqObj = getCell():getOrCreateGridSquare(xVal,yVal,0);
			if sqObj then
				if rooms:get(sqObj):getName() == "zippeestore" then
					self.notIntersecting = false;
				end;
			end;
		end;
	end;
	if self.notIntersecting then
        self.ok.tooltip = nil; -- Очищаем tooltip
    else
        self.ok.tooltip = getText("IGUI_CreateSH_Intersecting");
    end
end
-------------------------------------------------
--Обновление кнопки "Создать убежище"
-------------------------------------------------
function ISAddSHUI:updateButtons()
	self.ok.enable = self.size > 1
					--and string.trim(self.ownerEntry:getInternalText()) ~= ""
					and string.trim(self.titleEntry:getInternalText()) ~= ""
					and self.notIntersecting
					--and self.character:getAccessLevel() == "Admin";
end
-------------------------------------------------
--Отрисовка окна создания убежища
-------------------------------------------------
function ISAddSHUI:prerender()
	local z = 10;
	local splitPoint = self.width / 2;
	local x = 10;
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	self:drawText(getText("IGUI_SafeHouse_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_SafeHouse_Title")) / 2), z, 1,1,1,1, UIFont.Medium);

	z = z + 30;
	self:drawText(getText("IGUI_SafehouseUI_Titles"), x, z,1,1,1,1,UIFont.Small);
	self.titleEntry:setY(z + 3);
	self.titleEntry:setX(splitPoint);
	self.titleEntry:setWidth(splitPoint - 10);
	z = z + 30;

	--Описание	
	self:drawText(getText("IGUI_Description1_SafeHouses"), x, z,1,1,1,1,UIFont.Small);
	z = z + 15;
	self:drawText(getText("IGUI_Description2_SafeHouses"), x, z,1,1,1,1,UIFont.Small);
	z = z + 15;
	self:drawText(getText("IGUI_Description3_SafeHouses"), x, z,1,1,0,1,UIFont.Small);
	z = z + 30;

	--Надпись максимальный размер убежки	
	self:drawText(getText("IGUI_MaxSize_SafeHouses"), x, z,1,1,1,1,UIFont.Small);
	self:drawText(tostring(MaxSizeSH), splitPoint, z, 1,1,1,1, UIFont.Small);
	z = z + 30;

	local startingX = math.floor(self.startingX);
	local startingY = math.floor(self.startingY);
	local endX = math.floor(self.character:getX());
	local endY = math.floor(self.character:getY());

	if startingX > endX then
		local x2 = endX;
		endX = startingX;
		startingX = x2;
	end
	if startingY > endY then
		local y2 = endY;
		endY = startingY;
		startingY = y2;
	end

	local bwidth = math.abs(startingX - endX) * 2;
	local bheight = math.abs(startingY - endY) * 2;
	self.zonewidth = math.abs(startingX - endX);
	self.zoneheight = math.abs(startingY - endY);

	self:drawText(getText("IGUI_PvpZone_CurrentZoneSizes"), x, z,1,1,1,1,UIFont.Small);
	self.size = math.floor(self.zonewidth * self.zoneheight);
	if self.size > MaxSizeSH then
        self:drawText(self.size .. "", splitPoint, z, 1, 0, 0, 1, UIFont.Small) -- Устанавливаем красный цвет текста
    else
        self:drawText(self.size .. "", splitPoint, z, 1, 1, 1, 1, UIFont.Small) -- Используем стандартный цвет текста
    end
	z = z + 30;

	self:drawText(getText("IGUI_Position_SafeHouses"), x, z,1,1,1,1,UIFont.Small);
	self:drawText("X1: " .. self.X1 .. "     Y1: " .. self.Y1, splitPoint, z, 1,1,1,1, UIFont.Small);
	z = z + 30;
	self:drawText("X2: " .. self.X2 .. "     Y2: " .. self.Y2, splitPoint, z, 1,1,1,1, UIFont.Small);
	z = z + 30;

	self:highlightZone(startingX, endX, startingY, endY, self.fullHighlight)

	self.X1, self.Y1 = startingX, startingY;
	self.X2, self.Y2 = endX, endY;

	self:checkIfIntersectingAnotherZone();
	self:updateButtons();
end
-------------------------------------------------
--Инициализация окна создания убежища
-------------------------------------------------
function ISAddSHUI:initialise()
	ISPanel.initialise(self);
	--if self.character:getAccessLevel() ~= "Admin" then self:close(); return; end;

	local btnWid = 100
	local btnHgt = 25
	local btnHgt2 = 18
	local padBottom = 10

	btnWid = 100;
	self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISAddSHUI.onClick);
	self.cancel.internal = "CANCEL";
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.cancel);

	btnWid = 100;
	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_AddSafeHouses"), self, ISAddSHUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
	self:addChild(self.ok);

	self.titleEntry = ISTextEntryBox:new("Safezone #" .. SafeHouse.getSafehouseList():size() + 1, 10, 10, 200, 18);
	self.titleEntry:initialise();
	self.titleEntry:instantiate();
	self:addChild(self.titleEntry);


	self.claimOptions = ISTickBox:new(10, 270, 20, 18, "", self, ISAddSHUI.onClickClaimOptions);
	self.claimOptions:initialise();
	self.claimOptions:instantiate();
	self.claimOptions.selected[1] = false;
	self.claimOptions.selected[2] = true;
	self.claimOptions.selected[3] = true;
	self.claimOptions:addOption(getText("IGUI_Safezone_FullHighlight"));

	self:addChild(self.claimOptions);
end

-------------------------------------------------
--Переопределение начальной точки
-------------------------------------------------
function ISAddSHUI:redefineStartingPoint()
	local character = self.character;
	self.startingX = character:getX();
	self.startingY = character:getY();
	self.X1 = character:getX();
	self.Y1 = character:getY();
	self.X2 = character:getX();
	self.Y2 = character:getY();
end

-------------------------------------------------
--Опции при нажатии чекбоксе "Подсветить"
-------------------------------------------------
function ISAddSHUI:onClickClaimOptions(_clickedOption, _ticked)
	if _clickedOption == 1 then
		self.fullHighlight = _ticked;
	end;
end

-------------------------------------------------
--События при нажатии кнопок в окне создания убежища
-------------------------------------------------
function ISAddSHUI:onClick(button)
	if button.internal == "OK" then
		self.creatingZone = false;		
		local setX = math.floor(math.min(self.X1, self.X2));
		local setY = math.floor(math.min(self.Y1, self.Y2));
		local setW = math.floor(math.abs(self.X1 - self.X2) + 1);
		local setH = math.floor(math.abs(self.Y1 - self.Y2) + 1);		
		--Проверка города
		local x = math.floor((getPlayer():getX()) / 100)
		local y = math.floor((getPlayer():getY()) / 100)
		if FDSE.checkTownZones(x, y) then
			getPlayer():Say(getText('IGUI_Close_Zone'))
			return;
		end

		--Проверка на максимальный размер привата
		if self.size > MaxSizeSH then
			getPlayer():Say(getText('IGUI_Big_Size_SH'))
			return;
		else
			self:setVisible(false);
			self:removeFromUIManager()
			setSafehouseData(self.titleEntry:getInternalText(), self.character:getUsername(), setX, setY, setW, setH)
			return;
		end		
	end

	if button.internal == "CANCEL" then
		self.creatingZone = false;
		self:setVisible(false);
		self:removeFromUIManager();
		return;
	end;
end
-------------------------------------------------
--Создания окна "Создание убежища"
-------------------------------------------------
function ISAddSHUI:new(x, y, width, height, character)
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.width = width;
	o.height = height;
	o.character = character;
	o.startingX = character:getX();
	o.startingY = character:getY();
	o.X1 = character:getX();
	o.Y1 = character:getY();
	o.X2 = character:getX();
	o.Y2 = character:getY();
	o.moveWithMouse = true;
	o.creatingZone = false;
	o.fullHighlight = false;
	o.notIntersecting = true;
	ISAddSHUI.instance = o;
	o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
	return o;
end
-------------------------------------------------
-------------------------------------------------