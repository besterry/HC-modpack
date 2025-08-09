-- if POS then
-- 	return print("ERROR: Can't enable ZONES cos POS is already enabled!")
-- end
POS = {}
local ZONES_POS = POS
local admin
local textManager = getTextManager();

local screenX = 150; --65
local screenY = 5; --13

local cache_room = nil
local cache_room_name = ''
local cache_cnt_room_sq = 0
local is_claus = nil -- if player is claustrophobic

local function getZone(player, x,y)
	local s = ''
	
	--Zones
	local zones = getWorld():getMetaGrid():getZonesAt(x, y, 0);
	ZONES_POS.zonelist = zones
	if zones then
		for i=0,zones:size()-1 do
			local zone = zones:get(i)
			local name = zone:getName()
			local typ = zone:getType()
			if name and name ~= "" or typ and typ ~= "" then
				if s ~= '' then
					s = s .. ' ; ';
				end
				--do
				--	return tostring(name) .. ' / ' .. tostring(typ)
				--end
				if typ == 'Vegitation' then
					typ = 'Vegetation'
				end
				if name and name ~= "" and typ and typ ~= "" then
					s = s .. tostring(typ) .. '/' .. tostring(name) 
				elseif typ and typ ~= "" then
					s = s .. tostring(typ) --.. '/?'
				else
					s = s .. '?/'.. tostring(name)
				end
			end
		end
	end

	--Room name
	local square = player:getSquare()
	if square then
		local room = square:getRoom()
		if room then
			if room ~= cache_room then
				cache_room = room
				cache_room_name = room:getName()
				if is_claus then --for "Claustophobic" (mistype in game code)
					local list = room:getSquares()
					if list then
						cache_cnt_room_sq = list:size()
					end
				end
			end
			if s ~= '' then
				s = s .. ' ; '
			end
			s = s .. tostring(cache_room_name)
			if is_claus then
				s = s .. '(' .. tostring(cache_cnt_room_sq) .. ')'
			end
		end
		
		--Custom server message
		if ZONES_POS.CustomServerFn then
			local custom_str = ZONES_POS.CustomServerFn(square,x,y)
			if custom_str ~= nil and custom_str ~= '' then
				if s ~= '' then
					s = s .. ' ; ' .. tostring(custom_str)
				else
					s = tostring(custom_str)
				end
			end
		end
	end


	if s == '' then
		s = '???'
	end
	ZONES_POS.s=s
	return s
end


local floor = math.floor
local function round(x) --fixed
	return floor(x);
end

local player = nil
local cache_player_x = nil
local cache_player_y = nil
local cache_pos = ""
local cache_zone = ""
local floor = math.floor
local cache_online = ""

local function getOnlineInfo()
    if isClient() then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            local currentPlayers = onlinePlayers:size()
            local maxPlayers = getServerOptions():getOptionByName("MaxPlayers"):getValue()
            return "Online " .. currentPlayers .. "/" .. maxPlayers
        end
    end
    return "Online ?/?"
end

local function getCoords()
	if player then 
		admin = player:getAccessLevel()=="Admin"
	else
		admin = false
		return
	end
	--print("Cycle")
    if admin then
        local playerX = floor(player:getX());
        local playerY = floor(player:getY());
        if playerX ~= cache_player_x or playerY ~= cache_player_y then
            cache_player_x = playerX
            cache_player_y = playerY
			cache_online = getOnlineInfo()
            cache_pos = playerX .. " x " .. playerY .. " | " .. cache_online
            cache_zone = "Zone: " .. getZone(player, playerX, playerY)			
        end
        textManager:DrawString(UIFont.Large, screenX, screenY, cache_pos, 0.1, 0.8, 1, 1);
        textManager:DrawString(UIFont.Large, screenX, screenY + 20, cache_zone, 0.1, 0.8, 1, 1);
		--textManager:DrawString(UIFont.Large, screenX, screenY + 40, cache_online, 0.1, 0.8, 1, 1);
    end
end

Events.OnGameStart.Add(function()
	Events.OnPostUIDraw.Add(getCoords);
end)

Events.OnCreatePlayer.Add(function()
	player = getPlayer()	
	if player then
		is_claus = player:HasTrait("Claustophobic")
	end
end)

--[[
Examples of custom server message:

Events.OnGameStart.Add(function()
	POS.CustomServerFn = function() return "My Custom Server" end
end)


Events.OnGameStart.Add(function()
	if POS then
		POS.CustomServerFn = function(square, x, y) --Redboid PvE Zone
			if x >= 2098 and x <= 4147 and y >= 12712 and y <= 13908 then
				return "PvE"
			end
		end
	end
end)
--]]

