-- Default configurations

LOG_MESSAGE = {};
LOG_MESSAGE['error'] = true;					-- Log error messages (NOTE: Cannot be disabled)
LOG_MESSAGE['debug'] = false;					-- Log debug messages
LOG_MESSAGE['info'] = false;					-- Log info messages

LOG_MESSAGE_COLOR = {};
LOG_MESSAGE_COLOR['error'] = cli.red;			-- Color of error messages
LOG_MESSAGE_COLOR['debug'] = cli.lightblue;		-- Color of debug messages
LOG_MESSAGE_COLOR['info'] = cli.yellow;			-- Color of info messages

Settings = {}
Settings['turnleft'] = key.VK_A
Settings['turnright'] = key.VK_D
Settings['forward'] = key.VK_W
Settings['backward'] = key.VK_S
Settings['nexttarget'] = key.VK_TAB
Settings['interact'] = key.VK_F
