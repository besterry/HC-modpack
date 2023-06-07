Silencer = {}
Silencer = {}
Silencer.version = "1.0";
Silencer.author = "Nolan";
Silencer.modName = "Silencer";

if(ItemValueTable == nil) then ItemValueTable = {}; end
ItemValueTable["Silencer.Silencer"] = 6.00;
ItemValueTable["Silencer.HMSilencer"] = 4.00;

function Silencer.onAttack(owner,weapon)

	if Silencer:useSilencer( owner:getPrimaryHandItem() ) == false 
	 then
		if Silencer:isWeaponSilenced() then 
			Silencer:restoreWeapon();
			return;
		end
		return;
	end
	
	
	local reduce = 0.1; -- to 10% 
	
	if owner:getPrimaryHandItem():getCanon():getType() == "HMSilencer" then
		reduce = 0.3;
	end
	
	
	local volumeMod = Silencer.weapon:getModData().soundVolume * reduce
	local radiusMod = Silencer.weapon:getModData().soundRadius * reduce
	
	-- Make sure our volume and sound radius does not get bigger than the firearms initial volume.
	if volumeMod > 1 then volumeMod = 1; end
	if radiusMod > 1 then radiusMod = 1; end

	-- Set new parameters
	Silencer.weapon:setSoundVolume( volumeMod );
	Silencer.weapon:setSoundRadius( radiusMod );
	
	Silencer.weapon:setSwingSound('silenced_shot');
		
end

function Silencer:useSilencer(weap)
	
	if weap ~= nil then
		if weap:getCanon() ~= nil then
		
			if weap:getCanon():getType() == "Silencer" 
			or weap:getCanon():getType() == "HMSilencer" then
			
				self.weapon = weap;
		
				if (self.weapon:getModData().soundVolume == nil) then
					self.weapon:getModData().soundVolume = self.weapon:getSoundVolume();
					self.weapon:getModData().soundRadius = self.weapon:getSoundRadius();
					self.weapon:getModData().swingSound  = self.weapon:getSwingSound();		
				end
			
				return true
			end
		end
	end
	
	
	return false
end

function Silencer:isWeaponSilenced()
	if self.weapon ~= nil then
		if self.weapon:getModData().soundVolume ~= nil then
			return true
		end
	end
	return false
end

function Silencer:restoreWeapon()
	self.weapon:setSoundVolume( self.weapon:getModData().soundVolume );
	self.weapon:setSoundRadius( self.weapon:getModData().soundRadius );
	self.weapon:setSwingSound( self.weapon:getModData().swingSound );
end

function SilencerOnGameStart()

	local phi = getSpecificPlayer(0):getPrimaryHandItem()
	getSpecificPlayer(0):setPrimaryHandItem(nil)
	getSpecificPlayer(0):setPrimaryHandItem(phi)

end

Events.OnGameStart.Add(SilencerOnGameStart);

Events.OnWeaponSwing.Add(Silencer.onAttack);

