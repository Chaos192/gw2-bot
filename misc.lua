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
	elseif( _type == "ustring" ) then
		readfunc = memoryReadUString;
	elseif( _type == "intptr" ) then
		readfunc = memoryReadIntPtr;
		ptr = true;
	elseif( _type == "uintptr" ) then
		readfunc = memoryReadUIntPtr;
		ptr = true;
	elseif( _type == "byteptr" ) then
		readfunc = memoryReadBytePtr;
		ptr = true;
	elseif( _type == "floatptr" ) then
		readfunc = memoryReadFloatPtr;
		ptr = true;		
	else
		return nil;
	end

	for i = 1, 10 do
		showWarnings(false);
		if( ptr ) then
			val = readfunc(proc, address, offset);
		else
			val = readfunc(proc, address);
		end
		showWarnings(true);

		if( val == nil ) then
			local info = debug.getinfo(2);
			local name;
			if( info.name ) then
				name = info.name .. '()';
			else
				name = '<unknown>';
			end
			logger:log('debug',  "Error reading memory in %s from %s:%d", name, info.short_src, info.currentline or 0);
		end

		return val

	end

end	

function distance(x1, z1, y1, x2, z2, y2)
	if type(x1) == "table" and type(z1) == "table" then
        y2 = z1.Y or z1[3]
        z2 = z1.Z or z1[2]
        x2 = z1.X or z1[1]
        y1 = x1.Y or x1[3]
        z1 = x1.Z or x1[2]
        x1 = x1.X or x1[1]
    elseif z2 == nil and y2 == nil then -- assume x1,z1,x2,z2 values (2 dimensional)
		z2 = x2
		x2 = y1
		y1 = nil
	end

	if( x1 == nil or z1 == nil or x2 == nil or z2 == nil ) then
		error("Error: nil value passed to distance()", 2);
	end

	if y1 == nil or y2 == nil then -- 2 dimensional calculation
		return math.sqrt( (z2-z1)*(z2-z1) + (x2-x1)*(x2-x1) );
	else -- 3 dimensional calculation
		return math.sqrt( (z2-z1)*(z2-z1) + (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) );
	end
end

-- Checks if a variable is any of the types included.
-- Returns true if the variable is at least one type, otherwise false
-- EX: checkType(x, "string", "number")
function checkType(var, ...)
	local types = {...};

	for i,v in pairs(types) do
		if( type(v) ~= "string" ) then
			error(sprintf("Argument %d is an invalid type: string expected", i), 2);
		end

		if( type(var) == v ) then
			return true;
		end
	end

	return false;
end

function utf8ToAscii_umlauts(_str)

	-- convert one UTF8 character to his ASCII code
	-- key is the combined UTF8 code
	local function replaceUtf8( _str, _key )
		local tmp = database.utf8_ascii[_key];
		_str = string.gsub(_str, string.char(tmp.utf8_1, tmp.utf8_2), string.char(tmp.ascii) );
		return _str
	end

	_str = replaceUtf8(_str, 195164);		-- ä
	_str = replaceUtf8(_str, 195132);		-- Ä
	_str = replaceUtf8(_str, 195182);		-- ö
	_str = replaceUtf8(_str, 195150);		-- Ö
	_str = replaceUtf8(_str, 195188);		-- ü
	_str = replaceUtf8(_str, 195156);		-- Ü
	_str = replaceUtf8(_str, 195159);		-- ß
	return _str;
end

function convert_utf8_ascii( _str )

	-- local function to convert string (e.g. mob name / player name) from UTF-8 to ASCII
	local function convert_utf8_ascii_character( _str, _v )
		local found;
		_str, found = string.gsub(_str, string.char(_v.utf8_1, _v.utf8_2), string.char(_v.ascii) );
		return _str, found;
	end

	local found, found_all;
	found_all = 0;
	for i,v in pairs(database.utf8_ascii) do
--			_str, found = convert_utf8_ascii_character( _str, v.ascii  );	-- replace special characters
		_str, found = convert_utf8_ascii_character( _str, v  );	-- replace special characters
		found_all = found_all + found;									-- count replacements
	end

	if( found_all > 0) then
		return _str, true;
	else
		return _str, false;
	end
end