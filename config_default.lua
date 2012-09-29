-- Default configurations

SETTINGS = {}
SETTINGS['language'] = "english" -- "russian" "german" "french"
SETTINGS['combatstate'] = true					--  entercombat state pushed automaticly if incombat (used by working with waypoint files)
SETTINGS['lagallowance'] = 1

SETTINGS['useKeypress'] = false		-- use old keypress style for Player:useSkills()

LOG_MESSAGE = {};
LOG_MESSAGE['error'] = true;					-- Log error messages (NOTE: Cannot be disabled)
LOG_MESSAGE['debug'] = false;					-- Log debug messages
LOG_MESSAGE['debug2'] = false;					-- Log debug messages
LOG_MESSAGE['debug-states'] = false;			-- Log debug messages for states
LOG_MESSAGE['debug-moving'] = false;			-- Log debug messages for moving problems
LOG_MESSAGE['info'] = false;					-- Log info messages

LOG_MESSAGE_COLOR = {};
LOG_MESSAGE_COLOR['error'] = cli.red;			-- Color of error messages
LOG_MESSAGE_COLOR['debug'] = cli.lightblue;		-- Color of debug messages
LOG_MESSAGE_COLOR['info'] = cli.yellow;			-- Color of info messages

keySettings = {}
keySettings['turnleft']   = key.VK_A
keySettings['turnright']  = key.VK_D
keySettings['forward']    = key.VK_W
keySettings['backward']   = key.VK_S
keySettings['nexttarget'] = key.VK_TAB
keySettings['interact']   = key.VK_F
keySettings['skillweapon1'] = key.VK_1
keySettings['skillweapon2'] = key.VK_2
keySettings['skillweapon3'] = key.VK_3
keySettings['skillweapon4'] = key.VK_4
keySettings['skillweapon5'] = key.VK_5
keySettings['skillheal']    = key.VK_6
keySettings['skillhelp1']   = key.VK_7
keySettings['skillhelp2']   = key.VK_8
keySettings['skillhelp3']   = key.VK_9
keySettings['skillelite']   = key.VK_0
keySettings['skillclass1']  = key.VK_F1
keySettings['skillclass2']  = key.VK_F2
keySettings['skillclass3']  = key.VK_F3
keySettings['skillclass4']  = key.VK_F4
