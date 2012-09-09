--[[
	State base class. All other states should inherit from this.
]]

Update = class();

function Update:constructor()

end

function Update:targetupdate()
	local proc = getProc()
	player.TargetMob = memoryReadInt(proc, addresses.TargetMob) or player.TargetMob;
	player.TargetAll = memoryReadInt(proc, addresses.TargetAll) or player.TargetAll;
	if player.TargetAll ~= 0 then
		target.TargetX = memoryReadFloatPtr(proc, addresses.targetbaseAddress, addresses.targetXoffset) or target.TargetX
		target.TargetZ =  memoryReadFloatPtr(proc, addresses.targetbaseAddress, addresses.targetZoffset) or target.TargetZ
		target.TargetY =  memoryReadFloatPtr(proc, addresses.targetbaseAddress, addresses.targetYoffset) or target.TargetY
	else
		target.TargetX = 0
		target.TargetZ = 0
		target.TargetY = 0		
	end

end

function Update:coordsupdate()
	local proc = getProc()
	player.X = memoryReadFloat(proc,  addresses.playerX) or player.X;
	player.Z = memoryReadFloat(proc,  addresses.playerZ) or player.Z;
	player.Y = memoryReadFloat(proc,  addresses.playerY) or player.Y;
	player.Dir1 = memoryReadFloat(proc,  addresses.playerDir1) or player.Dir1;
	player.Dir2 = memoryReadFloat(proc,  addresses.playerDir2) or player.Dir2;
end

function Update:hpupdate()
	local proc = getProc()
	player.HP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerHPoffset) or player.HP;
	player.MaxHP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or player.MaxHP;
end

function Update:playerinfoupdate()
	local proc = getProc()
	player.Name = memoryReadUString(proc,addresses.playerName) or player.Name
	player.Account = memoryReadUString(proc,addresses.playerAccount) or player.Account
	player.Karma = memoryReadIntPtr(proc, addresses.playerbasehp, addresses.playerKarmaoffset) or player.Karma;
	player.Gold = memoryReadIntPtr(proc, addresses.playerbasehp, addresses.playerGoldoffset) or player.Gold;
	

end

function Update:statusupdate()
	local proc = getProc()
	
	player.Interaction = (memoryReadInt(proc, addresses.Finteraction) ~= 0)
	player.InCombat = (memoryReadInt(proc, addresses.playerInCombat) ~= 0)
	player.Downed = (memoryReadInt(proc, addresses.playerDowned) ~= 0)
	player.Loading = (memoryReadIntPtr(proc, addresses.loadingbase,addresses.loadingOffset) ~= 0)
end

function Update:update()
	local proc = getProc()

	--self.monthlyXP = memoryReadIntPtr(proc, addresses.monthxpcountbase, addresses.monthxpcountoffset) or self.monthlyXP
	self:playerinfoupdate()
	self:hpupdate()
	self:statusupdate()	
	self:coordsupdate()
	self:targetupdate()
	
	player.Angle = math.atan2(player.Dir2, player.Dir1) + math.pi;

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


