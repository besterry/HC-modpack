---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RespawnInCar_mod = RespawnInCar_mod or {}
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Utils = require("RespawnInCarMod/RIC_Utils")
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RIC = {}
local RIC_Respawn_UserData
local RIC_Respawn_Delai
local RIC_Respawn_FloorType
local RIC_Respawn_IsAllready
local RIC_Respawn_Wait
local RIC_SavedFlag
local RIC_SavedVehicle
local RIC_PreTeleportPlayerAttempt
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                  SPECIAL FUNCTIONS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RIC.IsAdmin(player)
    return isAdmin() or player:getAccessLevel() == "admin" or player:getAccessLevel() == "Admin"
end
function RIC.GetExpulseMenu(player,args,command)
    local RICmenu = require("RespawnInCarMod/RIC_Menu")
    RICmenu[command](player,args)
end
function RIC.ResetRespawnVars()
    RIC_Respawn_UserData = nil
    RIC_Respawn_Delai = 0
    RIC_Respawn_FloorType = nil
    RIC_Respawn_Wait = 0
end
function RIC.ISQuitGame()
    if RIC_Respawn_IsAllready and MainScreen.instance ~= nil and MainScreen.instance.inGame == true then
        local player = getPlayer()
        if not player then return end
        local vehicle = player:getVehicle()
        if vehicle or (RVInterior and RVInterior.playerInsideInterior(player)) then 
            if vehicle and vehicle:isDriver(player) then 
                RIC.SaveVehicle(player,vehicle) 
            end
            return
        end
        RIC.SendClientCommand(player,"SavePlayer",{false})
    end
end
function RIC.SendClientCommand(player,command,args)
    local name = player:getUsername()
    if not isClient() then
        local RICserver = require("RespawnInCarMod/RIC_ServerFunctions")
        RICserver.DATA.RIC_PLAYERS_POS = RICserver.DATA.RIC_PLAYERS_POS or {}
        RICserver.ClientCommand[command](player,name,command,args)
        --print("TEST.... SendClientCommand SP")
        return RICserver
    else
        table.insert(args,name)
        sendClientCommand("RespawnINcar",command,args) 
        --print("TEST.... SendClientCommand MP")
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                FUNCTIONS CALLED FROM SERVER COMMANDS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RIC.CheckPlayersNames(player,args)
    local txt 
    local seat = 0
    local playername
    for _,name in pairs(args) do
        if name then 
            if name == player:getUsername() then playername = player:getUsername() end
            if name ~= "   -" then seat = seat+1 end
            txt = txt or ""  
            txt = txt.."\n"..name
        end
    end
    if seat == 1 and playername then txt = getText('IGUI_RIC_JustYou') end
    RIC.GetDialogText(player,txt)
end
-------------------------------------------------------------------
function RIC.delayedFunctionOverSeatTaked(player)
    if RIC.IsAdmin(player) then return end
    player:Say(getText('IGUI_RIC_no_more_place'))    
    RIC.ForceExitCar(player)
end
-------------------------------------------------------------------
function RIC.ExpulsePlayer(player,args)        
    player:Say(getText("IGUI_RIC_playerIsExpulsed") .. tostring(args[1]) .. getText("IGUI_RIC_Is_Expulsed"))
    if getActivatedMods():contains("AvatarOffline") or getActivatedMods():contains("Avatar USER") then
        local Avatar_Item_Created = AvatarFUNC.CreateAvatarInInventory(player,args[1],args[2],false) 
        AvatarFUNC.DropAvatarFromInventory(player,Avatar_Item_Created) 
    end
end
-------------------------------------------------------------------
function RIC.SayText(player,args)
    if args[2] then player:Say(getText(args[1]))
    else            player:Say(tostring(args[1])) 
    end
end
-------------------------------------------------------------------
function RIC.PreTeleportPlayer(player,args)
    if type(args) == "table" and args[4] and (type(args[4]) == "number" or type(args[4]) == "boolean") then
        local vehicle = player:getVehicle() 
        local isNumber = type(args[4]) == "number"
        local teleport = true
        RIC.ResetRespawnVars()
        if isNumber then RIC_Respawn_UserData = args end
        if vehicle then 
            if isNumber and RIC.IsMyCar(player,vehicle,args[4]) then 
                RIC_PreTeleportPlayerAttempt = true
                RIC.OverTestInsideVehicle(player)
                teleport = false
                --print("TEST.... is my car")
            else
                RIC.ForceExitCar(player)
                --print("TEST.... is NOT my car >> force exit to go my car")
            end
        end
        if teleport then
            local square = player:getCurrentSquare()
            if square then player:getModData().RIC_originSquare = square end
            if SandboxVars.RespawnInCarMod.FullProtectDuringRespawn then 
                player:setInvisible(true);
                player:setNoClip(true);
                print("....... RIC INFO: Full protection is activated during the respawn.")
            else
                player:setZombiesDontAttack(true) 
                print("....... RIC INFO: Simple protection is activated during the respawn.")
            end
            RIC.TeleportPlayer(player,args)
            Events.OnPlayerUpdate.Add(RespawnInCar_mod.OnPlayerRespawnByLoop)
        end
    end
    RIC_Respawn_IsAllready = true
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                FUNCTIONS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RIC.TeleportPlayer(player,args)
    player:setX(args[1])
    player:setY(args[2])
    player:setZ(args[3])
    player:setLx(args[1])
    player:setLy(args[2])
    player:setLz(args[3])
end
-------------------------------------------------------------------
function RIC.SavePlayer(player,type)
    RIC.SendClientCommand(player,"SavePlayer",{type})
end
-------------------------------------------------------------------
function RIC.SaveVehicle(player,vehicle)
    local vehSquare = vehicle:getSquare()
    if vehSquare == RIC_SavedFlag and vehicle == RIC_SavedVehicle then return end--print("TEST.... this square is already saved") return end
    --if RIC_SavedFlag then print("TEST....RIC_SavedFlag  x: "..RIC_SavedFlag:getX().." y: "..RIC_SavedFlag:getY().." z: "..RIC_SavedFlag:getZ()) end
    --print("TEST....vehSquare  x: "..vehSquare:getX().." y: "..vehSquare:getY().." z: "..vehSquare:getZ())
    RIC_SavedVehicle = vehicle
    RIC_SavedFlag = vehSquare
    RIC.SendClientCommand(player,"SaveVehicle",{vehicle:getId()})
   -- print("TEST.... VEHICULE IS SAVED ")
end
-------------------------------------------------------------------
function RIC.IsMyCar(player,vehicle,num)
    local vehicleNUM = vehicle:getModData().RIC_vehicleNUM
    return num == vehicleNUM and RIC.MyNameInCar(player,vehicle)
end
-------------------------------------------------------------------
function RIC.GetDialogText(player,txt)
    local function confirm(this,button)
        if button.internal == "OK" then
        end
    end
    local txt = getText(txt)
    local dialog = ISModalDialog:new(0,0, 250, 150, txt, false, nil, confirm, 0)
    dialog:initialise()
    --dialog:setTexture("crafted_01_19");
    dialog:addToUIManager()
    getSoundManager():PlayWorldSound("RIC_vehicleMove", player:getCurrentSquare(), 1, 25, 2, true) 
end
-------------------------------------------------------------------
function RIC.ForceExitCar(player)
    local vehicle = player:getVehicle()
    if not vehicle then return end
    local seat = vehicle:getSeat(player)
    vehicle:exit(player)
    if seat then vehicle:setCharacterPosition(player, seat, "outside") end
    player:PlayAnim("Idle")
    vehicle:updateHasExtendOffsetForExitEnd(player)
    getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(nil)
end
-------------------------------------------------------------------
function RIC.MyNameInCar(player,vehicle)
    local vDATA = vehicle:getModData()
    local maxSeat = vehicle:getMaxPassengers()
    local name = player:getUsername()
    local counter = 0
    for i=1,maxSeat do
        counter = counter+1
        if vDATA["serverForceRespawn_playerName"..counter] and vDATA["serverForceRespawn_playerName"..counter] == name then return true end
    end
end
-------------------------------------------------------------------
function RIC.GetVehicleByRadius(player,square)
    if not player or not square then return end
    local x,y,z = square:getX(),square:getY(),square:getZ()
    local radius = 7
    local altZ = 0
    for xx = x-radius, x+radius do
    for yy = y-radius, y+radius do
    for zz = z-altZ, z+altZ do          
    ------------------------------------------------
        local square = getWorld():getCell():getGridSquare(xx,yy,zz);
        if square then
            local vehicle = square:getVehicleContainer()
            if vehicle and RIC.MyNameInCar(player,vehicle) then 
                return vehicle
            end
        end
    end -- xx
    end -- yy
    end -- zz
end
-------------------------------------------------------------------
function RIC.CreatePlayer()
    Utils.delayedFunction(function()
        local player = getSpecificPlayer(0)
        if not player or player:isDead() then return end
        local sandbox = SandboxVars.RespawnInCarMod.ForceToRespawnInCarEvenIfNewPlayer
        if not sandbox and player:getHoursSurvived() <= 0.01 then 
            RIC_Respawn_IsAllready = true
            RIC.SendClientCommand(player,"SavePlayer",{false})
            return 
        end 
        if RVInterior and RVInterior.playerInsideInterior(player) then RIC_Respawn_IsAllready = true return end
        RIC.SendClientCommand(player,"PreTeleportPlayer",{})
    end, 5)
end
-------------------------------------------------------------------
function RIC.SwitchVehicleSeat()
    local player = getPlayer()
    local vehicle = player:getVehicle()
    if vehicle then
        player:getModData().RIC_seatTaked = vehicle:getSeat(player)
        if vehicle:isDriver(player) then
            Events.OnPlayerUpdate.Add(RespawnInCar_mod.SaveVehicleByLoop)
        end
    end
end
-------------------------------------------------------------------
function RIC.CarEnter()
    local player = getPlayer()
    local vehicle = player:getVehicle()
    if vehicle then
        local args = {vehicle:getId(),RIC_Respawn_IsAllready}
        RIC.SendClientCommand(player,"CarEnter",args)
        player:getModData().RIC_seatTaked = vehicle:getSeat(player)
        if vehicle:isDriver(player) then
            RIC_SavedVehicle = vehicle
            RIC_SavedFlag = vehicle:getSquare()
            Events.OnPlayerUpdate.Add(RespawnInCar_mod.SaveVehicleByLoop)
        end
    end
end
-------------------------------------------------------------------
function RIC.CarExit(dead)
    local player = getSpecificPlayer(0)
    if not player then return end
    local vehicle = player:getVehicle()
    local square = player:getCurrentSquare()
    local name = player:getUsername()
    local command = "CarExit"
    local args = {-1,dead}
    if not vehicle and square then 
        vehicle = square:getVehicleContainer()
    end
    local vehicle = vehicle or RIC.GetVehicleByRadius(player,square)
    if vehicle then
        args = {vehicle:getId(),dead}
        RIC_SavedVehicle = vehicle
        RIC_SavedFlag = vehicle:getSquare() 
    end
    RIC.SendClientCommand(player,command,args)
    player:getModData().RIC_seatTaked = nil
    Events.OnPlayerUpdate.Remove(RespawnInCar_mod.SaveVehicleByLoop)
end
-------------------------------------------------------------------
function RIC.GetBoat(vehicle)
    if not vehicle then return end
    local fullName = vehicle:getScript():getFullName()
    if fullName == "Base.BoatSailingYacht" or fullName == "Base.BoatSailingYacht_Ground" then return "yacht"
    elseif fullName == "Base.BoatMotor" or fullName == "Base.BoatMotor_Ground" then return "boatMotor" 
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                                      FUNCTIONS EVENTS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT LOOP DURING PLAYER IS DRIVER (GLOBAL)
-------------------------------------------------------------------
local saveCounter = 0
function RespawnInCar_mod.SaveVehicleByLoop()
    if saveCounter < 80 then saveCounter = saveCounter+1 return end
    saveCounter = 0
    local player = getPlayer()
    if not player then return end
    local vehicle = player:getVehicle()
    if vehicle and vehicle:isDriver(player) then
        if not RIC_SavedFlag or RIC_SavedFlag:DistTo(player) > 80 then -- or (vehicle:getCurrentSpeedKmHour()
            RIC.SaveVehicle(player,vehicle)
        end
    else
        if vehicle then RIC.SaveVehicle(player,vehicle) end
        Events.OnPlayerUpdate.Remove(RespawnInCar_mod.SaveVehicleByLoop)
    end
    --print("TEST....loop")
end
-------------------------------------------------------------------
-- EVENT LOOP DURING RESPAWN IN CAR AND OTHER (GLOBAL)
-------------------------------------------------------------------
function RIC.Wait()
    if RIC_Respawn_Wait > 0 then RIC_Respawn_Wait = RIC_Respawn_Wait-1 return true end
    RIC_Respawn_Wait = 5 
end
function RespawnInCar_mod.OnPlayerRespawnByLoop(player)
    RIC_Respawn_Delai = RIC_Respawn_Delai +1
    local square = player:getCurrentSquare()
    if RIC_Respawn_Delai >= 800 then
        RIC.RespawnFailsecurity(player,square)
        --print("TEST.... RIC_Respawn_Delai > 800")
        return
    elseif RIC_Respawn_Delai == 300 then
        player:Say(getText('IGUI_RIC_FailSecurity_test'))
    end
    if not square then return end
    RIC_Respawn_FloorType = RIC_Respawn_FloorType or RIC.InitializeRespawn(player,square)
    if RIC_Respawn_UserData then
        if RIC.Wait() then return end
        RIC.AttemptToEnterInMyCar(player,square)
        --print("TEST.... OnPlayerRespawn AttemptToEnterInMyCar")
    else 
        RIC.SpawnOnGround(player)
        RIC.StopRespawn(player,square) 
        --print("TEST.... OnPlayerRespawn SpawnOnGround")
    end
end
-------------------------------------------------------------------
-- FUNCTIONS CALLED BY OnPlayerRespawn
-------------------------------------------------------------------
function RIC.StopRespawn(player,square)
    Utils.delayedFunction(function()
        if RIC_Respawn_FloorType == "water" and TickControl and TickControl.main then  Events.OnTick.Add(TickControl.main) end
        local square = square or player:getCurrentSquare()
        if square then 
            if getActivatedMods():contains("AvatarOffline") or getActivatedMods():contains("Avatar USER") then AvatarFUNC.AnalyseAvatarsFloor(square) end
            player:getModData().RIC_originSquare = nil 
        end
        if SandboxVars.RespawnInCarMod.FullProtectDuringRespawn then 
            player:setInvisible(false);
            player:setNoClip(false);
            print("....... RIC INFO: Full protection is desactivated.")
        else
            player:setZombiesDontAttack(false) 
            print("....... RIC INFO: Simple protection is desactivated.")
        end
        --player:setInvisible(false);
        RIC.ResetRespawnVars()
    end, 70)
    Events.OnPlayerUpdate.Remove(RespawnInCar_mod.OnPlayerRespawnByLoop)
end
-------------------------------------------------------------------
function RIC.InitializeRespawn(player,square)
    RIC_Respawn_Delai = 0
    local typeFloor
    if square:Is(IsoFlagType.water) and TickControl and TickControl.main then
        typeFloor = "water"
        player:getSprite():getProperties():Set(IsoFlagType.invisible) 
        Events.OnTick.Remove(TickControl.main)
    else
        typeFloor = "ground"
    end 
    return typeFloor
end 
-------------------------------------------------------------------
function RIC.RespawnFailsecurity(player,square)
    if RIC_Respawn_UserData then 
        if not player:getVehicle() then RIC.CarExit() end
    else                
        RIC.SpawnOnGround(player) 
    end
    if not RIC_Respawn_FloorType and player:getModData().RIC_originSquare then 
        local originSqaure = player:getModData().RIC_originSquare
        RIC.TeleportPlayer(player,{originSqaure:getX(),originSqaure:getY(),originSqaure:getZ()}) 
    end
    RIC.StopRespawn(player,square)   
    print("....... RIC INFO: Respawn is failed ! (can't enter, car or square is not founded )")
end
-------------------------------------------------------------------
function RIC.AttemptToEnterInMyCar(player,square)
    local vehicle = RIC.GetMyCar(player)
    if vehicle then
        Utils.delayedFunction(function()
            local seat = RIC.EnterInMyCar(player,vehicle)
            RIC.TestInMyCar(player,seat)
        end, 5)
        RIC.StopRespawn(player,square)
    end
end
-------------------------------------------------------------------

function RIC.OverTestInsideVehicle(player,seat)
    Utils.delayedFunction(function()
        local vehicle = player:getVehicle()
        if vehicle then 
            if vehicle:isDriver(player) then Events.OnPlayerUpdate.Add(RespawnInCar_mod.SaveVehicleByLoop) end
            if seat then
                vehicle:setCharacterPosition(player, seat, "inside")
                vehicle:transmitCharacterPosition(seat, "inside")
                triggerEvent("OnEnterVehicle", player)
            end
        else
            getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(nil)
            if not RIC_PreTeleportPlayerAttempt then -- because the player can be kicked by other player inside vehicle, force respawn
                RIC_PreTeleportPlayerAttempt = true  
                RIC.SendClientCommand(player,"PreTeleportPlayer",{})
            else
                RIC.SavePlayer(player,false)
            end
        end
    end, 70)
end
-------------------------------------------------------------------
function RIC.GetMyCar(player)
    local vehicles=getCell():getVehicles()--getWorld():
    if vehicles:size() > 0 then
        for i=1,vehicles:size() do
            local vehicle = vehicles:get(i-1)
            local myCar = RIC_Respawn_UserData[4]
            local thisCar = vehicle:getModData().RIC_vehicleNUM
            local thisIsMyCar = myCar == thisCar and RIC.MyNameInCar(player,vehicle)
            if thisIsMyCar then return vehicle end
        end
    end
end
-------------------------------------------------------------------
function RIC.EnterInMyCar(player,vehicle)
    local mySeat = player:getModData().RIC_seatTaked
    local boat = RIC.GetBoat(vehicle)
    local selectedSeat
    if mySeat then
        local doorPart = vehicle:getPassengerDoor(mySeat)
        if doorPart and not boat and not vehicle:isSeatOccupied(mySeat) and vehicle:isSeatInstalled(mySeat) and mySeat ~= -1  then --and not vehicle:getCharacter(mySeat) 
            vehicle:enter(mySeat, player) 
            selectedSeat = mySeat
        end
    end
    if not selectedSeat then
        local mySeat
        for seat= 0, vehicle:getMaxPassengers() -1 do --seat=vehicle:getMaxPassengers(),0, -1 do
            if seat ~= -1 and not vehicle:isSeatOccupied(seat) then --not vehicle:getCharacter(seat)
                local doorPart = vehicle:getPassengerDoor(seat)
                if doorPart and vehicle:isSeatInstalled(seat) then 
                    mySeat = seat
                elseif boat == "yacht" and (seat == 1 or seat == 0) then   
                    mySeat = seat
                elseif boat == "boatMotor" and (seat == 4 or seat == 5) then
                    mySeat = seat
                end
                if mySeat then 
                    vehicle:enter(mySeat, player)
                    selectedSeat = mySeat
                    break
                end
            end
        end
    end
    return selectedSeat
end
-------------------------------------------------------------------
function RIC.TestInMyCar(player,seat)
    local vehicle = player:getVehicle()
    if vehicle then
        if vehicle:isDriver(player) then getPlayerVehicleDashboard(player:getPlayerNum()):setVehicle(vehicle) end
        getSoundManager():PlayWorldSound("RIC_vehicleMove", player:getCurrentSquare(), 0, 10, 10.0, false);
        RIC.OverTestInsideVehicle(player,seat)                   
    else
        RIC.CarExit()
    end    
end
-------------------------------------------------------------------
function RIC.SpawnOnGround(player)
    getSoundManager():PlayWorldSound("RIC_respawnGround", player:getCurrentSquare(), 1, 25, 2, true) 
    RIC.SendClientCommand(player,"SavePlayer",{false})
    --addSound(player, player:getX(), player:getY(), player:getZ(), 20, 50);
end 
-------------------------------------------------------------------

return RIC