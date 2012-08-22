--[[
	Child of State class.
]]

include("../state.lua");

HealState = class(State);

function HealState:constructor()
	self.name = "Heal";
	self.first = nil
end

function HealState:update()
	if self.first ~= nil then 
		print("back at Healing") 
		self:constructor()	-- easy reset
	end
	updatehp()
	if 98 > playerhp/playermaxhp*100 then
		keyboardPress(key.VK_6)
		yrest(2000)
	else
		print("healed up so popping heal state.")
		stateman:popState("heal");
	end
end

-- Handle events
function HealState:handleEvent(event)
	if event == "Combat"  then
		printf("Ignoring combat event, healing.\n");
		return true;
	end
end
table.insert(events,{name = "Heal", func = HealState()})