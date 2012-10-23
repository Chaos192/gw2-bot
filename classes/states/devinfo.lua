--[[
	Child of State class.
]]

include("../state.lua");

DevinfoState = class(State);

function DevinfoState:constructor()
	self.name = "Devinfo";

	self.playerfields = {
		"Name", 
		"Account", 
		"Karma", 
		"Gold", 
		"HP", 
		"MaxHP", 
		"InCombat", 
		"Alive", 
		"Downed", 
		"Dead", 
		"X", 
		"Z", 
		"Y", 
		"Dir1", 
		"Dir2", 
		"Angle",
		"Interaction", 
		"Ftext", 
		"InteractionId",
        "TargetAll",
		"TargetMob", 
	}
	self.targetfields = {
		"TargetX", 
		"TargetZ", 
		"TargetY",
	}

	
end

function contains(table, entry)
  return table[entry]
end


function DevinfoState:update()

	updateall()
	clearScreen()

	self.player = self:Set(self.playerfields)
	self.target = self:Set(self.targetfields)


	for fieldname, _val in pairs(player) do 
		if contains(self.player,fieldname) then
			self.player[fieldname] = _val
		end
	end

	for i, _val in pairs(self.playerfields) do 
		printf("player.%s=%s\n", _val, self.player[_val])
	end

	for fieldname, _val in pairs(target) do 
		if contains(self.target,fieldname) then
			self.target[fieldname] = _val
		end
	end

	for i, _val in pairs(self.targetfields) do 
		printf("target.%s=%s\n", _val, self.target[_val])
	end

end

function DevinfoState:Set(_table)
	local set = {}
	for _,value in pairs(_table) do set[value] = true end
	return set
end


-- Handle events
function DevinfoState:handleEvent(event)

end

table.insert(events,{name = "Devinfo", func = DevinfoState})