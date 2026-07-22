-- Client prefs: favorites + last category for build catalog.

HT_BuildPrefs = HT_BuildPrefs or {}

local function store()
	return ModData.getOrCreate("HT_BuildCatalogPrefs")
end

HT_BuildPrefs.get = function()
	local md = store()
	if type(md.favorites) ~= "table" then
		md.favorites = {}
	end
	if type(md.lastCategory) ~= "string" then
		md.lastCategory = "Walls"
	end
	if type(md.lastSection) ~= "string" then
		md.lastSection = "Build"
	end
	if md.availableOnly == nil then
		md.availableOnly = false
	end
	return md
end

HT_BuildPrefs.save = function()
	ModData.transmit("HT_BuildCatalogPrefs")
end

HT_BuildPrefs.isFavorite = function(recipeId)
	local fav = HT_BuildPrefs.get().favorites
	return fav[recipeId] == true
end

HT_BuildPrefs.toggleFavorite = function(recipeId)
	local md = HT_BuildPrefs.get()
	if md.favorites[recipeId] then
		md.favorites[recipeId] = nil
	else
		md.favorites[recipeId] = true
	end
	HT_BuildPrefs.save()
	return md.favorites[recipeId] == true
end

HT_BuildPrefs.setLastCategory = function(cat)
	local md = HT_BuildPrefs.get()
	md.lastCategory = cat or ""
	HT_BuildPrefs.save()
end

HT_BuildPrefs.setLastSection = function(section)
	local md = HT_BuildPrefs.get()
	md.lastSection = section
	HT_BuildPrefs.save()
end

HT_BuildPrefs.setAvailableOnly = function(v)
	local md = HT_BuildPrefs.get()
	md.availableOnly = v and true or false
	HT_BuildPrefs.save()
end
