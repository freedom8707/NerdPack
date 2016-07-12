-- Final Table
NeP.OM = {
	unitEnemie = {},
	unitFriend = {},
	GameObjects = {}
}

-- Refresh OM & add to Final Table

local function RefreshOM()

	-- Make sure we're running
	--if NeP.Core.CurrentCR and peConfig.read('button_states', 'MasterToggle', false) then
		-- Wipe Cache
		wipe(NeP.OM.unitEnemie)
		wipe(NeP.OM.unitFriend)
		wipe(NeP.OM.GameObjects)
		--Refresh Enemine
		for i=1,#NeP.TempOM.unitEnemie do
			local Obj = NeP.TempOM.unitEnemie[i]
			if FireHack and ObjectExists(Obj.key) or not FireHack and UnitExists(Obj.key) then
				NeP.OM.unitEnemie[#NeP.OM.unitEnemie+1] = {
					key = Obj.key,
					name = Obj.name,
					is = Obj.is,
					id = Obj.id,
					class = Obj.class,
					distance = NeP.Engine.Distance('player', Obj.key),
					health = math.floor((UnitHealth(Obj.key) / UnitHealthMax(Obj.key)) * 100),
					maxHealth = UnitHealthMax(Obj.key),
					actualHealth = UnitHealth(Obj.key),
				}
			end
		end
		--Refresh Friendly
		for i=1,#NeP.TempOM.unitFriend do
			local Obj = NeP.TempOM.unitFriend[i]
			if FireHack and ObjectExists(Obj.key) or not FireHack and UnitExists(Obj.key) then
				NeP.OM.unitFriend[#NeP.OM.unitFriend+1] = {
					key = Obj.key,
					name = Obj.name,
					is = Obj.is,
					id = Obj.id,
					class = Obj.class,
					distance = NeP.Engine.Distance('player', Obj.key),
					health = math.floor((UnitHealth(Obj.key) / UnitHealthMax(Obj.key)) * 100),
					maxHealth = UnitHealthMax(Obj.key),
					actualHealth = UnitHealth(Obj.key),
				}
			end
		end
		--Refresh Objects
		for i=1,#NeP.TempOM.GameObjects do
			local Obj = NeP.TempOM.GameObjects[i]
			if FireHack and ObjectExists(Obj.key) or not FireHack and UnitExists(Obj.key) then
				NeP.OM.GameObjects[#NeP.OM.GameObjects+1] = {
					key = Obj.key,
					name = Obj.name,
					is = Obj.is,
					id = Obj.id,
					distance = NeP.Engine.Distance('player', Obj.key),
				}
			end
		end
	--end

end

--[[
	DESC: Checks if unit has a Blacklisted Debuff.
	This will remove the unit from the OM cache.
---------------------------------------------------]]
local BlacklistedAuras = {
		-- CROWD CONTROL
	[118] = '',        -- Polymorph
	[1513] = '',       -- Scare Beast
	[1776] = '',       -- Gouge
	[2637] = '',       -- Hibernate
	[3355] = '',       -- Freezing Trap
	[6770] = '',       -- Sap
	[9484] = '',       -- Shackle Undead
	[19386] = '',      -- Wyvern Sting
	[20066] = '',      -- Repentance
	[28271] = '',      -- Polymorph (turtle)
	[28272] = '',      -- Polymorph (pig)
	[49203] = '',      -- Hungering Cold
	[51514] = '',      -- Hex
	[61305] = '',      -- Polymorph (black cat)
	[61721] = '',      -- Polymorph (rabbit)
	[61780] = '',      -- Polymorph (turkey)
	[76780] = '',      -- Bind Elemental
	[82676] = '',      -- Ring of Frost
	[90337] = '',      -- Bad Manner (Monkey) -- FIXME: to check
	[115078] = '',     -- Paralysis
	[115268] = '',     -- Mesmerize
		-- MOP DUNGEONS/RAIDS/ELITES
	[106062] = '',     -- Water Bubble (Wise Mari)
	[110945] = '',     -- Charging Soul (Gu Cloudstrike)
	[116994] = '',     -- Unstable Energy (Elegon)
	[122540] = '',     -- Amber Carapace (Amber Monstrosity - Heat of Fear)
	[123250] = '',     -- Protect (Lei Shi)
	[143574] = '',     -- Swelling Corruption (Immerseus)
	[143593] = '',     -- Defensive Stance (General Nazgrim)
		-- WOD DUNGEONS/RAIDS/ELITES
	[155176] = '',     -- Damage Shield (Primal Elementalists - Blast Furnace)
	[155185] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155233] = '',     -- Dormant (Blast Furnace)
	[155265] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155266] = '',     -- Cotainment (Primal Elementalists - BRF)
	[155267] = '',     -- Cotainment (Primal Elementalists - BRF)
	[157289] = '',     -- Arcane Protection (Imperator Mar'Gok)
	[174057] = '',     -- Arcane Protection (Imperator Mar'Gok)
	[182055] = '',     -- Full Charge (Iron Reaver)
	[184053] = '',     -- Fel Barrier (Socrethar)
}

local function BlacklistedDebuffs(Obj)
	local isBadDebuff = false
	for i = 1, 40 do
		local spellID = select(11, UnitDebuff(Obj, i))
		if spellID ~= nil then
			if BlacklistedAuras[tonumber(spellID)] ~= nil then
				isBadDebuff = true
			end
		end
	end
	return isBadDebuff
end

--[[
	DESC: Checks if Object is a Blacklisted.
	This will remove the Object from the OM cache.
---------------------------------------------------]]
local BlacklistedObjects = {
	[76829] = '',		-- Slag Elemental (BrF - Blast Furnace)
	[78463] = '',		-- Slag Elemental (BrF - Blast Furnace)
	[60197] = '',		-- Scarlet Monastery Dummy
	[64446] = '',		-- Scarlet Monastery Dummy
	[93391] = '',		-- Captured Prisoner (HFC)
	[93392] = '',		-- Captured Prisoner (HFC)
	[93828] = '',		-- Training Dummy (HFC)
	[234021] = '',
	[234022] = '',
	[234023] = '',
}

local function BlacklistedObject(Obj)
	local _,_,_,_,_,ObjID = strsplit('-', UnitGUID(Obj) or '0')
	return BlacklistedObjects[tonumber(ObjID)] ~= nil
end

local Classifications = {
	['minus'] 		= 1,
	['normal'] 		= 2,
	['elite' ]		= 3,
	['rare'] 		= 4,
	['rareelite' ]	= 5,
	['worldboss' ]	= 6,
}

-- Temp Table
NeP.TempOM = {
	unitEnemie = {},
	unitFriend = {},
	GameObjects = {}
}

--[[
	DESC: Places the object in its correct place.
	This is done in a seperate function so we dont have
	to repeate code over and over again for all unlockers.
---------------------------------------------------]]
function NeP.OM.addToOM(Obj)
	if not BlacklistedObject(Obj) then
		if not BlacklistedDebuffs(Obj) then
			local objectType, _, _, _, _, _id, _ = strsplit('-', UnitGUID(Obj))
			local ID = tonumber(_id) or '0'
			-- Friendly
			if UnitIsFriend('player', Obj) and UnitHealth(Obj) > 0 then
				NeP.TempOM.unitFriend[#NeP.TempOM.unitFriend+1] = {
					key = Obj,
					name = UnitName(Obj),
					class = Classifications[tostring(UnitClassification(Obj))],
					distance = NeP.Engine.Distance('player', Obj),
					is = 'friendly',
					id = ID
				}
			-- Enemie
			elseif UnitCanAttack('player', Obj) and UnitHealth(Obj) > 0 then
				NeP.TempOM.unitEnemie[#NeP.TempOM.unitEnemie+1] = {
					key = Obj,
					name = UnitName(Obj),
					class = Classifications[tostring(UnitClassification(Obj))],
					distance = NeP.Engine.Distance('player', Obj),
					is = isDummy(Obj) and 'dummy' or 'enemie',
					id = ID
				}
			-- Object
			elseif FireHack and ObjectIsType(Obj, ObjectTypes.GameObject) then
				NeP.TempOM.GameObjects[#NeP.TempOM.GameObjects+1] = {
					key = Obj,
					name = UnitName(Obj) or '',
					distance = NeP.Engine.Distance('player', Obj),
					is = 'object',
					id = ID
				}
			end
		end
	end
end

-- Create a Temp OM contating all Objects
C_Timer.NewTicker(1, (function()

	-- wait until added from unlocker.
	if NeP.OM.Maker ~= nil then

		-- Wipe Cache
		wipe(NeP.TempOM.unitEnemie)
		wipe(NeP.TempOM.unitFriend)
		wipe(NeP.TempOM.GameObjects)

		-- Run OM depending on unlocker
		NeP.OM.Maker()

		-- Sort by distance
		table.sort(NeP.TempOM.unitEnemie, function(a,b) return a.distance < b.distance end)
		table.sort(NeP.TempOM.unitFriend, function(a,b) return a.distance < b.distance end)
		table.sort(NeP.TempOM.GameObjects, function(a,b) return a.distance < b.distance end)

	end

end), nil)

local DiesalTools = LibStub('DiesalTools-1.0')
local DiesalStyle = LibStub('DiesalStyle-1.0')
local DiesalGUI = LibStub('DiesalGUI-1.0')
local DiesalMenu = LibStub('DiesalMenu-1.0')
local SharedMedia = LibStub('LibSharedMedia-3.0')

-- Tables to Control Status Bars Used
local statusBars = { }
local statusBarsUsed = { }

NeP.OM.List = DiesalGUI:Create('Window')
local OMListGUI = NeP.OM.List
OMListGUI:SetWidth(500)
OMListGUI:SetHeight(250)
OMListGUI:SetTitle('ObjectManager GUI')
OMListGUI.frame:SetClampedToScreen(true)
OMListGUI:Hide()

local ListWindow = DiesalGUI:Create('ScrollFrame')
OMListGUI:AddChild(ListWindow)
ListWindow:SetParent(OMListGUI.content)
ListWindow:SetAllPoints(OMListGUI.content)
ListWindow.OMListGUI = OMListGUI

local function getStatusBar()
	local statusBar = tremove(statusBars)
	if not statusBar then
		statusBar = DiesalGUI:Create('StatusBar')
		statusBar:SetParent(ListWindow.content)
		OMListGUI:AddChild(statusBar)
		statusBar.frame:SetStatusBarColor(1,1,1,0.35)
	end
	statusBar:Show()
	table.insert(statusBarsUsed, statusBar)
	return statusBar
end

local function recycleStatusBars()
	for i = #statusBarsUsed, 1, -1 do
		statusBarsUsed[i]:Hide()
		tinsert(statusBars, tremove(statusBarsUsed))
	end
end

local OMTables = {
	['Enemie'] = NeP.OM.unitEnemie,
	['Friendly'] = NeP.OM.unitFriend,
	['GameObjects'] = NeP.OM.GameObjects
}

local function RefreshGUI()
	local tempTable = {}

	-- Combine all tables..
	for i=1, #NeP.OM.unitEnemie do tempTable[#tempTable+1] = NeP.OM.unitEnemie[i] end
	for i=1, #NeP.OM.unitFriend do tempTable[#tempTable+1] = NeP.OM.unitFriend[i] end
	for i=1, #NeP.OM.GameObjects do tempTable[#tempTable+1] = NeP.OM.GameObjects[i] end
	table.sort(tempTable, function(a,b) return a.distance < b.distance end)

	local offset = -5
	recycleStatusBars()

	for i=1,#tempTable do
		local Obj = tempTable[i]
		local ID = Obj.id or ''
		local Name = Obj.name or ''
		local Distance = Obj.distance or ''
		local Health = Obj.health or 100
		local classColor = NeP.Core.classColor(Obj.key)
		local statusBar = getStatusBar()

		statusBar.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
		statusBar.frame.Left:SetText('|cff'..classColor..Name)
		statusBar.frame.Right:SetText('( |cffff0000ID|r: '..ID..' / |cffff0000Health|r: '..Health..' / |cffff0000Distance|r: '..Distance..' )')

		statusBar.frame:SetScript('OnMouseDown', function(self) TargetUnit(Obj.key) end)
		statusBar:SetValue(Health)
		offset = offset -17
	end
end

-- Run OM
C_Timer.NewTicker(0.25, (function()
	RefreshOM()
	if NeP.OM.List:IsShown() then RefreshGUI() end
end), nil)
