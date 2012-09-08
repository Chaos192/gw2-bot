--[[
	Child of State class.
]]

include("../state.lua");

LootState = class(State);

function LootState:constructor()
	self.name = "Loot";
end

function LootState:update()
		if player.TargetMob ~= 0 then
			keyboardPress(key.VK_ESCAPE)
			yrest(1000)
		end
		logger:log('info',"finished looting, popping")
		stateman:popState("loot");
end
table.insert(events,{name = "Loot", func = LootState()})