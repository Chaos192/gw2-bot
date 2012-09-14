--[[
	Manages different states. That's all. Nothing you haven't seen before.
]]
events = {}
include("state.lua");

StateManager = class();

function StateManager:constructor()
	self.stateQueue = {};
	self.eventQueue = {};
	self.running = true; -- Set to false to stop the bot
end

-- Runs the update function for the current state.
function StateManager:run()
	if( #self.stateQueue > 0 ) then
		self.stateQueue[#self.stateQueue]:update();
	end
end

-- Cycles through events and checks to see if anything meaningful happened.
function StateManager:handleEvents()
	for i,event in pairs(self.eventQueue) do
		local handled = false;
		-- See if the current state wants to handle this event
		if( #self.stateQueue > 0 ) then
			handled = self.stateQueue[#self.stateQueue]:handleEvent(event);
		end

		-- If the state didn't handle it, then maybe the manager will.
		if( not handled ) then
			handled = self:handleEvent(event);
		end
	end

	-- Flush our queue.
	self:flushEvents();
end

-- Handle a single event. If we use it, return true. Else, false.
function StateManager:handleEvent(event)
	if( event == "Quit" ) then
		self.running = false;
		return true;
	end

	for k,events in pairs(events) do
		if( event == events.name and self.stateQueue[#self.stateQueue].name ~= event ) then
			logger:log('info',"Switching to "..event);
			stateman:pushState(events.func);
			self.stateQueue[#self.stateQueue]:constructor();
			return true;
		end
	end  
end

-- Returns the current running state (if there is one)
-- Otherwise, returns nil.
function StateManager:getState()
	if( #self.stateQueue > 0 ) then

		return self.stateQueue[#self.stateQueue];

	else
		return nil;
	end
end

-- Push a new state onto the queue. This will be the
-- state that gets run *next cycle*, not immediately.
function StateManager:pushState(newState)
	if( type(newState) == nil ) then
		error("Function expects a parameter.", 2);
	end
	if( type(newState) ~= "table" or newState:is_a(State) == false ) then
		error("Parameter is not a state object.", 2);
	end

	table.insert(self.stateQueue, newState);
end

-- Pops the top state off the queue.
function StateManager:popState(from)
	from = from or "unknown"
	logger:log("info" ,"statemanager pop state from "..from.."\n") 
	if( #self.stateQueue > 0 ) then
		table.remove(self.stateQueue);
	end
end

-- Push a new event
function StateManager:pushEvent(event, from)
	from = from or ""
	logger:log("info" ,"statemanager push event "..event.." from "..from.."\n")
	table.insert(self.eventQueue, event);
end

-- Pop last event
function StateManager:popEvent(event)
	table.remove(self.eventQueue, #self.eventQueue);
end

-- Remove all events
function StateManager:flushEvents()
	self.eventQueue = {};
end