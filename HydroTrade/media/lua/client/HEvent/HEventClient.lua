Events.OnServerCommand.Add(function(module, command, args)
    if module ~= "WPDynamic" or command ~= "ResyncSandbox" then return end

    -- обновляем локальные SandboxVars у клиента
    local options = SandboxOptions.new()
    options:copyValuesFrom(getSandboxOptions())
    local name = (args.which == "water") and "WaterShutModifier" or "ElecShutModifier"
    local opt = options:getOptionByName(name)
    if opt then
        opt:setValue(args.value)
        getSandboxOptions():copyValuesFrom(options)
        getSandboxOptions():toLua()
    end

    -- на клиенте свет тоже обновим на всякий
    if args.power ~= nil then
        getWorld():setHydroPowerOn(args.power)
    end
end)