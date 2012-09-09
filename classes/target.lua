--[[
	State base class. All other states should inherit from this.
]]

Target = class();

function Target:constructor()
	self.TargetX = 0
	self.TargetZ = 0
	self.TargetY = 0
end
