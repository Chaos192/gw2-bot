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
	--[[base = {
		pattern = string.char(
		0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x64, 0x8B, 0x0D, 0x2C, 0x00,
		0x00, 0x00, 0x8B, 0x14, 0x81, 0x8B, 0x82, 0xFF, 0x00, 0x00, 0x00, 0xC3),
		mask = "x????xxxxxxxxxxxx?xxxx",
		offset = 1,
		startloc = 0x880000,
	},]]
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
		0x56, 
		0x8b, 0xf1,
		0xc7, 0x06, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x04, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x08, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xc7, 0x46, 0x0C, 0xFF, 0xFF, 0xFF, 0xFF,
		0x57, 
		0x33, 0xff,
		0x8d, 0x4e),
		mask = "xxxxx????xxx????xxx????xxx",
		offset = 5,
		startloc = 0x479000,
	},	
	playerbaseui = {
		pattern = string.char(	
		0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 
		0xB8, 0x60, 0xC1, 0x67, 0x01, 
		0xC3, 
		0xCC, 0xCC, 0xCC, 0xCC, 0xCC),
		mask = "xxxxxx????xxxxxx",
		offset = 6,
		startloc = 0xACC000,
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
		startloc = 0x403F00,
	},	
}
addresses = {}
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

function rewriteAddresses()
	local filename = getExecutionPath() .. "/addresses.lua";
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

	local file = io.open(filename, "w");

	file:write(
		sprintf("-- Auto-generated by update.lua\n") ..
		"addresses = {\n"
	);

	for i,v in pairs(addresses_new) do
		local comment = "";
		if( updatePatterns[v.index] ) then
			local tmp = updatePatterns[v.index].comment;
			if( tmp ) then
				comment = "\t--[[ " .. tmp .. " ]]";
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
		
		if v.index == "playerbasecoords" then
			file:write(sprintf("\tplayerDir1 = 0x%X,\n",v.value + 0x1C))
			file:write(sprintf("\tplayerDir2 = 0x%X,\n", v.value + 0x20))
			file:write(sprintf("\tplayerX = 0x%X,\n", v.value + 0x28))
			file:write(sprintf("\tplayerZ = 0x%X,\n", v.value + 0x2C))
			file:write(sprintf("\tplayerY = 0x%X,\n",v.value + 0x30))
		end
		if v.index == "playerbasehp" then
			file:write("\n\tplayerHPoffset = {0x150,0x3C,0x10},\n")	
			file:write("\tplayerMaxHPoffset = {0x150,0x3C,0x14},\n")
			file:write("\tplayerKarmaoffset = {0x1B0, 0x4, 0x1B4},\n")
			file:write("\tplayerGoldoffset = {0x154, 0x50},\n")
		end	
		if v.index == "playerName" then
			file:write(sprintf("\n\tplayerAccount = 0x%X,\n",v.value + 0xD0))
		end
		if v.index == "playerbaseui" then
			file:write(sprintf("\tFinteraction = 0x%X,\n",v.value + 0x60))
			file:write(sprintf("\tTargetMob = 0x%X,\n", v.value + 0x78))
			file:write(sprintf("\tTargetAll = 0x%X,\n", v.value + 0x90))	
			file:write(sprintf("\tmousewinX = 0x%X,\n", v.value + 0x98))
			file:write(sprintf("\tmousewinZ = 0x%X,\n", v.value + 0x9C))
			file:write(sprintf("\tmousepointX = 0x%X,\n", v.value + 0xB8))
			file:write(sprintf("\tmousepointZ = 0x%X,\n", v.value + 0xBC))
			file:write(sprintf("\tmousepointY = 0x%X,\n", v.value + 0xC0))			
		end
		
		-- Comment part
		file:write( sprintf("%s\n", comment) );
	end

	file:write("\tplayerInCombat = 0x15AC710,\n")
	
	file:write("}\n");

	file:close();

end
rewriteAddresses();
--[[in combat 15A5718 updater at 11225680
	updater 167b160 at acc210
 	file:write("\tFinteraction = 0x0167B1C0\n") 	+0x60
	file:write("\tTargetMob = 0x167B1D8,\n")		+0x78
	file:write("\tTargetAll = 0x167B1F0,\n")		+0x90	
	file:write("\tmousewinX = 0x167B1F8,\n")		+0x98
	file:write("\tmousewinZ = 0x167B1FC,\n")		+0x9C
	file:write("\tmousepointX = 0x0167B218,\n")		+0xB8
	file:write("\tmousepointZ = 0x0167B21C,\n")		+0xBC
	file:write("\tmousepointY = 0x0167B220,\n")		+0xC0
	]]