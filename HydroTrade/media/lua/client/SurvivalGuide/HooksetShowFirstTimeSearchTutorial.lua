local old_checkShowFirstTimeSearchTutorial = ISSearchWindow.checkShowFirstTimeSearchTutorial

function ISSearchWindow:checkShowFirstTimeSearchTutorial()
    local o = old_checkShowFirstTimeSearchTutorial()
    if getCore():isShowFirstTimeSearchTutorial() then
        getCore():setShowFirstTimeSearchTutorial(false);
		getCore():saveOptions();
    end
    return o
end
