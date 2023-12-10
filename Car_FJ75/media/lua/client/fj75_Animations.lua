-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function FJ75PC_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.FJ75PC") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.FJ75PC") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function FJ75PC_Enter_Server(player)
	FJ75PC_Enter(player)
end

local function FJ75PC_Exit(player)
    sendClientCommand(player, "FJ75PC", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(FJ75PC_Enter)
Events.OnExitVehicle.Add(FJ75PC_Exit)
Events.OnSwitchVehicleSeat.Add(FJ75PC_Enter)