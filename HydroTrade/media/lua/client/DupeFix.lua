function ISUnequipAction:isValid()
    return self.valid;
end

local oldFunc = ISFitnessUI.updateButtons -- не даёт выполнять упражнения, если игрок движется
---@diagnostic disable-next-line: duplicate-set-field
function ISFitnessUI:updateButtons(currentAction)
	oldFunc(self, currentAction)
	if self.player:isPlayerMoving()  then -- or self.player:pressedMovement(false)
		self.ok.enable = false;
	end
end

ISWorldObjectContextMenu.onTrade = function(worldobjects, player, otherPlayer) -- не даёт торговаться с игроком, если он в убежище
	player:Say(getText("IGUI_FIX_T15K_TradeFix"))
	player:playEmote("shrug") 		-- показывает анимацию "не знаю" распуская руки перед собой на уровне живота
end

function ISUnequipAction:new(character, item, time)
	self.valid = true
   if character:isHeavyItem(item) and #ISTimedActionQueue.getTimedActionQueue(character).queue > 0 then
        self.valid = false
    end

    local o = ISBaseTimedAction.new(self, character);
    o.item = item;
    o.stopOnAim = false;
    o.stopOnWalk = false;
    o.stopOnRun = true;
    o.maxTime = time;
    o.ignoreHandsWounds = true;

    o.hotbar = getPlayerHotbar(character:getPlayerNum());
    if o.hotbar then
        o.fromHotbar = o.hotbar:isItemAttached(item);
    else
        o.fromHotbar = false;
    end
    o.useProgressBar = not o.fromHotbar;
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    if o.maxTime > 1 and o.fromHotbar then
        o.animSpeed = o.maxTime / o:adjustMaxTime(o.maxTime)
        o.maxTime = -1
    else
        o.animSpeed = 1.0
    end
    return o;
end

-------------------

function ISClothingExtraAction:isValid()
    return self.character:getInventory():contains(self.item) and self.character:getInventory():getCapacityWeight() < 25;
end

-------------------
function ISInventoryTransferAction:isValid()
	if not self.item then
		return false;
    end
	self.dontAdd = false;
	if not self.destContainer or not self.srcContainer then return false; end
	if self.allowMissingItems and not self.srcContainer:contains(self.item) then -- if the item is destroyed before, for example when crafting something, we want to transfer the items left back to their original position, but some might be destroyed by the recipe (like molotov, the gas can will be returned, but the ripped sheet is destroyed)
--		self:stop();
		self.dontAdd = true;
		return true;
	end
	if (not self.destContainer:isExistYet()) or (not self.srcContainer:isExistYet()) then
		return false
	end

	local parent = self.srcContainer:getParent()
	-- Duplication exploit: drag items from a corpse to another container while pickup up the corpse.
	-- ItemContainer:isExistYet() would detect this if SystemDisabler.doWorldSyncEnable was true.
	if instanceof(parent, "IsoDeadBody") and parent:getStaticMovingObjectIndex() == -1 then
		return false
	end

	if self.srcContainer:getParent() ~= nil and (self.srcContainer:getParent():getSquare() == nil or IsoUtils.DistanceTo(self.srcContainer:getParent():getSquare():getX(), self.srcContainer:getParent():getSquare():getY(), self.character:getX(), self.character:getY()) > 9) then --
		return false
	end

	-- Don't fail if the item was transferred by a previous action.
	if self:isAlreadyTransferred(self.item) then
		return true
	end

	-- Limit items per container in MP
	if isClient() then
		if not isItemTransactionConsistent(self.item, self.srcContainer, self.destContainer) then
			return false
		end
		local limit = getServerOptions():getInteger("ItemNumbersLimitPerContainer");
		if limit > 0 and (not instanceof(self.destContainer:getParent(), "IsoGameCharacter")) then
			--allow dropping full bags on an empty square or put full container in an empty container
			if not self.destContainer:getItems():isEmpty() then
				local destRoot = self:findRootInventory(self.destContainer);
				local srcRoot = self:findRootInventory(self.srcContainer);
				--total count remains the same if the same root container
				if srcRoot ~= destRoot then
					local tranferItemsNum = 1;
					if self.item:getCategory() == "Container" then
						tranferItemsNum = self:countItemsRecursive({self.item:getInventory()}, 1);
					end;
					--count items from the root container
					local destContainerItemsNum = self:countItemsRecursive({destRoot}, 0);
					--if destination is an item then add 1
					if destRoot:getContainingItem() then destContainerItemsNum = destContainerItemsNum + 1; end;
					--total items must not exceed the server limit
					if destContainerItemsNum + tranferItemsNum > limit then
						return false;
					end;
				end;
			end;
		end;
	end;

    if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
        return false;
	end
	if not self.srcContainer:contains(self.item) then
		return false;
    end
    if self.srcContainer == self.destContainer then return false; end

    if self.destContainer:getType()=="floor" then
        if instanceof(self.item, "Moveable") and self.item:getSpriteGrid()==nil then
            if not self.item:CanBeDroppedOnFloor() then
                return false;
            end
        end
        if self:getNotFullFloorSquare(self.item) == nil then
            return false;
        end
    elseif not self.destContainer:hasRoomFor(self.character, self.item) then
        return false;
    end

    if not self.srcContainer:isRemoveItemAllowed(self.item) then
        return false;
    end
    if not self.destContainer:isItemAllowed(self.item) then
        return false;
    end
    if self.item:getContainer() == self.srcContainer and not self.destContainer:isInside(self.item) then
        return true;
    end
    if isClient() and self.srcContainer:getSourceGrid() and SafeHouse.isSafeHouse(self.srcContainer:getSourceGrid(), self.character:getUsername(), true) then
        return false;
	end
    return false;
end

local CampfireDup_fix = function ()
    local oldfunc = ISDestroyStuffAction.isValid
    function ISDestroyStuffAction.isValid(self)
        if self.item:getSprite():getName() == "camping_01_6" or self.item:getName() == "Campfire" then 
             return false
        end
        return oldfunc(self)
    end
end

Events.OnGameStart.Add(CampfireDup_fix)