DreamsWindow = ISCollapsableWindow:derive("DreamsWindow");
DreamsWindow.compassLines = {}

function DreamsWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function DreamsWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = getText("IGUI_Dreams_Window");
	o.backgroundColor.a = 0.25
	--o.pin = false;
	--o:noBackground();
	return o;
end

local DreamWindowHeight = 275;

function DreamsWindow:setText(newText)
	DreamsWindow.HomeWindow.text = newText;
	DreamsWindow.HomeWindow:paginate();
	
	local tempTexture = getTexture("media/textures/dreams/dreams.png")
	if (tempTexture) then self.Image:setImage(tempTexture) 
	else self.Image:setImage(getTexture("media/textures/dreams/dreams.png")) end
end


function DreamsWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	
	self.Image = ISButton:new(10, 25, 240, 240, " ", nil, nil);
	self.Image:setImage(getTexture("media/textures/dreams/dreams.png"))
	self.Image:setVisible(true);
	self.Image:setEnable(true);
	--self.Image:addToUIManager();
	self:addChild(self.Image)
	
	self.HomeWindow = ISRichTextPanel:new(260, 25, 340, 240);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow.marginRight = 17
	self.HomeWindow.clip = true
	self.HomeWindow.backgroundColor.a = 0.25
	--self.HomeWindow:ignoreHeightChange() -- DreamsWindow.HomeWindow:setHeight(100)
	self.HomeWindow:addScrollBars()
	self:addChild(self.HomeWindow)
end

function DreamsWindowCreate()
	DreamsWindow = DreamsWindow:new(50, 450, 610, DreamWindowHeight) -- x, y, width, height
	DreamsWindow:addToUIManager();
	DreamsWindow:setVisible(false);
	--DreamsWindow.pin = false;
	DreamsWindow.resizable = false;
end

Events.OnGameStart.Add(DreamsWindowCreate);