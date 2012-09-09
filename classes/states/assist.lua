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
	self.InteractTime = getTime();	-- last time we loot/interact
	self.tabtime = getTime();		-- last time nexttarget
end

function AssistState:update()

-- attack or face middle/get target
	if  player.TargetMob ~= 0	and
		distance(player.X, player.Z, target.TargetX, target.TargetZ) < profile['fightdistance'] then	
--		stateman:pushEvent("Combat","mobwait");		-- not working proper atm
		player:useSkills()
	elseif ( deltaTime(getTime(), self.tabtime ) > 500 ) then	-- only ever 0.5 second
			player:getNextTarget();
			self.tabtime = getTime();
	end

-- Loot/Harvest if Interaction available
	if player.Interaction == true and 
	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
			logger:log('info',"Interaction available: doing loot/harvest");
			keyboardPress(keySettings['interact']);		-- loot
			self.InteractTime = getTime();
	end			

end

function AssistState:handleEvent(event)

end


table.insert(events,{name = "Assist", func = AssistState()})