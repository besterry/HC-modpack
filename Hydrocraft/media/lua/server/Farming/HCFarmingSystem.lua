--overrides server/farming/SFarmingSystem.lua

if isClient() then return end

local debug = false -- для отладки
local function debugLog(message)
	if debug then
		print(message)
	end
end
-- adding a few more fields for other timed actions here. (добавляем несколько полей для других действий с временными интервалами)

function SFarmingSystem:initSystem()
	SGlobalObjectSystem.initSystem(self)

	-- Specify GlobalObjectSystem fields that should be saved.
	self.system:setModDataKeys({'hoursElapsed'})
	
	-- Specify GlobalObject fields that should be saved.
	self.system:setObjectModDataKeys({
		'state', 'nbOfGrow', 'typeOfSeed', 'fertilizer', 'mildewLvl',
		'aphidLvl', 'fliesLvl', 'waterLvl', 'waterNeeded', 'waterNeededMax',
		'lastWaterHour', 'nextGrowing', 'hasSeed', 'hasVegetable',
		'health', 'badCare', 'exterior', 'spriteName', 'objectName', 'hasWindow'})

	self:convertOldModData()
end



-- Пришлось переписать, чтобы внедрить новые культуры. Перейду на HCgrowAllPlants для всех растений, как только он будет протестирован как продуктивный.
function SFarmingSystem:growPlant(luaObject, nextGrowing, updateNbOfGrow) -- созревание растения
	if(luaObject.state == "seeded") then -- если растение посажено
		local new = luaObject.nbOfGrow <= 0 -- если урожай равен 0, то растение новое

		if (getActivatedMods():contains("FarmingNeverRot")) then -- если мод FarmingNeverRot активен (растения никогда не умирают)
			--NeverRot is this if statement. (не будет расти больше 6 урожаев)
			if (luaObject.nbOfGrow >6) then -- если урожай больше 6, то урожай равен 6
				luaObject.nbOfGrow = 6
			end
		end
		
		luaObject = farming_vegetableconf.HCgrowAllPlants(luaObject, nextGrowing, updateNbOfGrow) -- растит растение
		if not new and luaObject.nbOfGrow > 0 then -- если растение не новое и урожай больше 0, то болезнь
			self:diseaseThis(luaObject, true) -- добавляет болезнь растению
		end
		luaObject.nbOfGrow = luaObject.nbOfGrow + 1 -- увеличивает урожай на 1
	end
end


-- had to be rewritten because of multiharvest option (многоурожайность)
function SFarmingSystem:harvest(luaObject, player) -- сбор урожая
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
		luaObject.nbOfGrow = ZombRand(2, 5)
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
	debugLog(" =============================== new cycle =============================== ")
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
		-- debugLog("temperature: " ..  temperature)
		if luaObject.state == "seeded" then -- если растение посажено
			props = farming_vegetableconf.props[luaObject.typeOfSeed] --seedsRequired, texture, waterLvl, waterLvlMax, timeToGrow, minVeg, maxVeg, minVegAutorized, maxVegAutorized, vegetableName, seedName, seedCollect, seedPerVeg, minTemp, bestTemp, maxTemp, plantWithFruit, damageFromStorm, multiHarvest, vegetableName2, numberOfVegetables2
			debugLog("--------------> " .. i)
			-- debugLog("nbOfGrow: " .. luaObject.nbOfGrow)
			-- debugLog("nextGrowing: " .. luaObject.nextGrowing)
			debugLog("Start health: " .. luaObject.health)
			-- Уровень воды у растения
			availableWater = luaObject.waterLvl --Уровень воды у растения
			minWater = props.waterLvl --Минимальный уровень воды
			maxWater = props.waterLvlMax --Максимальный уровень воды

			-- Система перелива воды из дождеприёмника в бочку
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
							-- debugLog("Transferred " .. transferAmount .. " water from gutter to barrel")
						else
							-- debugLog("Barrel is already full")
						end
					else
						-- debugLog("Rain gutter is empty")
					end
				end 

				-- debugLog("plant:" ..  availableWater ..   " barrel: ".. waterbarrel:getWaterAmount()) -- количество воды, которое есть у растения и количество воды в бочке
				-- полив растения из бочки
				--availableWater - текущий уровень воды у растения
				--maxWater - максимальный уровень воды у растения
				--waterbarrel:getWaterAmount() - количество воды в бочке
				--waterNeeded - количество воды, которое нужно растению
				if availableWater < maxWater then -- если уровень воды меньше максимального уровня воды
					local currentWaterbarrel = waterbarrel:getWaterAmount() -- количество воды в бочке
					local waterNeeded = maxWater - availableWater -- сколько воды нужно растению
					local waterToTransfer = math.min(waterNeeded, currentWaterbarrel) -- сколько воды нужно перелить из бочки в растение
					--debugLog ("waterToTransfer: " , waterToTransfer)
					waterbarrel:setWaterAmount(currentWaterbarrel - waterToTransfer/4) -- устанавливаем количество воды в бочке после полива
					availableWater = availableWater + waterToTransfer -- устанавливаем количество воды в растении после полива
					luaObject.waterLvl = availableWater -- устанавливаем количество воды в растении после полива


					-- waterNeeded = maxWater - availableWater -- сколько воды нужно растению, максимальный уровень у растения - текущий уровень воды
					-- if waterNeeded < waterbarrel:getWaterAmount() then -- если количество воды, которое нужно растению, меньше количества воды в бочке
					-- 	waterbarrel:setWaterAmount(waterbarrel:getWaterAmount()- (waterNeeded / 4)) -- устанавливаем количество воды в бочке после полива
					-- 	availableWater=maxWater
					-- 	luaObject.waterLvl=maxWater
					-- end
				end
				-- print("waterbarrel:" , waterbarrel:getWaterAmount(), " waterNeeded: " , waterNeeded) -- количество воды в бочке и количество воды, которое нужно растению
				-- waterbarrel:setWaterAmount(300) -- устанавливаем количество воды в бочке (для отладки)
			end


			--print ("*******  Change Health for:" .. luaObject.typeOfSeed .. "  temp:" .. temperature .. "  Waterlevel:" .. availableWater)
			local square = luaObject:getSquare() -- квадрат, на котором растение
			-- local cX, cY, cZ = 0, 0, 0
			-- if square ~= nil then -- Для отладки, когда в прогрузке будут получены координаты квадрата
			-- 	cX = square:getX() -- координата X квадрата
			-- 	cY = square:getY() -- координата Y квадрата
			-- 	cZ = square:getZ() -- координата Z квадрата
			-- end

			if not luaObject.exterior then -- ***indoors*** (внутри)			
				if square ~= nil then 
					luaObject.hasWindow = self:checkWindowsAndGreenhouse(square) 
				end -- проверяем, есть ли окна и теплица			
				-- print ("hasWindow: " , luaObject.hasWindow)
				if luaObject.hasWindow then --indoors with greenhouse: no negative effects on weather (внутри с теплицей: нет отрицательного влияния на погоду)
					debugLog(" [TEPLICA] " .. luaObject.typeOfSeed)
					-- Сезонные модификаторы
					local season = getGameTime():getMonth()
					-- debugLog("season: " .. season)
					local seasonMultiplier = 1.0
					if season == 12 or season == 1 or season == 2 then seasonMultiplier = 0.01      -- Зима (3*0.01 = +0.03)
					elseif season == 3 or season == 4 or season == 5 then seasonMultiplier = 0.03  -- Весна (3*0.03 = +0.09)
					elseif season == 6 or season == 7 or season == 8 then seasonMultiplier = 0.05  -- Лето (3*0.05 = +0.15)
					elseif season == 9 or season == 10 or season == 11 then seasonMultiplier = 0.02  -- Осень (3*0.02 = +0.06)
					end
					--Это только бонус для теплицы за сезон + основной бонус от солнца
					debugLog("+ light teplitsa:" .. lightStrength*3 * seasonMultiplier)
					luaObject.health = luaObject.health + (lightStrength*3 * seasonMultiplier)
				else 
					debugLog(" - [NO TEPLICA] " .. luaObject.typeOfSeed .." -10 hp") -- растение находится в помещении, но не в теплице
					luaObject.health = luaObject.health - 10 -- no indoor growing without a greenhouse plant will die (без теплицы растение умрёт)
				end -- greenhouse check

			else -- **** Outdoors ***	 (на улице)
				debugLog("[OUTSIDE] ".. luaObject.typeOfSeed .. ", temp:"..temperature)
				if temperature < 0 then  
					availableWater = 0 -- если температура ниже 0, то нет доступной воды
					debugLog("temp<0 -> water=0")
				end
				-- temp handling (обработка температуры)
				if temperature < props.bestTemp then 
					luaObject.health = luaObject.health + 0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.minTemp) * 1.5 -- +0.5 при лучшей температуре, -1 при минимальной температуре
					debugLog("1temp damage: ".. (0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.minTemp) * 1.5 ))
				else 
					luaObject.health = luaObject.health + 0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.maxTemp)  -- -0.5 при максимальной температуре
					debugLog("2temp damage: ".. (0.5 - (props.bestTemp - temperature) / (props.bestTemp - props.maxTemp)))
				end

				-- storm handling (обработка шторма)
				if props.damageFromStorm and luaObject.nbOfGrow >= 3 and rainStrength > 0.5 and windStrength > 0.5 then 
					debugLog("storm damage: -".. (16 * rainStrength * windStrength -3))
					luaObject.health = luaObject.health - (16 * rainStrength * windStrength -3) -- 1-13 урона
				end

			end -- indoors/outdoors	 (внутри/снаружи)

			debugLog("light: +".. lightStrength/5)
			-- sunlight (солнечный свет)
			luaObject.health = luaObject.health + lightStrength / 5 -- только среднее ~0.1/ч внутри
			-- debugLog("light bonus outside: ".. lightStrength / 5)
			local water = farming_vegetableconf.calcWater(luaObject.waterNeeded, availableWater) --
			local waterMax = farming_vegetableconf.calcWater(availableWater, luaObject.waterNeededMax)
			-- debugLog("water: ".. water.. " waterMax: ".. waterMax)
			-- water levels (уровень воды)
			if water >= 0 and waterMax >= 0 then -- вода в норме
				luaObject.health = luaObject.health + 0.4
				debugLog("water level is normal: +0.4")
			elseif water == -1 then -- воды мало
				luaObject.health = luaObject.health - 0.2
				debugLog("water level is low: -0.2")
			elseif water == -2 then -- воды очень мало
				luaObject.health = luaObject.health - 0.5
				debugLog("water level is very low: -0.5")
			elseif waterMax == -1 and luaObject.health > 20 then -- воды мало и растение здоровое
				luaObject.health = luaObject.health - 0.2
				debugLog("water level is low: -0.2")
			elseif waterMax == -2 and luaObject.health > 20 then -- воды очень мало и растение здоровое
				luaObject.health = luaObject.health - 0.5
				debugLog("water level is very low: -0.5")
			end

			-- mildew disease (плесень)
			if luaObject.mildewLvl > 0 then 
				local mildewDamage = 0.2 - luaObject.mildewLvl/50 -- 0.2 - 2.2 урона
				luaObject.health = luaObject.health - mildewDamage
				debugLog("mildew damage: -".. mildewDamage)
			end
			if luaObject.aphidLvl > 0 then 
				local aphidDamage = 0.15 - luaObject.mildewLvl/75 -- 0.15 - 1.6 урона
				luaObject.health = luaObject.health - aphidDamage
				debugLog("aphid damage: -".. aphidDamage)
			end
			if luaObject.fliesLvl > 0 then 
				local fliesDamage = 0.1 - luaObject.mildewLvl/100 -- 0.1 - 1.1 урона
				luaObject.health = luaObject.health - fliesDamage
				debugLog("flies damage: ".. fliesDamage)
			end
			debugLog("final health: ".. luaObject.health)

			-- plant dies (растение умирает)
			if luaObject.health <= 0 then
				debugLog("plant dies: ".. luaObject.health)
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

-- Переопределяем ванильную функцию checkPlant для защиты теплиц
function SFarmingSystem:checkPlant()
    for i=1,self:getLuaObjectCount() do -- цикл по всем растениям
        local luaObject = self:getLuaObjectByIndex(i) -- получаем растение
        local square = luaObject:getSquare()
        if square then luaObject.exterior = square:isOutside() end -- проверяем, находится ли растение на улице
        
		-- we may destroy our plant if someone walk onto it
		self:destroyOnWalk(luaObject) -- уничтожаем растение, если кто-то на него наступит

		-- Something can grow up ! (что-то может вырастить!)
		if luaObject.nextGrowing ~= nil then
			if self.hoursElapsed >= luaObject.nextGrowing then
				self:growPlant(luaObject, nil, true)
			end
		end

        local hasWindow = luaObject.hasWindow
        -- Проверяем теплицу только если квадрат загружен
        local inGreenhouse = false
        if square and not luaObject.exterior then
            inGreenhouse = self:checkWindowsAndGreenhouse(square)
            -- Обновляем hasWindow только если квадрат доступен
            luaObject.hasWindow = inGreenhouse
        end
        
        -- Остальная логика...
        if luaObject.state ~= "plow" and luaObject:isAlive() then -- если растение не вспахано и живое
            if RainManager.isRaining() then -- если идёт дождь
                if luaObject.exterior then -- если растение на улице
                    luaObject.waterLvl = luaObject.waterLvl + 3 -- увеличиваем уровень воды на 3
                    if luaObject.waterLvl > 100 then -- если уровень воды больше 100, то устанавливаем 100
                        luaObject.waterLvl = 100 
                    end
                    luaObject.lastWaterHour = self.hoursElapsed -- устанавливаем время последнего полива
                end
            elseif season.weather == "sunny" then -- если солнце светит
                -- НЕ снижаем воду для растений в теплице
                if not inGreenhouse and not hasWindow then
                    luaObject.waterLvl = luaObject.waterLvl - 0.1
                    if luaObject.waterLvl < 0 then
                        luaObject.waterLvl = 0
                    end
                end
            end
        end
        
        luaObject:addIcon()
        luaObject:checkStat()
        luaObject:saveData()
    end
end  