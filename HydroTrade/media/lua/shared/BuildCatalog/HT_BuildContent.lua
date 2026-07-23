-- Orchestrator: registers all catalog content from source menus (vanilla costs).

HT_BuildContent = HT_BuildContent or {}

HT_BuildContent.register = function()
	if HT_BuildContent_Vanilla and HT_BuildContent_Vanilla.register then
		HT_BuildContent_Vanilla.register()
	end
	if HT_BuildContent_Metal and HT_BuildContent_Metal.register then
		HT_BuildContent_Metal.register()
	end
	if HT_BuildContent_MB and HT_BuildContent_MB.register then
		HT_BuildContent_MB.register()
	end
	if HT_BuildContent_HC and HT_BuildContent_HC.register then
		HT_BuildContent_HC.register()
	end
	if HT_BuildContent_ItemStorage and HT_BuildContent_ItemStorage.register then
		HT_BuildContent_ItemStorage.register()
	end
end

