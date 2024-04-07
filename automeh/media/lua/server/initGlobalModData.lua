if isClient() then return end
local function AddTableParkingPenlty()
    ModData.getOrCreate("ParkingPenalty")
end

Events.OnInitGlobalModData.Add(AddTableParkingPenlty)