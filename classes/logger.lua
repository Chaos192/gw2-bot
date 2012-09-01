--[[
   This class handles logging. That's it. Pretty obvious stuff.
]]


Logger = class();

function Logger:constructor(fn)
   self.file = nil;
   self.filename = nil;
   self.dateformat = "%Y/%m/%d %H:%M:%S";

	if( fn ) then
		self:openFile(fn);
	end
end

function Logger:openFile(filename)
   if( self.file ) then
      self.file:close();
   end

   local path = getFilePath(filename);
   if( not isDirectory(path) ) then
      self:log("debug", "Creating log directory.");
      system( sprintf("mkdir \"%s\"", fixSlashes(path, false)) );
   end

   local appending = fileExists(filename);
   self.file = io.open(filename, "a");

   if( not self.file ) then
      self:log("error", "Unable to open file \'%s\' for logging.", filename);
   else
      self.filename = filename;
      cprintf(LOG_MESSAGE_COLOR['info'], "Logging to \'%s\'\n", filename);
   end

   if( appending ) then
      self.file:write("\n\n");
      self.file:write(string.rep("-", 80) .. "\n");
   end

   local msg = sprintf("File opened for logging at %s\n\n", os.date(self.dateformat));
   self.file:write(msg);
   self.file:flush();
end

function Logger:log(level, msg, ...)
   if( not string.find(msg, "\n$") ) then msg = msg .. "\n"; end;

   -- Check if we don't log debug messages
   if( level == 'debug' and not LOG_MESSAGE['debug'] ) then
      return;
   end

   -- Check if we don't log info messages
   if( level == 'info' and not LOG_MESSAGE['info'] ) then
      return;
   end

   local col = LOG_MESSAGE_COLOR[level];
   if( type(col) ~= "number" ) then
      printf(msg, ...);
   else
      cprintf(col, msg, ...);
   end


   if( self.file ) then
      self.file:write("\t" .. '[' .. string.upper(level) .. '] ' .. os.date(self.dateformat) .. "\t" .. sprintf(msg, ...));
      self.file:flush();
   end
end

function Logger:close()
   if( self.file ) then
      self.file:close();
   end
end
