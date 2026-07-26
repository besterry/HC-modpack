require "Vehicles/ISUI/ISVehicleMenu"

itemGPSmod = itemGPSmod or {}

local function findChargeableGPS(player)
	if itemGPSmod.PlugedGps and player:getInventory():contains(itemGPSmod.PlugedGps) then
		return itemGPSmod.PlugedGps
	end
	local toolP = player:getPrimaryHandItem()
	if toolP and toolP:hasTag("GPSmod") then return toolP end
	local toolS = player:getSecondaryHandItem()
	if toolS and toolS:hasTag("GPSmod") then return toolS end
	if itemGPSmod.gps and itemGPSmod.gps:hasTag("GPSmod") and player:getInventory():contains(itemGPSmod.gps) then
		return itemGPSmod.gps
	end
	local attached = player:getAttachedItems()
	if attached then
		for i = 0, attached:size() - 1 do
			local item = attached:getItemByIndex(i)
			if item and item:hasTag("GPSmod") then return item end
		end
	end
	return player:getInventory():getFirstTagRecurse("GPSmod")
end

local function gpsTexture(gps)
	if gps and gps:getTex() then return gps:getTex() end
	return getTexture("media/ui/GPSdayz_Cable.png")
end

function itemGPSmod.addVehicleRadialSlices(player)
	if not player or player:isDead() then return end
	local vehicle = player:getVehicle()
	if not vehicle then return end
	local seat = vehicle:getSeat(player)
	if seat == nil or seat > 1 then return end

	local menu = getPlayerRadialMenu(player:getPlayerNum())
	if not menu then return end

	local gps = findChargeableGPS(player)
	if not gps then return end

	local cable = itemGPSmod.findGPScable(player, vehicle)
	local tex = gpsTexture(gps)

	if itemGPSmod.PlugedGps and itemGPSmod.PlugedGps == gps then
		menu:addSlice(getText("IGUI_unPlug"), tex, itemGPSmod.GPS_UnPlug, player, gps)
		return
	end

	if itemGPSmod.PlugedGps and player:getInventory():contains(itemGPSmod.PlugedGps) then
		menu:addSlice(getText("IGUI_unPlug"), gpsTexture(itemGPSmod.PlugedGps), itemGPSmod.GPS_UnPlug, player, itemGPSmod.PlugedGps)
		return
	end

	local bat = gps:getUsedDelta()
	if bat == 0 then
		menu:addSlice(getText("IGUI_noBattery"), tex, nil)
		return
	end
	if not cable then
		menu:addSlice(getText("IGUI_itemGPS_radialNeedCable"), tex, nil)
		return
	end
	if bat >= 1 then
		menu:addSlice(getText("IGUI_itemGPS_radialFull"), tex, nil)
		return
	end

	local pct = string.format("%.0f", bat * 100)
	menu:addSlice(getText("IGUI_Plug") .. " (" .. pct .. "%)", tex, itemGPSmod.GPS_plug, player, gps)
end

local old_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu
function ISVehicleMenu.showRadialMenu(playerObj)
	old_ISVehicleMenu_showRadialMenu(playerObj)
	itemGPSmod.addVehicleRadialSlices(playerObj)
end
