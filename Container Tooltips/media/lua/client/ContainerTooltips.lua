require "NestedContainers"
require "RenameContainers/ISInventoryPage"
require "RenameEverything_Containers"
local ContainerTooltips = {}

-- OPTIONS
ContainerTooltips.options = {
	vanilla_enabled = true,
	renameContainer_enabled = true,
	renameEverything_enabled = true,
}

SetModOptions = function(options)
	ContainerTooltips.options = options
end

-- VANILLA TOOLTIPS
local vanilla_refreshBackpacks = ISInventoryPage.refreshBackpacks
function ISInventoryPage:refreshBackpacks()
    vanilla_refreshBackpacks(self)
    ContainerTooltips.backpacks = self.backpacks
    ContainerTooltips:updateNames()
end

-- UPDATE TOOLTIPS AFTER RENAME VIA MODS
local original_onRenameContainerClick = ISInventoryPage.onRenameContainerClick
if(original_onRenameContainerClick ~= nil) then
    function ISInventoryPage:onRenameContainerClick(button, inventory)
        original_onRenameContainerClick(self, button, inventory)
        ContainerTooltips:updateNames()
    end
end

function ContainerTooltips:updateNames()
    for _, containerButton in ipairs(ContainerTooltips.backpacks) do
        local modData = containerButton.inventory:getParent() and containerButton.inventory:getParent():getModData()

        if modData and ContainerTooltips.options.renameContainer_enabled and modData.RenameContainer_CustomName then
            containerButton.tooltip = modData.RenameContainer_CustomName
        elseif modData and ContainerTooltips.options.renameEverything_enabled and modData.renameEverything_name then
            containerButton.tooltip = modData.renameEverything_name
        elseif ContainerTooltips.options.vanilla_enabled then
            containerButton.tooltip = containerButton.name
        end
    end
end