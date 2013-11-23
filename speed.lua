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
	--[[
	if (memoryReadRepeat("int", proc, addresses.Finteraction) ~= 0) then
		for i = 0x54,0x134,0x20 do
			if memoryReadIntPtr(proc,addresses.FtextAddress, {0x0, i, 0x14, 0x0}) == 1650426113 then 
				return memoryReadUStringPtr(proc,addresses.FtextAddress, {0x0, i, 0x14, 0x22})
			end
		end
		if memoryReadIntPtr(proc,addresses.FtextAddress, {0x0, 0x84, 0x0}) == 1650426113 then 
			return memoryReadUStringPtr(proc,addresses.FtextAddress, {0x0, 0x84, 0x22})
		end		
		return ""
	else
		return ""
	end]]
end

function main()
	
	print("Numpad 1: Normal Speed")
	print("Numpad 2: Fast Speed")
	print("Numpad 3: Super Fast Speed")
	local tt = ""
	local _time = os.time()
	while(true) do
		
		if Ftext() and os.time() - _time >= 1 then keyboardPress(key.VK_F8) _time = os.time() end
		--[[
		local Ftext = Ftext()
		if Ftext ~= "" then
			if tt ~= Ftext then 
				tt = Ftext 
				print(Ftext)
			end
			if string.find(Ftext,"Search") then
				keyboardPress(key.VK_F)
				yrest(1000)
			end
		end]]
		
		
		if( keyPressed(key.VK_NUMPAD1) ) then
			speed("norm")
			yrest(1000)
			setWindowName(getHwnd(),speed("get"))
		end
		if( keyPressed(key.VK_NUMPAD2) ) then
			speed(speed("get")*1.33)
			yrest(1000)
			setWindowName(getHwnd(),speed("get"))
		end	
		if( keyPressed(key.VK_NUMPAD3) ) then
			speed(30)
			yrest(1000)
			setWindowName(getHwnd(),speed("get"))
		end
	yrest(10)
	end
end
startMacro(main, true);