require "ISUI/Maps/ISWorldMap"

function WorldMapOptions:getVisibleOptions()
	local result = {}
	--self.gps = itemGPSmod.gps
	if self.showAllOptions then
		for i=1,self.map.mapAPI:getOptionCount() do
			local option = self.map.mapAPI:getOptionByIndex(i-1)
			if isClient() or not self:isMultiplayerOption(option:getName()) then
				table.insert(result, option)
			end
		end
		return result;
	end
	local optionNames = {}
	--if self.gps then table.insert(optionNames, "Players") end
	if isClient() then
		table.insert(optionNames, "RemotePlayers")
		table.insert(optionNames, "PlayerNames")
	end
	table.insert(optionNames, "Symbols")
	for _,optionName in ipairs(optionNames) do
		for i=1,self.map.mapAPI:getOptionCount() do
			local option = self.map.mapAPI:getOptionByIndex(i-1) 
			if optionName == option:getName() then --(optionName == option:getName() and optionName ~= "Players") or (optionName == option:getName() and optionName == "Players" and itemGPSmod.gps) then 
				table.insert(result, option)
				break
			end
		end
	end
	return result
end