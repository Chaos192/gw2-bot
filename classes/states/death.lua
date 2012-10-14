--[[
	Child of State class.
]]

include("../state.lua");

DeathState = class(State);

function DeathState:constructor()
	self.name = "Death";
	self.Deathskill2used	= 0
	self.Deathskill3used	= 0
	self.Deathskill4used	= 0
end

function DeathState:update()
	logger:log('debug-states',"Coming to DeathState:update()");

	statusupdate()		-- for Death flag

	if player.HP ~= 0 then
		logger:log('info',"We are alive or only down. Pop Death State")
		stateman:popState("Death");
		return
	end




end

-- Handle events
function DeathState:handleEvent(event)

end


table.insert(events,{name = "Death", func = DeathState()})