-- Admin-only permanent street light (no power, no fuel drain, no dismantle/pickup).

ISPermanentLight = ISBuildingObject:derive("ISPermanentLight")

function ISPermanentLight:create(x, y, z, north, sprite)
	local cell = getWorld():getCell()
	self.sq = cell:getGridSquare(x, y, z)
	self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self)
	buildUtil.setInfo(self.javaObject, self)

	local offsetX = 0
	local offsetY = 0
	if self.east then
		offsetX = self.offsetX
	elseif self.west then
		offsetX = -self.offsetX
	elseif self.south then
		offsetY = self.offsetY
	elseif self.north then
		offsetY = -self.offsetY
	end

	self.javaObject:createLightSource(self.radius, offsetX, offsetY, 0, 0, "Base.Battery", nil, nil)
	self.javaObject:setHaveFuel(true)
	self.javaObject:setLifeLeft(1.0)
	self.javaObject:setLifeDelta(0.0)
	self.javaObject:toggleLightSource(true)

	self.javaObject:setMaxHealth(self:getHealth())
	self.javaObject:setHealth(self.javaObject:getMaxHealth())
	self.javaObject:setBreakSound("BreakObject")

	self.sq:AddSpecialObject(self.javaObject)
	self.javaObject:transmitCompleteItemToServer()
end

function ISPermanentLight:new(sprite, northSprite, player)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o:setSprite(sprite)
	o:setNorthSprite(northSprite)
	o.canBarricade = false
	o.dismantable = false
	o.isThumpable = false
	o.noNeedHammer = true
	o.character = player
	o.name = "Hydro Permanent Light"
	o.blockAllTheSquare = true
	o.offsetX = 5
	o.offsetY = 5
	o.radius = 12
	o.modData.HydroPermanentLight = true
	if player then
		o.modData.Builder = player:getUsername()
		o.modData.Date = os.date("%d/%m/%Y")
	end
	return o
end

function ISPermanentLight:getHealth()
	return 5000
end

function ISPermanentLight:haveMaterial(square)
	return true
end

function ISPermanentLight:isValid(square)
	if buildUtil.stairIsBlockingPlacement(square, true) then return false end
	if square:isVehicleIntersecting() then return false end
	return square:isFree(true)
end

function ISPermanentLight:render(x, y, z, square)
	ISBuildingObject.render(self, x, y, z, square)
end
