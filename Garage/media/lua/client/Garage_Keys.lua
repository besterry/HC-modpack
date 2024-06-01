Garage = Garage or {}

--Поиск ключа возле автомобиля на стороне клиента
local keyFind = {}
keyFind.count = 0
function keyFind.find()

	if not keyFind.x or not keyFind.y  or not keyFind.keyId then 
		Events.EveryOneMinute.Remove(keyFind.find)
		keyFind.event=false
		keyFind.count = 0
		return
	end
	
	--Удаление с пола
	local cell = getCell()
	local itemBuffer = {}
	for x=keyFind.x-10, keyFind.x+10 do
		for y=keyFind.y-10, keyFind.y+10 do
			local sq = cell:getGridSquare(x, y, 0)
			for i=0, sq:getObjects():size()-1 do
				local object = sq:getObjects():get(i)
				if instanceof(object, "IsoWorldInventoryObject") then
					local item = object:getItem()
					if item:getType() == "CarKey" and item:getKeyId()==keyFind.keyId then
						table.insert(itemBuffer, { it = object, square = sq })
					end
				end
			end
		end
	end

	--Удаление с контейнеров со всех уровеней по этажности
	for x=keyFind.x-10, keyFind.x+10 do
		for y=keyFind.y-10, keyFind.y+10 do
			--Вычисляем максимальный Z для этой клетки
			local maxZ = 0
			while cell:getGridSquare(x, y, maxZ+1) do
				maxZ = maxZ + 1
			end
			for z=0, maxZ do
				local sq = cell:getGridSquare(x, y, z)
				if sq then
					for i=0, sq:getObjects():size()-1 do
						local object = sq:getObjects():get(i)
						if object:getContainer() then
							local container = object:getContainer()
							local items = container:getItems()
							if items:size()~=0 then
								local tItems = {}
								for i = 0, items:size()-1 do
									local item = items:get(i)
									if item:getType() == "CarKey" and item:getKeyId()==keyFind.keyId then
										table.insert(tItems, item)
									end
								end
								for i, v in ipairs(tItems) do
									ISRemoveItemTool.removeItem(v, getPlayer())
								end
							end
						end
					end
				end
			end
		end
	end

	keyFind.count = keyFind.count + 1

	if #itemBuffer>0 then
		--print("REMOVE KEY!!!")
		for i, itemData in ipairs(itemBuffer) do
			local sq = itemData.square
			local item = itemData.it
			sq:transmitRemoveItemFromSquare(item);
			item:removeFromWorld()
			item:removeFromSquare()
			item:setSquare(nil)
		end
		Events.OnPlayerUpdate.Remove(keyFind.find)
		keyFind.event=false
		keyFind.count = 0
	end

	if keyFind.count>200 then
		Events.OnPlayerUpdate.Remove(keyFind.find)
		keyFind.event=false
		keyFind.count = 0
	end
end
keyFind.event = false

--Команда от сервера к клиенту findKeyCarEvent которая активирует поиск
--Ключа возле машины
function Garage.findKeyCarEvent(module, command, args)
    if module ~= "Garage" or command ~= "findKeyCarEvent" then return end
	keyFind.x = args.x
	keyFind.y = args.y
	keyFind.keyId = args.keyId

	if not keyFind.event then
		Events.OnPlayerUpdate.Add(keyFind.find)
		keyFind.event=true
	end
end
Events.OnServerCommand.Add(Garage.findKeyCarEvent)