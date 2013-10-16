--=== V 1.0 ===--
addresses = include("addresses.lua");
include("functions/attach.lua")
include("classes/statemanager.lua");
include("functions/update.lua")

attach(getWin());

local proc = getProc()


function main()
	local hold = 10000
	local pause = 6000
	local go = false
	print("hold is how long the #2 key is held down for (distance).\n pause is the cooldown")
	print("Numpad 1: hold + 500")
	print("Numpad 2: hold - 500")
	print("Numpad 4: pause + 500")
	print("Numpad 5: pause - 500")
	print("Numpad 7: end changing times")
	print("Numpad 8: Begin changing times")
	while(true) do
		if go then
			print("hold: "..hold.."\n pause"..pause)
			keyboardHold(key.VK_2)
			yrest(hold)
			keyboardRelease(key.VK_2)
			yrest(pause)
		else
			print("hold: "..hold.."\n pause"..pause)
			repeat
				if( keyPressed(key.VK_NUMPAD1) ) then
					hold = hold + 500
					print("hold: "..hold)
				end
				if( keyPressed(key.VK_NUMPAD2) ) then
					hold = hold - 500
					print("hold: "..hold)
				end
				if( keyPressed(key.VK_NUMPAD4) ) then
					pause = pause + 500
					print("pause: "..pause)
				end
				if( keyPressed(key.VK_NUMPAD5) ) then
					pause = pause - 500
					print("pause: "..pause)
				end
				if( keyPressed(key.VK_NUMPAD7) ) then
					go = true
				end
				yrest(100)
			until go == true
		end
		if( keyPressed(key.VK_NUMPAD8) ) then
			go = false
		end	
		yrest(500)
	end
end
startMacro(main, true);