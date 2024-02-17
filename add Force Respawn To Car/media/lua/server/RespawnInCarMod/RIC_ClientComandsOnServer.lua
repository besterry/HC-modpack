if isClient() then return end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RICserver = require("RespawnInCarMod/RIC_ServerFunctions")
RICserver.ClientCommand = {}
local seatNameMD = "serverForceRespawn_playerName"
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																									--CLIENT COMMANDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.OnClientCommand(module,command,player,arguments)
	if module ~= "RespawnINcar" then return end
	local name = arguments[#arguments]
	RICserver.DATA.RIC_PLAYERS_POS = RICserver.DATA.RIC_PLAYERS_POS or {}
	RICserver.ClientCommand[command](player,name,command,arguments)
	--print("TEST.... OnClientCommand: " ..command)
end
-----------------------------------------------------	
Events.OnClientCommand.Add(RICserver.OnClientCommand)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																									--FUNCTIONS COMMANDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
function RICserver.ClientCommand.PreTeleportPlayer(player,name,command)
	local userData = RICserver.DATA.RIC_PLAYERS_POS[name] or {}
	if userData[4] and type(userData[4]) == "number" then 
		RICserver.SearchCarToSavePlayer(player,name,true)			
	end
	RICserver.SendServerCommand(player,command,userData)
	--print("TEST.... send client finished...")
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.SavePlayer(player,name,command,arguments)
	local type = arguments[1]
	RICserver[command](player,name,type)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.SaveVehicle(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	RICserver["Pre"..command](vehicle,vDATA,vehicleNUM,maxSeat)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.CarEnter(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	--print("TEST.... RICserver.ClientCommand.CarEnter")
	local userData = RICserver.DATA.RIC_PLAYERS_POS[name]
	if userData and userData[4] then
		local allowed = arguments[2] == true or (type(userData[4]) == "number" and userData[4] == vehicleNUM)
		if not allowed then  
			RICserver.SendServerCommand(player,"ForceExitCar",{})
			return 
		end
	end
	local allReady, freeSeat = RICserver.PreSavePlayers(vehicle,vDATA,vehicleNUM,maxSeat,name) 
	if allReady then
		-- true because player is allready saved in car
	elseif freeSeat then 
		vDATA[seatNameMD..freeSeat] = name
		RICserver.SavePlayer(vehicle,name,vehicleNUM)	
	else
		RICserver.SendServerCommand(player,"OverSeatTaked",{})
		RICserver.SavePlayer(vehicle,name,false)
		return
	end
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.CarExit(player,name,command,arguments)
	local id = arguments[1]
	local dead = arguments[2] == true
	local myCar
	if id ~= -1 then
		local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(id)
		if vehicle then
			if RICserver.DATA.RIC_PLAYERS_POS[name] and RICserver.DATA.RIC_PLAYERS_POS[name][4] == vehicleNUM then
				--print("TEST.... RICserver.ClientCommand.CarExit  myCar")
				RICserver[command](vehicle,vDATA,vehicleNUM,maxSeat,name)
				myCar = true
			else
				RICserver.RedefineVehicleNamelist(vDATA,vehicleNUM,maxSeat)
			end
		end
	end
	if not myCar then 
		--print("TEST.... RICserver.ClientCommand.CarExit  not myCar")
		RICserver.SearchCarToSavePlayer(player,name,false) 
	end
	if dead then RICserver.DATA.RIC_PLAYERS_POS[name] = nil return end
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.CheckPlayersNames(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1])
	if not vehicle then return end
	RICserver.RedefineVehicleNamelist(vDATA,vehicleNUM,maxSeat)
	local args = {}
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local seatName = vDATA[seatNameMD..counter] or "   -"
		table.insert(args,seatName) 
	end	
	RICserver.SendServerCommand(player,command,args)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.ExpulsePlayer(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1])
	if not vehicle then return end
	local numSeat = arguments[2]
	local nameSeat 
	if numSeat then nameSeat = vDATA[seatNameMD..numSeat] end
	RICserver["Pre"..command](vehicle,vDATA,vehicleNUM,maxSeat,player,name,nameSeat,command)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.GetExpulseMenu(player,name,command,arguments)
    local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	RICserver.RedefineVehicleNamelist(vDATA,vehicleNUM,maxSeat)
	local args = {}
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local seatName = vDATA[seatNameMD..counter] or "   -"
		table.insert(args,seatName)
	end
	table.insert(args,arguments[1])
	RICserver.SendServerCommand(player,command,args)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--																				FUNCTIONS COMMANDS ADMIN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.ClientCommand.ExpulsePlayersFromVehicle(nplayer,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	RICserver["Pre"..command](vehicle,vDATA,vehicleNUM,maxSeat,player,name,"ExpulsePlayer")
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.RedefineVehicleNamelist(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	RICserver[command](vDATA,vehicleNUM,maxSeat)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.ResetPlayerListFromVehicle(player,name,command,arguments)
	local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local name = vDATA[seatNameMD..counter]  
		if name then 
			RICserver.SavePlayer(player,name,false) 
			vDATA[seatNameMD..counter]  = nil 
		end
	end
	local command = "SayText"
	local args = {"This vehicle is reseted"}
	RICserver.SendServerCommand(player,command,args)
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.VehicleNumberRef(player,name,command,arguments)
    local vehicle,vDATA,vehicleNUM = RICserver.GetVehicleData(arguments[1],command)
	if not vehicle then return end
	local command = "SayText"
	local args = {"Vehicle number "..tostring(vehicleNUM)}
	RICserver.SendServerCommand(player,command,args)
end

function RICserver.ClientCommand.RemovePlayerIsNotRespawn()
	RICserver.ModDataTest()
	for i,v in pairs(RICserver.DATA.RIC_PLAYERS_POS) do
		if not v[4] then--or type(v[4]) ~= "number" then
			RICserver.DATA.RIC_PLAYERS_POS[tostring(i)] = nil
		end
	end
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.ResetModData()
	RICserver.DATA.RIC_PLAYERS_POS = nil
	--print("............ RIC mod INFO: ModData of RIC is reseted | player list is reset to zero")
end
----------------------------------------------------------------------------------
function RICserver.ClientCommand.PrintInfos()
	RICserver.ModDataTest()
	print("--------------------- Players in car:")
	local modData = getGameTime():getModData()
	if modData.RIC_PLAYERS_POS then
		for _,v in pairs(RICserver.DATA.RIC_PLAYERS_POS) do
			if v[4] ~= false and v[4] ~= nil then
				print(tostring(_).." "..tostring(v[4]))
			end
		end
	end
	print("---------------- END ----------------")
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return RICserver
