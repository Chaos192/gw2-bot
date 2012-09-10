--[[
	Child of State class.
]]

include("../state.lua");

CombatState = class(State);

function CombatState:constructor()
	self.name = "Combat";
	self.autostarted = nil
	self.combat = false
	self.startfight = os.time()
	self.lastTargetTime = getTime();
end

function CombatState:update()
	if not player.InCombat	then 
		if profile['loot'] == true then
			stateman:pushEvent("Loot","finished combat"); 
		end
		stateman:popState("combat ended");	
	end

	if player.TargetMob ~= 0 then
		player:useSkills()
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