--[[
	Child of State class.
]]

include("../state.lua");

IdleState = class(State);

function IdleState:constructor()
	self.name = "Idle";
end

function IdleState:update()

end