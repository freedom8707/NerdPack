local GetTime = GetTime
local GetSpellBookIndex = GetSpellBookIndex
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitClassification = UnitClassification
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName
local stringFind = string.find
local stringLower = string.lower
local stringGmatch = string.gmatch

local rangeCheck = LibStub("LibRangeCheck-2.0")
local LibDispellable = LibStub("LibDispellable-1.0")
local LibBoss = LibStub("LibBossIDs")

NeP.DSL.RegisterConditon("dispellable", function(target, spell)
	if LibDispellable:CanDispelWith(target, GetSpellID(GetSpellName(spell))) then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("buff", function(target, spell)
	local buff,_,_,caster = NeP.APIs['UnitBuff'](target, spell)
	if not not buff and (caster == 'player' or caster == 'pet') then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("buff.any", function(target, spell)
	local buff,_,_,caster = NeP.APIs['UnitBuff'](target, spell, "any")
	if not not buff then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("buff.count", function(target, spell)
	local buff,count,_,caster = NeP.APIs['UnitBuff'](target, spell)
		if not not buff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

NeP.DSL.RegisterConditon("buff.duration", function(target, spell)
	local buff,_,expires,caster = NeP.APIs['UnitBuff'](target, spell)
	if not not buff and (caster == 'player' or caster == 'pet') then
		return (expires - GetTime())
	end
	return 0
end)

NeP.DSL.RegisterConditon("debuff", function(target, spell)
	local debuff,_,_,caster = NeP.APIs['UnitDebuff'](target, spell)
	if not not debuff and (caster == 'player' or caster == 'pet') then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("debuff.any", function(target, spell)
	local debuff,_,_,caster = NeP.APIs['UnitDebuff'](target, spell, "any")
	if not not debuff then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("debuff.count", function(target, spell)
	local debuff,count,_,caster = NeP.APIs['UnitDebuff'](target, spell)
	if not not debuff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

NeP.DSL.RegisterConditon("debuff.duration", function(target, spell)
	local debuff,_,expires,caster = NeP.APIs['UnitDebuff'](target, spell)
	if not not debuff and (caster == 'player' or caster == 'pet') then
		return (expires - GetTime())
	end
	return 0
end)

local Buffs = {
	['stats'] = 1,
	['stamina'] = 2,
	['attackpower'] = 3,
	['haste'] = 4,
	['spellpower'] = 5,
	['critical'] = 6,
	['mastery'] = 7,
	['multistrike'] = 8,
	['versatility'] = 9 
}
NeP.DSL.RegisterConditon('aura', function(unit, buff)
	return (GetRaidBuffTrayAuraInfo(Buffs[buff]) ~= nil)
end)

NeP.DSL.RegisterConditon("stance", function(target, spell)
	return GetShapeshiftForm()
end)

NeP.DSL.RegisterConditon("form", function(target, spell)
	return GetShapeshiftForm()
end)

NeP.DSL.RegisterConditon("seal", function(target, spell)
	return GetShapeshiftForm()
end)

NeP.DSL.RegisterConditon("focus", function(target, spell)
	return UnitPower(target, SPELL_POWER_FOCUS)
end)

NeP.DSL.RegisterConditon("holypower", function(target, spell)
	return UnitPower(target, SPELL_POWER_HOLY_POWER)
end)

NeP.DSL.RegisterConditon("shadoworbs", function(target, spell)
	return UnitPower(target, SPELL_POWER_SHADOW_ORBS)
end)

NeP.DSL.RegisterConditon("energy", function(target, spell)
	return UnitPower(target, SPELL_POWER_ENERGY)
end)

NeP.DSL.RegisterConditon("solar", function(target, spell)
	return GetEclipseDirection() == 'sun'
end)

NeP.DSL.RegisterConditon("lunar", function(target, spell)
	return GetEclipseDirection() == 'moon'
end)

NeP.DSL.RegisterConditon("eclipse", function(target, spell)
	return math.abs(UnitPower(target, SPELL_POWER_ECLIPSE))
end)

NeP.DSL.RegisterConditon("eclipseRaw", function(target, spell)
	return UnitPower(target, SPELL_POWER_ECLIPSE)
end)

NeP.DSL.RegisterConditon("timetomax", function(target, spell)
	local max = UnitPowerMax(target)
	local curr = UnitPower(target)
	local regen = select(2, GetPowerRegen(target))
	return (max - curr) * (1.0 / regen)
end)

NeP.DSL.RegisterConditon("stealable", function(target, spellCast, spell)
	for i=1, 40 do
		local name, _, _, _, _, _, _, _, isStealable, _ = UnitAura(target, i)
		if isStealable then
			if spell then
				if spell == GetSpellName(spell) then
					return true
				else
					return false
				end
			end
			return true
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("rage", function(target, spell)
	return UnitPower(target, SPELL_POWER_RAGE)
end)

NeP.DSL.RegisterConditon("chi", function(target, spell)
	return UnitPower(target, SPELL_POWER_CHI)
end)

NeP.DSL.RegisterConditon("demonicfury", function(target, spell)
	return UnitPower(target, SPELL_POWER_DEMONIC_FURY)
end)

NeP.DSL.RegisterConditon("embers", function(target, spell)
	return UnitPower(target, SPELL_POWER_BURNING_EMBERS, true)
end)

NeP.DSL.RegisterConditon("soulshards", function(target, spell)
	return UnitPower(target, SPELL_POWER_SOUL_SHARDS)
end)

NeP.DSL.RegisterConditon("behind", function(target, spell)
	return not NeP.Engine.Infront('player', target)
end)

NeP.DSL.RegisterConditon("infront", function(target, spell)
	return NeP.Engine.Infront('player', target)
end)


NeP.DSL.RegisterConditon("combopoints", function()
	return GetComboPoints('player', 'target')
end)

NeP.DSL.RegisterConditon("alive", function(target, spell)
	if UnitExists(target) and UnitHealth(target) > 0 then
	return true
	end
	return false
end)

NeP.DSL.RegisterConditon('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

NeP.DSL.RegisterConditon('swimming', function ()
	return IsSwimming()
end)

NeP.DSL.RegisterConditon("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

NeP.DSL.RegisterConditon("player", function (target)
	return UnitIsPlayer(target)
end)

NeP.DSL.RegisterConditon("exists", function(target)
	return (UnitExists(target))
end)

NeP.DSL.RegisterConditon("modifier.shift", function()
	return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.control", function()
	return IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.alt", function()
	return IsAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lshift", function()
	return IsLeftShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lcontrol", function()
	return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.lalt", function()
	return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.rshift", function()
	return IsRightShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.rcontrol", function()
	return IsRightControlKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.ralt", function()
	return IsRightAltKeyDown() and GetCurrentKeyBoardFocus() == nil
end)

NeP.DSL.RegisterConditon("modifier.player", function()
	return UnitIsPlayer("target")
end)

NeP.DSL.RegisterConditon("classification", function (target, spell)
	if not spell then return false end
	local classification = UnitClassification(target)
	if stringFind(spell, '[%s,]+') then
		for classificationExpected in stringGmatch(spell, '%a+') do
			if classification == stringLower(classificationExpected) then
			return true
			end
		end
		return false
	else
		return UnitClassification(target) == stringLower(spell)
	end
end)

NeP.DSL.RegisterConditon('boss', function (target, spell)
	local classification = UnitClassification(target)
	if classification == 'rareelite'
	or classification == 'rare'
	or classification == 'worldboss'
	or LibBoss.BossIDs[tonumber(UnitID(target))] then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon('elite', function (target, spell)
	local classification = UnitClassification(target)
	if classification == 'elite'
	or classification == 'rareelite'
	or classification == 'rare'
	or classification == 'worldboss'
	or LibBoss.BossIDs[tonumber(UnitID(target))] then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("id", function(target, id)
	local expectedID = tonumber(id)
	if expectedID and UnitID(target) == expectedID then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("toggle", function(toggle)
	return NeP.Config.Read('bStates_'..toggle, false)
end)

NeP.DSL.RegisterConditon("modifier.toggle", function(toggle)
	return NeP.Config.Read('bStates_'..toggle, false)
end)

NeP.DSL.RegisterConditon("threat", function(target)
	if UnitThreatSituation("player", target) then
		local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", target)
		return scaledPercent
	end
	return 0
end)

NeP.DSL.RegisterConditon("agro", function(target)
	if UnitThreatSituation(target) and UnitThreatSituation(target) >= 2 then
		return true
	end
	return false
end)


NeP.DSL.RegisterConditon("balance.sun", function()
	local direction = GetEclipseDirection()
	if direction == 'none' or direction == 'sun' then return true end
end)

NeP.DSL.RegisterConditon("balance.moon", function()
	local direction = GetEclipseDirection()
	if direction == 'moon' then return true end
end)

NeP.DSL.RegisterConditon("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)


local movingCache = { }

NeP.DSL.RegisterConditon("lastmoved", function(target)
	if target == 'player' then
		if not NeP.Listener.locals.moving then
			return GetTime() - NeP.Listener.locals.movingTime
		end
		return false
	else
		if UnitExists(target) then
			local guid = UnitGUID(target)
			if movingCache[guid] then
				local moving = (GetUnitSpeed(target) > 0)
				if not movingCache[guid].moving and moving then
					movingCache[guid].last = GetTime()
					movingCache[guid].moving = true
					return false
				elseif moving then
					return false
				elseif not moving then
					movingCache[guid].moving = false
					return GetTime() - movingCache[guid].last
				end
			else
				movingCache[guid] = { }
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			end
		end
		return false
	end
end)

NeP.DSL.RegisterConditon("movingfor", function(target)
	if target == 'player' then
		if NeP.Listener.locals.moving then
			return GetTime() - NeP.Listener.locals.movingTime
		end
		return false
	else
		if UnitExists(target) then
			local guid = UnitGUID(target)
			if movingCache[guid] then
				local moving = (GetUnitSpeed(target) > 0)
				if not movingCache[guid].moving then
					movingCache[guid].last = GetTime()
					movingCache[guid].moving = (GetUnitSpeed(target) > 0)
					return false
				elseif moving then
					return GetTime() - movingCache[guid].last
				elseif not moving then
					movingCache[guid].moving = false
					return false
				end
			else
				movingCache[guid] = { }
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			end
		end
		return false
	end
end)

-- DK Power

NeP.DSL.RegisterConditon("runicpower", function(target, spell)
	return UnitPower(target, SPELL_POWER_RUNIC_POWER)
end)

local runes_t = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0
}
local runes_c = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0
}

NeP.DSL.RegisterConditon("runes.count", function(target, rune)
	-- 12 b, 34 f, 56 u
	runes_t[1], runes_t[2], runes_t[3], runes_t[4], runes_c[1], runes_c[2], runes_c[3], runes_c[4] = 0,0,0,0,0,0,0,0
	for i=1, 6 do
		local _, _, c = GetRuneCooldown(i)
		local t = GetRuneType(i)
		runes_t[t] = runes_t[t] + 1
		if c then
			runes_c[t] = runes_c[t] + 1
		end
	end
	if rune == 'frost' then
		return runes_c[3]
	elseif rune == 'blood' then
		return runes_c[1]
	elseif rune == 'unholy' then
		return runes_c[2]
	elseif rune == 'death' then
		return runes_c[4]
	elseif rune == 'Frost' then
		return runes_c[3] + runes_c[4]
	elseif rune == 'Blood' then
		return runes_c[1] + runes_c[4]
	elseif rune == 'Unholy' then
		return runes_c[2] + runes_c[4]
	end
	return 0
end)

NeP.DSL.RegisterConditon("runes.frac", function(target, rune)
	-- 12 b, 34 f, 56 u
	runes_t[1], runes_t[2], runes_t[3], runes_t[4], runes_c[1], runes_c[2], runes_c[3], runes_c[4] = 0,0,0,0,0,0,0,0
	for i=1, 6 do
		local r, d, c = GetRuneCooldown(i)
		local frac = 1-(r/d)
		local t = GetRuneType(i)
		runes_t[t] = runes_t[t] + 1
		if c then
			runes_c[t] = runes_c[t] + frac
		end
	end
	if rune == 'frost' then
		return runes_c[3]
	elseif rune == 'blood' then
		return runes_c[1]
	elseif rune == 'unholy' then
		return runes_c[2]
	elseif rune == 'death' then
		return runes_c[4]
	elseif rune == 'Frost' then
		return runes_c[3] + runes_c[4]
	elseif rune == 'Blood' then
		return runes_c[1] + runes_c[4]
	elseif rune == 'Unholy' then
		return runes_c[2] + runes_c[4]
	end
	return 0
end)

NeP.DSL.RegisterConditon("runes.cooldown_min", function(target, rune)
	-- 12 b, 34 f, 56 u
	runes_t[1], runes_t[2], runes_t[3], runes_t[4], runes_c[1], runes_c[2], runes_c[3], runes_c[4] = 0,0,0,0,0,0,0,0
	for i=1, 6 do
		local r, d, c = GetRuneCooldown(i)
		local cd = (r + d) - GetTime()
		local t = GetRuneType(i)
		runes_t[t] = runes_t[t] + 1
		if cd > 0 and runes_c[t] > cd then
			runes_c[t] = cd
		else
			runes_c[t] = 8675309
		end
	end
	if rune == 'frost' then
		return runes_c[3]
	elseif rune == 'blood' then
		return runes_c[1]
	elseif rune == 'unholy' then
		return runes_c[2]
	elseif rune == 'death' then
		return runes_c[4]
	elseif rune == 'Frost' then
		if runes_c[3] < runes_c[4] then
			return runes_c[3]
		end
		return runes_c[4]
	elseif rune == 'Blood' then
		if runes_c[1] < runes_c[4] then
			return runes_c[1]
		end
		return runes_c[4]
	elseif rune == 'Unholy' then
		if runes_c[2] < runes_c[4] then
			return runes_c[2]
		end
		return runes_c[4]
	end
	return 0
end)

NeP.DSL.RegisterConditon("runes.cooldown_max", function(target, rune)
	-- 12 b, 34 f, 56 u
	runes_t[1], runes_t[2], runes_t[3], runes_t[4], runes_c[1], runes_c[2], runes_c[3], runes_c[4] = 0,0,0,0,0,0,0,0
	for i=1, 6 do
		local r, d, c = GetRuneCooldown(i)
		local cd = (r + d) - GetTime()
		local t = GetRuneType(i)
		runes_t[t] = runes_t[t] + 1
		if cd > 0 and runes_c[t] < cd then
			runes_c[t] = cd
		end
	end
	if rune == 'frost' then
		return runes_c[3]
	elseif rune == 'blood' then
		return runes_c[1]
	elseif rune == 'unholy' then
		return runes_c[2]
	elseif rune == 'death' then
		return runes_c[4]
	elseif rune == 'Frost' then
		if runes_c[3] > runes_c[4] then
			return runes_c[3]
		end
		return runes_c[4]
	elseif rune == 'Blood' then
		if runes_c[1] > runes_c[4] then
			return runes_c[1]
		end
		return runes_c[4]
	elseif rune == 'Unholy' then
		if runes_c[2] > runes_c[4] then
			return runes_c[2]
		end
		return runes_c[4]
	end
	return 0
end)


NeP.DSL.RegisterConditon("runes.depleted", function(target, spell)
	local regeneration_threshold = 1
	for i=1,6,2 do
		local start, duration, runeReady = GetRuneCooldown(i)
		local start2, duration2, runeReady2 = GetRuneCooldown(i+1)
		if not runeReady and not runeReady2 and duration > 0 and duration2 > 0 and start > 0 and start2 > 0 then
			if (start-GetTime()+duration)>=regeneration_threshold and (start2-GetTime()+duration2)>=regeneration_threshold then
				return true
			end
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("runes", function(target, rune)
	return NeP.DSL.Conditions["runes.count"](target, rune)
end)

NeP.DSL.RegisterConditon("health", function(target)
	local health = math.floor((UnitHealth(target) / UnitHealthMax(target)) * 100)
	return health
end)

NeP.DSL.RegisterConditon("health.actual", function(target)
	return UnitHealth(target)
end)

NeP.DSL.RegisterConditon("health.max", function(target)
	return UnitHealthMax(target)
end)

NeP.DSL.RegisterConditon("mana", function(target, spell)
	if UnitExists(target) then
		return math.floor((UnitMana(target) / UnitManaMax(target)) * 100)
	end
	return 0
end)

NeP.DSL.RegisterConditon("modifier.multitarget", function()
	return NeP.DSL.Conditions["modifier.toggle"]('AoE')
end)

NeP.DSL.RegisterConditon("modifier.cooldowns", function()
	return NeP.DSL.Conditions["modifier.toggle"]('Cooldowns')
end)

NeP.DSL.RegisterConditon("modifier.interrupts", function()
	if NeP.DSL.Conditions["modifier.toggle"]('Interrupts') then
		local stop = NeP.DSL.Conditions["casting"]('target')
		if stop then StopCast() end
		return stop
	end
	return false
end)

NeP.DSL.RegisterConditon("modifier.interrupt", function()
	if NeP.DSL.Conditions["modifier.toggle"]('Interrupts') then
		return NeP.DSL.Conditions["casting"]('target')
	end
	return false
end)

NeP.DSL.RegisterConditon("lastcast", function(spell, arg)
	if arg then spell = arg end
	return NeP.Engine.lastCast == GetSpellName(spell)
end)

NeP.DSL.RegisterConditon("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL.RegisterConditon("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL.RegisterConditon("totem", function(target, totem)
	for index = 1, 4 do
		local _, totemName, startTime, duration = GetTotemInfo(index)
		if totemName == GetSpellName(totem) then
			return true
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("mounted", function()
	return IsMounted()
end)

NeP.DSL.RegisterConditon("totem.duration", function(target, totem)
	for index = 1, 4 do
	local _, totemName, startTime, duration = GetTotemInfo(index)
	if totemName == GetSpellName(totem) then
		return floor(startTime + duration - GetTime())
	end
	end
	return 0
end)

NeP.DSL.RegisterConditon("mushrooms", function ()
	local count = 0
	for slot = 1, 3 do
	if GetTotemInfo(slot) then
		count = count + 1 end
	end
	return count
end)

local function checkChanneling(target)
	local name, _, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(target)
	if name then return name, startTime, endTime, notInterruptible end

	return false
end

local function checkCasting(target)
	local name, startTime, endTime, notInterruptible = checkChanneling(target)
	if name then return name, startTime, endTime, notInterruptible end

	local name, _, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(target)
	if name then return name, startTime, endTime, notInterruptible end

	return false
end

NeP.DSL.RegisterConditon('casting.time', function(target, spell)
	local name, startTime, endTime = checkCasting(target)
	if not endTime or not startTime then return false end
	if name then return (endTime - startTime) / 1000 end
	return false
end)

NeP.DSL.RegisterConditon('casting.delta', function(target, spell)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	if not endTime or not startTime then return false end
	if name and not notInterruptible then
		local castLength = (endTime - startTime) / 1000
		local secondsLeft = endTime / 1000 - GetTime()
		return secondsLeft, castLength
	end
	return false
end)

NeP.DSL.RegisterConditon('casting.percent', function(target, spell)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	if name and not notInterruptible then
		local castLength = (endTime - startTime) / 1000
		local secondsLeft = endTime / 1000  - GetTime()
		return ((secondsLeft/castLength)*100)
	end
	return false
end)

NeP.DSL.RegisterConditon('channeling', function (target, spell)
	return checkChanneling(target)
end)

NeP.DSL.RegisterConditon("casting", function(target, spell)
	local castName,_,_,_,_,endTime,_,_,notInterruptibleCast = UnitCastingInfo(target)
	local channelName,_,_,_,_,endTime,_,notInterruptibleChannel = UnitChannelInfo(target)
	local spell = GetSpellName(spell)
	if (castName == spell or channelName == spell) and not not spell then
		return true
	elseif notInterruptibleCast == false or notInterruptibleChannel == false then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon('interruptAt', function (target, spell)
	if UnitIsUnit('player', target) then return false end
	if NeP.DSL.Conditions['modifier.toggle']('Interrupts') then
		local stopAt = tonumber(spell) or 35
		local stopAt = stopAt + math.random(-5, 5)
		local secondsLeft, castLength = NeP.DSL.Conditions['casting.delta'](target)
		if secondsLeft and 100 - (secondsLeft / castLength * 100) > stopAt then
			return true
		end
	end
	return false
end)

NeP.DSL.RegisterConditon('interruptsAt', function(target, spell)
	return NeP.DSL.Conditions['casting.delta'](target, spell)
end)

NeP.DSL.RegisterConditon("spell.cooldown", function(target, spell)
	local start, duration, enabled = GetSpellCooldown(spell)
	if not start then return false end
	if start ~= 0 then
		return (start + duration - GetTime())
	end
	return 0
end)

NeP.DSL.RegisterConditon("spell.recharge", function(target, spell)
	local charges, maxCharges, start, duration = GetSpellCharges(spell)
	if not start then return false end
	if start ~= 0 then
		return (start + duration - GetTime())
	end
	return 0
end)

NeP.DSL.RegisterConditon("spell.usable", function(target, spell)
	return (IsUsableSpell(spell) ~= nil)
end)

NeP.DSL.RegisterConditon("spell.exists", function(target, spell)
	if GetSpellBookIndex(spell) then
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon("spell.charges", function(target, spell)
	return select(1, GetSpellCharges(spell))
end)

NeP.DSL.RegisterConditon("spell.cd", function(target, spell)
	return NeP.DSL.Conditions["spell.cooldown"](target, spell)
end)

NeP.DSL.RegisterConditon("spell.range", function(target, spell)
	local spellIndex, spellBook = GetSpellBookIndex(spell)
	if not spellIndex then return false end
	return spellIndex and IsSpellInRange(spellIndex, spellBook, target)
end)

NeP.DSL.RegisterConditon("talent", function(args)
	local row, col = strsplit(",", args, 2)
	return hasTalent(tonumber(row), tonumber(col))
end)

NeP.DSL.RegisterConditon("friend", function(target, spell)
	return ( UnitCanAttack("player", target) ~= 1 )
end)

NeP.DSL.RegisterConditon("enemy", function(target, spell)
	return ( UnitCanAttack("player", target) )
end)

NeP.DSL.RegisterConditon("glyph", function(target, spell)
	local spellId = tonumber(spell)
	local glyphName, glyphId

	for i = 1, 6 do
	glyphId = select(4, GetGlyphSocketInfo(i))
	if glyphId then
		if spellId then
		if select(4, GetGlyphSocketInfo(i)) == spellId then
			return true
		end
		else
		glyphName = GetSpellName(glyphId)
		if glyphName:find(spell) then
			return true
		end
		end
	end
	end
	return false
end)

NeP.DSL.RegisterConditon("range", function(target)
	return NeP.DSL.Conditions["distance"](target)
end)

NeP.DSL.RegisterConditon("distance", function(target)
	return NeP.Engine.Distance('player', target)
end)

NeP.DSL.RegisterConditon("level", function(target, range)
	return UnitLevel(target)
end)

NeP.DSL.RegisterConditon("combat", function(target, range)
	return UnitAffectingCombat(target)
end)

NeP.DSL.RegisterConditon("time", function(target, range)
	if NeP.Listener.locals.combat then
		return GetTime() - NeP.Listener.locals.combatTime
	end
	return false
end)

local deathTrack = { }
NeP.DSL.RegisterConditon("deathin", function(target)
	return NeP.TimeToDie(target)
end)

NeP.DSL.RegisterConditon("ttd", function(target)
	return NeP.DSL.Conditions["deathin"](target)
end)

NeP.DSL.RegisterConditon("role", function(target, role)
	local role = role:upper()

	local damageAliases = { "DAMAGE", "DPS", "DEEPS" }

	local targetRole = UnitGroupRolesAssigned(target)
	if targetRole == role then return true
	elseif role:find("HEAL") and targetRole == "HEALER" then return true
	else
	for i = 1, #damageAliases do
		if role == damageAliases[i] then return true end
	end
	end

	return false
end)

NeP.DSL.RegisterConditon("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

NeP.DSL.RegisterConditon("modifier.party", function()
	return IsInGroup()
end)

NeP.DSL.RegisterConditon("modifier.raid", function()
	return IsInRaid()
end)

NeP.DSL.RegisterConditon("party", function(target)
	return UnitInParty(target)
end)

NeP.DSL.RegisterConditon("raid", function(target)
	return UnitInRaid(target)
end)

NeP.DSL.RegisterConditon("modifier.members", function()
	return (GetNumGroupMembers() or 0)
end)

NeP.DSL.RegisterConditon("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

NeP.DSL.RegisterConditon("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)

	if tonumber(expectedClass) then
	return tonumber(expectedClass) == classID
	else
	return expectedClass == class
	end
end)

NeP.DSL.RegisterConditon("falling", function()
	return IsFalling()
end)

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }

NeP.DSL.RegisterConditon("hashero", function(unit, spell)
	for i = 1, #heroismBuffs do
		local SpellName = GetSpellName(heroismBuffs[i])
		if UnitBuff('player', SpellName) then
			return true
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("buffs.stats", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(1) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.stamina", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(2) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.attackpower", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(3) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.attackspeed", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(4) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.haste", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(4) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.spellpower", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(5) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.crit", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(6) ~= nil)
end)
NeP.DSL.RegisterConditon("buffs.critical", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(6) ~= nil)
end)
NeP.DSL.RegisterConditon("buffs.criticalstrike", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(6) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.mastery", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(7) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.multistrike", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(8) ~= nil)
end)
NeP.DSL.RegisterConditon("buffs.multi", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(8) ~= nil)
end)

NeP.DSL.RegisterConditon("buffs.vers", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(9) ~= nil)
end)
NeP.DSL.RegisterConditon("buffs.versatility", function(unit, _)
	return (GetRaidBuffTrayAuraInfo(9) ~= nil)
end)

NeP.DSL.RegisterConditon("charmed", function(unit, _)
	return (UnitIsCharmed(unit) == true)
end)

NeP.DSL.RegisterConditon("vengeance", function(unit, spell)
	local vengeance = select(15, _G['UnitBuff']("player", GetSpellName(132365)))
	if not vengeance then
		return 0
	end
	if spell then
		return vengeance
	end
	return vengeance / UnitHealthMax("player") * 100
end)

-- Blizz Removed UnitIsTappedByPlayer is Legion!
NeP.DSL.RegisterConditon('modifier.taunt', function()
	--[[for i=1,#NeP.OM.unitEnemie do
		local Obj = NeP.OM.unitEnemie[i]
		if NeP.Engine.Infront('player', Obj.key) then
			if UnitIsTappedByPlayer(Obj.key)
			and Obj.distance <= 40
			and UnitAffectingCombat(Obj.key) then
				if UnitThreatSituation('player', Obj.key)
				and UnitThreatSituation('player', Obj.key) <= 2 then
					NeP.Engine.ForceTarget = Obj.key
					return true 
				end
			end
		end
	end]]
	return false
end)

NeP.DSL.RegisterConditon("area.enemies", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]
			if NeP.Engine.Distance(unit, Obj.key) <= distance then
				total = total +1
			end
		end
	end
	return total
end)

NeP.DSL.RegisterConditon("area.friendly", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM.unitFriend do
			local Obj = NeP.OM.unitFriend[i]
			if NeP.Engine.Distance(unit, Obj.key) <= distance then
				total = total +1
			end
		end
	end
	return total
end)

NeP.DSL.RegisterConditon("ilevel", function(unit, _)
	return math.floor(select(1,GetAverageItemLevel()))
end)

NeP.DSL.RegisterConditon("firehack", function(unit, _)
	return FireHack or false
end)

NeP.DSL.RegisterConditon("offspring", function(unit, _)
	return type(opos) == 'function' or false
end)

NeP.DSL.RegisterConditon('dispellAll', function(target, spell)
	local condtion, target = NeP.Healing['DispellAll'](spell)
	if condtion then
		NeP.Engine.ForceTarget = target
		return true
	end
	return false
end)

NeP.DSL.RegisterConditon('AoEHeal', function(args)
	local health, num = strsplit(',', args, 2)
	local health, num = tonumber(health), tonumber(num)
	if num then
		return NeP.Healing['AoEHeal'](health) >= tonumber(num) or false
	end
end)

NeP.DSL.RegisterConditon("timeout", function(args)
	local name, time = strsplit(",", args, 2)
	local time = tonumber(time)
	if time then
		if NeP.timeOut.check(name) then return false end
		NeP.timeOut.set(name, time)
		return true
	end
	return false
end)

local waitTable = {}
NeP.DSL.RegisterConditon("waitfor", function(args)
	local name, time = strsplit(",", args, 2)
	if time then
		local time = tonumber(time)
		local GetTime = GetTime()
		local currentTime = GetTime % 60
		if waitTable[name] ~= nil then
			if waitTable[name] + time < currentTime then
				waitTable[name] = nil
				return true
			end
		else
			waitTable[name] = currentTime
		end
	end
	return false
end)

NeP.DSL.RegisterConditon("IsNear", function(targetID, distance)
	local targetID = tonumber(targetID) or 0
	local distance = tonumber(distance) or 60
		for i=1,#NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]
			if Obj.id == targetID then
				if NeP.Engine.Distance('player', target) <= distance then
					return true
				end
			end
		end
	return false
end)