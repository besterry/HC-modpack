
GPS_Recipe_code = {}
-- When creating item in result box of crafting panel.
function GPS_Recipe_code.GPSBatteryRemoval(items, result, player)
  for i=0, items:size()-1 do
	local item = items:get(i)
	-- we found the battery, we change his used delta according to the battery
	--if item:getType() == "GPSdayz" then
	if item:hasTag("GPSmod") and item:getUsedDelta() > 0 then
		result:setUsedDelta(item:getUsedDelta());
		-- then we empty the torch used delta (his energy)
		item:setUsedDelta(0);
		break
	end
  end
end
function GPS_Recipe_code.TestGPSBatteryRemoval (sourceItem, result)
	return sourceItem:hasTag("GPSmod") and sourceItem:getUsedDelta() > 0;
end
-- Return true if recipe is valid, false otherwise
function GPS_Recipe_code.TestGPSBatteryInsert(sourceItem, result)
	--if sourceItem:getType() == "GPSdayz" then
	if sourceItem:hasTag("GPSmod") then
		return sourceItem:getUsedDelta() == 0; -- Only allow the battery inserting if the flashlight has no battery left in it.
	end
	return true -- the battery
end

function GPS_Recipe_code.CreateGPSBatteryInsert(items, result, player)
	local batteryCharge = nil
	local gpsCharger
	for i=0, items:size()-1 do
	-- we found the battery, we change his used delta according to the battery
		if items:get(i):getType() == "Battery" then
			batteryCharge = items:get(i):getUsedDelta();
			result:setUsedDelta(batteryCharge);
			break
		end
  	end
end


function GPS_Recipe_code.DismantleGPS(items, result, player, selectedItem)
    local success = 50 + (player:getPerkLevel(Perks.Electricity)*5);
    if ZombRand(0,100)<success then
        player:getInventory():AddItem("Base.LightBulbGreen");
    end

    for i=1,ZombRand(1,4) do
        local r = ZombRand(1,4);
        if r==1 then
            player:getInventory():AddItem("Base.ElectronicsScrap");
        elseif r==2 then
            player:getInventory():AddItem("Radio.ElectricWire");
        elseif r==3 then
            player:getInventory():AddItem("Base.Aluminum");
        end
    end
    if ZombRand(0,100)<success then
        player:getInventory():AddItem("Base.LightBulb");
    end
    if ZombRand(0,100)<success then
        player:getInventory():AddItem("Radio.RadioReceiver");
    end
    for i=0,items:size()-1 do
        local item = items:get(i)
        --if item:getType() == "GPSdayz" then
        if item:hasTag("GPSmod") then
			if item:getUsedDelta() > 0 then
				local battery = player:getInventory():AddItem("Base.Battery")
				battery:setUsedDelta(item:getUsedDelta());
				break
			end
        end
    end
end
