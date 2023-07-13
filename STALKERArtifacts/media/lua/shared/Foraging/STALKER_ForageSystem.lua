require 'Foraging/forageSystem'

local mods = getActivatedMods();
for i=0, mods:size()-1, 1 do
	if mods:get(i) == "ToxicZones" or mods:get(i) == "ToxicZonesSTALKER" then

function forageSystem.isValidSquare(_square, _itemDef, _catDef)
	if (not _square) then return false; end;
	if _square:Is(IsoFlagType.solid) then return false; end;
	if _square:Is(IsoFlagType.solidtrans) then return false; end;
	if (not _square:isNotBlocked(false)) then return false; end;
	if _itemDef.forceOutside and (not _square:Is(IsoFlagType.exterior)) then return false; end;
	if _itemDef.forceOnWater and not (_square:Is(IsoFlagType.water)) then return false; end;
	if _square:HasTree() and (not _itemDef.canBeOnTreeSquare) then return false; end;
	if _catDef.name == "Artifacts" and isToxicSquare(_square) == false then return false end;
	if _catDef.validFunc then
		_catDef.validFunc(_square, _itemDef, _catDef);
	else
		return forageSystem.isValidFloor(_square, _itemDef, _catDef);
	end;
	return false;
end

	end
end