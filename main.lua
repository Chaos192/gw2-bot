include("classes/statemanager.lua")

-- Include all state classes
--[[
local subdir = getDirectory(getExecutionPath() .. "/classes/states/");
for i,v in pairs(subdir) do
	if string.find(v,".lua$") then
		include("classes/states/" .. v);
	end
end
]]
include("classes/states/idle.lua");

-- Include config
include("config_default.lua");
if( fileExists(getExecutionPath() .. "/config.lua") ) then
	include("config.lua");
end

-- Include loggnig
include("classes/logger.lua");

logger = Logger();
logger:setFile(getExecutionPath() .. "/logs/debug.txt");

local lastKS = keyboardState();
local function handleInput()
	local function pressed(vk)
		if( ks[vk] and not lastKS[vk] ) then
			return true;
		else
			return false;
		end
	end
	ks = keyboardState();

	if( pressed(key.VK_F8) ) then
		stateman:pushEvent("quit", "main");
	end

	lastKS = ks;
end

local function update()
	--[[updatehp()
	if 98 > playerhp/playermaxhp*100 then
		stateman:pushEvent("Heal", "main");
	end
	if playercombat then
		stateman:pushEvent("Combat","main");
	end]]
end

function main()
	stateman = StateManager();
	stateman:pushState(IdleState(), "main");

	while(stateman.running) do
		update()
		handleInput();
		stateman:handleEvents();
		stateman:run();
		yrest(1);
	end
end
startMacro(main, true);