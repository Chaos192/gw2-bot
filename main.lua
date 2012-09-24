BASE_PATH = getExecutionPath();
profile = include(BASE_PATH .. "/profiles/default.lua", true);
include("classes/language.lua");
include("classes/statemanager.lua");
include("addresses.lua");
include("config_default.lua");
include("config.lua");
local subdir = getDirectory(getExecutionPath() .. "/functions/")
for i,v in pairs(subdir) do
	if string.find(v,".lua") then
		include("functions/"..v)
	end
end
include("classes/logger.lua");
include("classes/player.lua");
include("classes/target.lua");


attach(getWin());
player = Player();
target = Target();

playerinfoupdate()
language = Language();
logger = Logger(BASE_PATH .. "/logs/".. string.gsub(player.Name,"%s","_") .. "/" .. os.date('%Y-%m-%d') .. ".txt");

updateall()

--=== update with character profile if it exists, do it here so state:construct can override profile settings ===--
local char = BASE_PATH .. "/profiles/" .. string.gsub(player.Name,"%s","_") .. ".lua";
if( fileExists(char) ) then	
	charprofile = include(BASE_PATH .. "/profiles/" .. string.gsub(player.Name,"%s","_") .. ".lua", true);
	logger:log('info',language:message('start_profile_name'), player.Name)	-- loading player profile 

	for k,v in pairs(charprofile) do
		profile[k] = v
	end
	player:constructor()
	updateall()
else
	logger:log('info',language:message('start_default_profile'), player.Name)	-- using default profile 
end	

attach(getWin());



local version = "rev 71"

atError(function(script, line, message)
	logger:log('error', "%s:%d\t%s", script, line, message);
	player:stopMoving();
	player:stopTurning()
end);

atPause(function()
	player:stopMoving();
	player:stopTurning()
end);

atExit(function()
	player:stopMoving();
	player:stopTurning()
end);

local subdir = getDirectory(getExecutionPath() .. "/classes/states/")
for i,v in pairs(subdir) do
	if string.find(v,".lua") then
		include("classes/states/"..v)
	end
end
--waypoint = WaypointState();
local lastKS = keyboardState();
function handleInput(_key)
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
	if( pressed(key.VK_F7) ) then
		return true
	end
	lastKS = ks;
end

local function updates()
	hpupdate()
	if player.Heal > player.HP/player.MaxHP*100 then
		logger:log('info',"use heal skills at %d/%d health (healing startes at %d percent)\n", player.HP, player.MaxHP, player.Heal);
		player:useSkills(true)
	end
end

function _windowname()
	hpupdate()
	coordsupdate()
	setWindowName(getHwnd(),sprintf("X: %d Z: %d Y: %d Dir1: %0.2f, Dir2: %0.2f, A: %0.2f", player.X, player.Z, player.Y, player.Dir1, player.Dir2, player.Angle))
end
registerTimer("setwindow", secondsToTimer(1), _windowname);


function main()
	local defaultState = nil;
	local wpName = nil;

	stateman = StateManager();
	for i = 2,#args do
		local foundpos = string.find(args[i], ":", 1, true);
		if foundpos then
			local var = string.sub(args[i], 1, foundpos-1);
			local val = string.sub(args[i], foundpos+1);
			if( var == "path" ) then
				--waypoint.waypointname = val
				wpName = val;
			end
			if( var == "state" ) then
				for k,v in pairs(events) do
					if string.lower(v.name) == string.lower(val) then 
						defaultState = v.func
					end
				end
			end
			if var == "profile" then
				val = string.find(val,"(.*).lua") or val
				local file = BASE_PATH .. "/profiles/" .. val .. ".lua";
				if( fileExists(file) ) then	
					addedprofile = include(BASE_PATH .. "/profiles/" .. val .. ".lua", true);
					for k,v in pairs(addedprofile) do
						profile[k] = v
					end
					player:constructor()
					updateall()
				else
					logger:log('info',"No such profile name %s", val)
				end	
			end
		elseif( args[i] == "coords" ) then
			unregisterTimer("setwindow");
			while(true) do
				updateall()
				if player.Heal > player.HP/player.MaxHP*100 then
					keyboardPress(key.VK_6)
				end	
				hpupdate()
				coordsupdate()
				local angle = math.atan2(-4294 - player.Z, -16379 - player.X) + math.pi;
				local anglediff = math.abs(player.Angle - angle);
				setWindowName(getHwnd(),sprintf("P.X: %d, P.Z: %d, P.Y: %d, Dir1: %0.2f, Dir2: %0.2f, PA: %0.2f, A: %0.2f", player.X, player.Z, player.Y, player.Dir1, player.Dir2, player.Angle, angle))
				yrest(100)
			end
		elseif( args[i] == "ftext" ) then
			unregisterTimer("setwindow");
			while(true) do
				statusupdate()
				setWindowName(getHwnd(),sprintf("Text: "..player.Ftext))
				yrest(100)
			end
		elseif ( args[i] == "com" ) then
			repeat
				yrest(1)
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
		elseif( args[i] == "devinfo" ) then
			-- Just print out some info that might be useful for developers.
			hpupdate()
			targetupdate()
			printf("Player info for \'%s\', HP: %d/%d, Target: 0x%X\n", player.Name, player.HP, player.MaxHP, player.TargetAll);
			printf("Player position: P.X: %d, P.Z: %d, P.Y: %d, Angle: %.2f\n", player.X, player.Z, player.Y, player.Angle );
			printf("Interaction: %s, ID: %d (0x%X)\n", player.Interaction, player.InteractionId, player.InteractionId);
			return;
		end
	end

	if( defaultState ) then
		stateman:pushState(defaultState);
	else
		stateman:pushState(WaypointState(wpName));
	end

	print("Version: "..version)
	print("Current state: ", stateman:getState().name);

	while(stateman.running) do
		updates()
		handleInput();			-- reactive it?
		stateman:handleEvents();
		stateman:run();
		yrest(1);
	 	if( os.difftime(os.time(),logger.lastMsgTime) > logger.repeatTimer+1 )	then
	 		logger:log('debug',"we are still alive here in main.lua at %s", os.date("%H:%M:%S") );
	 	end
	end
end
startMacro(main, true);