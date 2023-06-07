local CONFIG = require "NVAPI/CONFIG"


local ItemParam = {}

function ItemParam:new( nvitem )

	local o = {}
  setmetatable(o, self)
  self.__index  = self

  o._nvitem = nvitem

  return o

end

function ItemParam:getAvailableFilters()

	return CONFIG.PARAM_FILTER

end

function ItemParam:getAvailableBrightness()

	return {
    Min = 0.2,
    Med = 0.3,
    Max = 0.4
  }

end



function ItemParam:setBrightness( brightness )

	self._nvitem:getBoundItem():getModData().NVAPI_BRIGHTNESS = brightness

end


function ItemParam:getBrightness()

	return self._nvitem:getBoundItem():getModData().NVAPI_BRIGHTNESS or CONFIG.PARAM_OVERLAY_BRIGHTNESS

end


function ItemParam:setFilter( filter )

	self._nvitem:getBoundItem():getModData().NVAPI_FILTER = filter

end

function ItemParam:getFilterName()

	return self._nvitem:getBoundItem():getModData().NVAPI_FILTER or CONFIG.PARAM_FILTER[1][1]

end

function ItemParam:getFilterTexture()

	local filtername = self:getFilterName()

	for _, entry in ipairs( self:getAvailableFilters() ) do
		local name = entry[1]
		local tex  = entry[2]
		if filtername == name then
			return tex
		end
	end

	return nil

end

function ItemParam:getVisconeIntensity()

	return self._nvitem:getBoundItem():getModData().NVAPI_VISCONE_INTENSITY or CONFIG.PARAM_VISCONE_INTENSITY

end

function ItemParam:setVisconeIntensity( value )

	self._nvitem:getBoundItem():getModData().NVAPI_VISCONE_INTENSITY = value

end

function ItemParam:getVisconeRange()

	return self._nvitem:getBoundItem():getModData().NVAPI_VISCONE_RANGE or CONFIG.PARAM_VISCONE_RANGE

end

function ItemParam:setVisconeRange( value )

	self._nvitem:getBoundItem():getModData().NVAPI_VISCONE_RANGE = value

end



return ItemParam
