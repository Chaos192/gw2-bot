--[[
	State base class. All other states should inherit from this.
]]

Pet = class();

function Pet:constructor()
	self.Name = "petname"
	self.HP = 1000
	self.MaxHP = 1000
	self.Alive = true
	self.pet1 = true
	self.canchange = true
end

function Pet:update()
	local proc = getProc()
	local _offset2
	self.pet1 = (memoryReadIntPtr(proc, addresses.playerbasehp, {0x158,0x14}) ~= 0)
	if self.pet1 then _offset2 = 0x14 else _offset2 = 0x28 end
	self.HP = memoryReadFloatPtr(proc, addresses.playerbasehp, {0x158,_offset2,0x150,0x8}) or self.HP
	self.MaxHP = memoryReadFloatPtr(proc, addresses.playerbasehp, {0x158,_offset2,0x150,0xC}) or self.MaxHP
	self.Alive = (memoryReadIntPtr(proc, addresses.playerbasehp, {0x158,_offset2,0xA0}) == 0)
	self.Name = memoryReadUStringPtr(proc, addresses.playerbasehp, {0x158,_offset2,0xAC,0x0}) or "petname"
	self.canchange = (memoryReadIntPtr(proc, addresses.playerbasehp, {0x158,0x60}) == memoryReadIntPtr(proc, addresses.playerbasehp, {0x158,0x64}))
	if 35 > self.HP/self.MaxHP*100 and self.canchange then keyboardPress(key.VK_F4) end
end