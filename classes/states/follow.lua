--[[
	Child of State class.
]]

include("../state.lua");

FollowState = class(State);

function FollowState:constructor()
	self.name = "Follow";
end

function FollowState:update()
	logger:log('debug-states',"FollowState:update()");
	local x,z,y = followcharname("charname") -- should do a profile option
	player:moveTo_step(x, z)
	targetnearestmob()
	targetupdate()
	if( player.TargetMob ) then
		targetupdate();
		if( distance(player.X, player.Z, target.TargetX, target.TargetZ) < profile['maxdistance'] ) then
			player:stopMoving();
			player:stopTurning();
			stateman:pushState(CombatState());
		end
	end
end

function FollowState:handleEvent(event)
	if( event == "entercombat" ) then
		player:stopMoving();
		player:stopTurning();
		stateman:pushState(CombatState());
	end
end

table.insert(events,{name = "Follow", func = FollowState})