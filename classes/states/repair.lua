--[[
	Child of State class.
]]

include("../state.lua");

RepairState = class(State);

function RepairState:constructor()
	self.name = "Repair";
	self.lasttime = os.time(); -- We're going to just fake repair with time.
	self.prevtime = 0
	self.first = nil
end

function RepairState:update()
	if self.first ~= nil then 
		logger:log('info',"back at repair") 
		self:constructor() -- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then logger:log('info',"repair timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End repairing.
		logger:log('info',"Finished repairing.\n");
		stateman:popState();
		self.first = true
	end
end
table.insert(events,{name = "Repair", func = RepairState()})