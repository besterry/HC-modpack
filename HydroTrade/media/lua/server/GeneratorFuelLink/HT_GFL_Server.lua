require "GeneratorFuelLink/HT_GFL_Shared"

local function getRegistry()
    local md = ModData.getOrCreate(HT_GFL.MD_REGISTRY)
    if not md.gens then
        md.gens = {}
    end
    return md
end

local function registerGen(gen)
    if not gen or not gen:getSquare() then return end
    local sq = gen:getSquare()
    local key = HT_GFL.posKey(sq:getX(), sq:getY(), sq:getZ())
    local reg = getRegistry()
    reg.gens[key] = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
end

local function unregisterIfEmpty(gen)
    if not gen or not gen:getSquare() then return end
    local reserve = HT_GFL.getReserve(gen)
    local links = HT_GFL.getLinks(gen)
    if reserve > 0 or (#links > 0) then
        registerGen(gen)
        return
    end
    local sq = gen:getSquare()
    local key = HT_GFL.posKey(sq:getX(), sq:getY(), sq:getZ())
    local reg = getRegistry()
    reg.gens[key] = nil
end

local function transmitGen(gen)
    if gen and gen.transmitModData then
        gen:transmitModData()
    end
end

local function updateBarrelPhantomDisplay(link)
    if not link then return end
    local cell = getCell()
    if not cell then return end
    local sq = cell:getGridSquare(link.x, link.y, link.z)
    if not sq then return end
    local barrel = HT_GFL.findBarrelOnSquare(sq)
    if not barrel then return end
    HT_GFL.setBarrelPhantom(barrel, true, HT_GFL.getLinkShare(link))
end

--- Обновить фантом на всех загруженных связанных бочках.
function HT_GFL.refreshPhantomDisplays(gen)
    local links = HT_GFL.getLinks(gen)
    for i = 1, #links do
        updateBarrelPhantomDisplay(links[i])
    end
end

--- Списать часть резерва и пропорционально уменьшить share бочек.
local function consumeReserveShares(gen, litres)
    litres = tonumber(litres) or 0
    if litres <= 0 then return 0 end

    local reserve = HT_GFL.getReserve(gen)
    if reserve <= 0 then return 0 end
    local take = math.min(reserve, litres)

    local links = HT_GFL.getLinks(gen)
    local totalShare = HT_GFL.sumLinkShares(links)
    if totalShare > 0 then
        local left = take
        for i = 1, #links do
            local l = links[i]
            local share = HT_GFL.getLinkShare(l)
            if share > 0 then
                local part
                if i == #links then
                    part = left
                else
                    part = take * (share / totalShare)
                    left = left - part
                end
                l.share = math.max(0, share - part)
                updateBarrelPhantomDisplay(l)
            end
        end
        HT_GFL.setLinks(gen, links)
    end

    HT_GFL.setReserve(gen, reserve - take)
    transmitGen(gen)
    return take
end

--- Перелить реальное топливо с бочки в резерв + фантом на бочке.
--- Для уже фантомной: если игрок долил канистрой поверх, забираем дельту.
function HT_GFL.transferBarrelToReserve(gen, barrel)
    if not gen or not barrel then return 0 end
    if not HT_GFL.isInLinkRange(gen, barrel) then return 0 end

    HT_GFL.ensureModData(gen)
    local linked, linkIndex = HT_GFL.isLinked(gen, barrel)
    local links = HT_GFL.getLinks(gen)
    local bs = barrel:getSquare()
    if not bs then return 0 end

    local reserve = HT_GFL.getReserve(gen)
    local room = HT_GFL.getMaxReserve() - reserve
    if room <= 0 then return 0 end

    local take = 0
    if HT_GFL.isPhantomBarrel(barrel) and linked then
        local link = links[linkIndex]
        local display = HT_GFL.getBarrelFuelAmount(barrel)
        local share = HT_GFL.getLinkShare(link)
        -- игрок долил: на бочке стало больше share
        local extra = display - share
        if extra > 0.01 then
            take = math.min(extra, room)
            link.share = share + take
            HT_GFL.setLinks(gen, links)
            HT_GFL.setReserve(gen, reserve + take)
            HT_GFL.setBarrelPhantom(barrel, true, link.share)
        end
    else
        local barrelFuel = HT_GFL.getBarrelFuelAmount(barrel)
        if barrelFuel <= 0 then return 0 end
        take = math.min(barrelFuel, room)
        HT_GFL.setReserve(gen, reserve + take)

        if linked then
            local link = links[linkIndex]
            link.share = HT_GFL.getLinkShare(link) + take
            HT_GFL.setLinks(gen, links)
        end
        HT_GFL.setBarrelPhantom(barrel, true, linked and links[linkIndex].share or take)
    end

    transmitGen(gen)
    registerGen(gen)
    return take
end

function HT_GFL.topUpTankFromReserve(gen)
    if not gen then return 0 end
    HT_GFL.ensureModData(gen)

    local fuel = tonumber(gen:getFuel()) or 0
    local reserve = HT_GFL.getReserve(gen)
    if reserve <= 0 then return 0 end
    if fuel >= 100 then return 0 end

    local needPercent = 100 - fuel
    local needLitres = HT_GFL.percentToLitres(needPercent)
    local take = math.min(reserve, needLitres)
    if take <= 0 then return 0 end

    local addPercent = HT_GFL.litresToPercent(take)
    gen:setFuel(fuel + addPercent)
    consumeReserveShares(gen, take)
    return addPercent
end

function HT_GFL.pullFromLinkedBarrels(gen)
    if not gen then return 0 end
    HT_GFL.ensureModData(gen)

    local transferred = 0
    local links = HT_GFL.getLinks(gen)
    if #links == 0 then return 0 end

    local cell = getCell()
    if not cell then return 0 end

    local dirtyLinks = false
    local newLinks = {}

    for i = 1, #links do
        local l = links[i]
        if l and l.x and l.y and l.z ~= nil then
            local sq = cell:getGridSquare(l.x, l.y, l.z)
            if sq then
                local barrel = HT_GFL.findBarrelOnSquare(sq)
                if barrel then
                    transferred = transferred + HT_GFL.transferBarrelToReserve(gen, barrel)
                    l.share = HT_GFL.getLinkShare(l)
                    table.insert(newLinks, l)
                else
                    dirtyLinks = true
                end
            else
                table.insert(newLinks, l)
            end
        end
    end

    if dirtyLinks or #newLinks ~= #links then
        HT_GFL.setLinks(gen, newLinks)
        transmitGen(gen)
    end

    return transferred
end

--- Вернуть share одной бочки из резерва в реальное топливо бочки.
--- Сначала забираем долитое поверх фантома, чтобы не затереть свежий бензин.
function HT_GFL.returnShareToBarrel(gen, link)
    if not gen or not link then return end
    local cell = getCell()
    local barrel = nil
    if cell then
        local sq = cell:getGridSquare(link.x, link.y, link.z)
        barrel = HT_GFL.findBarrelOnSquare(sq)
    end

    if barrel then
        HT_GFL.transferBarrelToReserve(gen, barrel)
    end

    -- после transfer share мог вырасти; перечитываем линк из gen
    local links = HT_GFL.getLinks(gen)
    local key = HT_GFL.linkKey(link.x, link.y, link.z)
    local current = nil
    for i = 1, #links do
        if links[i] and HT_GFL.linkKey(links[i].x, links[i].y, links[i].z) == key then
            current = links[i]
            break
        end
    end
    if not current then
        current = link
    end

    local share = HT_GFL.getLinkShare(current)
    local reserve = HT_GFL.getReserve(gen)
    local give = math.min(share, reserve)
    if barrel then
        HT_GFL.setReserve(gen, reserve - give)
        HT_GFL.setBarrelPhantom(barrel, false, nil)
        HT_GFL.setBarrelFuelAmount(barrel, give)
    end
end

function HT_GFL.processGenerator(gen)
    if not gen or gen:getObjectIndex() == -1 then return end
    HT_GFL.ensureModData(gen)

    HT_GFL.pullFromLinkedBarrels(gen)

    local threshold = HT_GFL.getTopupThreshold()
    local fuel = tonumber(gen:getFuel()) or 0
    local reserve = HT_GFL.getReserve(gen)

    if reserve > 0 and fuel < threshold then
        HT_GFL.topUpTankFromReserve(gen)
        fuel = tonumber(gen:getFuel()) or 0
        reserve = HT_GFL.getReserve(gen)
    end

    if reserve > 0 and fuel <= 0.01 and not gen:isActivated() and gen:isConnected() then
        HT_GFL.topUpTankFromReserve(gen)
        fuel = tonumber(gen:getFuel()) or 0
        if fuel > 0 and gen:getCondition() > 0 then
            gen:setActivated(true)
        end
    end

    HT_GFL.refreshPhantomDisplays(gen)
    unregisterIfEmpty(gen)
end

local function resolveSquare(x, y, z)
    local cell = getCell()
    if not cell then return nil end
    return cell:getGridSquare(x, y, z)
end

local function onLink(player, args)
    if not player or not args then return end
    local gx, gy, gz = tonumber(args.gx), tonumber(args.gy), tonumber(args.gz)
    local bx, by, bz = tonumber(args.bx), tonumber(args.by), tonumber(args.bz)
    if not gx or not gy or gz == nil or not bx or not by or bz == nil then return end

    local gsq = resolveSquare(gx, gy, gz)
    local bsq = resolveSquare(bx, by, bz)
    local gen = HT_GFL.getGeneratorOnSquare(gsq)
    local barrel = HT_GFL.findBarrelOnSquare(bsq)
    if not gen or not barrel then return end
    if not HT_GFL.isInLinkRange(gen, barrel) then return end

    if player:DistToSquared(gen:getX() + 0.5, gen:getY() + 0.5) > 4 * 4
        and player:DistToSquared(barrel:getX() + 0.5, barrel:getY() + 0.5) > 4 * 4 then
        return
    end

    HT_GFL.ensureModData(gen)
    local linked, linkIndex = HT_GFL.isLinked(gen, barrel)
    local links = HT_GFL.getLinks(gen)

    if not linked then
        if #links >= HT_GFL.getMaxLinks() then
            player:setHaloNote(getText("IGUI_HT_GFL_MaxLinks", tostring(HT_GFL.getMaxLinks())), 255, 180, 120, 200)
            return
        end
        table.insert(links, { x = bx, y = by, z = bz, share = 0 })
        HT_GFL.setLinks(gen, links)
        linked, linkIndex = true, #links
    end

    local taken = HT_GFL.transferBarrelToReserve(gen, barrel)
    HT_GFL.topUpTankFromReserve(gen)
    HT_GFL.refreshPhantomDisplays(gen)
    transmitGen(gen)
    registerGen(gen)

    local share = 0
    links = HT_GFL.getLinks(gen)
    if linkIndex and links[linkIndex] then
        share = HT_GFL.getLinkShare(links[linkIndex])
    end

    player:setHaloNote(getText("IGUI_HT_GFL_LinkedPhantom", tostring(math.floor(share + 0.5))), 200, 255, 200, 220)
end

local function onUnlink(player, args)
    if not player or not args then return end
    local gx, gy, gz = tonumber(args.gx), tonumber(args.gy), tonumber(args.gz)
    local bx, by, bz = tonumber(args.bx), tonumber(args.by), tonumber(args.bz)
    if not gx or not gy or gz == nil then return end

    local gsq = resolveSquare(gx, gy, gz)
    local gen = HT_GFL.getGeneratorOnSquare(gsq)
    if not gen then return end
    if player:DistToSquared(gen:getX() + 0.5, gen:getY() + 0.5) > 4 * 4 then return end

    HT_GFL.ensureModData(gen)
    local links = HT_GFL.getLinks(gen)

    if bx and by and bz ~= nil then
        local key = HT_GFL.linkKey(bx, by, bz)
        local newLinks = {}
        for i = 1, #links do
            local l = links[i]
            if l and HT_GFL.linkKey(l.x, l.y, l.z) == key then
                HT_GFL.returnShareToBarrel(gen, l)
            else
                table.insert(newLinks, l)
            end
        end
        HT_GFL.setLinks(gen, newLinks)
    else
        for i = 1, #links do
            HT_GFL.returnShareToBarrel(gen, links[i])
        end
        HT_GFL.setLinks(gen, {})
    end

    transmitGen(gen)
    unregisterIfEmpty(gen)
    player:setHaloNote(getText("IGUI_HT_GFL_Unlinked"), 255, 220, 180, 200)
end

local function onTransfer(player, args)
    if not player or not args then return end
    local gx, gy, gz = tonumber(args.gx), tonumber(args.gy), tonumber(args.gz)
    local bx, by, bz = tonumber(args.bx), tonumber(args.by), tonumber(args.bz)
    if not gx or not gy or gz == nil then return end
    local gsq = resolveSquare(gx, gy, gz)
    local gen = HT_GFL.getGeneratorOnSquare(gsq)
    if not gen then return end

    local nearGen = player:DistToSquared(gen:getX() + 0.5, gen:getY() + 0.5) <= 6 * 6
    local nearBarrel = false
    if bx and by and bz ~= nil then
        nearBarrel = player:DistToSquared(bx + 0.5, by + 0.5) <= 6 * 6
    end
    if not nearGen and not nearBarrel then return end

    local taken = 0
    if bx and by and bz ~= nil then
        local bsq = resolveSquare(bx, by, bz)
        local barrel = HT_GFL.findBarrelOnSquare(bsq)
        if barrel then
            taken = HT_GFL.transferBarrelToReserve(gen, barrel)
        end
    else
        taken = HT_GFL.pullFromLinkedBarrels(gen)
    end

    HT_GFL.topUpTankFromReserve(gen)
    HT_GFL.refreshPhantomDisplays(gen)
    transmitGen(gen)
    registerGen(gen)

    if taken > 0.01 then
        player:setHaloNote(getText("IGUI_HT_GFL_Synced", tostring(math.floor(taken + 0.5))), 200, 255, 200, 200)
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= HT_GFL.MOD_CMD then return end
    if command == "link" then
        onLink(player, args)
    elseif command == "unlink" then
        onUnlink(player, args)
    elseif command == "transfer" then
        onTransfer(player, args)
    end
end

local function processRegistry()
    local reg = getRegistry()
    local cell = getCell()
    if not cell then return end

    for key, pos in pairs(reg.gens) do
        if pos and pos.x and pos.y and pos.z ~= nil then
            local sq = cell:getGridSquare(pos.x, pos.y, pos.z)
            if sq then
                local gen = HT_GFL.getGeneratorOnSquare(sq)
                if gen then
                    HT_GFL.processGenerator(gen)
                else
                    reg.gens[key] = nil
                end
            end
        end
    end
end

local function onLoadGridsquare(square)
    if not square then return end
    local gen = HT_GFL.getGeneratorOnSquare(square)
    if gen then
        local reserve = HT_GFL.getReserve(gen)
        local links = HT_GFL.getLinks(gen)
        if reserve > 0 or #links > 0 then
            registerGen(gen)
            HT_GFL.processGenerator(gen)
        end
        return
    end

    local barrel = HT_GFL.findBarrelOnSquare(square)
    if barrel and HT_GFL.isPhantomBarrel(barrel) then
        -- подтянуть фантом с гена рядом при загрузке бочки
        local gens = HT_GFL.findNearbyGenerators(square)
        for i = 1, #gens do
            local linked, idx = HT_GFL.isLinked(gens[i], barrel)
            if linked then
                local links = HT_GFL.getLinks(gens[i])
                updateBarrelPhantomDisplay(links[idx])
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
-- Часовой тик: AFK catch-up бака из резерва.
Events.EveryHours.Add(processRegistry)
-- Пока чанк гружен: быстрее подхватывать долитое в связанные бочки.
Events.EveryTenMinutes.Add(processRegistry)
Events.LoadGridsquare.Add(onLoadGridsquare)

Events.OnInitGlobalModData.Add(function(isNewGame)
    getRegistry()
end)
