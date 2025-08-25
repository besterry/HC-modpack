local modId = "ReadFasterWhenSitting"
local rate = 0.6


-- TimedActions\ISReadABook.lua
local originalISReadABookIsValid = ISReadABook.isValid
local originalISReadABookNew = ISReadABook.new
local originalISReadABookStop = ISReadABook.stop


function ISReadABook:isValid(...)
	return (originalISReadABookIsValid(self, ...) == true
		and (self.maxTime == 1
		 or  (self[modId] and self.character:isSitOnGround() == self[modId]["initialCharacterIsSitOnGround"])))
end

function ISReadABook:stop(...)
	local result = originalISReadABookStop(self, ...)

	if self.maxTime ~= 1 and self[modId] then
		local characterIsSitOnGround = self.character:isSitOnGround()
		if		characterIsSitOnGround ~= self[modId]["initialCharacterIsSitOnGround"]
			and characterIsSitOnGround then
			ISTimedActionQueue.add(ISReadABook:new(self.character, self.item, self.initialTime))
		end
	end

	return result
end

function ISReadABook:new(character, item, time, ...)
	local instance = originalISReadABookNew(self, character, item, time, ...)


	if instance.maxTime ~= 1 then
		local initialCharacterIsSitOnGround = character:isSitOnGround()
		instance[modId] = {
				["initialCharacterIsSitOnGround"] = initialCharacterIsSitOnGround
			}
		if initialCharacterIsSitOnGround then
			instance.maxTime = math.floor(instance.maxTime * rate)
		end
	end


	return instance
end
