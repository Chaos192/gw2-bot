--[[
	Child of State class.
]]

include("../state.lua");

TravelState = class(State);

function TravelState:constructor()
	self.name = "Travel";
	self.lasttime = os.time(); -- We're going to just fake Travel with time.
	self.prevtime = 0
	self.first = nil
end

function TravelState:update()
	if self.first ~= nil then 
		logger:log('info',"back at Traveling") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then logger:log('info',"Travel timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Travel.
		self.first = true
		stateman:popState();			
	end
end
table.insert(events,{name = "Travel", func = TravelState})