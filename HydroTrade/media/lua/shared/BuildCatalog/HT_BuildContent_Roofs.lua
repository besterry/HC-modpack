-- Roof style packs: full piece set.
-- solidfloor -> addFloor (ceiling / room seal)
-- other tiles -> IsoThumpable object (does not replace floor / punch holes)

HT_BuildContent_Roofs = HT_BuildContent_Roofs or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

local function spr(sheet, index)
	return sheet .. "_" .. tostring(index)
end

local function isSolidFloorName(spriteName)
	if not spriteName or not getSprite then
		return nil
	end
	local sp = getSprite(spriteName)
	if not sp then
		return nil
	end
	local props = sp:getProperties()
	if not props then
		return nil
	end
	if IsoFlagType and IsoFlagType.solidfloor and props:Is(IsoFlagType.solidfloor) then
		return true
	end
	if props:Is("solidfloor") == true then
		return true
	end
	return false
end

local function applySpriteCycle(obj, cycle)
	if not obj or not cycle or #cycle < 2 then
		return
	end
	obj._htCycle = cycle
	obj.nSprite = 1
	obj.sprite = cycle[1]
	obj.northSprite = cycle[2] or cycle[1]
	obj.eastSprite = cycle[3] or cycle[1]
	obj.southSprite = cycle[4] or cycle[2] or cycle[1]

	function obj:getSprite()
		local list = self._htCycle
		if not list then
			return ISBuildingObject.getSprite(self)
		end
		local max = #list
		local i = self.nSprite or 1
		if i < 1 then
			i = 1
		elseif i > max then
			i = ((i - 1) % max) + 1
		end
		self.nSprite = i
		local face = ((i - 1) % 4) + 1
		self.west = face == 1
		self.north = face == 2
		self.east = face == 3
		self.south = face == 4
		self.choosenSprite = list[i]
		return self.choosenSprite
	end

	function obj:rotateKey(key)
		if key == getCore():getKey("Rotate building") then
			local max = #self._htCycle
			self.nSprite = (self.nSprite or 1) + 1
			if self.nSprite > max then
				self.nSprite = 1
			end
		end
	end
end

local function buildCoverFloor(sprite, northSprite, eastSprite, southSprite, name, player, cycle)
	local floor = ISWoodenFloor:new(sprite, northSprite)
	floor.player = player
	floor.name = name
	if eastSprite then
		floor.eastSprite = eastSprite
	end
	if southSprite then
		floor.southSprite = southSprite
	end
	applySpriteCycle(floor, cycle)
	floor.create = function(self, x, y, z, north, sprName)
		self.sq = getWorld():getCell():getGridSquare(x, y, z)
		self.javaObject = self.sq:addFloor(sprName)
		buildUtil.consumeMaterial(self)
		self.sq:disableErosion()
		local args = { x = self.sq:getX(), y = self.sq:getY(), z = self.sq:getZ() }
		sendClientCommand("erosion", "disableForSquare", args)
	end
	getCell():setDrag(floor, player)
end

local function buildTrimObject(sprite, northSprite, eastSprite, southSprite, name, player, cycle)
	local furn = ISSimpleFurniture:new(name, sprite, northSprite)
	furn.player = player
	furn.canBeAlwaysPlaced = true
	furn.blockAllTheSquare = false
	furn.canPassThrough = true
	furn.renderFloorHelper = true
	furn.dismantable = true
	furn.buildLow = false
	furn.needToBeAgainstWall = false
	if eastSprite then
		furn.eastSprite = eastSprite
	end
	if southSprite then
		furn.southSprite = southSprite
	end
	applySpriteCycle(furn, cycle)
	furn.isValid = function(self, square)
		if not square then
			return false
		end
		if not self:haveMaterial(square) then
			return false
		end
		if square:isVehicleIntersecting() then
			return false
		end
		if buildUtil.stairIsBlockingPlacement and buildUtil.stairIsBlockingPlacement(square, true) then
			return false
		end
		return true
	end
	getCell():setDrag(furn, player)
end

local function dirSet(sheet, w, n, e, s)
	return {
		sprite = spr(sheet, w),
		north = spr(sheet, n),
		east = spr(sheet, e),
		south = spr(sheet, s),
	}
end

-- solidfloor -> addFloor (seals room). Else furniture object (visual trim).
-- Checked at place time: tile defs may be missing during recipe register.
local function placeRoof(s, n, e, so, name, player, cycle)
	local check = (cycle and cycle[1]) or s
	local asFloor = isSolidFloorName(check) == true
	local east, south = e, so
	if asFloor and not (isSolidFloorName(e) == true and isSolidFloorName(so) == true) then
		east, south = s, n
	end
	if asFloor then
		buildCoverFloor(s, n, east, south, name, player, cycle)
	else
		buildTrimObject(s, n, east, south, name, player, cycle)
	end
end

local function pushVariant(variants, roleKey, dir, name, cycle)
	if not dir then
		return
	end
	local s, n, e, so = dir.sprite, dir.north, dir.east, dir.south
	local solid = isSolidFloorName(s)
	local mode = nil
	if solid == true then
		mode = "cover"
	elseif solid == false then
		mode = "trim"
	end
	table.insert(variants, {
		roleKey = roleKey,
		sprite = s,
		roofMode = mode,
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 2 } },
		skills = { Woodwork = 2 },
		tools = { "Hammer" },
		create = function(player)
			placeRoof(s, n, e, so, name, player, cycle)
		end,
	})
end

local function makeVariants(sheet, base, name, opts)
	opts = opts or {}
	local variants = {}
	pushVariant(variants, "IGUI_HT_BuildCatalog_Role_RoofSlope",
		dirSet(sheet, base + 22, base + 23, base + 26, base + 27), name)
	pushVariant(variants, "IGUI_HT_BuildCatalog_Role_RoofSlope2",
		dirSet(sheet, base + 20, base + 21, base + 24, base + 25), name)
	pushVariant(variants, "IGUI_HT_BuildCatalog_Role_RoofEdge",
		dirSet(sheet, base + 0, base + 1, base + 4, base + 5), name)
	-- Corner + Corner2 (two seat heights): one role, R cycles 8 sprites.
	local cornerDir = dirSet(sheet, base + 8, base + 9, base + 12, base + 13)
	local cornerCycle = {
		spr(sheet, base + 8), spr(sheet, base + 9), spr(sheet, base + 12), spr(sheet, base + 13),
		spr(sheet, base + 10), spr(sheet, base + 11), spr(sheet, base + 14), spr(sheet, base + 15),
	}
	pushVariant(variants, "IGUI_HT_BuildCatalog_Role_RoofCorner", cornerDir, name, cornerCycle)
	if not opts.skipFlat then
		local flatA = opts.flatA or (base + 80)
		local flatB = opts.flatB or (base + 81)
		pushVariant(variants, "IGUI_HT_BuildCatalog_Role_RoofFlat",
			dirSet(sheet, flatA, flatB, flatA, flatB), name)
	end
	return variants
end

HT_BuildContent_Roofs.register = function()
	local styles = {
		{
			id = "ht_roof_02_dark",
			nameKey = "IGUI_HT_BuildCatalog_Roof_Dark02",
			sheet = "roofs_02", base = 0, material = "shingle",
			paint = "Base.PaintBlack", sort = 0,
			variantOpts = { skipFlat = true },
		},
		{
			id = "ht_roof_glass",
			nameKey = "ContextMenu_Glass_roof",
			sheet = "roofs_02", base = 32, material = "glass",
			paint = nil, sort = 1,
			section = "Metal",
			greenhouse = true,
			noteKey = "IGUI_HT_BuildCatalog_Note_GlassRoof",
			-- Glass block has no separate flat: base+22 is roofs_02_54/55 (same as old flatA/B).
			variantOpts = { skipFlat = true },
		},
		{
			id = "ht_roof_black_shingle",
			nameKey = "ContextMenu_BlackShingle_Roofing",
			sheet = "roofs_01", base = 0, material = "shingle",
			paint = "Base.PaintBlack", sort = 2,
		},
		{
			id = "ht_roof_brown_wood",
			nameKey = "ContextMenu_BrownWood_Roofing",
			sheet = "roofs_01", base = 32, material = "wood",
			paint = nil, sort = 3,
		},
		{
			id = "ht_roof_lbrown_wood",
			nameKey = "ContextMenu_LightBrown_WoodRoofing",
			sheet = "roofs_03", base = 0, material = "shingle",
			paint = "Base.PaintLightBrown", sort = 4,
		},
		{
			id = "ht_roof_green_wood",
			nameKey = "IGUI_HT_BuildCatalog_Roof_GreenSmooth",
			sheet = "roofs_03", base = 32, material = "shingle",
			paint = "Base.PaintGreen", sort = 5,
		},
		{
			id = "ht_roof_green_shingle",
			nameKey = "IGUI_HT_BuildCatalog_Roof_GreenShingle",
			sheet = "roofs_05", base = 0, material = "shingle",
			paint = "Base.PaintGreen", sort = 6,
		},
		{
			id = "ht_roof_red_wood",
			nameKey = "ContextMenu_RedWood_Roofing",
			sheet = "roofs_04", base = 0, material = "shingle",
			paint = "Base.PaintRed", sort = 7,
		},
		{
			id = "ht_roof_white",
			nameKey = "ContextMenu_White_Roofing",
			sheet = "roofs_04", base = 32, material = "shingle",
			paint = "Base.PaintWhite", sort = 8,
		},
		{
			id = "ht_roof_burnt",
			nameKey = "ContextMenu_Burnt_Roofing",
			sheet = "roofs_burnt_01", base = 0, material = "burnt",
			paint = nil, sort = 9,
		},
	}

	for _, st in ipairs(styles) do
		local name = getText(st.nameKey)
		local variants = makeVariants(st.sheet, st.base, name, st.variantOpts)
		add({
			id = st.id,
			section = st.section or "Build",
			group = "Roofs",
			kind = "style",
			sort = st.sort,
			nameKey = st.nameKey,
			sprite = variants[1].sprite,
			material = st.material,
			paint = st.paint,
			greenhouse = st.greenhouse == true,
			noteKey = st.noteKey or "IGUI_HT_BuildCatalog_Note_RoofPack",
			variants = variants,
		})
	end
end
