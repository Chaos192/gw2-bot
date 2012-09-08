--[[
	Child of State class.
]]

include("../state.lua");

EventsState = class(State);

function EventsState:constructor()
	self.name = "Event";
	self.lasttime = os.time(); -- We're going to just fake Event with time.
	self.prevtime = 0
	self.first = nil
end

function EventsState:update()
	if self.first ~= nil then 
		logger:log('info',"back at Eventing") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then logger:log('info',"Event timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Event.
		self.first = true
		stateman:popState();			
	end
end
table.insert(events,{name = "Events", func = EventsState()})