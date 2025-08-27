--Модифицированная функция получения ВАНИЛЬНОГО убежища
--Начальная Цель: ограничить поселение в зоне если в доме больше 1 квартиры

--доп функция на проверку нахождения в запрещённых координатах
local function checkTownZones(x,y,x1,x2,y1,y2)
	--print ("2Players cord: " .. x .. "," .. y .. ",0")
	
	for xVal = x1, x2-1 do
        for yVal = y1, y2-1 do
			if (xVal==x) and (yVal==y) then
				--print ("coords zapret")
				return true;
			end
        end;
    end;
	
	return false;
end


ISWorldObjectContextMenu.onTakeSafeHouse = function(worldobjects, square, player)

--================================================
--Запрет на заселение в некоторых городах
--================================================
local x = math.floor((getPlayer():getX())/100)
local y = math.floor((getPlayer():getY())/100)

--Координаты запрещённые к заселению в городах
--Луи
local x1 = 11700 / 100   	--X минимальное
local x2 = 14400 / 100 		--X макс
local y1 = 900 / 100 		--Y мин
local y2 = 3900 / 100 		--Y макс
if checkTownZones(x,y,x1,x2,y1,y2) then 
	getPlayer():Say(getText("IGUI_Luis_detected"))
	return
end
--================================================
--В многоквартирных домах
--================================================
	--Какое кол во кухонь
	_n=2
	--Счётчик комнат
	local numberApartments = 0
	--если есть квадрат то,
	if square then
		--спрашиваем у него "строение"
		local building = square:getBuilding()
		--если есть строение, то
		if building then
			--создаём переменную, в которой у строения спрашиваем
			--Def, и только после этого сколько комнат
			local rooms =  building:getDef():getRooms()
			--запускаем цикл - поиск по комнатам, начинаем с 0
			--заканчиваем кол-во комнат -1 (т.к. в луа некоторые таблицы)
			--начинаются с нуля, в частности эта
			for i = 0, rooms:size() - 1 do
				--создаём переменную названия комнаты
				local roomName = rooms:get(i):getName()
				--если в названии есть слово "кухня, то в счётчик
				--прибавляем один
				if roomName == "kitchen" then
					numberApartments = numberApartments + 1
				end
				if roomName == "grocery" or roomName == "toolstore" or roomName == "poststorage" or roomName == "post" or roomName == "bank" or roomName == "storage" or roomName == "office" then
					numberApartments = numberApartments + 3
				end
				--если счётчик больше N, говорим фразу над головой
				--и прерываем выполнение скрипта
				if numberApartments > _n then
					getPlayer():Say(getText("IGUI_Big_House"))
					--player:Say("This Dom Very Big Papartments")
					return
				end
			end
		end
	end
	--повторно делаем проверку на кол-во комнат, если их больше
	--N прерываем скрипт
	if numberApartments > _n then
		getPlayer():Say(getText("IGUI_Big_House"))
		return
	end
	
	--если мы дошли до сюда, значит можно выдать приват
	SafeHouse.addSafeHouse(square, getSpecificPlayer(player));
	--buildUtil.setHaveConstruction(square, true);
end