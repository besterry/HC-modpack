local ver = getCore():getGameVersion()

require((ver:getMajor() > 41 or ver:getMinor() >= 71) and 'BicPenNew' or 'BicPenOld')()

Events.OnGameTimeLoaded.Add(function()
	local recipe = getScriptManager():getModule('Base'):getRecipe('Transcribe Journal')
	if recipe then
		local sources = recipe:getSource()
		for i = 0, sources:size() - 1 do
			local items = sources:get(i):getItems()
			for j = 0, items:size() - 1 do
				if items:get(j) == 'Base.Pen' then
					items:add('BicPen.BicPen')
					return
				end
			end
		end
	end
end)
