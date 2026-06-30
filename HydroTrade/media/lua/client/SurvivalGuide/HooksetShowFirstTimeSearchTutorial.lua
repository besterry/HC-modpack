-- Отключаем ванильный туториал поиска (F1): с кастомным Survival Guide он падает в ISTutorialPageInfo.
function ISSearchWindow:checkShowFirstTimeSearchTutorial()
	if getCore():isShowFirstTimeSearchTutorial() then
		getCore():setShowFirstTimeSearchTutorial(false)
		getCore():saveOptions()
	end
	return false
end
