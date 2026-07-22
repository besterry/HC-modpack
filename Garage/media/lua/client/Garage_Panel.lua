-- Author: FD
-- Окно списка транспорта в гараже: поиск, фильтры, детали, выдача
-- Стиль: ночной гаражный бокс (асфальт / сталь / натриевый свет)

Garage_Panel = ISPanel:derive("Garage_Panel")
Garage_Panel.instance = nil

Garage_PreviewScene = ISUI3DScene:derive("Garage_PreviewScene")

function Garage_PreviewScene:new(x, y, width, height)
    local o = ISUI3DScene.new(self, x, y, width, height)
    return o
end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local MAX_SIZE_KB = 700
local PREVIEW_H = 150
local PREVIEW_VEH = "garagePreviewVeh"

-- Палитра бокса
local C = {
    bg = { r = 0.07, g = 0.085, b = 0.10, a = 0.94 },
    border = { r = 0.38, g = 0.44, b = 0.48, a = 1 },
    steel = { r = 0.22, g = 0.26, b = 0.30, a = 0.92 },
    inset = { r = 0.05, g = 0.06, b = 0.08, a = 0.88 },
    sodium = { r = 0.92, g = 0.68, b = 0.16, a = 1 },
    sodiumDim = { r = 0.55, g = 0.42, b = 0.12, a = 1 },
    text = { r = 0.88, g = 0.90, b = 0.92, a = 1 },
    textDim = { r = 0.62, g = 0.66, b = 0.70, a = 1 },
    select = { r = 0.92, g = 0.68, b = 0.16 },
    alt = { r = 0.12, g = 0.14, b = 0.16 },
    btn = { r = 0.14, g = 0.17, b = 0.20, a = 0.95 },
    btnHover = { r = 0.22, g = 0.26, b = 0.30, a = 0.95 },
    btnAccent = { r = 0.28, g = 0.22, b = 0.08, a = 0.95 },
}

local KEY_PARTS = {
    { id = "Engine", key = "IGUI_GaragePanel_Part_Engine" },
    { id = "Battery", key = "IGUI_GaragePanel_Part_Battery" },
    { id = "GasTank", key = "IGUI_GaragePanel_Part_GasTank" },
    { id = "TireFrontLeft", key = "IGUI_GaragePanel_Part_TireFL" },
    { id = "TireFrontRight", key = "IGUI_GaragePanel_Part_TireFR" },
    { id = "TireRearLeft", key = "IGUI_GaragePanel_Part_TireRL" },
    { id = "TireRearRight", key = "IGUI_GaragePanel_Part_TireRR" },
    { id = "Muffler", key = "IGUI_GaragePanel_Part_Muffler" },
}

local function hsvToRgb(h, s, v)
    h = tonumber(h) or 0
    s = tonumber(s) or 0
    v = tonumber(v) or 0
    if h > 1 then h = h / 360 end
    if h < 0 then h = 0 end
    if s < 0 then s = 0 elseif s > 1 then s = 1 end
    if v < 0 then v = 0 elseif v > 1 then v = 1 end
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v, t, p end
    if i == 1 then return q, v, p end
    if i == 2 then return p, v, t end
    if i == 3 then return p, q, v end
    if i == 4 then return t, p, v end
    return v, p, q
end

-- У модовых/улучшенных авто цвет часто в skin-текстуре, а HSV = белый/дефолт.
-- VehicleScript.Skin.texture в Kahlua недоступен как поле, поэтому путь кладём в data.skinTexture при загоне.
local function getSkinVisual(data)
    if not data then
        return nil
    end
    local texName = data.skinTexture
    if not texName or texName == "" or texName == "BOGUS" then
        return nil
    end
    local tex = getTexture("media/textures/" .. texName .. ".png")
    if not tex then
        tex = getTexture(texName)
    end
    local short = texName
    local slash = string.find(short, "/[^/]*$")
    if slash then
        short = string.sub(short, slash + 1)
    end
    short = string.gsub(short, "^[Vv]ehicles_", "")
    short = string.gsub(short, "^vehicle_", "")
    local colorTail = string.match(short, "_([%a]+%d*)$")
    if colorTail then
        short = colorTail
    end
    return {
        texture = tex,
        label = short,
        idx = data.skinIdx,
    }
end

local function drawColorSwatch(ui, x, y, size, data)
    local skin = getSkinVisual(data)
    if skin and skin.texture then
        ui:drawTextureScaledAspect(skin.texture, x, y, size, size, 1, 1, 1, 1)
        ui:drawRectBorder(x, y, size, size, 1, 0.15, 0.16, 0.18)
        return skin
    end
    local r, g, b = 0.4, 0.4, 0.4
    if data and data.HSV then
        r, g, b = hsvToRgb(data.HSV[1], data.HSV[2], data.HSV[3])
    end
    ui:drawRect(x, y, size, size, 1, r, g, b)
    ui:drawRectBorder(x, y, size, size, 1, 0.15, 0.16, 0.18)
    return skin
end

local function condColor(cond)
    if cond == nil then
        return 0.55, 0.58, 0.60
    end
    if cond >= 70 then
        return 0.45, 0.82, 0.55
    elseif cond >= 40 then
        return 0.92, 0.72, 0.22
    else
        return 0.90, 0.38, 0.32
    end
end

local function vehicleDisplayName(data)
    if not data or not data.scriptName then
        return "?"
    end
    return getText("IGUI_VehicleName" .. getText(data.scriptName))
end

local function partInfo(data, partId)
    local partData = data and data.partData and data.partData[partId]
    if not partData then
        return nil, false, nil, true
    end
    if partData.condition == nil and not partData.installItem then
        return nil, true, partData, false
    end
    return partData.condition, false, partData, false
end

local function avgCondition(data)
    if not data or not data.partData then
        return nil
    end
    local sum, count = 0, 0
    for _, pd in pairs(data.partData) do
        if pd and pd.condition ~= nil then
            sum = sum + pd.condition
            count = count + 1
        end
    end
    if count == 0 then
        return nil
    end
    return math.floor(sum / count + 0.5)
end

local function missingPartsCount(data)
    if not data or not data.partData then
        return 0
    end
    local n = 0
    for _, pd in pairs(data.partData) do
        if pd and pd.condition == nil and not pd.installItem then
            n = n + 1
        end
    end
    return n
end

local function parkedDays(data)
    if not data or not data.startDay then
        return 0
    end
    local days = math.floor((getWorld():getWorldAgeDays() or 0) - (data.startDay or 0))
    if days < 0 then days = 0 end
    return days
end

local function styleButton(btn, accent)
    btn.backgroundColor = accent and {
        r = C.btnAccent.r, g = C.btnAccent.g, b = C.btnAccent.b, a = C.btnAccent.a
    } or {
        r = C.btn.r, g = C.btn.g, b = C.btn.b, a = C.btn.a
    }
    btn.backgroundColorMouseOver = {
        r = C.btnHover.r, g = C.btnHover.g, b = C.btnHover.b, a = C.btnHover.a
    }
    btn.borderColor = accent and {
        r = C.sodium.r, g = C.sodium.g, b = C.sodium.b, a = 0.95
    } or {
        r = C.border.r, g = C.border.g, b = C.border.b, a = 0.9
    }
end

function Garage_Panel:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function Garage_Panel:createChildren()
    ISPanel.createChildren(self)

    local pad = 10
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)
    local entryHgt = math.max(22, FONT_HGT_SMALL + 4)
    local comboH = math.max(22, FONT_HGT_SMALL + 4)
    local y = pad

    self.ownerFilter = "all"
    self.condFilter = "all"
    self.sortMode = "name"

    self.titleLabel = ISLabel:new(pad, y, FONT_HGT_MEDIUM, getText("IGUI_GaragePanel_Title"), C.sodium.r, C.sodium.g, C.sodium.b, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self.titleLabel:instantiate()
    self:addChild(self.titleLabel)

    self.capLabel = ISLabel:new(self.width - pad - 220, y + 2, FONT_HGT_SMALL, "", C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small, true)
    self.capLabel:initialise()
    self.capLabel:instantiate()
    self:addChild(self.capLabel)

    y = y + FONT_HGT_MEDIUM + 10
    self.stripeY = y - 5

    self.filterLabel = ISLabel:new(pad, y + 2, FONT_HGT_SMALL, getText("IGUI_GaragePanel_Search"), C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small, true)
    self.filterLabel:initialise()
    self.filterLabel:instantiate()
    self:addChild(self.filterLabel)

    local filterX = pad + getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_GaragePanel_Search")) + 8
    self.filterEntry = ISTextEntryBox:new("", filterX, y, self.width - filterX - pad, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry.backgroundColor = { r = C.inset.r, g = C.inset.g, b = C.inset.b, a = 1 }
    self.filterEntry.borderColor = { r = C.border.r, g = C.border.g, b = C.border.b, a = 1 }
    self.filterEntry.onTextChange = function()
        if Garage_Panel.instance then
            Garage_Panel.instance:refreshList()
        end
    end
    self:addChild(self.filterEntry)

    y = y + entryHgt + 6

    local comboW = math.floor((self.width - pad * 2 - 16) / 3)
    self.ownerCombo = ISComboBox:new(pad, y, comboW, comboH, self, self.onFilterCombo)
    self.ownerCombo:initialise()
    self.ownerCombo:instantiate()
    self.ownerCombo:addOption(getText("IGUI_GaragePanel_OwnerAll"))
    self.ownerCombo:addOption(getText("IGUI_GaragePanel_OwnerMine"))
    self.ownerCombo:addOption(getText("IGUI_GaragePanel_OwnerOthers"))
    self:addChild(self.ownerCombo)

    self.condCombo = ISComboBox:new(pad + comboW + 8, y, comboW, comboH, self, self.onFilterCombo)
    self.condCombo:initialise()
    self.condCombo:instantiate()
    self.condCombo:addOption(getText("IGUI_GaragePanel_CondAll"))
    self.condCombo:addOption(getText("IGUI_GaragePanel_CondGood"))
    self.condCombo:addOption(getText("IGUI_GaragePanel_CondMid"))
    self.condCombo:addOption(getText("IGUI_GaragePanel_CondBad"))
    self.condCombo:addOption(getText("IGUI_GaragePanel_CondMissing"))
    self:addChild(self.condCombo)

    self.sortCombo = ISComboBox:new(pad + (comboW + 8) * 2, y, comboW, comboH, self, self.onFilterCombo)
    self.sortCombo:initialise()
    self.sortCombo:instantiate()
    self.sortCombo:addOption(getText("IGUI_GaragePanel_SortName"))
    self.sortCombo:addOption(getText("IGUI_GaragePanel_SortCond"))
    self.sortCombo:addOption(getText("IGUI_GaragePanel_SortPlate"))
    self.sortCombo:addOption(getText("IGUI_GaragePanel_SortSize"))
    self.sortCombo:addOption(getText("IGUI_GaragePanel_SortDays"))
    self:addChild(self.sortCombo)

    y = y + comboH + 8
    self.listY = y

    local listW = math.floor(self.width * 0.48)
    local listH = self.height - y - btnHgt - pad * 2 - 4
    self.detailX = pad + listW + 8
    self.detailY = y
    self.detailW = self.width - self.detailX - pad
    self.detailH = listH
    self.previewH = PREVIEW_H
    self.detailTextY = self.detailY + self.previewH + 6

    self.vehicleList = ISScrollingListBox:new(pad, y, listW, listH)
    self.vehicleList:initialise()
    self.vehicleList:instantiate()
    self.vehicleList.itemheight = FONT_HGT_SMALL * 2 + 8
    self.vehicleList.selected = 0
    self.vehicleList.joypadParent = self
    self.vehicleList.font = UIFont.Small
    self.vehicleList.drawBorder = true
    self.vehicleList.backgroundColor = { r = C.inset.r, g = C.inset.g, b = C.inset.b, a = C.inset.a }
    self.vehicleList.borderColor = { r = C.border.r, g = C.border.g, b = C.border.b, a = 1 }
    self.vehicleList.doDrawItem = Garage_Panel.drawVehicleItem
    self.vehicleList.onmousedown = Garage_Panel.onListMouseDown
    self:addChild(self.vehicleList)

    self.previewScene = Garage_PreviewScene:new(self.detailX + 4, self.detailY + 4, self.detailW - 8, self.previewH - 4)
    self.previewScene:initialise()
    self.previewScene:instantiate()
    self.previewScene:setAnchorTop(false)
    self.previewScene:setAnchorRight(false)
    self.previewScene:setAnchorBottom(false)
    self.previewScene:setView("Right")
    self.previewScene.javaObject:fromLua1("setZoom", 4)
    self.previewScene.javaObject:fromLua1("setDrawGrid", false)
    self.previewScene.javaObject:fromLua1("createVehicle", PREVIEW_VEH)
    self.previewScene:setVisible(false)
    self:addChild(self.previewScene)
    self.previewVehicleId = nil

    local btnY = self.height - pad - btnHgt
    local btnW = 110

    self.retrieveBtn = ISButton:new(self.detailX, btnY, btnW, btnHgt, getText("IGUI_GaragePanel_Retrieve"), self, Garage_Panel.onClick)
    self.retrieveBtn.internal = "RETRIEVE"
    self.retrieveBtn:initialise()
    self.retrieveBtn:instantiate()
    styleButton(self.retrieveBtn, true)
    self:addChild(self.retrieveBtn)

    self.putBtn = ISButton:new(self.detailX + btnW + 8, btnY, btnW + 40, btnHgt, getText("IGUI_GaragePanel_Put"), self, Garage_Panel.onClick)
    self.putBtn.internal = "PUT"
    self.putBtn:initialise()
    self.putBtn:instantiate()
    styleButton(self.putBtn, false)
    self:addChild(self.putBtn)

    self.closeBtn = ISButton:new(self.width - pad - 80, btnY, 80, btnHgt, getText("UI_Close"), self, Garage_Panel.onClick)
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    styleButton(self.closeBtn, false)
    self:addChild(self.closeBtn)

    self.selectedData = nil
    self:refreshList()
    self:updateButtons()
end

function Garage_Panel:onFilterCombo()
    local ownerIdx = self.ownerCombo.selected
    if ownerIdx == 2 then
        self.ownerFilter = "mine"
    elseif ownerIdx == 3 then
        self.ownerFilter = "others"
    else
        self.ownerFilter = "all"
    end

    local condIdx = self.condCombo.selected
    if condIdx == 2 then
        self.condFilter = "good"
    elseif condIdx == 3 then
        self.condFilter = "mid"
    elseif condIdx == 4 then
        self.condFilter = "bad"
    elseif condIdx == 5 then
        self.condFilter = "missing"
    else
        self.condFilter = "all"
    end

    local sortIdx = self.sortCombo.selected
    if sortIdx == 2 then
        self.sortMode = "cond"
    elseif sortIdx == 3 then
        self.sortMode = "plate"
    elseif sortIdx == 4 then
        self.sortMode = "size"
    elseif sortIdx == 5 then
        self.sortMode = "days"
    else
        self.sortMode = "name"
    end

    self:refreshList()
end

function Garage_Panel.onListMouseDown(item)
    local panel = Garage_Panel.instance
    if not panel then
        return
    end
    if item and item.item then
        panel.selectedData = item.item.data
    else
        panel.selectedData = nil
    end
    panel:updateButtons()
end

function Garage_Panel:drawVehicleItem(y, item, alt)
    local a = 0.95
    local h = self.itemheight - 1
    self:drawRectBorder(0, y, self:getWidth(), h, 0.35, C.border.r, C.border.g, C.border.b)
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), h, 0.22, C.select.r, C.select.g, C.select.b)
        self:drawRect(0, y, 3, h, 1, C.sodium.r, C.sodium.g, C.sodium.b)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), h, 0.35, C.alt.r, C.alt.g, C.alt.b)
    end

    local data = item.item.data
    local sw = 14
    local sx = 8
    local sy = y + (h - sw) / 2
    drawColorSwatch(self, sx, sy, sw, data)

    local textX = sx + sw + 6
    local name = item.item.name or "?"
    local plate = item.item.plate or ""
    local avg = item.item.avg
    local line2 = plate
    if item.item.owner and item.item.owner ~= "" then
        line2 = line2 .. "  " .. item.item.owner
    end
    if avg ~= nil then
        line2 = line2 .. "  " .. getText("IGUI_GaragePanel_AvgShort", tostring(avg))
    end

    self:drawText(name, textX, y + 2, C.text.r, C.text.g, C.text.b, a, self.font)
    local cr, cg, cb = condColor(avg)
    self:drawText(line2, textX, y + FONT_HGT_SMALL + 2, cr, cg, cb, a, self.font)
    return y + self.itemheight
end

function Garage_Panel:getGarageTable()
    if not self.worldobjects or not self.worldobjects[1] then
        return {}
    end
    local md = self.worldobjects[1]:getModData()
    return md and md["Garage"] or {}
end

function Garage_Panel:matchesSearch(data, filter)
    if not filter or filter == "" then
        return true
    end
    filter = string.lower(filter)
    local name = string.lower(vehicleDisplayName(data) or "")
    local plate = string.lower(tostring(data.oldSqlid or ""))
    local owner = string.lower(tostring(data.owner or ""))
    local script = string.lower(tostring(data.scriptName or ""))
    return string.find(name, filter, 1, true)
        or string.find(plate, filter, 1, true)
        or string.find(owner, filter, 1, true)
        or string.find(script, filter, 1, true)
end

function Garage_Panel:matchesOwner(data)
    local me = getPlayer() and getPlayer():getUsername() or ""
    local owner = data.owner or ""
    if self.ownerFilter == "mine" then
        return owner == me
    elseif self.ownerFilter == "others" then
        return owner ~= "" and owner ~= me
    end
    return true
end

function Garage_Panel:matchesCondition(data)
    local avg = avgCondition(data)
    local missing = missingPartsCount(data)
    if self.condFilter == "good" then
        return avg ~= nil and avg >= 70
    elseif self.condFilter == "mid" then
        return avg ~= nil and avg >= 40 and avg < 70
    elseif self.condFilter == "bad" then
        return avg ~= nil and avg < 40
    elseif self.condFilter == "missing" then
        return missing > 0
    end
    return true
end

function Garage_Panel:sortRows(rows)
    local mode = self.sortMode or "name"
    table.sort(rows, function(a, b)
        local da, db = a.data, b.data
        if mode == "cond" then
            local ca = avgCondition(da) or -1
            local cb = avgCondition(db) or -1
            if ca ~= cb then
                return ca > cb
            end
        elseif mode == "plate" then
            local pa = tostring(da.oldSqlid or "")
            local pb = tostring(db.oldSqlid or "")
            if pa ~= pb then
                return pa < pb
            end
        elseif mode == "size" then
            local sa = Garage.getModDataSizeKB and Garage.getModDataSizeKB(da) or 0
            local sb = Garage.getModDataSizeKB and Garage.getModDataSizeKB(db) or 0
            if sa ~= sb then
                return sa > sb
            end
        elseif mode == "days" then
            local daY = parkedDays(da)
            local dbY = parkedDays(db)
            if daY ~= dbY then
                return daY > dbY
            end
        end
        local na = vehicleDisplayName(da)
        local nb = vehicleDisplayName(db)
        if na == nb then
            return tostring(da.oldSqlid or "") < tostring(db.oldSqlid or "")
        end
        return na < nb
    end)
end

function Garage_Panel:refreshList()
    local prevSql = self.selectedData and self.selectedData.oldSqlid
    local prevFull = self.selectedData and self.selectedData.vehicleFullName
    self.vehicleList:clear()
    self.selectedData = nil

    local garage = self:getGarageTable()
    local filter = ""
    if self.filterEntry then
        filter = self.filterEntry:getText() or ""
    end

    local totalSize = 0
    if Garage.getModDataSizeKB then
        totalSize = Garage.getModDataSizeKB(garage)
    end
    local totalCount = #garage

    local rows = {}
    for idx, data in ipairs(garage) do
        if self:matchesSearch(data, filter) and self:matchesOwner(data) and self:matchesCondition(data) then
            table.insert(rows, { idx = idx, data = data })
        end
    end
    self:sortRows(rows)

    local shown = #rows
    if shown < totalCount then
        self.capLabel:setName(getText("IGUI_GaragePanel_CapacityFiltered", tostring(totalSize), tostring(MAX_SIZE_KB), tostring(shown), tostring(totalCount)))
    else
        self.capLabel:setName(getText("IGUI_GaragePanel_Capacity", tostring(totalSize), tostring(MAX_SIZE_KB), tostring(totalCount)))
    end

    local selectIndex = 0
    for i, row in ipairs(rows) do
        local data = row.data
        local sizeKB = Garage.getModDataSizeKB and Garage.getModDataSizeKB(data) or 0
        local item = {
            data = data,
            idx = row.idx,
            name = vehicleDisplayName(data),
            plate = "[H " .. tostring(data.oldSqlid or "?") .. " KT]",
            owner = data.owner or "",
            avg = avgCondition(data),
            sizeKB = sizeKB,
        }
        self.vehicleList:addItem(item.name, item)
        if prevSql and data.oldSqlid == prevSql and data.vehicleFullName == prevFull then
            selectIndex = i
            self.selectedData = data
        end
    end

    if selectIndex == 0 and #self.vehicleList.items > 0 then
        selectIndex = 1
        self.selectedData = self.vehicleList.items[1].item.data
    end
    self.vehicleList.selected = selectIndex
    self:setPreviewVehicle(self.selectedData)
    self:updateButtons()
end

function Garage_Panel:setPreviewVehicle(data)
    if not self.previewScene or not self.previewScene.javaObject then
        return
    end
    if not data or not data.vehicleFullName then
        self.previewScene:setVisible(false)
        self.previewVehicleId = nil
        return
    end

    local scriptId = data.vehicleFullName
    -- UI3DScene умеет только setVehicleScript (скин/цвет через fromLua нет, см. UI3DScene.java)
    if self.previewVehicleId ~= scriptId then
        local script = nil
        if getScriptManager then
            script = getScriptManager():getVehicle(scriptId)
        end
        if not script then
            self.previewScene:setVisible(false)
            self.previewVehicleId = nil
            return
        end
        self.previewVehicleId = scriptId
        self.previewScene.javaObject:fromLua2("setVehicleScript", PREVIEW_VEH, scriptId)
    end

    self.previewScene:setVisible(true)
end

function Garage_Panel:prerender()
    ISPanel.prerender(self)
    if self.stripeY then
        self:drawRect(10, self.stripeY, self.width - 20, 2, 0.85, C.sodium.r, C.sodium.g, C.sodium.b)
        self:drawRect(10, self.stripeY + 2, self.width - 20, 1, 0.25, C.sodiumDim.r, C.sodiumDim.g, C.sodiumDim.b)
    end
    self:drawRect(self.detailX, self.detailY, self.detailW, self.detailH, C.inset.a, C.inset.r, C.inset.g, C.inset.b)
    self:drawRectBorder(self.detailX, self.detailY, self.detailW, self.detailH, 1, C.border.r, C.border.g, C.border.b)
    self:drawRect(self.detailX, self.detailY, 3, self.detailH, 0.7, C.sodiumDim.r, C.sodiumDim.g, C.sodiumDim.b)
    if self.previewVehicleId then
        self:drawRectBorder(self.detailX + 4, self.detailY + 4, self.detailW - 8, self.previewH - 4, 0.7, C.border.r, C.border.g, C.border.b)
    end
    self:drawDetails()
end

function Garage_Panel:drawDetails()
    local x = self.detailX + 12
    local y = self.detailTextY or (self.detailY + 8)
    local maxW = self.detailW - 22
    local data = self.selectedData

    if not data then
        self:drawText(getText("IGUI_GaragePanel_NoSelection"), x, self.detailY + 8, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
        return
    end

    local name = vehicleDisplayName(data)
    self:drawText(name, x, y, C.sodium.r, C.sodium.g, C.sodium.b, 1, UIFont.Medium)
    y = y + FONT_HGT_MEDIUM + 4

    self:drawText(getText("IGUI_GaragePanel_PreviewHint"), x, y, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 4

    self:drawText(getText("IGUI_GaragePanel_Plate", tostring(data.oldSqlid or "?")), x, y, C.text.r, C.text.g, C.text.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2
    self:drawText(getText("IGUI_GaragePanel_Owner", tostring(data.owner or "-")), x, y, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2

    local sizeKB = Garage.getModDataSizeKB and Garage.getModDataSizeKB(data) or 0
    self:drawText(getText("IGUI_GaragePanel_Size", tostring(sizeKB)), x, y, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 4

    local sw = 28
    local skin = drawColorSwatch(self, x, y, sw, data)
    local labelX = x + sw + 8
    self:drawText(getText("IGUI_GaragePanel_Color"), labelX, y + 2, C.text.r, C.text.g, C.text.b, 1, UIFont.Small)
    local ly = y + 2 + FONT_HGT_SMALL
    if skin and skin.label then
        self:drawText(getText("IGUI_GaragePanel_SkinName", skin.label), labelX, ly, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    elseif data.skinIdx ~= nil then
        self:drawText(getText("IGUI_GaragePanel_Skin", tostring(data.skinIdx)), labelX, ly, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    end
    y = y + math.max(sw, FONT_HGT_SMALL * 2) + 6

    local rust = math.floor(((tonumber(data.rust) or 0) * 100) + 0.5)
    local rustR, rustG, rustB = condColor(100 - rust)
    self:drawText(getText("IGUI_GaragePanel_Rust", tostring(rust)), x, y, rustR, rustG, rustB, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2

    local engQ = data.engineFeature and data.engineFeature[1]
    if engQ ~= nil then
        local er, eg, eb = condColor(engQ)
        self:drawText(getText("IGUI_GaragePanel_EngineQuality", tostring(engQ)), x, y, er, eg, eb, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL + 2
    end

    local avg = avgCondition(data)
    if avg ~= nil then
        local ar, ag, ab = condColor(avg)
        self:drawText(getText("IGUI_GaragePanel_AvgCondition", tostring(avg)), x, y, ar, ag, ab, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL + 2
    end

    local missing = missingPartsCount(data)
    if missing > 0 then
        self:drawText(getText("IGUI_GaragePanel_MissingParts", tostring(missing)), x, y, 0.90, 0.38, 0.32, 1, UIFont.Small)
        y = y + FONT_HGT_SMALL + 2
    end

    local keyLine
    if data.isKeysInIgnition then
        keyLine = getText("IGUI_GaragePanel_KeysInIgnition")
    elseif data.isHotwired then
        keyLine = getText("IGUI_GaragePanel_Hotwired")
    else
        keyLine = getText("IGUI_GaragePanel_KeysNone")
    end
    self:drawText(keyLine, x, y, C.text.r, C.text.g, C.text.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 2

    self:drawText(getText("IGUI_GaragePanel_ParkedDays", tostring(parkedDays(data))), x, y, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 6

    self:drawText(getText("IGUI_GaragePanel_Parts"), x, y, C.sodium.r, C.sodium.g, C.sodium.b, 1, UIFont.Small)
    y = y + FONT_HGT_SMALL + 3

    for _, part in ipairs(KEY_PARTS) do
        if y > self.detailY + self.detailH - FONT_HGT_SMALL - 4 then
            break
        end
        local cond, missingPart, pd, notOnVehicle = partInfo(data, part.id)
        if not notOnVehicle then
            local label = getText(part.key)
            local value
            local vr, vg, vb = C.textDim.r, C.textDim.g, C.textDim.b
            if missingPart then
                value = getText("IGUI_GaragePanel_PartMissing")
                vr, vg, vb = 0.90, 0.38, 0.32
            else
                value = tostring(cond or 0) .. "%"
                vr, vg, vb = condColor(cond)
                if part.id == "GasTank" and pd and pd.containerAmount ~= nil then
                    value = value .. "  (" .. string.format("%.1f", pd.containerAmount) .. "L)"
                end
                if part.id == "Battery" and pd and pd.delta ~= nil then
                    value = value .. "  (" .. math.floor((pd.delta or 0) * 100) .. "%)"
                end
            end
            self:drawText(label, x, y, C.textDim.r, C.textDim.g, C.textDim.b, 1, UIFont.Small)
            local vx = x + 120
            if vx + 40 > x + maxW then
                vx = x + 90
            end
            self:drawText(value, vx, y, vr, vg, vb, 1, UIFont.Small)
            y = y + FONT_HGT_SMALL + 2
        end
    end
end

function Garage_Panel:update()
    ISPanel.update(self)
    local sel = self.vehicleList and self.vehicleList.selected or 0
    local prevData = self.selectedData
    if sel > 0 and self.vehicleList.items and self.vehicleList.items[sel] then
        self.selectedData = self.vehicleList.items[sel].item.data
    elseif not self.vehicleList or #self.vehicleList.items == 0 then
        self.selectedData = nil
    end
    if self.selectedData ~= prevData then
        self:setPreviewVehicle(self.selectedData)
    elseif self.selectedData then
        -- первый кадр после открытия
        if not self.previewVehicleId then
            self:setPreviewVehicle(self.selectedData)
        end
    else
        self:setPreviewVehicle(nil)
    end
    self:updateButtons()
end

function Garage_Panel:updateButtons()
    if not self.retrieveBtn or not self.putBtn then
        return
    end
    local hasSel = self.selectedData ~= nil
    local spotBusy = self.vehicleOnSpot ~= nil
    self.retrieveBtn:setEnable(hasSel and not spotBusy)
    if spotBusy then
        self.retrieveBtn.tooltip = getText("IGUI_PlaceForCarBusy")
    elseif not hasSel then
        self.retrieveBtn.tooltip = getText("IGUI_GaragePanel_NoSelection")
    else
        self.retrieveBtn.tooltip = nil
    end

    if self.vehicleOnSpot then
        self.putBtn:setEnable(true)
        self.putBtn.tooltip = nil
    else
        self.putBtn:setEnable(false)
        self.putBtn.tooltip = getText("IGUI_GaragePanel_NoCarOnSpot")
    end
end

function Garage_Panel:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
        return
    end
    if button.internal == "RETRIEVE" then
        if not self.selectedData then
            return
        end
        if Garage.retrieveCar then
            Garage.retrieveCar(self.worldobjects, self.playerNum, self.selectedData, self.vehicleOnSpot, self.spawnX, self.spawnY)
        end
        self:close()
        return
    end
    if button.internal == "PUT" then
        if self.vehicleOnSpot and Garage.storeCar then
            Garage.storeCar(self.worldobjects, self.playerNum, self.vehicleOnSpot)
        end
        self:close()
        return
    end
end

function Garage_Panel:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if Garage_Panel.instance == self then
        Garage_Panel.instance = nil
    end
end

function Garage_Panel:new(x, y, width, height, worldobjects, playerNum, spawnX, spawnY, vehicleOnSpot)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = C.border.r, g = C.border.g, b = C.border.b, a = C.border.a }
    o.backgroundColor = { r = C.bg.r, g = C.bg.g, b = C.bg.b, a = C.bg.a }
    o.width = width
    o.height = height
    o.moveWithMouse = true
    o.worldobjects = worldobjects
    o.playerNum = playerNum
    o.spawnX = spawnX
    o.spawnY = spawnY
    o.vehicleOnSpot = vehicleOnSpot
    Garage_Panel.instance = o
    return o
end

function Garage_Panel.open(worldobjects, playerNum, spawnX, spawnY, vehicleOnSpot)
    if Garage_Panel.instance then
        Garage_Panel.instance:close()
    end
    local width, height = 760, 580
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2
    local ui = Garage_Panel:new(x, y, width, height, worldobjects, playerNum, spawnX, spawnY, vehicleOnSpot)
    ui:initialise()
    ui:addToUIManager()
    ui:setVisible(true)
    return ui
end
