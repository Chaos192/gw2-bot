local windowList = findWindowList("Guild Wars 2");
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

--[[
	Required:
	pattern		The pattern, obviously.
	mask		...The mask?
	offset		Offset from the start of the pattern that the requested data exists.
	startloc	Where to start the search, in bytes

	Optional:
	searchlen	The length, in bytes, to continue searching (default: 0xA0000)
	adjustment	How many bytes to adjust the returned value forward or backward (default: 0)
	size		The length, in bytes, of the data (default: 4)
	comment		A string of text that will be appended in the output
]]

local updatePatterns =
{
	base = {
		pattern = string.char(
		0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x64, 0x8B, 0x0D, 0xFF, 0x00,
		0x00, 0x00, 0x8B, 0x14, 0x81, 0x8B, 0x82, 0xFF, 0x00, 0x00, 0x00, 0xC3),
		mask = "x????xxx?xxxxxxxx?xxxx",
		offset = 1,
		startloc = 0x630000,
	},
	statbase = {
		pattern = string.char(
		0x5F, 0x5E, 0x5D, 0xC2, 0x04, 0x00,
		0xCC,
		0xB8, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xC3, 0xCC, 0xCC, 0xCC, 0xCC),
		mask = "xxxxxxxx????xxxxx",
		offset = 8,
		startloc = 0xC00000,
		adjustment = 0x10,
	},
	playerbasecoords = {
		pattern = string.char(
		0x00, 0x00, 0x80, 0x00, 0x89, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0xC3, 0xCC, 
		0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC),
		mask = "xxxxxx????xxxxxxxxxxxx",
		offset = 6,
		startloc = 0x890000,
	},
	playerbasehp = {
		pattern = string.char(
		0xCC,
		0x56, 
		0x8b, 0xf1,
		0xc7, 0x06, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x04, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x08, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x0C, 0xFF, 0xFF, 0xFF, 0xFF,
		0x57, 
		0x33, 0xff,
		0x8d, 0x4e),
		mask = "xxxxxx????xxx????xxx????xxx",
		offset = 6,
		startloc = 0x470000,
	},	
	playerbaseui = {
		pattern = string.char(
		0xFF, 0xD2, 
		0xD9, 0x85, 0x78, 0xFF, 0xFF, 0xFF, 
		0xD8, 0x65, 0xCC, 
		0x8B, 0x15, 0xFF, 0xFF, 0xFF, 0xFF,
		0x56,
		0x56),
		mask = "xxxxxxxxxxxxx????xx",
		offset = 13,
		startloc = 0xAe4000,
	},
	playerName = {
		pattern = string.char(	
		0x53, 0x33, 0xDB, 0x33, 0xC0, 
		0x66, 0xA3, 0xFF, 0xFF, 0xFF, 0xFF,
		0x89, 0x1D,0xFF, 0xFF, 0xFF, 0xFF,
		0x89, 0x1D,0xFF, 0xFF, 0xFF, 0xFF,
		0x89, 0x1D,0xFF, 0xFF, 0xFF, 0xFF,
		0x89, 0x1D,0xFF, 0xFF, 0xFF, 0xFF),
		mask = "xxxxxxx????xx????xx????xx????xx????",
		offset = 7,
		startloc = 0x400F00,
	},	
	--[[FtextAddress = {
		pattern = string.char(	
		0xD9, 0x41, 0x08, 
		0xD8, 0x48, 0x08,
		0xDE, 0xC1,
		0xD9, 0x5D, 0x08,
		0xD9, 0x45, 0x08,
		0xD9, 0x05, 0xFF, 0xFF, 0xFF, 0xFF,
		0xDE, 0xD9),
		mask = "xx?xx?xxxx?xx?xx????xx",
		offset = 16,
		startloc = 0xBC5000,
		adjustment = -20
	},]]
	skillCDaddress = {
		pattern = string.char(
		0x5F, 0x5E, 0x5D,
		0xC2, 0x04, 0x00,
		0xCC,
		0xB8, 0xFF, 0xFF, 0xFF, 0xFF,
		0xC3, 
		0xCC, 0xCC, 0xCC, 0xCC, 0xCC),
		mask = "xxxxxxxx????xxxxxx",
		offset = 8,
		startloc = 0xC06000,
		adjustment = 0x10
	},	
}
addresses = include("addresses.lua", true);
print("Addresses:", addresses);
-- This function will attempt to automatically find the true addresses
-- from GW2, even if they have moved.
-- Only works on MicroMacro v1.0 or newer.
function findOffsets()
	-- Sort names so the output is in order
    local new_patterns = {}
	for n in pairs(updatePatterns) do
		table.insert(new_patterns, n)
	end
	table.sort(new_patterns)

    for __,name in ipairs(new_patterns) do
		local values = updatePatterns[name]

		local found = 0;
		local readFunc = nil;
		local pattern = values["pattern"];
		local mask = values["mask"];
		local offset = values["offset"];
		local startloc = values["startloc"];
		local searchlen = values["searchlen"] or 0xA00000;
		local adjustment = values["adjustment"] or 0;
		local size = values["size"] or 4;
		local comment = values["comment"] or "";

		found = findPatternInProcess(getProc(), pattern, mask, startloc, searchlen);
		if( found == 0 ) then
			error("Unable to find \'" .. name .. "\' in module.", 0);
		end

		if( size == 1 ) then
			readFunc = memoryReadUByte;
		elseif( size == 2 ) then
			readFunc = memoryReadUShort;
		elseif( size == 4 ) then
			readFunc = memoryReadUInt
		else -- default, assume 4 bytes
			readFunc = memoryReadUInt;
		end
		addresses[name] = readFunc(getProc(), found + offset) + adjustment;

		if name == "playerbasehp" then
			local hexval = string.format('%x',addresses[name])	
			local str = {} 
			for w in string.gmatch(hexval,".") do table.insert(str,w) end 
			num1 = tonumber("0x"..str[6]..str[7])
			num2 = tonumber("0x"..str[4]..str[5])
			num3 = tonumber("0x"..str[2]..str[3])
			num4 = tonumber("0x0"..str[1])
			local newpattern = string.char(num1,num2,num3,num4)
			found	= findPatternInProcess(getProc(), newpattern, "xxxx", 0x15A0000, searchlen);
			addresses[name] = found - 0x8
		end	
		
		local msg = sprintf("Patched addresses.%s\t (value: 0x%X, at: 0x%X)", name, addresses[name], found + offset);
		printf(msg .. "\n");
		logMessage(msg);

	end

	printf("\n");
	local function readBytesUpdate(name, address, number)
		local readBytesUpdateMsg = "Read bytes for %s at: 0x%X Bytes:%s\n"
		local bytesString = ""
		local tmp = {}
		for i = 0, number-1 do
			local tmpbyte = memoryReadUByte(getProc(),address + i)
			table.insert(tmp, tmpbyte)
			bytesString = bytesString ..string.format(" %02X", tmpbyte)
		end

		if tmp[1] == 0x90 then
			error("Patch bytes = 0x90. Please restart the game before trying to run \"GW2\update\" again.")
		end

		printf(readBytesUpdateMsg, name, address, bytesString)
		addresses[name] = tmp
	end
end

local function format_value(val)
	if( type(val) == "number" ) then
		return sprintf("0x%X", val);
	elseif( type(val) == "string" ) then
		return '"' .. string.gsub(val, '"', '\"') .. '"';
	elseif( type(val) == "nil" ) then
		return "nil";
	elseif( type(val) == "table" ) then
		local str = "{";
		local len = #val;
		for i,v in pairs(val) do
			str = str .. format_value(v);
			if( i < len ) then
				str = str .. ", ";
			end
		end
		str = str .. "}";
		return str;
	else
		return val;
	end
end

function rewriteAddresses()
	local filename = getExecutionPath() .. "/addresses.lua";
	local template_filename = getExecutionPath() .. "/addresses_template.tmpl";
	local template_f = io.open(template_filename, "r");
	local template;

	if( template_f ) then
		template = template_f:read("*a");
	end
	if( not template_f or not template ) then
		error(sprintf("Cannot read address template (%s). What did you do?", template_filename), 0);
	end

	getProc(); -- Just to make sure we open the process first

	printf("Scanning for updated addresses...\n");
	findOffsets();
	printf("Finished.\n");

	local addresses_new = {};
	for i,v in pairs(addresses) do
		table.insert(addresses_new, {index = i, value = v});
	end

	-- Sort alphabetically by index
	local function addressSort(tab1, tab2)
		if( tab1.index < tab2.index ) then
			return true;
		end

		return false;
	end
	table.sort(addresses_new, addressSort);

	addresses['playerDir1'] = addresses['playerbasecoords'] + 0x14;
	addresses['playerDir2'] = addresses['playerbasecoords'] + 0x18;
	addresses['playerX'] = addresses['playerbasecoords'] + 0x2C;
	addresses['playerZ'] = addresses['playerbasecoords'] + 0x30;
	addresses['playerY'] = addresses['playerbasecoords'] + 0x34;

	addresses['playerHPoffset'] = {0x150,0x8};
	addresses['playerMaxHPoffset'] = {0x150,0xC};
	addresses['playerKarmaoffset'] = {0x1B0, 0x4, 0x1B4};
	addresses['playerGoldoffset'] = {0x154, 0x50};
	addresses['playerInCombat'] = addresses['playerbasehp'] - 0x1C0;
	addresses['playerDowned'] = addresses['playerbasehp'] - 0x6D4;

	addresses['playerAccount'] = addresses['playerName'] + 0xD0;
	addresses['loadingbase'] = addresses['playerName'] + 0x14A8;
	addresses['loadingOffset'] = {0xC8, 0x4, 0x0, 0x3BC};

	--addresses['FtextOffset'] = {0x0, 0x94, 0x14, 0x22};

	addresses['Finteraction'] = addresses['playerbaseui'] + 0x60;
	addresses['TargetMob'] = addresses['playerbaseui'] + 0x78;
	addresses['TargetAll'] = addresses['playerbaseui'] + 0x90;
	addresses['mousewinX'] = addresses['playerbaseui'] + 0x98;
	addresses['mousewinZ'] = addresses['playerbaseui'] + 0x9C;
	addresses['mousepointX'] = addresses['playerbaseui'] + 0xB8;
	addresses['mousepointZ'] = addresses['playerbaseui'] + 0xBC;
	addresses['mousepointY'] = addresses['playerbaseui'] + 0xC0;
	addresses['XPbase'] = addresses['playerbaseui'] - 0x89C;
	addresses['xpOffset'] = {0x80, 0x120, 0x14, 0x4};
	addresses['xpnextlvlOffset'] = {0x80, 0x120, 0x14, 0xC};
	addresses['targetbaseAddress'] = addresses['playerbaseui'] + 0x182c;
	addresses['targetXoffset'] = {0x30, 0x58, 0x108};
	addresses['targetZoffset'] = {0x30, 0x58, 0x10c};
	addresses['targetYoffset'] = {0x30, 0x58, 0x110};
	addresses['moveForward'] = addresses['playerbaseui'] + 0x18f8;
	addresses['moveBackward'] = addresses['playerbaseui'] + 0x18fc;
	addresses['turnLeft'] = addresses['playerbaseui'] + 0x1908;
	addresses['turnRight'] = addresses['playerbaseui'] + 0x190c;
	addresses['FtextAddress'] = addresses['playerbaseui'] + 0x19d4;
	addresses['FtextOffset'] = {0x0, 0xC4, 0x22};
	addresses['FidOffset'] = {0x0, 0xC4, 0x8};
	
	addresses['actlvlOffset'] = 0x7C;
	addresses['adjlvlOffset'] = 0xA0;
	
	addresses['objectArray'] = addresses['playerbaseui'] + 0xFC;

	-- Attempts to replace an entry in the template.
	-- If successful, removes it from addresses.new
	local template_replace = function(str, index)
		if( addresses[index] ) then
			template = string.gsub(template, str, tostring(format_value(addresses[index])));
			addresses[index] = nil;
		end
	end

	-- Replace known template markers
	template_replace('__BASE__', 			'base');
	template_replace('__PLAYER_NAME__', 	'playerName');
	template_replace('__PLAYER_ACCOUNT__',	'playerAccount');
	template_replace('__LOADING_BASE__',	'loadingbase');
	template_replace('__LOADING_OFFSET__',	'loadingOffset');
	template_replace('__PLAYER_DIR_1__',	'playerDir1');
	template_replace('__PLAYER_DIR_2__',	'playerDir2');
	template_replace('__PLAYER_X__',		'playerX');
	template_replace('__PLAYER_Z__',		'playerZ');
	template_replace('__PLAYER_Y__',		'playerY');
	template_replace('__PLAYER_BASE_HP__',	'playerbasehp');
	template_replace('__PLAYER_HP_OFFSET__',	'playerHPoffset');
	template_replace('__PLAYER_MAX_HP_OFFSET__',	'playerMaxHPoffset');
	template_replace('__PLAYER_KARMA_OFFSET__',		'playerKarmaoffset');
	template_replace('__PLAYER_GOLD_OFFSET__',		'playerGoldoffset');
	template_replace('__PLAYER_COMBAT__',	'playerInCombat');
	template_replace('__PLAYER_DOWNED__',	'playerDowned');
	template_replace('__F_INTERACTION__',	'Finteraction');
	template_replace('__TARGET_MOB__',		'TargetMob');
	template_replace('__TARGET_ALL__',		'TargetAll');
	template_replace('__MOUSE_WIN_X__',		'mousewinX');
	template_replace('__MOUSE_WIN_Z__',		'mousewinZ');
	template_replace('__MOUSE_POINT_X__',	'mousepointX');
	template_replace('__MOUSE_POINT_Z__',	'mousepointZ');
	template_replace('__MOUSE_POINT_Y__',	'mousepointY');
	template_replace('__XP_BASE__',			'XPbase');
	template_replace('__XP_OFFSET__',		'xpOffset');
	template_replace('__XP_NEXT_LEVEL_OFFSET__',	'xpnextlvlOffset');
	template_replace('__TARGET_BASE__',		'targetbaseAddress');
	template_replace('__TARGET_X_OFFSET__',	'targetXoffset');
	template_replace('__TARGET_Z_OFFSET__',	'targetZoffset');
	template_replace('__TARGET_Y_OFFSET__',	'targetYoffset');
	template_replace('__MOVE_FORWARD__',	'moveForward');
	template_replace('__MOVE_BACKWARD__',	'moveBackward');
	template_replace('__TURN_LEFT__',		'turnLeft');
	template_replace('__TURN_RIGHT__',		'turnRight');
	template_replace('__F_TEXT__',			'FtextAddress');
	template_replace('__F_TEXT_OFFSET__',	'FtextOffset');
	template_replace('__SKILL_CD__',		'skillCDaddress');
	template_replace('__STAT_BASE__',		'statbase');
	template_replace('__ACT_LEVEL_OFFSET__',	'actlvlOffset');
	template_replace('__ADJ_LEVEL_OFFSET__',	'adjlvlOffset');
	template_replace('__OBJECT_ARRAY__',	'objectArray');

	-- Remove unnecessary garbage
	addresses['playerbasecoords'] = nil;

	-- Now add in any unlisted entries
	local additional_entries = "";
	for index,value in pairs(addresses) do
		additional_entries = additional_entries .. index .. " = " .. format_value(value) .. ",\n\t"
	end

	-- Trim whitespace from additional_entries
	additional_entries = string.trim(additional_entries);

	-- Now do the final template replace for additonal entries
	template = string.gsub(template, '__UNORGANIZED_ADDRESSES__', tostring(additional_entries));

	local file = io.open(filename, "w");
	file:write(template);
	file:close();


	-- Finally, reload our addresses (in case we needed anything from the addresses table)
	addresses = include("addresses.lua",true);

	--[[
		file:write(
		sprintf("-- Auto-generated by update.lua\n") ..
		"addresses = {\n"
	);

	for i,v in pairs(addresses_new) do
		local comment = "";
		if( updatePatterns[v.index] ) then
			local tmp = updatePatterns[v.index].comment;
			if( tmp ) then
				comment = "\t-- " .. tmp .. " ]";
			end
		end

			-- Index part
		if v.index ~= "playerbasecoords" and v.index ~= "playerbaseui" then
			file:write( sprintf("\t%s = ", v.index))

			-- Value part
			if type(v.value) == "table" then -- if it's a table of bytes
				file:write( sprintf("{"))
				for i = 1, #v.value do
					if i ~= 1 then file:write( sprintf(", ")) end
					file:write( sprintf("0x%02X", v.value[i]))
				end
				file:write( sprintf("},"))
			else                             -- if it's an address or offset
				file:write( sprintf("0x%X,", v.value))
			end
		end		
		
		
		--=== assumptions as offsets of other addresses ===--
		--=== also offsets for pointers ===--
		
		if v.index == "playerbasecoords" then
			file:write(sprintf("\tplayerDir1 = 0x%X,\n",v.value + 0x10))
			file:write(sprintf("\tplayerDir2 = 0x%X,\n", v.value + 0x14))
			file:write(sprintf("\tplayerX = 0x%X,\n", v.value + 0x28))
			file:write(sprintf("\tplayerZ = 0x%X,\n", v.value + 0x2C))
			file:write(sprintf("\tplayerY = 0x%X,\n",v.value + 0x30))
		end
		if v.index == "playerbasehp" then
			file:write("\n\tplayerHPoffset = {0x150,0x3C,0x10},\n")	
			file:write("\tplayerMaxHPoffset = {0x150,0x3C,0x14},\n")
			file:write("\tplayerKarmaoffset = {0x1B0, 0x4, 0x1B4},\n")
			file:write("\tplayerGoldoffset = {0x154, 0x50},\n")
			file:write(sprintf("\tplayerInCombat = 0x%X,\n",v.value - 0x1AC))
			file:write(sprintf("\tplayerDowned = 0x%X,\n",v.value - 0x6C0))
		end	
		if v.index == "playerName" then
			file:write(sprintf("\n\tplayerAccount = 0x%X,\n",v.value + 0xD0))
			file:write(sprintf("\tloadingbase = 0x%X,\n",v.value + 0x14A8))
			file:write("\tloadingOffset = {0xC8, 0x4, 0x0, 0x3BC},\n")
			
		end
		if v.index == "FtextAddress" then
			file:write("\n\tFtextOffset = {0x0, 0x94, 0x14, 0x22},\n")
		end
		if v.index == "playerbaseui" then
			file:write(sprintf("\tFinteraction = 0x%X,\n",v.value + 0x60))
			file:write(sprintf("\tTargetMob = 0x%X,\n", v.value + 0x78))
			file:write(sprintf("\tTargetAll = 0x%X,\n", v.value + 0x90))	
			file:write(sprintf("\tmousewinX = 0x%X,\n", v.value + 0x98))
			file:write(sprintf("\tmousewinZ = 0x%X,\n", v.value + 0x9C))
			file:write(sprintf("\tmousepointX = 0x%X,\n", v.value + 0xB8))
			file:write(sprintf("\tmousepointZ = 0x%X,\n", v.value + 0xBC))
			file:write(sprintf("\tmousepointY = 0x%X,\n\n", v.value + 0xC0))
			--file:write(sprintf("\tmonthxpcountbase = 0x%X,\n", v.value + 0xFC))
			--file:write("\tmonthxpcountoffset = {0x3C, 0x284, 0x1E4, 0x5C, 0x34},\n\n")
			file:write(sprintf("\n\tXPbase = 0x%X,\n", v.value - 0x89C))
			file:write("\txpOffset = {0x80, 0x120, 0x14, 0x4},\n")
			file:write("\txpnextlvlOffset = {0x80, 0x120, 0x14, 0xC},\n\n")	
			
			file:write(sprintf("\ttargetbaseAddress = 0x%X,\n", v.value + 0x181C))
			file:write("\ttargetXoffset = {0x30, 0x5C, 0x110},\n")
			file:write("\ttargetZoffset = {0x30, 0x5C, 0x114},\n")
			file:write("\ttargetYoffset = {0x30, 0x5C, 0x118},\n")

			file:write(sprintf("\n\tmoveForward = 0x%X,\n", v.value + 0x18E8))
			file:write(sprintf("\tmoveBackward = 0x%X,\n", v.value + 0x18EC))			
			file:write(sprintf("\tturnLeft = 0x%X,\n", v.value + 0x18F8))
			file:write(sprintf("\tturnRight = 0x%X,\n", v.value + 0x18FC))
			
			file:write(sprintf("\n\tFtextAddress = 0x%X,\n", v.value + 0x19C4))
			file:write("\tFtextOffset = {0x0, 0xC4, 0x22},\n")
		
		
		end
		
		if v.index == "statbase" then
			file:write("\n\tactlvlOffset = 0x7C,\n")
			file:write("\tadjlvlOffset = 0xA0,\n")

		end
		-- Comment part
		file:write( sprintf("%s\n", comment) );
	end
	
	file:write("}\n");

	file:close();
]]
end
rewriteAddresses();

--=== Remove this before public release ===--
cprintf(cli.lightblue, "\n\n\nPrint test for addresses, remove before public release.\n")
BASE_PATH = getExecutionPath();
profile = include(BASE_PATH .. "/profiles/default.lua", true);
include("classes/language.lua");
include("classes/statemanager.lua");
addresses = include("addresses.lua",true);
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
language = Language();
player = Player();
target = Target();
updateall()

print("name: "..player.Name)
print("Karma: "..player.Karma)
print("Gold: "..player.Gold)
print("Level: "..player.actlvl)
print("Adjusted Level: "..player.adjlvl)
print("HP: "..player.HP)
print("MaxHP: "..player.MaxHP)
print("XP: "..player.XP)
print("XP next lvl: "..player.XPnextlvl)
print("X: "..player.X)
print("Z: "..player.Z)
print("Y: "..player.Y)
print("Dir1: "..player.Dir1)
print("Dir2: "..player.Dir2)
printf("TargetMob: %x\n",player.TargetMob)
printf("TargetAll: %x\n",player.TargetAll)
printf("Loot: ") print(player.Loot)
printf("Interaction: ") print(player.Interaction)
printf("InCombat: ") print(player.InCombat)
printf("Downed: ") print(player.Downed)
printf("Loading Screen: ") print(player.Loading)
print("target X: "..target.TargetX)
print("target Z: "..target.TargetZ)
print("target Y: "..target.TargetY)
--print("Monthly Ach XP: "..player.monthlyXP)
printf("F ID: %x\n",player.Fid)
print("F text: "..player.Ftext)
