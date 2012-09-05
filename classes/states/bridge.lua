--[[
	Child of State class.
]]

include("../state.lua");

BridgeState = class(State);

function BridgeState:constructor()
	self.name = "Bridge";
	self.destX = -26943;
	self.destZ = 10246;
	profile['skill2use'] = true
	profile['skill5use'] = true
	self.tabtime = 0
end

function BridgeState:update()
	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed
	if player.HP > 10 then
		if player:moveTo_step(self.destX, self.destZ, 600) then
			if player.TargetMob == 0 then
				player:facedirection(self.destX, self.destZ, 0.5)
				if os.difftime(os.time(),self.tabtime) > 1 then
					keyboardPress(keySettings['nexttarget'])
					self.tabtime = os.time()
				end
			elseif profile['fightdistance'] > distance(player.X, player.Z, player.TargetX, player.TargetZ)  then
				player:useSkills()
			end
		end
	else
		yrest(10000)
	end
end

function BridgeState:handleEvent(event)

end
table.insert(events,{name = "Bridge", func = BridgeState()})