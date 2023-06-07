require "TimedActions/ISReadABook"

local MIN_LIGHT = 127
--[[ light in room (without windows, door is closed, no light-source)
					01:00	13:00
with NightVision	48		99
no NightVision		35		103
]]

local function getPlayerLight(Player)
	local player_id = Player:getPlayerNum()
	local square = Player:getCurrentSquare()
	local colors = {
		square:getVertLight(0, player_id),
		square:getVertLight(1, player_id),
		square:getVertLight(2, player_id),
		square:getVertLight(3, player_id),
		square:getVertLight(4, player_id),
		square:getVertLight(5, player_id),
		square:getVertLight(6, player_id),
		square:getVertLight(7, player_id),
	}
	local light = 0
	
	for i, color in ipairs(colors) do
		local hex_str = string.format("%x", color) -- exaple: "ffa1b2c3"
		light = math.max(
			tonumber(string.sub(hex_str, 3, 4), 16) or 0, -- "a1"
			tonumber(string.sub(hex_str, 5, 6), 16) or 0, -- "b2"
			tonumber(string.sub(hex_str, 7, 8), 16) or 0, -- "c3"
			light
		)
	end
	
	return light
end

local function inVehicleLigth(Player)
	local vehicle = Player:getVehicle()
	if vehicle ~= nil and vehicle:getBatteryCharge() > 0 then
		return true
	else
		return false
	end
end

local inHandLigth = nil
if tonumber(string.match(getCore():getVersionNumber(), "%d+")) < 41 then
	--[[ create inHandLigth for b40
	version 40.x does not contain isEmittingLight() function
	but lighting on tile is more predictably,
	getPlayerLight() function is enough,
	and this function is just a plug
	]]
	inHandLigth = function(Player)
		return false
	end
else
	-- create inHandLigth for b41
	inHandLigth = function(Player)
		local rightHandItem = Player:getPrimaryHandItem()
		local leftHandItem = Player:getSecondaryHandItem()
		if (rightHandItem ~= nil and rightHandItem:isEmittingLight()) or (leftHandItem ~= nil and leftHandItem:isEmittingLight()) then
			return true
		else
			return false
		end
	end
end


local default_update = ISReadABook.update

function ISReadABook:update()
	local player = self.character
	if getPlayerLight(player) < MIN_LIGHT and inVehicleLigth(player) == false and inHandLigth(player) == false then
		self.character:Say(getText("IGUI_NRK_NeedLightToRead"))
		self:forceStop()
	end
	
	default_update(self)
end
