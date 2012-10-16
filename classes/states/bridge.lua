--[[
	Child of State class.
]]

include("../state.lua");

BridgeState = class(State);

function BridgeState:constructor()
	self.name = "Bridge";
	self.destX = -26943;
	self.destZ = 10246;
	self.tabtime = 0
	self.karma = player.Karma
end

function BridgeState:update()
	targetupdate()
	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed
	if player.HP > 10 then
		if player:moveTo_step(self.destX, self.destZ, 400, true) then
			if player.TargetMob == 0 then
				player:facedirection(self.destX, self.destZ, 0.5, true)
				if os.difftime(os.time(),self.tabtime) > 1 then
					keyboardPress(keySettings['nexttarget'])
					self.tabtime = os.time()
				end
			else
				local tdist = distance(player.X, player.Z, target.TargetX, target.TargetZ)
				if profile['fightdistance'] > tdist  then
				printf("attacking mob with Address: %x, in Distance: %d.\n",player.TargetMob,tdist)
					player:useSkills()
					--[[if player.Interaction then
						keyboardPress(keySettings['interact'])
						print("using F key")
					end]]
				end
			end
		end
	else
		yrest(10000)
	end
	if os.difftime(os.time(),self.tabtime) > 1 then
		keyboardPress(keySettings['nexttarget'])
		self.tabtime = os.time()		
	end
end

function BridgeState:handleEvent(event)

end
table.insert(events,{name = "Bridge", func = BridgeState})