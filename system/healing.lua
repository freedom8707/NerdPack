NeP.Healing = {
	Units = {},
}

local Healing = NeP.Healing
local LibDispellable = LibStub("LibDispellable-1.0")

local Roles = {
	['TANK'] = 3,
	['HEALER'] = 2,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}

-- BlackListed Units	
local BlackListUnit = {
	[90296] = 'Soulbound Constructor', -- HC
}

-- BlackListed Debuffs
local BlackListDebuff = {
	[184449] = 'Mark of the Necromancer', -- Mark of the Necromancer (HC)
}

-- Build Roster
C_Timer.NewTicker(1, (function()
	wipe(NeP.Healing.Units)
	for i=1,#NeP.OM.unitFriend do
		local Obj = NeP.OM.unitFriend[i]
		if UnitPlayerOrPetInParty(Obj.key)
		and Obj.distance <= 40
		and not UnitIsDeadOrGhost(Obj.key)
		and not BlackListUnit[Obj.id] then
			if UnitIsVisible(Obj.key)
			and NeP.Engine.LineOfSight('player', Obj.key) then
				local Role = UnitGroupRolesAssigned(Obj.key) or 'NONE'
				local missingHealth = UnitHealthMax(Obj.key) - UnitHealth(Obj.key)
				local prio = Roles[tostring(Role)] * missingHealth
				Healing.Units[#Healing.Units+1] = {
					key = Obj.key,
					prio = prio,
					name = Obj.name,
					id = Obj.id,
					health = Obj.health,
					distance = Obj.distance,
					role = Role
				}
			end
		end
	end
	table.sort(NeP.Healing.Units, function(a,b) return a.prio > b.prio end)
end), nil)

-- Lowest
Healing['lowest'] = function()
	if Healing.Units[1] then
		return Healing.Units[1].key 
	else
		return 'player'
	end
end

-- AoE Healing
Healing['AoEHeal'] = function(health)
	local health = tonumber(health)
	local numb = 0	
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		if Obj.health < health then
			numb = numb + 1
		end
	end
	return numb
end

-- Tank
Healing['tank'] = function()
	local tempTable = {}
	for i=1, #Healing.Units do
		local Obj = Healing.Units[i]
		local prio = Roles[tostring(Obj.role)] * Obj.health
		tempTable[#tempTable+1] = {
			key = Obj.key,
			prio = prio
		}
	end
	table.sort(tempTable, function(a,b) return a.prio > b.prio end)
	if tempTable[1] then
		return tempTable[1].key 
	else
		return 'player'
	end
end

-- Dispell's
Healing['DispellAll'] = function(spell)
	for i=1,#Healing.Units do
		local Obj = Healing.Units[i]
		if LibDispellable:CanDispelWith(Obj.key, GetSpellID(GetSpellName(spell))) then
			return true, Obj.key
		end
	end
	return false, nil
end

-- Remaining complatible with ALL PEs Crs..
NeP.library.register('coreHealing', {
	
	needsHealing = function(percent, count)
		local total = Healing['AoEHeal'](percent)
		return total >= count
	end,

	lowestDebuff = function(debuff, health)
		for i=1, #Healing.Units do
			local Obj = Healing.Units[i]
			if Obj.health <= health then
				local debuff,_,_,caster = NeP.APIs['UnitDebuff'](Obj.key, debuff, "any")
				if not debuff then
					NeP.Engine.ForceTarget = Obj.key
					return true
				end
			end
		end
		return false
	end,

	lowestBuff = function(buff, health)
		for i=1, #Healing.Units do
			local Obj = Healing.Units[i]
			if Obj.health <= health then
				local buff,_,_,caster = NeP.APIs['UnitBuff'](Obj.key, buff, "any")
				if not buff then
					NeP.Engine.ForceTarget = Obj.key
					return true
				end
			end
		end
		return false
	end
})