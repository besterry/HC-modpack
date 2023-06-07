----------- Check Sleep	 --------- 
local function CheckIGUIDream(num)
	local str = 'IGUI_Dream'..num;
	return getText(str) ~= str; --Текст присутствует
end

local MAX_DREAMS = 87
local PEE_CHANCE = 0.1 -- Базовый шанс обмочиться от ужастиков
local DREAM_CHANCE = 0.33 -- Шанс сна на каждый день (по умолчанию)
local NEW_DREAM_DELAY = 12 --Количество игровых часов, в течение которых не может присниться второй сон

do --Проверка на вшивость
	--print('CHECK DREAMS')
	for i=1,MAX_DREAMS do
		--print(i,CheckIGUIDream(i))
		if not CheckIGUIDream(i) then
			--error('Dreams error! Dream not found:'..tostring(i))
			print('Dreams error! Dream not found: ',i)
			MAX_DREAMS = i-1
			break
		end
	end
	--Если были добавлены новые сны, автоматически расширяемся. Заодно выбрасываем ошибку.
	if CheckIGUIDream(MAX_DREAMS + 1) then
		print('Dreams error! Change MAX_DREAMS to '..tostring(MAX_DREAMS));
		while CheckIGUIDream(MAX_DREAMS + 1) do
			MAX_DREAMS = MAX_DREAMS + 1
		end
	end
end

for i=1,#DREAMS do
	local dream = DREAMS[i];
	if dream.happyness then
		dream.unhappiness = -tonumber(dream.happyness)
	end
	if dream.unhappiness then
		dream.unhappiness = tonumber(dream.unhappiness)
	end
	if dream.panic then
		dream.panic = tonumber(dream.panic)
	end
	if dream.stress then
		dream.stress = tonumber(dream.stress)
	end
end

local PLAYER = nil
local PLAYER_BD = nil
local PLAYER_STATS = nil
local IS_PLAYER_FEMALE = nil
local STAT = nil --Статистика снов игрока

--Данные о жизни игрока, свойства, бафы, бусты, штрафы и прочая инфа по моду.
local LIFE = nil
--[[
[1] - запоминаем, спит ли игрок, чтобы отслеживать смену состояния.
"l" = Последний сон - взято из GameTime:getInstance():getWorldAgeHours()
--]]

--Инициализирует игрока (если нужно) и его данные.
local function PlayerInit()
	local player = getPlayer()
	if player == PLAYER then
		return --и так все нормально
	end
	--print('NEW PLAYER! ',player);
	PLAYER = player
	IS_PLAYER_FEMALE = player:isFemale();
	PLAYER_BD = PLAYER:getBodyDamage();
	PLAYER_STATS = PLAYER:getStats();
	local data = player:getModData();
	if data.dreams then
		STAT = data.dreams.stat
		LIFE = data.dreams.life
	else --create new data
		STAT = { --Статистика показанных снов (количество показов).
			0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,
		};
		LIFE = {};
		data.dreams = {
			stat=STAT,
			life=LIFE,
		}
	end
end

--Функция фильтрации снов. На вход сон. Но выход - разрешено ли его применять.
function DreamFilter(dream)
	if dream.female_only and not IS_PLAYER_FEMALE then
		return
	end
	if dream.male_only and IS_PLAYER_FEMALE then
		return
	end
	return true
end

local is_SnorePlaySound = false; --проигран ли звук для текущего сна. true = да
local save_time_sleep_start = -99;
local save_sleep_duration = 0; --Продолжительность последнего сна.
local save_sleep_hunger = 0;
local save_bed_quality = nil;

--inject in onSleep function
--require "ISUI\ISWorldObjectContextMenu"
local oldOnSleep = ISWorldObjectContextMenu.onSleep
ISWorldObjectContextMenu.onSleep = function(bed, player, ...) --После команды меню появляется диалог, который может быть отменен.
	save_bed_quality = nil
	if bed and bed.getProperties then
		local props = bed:getProperties()
		if props.Val then
			save_bed_quality = props:Val("BedType") or "averageBed" ----> badBed, goodBed, averageBed
			--print('BED QUALITY: ',save_bed_quality) --debug
		end
	end
	oldOnSleep(bed, player, ...)
end

local function SaveStatsOnSleepBegin()
	save_time_sleep_start = GameTime:getInstance():getWorldAgeHours();
	save_sleep_hunger = PLAYER_STATS:getHunger()
end

--Проверить сон игрока (спит или не спит), и прореагировать на изменения.
local snore_sound = nil
function CheckSleepPlayer(player)
	PlayerInit()
	local is_asleep = PLAYER:isAsleep();
	
	if is_asleep ~= (LIFE[1] == 1) then
		if not is_asleep then --Момент пробуждения. Спал, потом перестал спать.
			--print('wake up neo');
			if snore_sound then
				snore_sound:stop();
				snore_sound = nil
			end
			OnCharacterDreams();
		else --Момент засыпания
			--Запомним время
			SaveStatsOnSleepBegin()
		end
		LIFE[1] = is_asleep and 1 or nil;
	end
	
	if is_asleep and not is_SnorePlaySound then --Звук во время сна.
		SnoreSound()
	end
end

function SnoreSound()
	is_SnorePlaySound = true;
	local player = getPlayer()
	if player:HasTrait("Snoring") then
		local snoring_chance = ZombRand(3);
		if snoring_chance == 0 then
			local snore_num = tostring(ZombRand(12)+1);
			local volume_snoring = (ZombRand(4)+1)/100;
			snore_sound = getSoundManager():PlayWorldSound("snore_" .. snore_num, false, player:getCurrentSquare(), 0.2, 60, 0.5, false);
		end
	end
end

function TryPee(chance)
	local r = ZombRand(10000) * 0.0001
	if r > chance then --Шанс, что случится мочеиспускание
		return
	end
	local pants = PLAYER:getClothingItem_Legs()
	if not pants then
		return --Нет штанов
	end
	if not pants.setWetness then
		return --Version 40.x and below
	end
	
    if Excrementum then
        Excrementum:InvoluntaryUrinate()
        return
    end
	
	pants:setDirtyness(100)
    pants:setWetness(100)
    pants:flushWetness() --Хз, что это. Примеров использования нет. Вроде ничего не ломает.
end

function NoDream()
	local DreamRandom = ZombRand(4);
	PLAYER:Say(getText("IGUI_NoDream"..DreamRandom));
end

--Проверяет, что число находится в заданном диапазоне
local function checkRange(num, min, max)
	if num < min then
		num = min
	end
	if num > max then
		num = max
	end
	return num
end

--Показывает сон с определенным номером
function ShowDream(num, text) -- num - номер сна. Возвращает сон, но может и вернуть nil, если сон фейлился.
	local dream = DREAMS[num]
	if not dream then
		return print('Dream #'..tostring(num)..' not found!') --debug
	end
	--Меняем заголовок окна снов
	DreamsWindow.title = getText("IGUI_Dreams_Window") .. tostring(num);
	--Выводим текст сна
	local Dreamstring = text or getText("IGUI_Dream"..num);
	if dream then --Добавляем цветные строки с подсказками
		--print('check dream')
		local add_green = ''
		local add_red = ''
		if dream.unhappiness then
			if dream.unhappiness < 0 then add_green = getText('Tooltip_food_Unhappiness')
			elseif dream.unhappiness > 0 then add_red = getText('Tooltip_food_Unhappiness')
			end
		end
		if dream.stress then
			if dream.stress > 0 then add_red = add_red .. (add_red == '' and '' or ', ') .. getText('Tooltip_food_Stress')
			elseif dream.stress < 0 then add_green = add_green .. (add_green == '' and '' or ', ') .. getText('Tooltip_food_Stress')
			end
		end
		if dream.panic then
			if dream.panic > 0 then add_red = add_red .. (add_red == '' and '' or ', ') .. getText('Moodles_panic_lvl2')
			elseif dream.panic < 0 then add_green = add_green .. (add_green == '' and '' or ', ') .. getText('Moodles_panic_lvl2')
			end
		end
		if add_green ~= '' or add_red ~= '' then
			if add_green ~= '' then
				add_green = ' <GREEN> '..add_green..' <LINE>'
			end
			if add_red ~= '' then
				add_red = ' <RED> '..add_red..' <LINE>'
			end
			Dreamstring = add_green .. add_red .. ' <RGB:1,1,1> ' .. Dreamstring
			--print('string = ',Dreamstring)
		end
	end
	DreamsWindow:setText(Dreamstring);
	DreamsWindow:setVisible(true);
	--Добавляем +1 в статистику просмотров
	if not STAT[num] then --Странная ситуация. Просмотрели сон, которого нет
		STAT[num] = 1
		--Проверка на вшивость. Возможно, у игрока старая версия мода и нужно заполнить пробелы
		for i=1,num-1 do
			if not STAT[i] then
				STAT[i] = 0;
			end
		end
	else
		STAT[num] = STAT[num] + 1;
	end
	--Персонаж произносит фразу при пробуждении, если есть
	if not dream then
		return print('ERROR! Dream #' + tostring(num) + ' not found!');
	end
	if dream.say then --Фраза указана
		local igui = type(dream.say) == 'string' and dream.say or ('IGUI_Dream'..num..'_Say')
		local str = getText(igui)
		if str ~= igui then
			PLAYER:Say(str);
		end
	elseif not dream.dont_say then --Фраза не указана, но и не запрещена
		local igui = 'IGUI_Dream'..num..'_Say'
		local str = getText(igui)
		if str ~= igui then
			PLAYER:Say(str);
		end
	end
	--Проверка на пипи
	if dream.pee then
		TryPee(dream.pee)
	end
	--Проверка на изменение статов
	if dream.unhappiness then
		local u = PLAYER_BD:getUnhappynessLevel();
		u = u + dream.unhappiness;
		PLAYER_BD:setUnhappynessLevel(checkRange(u,0,100));
	end
	if dream.panic then
		local x = PLAYER_STATS:getPanic();
		x = x + dream.panic;
		PLAYER_STATS:setPanic(checkRange(x,0,100));
	end
	if dream.stress then
		local x = PLAYER_STATS:getStress();
		x = x + dream.stress * 0.01;
		PLAYER_STATS:setStress(checkRange(x,0,1));
	end
	return dream
end

--Показывает случайный сон из заданного диапазона с учетом того, как часто сны были показаны до этого.
function ShowRandomDream(arr) -- arr - массив номеров снов
	if #arr == 0 then
		print("No dreams found.")
		return --nil
	end
	--do local s='Dreams: '; for k,v in pairs(arr) do s=s..tostring(v)..', ' end print(s) end
	local min_cnt = 999;
	for i=1,#arr do --Ищем минимальное количество показов
		local dream = arr[i]
		local cnt = STAT[dream] or 0 --На случай, если у игрока старая версия мода.
		if cnt < min_cnt then
			min_cnt = cnt
		end
	end
	local new_arr = {} --массив номеров снов
	for i=1,#arr do --Отсеиваем все сны, показанные в кол-ве выше минимального
		local dream = arr[i]
		if (STAT[dream] or 0) == min_cnt then
			table.insert(new_arr, dream)
		end
	end
	--do local s='New Dreams: '; for k,v in pairs(new_arr) do s=s..tostring(v)..', ' end print(s) end
	local r = ZombRand(#new_arr) + 1 --Выбираем случайный сон
	local dream_num = new_arr[r];
	--print('Chosen dream: '..tostring(dream_num))
	return ShowDream(dream_num)
end

--Специальные теги, которые исключают выбор снов из обычных.
--Особые сны показываются только в особых ситуациях.
--Осторожно! Теги являются взаимоисключающими, так что два тега сразу сделают показ сна невозможным.
local SPECIAL_TAGS = {
	helicopter=1, horror=1, hunger=1,
}

--Показать сон с данным тегом. Исключая теги из notags
function ShowTagDream(musttags,notags,fn_filter)
	--print('TagDream: ',musttags,' ',notags)
	--Prepare conditions
	local tags = {}
	if type(musttags) == 'string' then
		tags[musttags] = true
	elseif musttags == nil then
		tags.any = true
	else
		for _,v in pairs(musttags) do
			tags[v] = true
		end
	end
	if type(fn_filter) == 'string' then
		tags[fn_filter] = true
		fn_filter = nil
	end
	local arr = {} --new notags
	if type(notags) == 'string' then
		if musttags == nil then
			arr[notags] = true
		else
			tags[notags] = true
		end
	elseif type(notags) == 'table' then
		for _,v in pairs(notags) do
			arr[v] = true
		end
	end
	notags = arr
	--Filter all dreams
	arr = {} --Массив номеров снов
	for k,dream in pairs(DREAMS) do --Формируем список снов
		local good = true
		if not tags.any then
			for t,_ in pairs(tags) do
				if not dream[t] then
					good = false
					break
				end
			end
		end
		if good then --filter exclusions
			for t,_ in pairs(notags) do
				if dream[t] then
					good = false
					break
				end
			end
			if good then --filter special tags
				for t,_ in pairs(SPECIAL_TAGS) do
					if dream[t] and not tags[t] then
						good = false
						break
					end
				end
				if good and fn_filter and not fn_filter(dream) then --filter by function
					good = false
				end
			end
		end
		if good and DreamFilter(dream) then
			table.insert(arr, k);
		end
	end
	--Choose random dream
	return ShowRandomDream(arr)
end

--Показывает сон на тему ужасов (случайно)
function ShowHorrorDream()
	--[[local arr_horrors = {} --Массив номеров снов
	for k,v in pairs(DREAMS) do --Формируем список ужасов
		if v.horror and DreamFilter(v) then
			table.insert(arr_horrors, k);
		end
	end
	local dream = ShowRandomDream(arr_horrors) --]]
	local dream = ShowTagDream{'horror'}
	if dream then
		TryPee(PEE_CHANCE + (dream.pee or 0))
	end
	return dream
end

--Показывает ОБЫЧНЫЙ (нейтральный) сон (случайно)
function ShowNormalDream()
	--[[local arr = {} --Массив номеров снов
	for k,v in pairs(DREAMS) do --Формируем список обычных снов
		if not v.horror and DreamFilter(v) then
			table.insert(arr, k);
		end
	end--]]
	return ShowTagDream(nil,'horror')
	--return ShowRandomDream(arr)
end

--Вывести какой-то релевантный сон. Срабатывает всегда в момент пробуждения.
function OnCharacterDreams()
	is_SnorePlaySound = false;
	--Защищаемся от абьюза со снотворным и будильником
	local hours = GameTime:getInstance():getWorldAgeHours()
	do
		local last_dream = LIFE.l or 0;
		if hours - last_dream < NEW_DREAM_DELAY then
			--return NoDream(); --Ещё рано показывать новый сон.
		end
	end
	save_sleep_duration = hours - save_time_sleep_start; --Будет 12 при самом худшем раскладе.

	--Особые события с высоким приоритетом
	local checkAllConditions = function()
		local dream = nil
		--Helicopter
		local tm = getGameTime()
		local copter_day1 = tm:getHelicopterDay1()
		if copter_day1 > 0 then
			--Ровно в 7:00 засчитывается ночь как +1, но персонаж может проснуться до 7:00, поэтому нужно учесть утро (ночь).
			local cnt_nights = tm:getNightsSurvived()
			if cnt_nights == copter_day1 or cnt_nights+1 == copter_day1 then --Предварительная оценка: День Х сегодня или завтра.
				--local d = (hours+7)%24; --Текущий час на стандартных настройках мира. TODO: изменить
				local d = tm:getHour() --Точное время (текущий час в сутках).
				if cnt_nights == copter_day1 and d >= 7 and d <= 20 or cnt_nights+1 == copter_day1 and d < 7 then --Учитываем утро
					dream = ShowTagDream('helicopter')
					if dream then return dream end
				end
			end
		end
		--Panic
		local DreamPanic = getPlayer():getStats():getPanic();
		if DreamPanic > 0 then --horror
			dream = ShowHorrorDream()
			if dream then return dream end
		end
		--Hunger
		if save_sleep_hunger > 0.15 then --Проголодался (Слегка голоден)
			dream = ShowTagDream('hunger')
			if dream then return dream end
		end
		--Normal (Last condition)
		local noDreamRandom = ZombRand(10000);
		if noDreamRandom > 10000 * DREAM_CHANCE then --шанс, что сна не будет
			return NoDream(); --dream = nil;
		else
			return ShowNormalDream()
		end
	end
	local dream = checkAllConditions()

	if dream then --Сон был
		--Запоминаем время сна
		LIFE.l = hours;
	end
	return dream
end

--Привязка проверок ко времени
local lastMinute = nil
Events.OnTick.Add(function()
	local minute = getGameTime():getMinutes()
		if minute ~= lastMinute or is_asleep then
			lastMinute = minute
			CheckSleepPlayer()
	end
end)--ISWorldObjectContextMenu.onSleep