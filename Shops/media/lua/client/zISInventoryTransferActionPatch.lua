local oldIsValid = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    local valid = oldIsValid(self)
    local isOwner = false
    if self.srcContainer then
        local parent = self.srcContainer:getParent()
        if parent and parent:getModData().owner then
            isOwner = self.character:getUsername() == parent:getModData().owner
            if isAdmin() then isOwner = true end
            return (valid and isOwner)
        end
    end

    -- Проверяем перетаскивание В контейнер магазина
    if self.destContainer then
        local parent = self.destContainer:getParent()
        if parent and parent:getModData().owner then
            -- Если это магазин, проверяем цену на предмете
            local item = self.item
            if item and item:getModData() then
                local modData = item:getModData()
                -- Разрешаем только предметы с установленной ценой
                if not modData.price or modData.price <= 0 then
                    if self.character then
                        self.character:setHaloNote(getText("IGUI_ItemNoPrice"), 255, 100, 100, 300)
                    end
                    if isAdmin() then
                        return true
                    end
                    return false
                end
            end
        end
    end
    return valid
end