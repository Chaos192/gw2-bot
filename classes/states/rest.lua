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
		logger:log('info',"We are down so popping rest state.")
		stateman:popState("Rest");
		return
	end

	if player.Dead then
		logger:log('info',"We are dead so popping rest state.")
		return
	end

-- we ge in combat, stopping rest state
	if player.InCombat then
		logger:log('info',"Get in combat so popping rest state.")
		stateman:popState("Rest");
		return
	end		

end

-- Handle events
function RestState:handleEvent(event)

end


table.insert(events,{name = "Rest", func = RestState})