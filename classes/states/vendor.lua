--[[
	Child of State class.
]]

include("../state.lua");

VendorState = class(State);

function VendorState:constructor()
	self.name = "Vendor";
	self.lasttime = os.time(); -- We're going to just fake Vendor with time.
	self.prevtime = 0
	self.first = nil
end

function VendorState:update()
	if self.first ~= nil then 
		Logger:log('info',"back at Vendoring") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then Logger:log('info',"Vendor timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Vendor.
		self.first = true
		stateman:popState();			
	end
end
table.insert(events,{name = "Vendor", func = VendorState()})