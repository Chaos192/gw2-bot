local proc = getProc()
function targetupdate()
	player.TargetMob = memoryReadRepeat("int", proc, addresses.TargetMob) or player.TargetMob;
	player.TargetAll = memoryReadRepeat("int", proc, addresses.TargetAll) or player.TargetAll;
	if player.TargetAll ~= 0 then
		target.TargetX = memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetXoffset) or target.TargetX
		target.TargetZ =  memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetZoffset) or target.TargetZ
		target.TargetY =  memoryReadRepeat("floatptr", proc, addresses.targetbaseAddress, addresses.targetYoffset) or target.TargetY
	else
		target.TargetX = 0
		target.TargetZ = 0
		target.TargetY = 0
	end
end

function coordsupdate()
	player.X = memoryReadRepeat("float", proc, addresses.playerX) or player.X;
	player.Z = memoryReadRepeat("float", proc, addresses.playerZ) or player.Z;
	player.Y = memoryReadRepeat("float", proc, addresses.playerY) or player.Y;
	player.Dir1 = memoryReadRepeat("float", proc, addresses.playerDir1) or player.Dir1;
	player.Dir2 = memoryReadRepeat("float", proc, addresses.playerDir2) or player.Dir2;
	player.Angle = math.atan2(player.Dir2, player.Dir1) + math.pi;
	player.MapId = memoryReadRepeat("int", proc, addresses.mapId) or 0;
end

function hpupdate()
	player.HP = memoryReadRepeat("floatptr", proc, addresses.playerbasehp, addresses.playerHPoffset) or player.HP;
	player.MaxHP = memoryReadRepeat("floatptr", proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or player.MaxHP;
end

function playerinfoupdate()
	player.Name = memoryReadRepeat("ustring", proc,addresses.playerName) or player.Name
	player.Account = memoryReadRepeat("ustring", proc,addresses.playerAccount) or player.Account
	player.Karma = memoryReadRepeat("intptr", proc, addresses.playerbasehp, addresses.playerKarmaoffset) or player.Karma;
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
	player.Downed = (memoryReadRepeat("int", proc, addresses.playerDowned) ~= 0)
	player.Loading = (memoryReadRepeat("intptr", proc, addresses.loadingbase,addresses.loadingOffset) ~= 0)

	if( stateman and player.InCombat and not last_combat  and
	  SETTINGS['combatstate'] == true) then		-- allow entercombat state pushed automaticly if incombat
		local n = debug.getinfo(2);
		stateman:pushEvent("entercombat", n.name);
	end
	player.Ftext = "" -- reset it as the text doesn't change in memory if no "F" on screen	
	if player.Interaction == true then
		player.Ftext = memoryReadUStringPtr(proc,addresses.FtextAddress, addresses.FtextOffset) or ""
--		if( SETTINGS['language'] == "russian" ) then
--			player.Ftext = utf82oem_russian(player.Ftext)
--		else
--			player.Ftext = utf8ToAscii_umlauts(player.Ftext)
--		end
	end
end

function updateskills()
	--=== skills 1 to 5 ===--
	for i = 1,5 do
		local int = memoryReadRepeat("intptr", proc, addresses.playerbasehp,{0x188, 0x100 + (i*4)})
		if int == 0 then 
			return 
		else
			player.skill[i] = memoryReadRepeat("int", proc, int + 0x20) or player.skill[i]
		end
	end
	--=== skills 6 to 0 ===--
	for i = 0,4 do
		local num = i+6
		if num == 10 then num = 0 end
		local int = memoryReadRepeat("intptr", proc, addresses.playerbasehp,{0x188, 0xF0 + (i*4)})
		if int == 0 then 
			return 
		else
			player.skill[num] = memoryReadRepeat("int", proc, int + 0x20) or player.skill[num]
		end
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


