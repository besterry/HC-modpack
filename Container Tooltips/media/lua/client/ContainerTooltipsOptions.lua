require "ContainerTooltips"

local options = {
	vanilla_enabled = true,
	renameContainer_enabled = true,
	renameEverything_enabled = true,
}

if ModOptions and ModOptions.getInstance then
	local settings = ModOptions:getInstance(options, "ContainerTooltips", "Container Tooltips")

	local optVanilla = settings:getData("vanilla_enabled")
	optVanilla.name = "UI_ContainerTooltips_Options_Vanilla_Name"
	optVanilla.tooltip = "UI_ContainerTooltips_Options_Vanilla_Tooltip"

	local optRenameContainer = settings:getData("renameContainer_enabled")
	optRenameContainer.name = "UI_ContainerTooltips_Options_RenameContainer_Name"
	optRenameContainer.tooltip = "UI_ContainerTooltips_Options_RenameContainer_Tooltip"

	local optRenameEverything = settings:getData("renameEverything_enabled")
	optRenameEverything.name = "UI_ContainerTooltips_Options_RenameEverything_Name"
	optRenameEverything.tooltip = "UI_ContainerTooltips_Options_RenameEverything_Tooltip"

	SetModOptions(options)
end
