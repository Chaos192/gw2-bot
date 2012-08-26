include("addresses.lua");
include("/classes/player.lua");
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
-- ********************************************************************
-- Change the parameters below to your need                           *
-- ********************************************************************
-- if you want to create waypoint files with special waypoint types
-- like type=TRAVEL, than you can change the global variables
-- below to your need, see the following example
-- p_wp_gtype = " type=\"TRAVEL\"";	-- global type for whole file
-- p_wp_type = " type=\"TRAVEL\"";	-- type for normal waypoints
-- p_hp_type = " type=\"TRAVEL\"";	-- type for harvest waypoints
p_wp_gtype = "";	-- global type for whole file: e.g. TRAVEL
p_wp_type = "";		-- type for normal waypoints
p_hp_type = "";		-- type for harvest waypoints
p_harvest_command = "player:harvest();";
p_merchant_command = "player:merchant(\"%s\");";
p_targetNPC_command = "player:target_NPC(\"%s\");";
p_targetObj_command = "player:target_Object(\"%s\");";
p_choiceOption_command = "sendMacro(\"ChoiceOption(%d);\");";
p_mouseClickL_command = "player:mouseclickL(%d, %d, %d, %d);";
-- ********************************************************************
-- End of Change parameter changes                                    *
-- ********************************************************************


setStartKey(key.VK_F5);
setStopKey(key.VK_F6);

wpKey = key.VK_NUMPAD1;			-- insert a movement point
harvKey = key.VK_NUMPAD2;		-- insert a harvest point
saveKey = key.VK_NUMPAD3;		-- save the waypoints
merchantKey = key.VK_NUMPAD4;	-- target merchant, repair and buy stuff
targetNPCKey = key.VK_NUMPAD5;	-- target NPC and open dialog waypoint
choiceOptionKey = key.VK_NUMPAD6; 	-- insert choiceOption
mouseClickKey = key.VK_NUMPAD7; -- Save MouseClick
restartKey = key.VK_NUMPAD9;	-- restart waypoints script
resetKey = key.VK_NUMPAD8;	-- restart waypoints script and discard changes
codeKey = key.VK_NUMPAD0;		-- add comment to last WP.
targetObjKey = key.VK_DECIMAL;	-- target an object and action it.


-- read arguments / forced profile perhaps

local wpList = {};

attach(getWin());

function saveWaypoints(list)
	keyboardBufferClear();
	io.stdin:flush();
	print("What do you want to name your path")
	filename = getExecutionPath() .. "/waypoints/" .. io.stdin:read() .. ".xml";

	file, err = io.open(filename, "w");
	if( not file ) then
		error(err, 0);
	end

	local openformat = "\t<!-- #%3d --><waypoint x=\"%d\" z=\"%d\" y=\"%d\"%s>%s";
	local closeformat = "</waypoint>\n";

	file:write("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
	local str = sprintf("<waypoints%s>\n", p_wp_gtype);	-- create first tag
	file:write(str);					-- write first tag

	local hf_line, tag_open = "", false;
	for i,v in pairs(list) do
		if( v.wp_type == "WP" ) then -- Waypoint
			if( tag_open ) then hf_line = hf_line .. "\t" .. closeformat; end;
			hf_line = hf_line .. sprintf(openformat, i, v.X, v.Z, v.Y, p_wp_type, "");
			tag_open = true;
		elseif( v.wp_type == "MC" ) then -- Mouse click (left)
			if( tag_open ) then
				hf_line = hf_line .. "\t\t" .. sprintf(p_mouseClickL_command, v.mx, v.my, v.wide, v.high) .. "\n";
			else
				hf_line = hf_line .. sprintf(openformat, i, v.X, v.Z, v.Y, p_wp_type,
				"\n\t\t" .. sprintf(p_mouseClickL_command, v.mx, v.my, v.wide, v.high) ) .. "\n";
				tag_open = true;
			end
		elseif( v.wp_type == "COD" ) then -- Code
			if( tag_open ) then
				hf_line = hf_line .. "\t\t" .. v.com .. "\n";
			else
				hf_line = hf_line .. sprintf(openformat, i, v.X, v.Z, v.Y, p_wp_type,
				"\n\t\t" .. v.com ) .. "\n";
				tag_open = true;
			end
		end
	end

	-- If we left a tag open, close it.
	if( tag_open ) then
		hf_line = hf_line .. "\t" .. closeformat;
	end

	file:write(hf_line);
	file:write("</waypoints>");

	file:close();

	wpList = {};	-- clear intenal table

end

Player:update()
function main()

	local running = true;
	while(running) do

		local hf_x, hf_y, hf_wide, hf_high = windowRect( getWin());
		print( hf_wide, hf_high, hf_x, hf_y );	-- RoM windows size
		
		--[[printf(language[502]			-- Insert new waypoint
			.. language[503]		-- Insert new harvest waypoint
			.. language[505]		-- Save waypoints and quit
			.. language[509]		-- Insert merchant command
			.. language[504]		-- Insert target/dialog NPC command
			.. language[517]		-- Insert choiceOption command
			.. language[510]		-- Insert Mouseclick Left command
			.. language[518]		-- Reset script
			.. language[506]		-- Save waypoints and restart
			.. language[519]		-- Insert comment command
			.. language[522],		-- Insert comment command
			getKeyName(wpKey), getKeyName(harvKey), getKeyName(saveKey),
			getKeyName(merchantKey), getKeyName(targetNPCKey),
			getKeyName(choiceOptionKey), getKeyName(mouseClickKey),
			getKeyName(resetKey), getKeyName(restartKey),
			getKeyName(codeKey), getKeyName(targetObjKey));]]

		attach(getWin())
		print("RoM waypoint creator")

		local hf_key_pressed, hf_key;
		while(true) do

			hf_key_pressed = false;

			if( keyPressed(wpKey) ) then	-- normal waypoint key pressed
				hf_key_pressed = true;
				hf_key = "WP";
			end;
			if( keyPressed(saveKey) ) then	-- save key pressed
				hf_key_pressed = true;
				hf_key = "SAVE";
			end;
			if( keyPressed(codeKey) ) then	-- choice option key pressed
				hf_key_pressed = true;
				hf_key = "COD";
			end;
			if( keyPressed(mouseClickKey) ) then	-- target MouseClick key pressed
				hf_key_pressed = true;
				hf_key = "MC";
			end;
			if( keyPressed(restartKey) ) then	-- restart key pressed
				hf_key_pressed = true;
				hf_key = "RESTART";
			end;
			if( keyPressed(resetKey) ) then	-- reset key pressed
				hf_key_pressed = true;
				hf_key = "RESET";
			end;
			if( hf_key_pressed == false and 	-- key released, do the work
				hf_key ) then					-- and key not empty

				-- SAVE Key: save waypoint file and exit
				if( hf_key == "SAVE" ) then
					saveWaypoints(wpList);
					hf_key = " ";	-- clear last pressed key
					running = false;
					break;
				end;

				if( hf_key == "RESET" ) then
					clearScreen();
					wpList = {}; -- DON'T save clear table
					hf_key = " ";	-- clear last pressed key
					running = true; -- restart
					break;
				end;

				Player:update()
				
				local tmp = {}, hf_type;
				tmp.X = Player.X;
				tmp.Z = Player.Z;
				tmp.Y = Player.Y;
				hf_type = "";


				-- waypoint or harvest point key: create a waypoint/harvest waypoint
				if(	hf_key == "WP") then			-- normal waypoint
					tmp.wp_type = "WP";
					hf_type = "WP";
					--sprintf(language[511], #wpList+1) ; -- waypoint added
				elseif(	hf_key == "COD") then			-- enter code
					tmp.wp_type = "COD";

					-- ask for option number
					keyboardBufferClear();
					io.stdin:flush();
					--cprintf(cli.green, language[520]);	-- add code
					tmp.com = io.stdin:read();
					hf_type = tmp.com;
					--sprintf(language[521], tmp.com ) ; -- code
				elseif( hf_key == "MC" ) then 	-- is's a mouseclick?
					tmp.wp_type = "MC";			-- it is a mouseclick
					local x, y = mouseGetPos();
					local wx, wy, hf_wide, hf_high = windowRect(getWin());
					tmp.wide = hf_wide;
					tmp.high = hf_high;
			        tmp.mx = x - wx;
					tmp.my = y - wy;
					hf_type = sprintf("mouseclick %d,%d (%dx%d)", tmp.mx, tmp.my, tmp.wide, tmp.high );
					print(tmp.mx, tmp.my, tmp.wide, tmp.high ); -- Mouseclick
				end


				print("Continue to next. Press %s to save and quit",getKeyName(saveKey))

				table.insert(wpList, tmp);

				if( hf_key == "RESTART" ) then
					saveWaypoints(wpList);
					hf_key = " ";	-- clear last pressed key
					running = true; -- restart
					break;
				end;


				hf_key = nil;	-- clear last pressed key
			end;

			yrest(10);
		end -- End of: while(true)
	end -- End of: while(running)
end

startMacro(main, true);
