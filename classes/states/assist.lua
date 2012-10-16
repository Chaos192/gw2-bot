--[[
	Child of State class.
]]

-- easy fight support mode without running and turning
-- will targeting mobs, fight and try to loot/harvest if interaction available
-- can be used while standing or running around

include("../state.lua");

AssistState = class(State);

function AssistState:constructor()
	self.name = "Assist";
	self.interactionX = 0;		-- remember interaction place to avoid being sticked
	self.interactionZ = 0;
	self.interactionCount = 0;
	self.InteractTime = getTime();	-- last time we do an F-Interaction
	self.tabtime = getTime();		-- last time nexttarget
end

function AssistState:update()
	logger:log('debug-states',"Coming to AssistState:update()");

	statusupdate()		-- update Interaction
	targetupdate()		-- to get target cleared

-- attack or face middle/get target
	if  player.TargetMob ~= 0	and
		distance(player.X, player.Z, target.TargetX, target.TargetZ) < profile['maxdistance'] then	
		local newCombat = CombatState()
		logger:log('info',"get new target in assist state, we push combat state");
		newCombat.getNewTarget = false			-- don't get new targets in combat state, just defend
		stateman:pushState(newCombat);
--		stateman:pushEvent("Combat","assist have a target");		
--		player:useSkills()
	elseif ( deltaTime(getTime(), self.tabtime ) > 500 ) then	-- only ever 0.5 second
			player:getNextTarget();
			self.tabtime = getTime();
	end

--debug_value(player.Interaction, "player.Interaction")
--debug_value(player.InteractionId, "player.InteractionId")
--	if player.Interaction == true and 
--	   player.InteractionId == 0x1403F and -- Make sure it is actually loot
--	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
--			stateman:pushState(LootState(), "Walked over lootable.");		-- loot
--			logger:log('info',"Interaction at (%d, %d)\n", player.X, player.Z);
--	end			


-- Loot/Harvest if Interaction available
--debug_value(player.Ftext, "player.Ftext")
--debug_value(language:message('InteractTalk'), "language:message('InteractTalk')")
-- if F-Interaction loot every x milliseconds / TODO: use Interaction tye to avoid greeting
	if player.Interaction == true and 
	   player.Ftext ~= language:message('InteractGreeting') and
	   player.Ftext ~= language:message('InteractTalk')  and		-- not if only greeting
	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
		if( self.interactionX == player.X) and	-- count interactions at the same spot
		  ( self.interactionZ == player.Z) then
			self.interactionCount = self.interactionCount + 1;
		else
			self.interactionCount = 0;		-- interaction at new place, clear counter
		end

		if( self.interactionCount < 2 ) then		-- only 3 times at the same place
			self.interactionX = player.X;
			self.interactionZ = player.Z;
--			keyboardPress(keySettings['interact']);		-- loot
			stateman:pushState(LootState(), "Walked over lootable.");		-- loot
			logger:log('info',"Interaction at (%d, %d)\n", player.X, player.Z);
			self.InteractTime = getTime();
		else
			logger:log('info',"no more interaction at that place (%d, %d)\n", player.X, player.Z);
		end
	end			


end

function AssistState:handleEvent(event)

end


table.insert(events,{name = "Assist", func = AssistState})