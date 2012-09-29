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

-- print values also with nil/false/true
function debug_value(_v, _comment)

-- is there a way to get the name of the field, that is giving the value to an function argument?
-- so one could print the fieldname automaticly

	local hf_value = "";

	if(_v == true) then
		hf_value = "<true>";
	elseif(_v == false) then
		hf_value = "<false>";
	elseif(_v == nil) then
		hf_value  = "<nil>";
	elseif( type(_v) == "table" ) then
		hf_value  = "<table>";
	else
		hf_value = _v
	end
	if not _comment then
		_comment = ""
	end
	printf("v=%s (%s)\n", hf_value, _comment);
end

-- set mousepointer to the player in the middle of the screen
-- usefull for using ground skills
-- _interval: only do it again after x seconds
function setMousepointerToMiddle(_interval)
	local timer = _interval or 10

	detach(); -- Remove attach bindings

	if not timerMousepointerSet then
		timerMousepointerSet = 0	-- if never done we do it now
	end

	if os.difftime(os.time(),timerMousepointerSet) > timer then
		local hf_x, hf_y, hf_wide, hf_high = windowRect( getWin());
		mouseSet(hf_wide/2, hf_high/2+60);
		timerMousepointerSet = os.time()

	end
	attach(getWin()); -- Re-attach bindings

end

function setSpeed(_speed)
	if not SETTINGS['speed'] then return; end
	
	local timer = 500
	local proc = getProc()
	local speed = _speed or SETTINGS['speed'] 	-- 9.1 is standard speed

	if not timerLastSpeedSet then
		timerLastSpeedSet = getTime()	-- if never done we do it now
	end

	if( deltaTime(getTime(), timerLastSpeedSet) > 500 ) and
	   memoryReadRepeat("floatptr", proc, addresses.playerbasehp, {0x44,0x1c,0x5c,0x114}) ~= speed then
		memoryWriteFloatPtr(proc,addresses.playerbasehp, {0x44,0x1c,0x5c,0x114},speed)
		timerLastSpeedSet = getTime()
	end
	
end
