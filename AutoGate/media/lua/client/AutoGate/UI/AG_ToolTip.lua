if AutoGate == nil then AutoGate = {} end
if AutoGate.ToolTip == nil then AutoGate.ToolTip = {} end

function AutoGate.ToolTip.toolTipPair(context, emptyCtrl, battery)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName("Pairing")
    --<RGB:0.9,0.5,0> ORANGE
    --<RGB:0.9,0,0> RED
    --<RGB:1,1,1> WHITE
    local colorCtrl = " <RGB:1,1,1> "
    if not emptyCtrl then
        colorCtrl = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = colorCtrl  .. "Empty Gate Controller <LINE> "

    local colorBatt = " <RGB:1,1,1> "
    if not battery then
        colorBatt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorBatt  .. "Car Battery (Gate container) <LINE> "
end

function AutoGate.ToolTip.toolTipOpen(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName("Open")
    context.toolTip.description = "<RGB:0.9,0,0> Paired Controller <LINE> "
end

function AutoGate.ToolTip.toolTipInstall(context, componets, bt, wm, metalWelding, mechanics, electricity)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName("Install Components")

    local colorCpnt = " <RGB:1,1,1> "
    if not componets then
        colorCpnt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = colorCpnt  .. " Gate Components <LINE> "

    local colorBt = " <RGB:1,1,1> "
    if not bt then
        colorBt = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorBt  .. " BlowTorch <LINE> "

    local colorWm = " <RGB:1,1,1> "
    if not wm then
        colorWm = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorWm  .. " WeldingMask <LINE> "

    local colorMW = " <RGB:1,1,1> "
    if metalWelding < 2 then
        colorMW = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorMW  .. "Metalworking - Lvl 2 <LINE> "

    local colorMecha = " <RGB:1,1,1> "
    if mechanics < 2 then
        colorMecha = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorMecha  .. "Mechanics - Lvl 2 <LINE> "

    local colorEletc = " <RGB:1,1,1> "
    if electricity < 1 then
        colorEletc = " <RGB:0.9,0,0> "
    end
    context.toolTip.description = context.toolTip.description .. colorEletc  .. "Electrical - Lvl 1 <LINE> "
end

function AutoGate.ToolTip.toolTipUse(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName("Use")
    context.toolTip.description = "<RGB:0.9,0,0> Needs to be paired or copied <LINE>"
end

function AutoGate.ToolTip.toolTipCopy(context)
    context.toolTip = ISToolTip:new()
    context.toolTip:initialise()
    context.toolTip:setVisible(true)
    context.toolTip:setName("Copy")
    context.toolTip.description = "<RGB:0.9,0,0> Empty Controller <LINE>"
end