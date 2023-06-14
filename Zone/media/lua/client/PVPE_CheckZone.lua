require "PVPE_ForcePVPZone.lua"

-- Debug reload
-- old_ISSafetyUI_prerender_reload_debug = false
-- if not old_ISSafetyUI_prerender_reload_debug then
    -- old_ISSafetyUI_prerender = ISSafetyUI.prerender
    -- old_ISSafetyUI_prerender_reload_debug = true
-- end

-- Автоматическая активация режима PVP
local old_ISSafetyUI_prerender = ISSafetyUI.prerender
function ISSafetyUI:prerender()
    old_ISSafetyUI_prerender(self)
    local isNonPvpZone = NonPvpZone.getNonPvpZone(self.character:getX(), self.character:getY())
    local safetyEnabled = getServerOptions():getBoolean("SafetySystem");
    if safetyEnabled then
        local isPvpZone = ForcePVPZone:getPvpZone(self.character:getX(), self.character:getY())
        if isPvpZone and not isNonPvpZone then
            if self.character:getSafety():isEnabled() then
                self.character:getSafety():setEnabled(false)
                getPlayerSafetyUI(0):toggleSafety()
            end
            self.radialIcon:setVisible(false);
        end
    end
end

-- Отключение урона в зоне PVPE
Events.OnWeaponHitCharacter.Add(function (attackedBy, target, handWeapon, damage)
    if target:isZombie() then return end
    if attackedBy:getSafety():isEnabled() or target:getSafety():isEnabled() then
        attackedBy:setLastHitCount(attackedBy:getLastHitCount() - 1)
        target:setAvoidDamage(true)
    end
end)