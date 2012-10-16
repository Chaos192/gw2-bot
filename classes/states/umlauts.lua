--[[
	Child of State class.
]]
-- test state for working with umlauts

include("../state.lua");

UmlautsState = class(State);

function UmlautsState:constructor()
	self.name = "Umlauts";
end


function UmlautsState:update()

	local function AnsiToDos_umlauts(_str)

		-- ANSI char to DOS output
		local function replaceDos( _str, _ansi, _dos )
			_str = string.gsub(_str, string.char(_ansi), string.char(_dos) );
			return _str
		end

		_str = replaceDos(_str, 228, 132);		-- �
		_str = replaceDos(_str, 196, 142);		-- �
		_str = replaceDos(_str, 246, 148);		-- � unknown
		_str = replaceDos(_str, 214, 153);		-- � unknown
		_str = replaceDos(_str, 252, 129);		-- �
		_str = replaceDos(_str, 220, 154);		-- � unknown
		_str = replaceDos(_str, 223, 225);		-- �

		return _str;
	end

	statusupdate();
	
-- print player Ftext
	if player.Interaction == true then 

--		debug_value(player.Ftext, "player.Ftext");
--		debug_value(string.byte(player.Ftext,1), "1");
--		debug_value(string.byte(player.Ftext,2), "2");
--		debug_value(string.byte(player.Ftext,3), "3");
--		debug_value(string.byte(player.Ftext,4), "4");
--		debug_value(string.byte(player.Ftext,5), "5");
--		debug_value(string.byte(player.Ftext,6), "6");
--		debug_value(string.byte(player.Ftext,7), "7");
--		debug_value(string.byte(player.Ftext,8), "8");
--		debug_value(string.byte(player.Ftext,9), "9");
--		debug_value(string.byte(player.Ftext,10), "10");

		if( player.Ftext == language:message('InteractGreeting') )	 then
			logger:log('info',"Thats a greeting in %s: %s\n", SETTINGS['language'], player.Ftext)			
			logger:log('info',"Converted for the MM window: %s\n", AnsiToDos_umlauts(player.Ftext) )
		else
			logger:log('info',"No, that is not a greeting in %s: %s\n", SETTINGS['language'], player.Ftext)			
		end
		
	end

--	printf("Player name from game\n")

--	debug_value(player.Name,"player.Name");
--	debug_value(string.byte(player.Name,1), "1");
--	debug_value(string.byte(player.Name,2), "2");
--	debug_value(string.byte(player.Name,3), "3");
--	debug_value(string.byte(player.Name,4), "4");
--	debug_value(string.byte(player.Name,5), "5");
--	debug_value(string.byte(player.Name,6), "6");
--	debug_value(string.byte(player.Name,7), "7");
--	debug_value(string.byte(player.Name,8), "8");
--	debug_value(string.byte(player.Name,9), "9");
--	debug_value(string.byte(player.Name,10), "10");
--	debug_value(string.byte(player.Name,11), "11");
--	debug_value(string.byte(player.Name,12), "12");
--	debug_value(string.byte(player.Name,13), "13");
--	debug_value(string.byte(player.Name,14), "14");

--	printf("Dos Values\n")
--	debug_value(string.byte("�������",1), "DOS �"); -- 228
--	debug_value(string.byte("�������",2), "DOS �");	-- 196
--	debug_value(string.byte("�������",3), "DOS �");	-- 246
--	debug_value(string.byte("�������",4), "DOS �");	-- 214
--	debug_value(string.byte("�������",5), "DOS �");	-- 252
--	debug_value(string.byte("�������",6), "DOS �");	-- 220
--	debug_value(string.byte("�������",7), "DOS �");	-- 223

end

-- Handle events
function UmlautsState:handleEvent(event)

end

table.insert(events,{name = "Umlauts", func = UmlautsState})