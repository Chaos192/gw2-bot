--[[
	State base class. All other states should inherit from this.
]]


Player = class();

function Player:constructor()
	self.name = "playername"
	self.HP = 1000
	self.MaxHP = 1000
	self.Heal = 60
	self.HealCD = 25
	self.X = 0
	self.Z = 0
	self.Y = 0
	self.Dir1 = 0
	self.Dir2 = 0
	self.TargetMob = 0
	self.TargetAll = 0
	self.Loot = false
	self.Interaction = false
	self.InCombat = false
end

function Player:update()
	local proc = getProc()
	self.HP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerHPoffset) or self.HP;
	self.MaxHP = memoryReadFloatPtr(proc, addresses.playerbasehp, addresses.playerMaxHPoffset) or self.MaxHP;
	self.X = memoryReadFloat(proc, addresses.playercoords + addresses.playerX) or self.X;
	self.Z = memoryReadFloat(proc, addresses.playercoords + addresses.playerZ) or self.Z;
	self.Y = memoryReadFloat(proc, addresses.playercoords + addresses.playerY) or self.Y;
	self.Dir1 = memoryReadFloat(proc, addresses.playercoords + addresses.playerDir1) or self.Dir1;
	self.Dir2 = memoryReadFloat(proc, addresses.playercoords + addresses.playerDir2) or self.Dir2;
	self.TargetMob = memoryReadInt(proc, addresses.TargetMob) or self.TargetMob;
	self.TargetAll = memoryReadInt(proc, addresses.TargetAll) or self.TargetAll;
	self.Loot = (memoryReadInt(proc, addresses.lootwindow) ~= 0)
	self.Interaction = (memoryReadInt(proc, addresses.Finteraction) ~= 0)
	self.InCombat = (memoryReadInt(proc, addresses.playerInCombat) ~= 0)
end