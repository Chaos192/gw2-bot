--[[
	Child of State class.
]]

include("../state.lua");

DownState = class(State);

function DownState:constructor()
	self.name = "Down";
end

function DownState:update()
	logger:log('debug-states',"Coming to DownState:update()");

	statusupdate()		-- for down flag

-- Down until HP is full
	if not player.Downed then
		logger:log('info',"We are alive again. Pop Down State")
		stateman:popState("Down");
		return
	end

-- use skills during down / TODO: need some logic/priority/cooldowns
	logger:log('info',"use 1 during being down");
	keyboardPress(keySettings['skillweapon1'])

	logger:log('info',"use 4 during being down");
	keyboardPress(keySettings['skillweapon4'])

	yrest(4000)

	logger:log('info',"use 2 during being down");
	keyboardPress(keySettings['skillweapon2'])

	logger:log('info',"use 3 during being down");
	keyboardPress(keySettings['skillweapon3'])


end

-- Handle events
function DownState:handleEvent(event)

end


table.insert(events,{name = "Down", func = DownState()})