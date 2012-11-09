local proc = getProc()

function logInfo(_address,_name)
	local file, err, filename

	filename = getExecutionPath() .. "/logs/".._name..".txt"
	file, err = io.open(filename, "a+")

	if( not file ) then
		cprintf(cli.red,err.."\n")
		return
	end
	for i = 0,200,4 do
		local first = memoryReadInt(proc, _address + i*4)
		local sec = memoryReadInt(proc, _address + (i*4)+4)
		local thir = memoryReadInt(proc, _address + (i*4)+8)
		local four = memoryReadInt(proc, _address + (i*4)+0xC)
		msg = sprintf("%x \t%x \t%x \t%x\n",first,sec,thir,four)
		file:write(msg)
	end
	file:close()
end
local prevmob = {}
local npc = {}
function targetnearestmob(_range)
	_range = _range or 35
	local function mobstats(_arg1)
		local lvl, adjlvl, X, Z, Y, id, hostile, name, targetingID
		name = memoryReadUStringPtr(proc,_arg1 + 0x30,0x0)
		hostile = memoryReadInt(proc, _arg1 + 0x60)
		lvl = memoryReadIntPtr(proc, _arg1 + 0x128,0x7C)
		targetingID = memoryReadInt( proc, _arg1 + 0x44)
		hp = memoryReadFloatPtr(proc, _arg1 + 0x150,0x8)
		maxhp = memoryReadFloatPtr(proc, _arg1 + 0x150,0xC)
		
		local b4 = memoryReadIntPtr(proc, _arg1 + 0x44,{0x1C,0x5C})
		if b4 then
			X = memoryReadFloat(proc, b4 + 0x44)
			Z = memoryReadFloat(proc, b4 + 0x48)
			Y = memoryReadFloat(proc, b4 + 0x4C)
		end
		
		return lvl, X, Z, Y, hostile, name, targetingID, hp, maxhp
	end
	mobs = {}
	local _time = getTime()
	count = 0
	local size = memoryReadIntPtr(proc, addresses.objectArray, 0x1C)
	local one = memoryReadIntPtr(proc, addresses.objectArray,0x14)
	--print("The size of the array is "..size)
	for i = 0, size-1 do
		local two = memoryReadInt(proc, one + (i*4))
		if two ~= 0 then
			coordsupdate()
			count = count +1
			lvl, X, Z, Y, hostile, name, targetingID, hp, maxhp = mobstats(two)
			if X ~= nil then 
				dist = distance(player.ServX,player.ServZ,player.ServY,X,Z,Y)
				if (hostile == 2 or hostile == 1) and lvl ~= 1 then
					table.insert(mobs,{lvl = lvl, X=X, Z=Z, Y=Y, hostile=hostile,tarID = targetingID, dist = dist, HP = hp, MaxHP = maxhp, baseaddress = two,})
				end
			end
		end
	end
	print(count)
	print(deltaTime(getTime(), _time))
	table.print(npc)
	local function Sort(tab1, tab2)
		if( tab1.dist < tab2.dist ) then
			return true;
		end
		return false;
	end
	table.sort(mobs,Sort)
	print("distance to closest mob "..mobs[1].dist)
	for i = 1,3 do
		if mobs[i].HP ~= 0 and _range >= mobs[i].dist and mobs[i].tarID ~= prevmob.tarID then
			printf("HP: %d, MaxHP: %d\n",mobs[i].HP,mobs[i].MaxHP)
			memoryWriteInt( proc, addresses.TargetAll,mobs[i].tarID)
			yrest(100)
			prevmob = mobs[i]
			return mobs[i]
		end
	end
	print("no mob in range to kill")
	return
end


--[[ keeping back up copy
function mob()
	local function mobstats(_arg1)
		local lvl, adjlvl, X, Z, Y, id, hostile, name, targetingID
		name = memoryReadUStringPtr(proc,_arg1 + 0x30,0x0)
		id = memoryReadInt(proc, _arg1 + 0x48)
		hostile = memoryReadInt(proc, _arg1 + 0x60)
		lvl = memoryReadIntPtr(proc, _arg1 + 0x128,0x7C)
		targetingID = memoryReadInt( proc, _arg1 + 0x44)
		adjlvl = memoryReadIntPtr(proc, _arg1 + 0x128,0xA0)
		hp = memoryReadFloatPtr(proc, _arg1 + 0x150,0x8)
		maxhp = memoryReadFloatPtr(proc, _arg1 + 0x150,0xC)
		
		local two = memoryReadIntPtr(proc, _arg1 + 0x44,{0x1C,0x5C})
		X = memoryReadFloat(proc, two + 0x44)
		Z = memoryReadFloat(proc, two + 0x48)
		Y = memoryReadFloat(proc, two + 0x4C)
		
		return lvl, adjlvl, X, Z, Y, id, hostile, name, targetingID, hp, maxhp
	end
	mobs = {}
	local _time = getTime()
	count = 0
	local size = memoryReadRepeat("intptr", proc, addresses.objectArray, 0x1C)
	print("The size of the array is "..size)
	local one = memoryReadIntPtr(proc, addresses.objectArray,0x14)
	for i = 0, size-1 do
		local two = memoryReadInt(proc, one + (i*4))
		if two ~= 0 then
			coordsupdate()
			count = count +1
			lvl, adjlvl, X, Z, Y, id, hostile, name, targetingID, hp, maxhp = mobstats(two)
			dist = distance(player.ServX,player.ServZ,player.ServY,X,Z,Y)	
			if (hostile == 2 or hostile == 1) and lvl ~= 1 then
			--if lvl ~= 1 and hostile == 0 then
				table.insert(mobs,{lvl = lvl, X=X, Z=Z, Y=Y, id = id, hostile=hostile,tarID = targetingID, baseaddress = two, dist = dist, HP = hp, MaxHP = maxhp})
				--logInfo(two,i)
			end
				--memoryWriteInt( proc, addresses.TargetAll,targetingID)
				--yrest(1000)
		end
	end
	print(count)
	print(deltaTime(getTime(), _time))

	local function Sort(tab1, tab2)
		if( tab1.dist < tab2.dist ) then
			return true;
		end
		return false;
	end
	table.sort(mobs,Sort)
	for k,v in ipairs(mobs) do
		printf("%d Host: %x \tdist: %d \ttarID %x base: %x HP:%d\n",v.lvl,v.hostile,v.dist,v.tarID,v.baseaddress,v.HP)
	end
	table.print(mobs[1])
	targetupdate()
	printf("\nTarget all value: %x\n",player.TargetAll)
end
]]

function followcharname(_name)
	local function playerstats2(_arg1)
		name = memoryReadUStringPtr(proc, addresses.objectArray,{0x28,_arg1,0x30,0x0})
		X = memoryReadFloatPtr(proc, addresses.objectArray,{0x28,_arg1,0xC,0x44,0x1C,0x5C,0xB4})
		Z = memoryReadFloatPtr(proc, addresses.objectArray,{0x28,_arg1,0xC,0x44,0x1C,0x5C,0xB8})
		Y = memoryReadFloatPtr(proc, addresses.objectArray,{0x28,_arg1,0xC,0x44,0x1C,0x5C,0xBC})
		return X, Z, Y, name
	end
	npc = {}
   local proc = getProc()
   size = memoryReadRepeat("intptr", proc, addresses.objectArray, 0x30)
   print("The size of the array is "..size)
   for i = 1, size-1 do
      if memoryReadRepeat("intptr", proc, addresses.objectArray,{0x28,i*4}) ~= 0 then
         if memoryReadIntPtr(proc, addresses.objectArray,{0x28,i*4,0xC}) ~= 0 then
            X, Z, Y, name = playerstats2(i*4)
			table.insert(npc,{Name = name,X=X,Z=Z,Y=Y})
			if _name == name then
				return X,Z,Y
			end
         end
      end
   end
end
