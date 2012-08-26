--[[
	Child of State class.
]]

include("../state.lua");

WaypointState = class(State);

function WaypointState:constructor()
	self.name = "Waypoint";
	self.index = 1;
	self.waypoints = {1, 2, 3, 4, 5, 6, 7, 8};

	self.lasttime = os.time(); -- We're going to just fake actually moving with time.
end

function WaypointState:update()
	if( os.difftime(os.time(), self.lasttime) > 1 ) then
		self:advance();
		self.lasttime = os.time();
	end
end

-- Advance the waypoint index to the next point.
function WaypointState:advance()
	self.index = self.index + 1;
	if( self.index > #self.waypoints ) then self.index = 1; end

	Logger:log('info',"Waypoints advanced to #%d\n", self.index);
end

table.insert(events,{name = "Waypoint", func = WaypointState()})