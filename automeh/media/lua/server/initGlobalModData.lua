if isClient() then return end
local function AddTableParkingPenlty()
    ModData.getOrCreate("ParkingPenalty")
    ModData.getOrCreate("PersonalGarage")
end

Events.OnInitGlobalModData.Add(AddTableParkingPenlty)