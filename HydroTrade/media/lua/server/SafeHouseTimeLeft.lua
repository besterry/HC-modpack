local dayInMillis = 1000 * 60 * 60 * 24
local daysUntilDeletion = getServerOptions():getInteger("SafeHouseRemovalTime")

local function checkSafehouses()
    local currentTime = getTimeInMillis()
    print("daysUntilDeletion:",daysUntilDeletion) --240
    print("currentTime:",currentTime) --  1687855316931
    local safehouses = SafeHouse.getSafehouseList()
    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)
        if safehouse then
            local lastVisitedTimestamp = safehouse:getLastVisited()
            print("lastVisitedTimestamp:",lastVisitedTimestamp) --1687245174202
            local lastVisitedDate = os.date("%Y-%m-%d %H:%M:%S", lastVisitedTimestamp / 1000)

            local timeLeftMillis = lastVisitedTimestamp + (daysUntilDeletion/24 * dayInMillis) - currentTime
            local daysRemaining = math.floor(timeLeftMillis / (dayInMillis))
            print("daysRemaining:",daysRemaining .. " Owner:"..tostring(safehouse:getOwner())) -- -3
            if daysRemaining <= 1 then
                local timeLeftMillis = lastVisitedTimestamp + (daysUntilDeletion/24 * dayInMillis) - currentTime
                local timeLeftDays = math.floor(timeLeftMillis / (dayInMillis))
                local timeLeftHours = math.floor((timeLeftMillis % (dayInMillis)) / (1000 * 60 * 60))
                local timeLeftMinutes = math.floor((timeLeftMillis % (1000 * 60 * 60)) / (1000 * 60))
                local msg = ("safehouse=" .. tostring(safehouse:getTitle()) .. "; owner=" .. tostring(safehouse:getOwner()) .. "; LastVisited:" .. lastVisitedDate .. "; Time Left:" .. timeLeftDays .. " days, ".. timeLeftHours .. " hours, " .. timeLeftMinutes .. " minutes, /teleportto " .. tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. ",0")
                writeLog("SHTimeLeft",msg)
            end
        end
    end
end

Events.OnServerStarted.Add(checkSafehouses)