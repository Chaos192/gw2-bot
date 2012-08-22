--[[
	Child of State class.
]]

include("../state.lua");

LootState = class(State);

function LootState:constructor()
	self.name = "Loot";
	self.lasttime = os.time(); -- We're going to just fake loot with time.
	self.prevtime = 0
	self.first = nil
	self.timepassed = 0
	cprintf(cli.green,"loot constructor\n")
end

function LootState:update()
	self.timepassed = os.difftime(os.time(), self.lasttime)
	if self.prevtime ~= self.timepassed then print("loot timer: "..self.timepassed) self.prevtime = self.prevtime + 1 end
	if self.prevtime > 1  then
		-- End Loot.
		updatehp()
		if playertarget ~= 0 then
			keyboardPress(key.VK_ESCAPE)
			yrest(1000)
		end
		print("finished looting, popping") 
		self.first = true
		stateman:popState("loot");			
	end
end
table.insert(events,{name = "Loot", func = LootState()})