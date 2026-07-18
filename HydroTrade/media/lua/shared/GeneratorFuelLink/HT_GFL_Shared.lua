--[[
  HydroTrade Generator Fuel Link
  Подключение бочек FuelAPI (1 клетка вокруг гена).
  Учёт топлива в резерве гена; на бочке фантомный объём для вида.
]]

HT_GFL = HT_GFL or {}

HT_GFL.MOD_CMD = "HT_GFL"
HT_GFL.MD_RESERVE = "HT_fuelReserve"
HT_GFL.MD_LINKS = "HT_linkedBarrels"
HT_GFL.MD_REGISTRY = "HT_GeneratorFuelLinks"
HT_GFL.MD_PHANTOM = "HT_GFL_phantom"

-- Полная канистра = 10 л = 80% бака (8 Use * 10%)
HT_GFL.JERRY_LITRES = 10
HT_GFL.PERCENT_PER_JERRY = 80

-- 1 = только соседние клетки (и та же, если бочка на гене невозможна)
HT_GFL.DEFAULT_LINK_RANGE = 1
-- 8 соседей по Муру при радиусе 1
HT_GFL.DEFAULT_MAX_LINKS = 8
HT_GFL.DEFAULT_MAX_RESERVE = 1200
HT_GFL.DEFAULT_TOPUP_THRESHOLD = 90

function HT_GFL.getLinkRange()
    if SandboxVars.HT_GFL and SandboxVars.HT_GFL.LinkRange then
        return tonumber(SandboxVars.HT_GFL.LinkRange) or HT_GFL.DEFAULT_LINK_RANGE
    end
    return HT_GFL.DEFAULT_LINK_RANGE
end

function HT_GFL.getMaxLinks()
    if SandboxVars.HT_GFL and SandboxVars.HT_GFL.MaxLinks then
        return tonumber(SandboxVars.HT_GFL.MaxLinks) or HT_GFL.DEFAULT_MAX_LINKS
    end
    return HT_GFL.DEFAULT_MAX_LINKS
end

function HT_GFL.getMaxReserve()
    if SandboxVars.HT_GFL and SandboxVars.HT_GFL.MaxReserveLitres then
        return tonumber(SandboxVars.HT_GFL.MaxReserveLitres) or HT_GFL.DEFAULT_MAX_RESERVE
    end
    return HT_GFL.DEFAULT_MAX_RESERVE
end

function HT_GFL.getTopupThreshold()
    if SandboxVars.HT_GFL and SandboxVars.HT_GFL.TopupThreshold then
        return tonumber(SandboxVars.HT_GFL.TopupThreshold) or HT_GFL.DEFAULT_TOPUP_THRESHOLD
    end
    return HT_GFL.DEFAULT_TOPUP_THRESHOLD
end

function HT_GFL.litresToPercent(litres)
    litres = tonumber(litres) or 0
    if litres <= 0 then return 0 end
    return litres * HT_GFL.PERCENT_PER_JERRY / HT_GFL.JERRY_LITRES
end

function HT_GFL.percentToLitres(percent)
    percent = tonumber(percent) or 0
    if percent <= 0 then return 0 end
    return percent * HT_GFL.JERRY_LITRES / HT_GFL.PERCENT_PER_JERRY
end

function HT_GFL.getReserve(gen)
    if not gen then return 0 end
    local md = gen:getModData()
    local v = tonumber(md[HT_GFL.MD_RESERVE])
    if not v or v < 0 then return 0 end
    return v
end

function HT_GFL.setReserve(gen, litres)
    if not gen then return end
    local md = gen:getModData()
    litres = math.max(0, tonumber(litres) or 0)
    local maxR = HT_GFL.getMaxReserve()
    if litres > maxR then litres = maxR end
    md[HT_GFL.MD_RESERVE] = litres
end

function HT_GFL.getLinks(gen)
    if not gen then return {} end
    local md = gen:getModData()
    local links = md[HT_GFL.MD_LINKS]
    if type(links) ~= "table" then
        return {}
    end
    return links
end

function HT_GFL.setLinks(gen, links)
    if not gen then return end
    gen:getModData()[HT_GFL.MD_LINKS] = links or {}
end

function HT_GFL.linkKey(x, y, z)
    return tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
end

function HT_GFL.posKey(x, y, z)
    return HT_GFL.linkKey(x, y, z)
end

function HT_GFL.isBarrelObject(isoObject)
    if not isoObject or not instanceof(isoObject, "IsoObject") then
        return false
    end
    local sprite = isoObject:getSprite()
    if not sprite then return false end
    local props = sprite:getProperties()
    if not props then return false end
    return props:Val("CustomName") == "Barrel"
end

function HT_GFL.isPhantomBarrel(isoObject)
    if not isoObject then return false end
    return isoObject:getModData()[HT_GFL.MD_PHANTOM] == true
end

function HT_GFL.getBarrelFuelAmount(isoObject)
    if not isoObject then return 0 end
    local md = isoObject:getModData()
    local amount = tonumber(md.fuelAmount)
    if not amount or amount < 0 then return 0 end
    return amount
end

--- Сколько реально можно забрать с бочки в резерв (фантом не считается).
function HT_GFL.getBarrelTransferableLitres(isoObject)
    if not isoObject then return 0 end
    if HT_GFL.isPhantomBarrel(isoObject) then
        -- поверх фантома игрок мог долить канистрой: лишнее сверх share на линке обработаем отдельно
        return 0
    end
    return HT_GFL.getBarrelFuelAmount(isoObject)
end

function HT_GFL.setBarrelFuelAmount(isoObject, amount)
    if not isoObject then return end
    local md = isoObject:getModData()
    amount = tonumber(amount) or 0
    if amount <= 0 then
        md.fuelAmount = -1
    else
        md.fuelAmount = amount
    end
    isoObject:transmitModData()
end

function HT_GFL.setBarrelPhantom(isoObject, enabled, displayLitres)
    if not isoObject then return end
    local md = isoObject:getModData()
    if enabled then
        md[HT_GFL.MD_PHANTOM] = true
        displayLitres = tonumber(displayLitres) or 0
        if displayLitres <= 0 then
            md.fuelAmount = -1
        else
            md.fuelAmount = displayLitres
        end
    else
        md[HT_GFL.MD_PHANTOM] = nil
    end
    isoObject:transmitModData()
end

function HT_GFL.findBarrelOnSquare(square)
    if not square then return nil end
    local objs = square:getObjects()
    if not objs then return nil end
    for i = 0, objs:size() - 1 do
        local obj = objs:get(i)
        if HT_GFL.isBarrelObject(obj) then
            return obj
        end
    end
    return nil
end

function HT_GFL.getGeneratorOnSquare(square)
    if not square then return nil end
    if square.getGenerator then
        local gen = square:getGenerator()
        if gen then return gen end
    end
    local specials = square:getSpecialObjects()
    if specials then
        for i = 0, specials:size() - 1 do
            local obj = specials:get(i)
            if instanceof(obj, "IsoGenerator") then
                return obj
            end
        end
    end
    return nil
end

-- Chebyshev: ортогональ и диагональ при range=1 (max(|dx|,|dy|) <= 1).
function HT_GFL.chebyshev(ax, ay, bx, by)
    local dx = math.abs(ax - bx)
    local dy = math.abs(ay - by)
    if dx > dy then return dx end
    return dy
end

function HT_GFL.isInLinkRange(gen, barrel)
    if not gen or not barrel then return false end
    local gs = gen:getSquare()
    local bs = barrel:getSquare()
    if not gs or not bs then return false end
    if gs:getZ() ~= bs:getZ() then return false end
    local range = HT_GFL.getLinkRange()
    local d = HT_GFL.chebyshev(gs:getX(), gs:getY(), bs:getX(), bs:getY())
    return d >= 1 and d <= range
end

function HT_GFL.findNearbyGenerators(square, range)
    local result = {}
    if not square then return result end
    range = range or HT_GFL.getLinkRange()
    local cx, cy, cz = square:getX(), square:getY(), square:getZ()
    local cell = getCell()
    if not cell then return result end
    for x = cx - range, cx + range do
        for y = cy - range, cy + range do
            local d = HT_GFL.chebyshev(cx, cy, x, y)
            if d >= 1 and d <= range then
                local sq = cell:getGridSquare(x, y, cz)
                local gen = HT_GFL.getGeneratorOnSquare(sq)
                if gen then
                    table.insert(result, gen)
                end
            end
        end
    end
    return result
end

function HT_GFL.findNearbyBarrels(square, range)
    local result = {}
    if not square then return result end
    range = range or HT_GFL.getLinkRange()
    local cx, cy, cz = square:getX(), square:getY(), square:getZ()
    local cell = getCell()
    if not cell then return result end
    for x = cx - range, cx + range do
        for y = cy - range, cy + range do
            local d = HT_GFL.chebyshev(cx, cy, x, y)
            if d >= 1 and d <= range then
                local sq = cell:getGridSquare(x, y, cz)
                local barrel = HT_GFL.findBarrelOnSquare(sq)
                if barrel then
                    table.insert(result, barrel)
                end
            end
        end
    end
    return result
end

function HT_GFL.isLinked(gen, barrel)
    if not gen or not barrel then return false end
    local bs = barrel:getSquare()
    if not bs then return false end
    local key = HT_GFL.linkKey(bs:getX(), bs:getY(), bs:getZ())
    local links = HT_GFL.getLinks(gen)
    for i = 1, #links do
        local l = links[i]
        if l and HT_GFL.linkKey(l.x, l.y, l.z) == key then
            return true, i
        end
    end
    return false, nil
end

function HT_GFL.getLinkShare(link)
    if not link then return 0 end
    return math.max(0, tonumber(link.share) or 0)
end

function HT_GFL.getTotalFuelPercent(gen)
    if not gen then return 0 end
    return (tonumber(gen:getFuel()) or 0) + HT_GFL.litresToPercent(HT_GFL.getReserve(gen))
end

function HT_GFL.ensureModData(gen)
    if not gen then return end
    local md = gen:getModData()
    if md[HT_GFL.MD_RESERVE] == nil then
        md[HT_GFL.MD_RESERVE] = 0
    end
    if type(md[HT_GFL.MD_LINKS]) ~= "table" then
        md[HT_GFL.MD_LINKS] = {}
    end
end

function HT_GFL.sumLinkShares(links)
    local sum = 0
    for i = 1, #links do
        sum = sum + HT_GFL.getLinkShare(links[i])
    end
    return sum
end
