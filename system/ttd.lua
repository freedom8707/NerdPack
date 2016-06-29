-- Time To Death function
-- Made by DarkNemie

-- Return this if no data
local fakeTTD = 99999

-- Two arrays to hold the information we need to calculate the DPS on each mob
local TimeFirstDamaged = {}
local AmountHPLost = {}

-- are we currently watching the combat log?
local IsLogging = false

-- Last time we saw HP changes during the current fight. Used to calculate DPNeP.
local LastTimestamp = false
local LastAmount = false

-- temporary variables
local GUID
local EVENT
local UnitFlag

-- combat log events to watch for damage
local DamageLogEvents = {
	["SPELL_DAMAGE"] = '',
	["DAMAGE_SHIELD"] = '',
	["SPELL_PERIODIC_DAMAGE"] = '',
	["SPELL_BUILDING_DAMAGE"] = '',
	["RANGE_DAMAGE"] = ''
}

-- combat log events to watch for healing
local HealingLogEvents = {
	["SPELL_HEAL"] = '',
	["SPELL_PERIODIC_HEAL"] = ''
}

-- record incoming damage with the guid in a table
local logDamage = function(...)
	LastTimestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, LastAmount = select(1, ...)
	if LastAmount then
		if TimeFirstDamaged[GUID] then
			--Debug("logDamage: We already know this mob and add ".. LastAmount .. " to AmountHPLost.")
			AmountHPLost[GUID] = AmountHPLost[GUID] + LastAmount
		else
			--Debug("logDamage: We have not seen this mob before and add ".. LastTimestamp .. " to TimeFirstDamaged.")
			TimeFirstDamaged[GUID] = LastTimestamp
			AmountHPLost[GUID] = LastAmount
		end
	end
end

-- record incoming damage with the guid in a table
local logSwing = function(...)
	LastTimestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, LastAmount = select(1, ...)
	if LastAmount then
		if TimeFirstDamaged[GUID] then
			--Debug("logSwing: We already know this mob and add ".. LastAmount .. " to AmountHPLost.")
			AmountHPLost[GUID] = AmountHPLost[GUID] + LastAmount
		else
			--Debug("logSwing: We have not seen this mob before and add ".. LastTimestamp .. " to TimeFirstDamaged.")
			TimeFirstDamaged[GUID] = LastTimestamp
			AmountHPLost[GUID] = LastAmount
		end
	end
end

-- subtract incoming healing from the guid
local logHealing = function(...)
	LastTimestamp, _, _, _, _, _, _, GUID, _, UnitFlag, _, _, _, _, LastAmount = select(1, ...)
	if LastAmount then
		if TimeFirstDamaged[GUID] then
			--Debug("logHealing: We already know this mob and subtract ".. LastAmount .. " to AmountHPLost.")
			AmountHPLost[GUID] = AmountHPLost[GUID] - LastAmount
		end
	end
end

-- start the combat log (when the player enters combat)
local startLogging = function()
	NeP.Listener.register('ttd', "COMBAT_LOG_EVENT_UNFILTERED", function(...)
		local EVENT = select(2, ...)
		if DamageLogEvents[EVENT] then
			--Debug(EVENT .. " fired, calling logDamage")
			logDamage(...)
		elseif HealingLogEvents[EVENT] then
			--Debug(EVENT .. " fired, calling logHealing")
			logHealing(...)
		elseif EVENT == "SWING_DAMAGE" then
			logSwing(...)
		end

	end)
	IsLogging = true
	--Debug("startLogging: Started watching for COMBAT_LOG_EVENT_UNFILTERED.")
end

-- stop the combat log (when the player leaves combat)
local stopLogging = function()
	NeP.Listener.unregister('ttd', "COMBAT_LOG_EVENT_UNFILTERED", startLogging)
	LastTimestamp = false
	LastAmount = false
	wipe(TimeFirstDamaged)
	wipe(AmountHPLost)
	IsLogging = false
	--Debug("stopLogging: Stopped watching for COMBAT_LOG_EVENT_UNFILTERED.")
end

-- the public function that this is all about
NeP.TimeToDie = function(unit)
	local rtDMG = nil

	if not unit then unit = "target" end

	if IsLogging then
		local GUID = UnitGUID(unit)
		if GUID then
			if not isDummy(unit) and TimeFirstDamaged[GUID] then
				rtDMG = UnitHealth(unit) * (LastTimestamp - TimeFirstDamaged[GUID]) / AmountHPLost[GUID]
			end
		end
	end

	if rtDMG == 0 then rtDMG = fakeTTD end
	return rtDMG or fakeTTD
end

-- register events
NeP.Listener.register('ttd', "PLAYER_REGEN_ENABLED", stopLogging)
NeP.Listener.register('ttd', "PLAYER_REGEN_DISABLED", startLogging)
NeP.Listener.register('ttd', "PLAYER_LOGIN", stopLogging)