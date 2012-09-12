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