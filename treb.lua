--=== V 1.0 ===--
addresses = include("addresses.lua");
include("functions/attach.lua")
include("classes/statemanager.lua");
include("functions/update.lua")

attach(getWin());

local proc = getProc()


function main()

	while(true) do
		keyboardHold(key.VK_2)
		yrest(6300)
		keyboardRelease(key.VK_2)
		yrest(6000)
		
	end
end
startMacro(main, true);