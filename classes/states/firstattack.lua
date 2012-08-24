--[[
	Child of State class.
]]

include("../state.lua");

FirstattackState = class(State);

function FirstattackState:constructor()
	self.name = "Firstattack";
	self.starttime = os.time()
end

function FirstattackState:update()
	Player:update()
	if playertarget ~= 0 then
		keyboardPress(key.VK_1)
		yrest(1000)
	else
		stateman:popState("first attack popped") return -- returned from combat and loot
	end
	Player:update()
	if os.difftime(os.time(),self.starttime) > 5 then stateman:popState("first attack no damage") keyboardPress(key.VK_ESCAPE) end
end
table.insert(events,{ func = FirstattackState(), name = "Firstattack"})