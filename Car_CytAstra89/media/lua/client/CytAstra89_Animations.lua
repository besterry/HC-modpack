-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function CytAstra89_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.CytVAstraHB") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.CytVAstraHB") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function CytAstra89_Enter_Server(player)
	CytAstra89_Enter(player)
end

local function CytAstra89_Exit(player)
    sendClientCommand(player, "CytVAstraHB", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(CytAstra89_Enter)
Events.OnExitVehicle.Add(CytAstra89_Exit)
Events.OnSwitchVehicleSeat.Add(CytAstra89_Enter)