NFHotkeys = NFHotkeys or {}

NFHotkeys.bindings = {
    {
        value = '[NoctisFalco]'
    },
    {
        value = 'NFLootAll',
        action = NFHotkeys.lootAll,
        key = 0
    },
    {
        value = 'NFLootDrop',
        action = NFHotkeys.lootDrop,
        key = 0
    },
    {
        value = 'NFEnterVehicle',
        action = NFHotkeys.enterVehicle,
        key = 0
    },
    {
        value = 'Toggle mode',
        action = NFHotkeys.toggleMovable
    }
}

for _, bind in ipairs(NFHotkeys.bindings) do
    if bind.key or not bind.action then
        table.insert(keyBinding, { value = bind.value, key = bind.key })
    end
end

-- *********************

local function onKeyPressed(key)
    local action
    for _, bind in ipairs(NFHotkeys.bindings) do
        if key == getCore():getKey(bind.value) then
            action = bind.action
            break
        end
    end

    if not action then
        return
    end

    if isGamePaused() then
        return
    end

    local player = getPlayer()
    if not player or player:isDead() then
        return
    end

    action(key)
end

Events.OnGameStart.Add(function()
    Events.OnKeyPressed.Add(onKeyPressed)
end)