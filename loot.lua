--=== V 1.0 ===--
addresses = include("addresses.lua");
include("functions/attach.lua")
include("classes/statemanager.lua");
include("functions/update.lua")

attach(getWin());

local proc = getProc()
keyboardBufferClear();
function Ftext()
	return (memoryReadRepeat("int", proc, addresses.Finteraction) ~= 0) 
end

function main()
	local tt = ""
	local _time = os.time()
	while(true) do
		if Ftext() and os.time() - _time >= 1 then keyboardPress(key.VK_F8) _time = os.time() end
	yrest(10)
	end
end
startMacro(main, true);