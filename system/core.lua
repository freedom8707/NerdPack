NeP = {
	Info = {
		Name = 'NerdPack',
		Nick = 'NeP',
		Author = 'MrTheSoulz',
		Version = '7.0.3.1',
		Branch = 'BETA',
	},
	Interface = {
		Logo = 'Interface\\AddOns\\NerdPack\\media\\logo.blp',
		addonColor = '0070DE',
		printColor = '|cffFFFFFF',
		mediaDir = 'Interface\\AddOns\\NerdPack\\media\\',
	},
	Core = {},
	Locale = {}
}

local printPrefix = '|r[|cff'..NeP.Interface.addonColor..NeP.Info.Nick..'|r]: '..NeP.Interface.printColor


local locale = GetLocale()
function NeP.Core.TA(gui, index)
	--[[
		"frFR": French (France)
		"deDE": German (Germany)
		"enGB : English (Great Brittan) if returned, can substitute 'enUS' for consistancy
		"enUS": English (America)
		"itIT": Italian (Italy)
		"koKR": Korean (Korea) RTL - right-to-left
		"zhCN": Chinese (China) (simplified) implemented LTR left-to-right in WoW
		"zhTW": Chinese (Taiwan) (traditional) implemented LTR left-to-right in WoW
		"ruRU": Russian (Russia)
		"esES": Spanish (Spain)
		"esMX": Spanish (Mexico)
		"ptBR": Portuguese (Brazil)
	]]
	if NeP.Locale[locale] then
		if NeP.Locale[locale][gui] then
			if NeP.Locale[locale][gui][index] then
				return NeP.Locale[locale][gui][index]
			end
		end
	end
	return NeP.Locale['enUS'][gui][index]
end

local TrackedDummys = {
	[31144] = 'dummy',		-- Training Dummy - Lvl 80
	[31146] = 'dummy',		-- Raider's Training Dummy - Lvl ??
	[32541] = 'dummy', 		-- Initiate's Training Dummy - Lvl 55 (Scarlet Enclave)
	[32542] = 'dummy',		-- Disciple's Training Dummy - Lvl 65
	[32545] = 'dummy',		-- Initiate's Training Dummy - Lvl 55
	[32546] = 'dummy',		-- Ebon Knight's Training Dummy - Lvl 80
	[32666] = 'dummy',		-- Training Dummy - Lvl 60
	[32667] = 'dummy',		-- Training Dummy - Lvl 70
	[46647] = 'dummy',		-- Training Dummy - Lvl 85
	[67127] = 'dummy',		-- Training Dummy - Lvl 90
	[87318] = 'dummy',		-- Dungeoneer's Training Dummy <Damage> ALLIANCE GARRISON
	[87761] = 'dummy',		-- Dungeoneer's Training Dummy <Damage> HORDE GARRISON
	[87322] = 'dummy',		-- Dungeoneer's Training Dummy <Tanking> ALLIANCE ASHRAN BASE
	[88314] = 'dummy',		-- Dungeoneer's Training Dummy <Tanking> ALLIANCE GARRISON
	[88836] = 'dummy',		-- Dungeoneer's Training Dummy <Tanking> HORDE ASHRAN BASE
	[88288] = 'dummy',		-- Dunteoneer's Training Dummy <Tanking> HORDE GARRISON
	[87317] = 'dummy',		-- Dungeoneer's Training Dummy - Lvl 102 (Lunarfall - Damage)
	[87320] = 'dummy',		-- Raider's Training Dummy - Lvl ?? (Stormshield - Damage)
	[87329] = 'dummy',		-- Raider's Training Dummy - Lvl ?? (Stormshield - Tank)
	[87762] = 'dummy',		-- Raider's Training Dummy - Lvl ?? (Warspear - Damage)
	[88837] = 'dummy',		-- Raider's Training Dummy - Lvl ?? (Warspear - Tank)
	[88906] = 'dummy',		-- Combat Dummy - Lvl 100 (Nagrand)
	[88967] = 'dummy',		-- Training Dummy - Lvl 100 (Lunarfall, Frostwall)
	[89078] = 'dummy',		-- Training Dummy - Lvl 100 (Lunarfall, Frostwall)
}

function isDummy(Obj)
	local _,_,_,_,_,ObjID = strsplit('-', UnitGUID(Obj) or '0')
	return TrackedDummys[tonumber(ObjID)] ~= nil
end

local lastPrint = ''
function NeP.Core.Print(txt)
	local text = tostring(txt)
	if text ~= lastPrint then
		print(printPrefix..text)
		lastPrint = text
	end
end

local lastMSG = ''
function NeP.Core.Message(txt)
	local text = tostring(txt)
	if text ~= lastMSG then
	message(printPrefix..text)
		lastMSG = text
	end
end

local debug = false
function NeP.Core.Debug(prefix, txt)
	if debug then
		local prefix, text = tostring(prefix), tostring(txt)
		print(printPrefix..'(DEBUG): ('..prefix..') '..text)
	end
end

function NeP.Core.Round(num, idp)
	if num then
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	else
		return 0
	end
end

local _rangeTable = {
	['melee'] = 1.5,
	['ranged'] = 40,
}

function NeP.Core.UnitAttackRange(unitA, unitB, _type)
	if IsHackEnabled then 
		return _rangeTable[_type] + UnitCombatReach(unitA) + UnitCombatReach(unitB)
	else
		-- Unlockers wich dont have UnitCombatReach like functions...
		return _rangeTable[_type] + 3.5
	end
end

function GetSpellID(spell)
	if type(spell) == 'number' then return spell end

	local spellID = string.match(GetSpellLink(spell) or '', 'Hspell:(%d+)|h')
	if spellID then
		return tonumber(spellID)
	end

	return false
end

function GetSpellName(spell)
	local spellID = tonumber(spell)
	if spellID then
		return GetSpellInfo(spellID)
	end

	return spell
end

function GetSpellBookIndex(spell)
	local spellName = GetSpellName(spell)
	if not spellName then return false end
	spellName = string.lower(spellName)

	for t = 1, 2 do
		local _, _, offset, numSpells = GetSpellTabInfo(t)
		local i
		for i = 1, (offset + numSpells) do
			if string.lower(GetSpellBookItemName(i, BOOKTYPE_SPELL)) == spellName then
				return i, BOOKTYPE_SPELL
			end
		end
	end

	local numFlyouts = GetNumFlyouts()
	for f = 1, numFlyouts do
		local flyoutID = GetFlyoutID(f)
		local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
		if isKnown and numSlots > 0 then
			for g = 1, numSlots do
				local spellID, _, isKnownSpell = GetFlyoutSlotInfo(flyoutID, g)
				local name = GetSpellName(spellID)
				if name and isKnownSpell and string.lower(GetSpellName(spellID)) == spellName then
					return spellID, nil
				end
			end
		end
	end

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		for i = 1, numPetSpells do
			if string.lower(GetSpellBookItemName(i, BOOKTYPE_PET)) == spellName then
				return i, BOOKTYPE_PET
			end
		end
	end

	return false
end

function hasTalent(row, col)
	local group = GetActiveSpecGroup()
	local talentId, talentName, icon, selected, active = GetTalentInfo(row, col, group)
	return active and selected
end

function UnitID(target)
	local guid = UnitGUID(target)
	if guid then
		local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)

		if type == "Player" then return tonumber(ServerID) end
		if npc_id then return tonumber(npc_id) end
	end
	return false
end

function NeP.Core.updateSpec()
	local Spec = GetSpecialization()
	if Spec then
		local SpecInfo = GetSpecializationInfo(Spec)
		local SlctdCR = NeP.Config.Read('NeP_SlctdCR_'..SpecInfo)
		if NeP.Engine.Rotations[SpecInfo] then
			if NeP.Engine.Rotations[SpecInfo][SlctdCR] then
				NeP.Interface.ResetToggles()
				NeP.Interface.ResetSettings()
				NeP.Engine.SelectedCR = NeP.Engine.Rotations[SpecInfo][SlctdCR]
				NeP.Engine.Rotations[SpecInfo][SlctdCR]['InitFunc']()
			end
		end
	end
end

local _classColors = {
	['HUNTER'] = 		{ r = 0.67, g = 0.83, 	b = 0.45, 	Hex = 'abd473' },
	['WARLOCK'] = 		{ r = 0.58, g = 0.51, 	b = 0.79, 	Hex = '9482c9' },
	['PRIEST'] = 		{ r = 1.0, 	g = 1.0, 	b = 1.0, 	Hex = 'ffffff' },
	['PALADIN'] = 		{ r = 0.96, g = 0.55, 	b = 0.73, 	Hex = 'f58cba' },
	['MAGE'] = 			{ r = 0.41, g = 0.8, 	b = 0.94, 	Hex = '69ccf0' },
	['ROGUE'] = 		{ r = 1.0, 	g = 0.96, 	b = 0.41, 	Hex = 'fff569' },
	['DRUID'] = 		{ r = 1.0, 	g = 0.49, 	b = 0.04, 	Hex = 'ff7d0a' },
	['SHAMAN'] = 		{ r = 0.0, 	g = 0.44, 	b = 0.87, 	Hex = '0070de' },
	['WARRIOR'] = 		{ r = 0.78, g = 0.61, 	b = 0.43, 	Hex = 'c79c6e' },
	['DEATHKNIGHT'] = 	{ r = 0.77, g = 0.12 , 	b = 0.23, 	Hex = 'c41f3b' },
	['MONK'] = 			{ r = 0.0, 	g = 1.00 , 	b = 0.59, 	Hex = '00ff96' },
}

function NeP.Core.classColor(unit, _type, alpha)
	if _type == nil then _type = 'HEX' end
	if UnitIsPlayer(unit) then
		local class, className = UnitClass(unit)
		local color = _classColors[className]
		if _type == 'HEX' then
			return color.Hex
		elseif _type == 'RBG' then
			return color.r, color.g, color.b, alpha
		end
	else
		return 'FFFFFF'
	end
end