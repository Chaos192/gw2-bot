--[[
	Child of State class.
]]

include("../state.lua");

IdleState = class(State);

function IdleState:constructor()
	self.name = "Idle";
	self.index = 1;
end

function IdleState:update()

end