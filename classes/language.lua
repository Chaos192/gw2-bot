--[[
	Language management class.
	Loads language files and helps to display appropriate messages.
]]


Language = class();

function Language:constructor()
	self.messages = {};
	self.defaultLang = 'english';
	self.setLang = SETTINGS['langauge'];	
	self:load(self.defaultLang);
	self:load(self.setLang);	-- load individual language file
end

function Language:message(index)
	-- Return the string in the set language.
	local tab = self.messages[self.setLang];
	if( type(tab) == "table" and type(tab[index]) == "string" ) then
		return tab[index];
	else
		-- If not available, try using the default language.
		tab = self.messages[self.defaultLang];
		if( type(tab) == "table" and type(tab[index]) == "string" ) then
			return tab[index];
		else
			return "<Invalid language string requested>";
		end
	end
end

function Language:load(name)
	local file = BASE_PATH .. "/language/" .. name .. ".lua";
	if( fileExists(file) ) then
		self.messages[name] = include(BASE_PATH .. "/language/" .. name .. ".lua", true);
	else
		error(sprintf("Unable to load language file \'%s\' from \'%s\'", name, file), 2)
	end
end

function Language:unload(name)
	self.messages[name] = nil;
end

function Language:isLoaded(name)
	if( type(self.messages[name]) == "table" ) then
		return true;
	else
		return false;
	end
end

function Language:setLanguage(name)
	if( type(self.messages[name]) == "table" ) then
		self.setLang = name;
	else
		error(sprintf("Unable to set language to \'%s\': This is not a valid table.", name), 2);
	end
end