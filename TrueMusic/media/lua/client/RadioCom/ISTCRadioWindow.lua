-- @filename - ISTCRadioWindow.lua
require "TCMusicClientFunctions"

TCMusic.oldISRadioWindow_activate = ISRadioWindow.activate

function ISRadioWindow.activate( _player, _item, bol)
-- print("ISRadioWindow.activate")
    if _player == getPlayer() then
        if instanceof(_item, "Radio") then
            if TCMusic.ItemMusicPlayer[_item:getFullType()] then
                if _player:getSecondaryHandItem() == _item then
                    ISTCBoomboxWindow.activate( _player, _item );
                end
            elseif TCMusic.WalkmanPlayer[_item:getFullType()] then
                ISTCBoomboxWindow.activate( _player, _item );
            else
                TCMusic.oldISRadioWindow_activate( _player, _item, bol );
            end
        elseif instanceof(_item, "IsoWaveSignal") then
            if not _item:getSprite() or not TCMusic.WorldMusicPlayer[_item:getSprite():getName()] then
                -- ищем старой радио, и создаем новое радио
                for i=0, _item:getSquare():getWorldObjects():size()-1 do
                    local itemObj = _item:getSquare():getWorldObjects():get(i)
                    if instanceof(itemObj:getItem(), "Radio") then
                        if itemObj:getItem():getID() == _item:getModData().RadioItemID then
                            if TCMusic.WorldMusicPlayer[itemObj:getItem():getFullType()] then
                                -- нашли стандартное радио и удаляем его
                                invItem = itemObj:getItem()
                                square = itemObj:getSquare()
                                
                                square:transmitRemoveItemFromSquare(_item)
                                square:RecalcProperties();
                                square:RecalcAllWithNeighbours(true);
                                
                                local radio = IsoRadio.new(getCell(), square, getSprite(TCMusic.WorldMusicPlayer[invItem:getFullType()]))
                                square:AddTileObject(radio)
                                if invItem:getModData().tcmusic then
                                    radio:getModData().tcmusic = invItem:getModData().tcmusic
                                else
                                    radio:getModData().tcmusic = {}
                                end
                                radio:getModData().tcmusic.itemid = square:getX() .. 
                                                                    square:getY() .. 
                                                                    square:getZ()
                                -- invItem:getModData().tcmusic.worldObj = radio
                                radio:getModData().tcmusic.deviceType = "IsoObject"
                                radio:getModData().tcmusic.isPlaying = false
                                radio:getModData().RadioItemID = invItem:getID() .. "tm"
                                -- local deviceData = invItem:getDeviceData();
                                -- if deviceData then
                                    -- radio:setDeviceData(deviceData);
                                -- end
                                radio:getDeviceData():setIsTurnedOn(false)
                                radio:getDeviceData():setPower(invItem:getDeviceData():getPower())
                                radio:getDeviceData():setDeviceVolume(invItem:getDeviceData():getDeviceVolume())
                                if invItem:getDeviceData():getIsBatteryPowered() and invItem:getDeviceData():getHasBattery() then
                                    radio:getDeviceData():setPower(invItem:getDeviceData():getPower())
                                else
                                    radio:getDeviceData():setHasBattery(false)
                                end
                                if invItem:getDeviceData():getHeadphoneType() >= 0 then
                                    invItem:getDeviceData():getHeadphones(_player:getInventory())
                                end
                                if isClient() then 
                                    radio:transmitCompleteItemToServer(); 
                                end
                                ISTCBoomboxWindow.activate( _player, radio );
                                return
                            elseif TCMusic.WalkmanPlayer[itemObj:getItem():getFullType()] then
                                return
                            else
                                TCMusic.oldISRadioWindow_activate( _player, _item, bol );
                                return
                            end
                        end
                    end
                end
            else
                for i=0, _item:getSquare():getWorldObjects():size()-1 do
                    local itemObj = _item:getSquare():getWorldObjects():get(i)
                    if instanceof(itemObj:getItem(), "Radio") then
                        if itemObj:getItem():getID() .. "tm" == _item:getModData().RadioItemID then
                            if TCMusic.WorldMusicPlayer[itemObj:getItem():getFullType()] then
                                ISTCBoomboxWindow.activate( _player, _item );
                                return
                            end
                        end
                    end
                end
            end
            TCMusic.oldISRadioWindow_activate( _player, _item, bol );
        else
            TCMusic.oldISRadioWindow_activate( _player, _item, bol );
        end
    end
end
