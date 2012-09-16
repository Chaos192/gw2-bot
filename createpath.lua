BASE_PATH = getExecutionPath();
profile = include(BASE_PATH .. "/profiles/default.lua", true);
include("addresses.lua");
include("classes/player.lua");
local subdir = getDirectory(getExecutionPath() .. "/functions/")
for i,v in pairs(subdir) do
	if string.find(v,".lua") then
		include("functions/"..v)
	end
end
include("classes/target.lua");

player = Player();
target = Target();

include("classes/language.lua");
include("config_default.lua");
include("config.lua");
include("classes/logger.lua");

language = Language()


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
p_hp_type = "HARVEST";		-- type for harvest waypoints
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

	local openformat = "\t\<!-- #%3d -->{ X=%d, Z=%d, Y=%d, type=\"%s\"";
	local closeformat = "\},\n";

	file:write("return \{\n");
	local str = sprintf("<waypoints%s>\n", p_wp_gtype);	-- create first tag
	--file:write(str);					-- write first tag

	local hf_line, tag_open = "", false;
	for i,v in pairs(list) do
		if( v.wp_type == "WP" ) then -- Waypoint
			if( tag_open ) then hf_line = hf_line .. "" .. closeformat; end;
			hf_line = hf_line .. sprintf(openformat, i, v.X, v.Z, v.Y, p_wp_type, "");
			tag_open = true;
		elseif( v.wp_type == "HARVEST" ) then
			if( tag_open ) then hf_line = hf_line .. "" .. closeformat; end;
			hf_line = hf_line .. sprintf(openformat, i, v.X, v.Z, v.Y, p_hp_type, "");
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
		hf_line = hf_line .. "" .. closeformat;
	end

	file:write(hf_line);
	file:write("\n\}");

	file:close();

	wpList = {};	-- clear intenal table

end

updateall()
function main()

	local running = true;
	while(running) do

		local hf_x, hf_y, hf_wide, hf_high = windowRect( getWin());
		print( hf_wide, hf_high, hf_x, hf_y );	-- GW2 windows size
		
		printf(language:message('WPinsert') 	-- Insert new waypoint
			.. language:message('WPharvest') 	-- Insert new harvest waypoint
			.. language:message('WPsaveend') 	-- Save waypoints and quit
			.. language:message('WPcommand') 	-- Insert merchant command
			.. language:message('WPnpc')        -- Insert target/dialog NPC command
			.. language:message('WPchoice') 	-- Insert choiceOption command
			.. language:message('WPmouse')  	-- Insert Mouseclick Left command
			.. language:message('WPreset')   	-- Reset script
			.. language:message('WPsavenew')  	-- Save waypoints and restart
			.. language:message('WPcode')		-- Insert comment command
			.. language:message('WPobj'),		-- Insert comment command
			getKeyName(wpKey), getKeyName(harvKey), getKeyName(saveKey),
			getKeyName(merchantKey), getKeyName(targetNPCKey),
			getKeyName(choiceOptionKey), getKeyName(mouseClickKey),
			getKeyName(resetKey), getKeyName(restartKey),
			getKeyName(codeKey), getKeyName(targetObjKey) 
			);

		attach(getWin())
		print("GW2 waypoint creator")

		local hf_key_pressed, hf_key;
		while(true) do

			coordsupdate()
			local angle = math.atan2(-4294 - player.Z, -16379 - player.X) + math.pi;
			local anglediff = math.abs(player.Angle - angle);
			setWindowName(getHwnd(),sprintf("P.X: %d, P.Z: %d, P.Y: %d, Dir1: %0.2f, Dir2: %0.2f, PA: %0.2f, A: %0.2f", player.X, player.Z, player.Y, player.Dir1, player.Dir2, player.Angle, angle))
			yrest(100)

			hf_key_pressed = false;

			if( keyPressed(wpKey) ) then	-- normal waypoint key pressed
				hf_key_pressed = true;
				hf_key = "WP";
			end;
			if( keyPressed(harvKey) ) then
				hf_key_pressed = true;
				hf_key = "HARVEST";
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

				coordsupdate()
				print("updated")
				local tmp = {}, hf_type;
				tmp.X = player.X;
				tmp.Z = player.Z;
				tmp.Y = player.Y;
				hf_type = "";


				-- waypoint or harvest point key: create a waypoint/harvest waypoint
				if(	hf_key == "WP") then			-- normal waypoint
					tmp.wp_type = "WP";
					hf_type = "WP";
					--sprintf(language[511], #wpList+1) ; -- waypoint added
				elseif( hf_key == "HARVEST" ) then
					tmp.wp_type = "HARVEST";
					hf_type = "HARVEST";
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

				printf(language:message('WPcontinue'),getKeyName(saveKey));		-- Continue to next. Press %s to save and quit

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
