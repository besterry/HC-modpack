WalletContainers = WalletContainers or {}

function WalletContainers.AcceptItemFunc(container, item) -- проверяем есть ли тег в предмете
    local hasTag = false;
    for _,v in pairs(WALLET_ACCEPTED_TAGS) do
        if item:hasTag(v) then
            return true;
        end
    end
    
    return WALLET_ACCEPTED_DISPLAY_CATEGORIES[item:getDisplayCategory()]
end