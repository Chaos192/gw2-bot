-- Default configurations

SETTINGS = {}
SETTINGS['language'] = "english" -- "russian" "german" "french"


LOG_MESSAGE = {};
LOG_MESSAGE['error'] = true;					-- Log error messages (NOTE: Cannot be disabled)
LOG_MESSAGE['debug'] = false;					-- Log debug messages
LOG_MESSAGE['info'] = false;					-- Log info messages

LOG_MESSAGE_COLOR = {};
LOG_MESSAGE_COLOR['error'] = cli.red;			-- Color of error messages
LOG_MESSAGE_COLOR['debug'] = cli.lightblue;		-- Color of debug messages
LOG_MESSAGE_COLOR['info'] = cli.yellow;			-- Color of info messages

keySettings = {}
keySettings['turnleft'] = key.VK_A
keySettings['turnright'] = key.VK_D
keySettings['forward'] = key.VK_W
keySettings['backward'] = key.VK_S
keySettings['nexttarget'] = key.VK_TAB
keySettings['interact'] = key.VK_F


