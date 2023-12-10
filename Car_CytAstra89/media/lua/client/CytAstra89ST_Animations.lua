-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function CytAstra89ST_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.CytVST5DAstra") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.CytVST5DAstra") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function CytAstra89ST_Enter_Server(player)
	CytAstra89ST_Enter(player)
end

local function CytAstra89ST_Exit(player)
    sendClientCommand(player, "CytVST5DAstra", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(CytAstra89ST_Enter)
Events.OnExitVehicle.Add(CytAstra89ST_Exit)
Events.OnSwitchVehicleSeat.Add(CytAstra89ST_Enter)