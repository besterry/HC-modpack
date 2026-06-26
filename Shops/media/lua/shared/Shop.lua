Shop = Shop or {}
Shop.Items = Shop.Items or {}
Shop.Tabs = Shop.Tabs or {}
Shop.TabsBuy = Shop.TabsBuy or {}
Shop.TabsBuyOrder = Shop.TabsBuyOrder or {}
Shop.Sell = Shop.Sell or {}
Shop.SellisBlacklist = false
Shop.SellisWhitelist = false
Shop.defaultPrice = 1
Shop.defaultPriceBroken = 1

Shop.spritePrefix = "npcshop_"
Shop.sprites = {
	FemaleA = {
		"npcshop_0",
		"npcshop_1",
	},
	FemaleB = {
		"npcshop_2",
		"npcshop_3",
	},
	MaleA = {
		"npcshop_4",
		"npcshop_5",
	},
	MaleB = {
		"npcshop_6",
		"npcshop_7",
	},
}

Shop.textures = {
	AddButton = {
		texture = getTexture("media/textures/ShopUI_Add.png"),
		scale = 20
	},
	RemoveButton= {
		texture = getTexture("media/textures/ShopUI_Remove.png"),
		scale = 20
	},
	PreviewButton= {
		texture = getTexture("media/textures/ShopUI_Preview.png"),
		scale = 20
	},
	Browse= {
		texture = getTexture("media/textures/ShopUI_Browse.png"),
		scale = 20
	},
	Cart= {
		texture = getTexture("media/textures/ShopUI_Cart.png"),
		scale = 30
	},
	Sort= {
		texture = getTexture("media/textures/ShopUI_Sort.png"),
	},
	MoveAll= {
		texture = getTexture("media/textures/ShopUI_MoveAll.png"),
	},
	Edit= {
		texture = getTexture("media/textures/ShopUI_Edit.png"),
	},
	Save= {
		texture = getTexture("media/textures/ShopUI_Save.png"),
	},
	Dell= {
		texture = getTexture("media/textures/ShopUI_Dell.png"),
	},
}

Tab = Tab or {}
Tab["Favorite"] = "Favorite"
Tab["Sell"] = "Sell"
Tab["All"] = "All"
Tab["Food"] = "Food"
Tab["FirstAid"]= "FirstAid"
Tab["Cloth"] = "Cloth"
Tab["Tools"] = "Tools"
Tab["Book"] = "Book"
Tab["Weapons"] = "Weapons"
Tab["Vehicles"] = "Vehicles"
Tab["Event"] = "Event"


Shop.Tabs[Tab.Favorite] = getText("IGUI_Tab_Favorite")
Shop.Tabs[Tab.Sell] = getText("IGUI_Tab_Sell")
Shop.Tabs[Tab.All] = getText("IGUI_Tab_All")
Shop.Tabs[Tab.Food] = getText("IGUI_Tab_Food")
Shop.Tabs[Tab.FirstAid] = getText("IGUI_Tab_FirstAid")
Shop.Tabs[Tab.Cloth] = getText("IGUI_Tab_Cloth")
Shop.Tabs[Tab.Tools] = getText("IGUI_Tab_Tools")
Shop.Tabs[Tab.Book] = getText("IGUI_Tab_Book")
Shop.Tabs[Tab.Weapons] = getText("IGUI_Tab_Weapons")
Shop.Tabs[Tab.Vehicles] = getText("IGUI_Tab_Vehicles")
Shop.Tabs[Tab.Event] = getText("IGUI_Tab_Event")

Shop.TabsBuyOrder = {
	Tab.All,
	Tab.Food,
	Tab.FirstAid,
	Tab.Cloth,
	Tab.Tools,
	Tab.Book,
	Tab.Weapons,
	Tab.Vehicles,
	Tab.Event,
}

Shop.TabsBuy = {
	[Tab.All] = Shop.Tabs[Tab.All],
	[Tab.Food] = Shop.Tabs[Tab.Food],
	[Tab.FirstAid] = Shop.Tabs[Tab.FirstAid],
	[Tab.Cloth] = Shop.Tabs[Tab.Cloth],
	[Tab.Tools] = Shop.Tabs[Tab.Tools],
	[Tab.Book] = Shop.Tabs[Tab.Book],
	[Tab.Weapons] = Shop.Tabs[Tab.Weapons],
	[Tab.Vehicles] = Shop.Tabs[Tab.Vehicles],
	[Tab.Event] = Shop.Tabs[Tab.Event],
}

function Shop.hasSellCatalog()
	if not Shop.Sell then return false end
	for _ in pairs(Shop.Sell) do
		return true
	end
	return false
end
