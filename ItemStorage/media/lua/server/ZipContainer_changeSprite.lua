ZipServer = {}

local function getZipObject(coords,spriteCurrent)
    local square = getCell():getGridSquare(coords.x, coords.y, coords.z)
	if not square then return nil end
	for i=0,square:getSpecialObjects():size()-1 do
		local o = square:getSpecialObjects():get(i)
        local sprite = o:getSprite():getName()
        if string.find(sprite,ZipContainer.spritePrefix) and spriteCurrent == sprite then
            return o
        end
	end
	return nil
end

function ZipServer.ChangeSprite(player,args)
    local sprite = args[1]
    local coords = args[2]
    local currentSprite = args[3]
    local shop = getZipObject(coords,currentSprite)
    if shop then
        shop:setSprite(sprite)
        shop:sendObjectChange('sprite')
    end
end

local function PS_OnClientCommand(module, command, player, args)
    if module == "PS" and ZipServer[command] then
        ZipServer[command](player, args)
    end
end

Events.OnClientCommand.Add(PS_OnClientCommand)