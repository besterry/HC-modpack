if isClient() then return end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RICserver = {}
local seatNameMD = "serverForceRespawn_playerName"
local server = isServer()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function initGlobalModData()
    RICserver.DATA = getGameTime():getModData()
    RICserver.DATA.RIC_PLAYERS_POS = RICserver.DATA.RIC_PLAYERS_POS or {}
    RICserver.ModDataTest()
end
Events.OnInitGlobalModData.Add(initGlobalModData);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.ModDataTest()
	if RICserver.DATA.RIC_PLAYERS_POS then
		local count = 0
     	for i,v in pairs(RICserver.DATA.RIC_PLAYERS_POS) do
     		local fail
     		if v and type(v) == "table" then
     			local c = #v ~= 4
     			local x = not v[1] or type(v[1]) ~= "number" 
     			local y = not v[2] or type(v[2]) ~= "number" 
     			local z = not v[3] or type(v[3]) ~= "number"
     			local r = v[4] == nil or (type(v[4]) ~= "boolean" and type(v[4]) ~= "number")
     			if c or x or y or z or r  then 
     				fail = true 
     			end
     		else
     			fail = true
     		end
     		if fail then count = count+1 ;  RICserver.DATA.RIC_PLAYERS_POS[tostring(i)] = nil ; print("............ RIC mod INFO: FAIL SAVE ".. tostring(i)) end
     	end
     	--print("............ RIC mod INFO: FAIL SAVE ModData is initialized, fail count: "..tostring(count))
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--																							SEND COMMANDS TO CLIENT FUNCTION
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.SendServerCommand(player,command,args)
    if not server then 
    	local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
    	RIC[command](player,args,command)
    	--print("TEST....sendServerCommand SP")
    else 		
    	sendServerCommand(player,"RespawnINcar",command,args) 
    	--print("TEST....sendServerCommand MP")
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																									-- fONCTIONS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.SavePlayer(object,name,respawnType) -- type == true then ground, if type == numero then in vehicle, if not type then position is nil
	if not name or not object or respawnType == nil then return end
	local AvatarMod = getActivatedMods():contains("AvatarOffline") or getActivatedMods():contains("Avatar USER")
	local save = respawnType == true or type(respawnType) == "number"
	if save or AvatarMod then
		local x,y,z = object:getX(),object:getY(),object:getZ()
		if x and y and z then RICserver.DATA.RIC_PLAYERS_POS[name] = {x,y,z,respawnType} end
	else
		RICserver.DATA.RIC_PLAYERS_POS[name] = nil
	end
	--print("TEST.... save player ".. name .." from floor ".. tostring(respawnType))
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.PreSavePlayer(name)
	if not name then return end
	RICserver.DATA.RIC_PLAYERS_POS = RICserver.DATA.RIC_PLAYERS_POS or {}
	RICserver.DATA.RIC_PLAYERS_POS[name] = RICserver.DATA.RIC_PLAYERS_POS[name] or {nil,nil,nil,false}
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.SaveVehicle(x,y,name,vehicleNUM)
	if not name or not x or not y or vehicleNUM == nil then return end
	RICserver.DATA.RIC_PLAYERS_POS[name] = {x,y,0,vehicleNUM}
	--print("TEST.... save Vehicle ".. name .." in car n ".. tostring(vehicleNUM))
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.InitializeVehicle()
	RICserver.DATA.RIC_vehicleNUM = RICserver.DATA.RIC_vehicleNUM or 0
	RICserver.DATA.RIC_vehicleNUM = RICserver.DATA.RIC_vehicleNUM +1
	return RICserver.DATA.RIC_vehicleNUM
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.AllowVehicle(name,vehicleNUM)
	if not name or not RICserver.DATA.RIC_PLAYERS_POS[name] then return end
	local playerNUM = RICserver.DATA.RIC_PLAYERS_POS[name][4]
	return playerNUM == vehicleNUM
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.PreSaveVehicle(vehicle,vDATA,vehicleNUM,maxSeat)
	local x,y = vehicle:getX(),vehicle:getY()
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local name = vDATA[seatNameMD..counter]
		if name then 
			if RICserver.AllowVehicle(name,vehicleNUM) then 
				RICserver.SaveVehicle(x,y,name,vehicleNUM)
			else
				vDATA[seatNameMD..counter] = nil 
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.PreSavePlayers(vehicle,vDATA,vehicleNUM,maxSeat,name)
	local x,y = vehicle:getX(),vehicle:getY()
	local counter = 0
	local freeSeat
	local allReady
	for i = 1,maxSeat do
		counter = counter+1
		local seatName = vDATA[seatNameMD..counter]
		if seatName then
			local isPlayer = name == seatName
			local goodName = not isPlayer or (isPlayer and not allReady)
			if goodName and RICserver.AllowVehicle(seatName,vehicleNUM) then 
				if isPlayer then allReady = true end
				RICserver.SaveVehicle(x,y,seatName,vehicleNUM)
			else
				vDATA[seatNameMD..counter] = nil 
				seatName = nil
			end
		end
		if not seatName and not freeSeat then freeSeat = counter end
	end
	return allReady, freeSeat
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.CarExit(vehicle,vDATA,vehicleNUM,maxSeat,name) 
	RICserver.SavePlayer(vehicle,name,false)
	RICserver.PreSaveVehicle(vehicle,vDATA,vehicleNUM,maxSeat)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.MyNameInCar(vDATA,maxSeat,name)
    local counter = 0
    for i=1,maxSeat do
        counter = counter+1
        if vDATA[seatNameMD..counter] and vDATA[seatNameMD..counter] == name then return true end
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.SearchCarToSavePlayer(player,name,save)
	if RICserver.DATA.RIC_PLAYERS_POS[name] then
		local playerNUM = RICserver.DATA.RIC_PLAYERS_POS[name][4]
		if playerNUM and type(playerNUM) == "number" then
			local vehicles = getWorld():getCell():getVehicles()			
			for i=1,vehicles:size() do
				local vehicle = vehicles:get(i-1)
				local vehicle,vDATA,vehicleNUM,maxSeat = RICserver.GetVehicleData(nil,"SearchCarToSavePlayer",vehicle)
				if vehicleNUM == playerNUM then
					if RICserver.MyNameInCar(vDATA,maxSeat,name) then
						if save then
							RICserver.PreSaveVehicle(vehicle,vDATA,vehicleNUM,maxSeat)
						else
							RICserver.CarExit(vehicle,vDATA,vehicleNUM,maxSeat,name)
						end
						--print("............ RIC mod INFO: SearchCarToSavePlayer vehicleNUM == playerNUM from name:"..tostring(name).." for save: "..tostring(save))
						return
					end
				end
			end	
			--print("............ RIC mod INFO: SearchCarToSavePlayer from name:"..tostring(name).." for save: "..tostring(save))	
		end
	end
	if not save then RICserver.SavePlayer(player,name,false) end --; print("TEST....SearchCarToSavePlayer vehicle not founded") 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.RedefineVehicleNamelist(vDATA,vehicleNUM,maxSeat)
	if vehicleNUM == nil then return end
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local name = vDATA[seatNameMD..counter]
		if name then
			if not RICserver.AllowVehicle(name,vehicleNUM) then vDATA[seatNameMD..counter] = nil end
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.ExpulsePlayer(vDATA,vehicleNUM,maxSeat,player,nameSeat,saveType,command)
	if saveType == "FALSE" then
		local vehicle = player:getVehicle()
		if not vehicle or (vehicle and nameSeat ~= player:getUsername()) then 
			RICserver.SavePlayer(player,nameSeat,false)
		end
	elseif saveType == "TRUE" then 
		local choice
		if getActivatedMods():contains("AvatarOffline") or getActivatedMods():contains("Avatar USER") then
			local AvatarModData = ModData.get("AvatarModData");
			if AvatarModData and AvatarModData[nameSeat] then
				choice = AvatarModData[nameSeat].TextureChoice--ModData.get("AvatarMOD")[nameSeat]
				AvatarModData[nameSeat].Position = {player:getX(),player:getY(),player:getZ()}
			end
		end
		RICserver.SavePlayer(player,nameSeat,true)
		RICserver.SendServerCommand(player,command,{nameSeat,choice}) 
	end
	RICserver.RedefineVehicleNamelist(vDATA,vehicleNUM,maxSeat) 
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.PreExpulsePlayer(vehicle,vDATA,vehicleNUM,maxSeat,player,playerName,nameSeat,command)
	local saveType = "TRUE"
	if not nameSeat then 
		local args = {"IGUI_There_is_no_one_on_the_seat",true}
		local command = "SayText"
		RICserver.SendServerCommand(player,command,args) 
		return 
	elseif playerName == nameSeat then
		saveType = "FALSE"
	elseif server then
		local playerOnline = RICserver.GetPlayerOnline(nameSeat)
		if playerOnline then
			local vehicleOnline = playerOnline:getVehicle()
			saveType = "NONE"
			if RICserver.DATA.RIC_PLAYERS_POS[nameSeat] and vehicleOnline then
				local numOnline = RICserver.DATA.RIC_PLAYERS_POS[nameSeat][4]
				if vehicleOnline == vehicle or numOnline == vehicleNUM then 
					saveType = "PRESENT"
				end
			end
		end
	end
	if saveType == "PRESENT" then
		local args = {"IGUI_player_is_present_inside",true}
		local command = "SayText"
		RICserver.SendServerCommand(player,command,args) 
		return
	end 
	RICserver[command](vDATA,vehicleNUM,maxSeat,player,nameSeat,saveType,command)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.PreExpulsePlayersFromVehicle(vehicle,vDATA,vehicleNUM,maxSeat,player,playerName,command)
	local counter = 0
	for i=1,maxSeat do
		counter = counter+1
		local nameSeat = vDATA[seatNameMD..counter]
		if nameSeat then
			RICserver.PreExpulsePlayer(vehicle,vDATA,vehicleNUM,maxSeat,player,playerName,nameSeat,command)
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.GetPlayerOnline(name)
	local onlineUsers = getOnlinePlayers()
	for i=0, onlineUsers:size()-1 do
		local playerOnline = onlineUsers:get(i)
		local nameOnline = playerOnline:getUsername()
		if playerOnline and nameOnline == name then
			return playerOnline
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RICserver.GetVehicleData(id,command,vehicle)
	local vehicle = vehicle or getVehicleById(id)
	if not vehicle then if command then print("............ RIC mod INFO: "..tostring(command).." | attempt to obtain vehicle failed !! (Certainly because your server has too much latency)") end return end
	local maxSeat = vehicle:getMaxPassengers()
	local vDATA   = vehicle:getModData()
	vDATA.RIC_vehicleNUM = vDATA.RIC_vehicleNUM or RICserver.InitializeVehicle()
	return vehicle,vDATA,vDATA.RIC_vehicleNUM,maxSeat
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
return RICserver