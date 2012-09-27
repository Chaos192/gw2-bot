--[[
	Child of State class.
]]
-- example state at Kessex Bridge LvL 14 - 40
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
	self.OutOfCombatTimer = 40;	-- after x sec of of combat we don't move around anymore
	self.CombatWait = 10;			-- wait x seconds before entering event
	self.moveafter = 10;			-- time after that we change place
	self.moveafter_rnd = 10;		-- random add to the time after that we change place
	self.FaceWait = 10;				-- wait until next face (so one has time to do something by hand)
	self.UseLootrun = true;			-- should we do a loot run at the end of the event (looks more like a bot)
	self.LootrunWPname = {};		-- WP file(s) for the lootrun at end of event
	  self.LootrunWPname[1]="kessex-bridge-lootrun1"	-- randomly choose a filename
	  self.LootrunWPname[2]="kessex-bridge-lootrun2"
	  self.LootrunWPname[3]="kessex-bridge-lootrun3"
	  self.LootrunWPname[4]="kessex-bridge-lootrun4"
	self.UseWaitrun = true;			-- should we do harvesting runs between waiting for the next event
	self.WaitrunTimer = 60;		-- after beeing X sec out of combat we move await
	self.WaitrunTimer_rnd = 30;	-- random add
	self.WaitrunWPname = {};		-- WP file(s) for the waitrun
	  self.WaitrunWPname[1]="kessex-bridge-waitrun-NW"	-- randomly choose a filename
	  self.WaitrunWPname[2]="kessex-bridge-waitrun-NW2"
	  self.WaitrunWPname[3]="kessex-bridge-waitrun-NW3"	  
	  self.WaitrunWPname[4]="kessex-bridge-waitrun-S"
	  self.WaitrunWPname[5]="kessex-bridge-waitrun-S2"	  
	  self.WaitrunWPname[6]="kessex-bridge-waitrun-W"	  
	  self.WaitrunWPname[7]="kessex-bridge-waitrun-W2"	  	  
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
	{ X=-26599, Z=10512, Y=-1675, type="", comment="#1"},
	{ X=-26725, Z=10634, Y=-1687, type="", comment="#2"},
	{ X=-26676, Z=10480, Y=-1660, type="", comment="#3"},
	{ X=-26511, Z=10412, Y=-1654, type="", comment="#4"},
	{ X=-26895, Z=10457, Y=-1651, type="", comment="#1"},
	{ X=-26820, Z=10191, Y=-1594, type="", comment="#2"},
	{ X=-26597, Z=10260, Y=-1618, type="", comment="#3"},
	{ X=-26729, Z=10392, Y=-1633, type="", comment="#4"},
	{ X=-27083, Z=10480, Y=-1673, type="", comment="#5"},
	{ X=-26973, Z=10593, Y=-1711, type="", comment="#6"},
	{ X=-26864, Z=10229, Y=-1600, type="", comment="#7"},
	{ X=-26725, Z=10039, Y=-1579, type="", comment="#8"},
	{ X=-26688, Z=10295, Y=-1614, type="", comment="#9"},
	{ X=-26835, Z=10492, Y=-1658, type="", comment="#10"},
	};	
-- Working fields
	self.index = 1;
	self.interactionX = 0;		-- remember interaction place to avoid being sticked
	self.interactionZ = 0;
	self.interactionCount = 0;
	self.InteractTime = getTime();	-- last time we do an F-Interaction
	self.nextMoveafter = 0;
	self.EventRunning = false;
	self.lastTargetTime = getTime();-- last time we use nextTarget Tab
	self.LastFaceTime = os.time();	-- last time we try to face middle
	self.LastMoveTime = os.time();	-- last time we moved the place
	self.LastCombatTime = os.time()-self.OutOfCombatTimer;		-- last time we use skills in combat
	self.moving = false;			-- mark if we are moving to avoid facing during move
	self.facing = false;			-- mark if we are during facing
	self.needlootrun = false;		-- mark if we need to trigger a lootrun / cleared after triggering
	self.waitrunActive = false;		-- remember if waitrun is active
	self.escaperunActive = false	-- remember if escaperun from gorge is active
	self.LastKarma = 0				-- Karma before end of event
end


function Bridge2State:update()
	logger:log('debug-states',"Coming to Bridge2State:update()");

	statusupdate()		-- to get info about interaction
	targetupdate()		-- to get target cleared
	playerinfoupdate()	-- to get the karma update information

	-- set mouse pointer to middle of screen
	setMousepointerToMiddle(60)	-- only every 60 seconds

	if SETTINGS['combatstate'] == true then SETTINGS['combatstate'] = false end -- stops combat being pushed

	if( self.LastKarma == 0 ) then		-- remeber Karma at beginning
		self.LastKarma = player.Karma
	end

	if player.HP < 10 then
		logger:log('debug',"HP = %d < 10 wait for 10 seconds", player.HP);
		yrest(10000)
		return
	end

-- Check end of Event by Karma / 
	if ( player.Karma > self.LastKarma ) then
		logger:log('info',"Event finished. Karma update from %d to %d", self.LastKarma, player.Karma );
		self.EventRunning = false;	
		self.needlootrun = true;		-- Lootrun only at end of Event
		self.LastKarma = player.Karma
	end

-- check if event is running depending from last combat time / TODO: real event flag for start of Event?
	if os.difftime(os.time(),self.LastCombatTime) > self.OutOfCombatTimer then
		logger:log('info',"Last combat at %s more then %d sec ago. No moving anymore", os.date("%H:%M:%S", self.LastCombatTime) , self.OutOfCombatTimer );
		self.EventRunning = false;	
	else
		self.EventRunning = true;
	end

-- start loot run after end of combat/event
	if ( self.UseLootrun == true ) and
	   ( self.needlootrun == true ) then
		self.needlootrun = false;	-- clear need lootrun flag
		stateman:pushEvent("Lootrun", "Bridge2");
	end

-- after end of escape run from gorge
	if ( self.escaperunActive == true ) then	-- reset combat timer after coming back from waitrun
		self.escaperunActive = false
		player:moveTo_step(self.destX, self.destZ )		-- move to middle of fightarea to get away from escape path
	end

-- start wait run between events
	if ( self.waitrunActive == true ) then	-- reset combat timer after coming back from waitrun
		self.waitrunActive = false
		self.LastCombatTime = os.time();
	end

	if ( self.UseWaitrun == true ) and
	   ( self.EventRunning == false ) and
	   os.difftime(os.time(),self.LastCombatTime) > self.WaitrunTimer+math.random(self.WaitrunTimer_rnd) then
		stateman:pushEvent("Waitrun", "Bridge2");
	end

-- if F-Interaction loot every x milliseconds / TODO: use Interaction tye to avoid greeting
	if player.Interaction == true and 
	   player.Ftext ~= language:message('InteractGreeting') and
	   player.Ftext ~= language:message('InteractTalk')  and		-- not if only greeting
--		player.InteractionId == 0x1403F and -- Make sure it is actually loot  / NOT WORKING ATM
	   deltaTime(getTime(), self.InteractTime ) > 500 then	-- only ever 0.5 second
		if( self.interactionX == player.X) and	-- count interactions at the same spot
		  ( self.interactionZ == player.Z) then
			self.interactionCount = self.interactionCount + 1;
		else
			self.interactionCount = 0;		-- interaction at new place, clear counter
		end

		if( self.interactionCount < 3 ) then		-- only 2 times at the same place
			self.interactionX = player.X;
			self.interactionZ = player.Z;
--			keyboardPress(keySettings['interact']);		-- loot
			stateman:pushState(LootState(), "Walked over lootable.");		-- loot
			logger:log('info',"Interaction at (%d, %d)\n", player.X, player.Z);
			self.InteractTime = getTime();
		elseif( self.interactionCount == 3 ) then	-- only one message
			logger:log('info',"no more interaction at that place (%d, %d)\n", player.X, player.Z);
		end
	end			

-- initiate move around the fight place
-- we use a flag to initiate move to avoid endless move if event stops during move unfinished
	if player.TargetMob == 0 and
	    ( os.difftime(os.time(),self.LastMoveTime) > self.moveafter+math.random(self.moveafter_rnd) ) and
		( 	self.EventRunning == true )	then		-- moving only during/close to combat
		self.moving = true;
	end


-- move around at the fight place
	if self.moving == true then
		logger:log('debug-moving',"try to move to #%d (%d, %d) Lastmovetime %s \n", self.index, self.nextX, self.nextZ, os.date("%H:%M:%S", self.LastMoveTime));
		if not player:moveTo_step(self.nextX, self.nextZ ) then
			self.moving = true;
			logger:log('debug-moving',"at bridge2.lua:move to not finished, we are (%d,%d) distance %d", player.X, player.Z, distance(player.X, player.Z, self.nextX, self.nextZ));
		else
			logger:log('debug-moving',"at bridge2.lua:move finished");
			self.moving = false;
			self.LastMoveTime = os.time();
			self:advance()		
		end
	end

-- face to middle of fighting area
	if player.TargetMob == 0 and	-- only face if no target / TODO how to avoid not visible targets
	   ( os.difftime(os.time(),self.LastFaceTime ) > self.FaceWait ) and	-- only face after every x seconds
	   self.moving == false  then 	-- no facing during moving
		local angle = math.atan2(self.destZ - player.Z, self.destX - player.X) + math.pi;	-- *** DEBUG
		local anglediff = player.Angle - angle;												-- *** DEBUG
--		logger:log('debug2',"Bridge2.lua: face middle player.Angle %.2f (anglediff %.2f) max 0.5", player.Angle, anglediff );
		if not player:facedirection(self.destX, self.destZ, 0.5) then		-- turn if angel more then x  of from waypoint
			self.facing = true;
		else
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

-- unstick from gorge
-- TODO: only check if in a unstick situation / what's best place to detect an unstick situation?
	if not unstickPathWP then
		unstickPathWP = WaypointState("kessex-bridge-escape-gorge")
	end

	local nearest
	nearest, unstickPathWP.index = unstickPathWP:distanceToPath()
	if nearest < 250 then	-- seems to be down in the gorge
		stateman:pushEvent("GorgeEscape", "Bridge2");
	end

end

-- Advance the waypoint index randomly to the next point.
function Bridge2State:advance()
	self.index = math.random(#self.waypoints);
	local wp = self.waypoints[self.index];
	self.nextX = wp.X+math.random(self.WPadd_rnd);
	self.nextZ = wp.Z+math.random(self.WPadd_rnd);
	self.nextMoveafter = self.moveafter+math.random(self.moveafter_rnd)	-- set time for next move
	logger:log('info',"Waypoints randomly move to #%d (%d, %d) next move in %d sec\n", self.index, wp.X, wp.Z, self.nextMoveafter);
end



-- Handle events
function Bridge2State:handleEvent(event)

	if event == "GorgeEscape"  then			

--		unstickPathWP.laps = 1					-- only one round
		unstickPathWP.stopAtEnd = true			-- run path only until end
		unstickPathWP.getTarget = false			-- don't look for targets during runing back
		logger:log('info',"Try to escape from gorge. We use waypointfile '%s'\n", unstickPathWP.waypointname);
		self.escaperunActive = true
		stateman:pushState(unstickPathWP)
		return true;

	end

	if event == "Lootrun"  then			

		self.needlootrun = false;	-- clear need lootrun flag
		local lootrunWP = WaypointState()
		lootrunWP.lootwalk = true	-- loot while running
		lootrunWP.laps = 1			-- only one round
		lootrunWP.getTarget = false		-- don't look for targets during lootrun
		lootrunWP.waypointname = self.LootrunWPname[math.random(#self.LootrunWPname)]
		logger:log('info',"Change to loot run using waypointfile '%s'\n", lootrunWP.waypointname);		
		stateman:pushState(lootrunWP)
		return true;
	end

	if event == "Waitrun"  then			

		local waitrunWP = WaypointState(self.WaitrunWPname[math.random(#self.WaitrunWPname)])
		waitrunWP.lootwalk = true	-- loot while running
		waitrunWP.stopAtEnd = true	-- run path only until end
		waitrunWP.getTarget = true	-- look for targets during lootrun
--		waitrunWP.index = 1			-- start with WP #1
		logger:log('info',"Go to wait run between event using path '%s'\n", waitrunWP.waypointname);
		self.waitrunActive = true
		stateman:pushState(waitrunWP)
		return true;
	end


end

table.insert(events,{name = "Bridge2", func = Bridge2State()})