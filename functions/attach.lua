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

		if( val ) then i = 11; end; -- Get out of loop
	end

	if( val == nil ) then
		local info = debug.getinfo(2);
		local name;
		if( info.name ) then
			name = info.name .. '()';
		else
			name = '<unknown>';
		end
--		logger:log('debug',  "Error reading memory in %s from %s:%d", name, info.short_src, info.currentline or 0);
--	no logger available at the time of using that
		local msg = sprintf("Error reading memory in %s from %s:%d", name, info.short_src, info.currentline or 0);
		error(msg, 2)

	end

	return val

end	