
function targetupdate()
	local proc = getProc()
	player.TargetMob = memoryReadRepeat("int",proc, addresses.TargetMob) or player.TargetMob;
	player.TargetAll = memoryReadRepeat("int",proc, addresses.TargetAll) or player.TargetAll;
	if player.TargetAll ~= 0 then
		target.TargetX = memoryReadRepeat("floatptr",proc, addresses.targetbaseAddress, addresses.targetXoffset) or target.TargetX
		target.TargetZ =  memoryReadRepeat("floatptr",proc, addresses.targetbaseAddress, addresses.targetZoffset) or target.TargetZ
		target.TargetY =  memoryReadRepeat("floatptr",proc, addresses.targetbaseAddress, addresses.targetYoffset) or target.TargetY
	else
		target.TargetX = 0
		target.TargetZ = 0
		target.TargetY = 0		
	end
end

function coordsupdate()
	local proc = getProc()
	player.X = memoryReadRepeat("float",proc,  addresses.playerX) or player.X;
	player.Z = memoryReadRepeat("float",proc,  addresses.playerZ) or player.Z;
	player.Y = memoryReadRepeat("float",proc,  addresses.playerY) or player.Y;
	player.Dir1 = memoryReadRepeat("float",proc,  addresses.playerDir1) or player.Dir1;
	player.Dir2 = memoryReadRepeat("float",proc,  addresses.playerDir2) or player.Dir2;
	player.Angle = math.atan2(player.Dir2, player.Dir1) + math.pi;
	
	-- Only update movement info occasionally; reduce unnecessary memory reads
	if( deltaTime(player.curtime, player.movementLastUpdate) > 1000 ) then
		if( player.turnDir == "left" ) then
			-- Ensure we're turning left.
			memoryWriteInt(proc, addresses.turnLeft, 1);
			memoryWriteInt(proc, addresses.turnRight, 0);
		elseif( player.turnDir == "right" ) then
			-- Ensure we're turning right.
			memoryWriteInt(proc, addresses.turnLeft, 0);
			memoryWriteInt(proc, addresses.turnRight, 1);
		else
			-- Ensure we're not turning
			memoryWriteInt(proc, addresses.turnLeft, 0);
			memoryWriteInt(proc, addresses.turnRight, 0);
		end

		if( player.fbMovement == "forward" ) then
			-- Ensure we're moving foward
			memoryWriteInt(proc, addresses.moveForward, 1);
			memoryWriteInt(proc, addresses.moveBackward, 0);
		elseif( player.fbMovement == "backward" ) then
			-- Ensure we're moving backward
			memoryWriteInt(proc, addresses.moveForward, 0);
			memoryWriteInt(proc, addresses.moveBackward, 1);
		else
			-- Ensure we're not moving
			memoryWriteInt(proc, addresses.moveForward, 0);
			memoryWriteInt(proc, addresses.moveBackward, 0);
		end

		player.movementLastUpdate = player.curtime;
	end
end

function hpupdate()
	local proc = getProc()
	player.HP = memoryReadRepeat("floatptr",proc, addresses.playerbasehp, addresses.playerHPoffset) or player.HP;
	player.MaxHP = memoryReadRepeat("floatptr",proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or player.MaxHP;
end

function playerinfoupdate()
	local proc = getProc()
	player.Name = memoryReadRepeat("ustring",proc,addresses.playerName) or player.Name
	player.Account = memoryReadRepeat("ustring",proc,addresses.playerAccount) or player.Account
	player.Karma = memoryReadRepeat("intptr",proc, addresses.playerbasehp, addresses.playerKarmaoffset) or player.Karma;
	player.Gold = memoryReadRepeat("intptr",proc, addresses.playerbasehp, addresses.playerGoldoffset) or player.Gold;
	--player.monthlyXP = memoryReadRepeat("intptr",proc, addresses.monthxpcountbase, addresses.monthxpcountoffset) or player.monthlyXP

	end

function statusupdate()
	local proc = getProc()
	player.Interaction = (memoryReadRepeat("int",proc, addresses.Finteraction) ~= 0)
	player.InCombat = (memoryReadRepeat("int",proc, addresses.playerInCombat) ~= 0)
	player.Downed = (memoryReadRepeat("int",proc, addresses.playerDowned) ~= 0)
	player.Loading = (memoryReadRepeat("intptr",proc, addresses.loadingbase,addresses.loadingOffset) ~= 0)
end

function updateall()
	local proc = getProc()

	playerinfoupdate()
	hpupdate()
	statusupdate()	
	coordsupdate()
	targetupdate()

	--self.Ftext = "" -- reset it as the text doesn't change in memory if no "F" on screen	
	--[[if self.Interaction == true then
		self.Ftext = memoryReadUStringPtr(proc,addresses.FtextAddress, addresses.FtextOffset) or ""
		if( SETTINGS['language'] == "russian" ) then
			self.Ftext = utf82oem_russian(self.Ftext)
		else
			self.Ftext = utf8ToAscii_umlauts(self.Ftext)
		end
	end]]
end


