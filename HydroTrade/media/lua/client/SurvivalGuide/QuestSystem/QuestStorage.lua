QuestStorage = QuestStorage or {}

QuestStorage.S_INACTIVE = 0
QuestStorage.S_ACTIVE = 1
QuestStorage.S_COMPLETE = 2
QuestStorage.S_CLAIMED = 3

local function defaultUi()
	return {
		collapsed = false,
		hidden = false,
		x = nil,
		y = nil,
	}
end

local function defaultQuestsBlock()
	return {
		ui = defaultUi(),
		tutorialOptedIn = false,
		entries = {},
	}
end

function QuestStorage.ensure(player)
	if not player then return nil end
	local md = player:getModData()
	if not md.ht then
		md.ht = { v = 1 }
	end
	if not md.ht.quests then
		md.ht.quests = defaultQuestsBlock()
	end
	local q = md.ht.quests
	if not q.ui then
		q.ui = defaultUi()
	end
	if q.tutorialOptedIn == nil then
		q.tutorialOptedIn = false
	end
	if not q.entries then
		q.entries = {}
	end
	return q
end

function QuestStorage.getUi(player)
	local q = QuestStorage.ensure(player)
	return q and q.ui or defaultUi()
end

function QuestStorage.isTutorialOptedIn(player)
	local q = QuestStorage.ensure(player)
	return q and q.tutorialOptedIn == true
end

function QuestStorage.setTutorialOptedIn(player, value)
	local q = QuestStorage.ensure(player)
	if q then
		q.tutorialOptedIn = value == true
	end
end

function QuestStorage.getEntry(player, questId)
	local q = QuestStorage.ensure(player)
	if not q or not questId then return nil end
	return q.entries[questId]
end

function QuestStorage.ensureEntry(player, questId)
	local q = QuestStorage.ensure(player)
	if not q or not questId then return nil end
	local entry = q.entries[questId]
	if not entry then
		entry = { s = QuestStorage.S_INACTIVE, p = {} }
		q.entries[questId] = entry
	end
	if not entry.p then
		entry.p = {}
	end
	if entry.s == nil then
		entry.s = QuestStorage.S_INACTIVE
	end
	return entry
end

function QuestStorage.getStatus(player, questId)
	local entry = QuestStorage.getEntry(player, questId)
	if not entry then return QuestStorage.S_INACTIVE end
	return entry.s or QuestStorage.S_INACTIVE
end

function QuestStorage.setStatus(player, questId, status)
	local entry = QuestStorage.ensureEntry(player, questId)
	if entry then
		entry.s = status
	end
end

function QuestStorage.getProgress(player, questId)
	local entry = QuestStorage.ensureEntry(player, questId)
	return entry and entry.p or {}
end

function QuestStorage.saveHudPosition(player, x, y)
	local ui = QuestStorage.getUi(player)
	ui.x = math.floor(x)
	ui.y = math.floor(y)
end
