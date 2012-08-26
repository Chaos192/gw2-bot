--[[
	Child of State class.
]]

include("../state.lua");

HealState = class(State);

function HealState:constructor()
	self.name = "Heal";
	self.timeused = 0
	self.cooldown = 25
	self.healCD = Player.HealCD
end

function HealState:update()
	Player:update()
	if Player.Heal > Player.HP/Player.MaxHP*100 then
		keyboardPress(key.VK_6)
		yrest(2000)
	else
		Logger:log('info',"healed up so popping heal state.")
		stateman:popState("heal");
	end
end

-- Handle events
function HealState:handleEvent(event)
	if event == "Combat"  then
		Logger:log('info',"Ignoring combat event, healing.\n");
		return true;
	end
end
table.insert(events,{name = "Heal", func = HealState()})