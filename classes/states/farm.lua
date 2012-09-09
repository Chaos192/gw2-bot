--[[
	Child of State class.
]]

include("../state.lua");

FarmState = class(State);

function FarmState:constructor()
	self.name = "Farm";
	self.prevmob = 0
	self.skipmob = false
end

function FarmState:update()
	if self.prevmob == player.TargetMob then
		self.skipmob = true
	else
		self.skipmob = false
	end
	keyboardPress(keySettings['nexttarget'])
	update:targetupdate()
	self.prevmob = player.TargetMob
	if self.skipmob ~= true and player.TargetMob ~= 0 then
		stateman:pushEvent("Firstattack","farm have target");
	else
		for i = 1,10 do
			keyboardPress(keySettings['turnleft'])
		end
	end
end
table.insert(events,{name = "Farm" ,func = FarmState()})