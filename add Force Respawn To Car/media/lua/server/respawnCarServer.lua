if not isServer() then return end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																									-- fONCTIONS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function preSavePlayer(name)
	if name == nil then return end
	local gtDATA = getGameTime():getModData()
	if gtDATA.RIC_PLAYERS_POS 		   == nil then gtDATA.RIC_PLAYERS_POS 		   = {}    end
	if gtDATA.RIC_PLAYERS_POS[name]    == nil then gtDATA.RIC_PLAYERS_POS[name]    = {}    end
	if gtDATA.RIC_PLAYERS_POS[name]    == nil then gtDATA.RIC_PLAYERS_POS[name][4] = false end
	
--	if gtDATA.RIC_PLAYERS_POS[name] ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == nil then gtDATA.RIC_PLAYERS_POS[name][4] = false end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SavePlayerPostionInCar(name,vehicle)
	local gtDATA = getGameTime():getModData()
	local vDATA = vehicle:getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM

	--print("........... save player ".. name .." in car n ... ".. vehicleNum)
	gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),vehicleNum} 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function setNilPlayerPostion(name)
	local gtDATA = getGameTime():getModData()

	gtDATA.RIC_PLAYERS_POS[name][4] = false
	--print("........... Player position is reseted ... " .. name)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SavePlayersPostionFromCar(name,vehicle)
	local gtDATA = getGameTime():getModData()
	local vDATA = vehicle:getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM

	preSavePlayer(name)

	local playerNUM = gtDATA.RIC_PLAYERS_POS[name][4]
	if playerNUM == vehicleNum then 
		--print("........... save player ".. name .." in car n ... ".. playerNUM)
		gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),vehicleNum} 
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function preSavePlayersByNameFromCar(vehicle)
	local gtDATA = getGameTime():getModData()
	local vDATA = vehicle:getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM
	--print("........... save global player in car n ... ".. vehicleNum)

	local name = vDATA.serverForceRespawn_playerName1  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName2  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName3  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName4  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName5  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName6  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName7  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName8  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName9  ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
	local name = vDATA.serverForceRespawn_playerName10 ; if name ~= nil then SavePlayersPostionFromCar(name,vehicle) end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RedefineSeat(vehicle)
	local vDATA = vehicle:getModData()
	local maxSeat = vehicle:getMaxPassengers()
	local CounterIN  = 0

	if 	vDATA.serverForceRespawn_playerName1  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName2  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName3  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName4  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName5  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName6  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName7  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName8  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName9  ~= nil then CounterIN = CounterIN +1 end
	if 	vDATA.serverForceRespawn_playerName10 ~= nil then CounterIN = CounterIN +1 end	

	local seatTaked = vDATA.serverForceRespawn_TargetedVehicle_takedSEAT
	if CounterIN  ~= seatTaked then 
		vDATA.serverForceRespawn_TargetedVehicle_takedSEAT = CounterIN 
		--print(" ........... Seat redefine in ... " .. CounterIN )
	end
	if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT > maxSeat then vDATA.serverForceRespawn_TargetedVehicle_takedSEAT = maxSeat end
	if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT < 0 then vDATA.serverForceRespawn_TargetedVehicle_takedSEAT = 0 end
	--print("............. redefineSeat is finish ....")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RedefineNameListByPositionNum(vehicle)
	local vDATA = vehicle:getModData()
	local gtDATA = getGameTime():getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM

	local name = vDATA.serverForceRespawn_playerName1  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName1  = nil end -- ; --print("........ name is removed " .. name1 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName2  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName2  = nil end -- ; --print("........ name is removed " .. name2 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName3  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName3  = nil end -- ; --print("........ name is removed " .. name3 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName4  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName4  = nil end -- ; --print("........ name is removed " .. name4 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName5  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName5  = nil end -- ; --print("........ name is removed " .. name5 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName6  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName6  = nil end -- ; --print("........ name is removed " .. name6 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName7  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName7  = nil end -- ; --print("........ name is removed " .. name7 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName8  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName8  = nil end -- ; --print("........ name is removed " .. name8 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName9  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName9  = nil end -- ; --print("........ name is removed " .. name9 ..  " ...")  end
	local name = vDATA.serverForceRespawn_playerName10 ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] ~= vehicleNum then vDATA.serverForceRespawn_playerName10 = nil end -- ; --print("........ name is removed " .. name10 .. " ...")  end

	RedefineSeat(vehicle)
	--print (".......... RedefineNameListByPositionNum is finshed ...")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RemovePlayerInCar(playerName, vehicle) 
	local vDATA = vehicle:getModData()

	local name = vDATA.serverForceRespawn_playerName1  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName1  = nil end
	local name = vDATA.serverForceRespawn_playerName2  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName2  = nil end
	local name = vDATA.serverForceRespawn_playerName3  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName3  = nil end
	local name = vDATA.serverForceRespawn_playerName4  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName4  = nil end
	local name = vDATA.serverForceRespawn_playerName5  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName5  = nil end
	local name = vDATA.serverForceRespawn_playerName6  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName6  = nil end
	local name = vDATA.serverForceRespawn_playerName7  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName7  = nil end
	local name = vDATA.serverForceRespawn_playerName8  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName8  = nil end
	local name = vDATA.serverForceRespawn_playerName9  ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName9  = nil end
	local name = vDATA.serverForceRespawn_playerName10 ; if name ~= nil and name == playerName then vDATA.serverForceRespawn_playerName10 = nil end
	
	RedefineSeat(vehicle)	
	--print(" ........... RemovePlayerInCar " .. playerName .. " is finish... ")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SearchCarToRemovePlayerInside(name)
	local gtDATA = getGameTime():getModData()
	
	if gtDATA.RIC_PLAYERS_POS[name][4] ~= false and gtDATA.RIC_PLAYERS_POS[name][4] ~= true  then--and gtDATA.SERVER_RIC_vehiclesNUM ~=nil then	
		local vehicles = getCell():getVehicles()			
		for k=1,vehicles:size() do
			local vehicle = vehicles:get(k-1)
			local vehiclesnum = vehicle:getModData().RIC_vehicleNUM
			if vehiclesnum ~=nil then
				if vehiclesnum == gtDATA.RIC_PLAYERS_POS[name][4] then
					--print(" ........... SearchCarToRemovePlayerInside TRUE for ... "..vehiclesnum)
					RemovePlayerInCar(name,vehicle)
					preSavePlayersByNameFromCar(vehicle)
					break
				end
			end
		end
	end
	setNilPlayerPostion(name)
	--print(" ........... SearchCarToRemovePlayerInside is finshed ...")			
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SearchCarToSavePosition(name)
	local gtDATA = getGameTime():getModData()

	if gtDATA.RIC_PLAYERS_POS[name][4] ~= false and gtDATA.RIC_PLAYERS_POS[name][4] ~= true  then--and gtDATA.SERVER_RIC_vehiclesNUM ~=nil then
		local vehicles = getCell():getVehicles()			
		for k=1,vehicles:size() do
			local vehicle = vehicles:get(k-1)
			local vehiclesnum = vehicle:getModData().RIC_vehicleNUM
			if vehiclesnum ~= nil then
				if vehiclesnum == gtDATA.RIC_PLAYERS_POS[name][4] then
					--print(" ........... SearchCarToSavePosition TRUE for ... "..vehiclesnum)
					preSavePlayersByNameFromCar(vehicle)
					break
				end
			end
		end		
	end
	--print(" ........... SearchCarToSavePosition is finshed ...")	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function dumpPlayersFromCar(vehicle,player)
	local vDATA = vehicle:getModData()
	local gtDATA = getGameTime():getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM

	local name = vDATA.serverForceRespawn_playerName1  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName1  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName2  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName2  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName3  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName3  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName4  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName4  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName5  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName5  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName6  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName6  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName7  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName7  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName8  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName8  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName9  ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName9  = nil end -- ; --print(" ........... this player is expulsed : ... "..name)
	local name = vDATA.serverForceRespawn_playerName10 ; preSavePlayer(name) ; if name ~= nil and gtDATA.RIC_PLAYERS_POS[name][4] == vehicleNum then gtDATA.RIC_PLAYERS_POS[name] = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true} sendServerCommand(player,"RespawnINcar_expulse_players", "true",{name}) ; vDATA.serverForceRespawn_playerName10 = nil end -- ; --print(" ........... this player is expulsed : ... "..name)

	RedefineNameListByPositionNum(vehicle) 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function preDumpPlayersFromCar(vehicle,player)
	local onlineUsers = getOnlinePlayers()
	for i=0, onlineUsers:size()-1 do
		local playerOnline = onlineUsers:get(i)
		if playerOnline and not playerOnline:isDead() then
			--print("............ " .. playerOnline:getUsername() .. " exist ...")
			local veh = playerOnline:getVehicle()
			if veh and veh == vehicle then 
				local txt = "There's someone inside"
				sendServerCommand(player,"RespawnINcar_Text", "true",{txt}) 
				--print(".......... player inside! ...") 
				return 
			end
		end
	end
	dumpPlayersFromCar(vehicle,player)
	--print("............ dump players is finished ...")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function expulsePlayer(vehicle,player,nameSeat)
	local vDATA = vehicle:getModData()
	local gtDATA = getGameTime():getModData()
	local vehicleNum = vDATA.RIC_vehicleNUM
	----------------------------------------------------------------------------------------------------------------------------------------------
	preSavePlayer(nameSeat)
	----------------------------------------------------------------------------------------------------------------------------------------------
	if nameSeat ~= nil and gtDATA.RIC_PLAYERS_POS[nameSeat][4] == vehicleNum then 
		gtDATA.RIC_PLAYERS_POS[nameSeat]  = {vehicle:getX(),vehicle:getY(),vehicle:getZ(),true}
		sendServerCommand(player,"RespawnINcar_expulse_players", "true",{nameSeat})  
		--print(" ........... this player is expulsed : ... "..nameSeat)
		nameSeat = nil
	end
	
	RedefineNameListByPositionNum(vehicle) 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function preExpulsePlayer(vehicle,player,nameSeat)
	local vDATA = vehicle:getModData()
	local gtDATA = getGameTime():getModData()
	if nameSeat == nil then 
		local txt = "There is no one on the seat."
		sendServerCommand(player,"RespawnINcar_Text", "true",{txt}) 
		return 
	end
	local onlineUsers = getOnlinePlayers()
	for i=0, onlineUsers:size()-1 do
		local playerOnline = onlineUsers:get(i)
		if playerOnline and not playerOnline:isDead() then
			--print("............ " .. playerOnline:getUsername() .. " exist ...")
			local veh = playerOnline:getVehicle()
			local vehiclesnum = vDATA.RIC_vehicleNUM
			local name = playerOnline:getUsername()
			preSavePlayer(name)
			local playerOnlinenum = gtDATA.RIC_PLAYERS_POS[name][4]
			if (nameSeat and nameSeat == name) and ((veh and veh == vehicle) or (vehiclesnum and vehiclesnum == playerOnlinenum)) then 
				local txt = "player is present inside!"
				sendServerCommand(player,"RespawnINcar_Text", "true",{txt}) 
				--print(".......... player inside! ...") 
				return 
			end
		end
	end
	expulsePlayer(vehicle,player,nameSeat)
	--print("............ dump players is finished ...")
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																									--SERVER COMMANDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ForceRespawnInVehicle_OnClientCommand(module, command, player,arguments)
	local gtDATA = getGameTime():getModData()
	local name   = player:getUsername()

	preSavePlayer(name)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	if module == "RespawnINcar_OnStartGame" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------		
		if gtDATA.RIC_PLAYERS_POS[name][4] ~= false and gtDATA.RIC_PLAYERS_POS[name][4] ~= true and gtDATA.RIC_PLAYERS_POS[name][4] ~= nil then
			SearchCarToSavePosition(name)			
			local Vehiclecarpos = gtDATA.RIC_PLAYERS_POS[name]--gtDATA.SERVER_RIC_vehiclesNUM[gtDATA.RIC_PLAYERS_POS[name]]
			sendServerCommand(player,"RespawnINcar_OnStartGame", "true",Vehiclecarpos)
			--print("............. respawn to car send client ...")
		----------------------------------------------------------------------------
		elseif gtDATA.RIC_PLAYERS_POS[name][4] == true then
			local Groundpos = gtDATA.RIC_PLAYERS_POS[name]
			sendServerCommand(player,"RespawnINcar_OnStartGame", "true",Groundpos)
			--print("............. respawn to ground send client ...")
		end
		--print("............. send client finished...")
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif module == "RespawnINcar_expulse_player" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local numSeat = arguments[3]

		if 	   numSeat == 1  then nameSeat = vehicle:getModData().serverForceRespawn_playerName1
		elseif numSeat == 2  then nameSeat = vehicle:getModData().serverForceRespawn_playerName2
		elseif numSeat == 3  then nameSeat = vehicle:getModData().serverForceRespawn_playerName3
		elseif numSeat == 4  then nameSeat = vehicle:getModData().serverForceRespawn_playerName4
		elseif numSeat == 5  then nameSeat = vehicle:getModData().serverForceRespawn_playerName5
		elseif numSeat == 6  then nameSeat = vehicle:getModData().serverForceRespawn_playerName6
		elseif numSeat == 7  then nameSeat = vehicle:getModData().serverForceRespawn_playerName7
		elseif numSeat == 8  then nameSeat = vehicle:getModData().serverForceRespawn_playerName8
		elseif numSeat == 9  then nameSeat = vehicle:getModData().serverForceRespawn_playerName9
		elseif numSeat == 10 then nameSeat = vehicle:getModData().serverForceRespawn_playerName10
		end 
		preExpulsePlayer(vehicle,player,nameSeat)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif module == "RespawnINcar_dumpPlayersFromCar" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
	    preDumpPlayersFromCar(vehicle,player)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif module == "RespawnINcar_NilPlayerPostion" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	    setNilPlayerPostion(name)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_SearchCarToRemovePlayerInside" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		SearchCarToRemovePlayerInside(name)	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_saveVehiclePosition" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		preSavePlayersByNameFromCar(vehicle)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif module == "RespawnINcar_EnterCar" then
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local maxSeat = vehicle:getMaxPassengers()
		local vDATA   = vehicle:getModData()
		----------------------------------------------------------------------------------------------------------
		if gtDATA.RIC_vehicleNUM == nil then gtDATA.RIC_vehicleNUM = 0 end
		----------------------------------------------------------------------------------------------------------
		if vDATA.RIC_vehicleNUM   == nil then
			vDATA.RIC_vehicleNUM  = gtDATA.RIC_vehicleNUM +1
			gtDATA.RIC_vehicleNUM = gtDATA.RIC_vehicleNUM +1
		end
		----------------------------------------------------------------------------
		if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT == nil then vDATA.serverForceRespawn_TargetedVehicle_takedSEAT = 0 end
		----------------------------------------------------------------------------		
		
		RedefineNameListByPositionNum(vehicle)

		if gtDATA.RIC_PLAYERS_POS[name][4] == true then sendServerCommand(player,"RespawnINcar_forceExitCar", "true",{}) return end 

		local Name1  = vDATA.serverForceRespawn_playerName1
		local Name2  = vDATA.serverForceRespawn_playerName2
		local Name3  = vDATA.serverForceRespawn_playerName3
		local Name4  = vDATA.serverForceRespawn_playerName4
		local Name5  = vDATA.serverForceRespawn_playerName5
		local Name6  = vDATA.serverForceRespawn_playerName6
		local Name7  = vDATA.serverForceRespawn_playerName7
		local Name8  = vDATA.serverForceRespawn_playerName8
		local Name9  = vDATA.serverForceRespawn_playerName9
		local Name10 = vDATA.serverForceRespawn_playerName10

		if name==Name1 or name==Name2 or name==Name3 or name==Name4 or name==Name5 or name==Name6 or name==Name7 or name==Name8 or name==Name9 or name==Name10 then
			
			SavePlayerPostionInCar(name,vehicle)
			preSavePlayersByNameFromCar(vehicle)	
			------
			return
			------ 
		end
		----------------------------------------------------------------------------
		if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT < maxSeat then
			vDATA.serverForceRespawn_TargetedVehicle_takedSEAT = vDATA.serverForceRespawn_TargetedVehicle_takedSEAT +1
			--print("........... player enter +1 ...")
		else
			sendServerCommand(player,"RespawnINcar_OverSeatTaked", "true",{})
			setNilPlayerPostion(name)
			preSavePlayersByNameFromCar(vehicle)
			------
			return
			------
		end
		----------------------------------------------------------------------------
		if 	   Name1  == nil then vDATA.serverForceRespawn_playerName1  = name
		elseif Name2  == nil then vDATA.serverForceRespawn_playerName2  = name
		elseif Name3  == nil then vDATA.serverForceRespawn_playerName3  = name
		elseif Name4  == nil then vDATA.serverForceRespawn_playerName4  = name
		elseif Name5  == nil then vDATA.serverForceRespawn_playerName5  = name
		elseif Name6  == nil then vDATA.serverForceRespawn_playerName6  = name
		elseif Name7  == nil then vDATA.serverForceRespawn_playerName7  = name
		elseif Name8  == nil then vDATA.serverForceRespawn_playerName8  = name
		elseif Name9  == nil then vDATA.serverForceRespawn_playerName9  = name
		elseif Name10 == nil then vDATA.serverForceRespawn_playerName10 = name
		end	
		SavePlayerPostionInCar(name,vehicle)
		preSavePlayersByNameFromCar(vehicle)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_CarExit" then  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local vDATA   = vehicle:getModData()
					
		if gtDATA.RIC_PLAYERS_POS[player:getUsername()][4] == vDATA.RIC_vehicleNUM then
			--print("RespawnINcar_CarExit 4 == RIC_vehicleNUM")
			RemovePlayerInCar(name,vehicle)
			setNilPlayerPostion(player:getUsername())
			preSavePlayersByNameFromCar(vehicle)
		else
			--print("RespawnINcar_CarExit search")
			SearchCarToRemovePlayerInside(name)
		end
		--print("RespawnINcar_CarExit")
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_CheckName" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------		
		local vehicle = getVehicleById(arguments[1])
		local vDATA   = vehicle:getModData()

		local Name1  = vDATA.serverForceRespawn_playerName1
		local Name2  = vDATA.serverForceRespawn_playerName2
		local Name3  = vDATA.serverForceRespawn_playerName3
		local Name4  = vDATA.serverForceRespawn_playerName4
		local Name5  = vDATA.serverForceRespawn_playerName5
		local Name6  = vDATA.serverForceRespawn_playerName6
		local Name7  = vDATA.serverForceRespawn_playerName7
		local Name8  = vDATA.serverForceRespawn_playerName8
		local Name9  = vDATA.serverForceRespawn_playerName9
		local Name10 = vDATA.serverForceRespawn_playerName10

		if  vDATA.RIC_vehicleNUM == nil or (Name1==nil and Name2==nil and Name3==nil and Name4==nil and Name5==nil and Name6==nil and Name7==nil and Name8==nil and Name9==nil and Name10==nil) then 

			local txt = "There is nobody!" 
			sendServerCommand(player,"RespawnINcar_Text", "true",{txt})
			------
			return
			------ 
		end
		sendServerCommand(player,"RespawnINcar_CheckName", "true",{Name1,Name2,Name3,Name4,Name5,Name6,Name7,Name8,Name9,Name10})
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--																				COMMANDS ADMIN
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_seat" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	local vehicle = getVehicleById(arguments[1])
    	local vDATA   = vehicle:getModData()
    	if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT == nil then 
    		local txt = "There is nobody!"
    		sendServerCommand(player,"RespawnINcar_Text", "true",{txt}) 
    		return 
    	end
    	local placeDispo = vDATA.serverForceRespawn_TargetedVehicle_takedSEAT
		sendServerCommand(player,"RespawnINcar_placeDispo", "true",{placeDispo}) 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RedefineNameListByPositionNum" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	   local vehicle = getVehicleById(arguments[1])
	   RedefineNameListByPositionNum(vehicle)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "server_RespawnINcar_resetcar" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local vDATA   = vehicle:getModData()

		if gtDATA.RIC_PLAYERS_POS == nil then gtDATA.RIC_PLAYERS_POS = {} end
		-------------------------------------------------------------------------
		local Name = vDATA.serverForceRespawn_playerName1  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName1  = nil end
		local Name = vDATA.serverForceRespawn_playerName2  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName2  = nil end
		local Name = vDATA.serverForceRespawn_playerName3  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName3  = nil end
		local Name = vDATA.serverForceRespawn_playerName4  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName4  = nil end
		local Name = vDATA.serverForceRespawn_playerName5  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName5  = nil end
		local Name = vDATA.serverForceRespawn_playerName6  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName6  = nil end
		local Name = vDATA.serverForceRespawn_playerName7  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName7  = nil end
		local Name = vDATA.serverForceRespawn_playerName8  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName8  = nil end
		local Name = vDATA.serverForceRespawn_playerName9  ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName9  = nil end
		local Name = vDATA.serverForceRespawn_playerName10 ; if Name ~= nil then preSavePlayer(Name) ; setNilPlayerPostion(name) ; vDATA.serverForceRespawn_playerName10 = nil end
		
		vDATA.serverForceRespawn_TargetedVehicle_takedSEAT  = 0
		local txt = "This vehicle is reseted!"
    	sendServerCommand(player,"RespawnINcar_Text", "true",{txt})
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_removePerson" then
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local maxSeat = vehicle:getMaxPassengers()
		local vDATA   = vehicle:getModData()

		if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT > 0 then
			vDATA.serverForceRespawn_TargetedVehicle_takedSEAT	= vDATA.serverForceRespawn_TargetedVehicle_takedSEAT -1
		end
		local placeDispo = vDATA.serverForceRespawn_TargetedVehicle_takedSEAT
		sendServerCommand(player,"RespawnINcar_placeDispo", "true",{placeDispo}) 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_addPerson" then
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		local vehicle = getVehicleById(arguments[1])
		local maxSeat = vehicle:getMaxPassengers()
		local vDATA   = vehicle:getModData()

		if vDATA.serverForceRespawn_TargetedVehicle_takedSEAT < maxSeat then
			vDATA.serverForceRespawn_TargetedVehicle_takedSEAT	= vDATA.serverForceRespawn_TargetedVehicle_takedSEAT +1
		end
		local placeDispo = vDATA.serverForceRespawn_TargetedVehicle_takedSEAT
		sendServerCommand(player,"RespawnINcar_placeDispo", "true",{placeDispo}) 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	elseif module == "RespawnINcar_numberRef" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    	local vehicle 	= getVehicleById(arguments[1])
    	local vDATA = vehicle:getModData()
    	local numberRef = vDATA.RIC_vehicleNUM

    	if numberRef == nil then numberRef = "nil" end
		local txt = "Vehicle number: " .. tostring(numberRef)
    	sendServerCommand(player,"RespawnINcar_Text", "true",{txt})
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif module == "RespawnINcar_set_pos_player_here" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	gtDATA.RIC_PLAYERS_POS[name] = {player:getX(),player:getY(),player:getZ(),true}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--	elseif module == "RespawnINcar_counter_GetTimeModData" then 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
Events.OnClientCommand.Add(ForceRespawnInVehicle_OnClientCommand)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
local function autoReset_OldGetGameTime_modData()
	if getGameTime():getModData().SERVER_RIC_vehiclesNUM ~= nil then
    	for i=#getGameTime():getModData().SERVER_RIC_vehiclesNUM,1,-1 do		
			print("old vehicle ".. i .. " is removed to table")
			table.remove(getGameTime():getModData().SERVER_RIC_vehiclesNUM,i)
		end
		getGameTime():getModData().SERVER_RIC_vehiclesNUM = nil
		print("old getGameTime modData is removed SERVER_RIC_vehiclesNUM")
	end
	if getGameTime():getModData().RIC_PLAYERS_GroundPOS ~= nil then
    	for i=#getGameTime():getModData().RIC_PLAYERS_GroundPOS,1,-1 do		
			print("old player ".. i .. " is removed to table")
			table.remove(getGameTime():getModData().RIC_PLAYERS_GroundPOS,i)
		end
		getGameTime():getModData().RIC_PLAYERS_GroundPOS = nil
		print("old getGameTime modData is removed RIC_PLAYERS_GroundPOS")
	end
	if getGameTime():getModData().SERVER_FORCE_RESPAWN_IN_CAR ~= nil then
    	for i=#getGameTime():getModData().SERVER_FORCE_RESPAWN_IN_CAR,1,-1 do		
			print("old vehicle ".. i .. " is removed to table")
			table.remove(getGameTime():getModData().SERVER_FORCE_RESPAWN_IN_CAR,i)
		end
		getGameTime():getModData().SERVER_FORCE_RESPAWN_IN_CAR = nil
		print("old getGameTime modData is removed SERVER_FORCE_RESPAWN_IN_CAR")
	end
	if getGameTime():getModData().serverForceRespawn_PLAYER_POS ~= nil then
		for i=#getGameTime():getModData().serverForceRespawn_PLAYER_POS,1,-1 do		
			print("old player number ".. i .. " is removed to table")
			table.remove(getGameTime():getModData().serverForceRespawn_PLAYER_POS,i)
		end
		getGameTime():getModData().serverForceRespawn_PLAYER_POS = nil 
		print("old getGameTime modData is removed serverForceRespawn_PLAYER_POS")
	end
	if getGameTime():getModData().serverForceRespawn_TargetedVehicle_NUM ~= nil then
		getGameTime():getModData().serverForceRespawn_TargetedVehicle_NUM = nil 
		print("old getGameTime modData is removed serverForceRespawn_TargetedVehicle_NUM")
	end
	if getGameTime():getModData().ObjectForceRespawn_TargetedVehicle_NUM ~= nil then
		getGameTime():getModData().ObjectForceRespawn_TargetedVehicle_NUM = nil 
		print("old getGameTime modData is removed ObjectForceRespawn_TargetedVehicle_NUM")
	end
	print("global old getGameTime modData is checked")
end
-----------------------------	
Events.OnGameTimeLoaded.Add(autoReset_OldGetGameTime_modData)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--																				LOADING IN SERVER [OLD]
--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--ForceRespawnVehicle_counter = 0
--local function ForceRespawnVehicleOnTick(numberTicks)
--	-- print(getCell():getVehicles())
--	if ForceRespawnVehicle_counter < 100 then ForceRespawnVehicle_counter = ForceRespawnVehicle_counter +1 return end
--	ForceRespawnVehicle_counter = 0
--	if gtDATA.SERVER_RIC_vehiclesNUM~=nil then
--		local vehicles=getCell():getVehicles()
--		for i=1,#gtDATA.SERVER_RIC_vehiclesNUM do
--			
--			--local asdasd=0
--			for k=1,vehicles:size() do
--
--				local vehiclez=vehicles:get(k-1)
--				local vehiclesnum = vehiclez:getModData().RIC_vehicleNUM
--				local vehicleseat = vehiclez:getModData().serverForceRespawn_TargetedVehicle_takedSEAT
--
--				if vehiclesnum ~=nil and vehicleseat ~= nil then
--					if vehiclesnum==i and vehicleseat > 0 then
--
--						gtDATA.SERVER_RIC_vehiclesNUM[vehiclesnum]={vehiclez:getX(),vehiclez:getY(),vehiclez:getZ()}--,{true,vehiclez:getId()}}
--						--asdasd=1
--						 break	
--					end
--				end
--			end
--
--			--if asdasd==0 then
--			--	if gtDATA.SERVER_RIC_vehiclesNUM[i]==nil then
--			--		gtDATA.SERVER_RIC_vehiclesNUM[i]={}
--			--	end
--			--	gtDATA.SERVER_RIC_vehiclesNUM[i][4]=false
--			--end
--		end
--	end
--end
--
--Events.OnTick.Add(ForceRespawnVehicleOnTick)

			
--if vehicle:getModData().serverForceRespawn_TargetedVehicle_takedSEAT == 0 then 
			
			
--	count = 0
--	for i=1,#gtDATA.SERVER_FORCE_RESPAWN_IN_CAR do
--	
--		if gtDATA.SERVER_RIC_vehiclesNUM[i] == vDATA.RIC_vehicleNUM then
--			table.remove(gtDATA.SERVER_RIC_vehiclesNUM,i)-- 
--			--print(count)
--			break
--		end --endif
--	end --endfo
--end
--for i=#gtDATA.SERVER_RIC_vehiclesNUM,1,-1 do --INVERSE
	
--ModData.add('name', table)
--ModData.add('name', 'value')
--for i=#getGameTime():getModData().SERVER_vehicleNUM,1,-1 do
--table.remove(getGameTime():getModData().SERVER_vehicleNUM,i)
--table.insert(getGameTime():getModData().SERVER_vehicleNUM,myNewVehicleNum)


--vehicle:transmitCompleteItemToClients()
--local obj = vehicle:getIsoObject()
--obj:transmitModData()
--vehicle:transmitPartModData(vehicle);
--trailer:updateParts();