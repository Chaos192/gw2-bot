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
	playerhpbase = {
		pattern = string.char(
		0xFF, 0x68, 0x5a, 0x01),
		mask = "?xxx",
		offset = 0,
		startloc = 0x410000,
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
			error("Patch bytes = 0x90. Please restart the game before trying to run \"GW2\update\" again.")
		end

		printf(readBytesUpdateMsg, name, address, bytesString)
		addresses[name] = tmp
	end
end
findOffsets()
