--[[
	Chest farm state - Still under construction
	Farms chests in whichever map you are currently in.
	Currently, on Lion's Arch is supported.

	To use (Subject to change):
		* Set self.skillcd to the cooldown of your sync skill (TODO: Automate this)
		* Change ChestfarmState:sync() to use proper skill for you class/weapon combo (TODO: Automate this)
		* Go to correct zone, run gw2/main state:Chestfarm
		* Wait
]]

include("../state.lua");

ChestfarmState = class(State);

function ChestfarmState:constructor()
	self.name = "Chest farm (Teleporting)";

	self.teleportingState = 0;
	self.teleportWaitTime = 1000; -- Time in miliseconds to wait before attempting to sync
	self.interactTime = 5000; -- Time in miliseconds to wait for looting chests
	self.teleportTime = {high = 0, low = 0};
	self.skillcd = 18000;
	self.lastskilltime = {high = 0, low = 0};
	self.progress = 0;
	self.region = nil;
	self.regionData = {
		[50] = { -- Lion's Arch
			chests = {
				{x = -484.277, z = 414.525, y = 51.923},
				{x = 703.964, z = -499.796, y = 2.740},
				{x = 827.720, z = 463.908, y = 83.139},
			},
		},
	};
	-- Note: Bloodtide Coast Map ID: 73
end

function ChestfarmState:update()
	if( self.teleportingState > 0 ) then
		-- Stuck waiting on teleport completion
		self:teleport(); -- Continue with teleporting until complete
		return;
	end

	if( self.region == nil ) then
		self.region = self.regionData[player.MapId];
		if( self.region == nil ) then
			error('No data provided for this map. Sorry.', 2);
		end
	end

	self.progress = self.progress + 1;
	local chest = self.region.chests[self.progress];
	if( self.progress > #self.region.chests or chest == nil ) then
		-- Done.
		stateman:pushEvent("Quit", "Chest farming complete.");
		return;
	end

	self:teleport(chest.x, chest.y, chest.z);
	printf("Going to chest #%d\n", self.progress);

end

function ChestfarmState:handleEvent(event)

end

function ChestfarmState:sync()
	-- TODO: Make this depend on class and weapon skills.
	keyboardPress(key.VK_4);
	self.lastskilltime = getTime();
end

local _x, _y, _z; -- These hold the location we last teleported to (for adjustment after sync)
function ChestfarmState:teleport(x, y, z)
	local setLoc = function(x, y, z)
		local proc = getProc();
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerVisX, x);
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerServX, x);
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerVisY, y);
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerServY, y);
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerVisZ, z);
		memoryWriteFloatPtr(proc, addresses.playerbasehp, addresses.playerServZ, z);
		_x, _y, _z = x, y, z;
	end

	local _time = getTime();
	if( self.teleportingState == 0 ) then
		setLoc(x, y, z);
		self.teleportTime = _time;
		self.teleportingState = 1; -- Marked for waiting
		return;
	elseif( self.teleportingState == 1
		and deltaTime(_time, self.teleportTime) > self.teleportWaitTime
		and deltaTime(_time, self.lastskilltime) > self.skillcd ) then
		-- Sync, then wait another x amount of time
		self:sync();
		self.teleportTime = _time;
		self.teleportingState = 2;
		return;
	elseif( self.teleportingState == 2 and deltaTime(_time, self.teleportTime) > self.teleportWaitTime ) then
		-- Teleport finished, interact with chest
		setLoc(_x, _y, _z);
		self.teleportTime = _time;
		self.teleportingState = 3;
	elseif( self.teleportingState == 3 and deltaTime(_time, self.teleportTime) > self.teleportWaitTime ) then
		self:interact();
		self.teleportingState = 4;
		self.teleportTime = _time;
	elseif( self.teleportingState == 4 and deltaTime(_time, self.teleportTime) > self.interactTime ) then
		self.teleportingState = 0;
	end
end

function ChestfarmState:interact()
	if( not player.Interaction ) then
		return; -- No interaction
	end

	if( -- Vistas, chests, etc.
		player.Ftext ~= language:message('InteractGreeting') or
		player.Ftext ~= language:message('InteractTalk')
	) then
		keyboardPress(keySettings['interact']);
	end
end

table.insert(events,{name = "Chestfarm", func = ChestfarmState()})