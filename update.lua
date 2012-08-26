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
	playercoords = {
		pattern = string.char(
		0x00, 0x00, 0x80, 0x00, 0x89, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0xC3, 0xCC, 
		0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC),
		mask = "xxxxxx????xxxxxxxxxxxx",
		offset = 6,
		startloc = 0x890000,
	},
}
addresses = {}
-- This function will attempt to automatically find the true addresses
-- from RoM, even if they have moved.
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
			error("Patch bytes = 0x90. Please restart the game before trying to run \"rom\update\" again.")
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
		if v.index == "playercoords" then
			file:write("\n\tplayerDir1 = 0x1C,\n")
			file:write("\tplayerDir2 = 0x20,\n")	
			file:write("\tplayerX = 0x28,\n")
			file:write("\tplayerZ = 0x2C,\n")
			file:write("\tplayerY = 0x30,\n")
		end
		
		-- Comment part
		file:write( sprintf("%s\n", comment) );
	end

	
	file:write("\tplayerbasehp = 0x15a48b0, \n\tplayerHPoffset = {0x150,0x3C,0x10},\n")
	file:write("\tplayerMaxHPoffset = {0x150,0x3C,0x14},\n\tplayerInCombat = 0x15A4718,\n")
	file:write("\tFinteraction = 0x1674160,\n\tlootwindow = 0x16732FC,\n")
	file:write("\tTargetMob = 0x1674178,\n\tTargetAll = 0x1674184,\n")
	file:write("\tTargetunk = 0x1674190,\n")	
	
	
	file:write("}\n");

	file:close();

end
rewriteAddresses();
