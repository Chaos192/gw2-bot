--[[
	Child of State class.
]]

include("../state.lua");

CombatState = class(State);

function CombatState:constructor()
	self.name = "Combat";
--	self.autostarted = nil			-- DEPRECATED not used ???
	self.getNewTarget = true		-- automaticly look for new targets around if no target
	self.getNewTargetTimer = 500	-- only look for new target each x ms			
	self.waitForAggroTimer = 5000	-- how long we wait for getting aggro after attacking a new target
--	self.combat = false				-- DEPRECATED not used ???
	--self.startfight = os.time() 	-- DEPRECATED
	self.waitForTargetInCombatTime = false			-- rember how long we wait for a target if in combat
	self.waitForCombatWithTargetTime = false		-- rember how long we wait for combat flag until change/clear target
	self.startFightTime = getTime();	--- ???
	self.lastTargetTime = getTime();
	self.wasFighting = false;		-- remember if we have used skill
end

function CombatState:update()
	logger:log('debug-states',"Coming to CombatState:update()");
	
-- TODO: need to handle first attack somehow special
-- if we attack a new target, sometimes incombat flag is not fast enough and the
-- bot select a new target. So we get aggro from two mob
-- Solution: firstattack state with special wait time?

-- Situations:
-- have target	/	don't get in Combat flag	-->	needs to wait x sec until change/clear target (self.waitForCombatWithTargetTime)
-- no target	/	but are in Combat			-->	needs to wait x sec until leave state (self.waitForTargetInCombatTime)

-- TODO: 
-- inCombat but no taget if target behind or not visible, bot will leave combat state
-- => perhaps turning if loosing HP points to find the target behind the player ?

-- TODO: sometimes mobs are invulnerable and don'T lose HP but we are still incombat => need to check mob HP


	targetupdate();
	statusupdate();
	
--debug_value(player.InCombat,"player.InCombat")	
	if player.InCombat	then
		self.waitForCombatWithTargetTime = false		-- clear wait for combat flag
		if not self.waitForTargetInCombatTime then
			self.waitForTargetInCombatTime = getTime()	-- rember how long incombat without target
		end
	else										-- not in combat
		self.waitForTargetInCombatTime = false			-- clear wait for target in combat time

		-- loot at end of fight TODO: only loot close targets, loot state don't walk to mob atm
		if self.wasFighting == true and
		   self.waitForCombatWithTargetTime == false then	-- only loot if not waiting for aggro from the mob
			self.wasFighting = false
--			if profile['loot'] == true and deltaTime(getTime(), self.startFightTime) > 1000 then	-- ??? why wait ?
			if profile['loot'] == true  then	
				stateman:pushEvent("Loot", "finished combat");
			end
			stateman:popState("combat ended");
			return
		end

--		if self.waitForCombatWithTargetTime then
--debug_value(deltaTime(getTime(),self.waitForCombatWithTargetTime),"deltaTime(getTime(),self.waitForCombatWithTargetTime)")
--		end
		
		if self.waitForCombatWithTargetTime	and			-- we wait for the combat flag
		   deltaTime(getTime(),self.waitForCombatWithTargetTime)	> self.waitForAggroTimer then
			self.waitForCombatWithTargetTime = false
-- TODO: if getNewTarget = true then we should look for new target within combat state and block that target instead of leaving the state		
			if player.TargetMob ~= 0 then
				logger:log('info', "Don't get aggro from Target %s. Clear target.\n", player.TargetMob);
				if not player.blockedTargets[player.TargetMob] then player.blockedTargets[player.TargetMob] = { count=0 } end
				player.blockedTargets[player.TargetMob].time = os.time()
				player.blockedTargets[player.TargetMob].count = player.blockedTargets[player.TargetMob].count + 1
--debug_value(player.TargetMob,"player.TargetMob")
--debug_value(player.blockedTargets[player.TargetMob].count,"player.blockedTargets[player.TargetMob].count in cmobat")				
				keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
				targetupdate()
			end
			stateman:popState("end of combat state forced, we don't get combat flag");
			return
		end

	end

	if player.TargetMob ~= 0 then

		self.waitForTargetInCombatTime = false			-- reset timer in combat without target

		-- FIX/TODO: as long as clear target don't work properly in getNextTarget() we have to check blocked targets here again
		if player.blockedTargets[player.TargetMob] and
		   player.blockedTargets[player.TargetMob].count > 4 then
			keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
			stateman:popState("end of combat state forced, blocked target %s", player.TargetMob);
			return
		end

		player:useSkills()
		self.wasFighting = true							-- remember if we have used skills

		if not player.InCombat and						-- remember how long we wait for getting aggro from mob
		   not self.waitForCombatWithTargetTime then 	-- FIX/TODO: need that as long we don't see if we do damage to the mob
			self.waitForCombatWithTargetTime = getTime()
		end

		-- delete mob from blocked targets
		-- TODO: use targetHP and nod InCombat flag to decide if we do damage to the mob
		if player.InCombat and
		   player.blockedTargets[player.TargetMob] then
			player.blockedTargets[player.TargetMob] = nil
		end

	else												-- don't have a target

		self.waitForCombatWithTargetTime = false		-- no target, clear wait aggro timer
		
		-- no target since more then x seconda => we leave state
		if self.waitForTargetInCombatTime	and			-- if combat flag comes to late there is not time
		   deltaTime(getTime(),self.waitForTargetInCombatTime)	> 3000 then
			self.waitForTargetInCombatTime = false
			stateman:popState("end of combat state forced, no target");
			return		
		end

		-- try to get a target
		if self.getNewTarget == true and		-- automatic get new targets during in combat to clear area
		( deltaTime(getTime(), self.lastTargetTime) > self.getNewTargetTimer ) then
			logger:log('debug',"getNewTarget == true, try to get a new target in combat state");
			player:getNextTarget()
			self.lastTargetTime = getTime();
		elseif self.getNewTarget == false and	-- no targeting in combat but we have to defend
		   player.InCombat and
		( deltaTime(getTime(), self.lastTargetTime) > self.getNewTargetTimer ) then
			logger:log('debug',"still in combat, try to get the target in combat state");
			player:getNextTarget()
			self.lastTargetTime = getTime();
		end

		if player.TargetMob == 0 then	-- still no target
			stateman:popState("end of combat state, no more targets");
			return
		end

	end

end

-- Handle events
function CombatState:handleEvent(event)

-- not used anymore / heal is pushed in main.lua
--	if event == "Heal"  then
--		player:useSkills(_heal)
--		return true;
--	end

end
table.insert(events,{name = "Combat", func = CombatState()})