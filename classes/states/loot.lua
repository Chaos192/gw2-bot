--[[
	Child of State class.
]]

include("../state.lua");

LootState = class(State);

function LootState:constructor()
	self.name = "Loot";
end

function LootState:update()
	logger:log('debug-states',"Coming to LootState:update()");
	if player.TargetMob ~= 0 then
		keyboardPress(key.VK_ESCAPE)
		yrest(1000)
	end

	if( player.Interaction ) then
--	    player.InteractionId == 0x1403F ) then		-- FIX not working ATM
		keyboardPress(keySettings['interact']);
	end

	logger:log('info',"finished looting, popping")
	stateman:popState("loot");
	statusupdate();
end
table.insert(events,{name = "Loot", func = LootState()})