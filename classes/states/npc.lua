--[[
	Child of State class.
]]

include("../state.lua");

NpcState = class(State);

function NpcState:constructor()
	self.name = "Npc";
	self.lasttime = os.time(); -- We're going to just fake Npc with time.
	self.prevtime = 0
	self.first = nil
end

function NpcState:update()
	if self.first ~= nil then 
		logger:log('info',"back at Npcing") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then logger:log('info',"Npc timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Npc.
		self.first = true
		stateman:popState();			
	end
end
table.insert(events,{name = "Npc", func = NpcState()})