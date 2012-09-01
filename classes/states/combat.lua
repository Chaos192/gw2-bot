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
end

function CombatState:update()
	Player:update()
	if not Player.InCombat	then 
		if profile['loot'] == true then
			stateman:pushEvent("Loot","finished combat"); 
		end
		stateman:popState("combat ended");	
	end
	if Player.TargetMob ~= 0 then
		player:useSkills()
	else
		stateman:popState("combat no target");
	end
end

-- Handle events
function CombatState:handleEvent(event)
	if event == "Heal"  then
		Logger:log('info',"in combat need heals")
		stateman:pushState(HealState())
		return true;
	end
end
table.insert(events,{name = "Combat", func = CombatState()})