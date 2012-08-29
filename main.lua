BASE_PATH = getExecutionPath();

include("classes/language.lua");
include("classes/statemanager.lua");
include("addresses.lua");
include("config_default.lua");
include("config.lua");
include("misc.lua");
include("classes/logger.lua");
include("classes/player.lua");

attach(getWin());

player = Player();
player:update()
language = Language();


local subdir = getDirectory(getExecutionPath() .. "/classes/states/")
for i,v in pairs(subdir) do
	if string.find(v,".lua") then
		include("classes/states/"..v)
	end
end


logger = Logger(BASE_PATH .. "/logs/" .. os.date('%Y-%m-%d') .. ".txt");
local version = "rev 7"

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
		stateman:pushEvent("Quit", "main");
	end
	lastKS = ks;
end

local function update()
	player:update()
	if player.Heal > player.HP/player.MaxHP*100 then
		stateman:pushEvent("Heal", "main");
	end
	--[[if player.InCombat then
		stateman:pushEvent("Combat","main");
	end]]
end
print("Get focus on GW2 and press F5")
local times = 3
repeat 
times = times - 1
	yrest(1000)
	print(times.." seconds to go")
until times == 0

function _windowname()
	player:update()
	setWindowName(getHwnd(),sprintf("X: %d Z: %d Y: %d Dir1: %0.2f, Dir2: %0.2f, A: %0.2f", player.X, player.Z, player.Y, player.Dir1, player.Dir2, player.Angle))
end
registerTimer("setwindow", secondsToTimer(1), _windowname);

function main()
	local defaultState = nil;


	stateman = StateManager();
	for i = 2,#args do
		if( args[i] == "coords" ) then
			while(true) do
				player:update()
				if player.Heal > player.HP/player.MaxHP*100 then
					keyboardPress(key.VK_6)
				end				
				setWindowName(getHwnd(),sprintf("X: %d Z: %d Y: %d Dir1: "..player.Dir1.." Dir2: "..player.Dir2,player.X,player.Z,player.Y))
				yrest(10)
				keyboardPress(key.VK_1)
				yrest(500)
			end
		elseif ( args[i] == "com" ) then
			repeat
				cprintf(cli.lightblue,"Command> ");
				local name = io.stdin:read();
				if string.lower(name) == "q" then error("Exiting commandline.",0) end
				funct=loadstring(name)
				if type(funct) == "function" then
					local status,err = pcall(funct);
					if status == false then
						printf("onLoad error: %s\n", err);
					end

				else
					print ("Invalid Command")
				end
			until false	
		elseif ( args[i] == "idle" ) then
			defaultState = IdleState();
		elseif( args[i] == "portal" ) then
			defaultState = PortalState();
		end
		
	end

	if( defaultState ) then
		stateman:pushState(defaultState);
	else
		stateman:pushState(WaypointState());
	end

	print("Version: "..version)
	print("Current state: ", stateman:getState().name);

	while(stateman.running) do
		--update()
		--handleInput();
		player:update()
		stateman:handleEvents();
		stateman:run();
		yrest(1);
	end
end
startMacro(main, true);