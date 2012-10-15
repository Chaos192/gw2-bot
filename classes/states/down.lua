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
	self.lastCastingTimer = 0				-- Casttime of used Spell
	self.lastSkilluseTime = getTime()			-- last time we used a skill
	self.breakableSkillActiv = false
end

function DownState:update()
	logger:log('debug-states',"Coming to DownState:update()");

	statusupdate()		-- for down flag

	if not player.Downed then
		logger:log('info',"We are alive again. Pop Down State")
		stateman:popState("Down");
		return
	end

-- check if we get damage and skill 4 is interrupted 
	if self.breakableSkillActiv and
	   player.HP < self.lastHP then		-- we get Damage
		logger:log('info',"Skill 4 interuppted")
		self.breakableSkillActiv = false
		self.lastCastingTimer = 0
	else
		self.lastHP = player.HP
	end

	if deltaTime(getTime(), self.lastSkilluseTime ) < self.lastCastingTimer then	-- still other cast channeling?
	--	logger:log('debug',"still casting: %d < %d)\n", deltaTime(getTime(), self.lastSkilluseTime ), self.lastCastingTimer );
		return
	end

	if profile['downskill4use'] == true and os.difftime(os.time(),self.downskill4used) > profile['downskill4cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon4'])	
		cprintf(cli.red,"using downskill 4\n")
		self.lastCastingTimer = profile['downskill4casttime']*1000
--		yrest(profile['downskill4casttime']*1000)
		self.downskill4used = os.time()
		self.lastSkilluseTime = getTime()
		self.breakableSkillActiv = true
		self.lastHP = player.HP				-- remember HP to detect Damage
		return
	end	

	if profile['downskill2use'] == true and os.difftime(os.time(),self.downskill2used) > profile['downskill2cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon2'])
		cprintf(cli.red,"using skill 2\n")
		self.lastCastingTimer = profile['downskill2casttime']*1000
--		yrest(profile['downskill2casttime']*1000)
		self.downskill2used = os.time()
		self.lastSkilluseTime = getTime()
		return
	end
	if profile['downskill3use'] == true and os.difftime(os.time(),self.downskill3used) > profile['downskill3cd'] + SETTINGS['lagallowance'] then
		keyboardPress(keySettings['skillweapon3'])
		cprintf(cli.red,"using downskill 3\n")
		self.lastCastingTimer = profile['downskill3casttime']*1000
--		yrest(profile['downskill3casttime']*1000)
		self.downskill3used = os.time()
		self.lastSkilluseTime = getTime()		
		return
	end

	cprintf(cli.red,"using downskill 1\n")
	keyboardPress(keySettings['skillweapon1'])
	self.lastCastingTimer = 750
	self.lastSkilluseTime = getTime()




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