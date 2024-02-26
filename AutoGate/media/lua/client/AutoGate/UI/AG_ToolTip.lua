if AutoGate == nil then AutoGate = {} end
if AutoGate.ToolTip == nil then AutoGate.ToolTip = {} end

function AutoGate.ToolTip.toolTipPair(context, emptyCtrl, battery)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName(getText("Tooltip_Pairing"))
    --<RGB:0.9,0.5,0> ORANGE
    --<RGB:0.9,0,0> RED
    --<RGB:1,1,1> WHITE
    local colorCtrl = " <RGB:1,1,1> "
    if not emptyCtrl then
        colorCtrl = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = colorCtrl  .. getText("Tooltip_Empty_Gate_Controller")--"Empty Gate Controller <LINE> "

    local colorBatt = " <RGB:1,1,1> "
    if not battery then
        colorBatt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorBatt  .. getText("Tooltip_Car_Battery_Gate_container")--"Car Battery (Gate container) <LINE> "
end

function AutoGate.ToolTip.toolTipOpen(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName(getText("Tooltip_OpenGate"))
    context.toolTip.description = getText("Tooltip_Paired_Controller")--"<RGB:0.9,0,0> Paired Controller <LINE> "
end

function AutoGate.ToolTip.toolTipInstall(context, componets, bt, wm, metalWelding, mechanics, electricity)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName(getText("Tooltip_Install_Components"))

    local colorCpnt = " <RGB:1,1,1> "
    if not componets then
        colorCpnt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = colorCpnt  .. getText("Tooltip_Gate_Components")

    local colorBt = " <RGB:1,1,1> "
    if not bt then
        colorBt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorBt  .. getText("Tooltip_Gate_BlowTorch") 

    local colorWm = " <RGB:1,1,1> "
    if not wm then
        colorWm = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorWm  .. getText("Tooltip_Gate_WeldingMask")

    local colorMW = " <RGB:1,1,1> "
    if metalWelding < 2 then
        colorMW = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorMW  .. getText("Tooltip_Gate_Metalworking")

    local colorMecha = " <RGB:1,1,1> "
    if mechanics < 2 then
        colorMecha = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorMecha  .. getText("Tooltip_Gate_Mechanics")

    local colorEletc = " <RGB:1,1,1> "
    if electricity < 1 then
        colorEletc = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorEletc  .. getText("Tooltip_Gate_Electrical")
end

function AutoGate.ToolTip.toolTipUse(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName(getText("IGUI_UseController"))
    context.toolTip.description = getText("IGUI_Needs_to_be_paired_or_copied") -- "<RGB:0.9,0,0> Needs to be paired or copied <LINE>"
end

function AutoGate.ToolTip.toolTipCopy(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName(getText("IGUI_Copy_Controller"))
    context.toolTip.description = getText("IGUI_Empty_Controller") -- "<RGB:0.9,0,0> Empty Controller <LINE>"
end