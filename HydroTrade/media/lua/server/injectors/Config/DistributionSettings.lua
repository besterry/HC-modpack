-- This config supports VS Code annotations! Variables display hints when hovered over.

---@class SpawnConfig
---@field rolls number                   # Amount of passes over the item list.
---@field maxItems number                # Max possible amount of spawned items.
---@field items SpawnItem[]              # List of items with spawn rules.

---@class SpawnItem                      # Entry for the spawnable item. To disable certain spawns simply remove or comment them in the SpawnConfig.
---@field Name string                    # **Required**. Full item ID. Modded modules require prefix (e.g. "ModdedModule.ItemName").<br> "Base.*" is optional for vanilla items as long as there are no duplicates.
---@field Chance number                  # **Required**. Spawn chance as a float from range [0, 1].<br> (0 = 0%, 0.5 = 50%, 1 = 100%).
---@field RoomType string|string[]?      # *Optional*. Internal room name(s). Uses a single string or an array object.<br> For reference check <a href="https://pzwiki.net/wiki/Room_definitions_and_item_spawns">room definitions and item spawns</a>.
---@field ContainerType string|string[]? # *Optional*. Internal container name(s). Uses a single string or an array object.<br> For reference check <a href="https://pzwiki.net/wiki/Room_definitions_and_item_spawns">room definitions and item spawns</a>.

--- Example of some variants of configuration entries.
--- SpawnConfig = {
---     rolls = 5,
---     maxItems = 3,
---     items = {
---         {
---             Name = "Base.item_1",
---             Chance = 0.1,
---             RoomType = {"kitchen", "livingroom"},
---             ContainerType = {"fridge", "cabinet"}
---         },
---         {
---             Name = "ModdedModule.item_2",
---             Chance = 0.25,
---             RoomType = "bedroom",
---             ContainerType = "dresser"
---         },
---         {
---             Name = "item_3",
---             Chance = 0.05
---         }
---     }
--- }

local chance = 0.01                                         --- General spawn chance value to minimize excess code.
local rooms = {                                             --- General array for rooms to minimize excess code.
    "Nurse", "SafehouseLoot", "armystorage", "armytent",
    "dentist", "druglab", "drugshack", "gym", "medclinic",
    "hospitalhallway", "hospitalroom", "hospitalstorage",
    "medical", "medicaloffice", "medicalstorage",
    "morgue", "oldarmy", "oldmedical", "pharmacy",
    "pharmacystorage", "warehouse", "bathroom"
}
local containers = nil                                      --- Container types are unused, but can be added if needed.<br> e.g. {"container1", "container2", "container3"}

--- Distribution configuration.
---@type SpawnConfig
SpawnConfig = {
    rolls = 3,
    maxItems = 2,
    items = {
        { Name = "injectorItems.injector_adrenaline",     Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_ahf1",           Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_btg2a2",         Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_btg3",           Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_etg",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_meldonin",       Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_morphine",       Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_mule",           Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_norepinephrine", Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_obdolbos",       Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_obdolbos2",      Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_p22",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_perfotoran",     Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_pnb",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_propital",       Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_sj1",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_sj6",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_sj9",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_sj12",           Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_trimadol",       Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_xtg",            Chance = chance, RoomType = rooms, ContainerType = containers },
        { Name = "injectorItems.injector_zagustin",       Chance = chance, RoomType = rooms, ContainerType = containers }
    }
}