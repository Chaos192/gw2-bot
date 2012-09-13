--[[
	Child of State class.
]]
-- example state at Kessex Bridge LvL 12 - 40
--------------------------------------------------
-- functions:
-- randomly moving between points in the fight area
-- facing to the middle
-- looting during moving
-- loot run at the end of the event
--
-- tested with: Ranger, Elementalist

include("../state.lua");

Bridge2State = class(State);

function Bridge2State:constructor()
	self.name = "Bridge2";
-- Parameters
	self.OutOfCombatTimer = 30;	-- after x sec of of combat we don't move around anymore
	self.CombatWait = 10;			-- wait x seconds before entering event
	self.moveafter = 20;			-- time after that we change place
	self.moveafter_rnd = 20;		-- random add to the time after that we change place
	self.FaceWait = 10;				-- wait until next face (so one has time to do something by hand)
	self.UseLootrun = true;			-- should we do a loot run at the end of the event (looks more like a bot)
	self.destX = -27103;		-- middle of fight area
	self.destZ = 10181;
	self.nextX = -27236;		-- first place of circle around middle point to run
	self.nextZ = 10121;
	self.WPadd_rnd = 40;		-- random add to the waypoint to be not to exact
	self.waypoints = {			-- waypoints around fight area / used randomly
	{ X=-26618, Z=10294, Y=-1621},
	{ X=-26947, Z=10480, Y=-1669},
	{ X=-27090, Z=10038, Y=-1559},
	{ X=-26840, Z=9791, Y=-1508},
	{ X=-27304, Z=9862, Y=-1512},
	{ X=-26795, Z=9981, Y=-1564},
	{ X=-26749, Z=10369, Y=-1626},
	{ X=-27243, Z=10219, Y=-1631},
	{ X=-26823, Z=10018, Y=-1570},
	{ X=-26960, Z=10540, Y=-1696},
	{ X=-26823, Z=10294, Y=-1610},
	{ X=-27167, Z=10426, Y=-1674},
	{ X=-27176, Z=10059, Y=-1568},
	{ X=-27372, Z=10423, Y=-1693},
	{ X=-26790, Z=9998, Y=-1568},
	{ X=-26898, Z=10454, Y=-1651},
	{ X=-26637, Z=10220, Y=-1609},
	{ X=-27242, Z=10248, Y=-1642},
	{ X=-27075, Z=9740, Y=-1482},
	{ X=-26956, Z=10275, Y=-1608},
	{ X=-26623, Z=10054, Y=-1587},
	};	
-- Working fields
	self.index = 1;
	self.interactionX = 0;		-- remember interaction place to avoid being sticked
	self.interactionZ = 0;
	self.interactionCount = 0;
	self.nextMoveafter = 0;
	self.EventRunning = false;
	self.lastTargetTime = getTime();-- last time we use nextTarget Tab
	self.InteractTime = getTime();	-- last time we do an F-Interaction
	self.LastFaceTime = os.time();	-- last time we try to face middle
	self.LastMoveTime = os.time();	-- last time we moved the place
	self.LastCombatTime = 0;		-- last time we use skills in combat
	self.moving = false;			-- mark if we are moving to avoid facing during move
	self.facing = false;			-- mark if we are during facing
	self.needlootrun = false;		-- mark if we need to trigger a lootrun / cleared after triggering
end


function Bridge2State:update()
--	logger:log('debug',"Coming to Bridge2State:update()");

	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed

	if player.HP < 10 then
		logger:log('debug',"HP = %d < 10 wait for 10 seconds", player.HP);
		yrest(10000)
		return
	end

-- check if event is running depending from last combat time / TODO: real event flag or Karma update?
	if os.difftime(os.time(),self.LastCombatTime) > self.OutOfCombatTimer then
		logger:log('info',"state bridge: no event running (out of combat timer > %d sec", self.OutOfCombatTimer );
		self.EventRunning = false;	
	else
		self.EventRunning = true;
		self.needlootrun = true;
	end

-- start loot run after end of combat/event
	if ( self.UseLootrun == true ) and
	   ( self.EventRunning == false ) and
	   ( self.needlootrun == true ) then
		self.needlootrun = false;	-- clear need lootrun flag
		stateman:pushEvent("Lootrun", "Bridge2");
	end

-- if F-Interaction loot every x milliseconds / TODO: use Interaction tye to avoid greeting
	if player.Interaction == true and 
	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
		if( self.interactionX == player.X) and	-- count interactions at the same spot
		  ( self.interactionZ == player.Z) then
			self.interactionCount = self.interactionCount + 1;
		else
			self.interactionCount = 0;		-- interaction at new place, clear counter
		end

		if( self.interactionCount < 4 ) then		-- only 3 times at the same place
			self.interactionX = player.X;
			self.interactionZ = player.Z;
			keyboardPress(keySettings['interact']);		-- loot
			logger:log('info',"Interaction at (%d, %d)\n", player.X, player.Z);
			self.InteractTime = getTime();
		else
			logger:log('info',"no more interaction at that place (%d, %d)\n", player.X, player.Z);
		end
	end			

-- move around at the fight place
	if player.TargetMob == 0 and
	    ( os.difftime(os.time(),self.LastMoveTime) > self.moveafter+math.random(self.moveafter_rnd) ) and
		( 	self.EventRunning == true )	then		-- moving only during/close to combat
		logger:log('info',"try to move to #%d (%d, %d) Lastmovetime %d \n", self.index, self.nextX, self.nextZ, self.LastMoveTime);
		if not player:moveTo_step(self.nextX, self.nextZ, 100 ) then
			self.moving = true;
			logger:log('debug2',"move to not finished: we are (%d,%d) distance %d", player.X, player.Z, distance(player.X, player.Z, self.nextX, self.nextZ));
--			return  -- activate to avoid fighting during moving
		else
			player:stopMoving();	-- FIX for movements after reaching wp
			logger:log('debug',"move finished");
			self.moving = false;
			self.LastMoveTime = os.time();
			self:advance()		
		end
	end

-- face to middle of fighting area
	if player.TargetMob == 0 and	-- only face if no target / TODO how to avoid not visible targets
	   ( os.difftime(os.time(),self.LastFaceTime ) > self.FaceWait ) and
	   self.moving == false  then 	-- no facing during moving
		local angle = math.atan2(self.destZ - player.Z, self.destX - player.X) + math.pi;	-- *** DEBUG
		local anglediff = player.Angle - angle;												-- *** DEBUG
--		logger:log('debug2',"Bridge2.lua: face middle player.Angle %.2f (anglediff %.2f) max 0.5", player.Angle, anglediff );
		if not player:facedirection(self.destX, self.destZ, 0.5) then		-- turn if angel more then x  of from waypoint
			self.facing = true;
		else
			player:stopMoving();	-- FIX for movements after reaching wp
			self.facing = false;
			self.LastFaceTime = os.time();
		end
	end

-- target new mob
	if player.TargetMob == 0 and
	   deltaTime(getTime(), self.lastTargetTime) > 500 and
	   self.moving == false and		-- not during moving
	   self.facing == false  then	-- no targeting during facing to middle move
		self.lastTargetTime = getTime()
		player:getNextTarget()
	end

-- attack 
	if  player.TargetMob ~= 0	and
		self.moving == false then
		local target_distance = distance(player.X, player.Z, target.TargetX, target.TargetZ)
		if ( target_distance < profile['fightdistance'] ) then	
			player:useSkills()
	--		stateman:pushEvent("Combat","Bridge2");
			self.LastCombatTime = os.time()	-- remeber last time we get in combat
		else
			logger:log('info',"Target %s is to fare. distance=%d > fightdistance=%d\n", player.TargetMob, target_distance, profile['fightdistance']);
			keyboardPress(key.VK_ESCAPE)	-- TODO / use memwrite function to clear target
		end
	end

end

-- Advance the waypoint index randomly to the next point.
function Bridge2State:advance()
	self.index = math.random(#self.waypoints);
	local wp = self.waypoints[self.index];
	self.nextX = wp.X+math.random(self.WPadd_rnd);
	self.nextZ = wp.Z+math.random(self.WPadd_rnd);
	self.nextMoveafter = self.moveafter+math.random(self.moveafter_rnd)	-- set time for next move
	logger:log('info',"Waypoints advanced to #%d (%d, %d) next move in %d sec\n", self.index, wp.X, wp.Z, self.nextMoveafter);
end



-- Handle events
function Bridge2State:handleEvent(event)

	if event == "Lootrun"  then			
--		stateman:pushEvent("Waypoint", "Bridge2");

		self.needlootrun = false;	-- clear need lootrun flag
		waypoint.lootwalk = true	-- loot while running
		waypoint.laps = 1			-- only one round
		waypoint.waypointname = "kessex-bridge-loot"
		logger:log('info',"Change to loot run\n");		
		stateman:pushState(WaypointState())
		return true;
	end


end

table.insert(events,{name = "Bridge2", func = Bridge2State()})