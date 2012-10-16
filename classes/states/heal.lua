--[[
	Child of State class.
]]

include("../state.lua");

HealState = class(State);

function HealState:constructor()
	self.name = "Heal";
end

function HealState:update()
	logger:log('debug-states',"Coming to HealState:update()");
	if player.Heal > player.HP/player.MaxHP*100 then
		player:useSkills(true)
	else
		logger:log('info',"healed up so popping heal state.")
		stateman:popState("heal");
	end
end

-- Handle events
function HealState:handleEvent(event)
	if event == "Combat"  then
		logger:log('info',"Ignoring combat event, healing.\n");
		return true;
	end
end
table.insert(events,{name = "Heal", func = HealState})