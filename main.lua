include("classes/statemanager.lua")
include("addresses.lua")
include("config_default.lua")
include("config.lua")
include("classes/logger.lua")
include("classes/player.lua")

local subdir = getDirectory(getExecutionPath() .. "/classes/states/")
for i,v in pairs(subdir) do
	if string.find(v,".lua") then
		include("classes/states/"..v)
	end
end

local version = "rev 4"

local windowList = findWindowList("*","ArenaNet_Dx_Window_Class");
if( #windowList == 0 ) then
	print("You need to run GW2 first!");
	return 0;
end
function getWin()
	if( __WIN == nil ) then
  		__WIN = windowList[1]
	end

	return __WIN;
end	
function getProc()
	if( __PROC == nil or not windowValid(__WIN) ) then
		if( __PROC ) then closeProcess(__PROC) end;
		__PROC = openProcess( findProcessByWindow(getWin()) );
	end

	return __PROC;
end	
function memoryReadRepeat(_type, proc, address, offset)
	local readfunc;
	local ptr = false;
	local val;

	if( type(proc) ~= "userdata" ) then
		error("Invalid proc", 2);
	end

	if( type(address) ~= "number" ) then
		error("Invalid address", 2);
	end

	if( _type == "int" ) then
		readfunc = memoryReadInt;
	elseif( _type == "uint" ) then
		readfunc = memoryReadUInt;
	elseif( _type == "float" ) then
		readfunc = memoryReadFloat;
	elseif( _type == "byte" ) then
		readfunc = memoryReadByte;
	elseif( _type == "string" ) then
		readfunc = memoryReadString;
	elseif( _type == "intptr" ) then
		readfunc = memoryReadIntPtr;
		ptr = true;
	elseif( _type == "uintptr" ) then
		readfunc = memoryReadUIntPtr;
		ptr = true;
	elseif( _type == "byteptr" ) then
		readfunc = memoryReadBytePtr;
		ptr = true;

	else
		return nil;
	end

	for i = 1, 10 do
		if( ptr ) then
			val = readfunc(proc, address, offset);
		else
			val = readfunc(proc, address);
		end

		if( val ~= nil ) then
			return val;
		end
	end

end	

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
Player:constructor()
local function update()
	Player:update()
	if Player.Heal > Player.HP/Player.MaxHP*100 then
		stateman:pushEvent("Heal", "main");
	end
	if Player.InCombat then
		stateman:pushEvent("Combat","main");
	end
end
function _windowname()
	Player:update()
	setWindowName(getHwnd(),sprintf("X: %d Z: %d Y: %d Dir1: "..Player.Dir1.." Dir2: "..Player.Dir2,Player.X,Player.Z,Player.Y))
end
registerTimer("setwindow", secondsToTimer(1), _windowname);

function main()
	for i = 2,#args do
		if( args[i] == "coords" ) then
			while(true) do
				Player:update()
				setWindowName(getHwnd(),sprintf("X: %d Z: %d Y: %d Dir1: "..Player.Dir1.." Dir2: "..Player.Dir2,Player.X,Player.Z,Player.Y))
				yrest(10)
			end
		end
	end
	stateman = StateManager();
	stateman:pushState(FarmState());
	print("Version: "..version)
	print("Current state: ", stateman:getState().name);

	while(stateman.running) do
		update()
		handleInput();
		stateman:handleEvents();
		stateman:run();
		yrest(1);
	end
end
startMacro(main, true);