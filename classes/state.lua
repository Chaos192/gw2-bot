--[[
	State base class. All other states should inherit from this.
]]


State = class();

function State:constructor()
	self.name = "State baseclass or undefined.";
end

function State:update()
	-- This is just a placeholder for children. Should be overridden.
end

function State:handleEvent(event)

end