-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function DeathMstang_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.DeathMstang") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.DeathMstang") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function DeathMstang_Enter_Server(player)
	DeathMstang_Enter(player)
end

local function DeathMstang_Exit(player)
    sendClientCommand(player, "DeathMstang", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(DeathMstang_Enter)
Events.OnExitVehicle.Add(DeathMstang_Exit)
Events.OnSwitchVehicleSeat.Add(DeathMstang_Enter)