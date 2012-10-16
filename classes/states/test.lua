--[[
	Child of State class.
]]

include("../state.lua");

TestState = class(State);

function TestState:constructor()
	self.name = "Test";
	self.MoveFinished = false;		
end


function TestState:update()
	logger:log('debug',"Coming to TestState:update()");

	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed

		if (self.MoveFinished == true ) then
			logger:log('debug',"MoveFinished = true (nothing more to do => return to main");
--			error("Move finished")
			player:stopMoving();
			return
		end


		if not player:moveTo_step(-26618, 10294, 100 ) then
			logger:log('debug',"move not finished: distance %d", distance(player.X, player.Z, -26618, 10294) );
			self.MoveFinished = false;
		else
			logger:log('info',"*** move finished ***");
			self.MoveFinished = true;
		end

end


-- Handle events
function TestState:handleEvent(event)

end

table.insert(events,{name = "Test", func = TestState})