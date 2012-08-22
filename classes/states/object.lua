--[[
	Child of State class.
]]

include("../state.lua");

ObjectState = class(State);

function ObjectState:constructor()
	self.name = "Object";
	self.lasttime = os.time(); -- We're going to just fake Object with time.
	self.prevtime = 0
	self.first = nil
end

function ObjectState:update()
	if self.first ~= nil then 
		print("back at Objecting") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then print("Object timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Object.
		self.first = true
		stateman:popState();			
	end
end
table.insert(events,{name = "Object", func = ObjectState()})