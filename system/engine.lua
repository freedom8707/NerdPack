NeP.Engine = {
	Run = false,
	SelectedCR = nil,
	ForceTarget = nil,
	lastCast = nil,
	forcePause = false,
	Current_Spell = nil,
	HarmfulSpell = false,
	Rotations = {},
	------------------------------------ Fake Units ------------------------------------
	FakeUnits = {
		['lowest'] 		= function() return 	 NeP.Healing['lowest']() 					end,
		['!lowest'] 	= function() return '!'..NeP.Healing['lowest']() 					end,
		['tank'] 		= function() return 	 NeP.Healing['tank']() 						end,
		['!tank'] 		= function() return '!'..NeP.Healing['tank']() 						end,
		['tanktarget'] 	= function() return 	 NeP.Healing['tank']()..'target' 			end,
		['!tanktarget'] = function() return '!'..NeP.Healing['tank']()..'target' 			end,
		['nil'] 		= function() return UnitExists('target') and 'target' or 'player' 	end
	}
}

local Engine = NeP.Engine
local fetchKey = NeP.Interface.fetchKey
local TA = NeP.Core.TA

local ListClassSpec = {
	[0] = {}, -- None
	[1] = { -- Warrior
		[71] = 'Arms',
		[72] = 'Fury',
		[73] = 'Protection',
	},
	[2] = {  -- Paladin
		[65] = 'Holy',
		[66] = 'Protection',
		[70] = 'Retribution',
	},
	[3] = { -- Hunter
		[253] = 'Beast Mastery',
		[254] = 'Marksmanship',
		[255] = 'Survival',
	},
	[4] = { -- Rogue
		[259] = 'Assassination',
		[260] = 'Combat',
		[261] = 'Subtlety',
	},
	[5] = {  -- Priest
		[256] = 'Discipline',
		[257] = 'Holy',
		[258] = 'Shadow',
	},
	[6] = { -- DeathKnight
		[250] = 'Blood',
		[251] = 'Frost',
		[252] = 'Unholy',
	},
	[7] = {  -- Shaman
		[262] = 'Elemental',
		[263] = 'Enhancement',
		[264] = 'Restoration',
	},
	[8] = {  -- Mage
		[62] = 'Arcane',
		[63] = 'Fire',
		[64] = 'Frost',
	},
	[9] = { -- Warlock
		[265] = 'Affliction',
		[266] = 'Demonology',
		[267] = 'Destruction',
	},
	[10] = { -- Monk
		[268] = 'Brewmaster',
		[269] = 'Windwalker',
		[270] = 'Mistweaver',
	},
	[11] = { -- Druid
		[102] = 'Balance',
		[103] = 'Feral Combat',
		[104] = 'Guardian',
		[105] = 'Restoration',
	},
	[12] = { -- Demon Hunter
		[577] = 'Havoc',
		[581] = 'Vengeance',
	}
}

-- Register CRs
function Engine.registerRotation(SpecID, CrName, InCombat, outCombat, initFunc)
	-- Only Load Crs for our current class (saves memory)
	local Spec = GetSpecialization() or 0
	local SpecInfo = GetSpecializationInfo(Spec)
	local localizedClass, englishClass, classIndex = UnitClass('player')
	if ListClassSpec[tonumber(classIndex)][tonumber(SpecID)] ~= nil then
		-- If SpecID Table is not created yet, create one.
		if NeP.Engine.Rotations[SpecID] == nil then NeP.Engine.Rotations[SpecID] = {} end
		-- In case someone tries to load a cr with the same name of a existing one
		local TableName = CrName
		if NeP.Engine.Rotations[SpecID][CrName] ~= nil then TableName = CrName..'_'..math.random(0,1000) end
		-- Create CR table
		NeP.Engine.Rotations[SpecID][TableName] = {
			[true] = InCombat,
			[false] = outCombat,
			['InitFunc'] = initFunc or (function() return end),
			['Name'] = CrName
		}
	end
end


local function insertToLog(whatIs, spell, target)
	local targetName = UnitName(target or 'player')
	local name, icon
	if whatIs == 'Spell' then
		local spellIndex, spellBook = GetSpellBookIndex(spell)
		if spellBook then
			local spellID = select(2, GetSpellBookItemInfo(spellIndex, spellBook))
			name, _, icon = GetSpellInfo(spellIndex, spellBook)
		else
			name, _, icon = GetSpellInfo(spellIndex)
		end
	elseif whatIs == 'Item' or whatIs == 'InvItem' then
		name, _,_,_,_,_,_,_,_, icon = GetItemInfo(spell)
	end
	NeP.MFrame.usedButtons['MasterToggle'].texture:SetTexture(icon)
	NeP.ActionLog.insert(whatIs, name, icon, targetName)
end

local function Cast(spell, target, ground)
	if ground then
		NeP.Engine.CastGround(spell, target)
	else
		NeP.Engine.Cast(spell, target)
	end
	NeP.Engine.lastCast = spell
	insertToLog('Spell', spell, target)
end

local function checkTarget(target)
	local target = tostring(target)
	local ground = false
	-- Allow functions/conditions to force a target
	if NeP.Engine.ForceTarget then
		target = NeP.Engine.ForceTarget
		NeP.Engine.ForceTarget = nil
	end
	-- Ground target
	if string.sub(target, -7) == '.ground' then
		ground = true
		target = string.sub(target, 0, -8)
	end
	-- Fake Target
	if Engine.FakeUnits[target] then
		target = Engine.FakeUnits[target]()
	end
	-- Sanity Checks
	if HarmfulSpell and not UnitCanAttack('player', target) then return false end
	if UnitExists(target) and NeP.Engine.LineOfSight('player', target) then
		return true, target, ground
	end
	return false
end

local function castSanityCheck(spell)
	if type(spell) == 'string' then
		-- Turn string to number
		if string.match(spell, '%d') then
			spell = tonumber(spell)
		end
		-- SOME SPELLS DO NOT CAST BY IDs! (make them names...)
		local spell = GetSpellInfo(spell)
		if spell then
			NeP.Core.Debug('Engine', 'castSanityCheck_Spell:'..spell)

			-- Make sure we have the spell
			local skillType, spellId = GetSpellBookItemInfo(spell)
			if skillType == 'FUTURESPELL' then
				NeP.Core.Debug('Engine', 'castSanityCheck hit FUTURESPELL')
				return false
			end

			-- Set Var (Gonna be needed for checking target)
			HarmfulSpell = IsHarmfulSpell(spell)

			-- Spell Sanity Checks
			if IsUsableSpell(spell) and GetSpellCooldown(spell) == 0 then
				NeP.Core.Debug('Engine', 'castSanityCheck passed')
				NeP.Engine.Current_Spell = spell
				return true, spell
			end
		end

	end
	return false, nil
end

local function canIterate()
	if UnitCastingInfo('player') == nil
	and UnitChannelInfo('player') == nil
	and not UnitIsDeadOrGhost('player') then
		return true
	end
	return false
end

local function castingTime(target)
    local _,_,_,_,_, endTime= UnitCastingInfo(target)
    if endTime then return endTime end
    return false
end

local invItems = {
	['head']		= 'HeadSlot',
	['helm']		= 'HeadSlot',
	['neck']		= 'NeckSlot',
	['shoulder']	= 'ShoulderSlot',
	['shirt']		= 'ShirtSlot',
	['chest']		= 'ChestSlot',
	['belt']		= 'WaistSlot',
	['waist']		= 'WaistSlot',
	['legs']		= 'LegsSlot',
	['pants']		= 'LegsSlot',
	['feet']		= 'FeetSlot',
	['boots']		= 'FeetSlot',
	['wrist']		= 'WristSlot',
	['bracers']		= 'WristSlot',
	['gloves']	 	= 'HandsSlot',
	['hands']		= 'HandsSlot',
	['finger1']		= 'Finger0Slot',
	['finger2']		= 'Finger1Slot',
	['trinket1'] 	= 'Trinket0Slot',
	['trinket2'] 	= 'Trinket1Slot',
	['back']		= 'BackSlot',
	['cloak']		= 'BackSlot',
	['mainhand'] 	= 'MainHandSlot',
	['offhand']		= 'SecondaryHandSlot',
	['weapon']		= 'MainHandSlot',
	['weapon1']		= 'MainHandSlot',
	['weapon2']		= 'SecondaryHandSlot',
	['ranged'] 		= 'RangedSlot'
}

local SpecialTrigers = {
	-- Cancel cast
	['!'] = function(spell, conditons, target)
		local spell = string.sub(spell, 2);
		local canCast, spell = castSanityCheck(spell)
		if canCast then
			local conditions = NeP.DSL.parse(conditons, spell)
			if conditions then
				local castingTime = castingTime('player')
				if not castingTime or castingTime > 1 then
					local hasTarget, target, ground = checkTarget(target)
					if hasTarget then
						SpellStopCasting()
						Cast(spell, target, ground)
						return true
					end
				end
			end
		end
		return false
	end,
	-- Item (FIXME)
	['#'] = function(spell, conditons, target)
		if canIterate() then
			local item = string.sub(spell, 2);
			local conditions = NeP.DSL.parse(conditons, spell)
			if conditions then
				if invItems[tostring(item)] then
					local item = GetInventoryItemID('player', invItems[tostring(item)])
					local isUsable, notEnoughMana = IsUsableItem(item)
					if isUsable then
						local itemStart, itemDuration, itemEnable = GetInventoryItemCooldown('player', item)
						if itemStart == 0 then
							insertToLog('InvItem', item, target)
							NeP.Engine.UseInvItem(item)
							return true
						end
					end
				else
					local isUsable, notEnoughMana = IsUsableItem(item)
					if isUsable then
						local itemStart, itemDuration, itemEnable = GetItemCooldown(item)
						if itemStart == 0 and GetItemCount(item) > 0 then
							insertToLog('Item', item, target)
							NeP.Engine.UseItem(item, target)
							return true
						end
					end
				end
			end
		end
		return false
	end,
	-- Lib
	['@'] = function(spell, conditons, target)
		if canIterate() then
			local conditions = NeP.DSL.parse(conditons, '')
			if conditions then
				NeP.library.parse(false, spell, target)
				return true
			end
			return false
		end
	end,
	-- Macro
	['/'] = function(spell, conditons, target)
		if canIterate() then
			local conditions = NeP.DSL.parse(conditons, spell)
			if conditions then
				NeP.Engine.Macro(spell)
				return true
			end
			return false
		end
	end
}

-- This allows for nesting a nest inside 1k nests and more...
local function IterateNest(table)
	local tempTable = {}
	for i=1, #table do tempTable[#tempTable+1] = table[i] end
	Engine.Iterate(tempTable)
end

-- This iterates the routine table itself.
function Engine.Iterate(table)
	for i=1, #table do
		local line = table[i]
		local spell = line[1]
		local target = line[3]
		local _type = type(spell)
		NeP.Core.Debug('Engine', 'Iterate: TYPE_'.._type..' -- '..tostring(spell))
		-- Nested
		if _type == 'table' then
			NeP.Core.Debug('Engine', 'Iterate: Hit Table')
			local conditions = NeP.DSL.parse(line[2], '')
			if conditions then
				NeP.Core.Debug('Engine', 'Iterate: passed Table conditions')
				IterateNest(spell)
			end
		-- Function
		elseif _type == 'function' then
			NeP.Core.Debug('Engine', 'Iterate: Hit Func')
			if canIterate() then
				local conditions = NeP.DSL.parse(line[2], '')
				if conditions then
					NeP.Core.Debug('Engine', 'Iterate: passed func conditions')
					spell()
					break
				end
			end
		-- Normal cast
		elseif _type == 'string' then
			NeP.Core.Debug('Engine', 'Iterate: Hit String')
			local prefix = string.sub(spell, 1, 1)
			-- Pause
			if spell == 'pause' then
				NeP.Core.Debug('Engine', 'Iterate: Hit Pause')
				local conditions = NeP.DSL.parse(line[2], spell)
				if conditions then
					NeP.Core.Debug('Engine', 'Iterate: passed pause conditions')
					break
				end
			-- Special trigers
			elseif SpecialTrigers[prefix] then
				NeP.Core.Debug('Engine', 'Iterate: Hit Special Trigers')
				local shouldBreak = SpecialTrigers[prefix](spell, line[2], target)
				if shouldBreak then break end
			-- Regular sanity checks
			elseif canIterate() then
				NeP.Core.Debug('Engine', 'Iterate: Hit Normal')
				local canCast, spell = castSanityCheck(spell)
				if canCast then
					NeP.Core.Debug('Engine', 'Iterate: Can Cast')
					local conditions = NeP.DSL.parse(line[2], spell)
					if conditions then
						NeP.Core.Debug('Engine', 'Iterate: passed cast conditions')
						local hasTarget, target, ground = checkTarget(target)
						if hasTarget then
							NeP.Core.Debug('Engine', 'Iterate: Has Target: '..target..' Ground: '..tostring(ground))
							Cast(spell, target, ground)
							break
						end
					end
				end
			end
		end
	end
end

local function EngineTimeOut()
	local Setting = fetchKey('NePSettings', 'NeP_Cycle', 'Standard')
	if Setting == 'Standard' then
		return 0.5
	elseif Setting == 'Random' then
		local RND = math.random(3, 7)/10
		return tonumber(RND)
	else
		local MTC = fetchKey('NePSettings', 'MCT', 0.5)
		return tonumber(MTC)
	end
end

-- Engine Ticker
local LastTimeOut = 0
C_Timer.NewTicker(0.1, (function()

	local Running = NeP.Config.Read('bStates_MasterToggle', false)
	if Running and not NeP.Engine.forcePause then

		local CurrentTime = GetTime();
		if CurrentTime >= LastTimeOut then

			local TimeOut = EngineTimeOut()

			-- Hide FaceRoll.
			NeP.FaceRoll:Hide()

			-- Run the engine.
			if NeP.Engine.SelectedCR then
				local InCombatCheck = UnitAffectingCombat('player')
				local table = NeP.Engine.SelectedCR[InCombatCheck]
				Engine.Iterate(table)
			else
				NeP.Core.Message(TA('Engine', 'NoCR'))
			end

			LastTimeOut = CurrentTime + TimeOut
		end
	end
end), nil)
