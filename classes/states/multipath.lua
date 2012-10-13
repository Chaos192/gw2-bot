--[[
	Child of State class.
]]

-- use that state to run a selection of waypoint path files together
-- the bot will randomly mix up that files
--
-- you can start the bot with 'gw2/main multipath:<filename>
--
-- write the wp filenames into the file <filename> 




include("../state.lua");

MultipathState = class(State);

function MultipathState:constructor(_name)
	self.name = "Multipath";
	self.paths = {			-- paths to choose from
--	  "flamm-ketzer-1",
--	  "flamm-ketzer-2",
--	  "flamm-ketzer-3",	  
--	  "flamm-endlose-1",
	  };	
	if _name then			-- load WPs from path file (set also index and startIndex)
		self:loadmultipath(_name)
	end
	self.startState = true
end


function MultipathState:update()
	logger:log('debug',"Coming to MultipathState:update()");

	local chooseWP
	
	if self.startState then		-- choose closest path
		self.startState = false
		local startPath, startIndex = self:chooseStartPath()
		chooseWP = WaypointState( startPath )	-- run to start area
		chooseWP.lootwalk = true				-- loot while running
		chooseWP.stopAtEnd = true				-- run path only until end,
		logger:log('info',"Choose path '%s' #%s to go to the start area of multiple paths\n", chooseWP.waypointname, startIndex);		
		stateman:pushState(chooseWP)
		return
	end

	chooseWP = WaypointState(self.paths[math.random(#self.paths)])
	chooseWP.lootwalk = true					-- loot while running
	chooseWP.laps = 1							-- only one round
	logger:log('info',"Change to path '%s'\n", chooseWP.waypointname);		
	stateman:pushState(chooseWP)

end


-- Handle events
function MultipathState:handleEvent(event)

end

function MultipathState:loadmultipath(_filename)

	_filename = string.find(_filename,"(.*).xml") or _filename
	local file = BASE_PATH .. "/waypoints/" .. _filename .. ".xml";
	if( fileExists(file) ) then	
	
		local function trim(s)
			return (s:gsub("^%s*(.-)%s*$", "%1"))
		end
	
		self.paths = {}
		local hf_file = io.open(file,"r")
		local i = 1
		for line in hf_file:lines() do
			self.paths[i] = trim(line)
			i = i + 1
		end
		
		hf_file:close()

	else
		logger:log('error',"Multipathfile %s not found", file);
		error("Multipathfile not found",1)
	end


end

function MultipathState:chooseStartPath()
	local hf_dist, hf_index, nearestWPIndex, nearestPathName
	local nearestDist = 999999999 

-- look for nearest path
	for i = 1,#self.paths do
		local checkPathWP = WaypointState(self.paths[i])
		hf_dist, hf_index = checkPathWP:distanceToPath()
		if hf_dist < nearestDist then
			nearestDist = hf_dist
			nearestWPIndex = hf_index         
			nearestPathName = checkPathWP.waypointname
		end
	end

	return nearestPathName, nearestWPIndex;
end

table.insert(events,{name = "Multipath", func = MultipathState()})