--[[
	Child of State class.
]]

include("../state.lua");

DownState = class(State);

function DownState:constructor()
	self.name = "Down";
	self.downskill2used	= 0
	self.downskill3used	= 0
	self.downskill4used	= 0
end

function DownState:update()
	logger:log('debug-states',"Coming to DownState:update()");

	statusupdate()		-- for down flag

	if not player.Downed then
		logger:log('info',"We are alive again. Pop Down State")
		stateman:popState("Down");
		return
	end

	cprintf(cli.red,"using downskill 1\n")
	keyboardPress(keySettings['skillweapon1'])

	if profile['downskill4use'] == true and os.difftime(os.time(),self.downskill4used) > profile['downskill4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon4'])	
		cprintf(cli.red,"using downskill 4\n")
		yrest(profile['downskill4casttime']*1000)
		self.downskill4used = os.time()
		return
	end	

	if profile['downskill2use'] == true and os.difftime(os.time(),self.downskill2used) > profile['downskill2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon2'])
		cprintf(cli.red,"using skill 2\n")
		yrest(profile['downskill2casttime']*1000)
		self.downskill2used = os.time()
		return
	end
	if profile['downskill3use'] == true and os.difftime(os.time(),self.downskill3used) > profile['downskill3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon3'])
		cprintf(cli.red,"using downskill 3\n")
		yrest(profile['downskill3casttime']*1000)
		self.downskill3used = os.time()
		return
	end





-- use skills during down / TODO: need some logic/priority/cooldowns

--	logger:log('info',"use 4 during being down");
--	keyboardPress(keySettings['skillweapon4'])

--	yrest(4000)

--	logger:log('info',"use 2 during being down");
--	keyboardPress(keySettings['skillweapon2'])

--	logger:log('info',"use 3 during being down");
--	keyboardPress(keySettings['skillweapon3'])


end

-- Handle events
function DownState:handleEvent(event)

end


table.insert(events,{name = "Down", func = DownState()})