--[[
	Child of State class.
]]

include("../state.lua");

CombatState = class(State);

function CombatState:constructor()
	self.name = "Combat";
	self.autostarted = nil
	self.combat = false
	--self.startfight = os.time() -- DEPRECATED
	self.startfighttime = getTime();
	self.lastTargetTime = getTime();
	self.needLoot = false;
end

function CombatState:update()
	logger:log('debug-states',"Coming to CombatState:update()");
	
-- TODO: need to handle first attack somehow special
-- if we attack a new target, sometimes incombat flag is not fast enough and the
-- bot select a new target. So we get aggro from two mob
-- Solution: firstattack state with special wait time?

-- FIX: wait for aggro
if not player.InCombat then
	yrest(1000)	-- wait for aggro after firstattack
end

	targetupdate();
	statusupdate();

	if not player.InCombat	then
--		statusupdate();
		if profile['loot'] == true and deltaTime(getTime(), self.startfighttime) > 1000 and
		   self.needLoot == true  then	-- only push loot event after using skills
			stateman:pushEvent("Loot", "finished combat"); 
			self.needLoot = false
		end
		stateman:popState("combat ended");	
	end

	if player.TargetMob ~= 0 then
		player:useSkills()
		self.needLoot = true
	else
		-- So we don't target TOO fast.
		if( deltaTime(getTime(), self.lastTargetTime) > 500 ) then
			keyboardPress(keySettings['nexttarget']);
			self.lastTargetTime = getTime();
		end
	end
end

-- Handle events
function CombatState:handleEvent(event)
	if event == "Heal"  then
		player:useSkills(_heal)
		return true;
	end
end
table.insert(events,{name = "Combat", func = CombatState()})