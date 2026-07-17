WALLET_ACCEPTED_TAGS = {
    "WalletItem",
}

WALLET_ACCEPTED_DISPLAY_CATEGORIES = {
    ["Money"] = true,
    ["Cartography"] = true,
}

-- Мелочь и документы, которые логично носить в кошельке
WALLET_ACCEPTED_FULLTYPES = {
    ["Base.Pen"] = true,
    ["BicPen.BicPen"] = true,
    ["Base.BluePen"] = true,
    ["Base.RedPen"] = true,
    ["Base.Pencil"] = true,
    ["Base.Eraser"] = true,
    ["Base.CreditCard"] = true,
    ["BetLock.BobbyPin"] = true,
    ["BetLock.HandmadeBobbyPin"] = true,
    ["Hydrocraft.HCDriverslicense"] = true,
    ["Hydrocraft.HCPassport"] = true,
}

WalletContainers = WalletContainers or {}

function WalletContainers.AcceptItemFunc(container, item)
    if WALLET_ACCEPTED_FULLTYPES and WALLET_ACCEPTED_FULLTYPES[item:getFullType()] then
        return true
    end

    if WALLET_ACCEPTED_TAGS then
        for _, v in pairs(WALLET_ACCEPTED_TAGS) do
            if item:hasTag(v) then
                return true
            end
        end
    end

    return WALLET_ACCEPTED_DISPLAY_CATEGORIES and WALLET_ACCEPTED_DISPLAY_CATEGORIES[item:getDisplayCategory()]
end
