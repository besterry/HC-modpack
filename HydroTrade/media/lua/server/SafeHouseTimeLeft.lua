local dayInMillis = 1000 * 60 * 60 * 24
--local daysUntilDeletion = 10
local daysUntilDeletion = getServerOptions():getInteger("SafeHouseRemovalTime")

local function checkSafehouses()
    local currentTime = getTimeInMillis()
    local safehouses = SafeHouse.getSafehouseList()
    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)
        if safehouse then
            local lastVisitedTimestamp = safehouse:getLastVisited()
            local lastVisitedDate = os.date("%Y-%m-%d %H:%M:%S", lastVisitedTimestamp / 1000)
            if math.floor((currentTime - lastVisitedTimestamp) / dayInMillis) > daysUntilDeletion-1 then
                local timeLeftMillis = safehouse:getLastVisited() + (daysUntilDeletion * dayInMillis) - currentTime
                local timeLeftDays = math.floor(timeLeftMillis / (dayInMillis))
                local timeLeftHours = math.floor((timeLeftMillis % (dayInMillis)) / (1000 * 60 * 60))
                local timeLeftMinutes = math.floor((timeLeftMillis % (1000 * 60 * 60)) / (1000 * 60))

                print("safehouse=" .. tostring(safehouse:getTitle()) .. "; owner=" .. tostring(safehouse:getOwner()) .. "; LastVisited " .. lastVisitedDate .. "; Time Left: " .. timeLeftHours .. " hours," .. timeLeftMinutes .. " minutes /teleportto " .. tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. ",0")
                --print("safehouse=" .. tostring(safehouse:getTitle()) .. "; owner=" .. tostring(safehouse:getOwner()) .. "; LastVisited " .. lastVisitedDate .. "; Time Left: " .. timeLeftDays .. " days," .. timeLeftHours .. " hours," .. timeLeftMinutes .. " minutes /teleportto " .. tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. ",0")
            end
        end
    end
end

Events.OnServerStarted.Add(checkSafehouses)