--[[
	Child of State class.
]]

include("../state.lua");

QuestState = class(State);

function QuestState:constructor()
	self.name = "Quest";
	self.lasttime = os.time(); -- We're going to just fake Quest with time.
	self.prevtime = 0
	self.first = nil
end

function QuestState:update()
	if self.first ~= nil then 
		Logger:log('info',"back at Questing") 
		self:constructor()	-- easy reset
	end
	local timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= timepassed then Logger:log('info',"Quest timer: "..timepassed) self.prevtime = self.prevtime + 1 end
	if timepassed > 3  then
		-- End Quest.
		self.first = true
		stateman:popState();			
	end
end

table.insert(events,{name = "Quest", func = QuestState()})
