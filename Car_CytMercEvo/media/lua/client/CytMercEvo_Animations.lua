-- Huge thanks to Dislaik for creating this method, you should him out: https://steamcommunity.com/sharedfiles/filedetails/?id=2728300240

local function CytMercEvo_Enter(player)
	local vehicle = player:getVehicle()
	if not vehicle then return end
    local vehicleName = vehicle:getScriptName()
    local seat = vehicle:getSeat(player)
    if not seat then return end
	if seat == 0 and vehicleName:contains("Base.CytMercEvo") then				
		player:SetVariable("VehicleScriptName", "Bob_IdleDriver")
		return
	end
	if seat == 1 and vehicleName:contains("Base.CytMercEvo") then
		player:SetVariable("VehicleScriptName", "Bob_IdlePassenger")
		return
	end
end

function CytMercEvo_Enter_Server(player)
	CytMercEvo_Enter(player)
end

local function CytMercEvo_Exit(player)
    sendClientCommand(player, "CytMercEvo", "PlayerExit", {})
    player:SetVariable("VehicleScriptName", "")
end

Events.OnEnterVehicle.Add(CytMercEvo_Enter)
Events.OnExitVehicle.Add(CytMercEvo_Exit)
Events.OnSwitchVehicleSeat.Add(CytMercEvo_Enter)