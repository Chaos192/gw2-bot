--[[
	Child of State class.
]]

include("../state.lua");

FirstattackState = class(State);

function FirstattackState:constructor()
	self.name = "Firstattack";
	self.starttime = 0
end

function FirstattackState:update()
	logger:log('debug-states',"Coming to FirstattackState:update()");
	targetupdate()
	coordsupdate()
	if player.TargetMob ~= 0 then
		if profile['maxdistance'] > distance(player.X, player.Z, target.TargetX, target.TargetZ) then
			if player:moveTo_step(target.TargetX, target.TargetZ, profile['fightdistance']) then
				self.starttime = os.time()
				keyboardPress(key.VK_1)
				yrest(1000)
			end	
		else
			stateman:popState("Target to far away") keyboardPress(key.VK_ESCAPE)
		end
	else
		stateman:popState("first attack popped") return -- returned from combat or loot
	end
	if os.difftime(os.time(),self.starttime) > 5 then stateman:popState("first attack no damage") keyboardPress(key.VK_ESCAPE) end
end
table.insert(events,{ name = "Firstattack", func = FirstattackState() })