--[[
	Child of State class.
]]

include("../state.lua");

IdleState = class(State);

function IdleState:constructor()
	self.name = "Idle";
end

function IdleState:update()

--	if player.InCombat	then 	-- combat not working at the moment / also need to get a target if aggro
--		stateman:pushEvent("Combat","idle");
--	end

end

table.insert(events,{name = "Idle", func = IdleState()})