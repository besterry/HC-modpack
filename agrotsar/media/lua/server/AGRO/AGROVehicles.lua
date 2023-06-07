
if not AGROVehicles then AGROVehicles = {} end
if not AGROUtils then AGROUtils = {} end
if not AGROVehicles.CheckEngine then AGROVehicles.CheckEngine = {} end
if not AGROVehicles.CheckOperate then AGROVehicles.CheckOperate = {} end
if not AGROVehicles.ContainerAccess then AGROVehicles.ContainerAccess = {} end
if not AGROVehicles.Create then AGROVehicles.Create = {} end
if not AGROVehicles.Init then AGROVehicles.Init = {} end
if not AGROVehicles.InstallComplete then AGROVehicles.InstallComplete = {} end
if not AGROVehicles.InstallTest then AGROVehicles.InstallTest = {} end
if not AGROVehicles.UninstallComplete then AGROVehicles.UninstallComplete = {} end
if not AGROVehicles.UninstallTest then AGROVehicles.UninstallTest = {} end
if not AGROVehicles.Update then AGROVehicles.Update = {} end
if not AGROVehicles.Use then AGROVehicles.Use = {} end

function AGROVehicles.AgroPlowshareModel(vehicle, part)
    -- print("AgroPlowshareModel ")
    -- print(part)
    if not part then return end
    local item = part:getInventoryItem()
    if not item then
        part:setModelVisible("Up", false)
        part:setModelVisible("Down", false)
    else
        if vehicle:getModData().isActivated then
            part:setModelVisible("Up", false)
            part:setModelVisible("Down", true)
        else
            part:setModelVisible("Up", true)
            part:setModelVisible("Down", false)
        end
    end
end

function AGROVehicles.Create.AgroPlowshare(vehicle, part)
    Vehicles.Create.Default(vehicle, part)
    AGROVehicles.AgroPlowshareModel(vehicle, part)
    vehicle:doDamageOverlay()
end

function AGROVehicles.Init.AgroPlowshare(vehicle, part)
    AGROVehicles.AgroPlowshareModel(vehicle, part)
    vehicle:doDamageOverlay()
end

function AGROVehicles.InstallComplete.AgroPlowshare(vehicle, part)
    AGROVehicles.AgroPlowshareModel(vehicle, part)
    vehicle:doDamageOverlay()
end

function AGROVehicles.UninstallComplete.AgroPlowshare(vehicle, part, item)
    AGROVehicles.AgroPlowshareModel(vehicle, part)
    vehicle:doDamageOverlay()
end

function AGROVehicles.Update.AgroPlowshare(vehicle, part, elapsedMinutes)
    AGROVehicles.AgroPlowshareModel(vehicle, part)
    vehicle:doDamageOverlay()
end

--function AGROVehicles.Use.AgroPlowshare(vehicle)
--	vehicle:getModData().isActivated = not vehicle:getModData().isActivated
--	vehicle:transmitModData()
--	-- AGROVehicles.AgroPlowshareModel(vehicle, vehicle:getPartById("AgroPlowshareLeft"))
--	-- AGROVehicles.AgroPlowshareModel(vehicle, vehicle:getPartById("AgroPlowshareRight"))
--	vehicle:updateParts();
--end