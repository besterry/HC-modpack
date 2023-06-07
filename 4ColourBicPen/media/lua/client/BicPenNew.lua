return function()
	require 'ISUI/Maps/ISMap'
	require 'ISUI/Maps/ISTextBoxMap'
	require 'ISUI/Maps/ISWorldMapSymbols'

	local function makeNewIndex(inst, oldMt)
		return function(t, k, v)
			if k == 'colorButtonInfo' then
				table.insert(v, { item='GreenPen', colorInfo=ColorInfo.new(0, 1, 0, 1), tooltip=getText('ToolTip_Map_NeedBicPen') })
			end
			if oldMt then
				oldMt(t, k, v)
			else
				rawset(t, k, v)
			end
		end
	end

	local function wrapCreate(tbl)
		local oldFunc = tbl.createChildren
		tbl.createChildren = function(self, ...)
			local mt = getmetatable(self) or {}
			mt.__newindex = makeNewIndex(self, mt.__newindex)
			setmetatable(self, mt)
			return oldFunc(self, ...)
		end
	end

	local function wrapErase(tbl)
		local oldFunc = tbl.canErase
		tbl.canErase = function(self, ...)
			return oldFunc(self, ...) or self.character:getInventory():containsTypeRecurse('Base.Pencil')
		end
	end

	for _,tbl in ipairs({ISTextBoxMap, ISWorldMapSymbols}) do
		wrapCreate(tbl)
		wrapErase(tbl)
	end

end
