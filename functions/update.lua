local proc = getProc()
function targetupdate()
	player.TargetMob = memoryReadRepeat("int", proc, addresses.TargetMob) or player.TargetMob;
	player.TargetAll = memoryReadRepeat("int", proc, addresses.TargetAll) or player.TargetAll;
	--[[if player.TargetAll ~= 0 then
		target.TargetX = memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetXoffset) or target.TargetX
		target.TargetZ =  memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetZoffset) or target.TargetZ
		target.TargetY =  memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetYoffset) or target.TargetY
	else]]
		target.TargetX = 0
		target.TargetZ = 0
		target.TargetY = 0
	--end
end

function coordsupdate()
	--player.X = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServX) or player.X;
	--player.Z = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServZ) or player.Z;
	--player.Y = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServY) or player.Y;
	player.Dir1 = memoryReadRepeat("float", proc, addresses.playerDir1) or player.Dir1;
	player.Dir2 = memoryReadRepeat("float", proc, addresses.playerDir2) or player.Dir2;
	player.X = (memoryReadRepeat("float", proc, addresses.playerX)/30) or player.X;
	player.Z = (memoryReadRepeat("float", proc, addresses.playerZ)/30) or player.Z;	
	player.Y = (memoryReadRepeat("float", proc, addresses.playerY)/30) or player.Y;
	

	player.Angle = math.atan2(player.Dir2, player.Dir1) + math.pi;
	--player.ServX = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServX) or 0
	--player.ServZ = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServZ) or 0
	--player.ServY = memoryReadRepeat("floatptr", proc, addresses.playerbasehp,addresses.playerServY) or 0
	
--debug_value(player.Angle, "player.Angle");	
--	player.MapId = memoryReadRepeat("int", proc, addresses.mapId) or 0;
end

function hpupdate()
	player.HP = memoryReadRepeat("floatptr", proc, addresses.playerbasehp, addresses.playerHPoffset) or player.HP;
	player.MaxHP = memoryReadRepeat("floatptr", proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or player.MaxHP;
end

function playerinfoupdate()
	player.Name = memoryReadRepeat("ustring", proc,addresses.playerName) or player.Name
	player.Account = memoryReadRepeat("ustring", proc,addresses.playerAccount) or player.Account
	--player.Karma = memoryReadRepeat("intptr", proc, addresses.playerbasehp, addresses.playerKarmaoffset) or player.Karma;
	player.Gold = memoryReadRepeat("intptr", proc, addresses.playerbasehp, addresses.playerGoldoffset) or player.Gold;
	--player.monthlyXP = memoryReadRepeat("intptr",proc, addresses.monthxpcountbase, addresses.monthxpcountoffset) or player.monthlyXP
end
	
function playerstatsupdate()
	player.actlvl = memoryReadRepeat("intptr", proc, addresses.statbase, addresses.actlvlOffset) or player.actlvl;
	player.adjlvl = memoryReadRepeat("intptr", proc, addresses.statbase, addresses.adjlvlOffset) or player.adjlvl;
	--player.XP = memoryReadRepeat("intptr", proc,  addresses.XPbase, addresses.xpOffset) or player.XP;	
	--player.XPnextlvl = memoryReadRepeat("intptr", proc, addresses.XPbase, addresses.xpnextlvlOffset) or player.XPnextlvl;
end

function statusupdate()
	local last_combat = player.InCombat;
	player.Interaction = (memoryReadRepeat("int", proc, addresses.Finteraction) ~= 0)
	--player.InteractionId = memoryReadRepeat("int", proc, 0x1103EFD8);
	player.InCombat = (memoryReadRepeat("int", proc, addresses.playerInCombat) ~= 0)
	local down = memoryReadRepeat("intptr", proc, addresses.playerbasehp,0xA0)
	player.Alive = (down == 0);
	player.Downed = (down == 2);
	player.Dead = (down == 1);
	--player.Loading = (memoryReadRepeat("intptr", proc, addresses.loadingbase,addresses.loadingOffset) ~= 0)

	if( stateman and player.InCombat and not last_combat  and
	  SETTINGS['combatstate'] == true) then		-- allow entercombat state pushed automaticly if incombat
		local n = debug.getinfo(2);
		stateman:pushState(CombatState(), n.name);
	end
	player.Ftext = "" -- reset it as the text doesn't change in memory if no "F" on screen	
	player.Fid = 0
	if player.Interaction == true then
		player.Ftext = memoryReadUStringPtr(proc,addresses.FtextAddress, addresses.FtextOffset) or ""
--		if( SETTINGS['language'] == "russian" ) then
--			player.Ftext = utf82oem_russian(player.Ftext)
--		else
--			player.Ftext = utf8ToAscii_umlauts(player.Ftext)
--		end
		player.Fid = memoryReadIntPtr(proc,addresses.FtextAddress, addresses.FidOffset) or 0
	end
end

function updateskills()
	local fskill = {6,7,8,9,0,1,2,3,4,5,"U1","U2","F1","F2","F3","F4","U3"}
--	for i = 1,17 do
--		local int = memoryReadRepeat("intptr", proc, addresses.playerbasehp,{0x188, 0xEC + (i*4)})
--		if int == 0 then 
--			player.skill[fskill[i]] = 0
--		else
--			player.skill[fskill[i]] = memoryReadRepeat("int", proc, int + 0x20) or player.skill[fskill[i]]
--		end
--	end
end

function speed(_speed)
	local currspeed = memoryReadRepeat("floatptr", proc, addresses.speed, addresses.speedOffset)
	if _speed == "get" then
		return currspeed
	end
	if _speed == "norm" then
		memoryWriteFloatPtr( proc, addresses.speed,addresses.speedOffset, 9.1875)
		return
	end
	if _speed and _speed ~= currspeed then
		memoryWriteFloatPtr( proc, addresses.speed,addresses.speedOffset, _speed)
		return
	end
end

function updateall()
	playerinfoupdate()
	hpupdate()
	statusupdate()	
	coordsupdate()
	targetupdate()
	playerstatsupdate()
	updateskills()
end


