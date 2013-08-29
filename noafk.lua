--=== V 1.0 ===--
addresses = include("addresses.lua");
include("functions/attach.lua")
include("classes/statemanager.lua");
include("functions/update.lua")

attach(getWin());

local proc = getProc()

function main()
	local count = 0
	print("starting")
	while(true) do
		keyboardPress(key.VK_W)
		yrest(120*1000)
		count = count + 1
		print(count)
	end
end
startMacro(main, true);