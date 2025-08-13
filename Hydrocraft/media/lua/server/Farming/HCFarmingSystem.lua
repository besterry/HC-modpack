--overrides server/farming/SFarmingSystem.lua


if isClient() then return end



-- adding a few more fields for other timed actions here.

function SFarmingSystem:initSystem()
	SGlobalObjectSystem.initSystem(self)

	-- Specify GlobalObjectSystem fields that should be saved.
	self.system:setModDataKeys({'hoursElapsed'})
	
	-- Specify GlobalObject fields that should be saved.
	self.system:setObjectModDataKeys({
		'state', 'nbOfGrow', 'typeOfSeed', 'fertilizer', 'mildewLvl',
		'aphidLvl', 'fliesLvl', 'waterLvl', 'waterNeeded', 'waterNeededMax',
		'lastWaterHour', 'nextGrowing', 'hasSeed', 'hasVegetable',
		'health', 'badCare', 'exterior', 'spriteName', 'objectName'})

	self:convertOldModData()
end



-- had to be rewritten to embed the new crops. Will be switched to HCgrowAllPlants for all plants as soon as it was tested productive.
function SFarmingSystem:growPlant(luaObject, nextGrowing, updateNbOfGrow)
	if(luaObject.state == "seeded") then
		local new = luaObject.nbOfGrow <= 0
		-- allow FarmingNeverRot mod to work with hydrocraft
		if (getActivatedMods():contains("FarmingNeverRot")) then
			--NeverRot is this if statement.
			if (luaObject.nbOfGrow >6) then
				luaObject.nbOfGrow = 6
			end
		end
		
		luaObject = farming_vegetableconf.HCgrowAllPlants(luaObject, nextGrowing, updateNbOfGrow)
		if not new and luaObject.nbOfGrow > 0 then
			self:diseaseThis(luaObject, true)
		end
		luaObject.nbOfGrow = luaObject.nbOfGrow + 1
	end
end


-- had to be rewritten because of multiharvest option (многоурожайность)
function SFarmingSystem:harvest(luaObject, player)
	local props = farming_vegetableconf.props[luaObject.typeOfSeed]
	local numberOfVeg = getVegetablesNumber(props.minVeg, props.maxVeg, props.minVegAutorized, props.maxVegAutorized, luaObject)
	if player then
		player:sendObjectChange('addItemOfType', { type = props.vegetableName, count = numberOfVeg })
	end

	if luaObject.hasSeed and player then
		player:sendObjectChange('addItemOfType', { type = props.seedName, count = (props.seedPerVeg * numberOfVeg) })
	end

	luaObject.hasVegetable = false
	luaObject.hasSeed = false

	-- multiharvest option
	if props.multiHarvest == true then
		luaObject.nbOfGrow = 3
		luaObject.fertilizer = 0;
		self:growPlant(luaObject, nil, true)
		luaObject:saveData()
	else
		self:removePlant(luaObject)
	end
end

function SFarmingSystem:changeHealth() -- функция для изменения здоровья растения
	-- local gameTime = getGameTime()
	-- print("gameTime " , gameTime:getHours(),':',gameTime:getMinutes())
	--Инициализация переменных
	local lightStrength = ClimateManager.getInstance():getDayLightStrength() --Солнечный свет
	-- print("lightStrength: " , lightStrength)
	local rainStrength = ClimateManager.getInstance():getRainIntensity() --Дождь
	-- print("rainStrength: " , rainStrength)
	local windStrength = ClimateManager.getInstance():getWindIntensity() --Ветер
	-- print("windStrength: " , windStrength)
	local luaObject = nil --Растение
	local props = nil --Свойства растения
	local minWater = 0 --Минимальный уровень воды
	local maxWater = 0 --Максимальный уровень воды
	local availableWater = 0 --Доступный уровень воды
	local waterbarrel = nil --Бочка с водой
	local waterNeeded = 0  --Нужное количество воды
	local needs=0 --Нужное количество воды
	local has=0 --Доступный уровень воды

	for i=1,self:getLuaObjectCount() do -- цикл по всем растениям
		luaObject = self:getLuaObjectByIndex(i) -- получаем растение
		local temperature = ClimateManager.getInstance():getAirTemperatureForSquare(luaObject:getSquare()) --indoor temp is 22a (внутри температура 22)
		-- print("temperature: " , temperature)
		if luaObject.state == "seeded" then -- если растение посажено
			props = farming_vegetableconf.props[luaObject.typeOfSeed] --seedsRequired, texture, waterLvl, waterLvlMax, timeToGrow, minVeg, maxVeg, minVegAutorized, maxVegAutorized, vegetableName, seedName, seedCollect, seedPerVeg, minTemp, bestTemp, maxTemp, plantWithFruit, damageFromStorm, multiHarvest, vegetableName2, numberOfVegetables2

			-- Уровень воды у растения
			availableWater = luaObject.waterLvl --Уровень воды у растения
			minWater = props.waterLvl --Минимальный уровень воды
			maxWater = props.waterLvlMax --Максимальный уровень воды

			-- Система полива растений из бочки
			waterbarrel=self:findbarrel(luaObject:getSquare()) --Находим бочку с водой
			if waterbarrel ~= nil then
				raingutter = self:findRainGutter(waterbarrel:getSquare()) -- Находим дождеприёмник
				if raingutter then 
					needs = waterbarrel:getWaterMax() - waterbarrel:getWaterAmount() -- Сколько можно долить в бочку
					has = raingutter:getWaterAmount() -- Сколько воды в дождеприёмнике
					
					if has > 0 then -- Если в желобе есть вода
						if needs > 0 then -- Если бочка не полная
							local transferAmount = math.min(needs, has) -- Берем минимум из возможного							
							-- Переливаем воду
							raingutter:setWaterAmount(raingutter:getWaterAmount() - transferAmount)
							waterbarrel:setWaterAmount(waterbarrel:getWaterAmount() + transferAmount)							
							-- print("Transferred " .. transferAmount .. " water from gutter to barrel")
						else
							-- print("Barrel is already full")
						end
					else
						-- print("Rain gutter is empty")
					end
				end 

				-- print ("plant:" ..  availableWater ..   " barrel: ".. waterbarrel:getWaterAmount()) -- количество воды, которое есть у растения и количество воды в бочке
				-- полив растения из бочки
				if availableWater < maxWater then
					waterNeeded = maxWater - availableWater 
					if waterNeeded < waterbarrel:getWaterAmount() then
						waterbarrel:setWaterAmount(waterbarrel:getWaterAmount()- (waterNeeded / 4)) -- 
						availableWater=100
						luaObject.waterLvl=100
					end
				end
				-- print("waterbarrel:" , waterbarrel:getWaterAmount(), " waterNeeded: " , waterNeeded) -- количество воды в бочке и количество воды, которое нужно растению
				-- waterbarrel:setWaterAmount(300) -- устанавливаем количество воды в бочке (для отладки)
			end


			--print ("*******  Change Health for:" .. luaObject.typeOfSeed .. "  temp:" .. temperature .. "  Waterlevel:" .. availableWater)
			local square = luaObject:getSquare() -- квадрат, на котором растение
			local cX, cY, cZ = 0, 0, 0
			if square ~= nil then -- Для отладки, когда в прогрузке будут получены координаты квадрата
				cX = square:getX() -- координата X квадрата
				cY = square:getY() -- координата Y квадрата
				cZ = square:getZ() -- координата Z квадрата
			end

			if not luaObject.exterior then -- ***indoors*** (внутри)			
				if square ~= nil then 
					luaObject.hasWindow = self:checkWindowsAndGreenhouse(square) 
					-- print ("hasWindow: " , luaObject.hasWindow)
				end -- проверяем, есть ли окна и теплица			
				if luaObject.hasWindow then --indoors with greenhouse: no negative effects on weather (внутри с теплицей: нет отрицательного влияния на погоду)
					-- print (luaObject.typeOfSeed .. " + [TEPLICA] plant is indoors with greenhouse at: " .. cX .. "," .. cY .. "," .. cZ)
					luaObject.health = luaObject.health + (lightStrength*3) 
				else 
					-- print (luaObject.typeOfSeed .. " - [NO TEPLICA] plant is indoors without a greenhouse at: " .. cX .. "," .. cY .. "," .. cZ)
					luaObject.health = luaObject.health - 10 -- no indoor growing without a greenhouse plant will die (без теплицы растение умрёт)
				end -- greenhouse check

			else -- **** Outdoors ***	 (на улице)
				-- print (luaObject.typeOfSeed .. " ~ [OUTSIDE] - storm and frost handling at: " .. cX .. "," .. cY .. "," .. cZ)
				if temperature < 0 then  availableWater = 0 -- no available Water if outdoors and frozen (если температура ниже 0, то нет доступной воды)
				end
				
				-- temp handling (обработка температуры)
				if temperature < props.bestTemp then 
					luaObject.health = luaObject.health + 0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.minTemp) * 1.5 -- +0.5 at best temp, -1 at min temp
				else 
					luaObject.health = luaObject.health + 0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.maxTemp)  -- -0.5 at max temp
				end

				-- storm handling (обработка шторма)
				if props.damageFromStorm and luaObject.nbOfGrow >= 3 and rainStrength > 0.5 and windStrength > 0.5 then 
					luaObject.health = luaObject.health - (16 * rainStrength * windStrength -3) -- 1-13 damage
				end

			end -- indoors/outdoors	 (внутри/снаружи)


			-- sunlight (солнечный свет)
			luaObject.health = luaObject.health + lightStrength / 5 -- только среднее ~0.1/ч внутри
		
			-- water levels (уровень воды)
			if availableWater < minWater then 
				luaObject.health = luaObject.health - 0.5 - (minWater - availableWater) / 50 -- минимум 0.5 - максимум ~1.4/2.1, в зависимости от растения
			elseif availableWater > maxWater then 
				luaObject.health = luaObject.health - (availableWater - maxWater) / 50 -- максимум ~0.3 урона для большинства растений
			else 
				luaObject.health = luaObject.health + 1 - math.abs(minWater + (maxWater-minWater)/2 - availableWater)/(maxWater-minWater)/2 -- 0-1 прирост
			end

			-- mildew disease (грибки)
			if luaObject.mildewLvl > 0 then 
				luaObject.health = luaObject.health - 0.2 - luaObject.mildewLvl/50 -- 0.2 - 2.2 урона
			end
			if luaObject.aphidLvl > 0 then 
				luaObject.health = luaObject.health - 0.15 - luaObject.mildewLvl/75 -- 0.15 - 1.6 урона
			end
			if luaObject.fliesLvl > 0 then 
				luaObject.health = luaObject.health - 0.1 - luaObject.mildewLvl/100 -- 0.1 - 1.1 урона
			end

			-- plant dies (растение умирает)
			if luaObject.health <= 0 then
				if luaObject.exterior and rainStrength > 0.7 and windStrength > 0.7 then luaObject:destroyThis()
				elseif luaObject.exterior and temperature <= 0 then luaObject:dryThis()
				elseif luaObject.waterLvl <= 0 then luaObject:dryThis()
				elseif luaObject.mildewLvl > 0 then luaObject:rottenThis()
				else luaObject:dryThis()
				end
			end
		end -- seeded? (посажено)
	end -- loop over getLuaObjectCount
end -- function



function SFarmingSystem:findbarrel(sq)
	if sq then
		local x=sq:getX()  -- координата X квадрата
		local y=sq:getY()  -- координата Y квадрата
		local z=sq:getZ()  -- координата Z квадрата
		local objs = nil -- объекты на квадрате
		local barrel = nil -- бочка с водой

		for x = x-1,x+1 do -- цикл по всем квадратам вокруг растения
			for y = y-1,y+1 do -- цикл по всем квадратам вокруг растения
				gridSquare = getCell():getGridSquare(x,y,z) -- получаем квадрат
				if gridSquare ~= nil then
					objs = gridSquare:getObjects() -- получаем объекты на квадрате
					if objs:size() > 1 then -- если объектов больше 1
						for i = 0, objs:size()-1 do -- цикл по всем объектам
							barrel = objs:get(i) -- получаем объект
							if barrel:getWaterAmount() > 0 then return barrel end -- если бочка с водой найдена, возвращаем её
						end 
					end
				end
			end
		end
	end
	return nil
end

-- проверка на наличие помещения и прозрачной крыши
function SFarmingSystem:checkWindowsAndGreenhouse(sq)
	-- print ("check if windows and greenhouse..")
	if sq == nil then 
		-- print ("It has no square," , sq)
		return nil 
	end
    	
	--Проверка на наличие помещения
	local room = sq:isInARoom()
	-- print ("room: " , room)
	if not room then 
		-- print ("It has not in room")
		return false 
	end

	if self:checkRoof(sq) > 0 then
		-- print ("It has a glass roof")
		return true
	end
	-- print ("It has no glass roof")
	return false
end


function SFarmingSystem:checkRoof(sq)	-- проверка на наличие прозрачной крыши
	sq = getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ()+1) -- +1 этаж выше
	if sq == nil then return 0 end

	local objs = sq:getObjects() -- получаем объекты на квадрате
	if objs:size() > 0 then
		if objs:get(0):getSprite() then -- получаем спрайт объекта
			local id = objs:get(0):getSprite():getID() -- получаем ID спрайта
			if id >= 220032 and id <= 220079 then --220055 is the HC glass roof
				if id >= 220032 and id <= 220047 then return 2 --slopes probably exist twice, but the 2nd one is hidden because of iso perspective -- возвращаем 2 если это крыша
				elseif id >= 220050 and id <= 220061 then return 1 -- возвращаем 1 если это крыша
				elseif id == 220078 or id == 220079 then return 1 -- возвращаем 1 если это крыша
				end
			end
		end
	end
	return 0
end


function SFarmingSystem:findRainGutter(sq)
	if sq then
		local x=sq:getX()
		local y=sq:getY()
		local z=sq:getZ()+1
		local objs = nil
		local barrel = nil
		sq = getCell():getGridSquare(x,y,z)
		if sq ~= nil then
			objs = sq:getObjects()
			if objs:size() > 1 then
				if objs:get(1):getSprite() then
					barrel = objs:get(1)
					if barrel:getWaterAmount() > 0 then return barrel end
				end 
			end 
		end
	end 
	return nil
end  