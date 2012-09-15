--[[
	Child of State class.
]]

include("../state.lua");

BridgeState = class(State);

function BridgeState:constructor()
	self.name = "Bridge";
	self.destX = -26943;
	self.destZ = 10246;
--	profile['skill2use'] = true
--	profile['skill5use'] = true
	self.tabtime = 0
	self.karma = player.Karma
end

function BridgeState:update()
	--[[if player.Karma > self.karma or handleInput(VK_F7) == true then -- event over
		waypoint.closest = false
		waypoint.waypointname = "bridgewalk"
		stateman:pushState(WaypointState())
	end]]
	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed
	if player.HP > 10 then
		if player:moveTo_step(self.destX, self.destZ, 400, true) then
			if player.TargetMob == 0 then
				player:facedirection(self.destX, self.destZ, 0.5, true)
				if os.difftime(os.time(),self.tabtime) > 1 then
					keyboardPress(keySettings['nexttarget'])
					self.tabtime = os.time()
				end
			elseif profile['fightdistance'] > distance(player.X, player.Z, target.TargetX, target.TargetZ)  then
				player:useSkills()
				if player.Interaction then
					keyboardPress(keySettings['interact'])
					print("using F key")
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
table.insert(events,{name = "Bridge", func = BridgeState()})