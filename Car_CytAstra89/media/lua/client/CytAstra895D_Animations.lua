-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function CytAstra895D_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.CytVHB5DAstra") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.CytVHB5DAstra") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function CytAstra895D_Enter_Server(player)
	CytAstra895D_Enter(player)
end

local function CytAstra895D_Exit(player)
    sendClientCommand(player, "CytVHB5DAstra", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(CytAstra895D_Enter)
Events.OnExitVehicle.Add(CytAstra895D_Exit)
Events.OnSwitchVehicleSeat.Add(CytAstra895D_Enter)