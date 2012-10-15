--[[
	Child of State class.
]]

include("../state.lua");

RestState = class(State);

function RestState:constructor()
	self.name = "Rest";
end

function RestState:update()
	logger:log('debug-states',"Coming to RestState:update()");

	statusupdate()		-- update combat flag

-- rest until HP is full
	if player.HP == player.MaxHP then
		logger:log('info',"Rested up to full HP so popping Rest state.")
		stateman:popState("Rest");
		return
	end

	if player.Downed then
		logger:log('info',"We are down so popping Rest state.")
		stateman:popState("Rest");
		return
	end

	if player.HP == 0 then
		logger:log('info',"We are dead so popping Rest state.")
		stateman:popState("Rest");
		return
	end


-- defend if inCombat but don't target new ones
	if player.InCombat then
		local combat = CombatState()
		combat.getNewTarget = false			-- don't get new targets in combat state, just defend
		logger:log('info',"Get in combat during resting. We push combat state..")
		stateman:pushState(CombatState(combat));
	end		

end

-- Handle events
function RestState:handleEvent(event)

end


table.insert(events,{name = "Rest", func = RestState()})