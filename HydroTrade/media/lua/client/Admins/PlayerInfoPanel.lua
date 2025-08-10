-- media/lua/client/AdminHealthPanel.lua
-- Admin/Medic health inspector with tabs (extended)

AdminHealthPanel = ISPanel:derive("AdminHealthPanel")

-- ==== Config ====
local TAB_NAMES = {"Overview","Wounds","Stats","Moodles","Identity","Combat","Physiology","Equipment","Position/Admin"}
local TAB_Y, TAB_H = 26, 18
local CONTENT_TOP  = TAB_Y + TAB_H + 10

local partsOrder = {
    "Head","Neck","Torso_Upper","Torso_Lower",
    "UpperArm_L","UpperArm_R","ForeArm_L","ForeArm_R",
    "Hand_L","Hand_R","UpperLeg_L","UpperLeg_R",
    "LowerLeg_L","LowerLeg_R","Foot_L","Foot_R"
}
local partNiceName = {
    Head="Head", Neck="Neck",
    Torso_Upper="Upper Torso", Torso_Lower="Lower Torso",
    UpperArm_L="Upper Arm L", UpperArm_R="Upper Arm R",
    ForeArm_L="Forearm L",  ForeArm_R="Forearm R",
    Hand_L="Hand L", Hand_R="Hand R",
    UpperLeg_L="Upper Leg L", UpperLeg_R="Upper Leg R",
    LowerLeg_L="Lower Leg L", LowerLeg_R="Lower Leg R",
    Foot_L="Foot L", Foot_R="Foot R"
}

-- ==== Helpers ====
local function colorByHealth(hp)
    if hp >= 75 then return 0.3,1.0,0.3 end
    if hp >= 40 then return 1.0,0.85,0.2 end
    return 1.0,0.35,0.35
end
local function safeCall(obj, method, ...)
    return (obj and obj[method]) and obj[method](obj, ...) or nil
end
local function woundFlags(part)
    if not part then return "" end
    local f = {}
    if part.isBleeding     and part:isBleeding()     then f[#f+1]="Bleeding" end
    if part.isBitten       and part:isBitten()       then f[#f+1]="Bitten"   end
    if part.isDeepWounded  and part:isDeepWounded()  then f[#f+1]="Deep"     end
    if part.getBurnTime    and (part:getBurnTime() or 0)      > 0 then f[#f+1]="Burn"     end
    if part.getFractureTime and (part:getFractureTime() or 0) > 0 then f[#f+1]="Fracture" end
    if part.getScratchTime and (part:getScratchTime() or 0)   > 0 then f[#f+1]="Scratch"  end
    if part.hasBandage     and part:hasBandage()     then f[#f+1]="Bandaged" end
    if part.stitched       and part:stitched()       then f[#f+1]="Stitched" end
    if part.hasSplint      and part:hasSplint()      then f[#f+1]="Splint"   end
    return (#f>0) and (" ["..table.concat(f,",").."]") or ""
end
local function drawKV(panel, x, y, label, value, r,g,b, font)
    panel:drawText(value==nil and label or (label..tostring(value)), x, y, r or 1,g or 1,b or 1,1, font or panel.font)
end
local function boolStr(v) return v and "ON" or "OFF" end

-- ==== Class ====
function AdminHealthPanel:new(x,y,w,h)
    local o = ISPanel:new(x,y,w,h)
    setmetatable(o,self); self.__index=self
    o.anchorLeft=true; o.anchorTop=true
    o.moveWithMouse=true; o.resizable=false
    o.activeTab = TAB_NAMES[1]
    o.tabButtons = {}
    return o
end

function AdminHealthPanel:initialise()
    ISPanel.initialise(self)
    self.fontTitle = UIFont.Medium
    self.font = UIFont.Small

    self.closeBtn = ISButton:new(self.width-22, 2, 20, 18, "X", self, function() self:setVisible(false) end)
    self.closeBtn:initialise(); self.closeBtn.borderColor={r=1,g=1,b=1,a=0.3}; self:addChild(self.closeBtn)

    local tx = 8
    for _,name in ipairs(TAB_NAMES) do
        local tabName = name
        local btn = ISButton:new(tx, TAB_Y, math.max(70, getTextManager():MeasureStringX(UIFont.Small, tabName)+14), TAB_H, tabName, self, function() self.activeTab = tabName end)
        btn:initialise(); btn.borderColor={r=1,g=1,b=1,a=0.3}; self:addChild(btn)
        self.tabButtons[#self.tabButtons+1] = btn
        tx = tx + btn.width + 4
    end
end

function AdminHealthPanel:setTarget(p) self.target = p end

-- ==== TABS ====
function AdminHealthPanel:renderOverview(p, bd, st)
    local y = CONTENT_TOP
    local hp = safeCall(bd,"getOverallBodyHealth") or 0
    local r,g,b = colorByHealth(hp)
    drawKV(self, 8,  y,  string.format("HP: %.1f", hp), nil, r,g,b)
    local inf = safeCall(bd,"getInfectionLevel") or 0
    local ir,ig,ib = (inf>0) and 1 or 0.7, (inf>0) and 0.35 or 0.9, (inf>0) and 0.35 or 1
    drawKV(self, 8,  y+16, string.format("Infection: %.1f", inf), nil, ir,ig,ib)

    if st then
        drawKV(self, 8,  y+40, string.format("Thirst: %.2f",  st:getThirst()))
        drawKV(self, 8,  y+56, string.format("Hunger: %.2f",  st:getHunger()))
        drawKV(self, 8,  y+72, string.format("Panic: %.0f",   st:getPanic()))
        drawKV(self, 8,  y+88, string.format("Stress: %.2f",  st:getStress()))
        drawKV(self, 8,  y+104,string.format("Fatigue: %.2f", st:getFatigue()))
    end

    local mort = bd and bd.getInfectionMortalityDuration and bd:getInfectionMortalityDuration() or nil
    if mort then drawKV(self, 8, y+128, string.format("Infection mortality (h): %.1f", mort)) end

    local x1, x2 = 180, 330
    local y0 = y
    local half = math.ceil(#partsOrder/2)
    for i,key in ipairs(partsOrder) do
        local part = (bd and BodyPartType and BodyPartType.FromString) and bd:getBodyPart(BodyPartType.FromString(key)) or nil
        if part then
            local h = safeCall(part,"getHealth") or 0
            local pr,pg,pb = colorByHealth(h)
            local label = partNiceName[key] or key
            local colX = (i<=half) and x1 or x2
            local row = (i-1)%half
            local yy = y0 + row*16
            self:drawText(string.format("%-13s  HP:%5.1f", label, h), colX, yy, pr,pg,pb,1, self.font)
        end
    end
end

function AdminHealthPanel:renderWounds(p, bd, st)
    local y = CONTENT_TOP
    self:drawText("Body Wounds & Conditions", 8, y, 1,1,1,1, self.fontTitle)
    y = y + 20
    local x1, x2 = 8, 250
    local y0 = y
    local half = math.ceil(#partsOrder/2)
    for i,key in ipairs(partsOrder) do
        local part = (bd and BodyPartType and BodyPartType.FromString) and bd:getBodyPart(BodyPartType.FromString(key)) or nil
        local label = partNiceName[key] or key
        local colX = (i<=half) and x1 or x2
        local row = (i-1)%half
        local yy = y0 + row*18
        if part then
            local h = safeCall(part,"getHealth") or 0
            local pr,pg,pb = colorByHealth(h)
            local text = string.format("%-14s  HP:%5.1f", label, h) .. woundFlags(part)
            self:drawText(text, colX, yy, pr,pg,pb,1, self.font)
            local t = {}
            if part.getBleedingTime  and part:getBleedingTime()  > 0 then t[#t+1]="Bleed:"..math.floor(part:getBleedingTime()) end
            if part.getScratchTime   and part:getScratchTime()   > 0 then t[#t+1]="Scratch:"..math.floor(part:getScratchTime()) end
            if part.getBurnTime      and part:getBurnTime()      > 0 then t[#t+1]="Burn:"..math.floor(part:getBurnTime()) end
            if part.getFractureTime  and part:getFractureTime()  > 0 then t[#t+1]="Fracture:"..math.floor(part:getFractureTime()) end
            if #t>0 then self:drawText("  "..table.concat(t,"  "), colX+180, yy, 0.8,0.8,1,1, self.font) end
        else
            self:drawText(label.."  (no data)", colX, yy, 1,0.6,0.6,1, self.font)
        end
    end
end

function AdminHealthPanel:renderStats(p, bd, st)
    local y = CONTENT_TOP
    self:drawText("Detailed Stats", 8, y, 1,1,1,1, self.fontTitle)
    y = y + 20
    if not st then self:drawText("No stats object", 8, y, 1,0.5,0.5,1, self.font); return end
    local lines = {
        {"Endurance",    st.getEndurance and string.format("%.2f", st:getEndurance()) or "n/a"},
        {"Pain",         st.getPain and string.format("%.2f", st:getPain()) or "n/a"},
        {"Boredom",      st.getBoredom and string.format("%.2f", st:getBoredom()) or "n/a"},
        {"Unhappiness",  st.getUnhappyness and string.format("%.2f", st:getUnhappyness()) or "n/a"},
        {"Sickness",     st.getSickness and string.format("%.2f", st:getSickness()) or "n/a"},
        {"Temperature",  st.getTemperature and string.format("%.2f", st:getTemperature()) or "n/a"},
        {"Wetness",      st.getWetness and string.format("%.2f", st:getWetness()) or "n/a"},
        {"Drunkenness",  st.getDrunkenness and string.format("%.2f", st:getDrunkenness()) or "n/a"},
        {"SmokerStress", st.getStressFromCigarettes and string.format("%.2f", st:getStressFromCigarettes()) or "n/a"},
        {"Anger",        st.getAnger and string.format("%.2f", st:getAnger()) or "n/a"},
        {"Morale",       st.getMorale and string.format("%.2f", st:getMorale()) or "n/a"},
    }
    local x = 8; local row = 0; local half = math.ceil(#lines/2)
    for i,kv in ipairs(lines) do
        self:drawText(string.format("%-14s: %s", kv[1], kv[2]), x, y + row*16, 0.9,0.9,1,1, self.font)
        row = row + 1
        if i == half then x = 220; row = 0 end
    end
end

-- заменяй всю функцию renderMoodles на эту
function AdminHealthPanel:renderMoodles(p)
    local y0 = CONTENT_TOP
    self:drawText("Moodles (levels)", 8, y0, 1,1,1,1, self.fontTitle)
    y0 = y0 + 20

    local md = p.getMoodles and p:getMoodles() or nil
    local mt = rawget(_G,"MoodleType")
    if not (md and mt and md.getMoodleLevel) then
        self:drawText("Moodles API not available in this build.", 8, y0, 1,0.6,0.6,1, self.font)
        return
    end

    local list = {
        "Hungry","Thirst","Panic","Sick","Tired","Bleeding","Angry",
        "Unhappy","Bored","Wet","Cold","Hot","Injured","Pain","Drunk"
    }

    local perCol  = 12         -- строк в колонке
    local colW    = 160        -- ширина колонки
    local xStart  = 8
    local yStart  = y0

    for i, name in ipairs(list) do
        local enum = mt[name]
        if enum then
            local lvl = md:getMoodleLevel(enum) or 0
            local col = math.floor((i-1) / perCol)
            local row = (i-1) % perCol
            local x   = xStart + col * colW
            local y   = yStart + row * 16

            local r,g,b = (lvl>=3) and 1 or (lvl>=1) and 1 or 0.8,
                          (lvl>=3) and 0.4 or (lvl>=1) and 0.8 or 0.8,
                          (lvl>=3) and 0.4 or (lvl>=1) and 0.8 or 1
            self:drawText(string.format("%-9s: %d", name, lvl), x, y, r,g,b,1, self.font)
        end
    end
end


function AdminHealthPanel:renderIdentity(p)
    local y = CONTENT_TOP
    self:drawText("Identity", 8, y, 1,1,1,1, self.fontTitle); y=y+20

    local sid = safeCall(p, "getSteamID")
    -- нормализуем: всегда строка, без экспоненты
    if type(sid) == "number" then
        sid = string.format("%.0f", sid)         -- убираем e+16
    elseif sid == nil then
        sid = "n/a"
    else
        sid = tostring(sid)
    end

    local uname = safeCall(p, "getUsername") or "?"
    local uid   = safeCall(p, "getOnlineID") or "n/a"
    local hours = safeCall(p, "getHoursSurvived") or 0
    local prof  = (safeCall(p, "getDescriptor") and p:getDescriptor():getProfession()) or "n/a"

    self:drawText("Username: "..uname, 8, y, 1,1,1,1, self.font); y=y+16
    self:drawText("SteamID : "..sid,   8, y, 0.8,0.9,1,1, self.font); y=y+16
    self:drawText("OnlineID: "..tostring(uid), 8, y, 0.8,0.9,1,1, self.font); y=y+16
    self:drawText(string.format("Hours Survived: %.2f", hours), 8, y, 1,1,1,1, self.font); y=y+16
    self:drawText("Profession: "..tostring(prof), 8, y, 1,1,1,1, self.font)
end

function AdminHealthPanel:renderCombat(p)
    local y = CONTENT_TOP
    self:drawText("Combat / Kills", 8, y, 1,1,1,1, self.fontTitle); y=y+20
    local zk = safeCall(p,"getZombieKills") or 0
    local pk = safeCall(p,"getSurvivorKills") or 0
    local fav = safeCall(p,"getFavoriteWeapon") ; local favName = fav and fav:getDisplayName() or "n/a"
    self:drawText("Zombie Kills  : "..zk, 8, y, 1,1,1,1, self.font); y=y+16
    self:drawText("Survivor Kills: "..pk, 8, y, 1,1,1,1, self.font); y=y+16
    self:drawText("Favorite Weapon: "..favName, 8, y, 1,1,1,1, self.font); y=y+24

    self:drawText("Hands", 8, y, 1,1,1,1, self.fontTitle); y=y+18
    local ph = safeCall(p,"getPrimaryHandItem");  local sh = safeCall(p,"getSecondaryHandItem")
    self:drawText("Primary  : "..(ph and ph:getDisplayName() or "Empty"),   8, y, 0.9,0.9,1,1, self.font); y=y+16
    self:drawText("Secondary: "..(sh and sh:getDisplayName() or "Empty"),   8, y, 0.9,0.9,1,1, self.font)
end

function AdminHealthPanel:renderPhysiology(p)
    local y = CONTENT_TOP
    self:drawText("Physiology / Nutrition", 8, y, 1,1,1,1, self.fontTitle); y=y+20
    local nut = safeCall(p,"getNutrition")
    if not nut then
        self:drawText("Nutrition API not available.", 8, y, 1,0.6,0.6,1, self.font); return
    end
    local weight = safeCall(p,"getWeight") or safeCall(nut,"getWeight") or 0
    local cal = safeCall(nut,"getCalories") or 0
    local pro = safeCall(nut,"getProteins") or 0
    local fat = safeCall(nut,"getLipids") or 0
    local carb= safeCall(nut,"getCarbohydrates") or 0
    self:drawText(string.format("Weight: %.1f", weight), 8, y, 1,1,1,1, self.font); y=y+16
    self:drawText(string.format("Calories: %.0f", cal),  8, y, 1,1,1,1, self.font); y=y+16
    self:drawText(string.format("Proteins: %.1f", pro),  8, y, 0.8,1,0.8,1, self.font); y=y+16
    self:drawText(string.format("Lipids: %.1f", fat),    8, y, 0.8,1,0.8,1, self.font); y=y+16
    self:drawText(string.format("Carbs: %.1f",  carb),   8, y, 0.8,1,0.8,1, self.font)
end

function AdminHealthPanel:renderEquipment(p)
    local y = CONTENT_TOP
    self:drawText("Equipment", 8, y, 1,1,1,1, self.fontTitle); y=y+20
    local function eq(label, fn)
        local item = safeCall(p, fn)
        self:drawText(string.format("%-16s: %s", label, item and item:getDisplayName() or "None"), 8, y, 0.9,0.9,1,1, self.font)
        y = y + 16
    end
    eq("Back",              "getClothingItem_Back")
    eq("Torso (Inner)",     "getClothingItem_Torso")
    eq("Torso (Outer)",     "getClothingItem_TorsoExtra")
    eq("Pants",             "getClothingItem_Legs")
    eq("Shoes",             "getClothingItem_Feet")
    eq("Hat",               "getClothingItem_Head")
    eq("Gloves",            "getClothingItem_Hands")
    eq("Mask",              "getClothingItem_Mask")
    eq("Eyes",              "getClothingItem_Eyes")
end

local function safeBool(p, method)
    if not (p and p[method]) then return nil end
    local ok, res = pcall(p[method], p)
    if not ok then return nil end
    if type(res) ~= "boolean" then return nil end
    return res
end

function AdminHealthPanel:renderPositionAdmin(p)
    local y = CONTENT_TOP
    self:drawText("Position / Admin flags", 8, y, 1,1,1,1, self.fontTitle); y = y + 20

    -- позиция
    local px, py, pz = (p.getX and p:getX() or 0), (p.getY and p:getY() or 0), (p.getZ and p:getZ() or 0)
    self:drawText(string.format("Pos: X=%.2f  Y=%.2f  Z=%d", px, py, pz), 8, y, 1,1,1,1, self.font); y = y + 18

    -- Safety/PvP (реплицируемые)
    local safety = safeBool(p, "getSafety")
    if safety ~= nil then
        local pvp = not safety
        self:drawText("PVP: "..(pvp and "ON" or "OFF").."   Safety: "..(safety and "ON" or "OFF"),
            8, y, 0.9,0.9,1,1, self.font)
        y = y + 22
    end

    self:drawText("Cheat flags (replicated)", 8, y, 1,1,1,1, self.fontTitle); y = y + 20

    local candidates = {
        {"Invisible",  "isInvisible"},
        {"God mode",   "isGodMod"},
        {"Ghost mode", "isGhostMode"},
        {"No Clip",    "isNoClip"},
    }

    local shown = 0
    local x = 8; local colW = 260; local perCol = 8
    for i, pair in ipairs(candidates) do
        local label, method = pair[1], pair[2]
        local val = safeBool(p, method)
        if val ~= nil then
            shown = shown + 1
            local row = (shown-1) % perCol
            local cx  = x + math.floor((shown-1)/perCol) * colW
            self:drawText(string.format("%-18s: %s", label, val and "ON" or "OFF"),
                cx, y + row*16, val and 0.6 or 0.8, val and 1 or 0.8, val and 0.6 or 1, 1, self.font)
        end
    end

    if shown == 0 then
        self:drawText("No replicated cheat flags available in this build.", 8, y, 1,0.6,0.6,1, self.font)
    end
end


-- ==== Base render ====
function AdminHealthPanel:prerender()
    ISPanel.prerender(self)
    self:drawRect(0,0,self.width,self.height,0.55,0,0,0)
    self:drawRectBorder(0,0,self.width,self.height,0.8,1,1,1)
    self:drawRect(4, TAB_Y+TAB_H+3, self.width-8, 1, 0.7, 1,1,1)

    local name = (self.target and self.target.getUsername and self.target:getUsername()) or "?"
    self:drawText("Player: "..name, 8, 6, 1,1,1,1, self.fontTitle)

    if not self.target then
        self:drawText("No target", 8, CONTENT_TOP, 1,0.6,0.6,1, self.fontTitle)
        return
    end

    local p  = self.target
    local bd = p.getBodyDamage and p:getBodyDamage() or nil
    local st = p.getStats and p:getStats() or nil

    if     self.activeTab == "Overview"      then self:renderOverview(p, bd, st)
    elseif self.activeTab == "Wounds"        then self:renderWounds(p, bd, st)
    elseif self.activeTab == "Stats"         then self:renderStats(p, bd, st)
    elseif self.activeTab == "Moodles"       then self:renderMoodles(p)
    elseif self.activeTab == "Identity"      then self:renderIdentity(p)
    elseif self.activeTab == "Combat"        then self:renderCombat(p)
    elseif self.activeTab == "Physiology"    then self:renderPhysiology(p)
    elseif self.activeTab == "Equipment"     then self:renderEquipment(p)
    elseif self.activeTab == "Position/Admin"then self:renderPositionAdmin(p)
    end
end

function AdminHealthPanel.openFor(target)
    if not AdminHealthPanel.instance then
        local ui = AdminHealthPanel:new(80,80,720,360)
        ui:initialise(); ui:addToUIManager()
        AdminHealthPanel.instance = ui
    end
    AdminHealthPanel.instance:setTarget(target)
    AdminHealthPanel.instance:setVisible(true)
end

-- hotkey: F6 (self)
Events.OnKeyPressed.Add(function(key)
    if key == Keyboard.KEY_F6 and isAdmin() then
        local me = getSpecificPlayer(0)
        if me then AdminHealthPanel.openFor(me) end
    end
end)

-- context menu: nearest player (~3 tiles)
Events.OnFillWorldObjectContextMenu.Add(function(playerNum, context)
    local me = getSpecificPlayer(playerNum); if not me then return end
    local nearest, dist2 = nil, 9
    for i=0,getNumActivePlayers()-1 do
        local p = getSpecificPlayer(i)
        if p and p ~= me then
            local dx,dy = p:getX()-me:getX(), p:getY()-me:getY()
            local d2 = dx*dx + dy*dy
            if d2 <= dist2 then nearest, dist2 = p, d2 end
        end
    end
    if nearest then
        context:addOption("Inspect Health: "..(nearest:getUsername() or "?"), nil, function()
            AdminHealthPanel.openFor(nearest)
        end)
    end
end)
