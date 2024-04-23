local oldFunc = ISFitnessUI.updateButtons
---@diagnostic disable-next-line: duplicate-set-field
function ISFitnessUI:updateButtons(currentAction)
	oldFunc(self, currentAction)
	if self.player:isPlayerMoving()  then -- or self.player:pressedMovement(false)
		self.ok.enable = false;
	end
end