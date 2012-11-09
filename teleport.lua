--=== V 1.0 ===--

include("classes/statemanager.lua");
include("addresses.lua");
include("functions/attach.lua")

attach(getWin());

local proc = getProc()
local coords = {}
local syncskill = key.VK_4
local syncskillcd = 10
local skill

function getcoords()
	local Y,Z,X
	Y = memoryReadFloatPtr( proc, addresses.playerbasehp,addresses.playerVisY)
	Z = memoryReadFloatPtr( proc, addresses.playerbasehp,addresses.playerVisZ)
	X = memoryReadFloatPtr( proc, addresses.playerbasehp,addresses.playerVisX)
	return X,Z,Y
end

function teleport(X,Z,Y)
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerVisY, Y)
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerServY, Y)	
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerVisX, X)
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerServX, X)	
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerVisZ, Z)
	memoryWriteFloatPtr( proc, addresses.playerbasehp,addresses.playerServZ, Z)
	yrest(1000)
	keyboardPress(syncskill)
end

	local function list_coords_files()

		local hf_counter = 0;
		local pathlist = { }

		local function read_subdirectory(_folder)
			local subdir = getDirectory(getExecutionPath() .. "/coords/".._folder);
			if( not subdir) then return; end

			for i,v in pairs(subdir) do
				if( string.find (v,".lua",1,true) ) then
					hf_counter = hf_counter + 1;
						pathlist[hf_counter] = { };
						pathlist[hf_counter].folder = _folder;
						pathlist[hf_counter].filename = v;
				end
			end

		end		-- end of: local function read_subdirectory(_folder)


		local function concat_filename(_i, _folder, _filename)

			local hf_newname;
			local hf_folder = "";
			local hf_dots = "";
			local hf_slash = "";

			if( _folder  and  string.len(_folder) > 8 )  then
				hf_folder = string.sub(_folder, 1, 6);
				hf_dots = "..";
				hf_slash = "/";
			elseif( _folder  and  string.len(_folder) > 0 )  then
				hf_folder = _folder;
				hf_slash = "/";
			end

			hf_newname = sprintf("%s%s%s%s",
			  hf_folder,
			  hf_dots,
			  hf_slash,
			  _filename);

			hf_nr = sprintf("%3d:", _i);

			return hf_nr, hf_newname;

		end

		-- choose a path from the coords folder
		local dir = getDirectory(getExecutionPath() .. "/coords/")

		cprintf(cli.green, "coords files in %s\n", getExecutionPath().. "/coords/");	-- coords files in %s


		-- copy table dir to table pathlist
		-- select only lua files
		for i,v in pairs(dir) do

			-- no . means perhaps folder
			if( not string.find (v,".",1,true) ) then
				read_subdirectory(v);

			-- only list files with extension .lua
			elseif( string.find (v,".lua",1,true) ) then
				hf_counter = hf_counter + 1;
				pathlist[hf_counter] = { };
				pathlist[hf_counter].filename = v;
			end
		end

		local inc = math.ceil(#pathlist/3);
		for i = 1, inc do
			local column1 = ""; local column2 = ""; local column3 = "";
			local col1nr = ""; local col2nr = ""; local col3nr = "";

			col1nr, column1 = concat_filename(i, pathlist[i].folder, pathlist[i].filename)

			if ( (i + inc) <= #pathlist ) then
				col2nr, column2 = concat_filename(i+inc, pathlist[i+inc].folder, pathlist[i+inc].filename);
			end
			if ( (i+inc*2) <= #pathlist ) then
				col3nr, column3 = concat_filename(i+inc*2, pathlist[i+inc*2].folder, pathlist[i+inc*2].filename);
			end

			cprintf(cli.green,"%s %s %s %s %s %s\n",
				col1nr,
				string.sub(column1.."                    ", 1, 21),
				col2nr,
				string.sub(column2.."                    ", 1, 21),
				col3nr,
				string.sub(column3.."                    ", 1, 20) );

		end

		-- ask for pathname to choose
		keyboardBufferClear();
		io.stdin:flush();
		cprintf(cli.green, "Enter the number of the coords file-->", getKeyName(_G.key.VK_ENTER) );	-- Enter the number of the path
		local hf_choose_path_nr = tonumber(io.stdin:read() );
		if( hf_choose_path_nr and
			hf_choose_path_nr >= 0 and
			hf_choose_path_nr <= #pathlist ) then
			printf("You chose %s\n", hf_choose_path_nr );	-- You choose %s\n
			if( pathlist[hf_choose_path_nr].folder ) then
				wp_to_load = "coords/"..pathlist[hf_choose_path_nr].folder.."/"..pathlist[hf_choose_path_nr].filename;
			else
				wp_to_load = "coords/"..pathlist[hf_choose_path_nr].filename;
			end

			return wp_to_load;
		else
			cprintf(cli.yellow, "Invalid selection");	-- Wrong selection
			yrest(3000);
			return false;
		end

	end



function main()
	local function skill()
		printf("Please choose the skill number for syncing\n-->")
		keyboardBufferClear();
		io.stdin:flush();
		skill = io.stdin:read();
	end
	skill()
	--=== couldn't think of easier way to do it ===--
	if 	skill == "1" then syncskill = key.VK_1 
		elseif 	skill == "2" then syncskill = key.VK_2 
		elseif 	skill == "3" then syncskill = key.VK_3 
		elseif 	skill == "4" then syncskill = key.VK_4
		elseif 	skill == "5" then syncskill = key.VK_5 
		elseif 	skill == "6" then syncskill = key.VK_6 
		elseif 	skill == "7" then syncskill = key.VK_7 
		elseif 	skill == "8" then syncskill = key.VK_8 
		elseif 	skill == "9" then syncskill = key.VK_9 
		elseif 	skill == "0" then syncskill = key.VK_0 
		else 
		print("please only use a number 0-9")
		skill()
	end	
	local function cd()
		printf("Please state the cooldown for syncing skill in seconds\n-->")
		keyboardBufferClear();
		io.stdin:flush();
		syncskillcd = io.stdin:read();
	end
	cd()
	
	syncskillcd = tonumber(syncskillcd)
	if type(syncskillcd) ~= "number" then 
		print("Please only type a number") 
		cd()
	end

	print("Numpad 1: Add current coords, no name")
	print("Numpad 2: Add current coords, with name")
	print("Numpad 3: Print current saved coords")
	print("Numpad 4: Teleport")
	print("Numpad 5: Load coords from file")
	print("Numpad 6: Save current coords to file")
	print("Numpad 7: Auto teleport through all coords")
	print("Numpad 8: Clear coords table")
	print("Numpad 9: Exit")
	print("Numpad 0: Remove coords from table")
	
	local hack_key_pressed, hack_key;
	while(true) do
		hack_key_pressed = false;

		if( keyPressed(key.VK_NUMPAD0) ) then
			hack_key_pressed = true;
			hack_key = "Remove";
		end
		if( keyPressed(key.VK_NUMPAD1) ) then
			hack_key_pressed = true;
			hack_key = "SaveNN";
		end
		if( keyPressed(key.VK_NUMPAD2) ) then
			hack_key_pressed = true;
			hack_key = "SaveWN";
		end		
		if( keyPressed(key.VK_NUMPAD3) ) then
			hack_key_pressed = true;
			hack_key = "Print";
		end		
		if( keyPressed(key.VK_NUMPAD4) ) then
			hack_key_pressed = true;
			hack_key = "Tele";
		end	
		if( keyPressed(key.VK_NUMPAD5) ) then
			hack_key_pressed = true;
			hack_key = "Load";
		end
		if( keyPressed(key.VK_NUMPAD6) ) then
			hack_key_pressed = true;
			hack_key = "Savefile";
		end
		if( keyPressed(key.VK_NUMPAD7) ) then
			hack_key_pressed = true;
			hack_key = "autotele";
		end
		if( keyPressed(key.VK_NUMPAD8) ) then
			hack_key_pressed = true;
			hack_key = "clear";
		end
		if( keyPressed(key.VK_NUMPAD9) ) then
			hack_key_pressed = true;
			hack_key = "Exit";
		end
		
		
		--=== Ok do stuff here ===--
		if( hack_key_pressed == false and hack_key ) then
		
			-- key 9 Exit
			if hack_key == "Exit" then break end
			
			-- key 8 Clear coords table
			if hack_key == "clear" then 
				coords = {} 
			end
			
			-- key 7 Auto teleport through all coords
			if hack_key == "autotele" then
				print("Starting autotele")
				for k,v in ipairs(coords) do
					teleport(v.X, v.Z, v.Y)
					yrest((syncskillcd+1)*1000)
				end
			end
			
			-- key 6 Save current coords to file
			if hack_key == "Savefile" then
				printf("Please choose the filename\n-->")
				keyboardBufferClear();
				io.stdin:flush();
				local _filename = io.stdin:read();
				local fileme = getExecutionPath() .. "/coords/".._filename..".lua";
				local file = io.open(fileme, "w");
				file:write("-- Auto-generated by teleport.lua\n return {\n")
				for k,v in ipairs(coords) do
					file:write("{ Name =\""..v.Name.."\", X = "..v.X..", Z = "..v.Z..", Y = "..v.Y.."},\n")
				end
				file:write("}")
				file:close();
			end
			
			-- key 5 Load coords from file
			if hack_key == "Load" then
				_filename = list_coords_files()
				filecoords = include(_filename,true)
				for k,v in ipairs(filecoords) do
					table.insert(coords,v)
				end
			end
			
			-- key 4 Teleport
			if hack_key == "Tele" then
				table.print(coords)
				printf("Please choose the number to teleport to\n-->")
				keyboardBufferClear();
				io.stdin:flush();
				local coordnum = io.stdin:read();
				coordnum = tonumber(coordnum)
				teleport(coords[coordnum].X,coords[coordnum].Z,coords[coordnum].Y)
			end
			
			-- key 3 Print current saved coords
			if hack_key == "Print" then
				table.print(coords)
			end
			
			-- key 2 Add current coords, with name
			if hack_key == "SaveWN" then
				printf("Please type the name for these coords\n-->")
				keyboardBufferClear();
				io.stdin:flush();
				local name = io.stdin:read();
				_x , _z, _y = getcoords()
				table.insert(coords,{Name = name, X=_x, Z=_z, Y=_y})
			end
			
			-- key 1 Add current coords, no name
			if hack_key == "SaveNN" then
				_x , _z, _y = getcoords()
				table.insert(coords,{Name = "", X=_x, Z=_z,Y=_y})
				print("Coords added with no name")
			end
			
			-- key 0 Remove coords
			if hack_key == "Remove" then
				table.print(coords)
				printf("Please choose the number to remove\n-->")
				keyboardBufferClear();
				io.stdin:flush();
				local coordnum = io.stdin:read();	
				coordnum = tonumber(coordnum)
				table.remove(coords, coordnum)
			end
			hack_key = nil
		end
	yrest(10)
	end
end
startMacro(main, true);