-- Admin placement UI for permanent street lights.

AdminPermanentLight = AdminPermanentLight or {}

AdminPermanentLight.variants = {
	{
		nameKey = "ContextMenu_HT_PermanentLight_Pole1",
		sprite = "lighting_outdoor_01_0",
		radius = 12,
		offsetX = 5,
		offsetY = 5,
	},
	{
		nameKey = "ContextMenu_HT_PermanentLight_Pole2",
		sprite = "lighting_outdoor_01_1",
		radius = 12,
		offsetX = 5,
		offsetY = 5,
	},
	{
		nameKey = "ContextMenu_HT_PermanentLight_Pole3",
		sprite = "lighting_outdoor_01_2",
		radius = 12,
		offsetX = 5,
		offsetY = 5,
	},
	{
		nameKey = "ContextMenu_HT_PermanentLight_Emergency",
		sprite = "lighting_outdoor_01_49",
		northSprite = "lighting_outdoor_01_48",
		southSprite = "lighting_outdoor_01_50",
		eastSprite = "lighting_outdoor_01_51",
		radius = 20,
		offsetX = 0,
		offsetY = 0,
	},
}

function AdminPermanentLight.onBuild(playerObj, data)
	if not playerObj or not data then return end
	local playerNum = playerObj:getPlayerNum()
	local north = data.northSprite or data.sprite
	local light = ISPermanentLight:new(data.sprite, north, playerObj)
	light.radius = data.radius or 12
	light.offsetX = data.offsetX or 5
	light.offsetY = data.offsetY or 5
	light.player = playerNum
	if data.eastSprite then
		light:setEastSprite(data.eastSprite)
	end
	if data.southSprite then
		light:setSouthSprite(data.southSprite)
	end
	getCell():setDrag(light, playerNum)
end

function AdminPermanentLight.addToSubMenu(subMenu, playerObj)
	if not subMenu or not playerObj then return end
	local lightOption = subMenu:addOption(getText("ContextMenu_HT_PermanentLights"), nil, nil)
	local lightSub = ISContextMenu:getNew(subMenu)
	subMenu:addSubMenu(lightOption, lightSub)
	for _, data in ipairs(AdminPermanentLight.variants) do
		lightSub:addOption(getText(data.nameKey), playerObj, AdminPermanentLight.onBuild, data)
	end
end
