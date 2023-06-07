
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                FUNCTIONS SERVER COMMANDS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ExitFromVehicle()
    local player = getSpecificPlayer(0)
    local square = player:getCurrentSquare()
    if not square then return end
    local vehicle = square:getVehicleContainer()

    if vehicle then 
        sendClientCommand("RespawnINcar_CarExit","true",{vehicle:getId()})
     --   print("ExitFromVehicle square container")
    else
        sendClientCommand("RespawnINcar_SearchCarToRemovePlayerInside","true",{}) 
     --   print("ExitFromVehicle cell to server")
    end
end
-------------------------------------------------------------------
-------------------------------------------------------------------
local RIC_TestInside_Counter = 0

local function OverTestInsideVehicle()
    if RIC_TestInside_Counter < 150 then RIC_TestInside_Counter = RIC_TestInside_Counter +1 return end
    local player = getPlayer()
    local vehicleInside = player:getVehicle()
    if not vehicleInside then sendClientCommand("RespawnINcar_OnStartGame","true",{}) end
 --   print("remove event OverTestInsideVehicle")
    Events.OnPlayerUpdate.Remove(OverTestInsideVehicle) 
end
-------------------------------------------------------------------
-------------------------------------------------------------------
local RIC_getSquare_Stat = false
local RIC_Respawn_Counter = 0

local function OnPlayerRespawncar(player)
   
    RIC_Respawn_Counter = RIC_Respawn_Counter +1
    if RIC_Respawn_Counter == 600 then
        ----------------------
        ExitFromVehicle()        
        ------------------------------------------------
        Events.OnPlayerUpdate.Remove(OnPlayerRespawncar) 
        ------------------------------------------------
     --   print("OnPlayerRespawncar Fail security")
        return
    end
    --------------------------------------------------------- ^ Security Fails ^ -----------------------------------------------------------------------------
    local square = player:getSquare()
    if square == nil and RIC_getSquare_Stat == false then return end
    if RIC_getSquare_Stat == false then 
        RIC_Respawn_Counter = 0
        RIC_getSquare_Stat = true 
    end  
    -----------------------------------------
    local plyName = player:getUsername()
    local vehicles=getCell():getVehicles()--getWorld():
         --------------------------------------
    for i=1,vehicles:size() do
        local vehicle = vehicles:get(i-1)
        local vehicleseat = vehicle:getModData().serverForceRespawn_TargetedVehicle_takedSEAT
        -----------------------------------------------------------
        if vehicleseat ~= nil and vehicleseat > 0 then  
            -----------------------------------
            local CheckName = false
            local vDATA = vehicle:getModData()
    
            if     vDATA.serverForceRespawn_playerName1  ~= nil and vDATA.serverForceRespawn_playerName1  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName2  ~= nil and vDATA.serverForceRespawn_playerName2  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName3  ~= nil and vDATA.serverForceRespawn_playerName3  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName4  ~= nil and vDATA.serverForceRespawn_playerName4  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName5  ~= nil and vDATA.serverForceRespawn_playerName5  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName6  ~= nil and vDATA.serverForceRespawn_playerName6  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName7  ~= nil and vDATA.serverForceRespawn_playerName7  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName8  ~= nil and vDATA.serverForceRespawn_playerName8  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName9  ~= nil and vDATA.serverForceRespawn_playerName9  == plyName then CheckName = true
            elseif vDATA.serverForceRespawn_playerName10 ~= nil and vDATA.serverForceRespawn_playerName10 == plyName then CheckName = true
            end
    
            if CheckName == true then

                for seat=vehicle:getMaxPassengers(),0, -1 do --seat=vehicle:getMaxPassengers(),0, -1 do
                    local doorPart = vehicle:getPassengerDoor(seat)
                    if not vehicle:isSeatOccupied(seat) and vehicle:isSeatInstalled(seat) and not vehicle:getCharacter(seat) and seat ~= -1 and doorPart then
                        vehicle:enter(seat, player) 
                        --print("car")
                        break
                    elseif vehicle:getScript():getFullName() == "Base.BoatSailingYacht" or vehicle:getScript():getFullName() == "Base.BoatSailingYacht_Ground" then  

                        if (not vehicle:isSeatOccupied(seat) and not vehicle:getCharacter(seat) and seat ~= -1) and (seat == 1 or seat == 0) then
                            vehicle:enter(seat, player)
                            --print("boatMotor") 
                            break
                        end
                    elseif vehicle:getScript():getFullName() == "Base.BoatMotor" or vehicle:getScript():getFullName() == "Base.BoatMotor_Ground" then  
                        if (not vehicle:isSeatOccupied(seat) and not vehicle:getCharacter(seat) and seat ~= -1) and (seat == 4 or seat == 5) then
                            vehicle:enter(seat, player)
                            --print("boatYatch") 
                            break
                        end
                    end
                end
                ---------------------------------------------------                
                local vehicleInside = player:getVehicle()
                if not vehicleInside then
                    ExitFromVehicle() 
                    --print("OnPlayerRespawncar fail force exit") 
                else
                    getSoundManager():PlayWorldSound("RIC_vehicleMove", player:getCurrentSquare(), 0, 10, 10.0, false);
                    sendClientCommand("RespawnINcar_saveVehiclePosition","true",{vehicleInside:getId()})
                    RIC_savedSquare = vehicleInside:getSquare()
                    ----------------------------------------------------------------------------------  
                    Events.OnPlayerUpdate.Add(OverTestInsideVehicle)
                    ----------------------------------------------------------------------------------   
                    --print("OnPlayerRespawncar good enter") 
                end
                ----------------------------------------------------------------------------------   
                Events.OnPlayerUpdate.Remove(OnPlayerRespawncar)
                ----------------------------------------------------------------------------------   
                return               
            end
        end  
    end
end
-------------------------------------------------------------------
-------------------------------------------------------------------
local function OnPlayerRespawnGround(player)
    local square = player:getSquare()
    if square == nil then return end
    getSoundManager():PlayWorldSound("RIC_respawnGround", player:getCurrentSquare(), 1, 25, 2, true)
    addSound(player, player:getX(), player:getY(), player:getZ(), 20, 50);
    sendClientCommand("RespawnINcar_NilPlayerPostion","true",{})
    Events.OnPlayerUpdate.Remove(OnPlayerRespawnGround) 
    --print("OnPlayerRespawnGround good floor")    
end
-------------------------------------------------------------------
-------------------------------------------------------------------
local RIC_CheckName_counter
local RIC_CheckName   

local RIC_Name1 
local RIC_Name2 
local RIC_Name3 
local RIC_Name4 
local RIC_Name5 
local RIC_Name6 
local RIC_Name7 
local RIC_Name8 
local RIC_Name9 
local RIC_Name10

local function playerName_process(player)
    
    local plyName = player:getUsername()
    if RIC_CheckName_counter == 0 then getSoundManager():PlayWorldSound("RIC_vehicleMove", player:getCurrentSquare(), 1, 25, 2, true) end
    if RIC_CheckName_counter then RIC_CheckName_counter = RIC_CheckName_counter +1 end
    ----------------------------------------------------------------------------------------------------
    if plyName ~= RIC_Name1  and RIC_CheckName_counter == 1   and RIC_Name1  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 1 " .. (RIC_Name1))  elseif RIC_CheckName_counter == 1   and  RIC_Name1  == nil then RIC_CheckName_counter = 39  end
    if plyName ~= RIC_Name2  and RIC_CheckName_counter == 40  and RIC_Name2  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 2 " .. (RIC_Name2))  elseif RIC_CheckName_counter == 40  and  RIC_Name2  == nil then RIC_CheckName_counter = 79  end
    if plyName ~= RIC_Name3  and RIC_CheckName_counter == 80  and RIC_Name3  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 3 " .. (RIC_Name3))  elseif RIC_CheckName_counter == 80  and  RIC_Name3  == nil then RIC_CheckName_counter = 119 end
    if plyName ~= RIC_Name4  and RIC_CheckName_counter == 120 and RIC_Name4  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 4 " .. (RIC_Name4))  elseif RIC_CheckName_counter == 120 and  RIC_Name4  == nil then RIC_CheckName_counter = 159 end
    if plyName ~= RIC_Name5  and RIC_CheckName_counter == 160 and RIC_Name5  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 5 " .. (RIC_Name5))  elseif RIC_CheckName_counter == 160 and  RIC_Name5  == nil then RIC_CheckName_counter = 199 end
    if plyName ~= RIC_Name6  and RIC_CheckName_counter == 200 and RIC_Name6  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 6 " .. (RIC_Name6))  elseif RIC_CheckName_counter == 200 and  RIC_Name6  == nil then RIC_CheckName_counter = 239 end
    if plyName ~= RIC_Name7  and RIC_CheckName_counter == 240 and RIC_Name7  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 7 " .. (RIC_Name7))  elseif RIC_CheckName_counter == 240 and  RIC_Name7  == nil then RIC_CheckName_counter = 279 end
    if plyName ~= RIC_Name8  and RIC_CheckName_counter == 280 and RIC_Name8  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 8 " .. (RIC_Name8))  elseif RIC_CheckName_counter == 280 and  RIC_Name8  == nil then RIC_CheckName_counter = 319 end
    if plyName ~= RIC_Name9  and RIC_CheckName_counter == 320 and RIC_Name9  ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 9 " .. (RIC_Name9))  elseif RIC_CheckName_counter == 320 and  RIC_Name9  == nil then RIC_CheckName_counter = 359 end
    if plyName ~= RIC_Name10 and RIC_CheckName_counter == 360 and RIC_Name10 ~= nil then RIC_CheckName = RIC_CheckName +1 ; player:Say("Seat 10 ".. (RIC_Name10)) elseif RIC_CheckName_counter == 360 and  RIC_Name10 == nil then RIC_CheckName_counter = 361 end
        
    if RIC_CheckName_counter == 361 then 

        if RIC_CheckName == 0 then player:Say("Just you! ") end
        -------------------------------------------------------------
        Events.OnPlayerUpdate.Remove(playerName_process) 
        -------------------------------------------------------------
    end
end
local function forceExitCar(player)
    local vehicleInside = player:getVehicle()
    local seat = vehicleInside:getSeat(player)
    vehicleInside:exit(player)
    vehicleInside:setCharacterPosition(player, seat, "outside")
    player:PlayAnim("Idle")
    vehicleInside:updateHasExtendOffsetForExitEnd(player)
    getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(nil)
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                           SERVER COMMANDS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RespawnINcar_OnServerCommand(module, command, arguments)

    local player=getPlayer()
    -------------------------------------------------------------------
    if 		module == "RespawnINcar_OverSeatTaked" 	then  
        if isAdmin() then return end   	
       																										player:Say("no more place!")    
        forceExitCar(player)
    -------------------------------------------------------------------
    elseif module == "RespawnINcar_forceExitCar"  then  
        if isAdmin() then return end    
        forceExitCar(player)
    -------------------------------------------------------------------
    elseif 	module == "RespawnINcar_placeDispo" 		then
        local vehicleInside = player:getVehicle()
    	if 	   arguments[1] == 0  then player:Say("0 passenger")               
    	elseif arguments[1] == 1  then player:Say("You are alone")             
    	elseif arguments[1] >= 2  then player:Say("You and " .. tostring(arguments[1]-1).." passenger(s)")
    	end
    -------------------------------------------------------------------
    elseif 	module == "RespawnINcar_OnStartGame" 	then
           
        if arguments[4] ~= true then
            RIC_TestInside_Counter = 0 
            if player:getVehicle() then
                Events.OnPlayerUpdate.Add(OverTestInsideVehicle)
                return 
            end
            RIC_Respawn_Counter = 0
            RIC_getSquare_Stat = false 
            -----------------------------------
            player:setX(arguments[1])
            player:setY(arguments[2])
            player:setZ(arguments[3])
            player:setLx(arguments[1])
            player:setLy(arguments[2])
            player:setLz(arguments[3])
            -----------------------------------
            Events.OnPlayerUpdate.Add(OnPlayerRespawncar)

        elseif arguments[4] == true then
            if player:getVehicle() then
                forceExitCar(player)
                ExitFromVehicle()
            end
            player:setX(arguments[1])
            player:setY(arguments[2])
            player:setZ(arguments[3])
            player:setLx(arguments[1])
            player:setLy(arguments[2])
            player:setLz(arguments[3])
            -----------------------------------
            Events.OnPlayerUpdate.Add(OnPlayerRespawnGround)
        end
    -------------------------------------------------------------------        
    elseif  module == "RespawnINcar_CheckName"   then  
        RIC_CheckName_counter = 0
        RIC_CheckName      = 0

        RIC_Name1    = arguments[1]
        RIC_Name2    = arguments[2]
        RIC_Name3    = arguments[3]
        RIC_Name4    = arguments[4]
        RIC_Name5    = arguments[5]
        RIC_Name6    = arguments[6]
        RIC_Name7    = arguments[7]
        RIC_Name8    = arguments[8]
        RIC_Name9    = arguments[9]
        RIC_Name10   = arguments[10]

        Events.OnPlayerUpdate.Add(playerName_process)
    -------------------------------------------------------------------
    elseif  module == "RespawnINcar_expulse_players"   	 then 		    player:Say("player: " .. tostring(arguments[1]) .. " is expulsed!")
    -------------------------------------------------------------------  
    elseif  module == "RespawnINcar_Text"                then           player:Say(tostring(arguments[1])) 
    -------------------------------------------------------------------  
    end
end
--------------------------------------------------------
Events.OnServerCommand.Add(RespawnINcar_OnServerCommand)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--						                                                                FUNCTIONS EVENTS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RIC_savedSquare
local function SaveVehicle(veh)
-------------------------------------------------------------------
	local vehSquare = veh:getSquare()
    if RIC_savedSquare and RIC_savedSquare == vehSquare then 
    	--print("this square is already saved") 
    	return 
    end
    RIC_savedSquare = vehSquare
    sendClientCommand("RespawnINcar_saveVehiclePosition","true",{veh:getId()})
    --print("VEHICULE IS SAVED")
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ToggleEscapeMenuForSave(key)
-------------------------------------------------------------------
    local mainMenuKey = getCore():getKey("Main Menu")
    if (key == mainMenuKey) or (mainMenuKey == 0 and key == Keyboard.KEY_ESCAPE) then--or key == getCore():getKey("StartVehicleEngine") then
        local player = getPlayer()
        if not player then return end
        local vehicle = player:getVehicle()
        if not vehicle or not vehicle:isDriver(player) then return end
        
        SaveVehicle(vehicle)
     --   print("saved by key")
    end
end
------------------------------------------------
Events.OnKeyPressed.Add(ToggleEscapeMenuForSave)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RIC_flag_saved = nil
local RIC_save_counter = 0
local function saveVehiclePositionLoop()
-------------------------------------------------------------------
    if RIC_save_counter < 80 then RIC_save_counter = RIC_save_counter+1 return end
    RIC_save_counter = 0
    local player = getPlayer()
    local vehicle = player:getVehicle()
    if vehicle and vehicle:isDriver(player) then
        local vSpeed = vehicle:getCurrentSpeedKmHour()
        if vSpeed ~= 0 then--vehicle:isEngineRunning() then if  math.floor(vehicle:getCurrentSpeedKmHour()) > 0 then
            if RIC_flag_saved == nil then 
                RIC_flag_saved = player:getCurrentSquare()
                --print("flag activate")
            end
            if RIC_flag_saved:DistTo(player) > 70 then  
                RIC_flag_saved = player:getCurrentSquare() 
                SaveVehicle(vehicle)
                --print("flag by distance save")  
            end
        elseif RIC_flag_saved ~= nil then 
            RIC_flag_saved = nil
            SaveVehicle(vehicle) 
            --print("stop Vehicle remove flag save")
        end
    else
        if vehicle then SaveVehicle(vehicle) end
        RIC_flag_saved = nil
        RIC_save_counter = 0
        Events.OnPlayerUpdate.Remove(saveVehiclePositionLoop)
        --print("remove loop save")
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function EnterCar()
-------------------------------------------------------------------
    local player = getPlayer()
    local vehicle = player:getVehicle()
    if vehicle then
    	sendClientCommand("RespawnINcar_EnterCar","true",{vehicle:getId()}) 
        if vehicle:isDriver(player) then
            Events.OnPlayerUpdate.Add(saveVehiclePositionLoop)
            --print("loop by enter") 
        end
        RIC_savedSquare = vehicle:getSquare()
        --print("enter vehicle")                                        
    end
end
------------------------------------------------
Events.OnEnterVehicle.Add(EnterCar)
---------------------------------------------------------------------------------------------------------------------------------------------------
local function CarExit()
---------------------------------------------------------------------------
ExitFromVehicle() 
RIC_savedSquare = nil
end
---------------------------------
Events.OnExitVehicle.Add(CarExit)
---------------------------------------------------------------------------------------------------------------------------------------------------
local function SwitchSeat()
---------------------------------------------------------------------------
    local player = getPlayer()
    local vehicle = player:getVehicle()
    if vehicle then
        if vehicle:isDriver(player) then
            SaveVehicle(vehicle)
            Events.OnPlayerUpdate.Add(saveVehiclePositionLoop)
            --print("loop by switch") 
        end
    end
end
---------------------------------------------
Events.OnSwitchVehicleSeat.Add(SwitchSeat)
---------------------------------------------------------------------------------------------------------------------------------------------------
local function onPlayerDeath()
--------------------------------------------------------------------
    local player = getPlayer()
    local vehicleInside = player:getVehicle()
    if vehicleInside then   
        sendClientCommand("RespawnINcar_CarExit","true",{vehicleInside:getId()}) 
        --print("Death vehicleInside")
    else 
        local square = player:getCurrentSquare()
        local vehicle = square:getVehicleContainer()
        if vehicle then 
            sendClientCommand("RespawnINcar_CarExit","true",{vehicle:getId()})
            --print("Death vehicle square")
        else 
            sendClientCommand("RespawnINcar_SearchCarToRemovePlayerInside","true",{}) 
            --print("force exit vehicle cell to server")
        end
    end
end
---------------------------------------
Events.OnPlayerDeath.Add(onPlayerDeath)
----------------------------------------------------------------------------------------------------------------------------------------------------
local OnGameStart_Counter = 0
local function OnStartGame()
-------------------------------------------------------------------
	local player = getPlayer()
    if not player or not player:getCell() or not player:getCurrentSquare() then return end
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if OnGameStart_Counter < 5 then OnGameStart_Counter = OnGameStart_Counter +1 return end
    ----------------------------------------------------------------------------------------------------------------------------------------
    if player:getHoursSurvived() < 0.01 then
        --if getPlayer():getHoursSurvived() < YouHaveOneDay.hoursBeforeSpawn then
        --if not YouHaveOneDay.hordeSpawned and getPlayer():getHoursSurvived() > getGameTime():getModData()["hoursBeforeSpawn"] then
		sendClientCommand("RespawnINcar_NilPlayerPostion","true",{})
		Events.OnPlayerUpdate.Remove(OnStartGame) 
		--print("new character stop OnGameStart") 
        return
	end
    ----------------------------------------------------------------------------------------------------------------------------------------
    if OnGameStart_Counter ~= 10 then OnGameStart_Counter = OnGameStart_Counter +1 return end
    ----------------------------------------------------------------------------------------------------------------------------------------
    OnGameStart_Counter = 11
    if player:getHoursSurvived() >= 0.01 then
        sendClientCommand("RespawnINcar_OnStartGame","true",{})
        Events.OnPlayerUpdate.Remove(OnStartGame)
        --print("OnStartGame send server")
    end
end
---------------------------------------------------
Events.OnPlayerUpdate.Add(OnStartGame)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--						                                                                     DEBUG MENU and PLAYER MENU
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local respawnVehicle = {}
------------------------------------------------------------------------------------
respawnVehicle.onFillWorldObjectContextMenu = function(playerId, context, worldobjects, test)
local player = getSpecificPlayer(playerId)
local vehicleInside = player:getVehicle()
--------------------------------------------------------------------------------------------------------------------------------
if vehicleInside then 
if isAdmin() or getCore():getDebug() then context:addOption(getText("Check how many passenger(s)"), worldobjects, respawnVehicle.seat, player) end
context:addOption(getText("Check passenger(s) name(s)"), worldobjects, respawnVehicle.CheckName, player)
end
--------------------------------------------------------------------------------------------------------------------------------
if isAdmin() or getCore():getDebug() then
local KeyMenu = context:addOption("[DEBUG] ForceRespawnToVehicle", worldobjects);
local subMenu = ISContextMenu:getNew(context);
respawnVehicle.context = context
respawnVehicle.subMenu = subMenu
context:addSubMenu(KeyMenu, subMenu);
subMenu:addOption(getText('Check Seat taked'), worldobjects, respawnVehicle.seat, player)
subMenu:addOption(getText('Check players names'), worldobjects, respawnVehicle.CheckName, player)
subMenu:addOption(getText('Vehicle number ref'), worldobjects, respawnVehicle.numberRef, player)
subMenu:addOption(getText('Reset player list in this vehicle'), worldobjects, respawnVehicle.RespawnINcar_resetcar, player)
subMenu:addOption(getText('Expulse all players vehicle inside at this position '), worldobjects, respawnVehicle.dumpPlayers, player)
subMenu:addOption(getText('seat Number'), worldobjects, respawnVehicle.seatNumber, player)
if getCore():getDebug() then
subMenu:addOption(getText('Exit vehicle (without TriggerOnExit)'), worldobjects, respawnVehicle.exitcar, player)
subMenu:addOption(getText('Enter vehicle (without TriggerOnEnter)'), worldobjects, respawnVehicle.entercar, player)
subMenu:addOption(getText('Redefine vehicle name list'), worldobjects, respawnVehicle.Redefine, player)
subMenu:addOption(getText('-1 passenger'), worldobjects, respawnVehicle.removePerson, player)
subMenu:addOption(getText('+1 passenger'), worldobjects, respawnVehicle.addPerson, player)
subMenu:addOption(getText('Reset player position'), worldobjects, respawnVehicle.resetPOSplayer, player)
subMenu:addOption(getText('set pos player here'), worldobjects, respawnVehicle.setposplayerhere, player)
subMenu:addOption(getText('On Game Start simulated '), worldobjects, respawnVehicle.respawn, player)
end
end
--------------------------------------------------------------------------------------------------------------------------------
local vehicle = player:getVehicle()
if not vehicle then
vehicle = player:getUseableVehicle()
if vehicle then
-------------------------------------------
local part = vehicle:getUseablePart(player)
if not part or not part:getDoor() then return end
if not part:getDoor():isOpen() or part:getId() == "EngineDoor" then return end --or part:getDoor():isLocked() or (part:getId() ~= "TrunkDoor" and part:getId() ~= "DoorRear")
else
return
end
elseif vehicle and 
vehicle:getScript():getFullName() ~= "Base.BoatSailingYacht"        and 
vehicle:getScript():getFullName() ~= "Base.BoatSailingYacht_Ground" and  
vehicle:getScript():getFullName() ~= "Base.BoatMotor"               and 
vehicle:getScript():getFullName() ~= "Base.BoatMotor_Ground"        then
return
end
-------------------------------------------
local playerName    = player:getUsername()
local VEHICLE_TARGETED_MAX_SEAT = vehicle:getMaxPassengers()
-------------------------------------------
local KeyMenu = context:addOption("Expulse player to",worldobjects)
local subMenu = ISContextMenu:getNew(context)
-------------------------------------------
respawnVehicle.context = context
respawnVehicle.subMenu = subMenu
context:addSubMenu(KeyMenu, subMenu)
-------------------------------------------------------------------------------------------------
subMenu:addOption(getText('Seat 1'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,1) 
if VEHICLE_TARGETED_MAX_SEAT == 1 then return end
subMenu:addOption(getText('Seat 2'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,2)
if VEHICLE_TARGETED_MAX_SEAT == 2 then return end
subMenu:addOption(getText('Seat 3'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,3)
if VEHICLE_TARGETED_MAX_SEAT == 3 then return end
subMenu:addOption(getText('Seat 4'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,4)
if VEHICLE_TARGETED_MAX_SEAT == 4 then return end
subMenu:addOption(getText('Seat 5'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,5)
if VEHICLE_TARGETED_MAX_SEAT == 5 then return end
subMenu:addOption(getText('Seat 6'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,6)
if VEHICLE_TARGETED_MAX_SEAT == 6 then return end
subMenu:addOption(getText('Seat 7'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,7)
if VEHICLE_TARGETED_MAX_SEAT == 7 then return end
subMenu:addOption(getText('Seat 8'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,8)
if VEHICLE_TARGETED_MAX_SEAT == 8 then return end
subMenu:addOption(getText('Seat 9'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,9)
if VEHICLE_TARGETED_MAX_SEAT == 9 then return end
subMenu:addOption(getText('Seat 10'), worldobjects, respawnVehicle.expulsePlayer,player,vehicle,10)
end
------------------------------------------------------------------------------------
Events.OnFillWorldObjectContextMenu.Add(respawnVehicle.onFillWorldObjectContextMenu)
--------------------------------------------------------------------------------------------------------------------------------

respawnVehicle.setposplayerhere = function (worldobjects, player)
sendClientCommand("RespawnINcar_set_pos_player_here","true",{})
end
respawnVehicle.seatNumber = function (worldobjects, player)
local vehicle = player:getVehicle()
if not vehicle then return end
local seat = vehicle:getSeat(player)
print("number of your seat is " .. seat)
end
---------------------------------------------------------------------
respawnVehicle.expulsePlayer = function(worldobjects, player, vehicle, numSeat)
local vehicleTestBoat = player:getVehicle()
if  vehicleTestBoat and
vehicle:getScript():getFullName() ~= "Base.BoatSailingYacht"        and 
vehicle:getScript():getFullName() ~= "Base.BoatSailingYacht_Ground" and  
vehicle:getScript():getFullName() ~= "Base.BoatMotor"               and 
vehicle:getScript():getFullName() ~= "Base.BoatMotor_Ground"        then 
player:Say("You should get out vehicle") 
return 
end
local vehicleTest = player:getUseableVehicle()
if (not vehicleTest and not vehicleTestBoat) or (vehicleTest ~= vehicle and vehicleTestBoat ~= vehicle) then player:Say("You should get near vehicle") return end
ISTimedActionQueue.add(respawnCar_TimedAction:new(player, vehicle, numSeat))    
end  
-------------------------------------------------------------------
respawnVehicle.entercar = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then player:Say("You should get out vehicle") return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then vehicle:enter(0, player) end
end
-------------------------------------------------------------------
respawnVehicle.RespawnINcar_resetcar = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then player:Say("You should get out vehicle") return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("server_RespawnINcar_resetcar","true",{vehicle:getId()}) end
end
-------------------------------------------------------------------
respawnVehicle.resetPOSplayer = function (worldobjects, player)
sendClientCommand("RespawnINcar_NilPlayerPostion","true",{}) 
end
-------------------------------------------------------------------
respawnVehicle.CheckName = function(worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RespawnINcar_CheckName","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RespawnINcar_CheckName","true",{vehicle:getId()})  end 
end
-------------------------------------------------------------------
respawnVehicle.removePerson = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RespawnINcar_removePerson","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RespawnINcar_removePerson","true",{vehicle:getId()})  end 
end
-------------------------------------------------------------------
respawnVehicle.dumpPlayers = function (worldobjects, player)
local vehicleInside = player:getVehicle()
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
--local onlineUsers = getOnlinePlayers()
--for i=0, onlineUsers:size()-1 do
--    local playerOnline = onlineUsers:get(i)
--    if playerOnline and not playerOnline:isDead() then
--     --   print(playerOnline:getUsername() .. " exist")
--        local veh = playerOnline:getVehicle()
--        if veh and veh == vehicle then print(playerOnline:getUsername() .. " inside car") end
--
--    end
--end
if vehicleInside then sendClientCommand("RespawnINcar_dumpPlayersFromCar","true",{vehicleInside:getId()}) return end
if vehicle then sendClientCommand("RespawnINcar_dumpPlayersFromCar","true",{vehicle:getId()}) end
end
-------------------------------------------------------------------
respawnVehicle.Redefine = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RedefineNameListByPositionNum","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RedefineNameListByPositionNum","true",{vehicle:getId()}) end

end
-------------------------------------------------------------------
respawnVehicle.addPerson = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RespawnINcar_addPerson","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RespawnINcar_addPerson","true",{vehicle:getId()}) end 
end
-------------------------------------------------------------------
respawnVehicle.seat = function(worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RespawnINcar_seat","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RespawnINcar_seat","true",{vehicle:getId()}) end 
end
-------------------------------------------------------------------
respawnVehicle.numberRef = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if vehicleInside then sendClientCommand("RespawnINcar_numberRef","true",{vehicleInside:getId()}) return end
local square = player:getCurrentSquare()
local vehicle = square:getVehicleContainer()
if vehicle then sendClientCommand("RespawnINcar_numberRef","true",{vehicle:getId()}) end 
end
-------------------------------------------------------------------
respawnVehicle.respawn = function (worldobjects, player)
player:Say("OnStartGame simulated")
sendClientCommand("RespawnINcar_OnStartGame","true",{})
end
-------------------------------------------------------------------
respawnVehicle.exitcar = function (worldobjects, player)
local vehicleInside = player:getVehicle()
if not vehicleInside then player:Say("You should get out vehicle") return end
local seat = vehicleInside:getSeat(player)
getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(nil)
vehicleInside:exit(player)
vehicleInside:setCharacterPosition(player, seat, "outside")
player:PlayAnim("Idle")
vehicleInside:updateHasExtendOffsetForExitEnd(player)
end
      