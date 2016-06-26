local Intf = NeP.Interface
local Tittle = '|cff'..Intf.addonColor..NeP.Info.Name
local Logo = '|T'..Intf.Logo..':15:15|t'
local Config = NeP.Config
local Round = NeP.Core.Round
local fetchKey = NeP.Interface.fetchKey
local TA = NeP.Core.TA

NeP.MFrame = {
	buttonPadding = 2,
	buttonSize = 40,
	Buttons = {},
	usedButtons = {},
	Settings = {},
	Plugins = {}
}

local E, _L, V, P, G
if IsAddOnLoaded("ElvUI") then
	E, _L, V, P, G = unpack(ElvUI)
	ElvSkin = E:GetModule('ActionBars')
	NeP.MFrame.buttonPadding = 2
	NeP.MFrame.buttonSize = 32
end

-- These are the default toggles.
local function defaultToggles()
	Intf.CreateToggle('MasterToggle', 'Interface\\ICONS\\Ability_repair.png', 'MasterToggle', TA('mainframe', 'MasterToggle'), function(self) NeP.FaceRoll:Hide() end)
	Intf.CreateToggle('Interrupts', 'Interface\\ICONS\\Ability_Kick.png', 'Interrupts', TA('mainframe', 'Interrupts'))
	Intf.CreateToggle('Cooldowns', 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png', 'Cooldowns', TA('mainframe', 'Cooldowns'))
	Intf.CreateToggle('AoE', 'Interface\\ICONS\\Ability_Druid_Starfall.png', 'AoE', TA('mainframe', 'AoE'))
end

-- These are the default Settings.
local function defaultSettings()
	Intf.CreateSetting(TA('mainframe', 'OM'), function() NeP.OM.List:Show() end)
	Intf.CreateSetting(TA('mainframe', 'AL'), function() PE_ActionLog:Show() end)
	Intf.CreateSetting(TA('mainframe', 'Settings'), function() NeP.Interface.ShowGUI('NePSettings') end)
	Intf.CreateSetting(TA('mainframe', 'HideNeP'), function() NePFrame:Hide(); NeP.Core.Print(TA('Any', 'NeP_Show')) end)
end

Intf.CreateSetting = function(name, func)
	NeP.MFrame.Settings[#NeP.MFrame.Settings+1] = {
		name = tostring(name),
		func = func
	}
end

Intf.ResetSettings = function()
	wipe(NeP.MFrame.Settings)
	defaultSettings()
end

Intf.CreatePlugin = function(name, func)
	NeP.MFrame.Plugins[#NeP.MFrame.Plugins+1] = {
		name = tostring(name),
		func = func
	}
end

Intf.CreateToggle = function(key, icon, name, tooltipz, callback)
	func = function(self)
		if callback then
			callback(self)
		end
		self.actv = not self.actv
		self:SetChecked(self.actv)
		Config.Write('bStates_'..key, self.actv)
	end
	NeP.MFrame.Buttons[#NeP.MFrame.Buttons+1] = {
		key = tostring(key),
		name = tostring(name),
		tooltip = tooltipz,
		icon = icon,
		func = func
	}
	Intf.RefreshToggles()
end

local function LoadCrs(info)
	local Spec = GetSpecialization()
	if Spec then
		local SpecInfo = GetSpecializationInfo(Spec)
		local routinesTable = NeP.Engine.Rotations[SpecInfo]
		if routinesTable then
			local lastCR = Config.Read('NeP_SlctdCR_'..(SpecInfo))
			for k,v in pairs(routinesTable) do
				local rState = (lastCR == k) or false
				info = UIDropDownMenu_CreateInfo()
				info.text = v['Name']
				info.value = k
				info.checked = rState
				info.func = function(self)
					self.checked = not self.checked
					NeP.Core.Print(TA('mainframe', 'ChangeCR')..' ( '..v['Name']..' )')
					Intf.ResetToggles()
					Intf.ResetSettings()
					Config.Write('NeP_SlctdCR_'..(SpecInfo), k)
					NeP.Core.updateSpec()
				end
				UIDropDownMenu_AddButton(info)
			end
		else
			info = UIDropDownMenu_CreateInfo()
			info.notCheckable = 1
			info.text = TA('mainframe', 'NoCR')
			UIDropDownMenu_AddButton(info)
		end
	else
		info = UIDropDownMenu_CreateInfo()
		info.notCheckable = 1
		info.text = TA('mainframe', 'NoSpec')
		UIDropDownMenu_AddButton(info)
	end
end

local function createButtons(key, icon, name, tooltip, func)
	if NeP.MFrame.usedButtons[key] ~= nil then
		NeP.MFrame.usedButtons[key]:Show()
	else
		local pos = (NeP.MFrame.buttonSize*#NeP.MFrame.Buttons)+(#NeP.MFrame.Buttons*NeP.MFrame.buttonPadding)-(NeP.MFrame.buttonSize+NeP.MFrame.buttonPadding)
		NeP.MFrame.usedButtons[key] = CreateFrame("CheckButton", key, NePFrame, 'ActionButtonTemplate')
		local temp = NeP.MFrame.usedButtons[key]
		temp:SetPoint("TOPLEFT", NePFrame, pos, -( NePFrame.TF:GetHeight() ))
		temp:SetSize(NeP.MFrame.buttonSize, NeP.MFrame.buttonSize)
		temp:SetFrameLevel(3)
		temp:SetNormalFontObject("GameFontNormal")
		temp.texture = temp:CreateTexture()
		temp.texture:SetTexture(icon)
		temp.texture:SetAllPoints()

		if ElvSkin then
			ElvSkin.db = E.db.actionbar
			temp.texture:SetTexCoord(.08, .92, .08, .92)
			ElvSkin:StyleButton(temp)
			temp:CreateBackdrop('Default')
			local htex = temp:CreateTexture()
			htex:SetTexture(NeP.Core.classColor('player', 'RBG', 0.65))
			htex:SetAllPoints()
			temp:SetCheckedTexture(htex)
		else
			local htex = temp:CreateTexture()
			htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
			htex:SetTexCoord(0, 0.625, 0, 0.6875)
			htex:SetAllPoints()
			temp:SetHighlightTexture(htex)
			temp:SetPushedTexture(htex)
		end
		temp.actv = Config.Read('bStates_'..key, false)
		temp:SetChecked(temp.actv)
		temp:SetScript("OnClick", func)
		temp:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("|cffffffff"..name..' '..(self.actv and '|cff08EE00'..TA('Any', 'ON') or '|cffFF0000'..TA('Any', 'OFF')).."|r")
			if tooltip then
				GameTooltip:AddLine(tooltip)
			end
			GameTooltip:Show()
		end)
		temp:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

	end
end

-- Refresh Toggles
Intf.RefreshToggles = function()
	-- Update Sizes
	--local testU = #NeP.MFrame.Buttons+1
	for k,v in pairs(NeP.MFrame.usedButtons) do
		--testU = testU-1
		NeP.MFrame.usedButtons[k]:SetSize(NeP.MFrame.buttonSize, NeP.MFrame.buttonSize)
		--local pos = (NeP.MFrame.buttonSize*testU)+(testU*NeP.MFrame.buttonPadding)-(NeP.MFrame.buttonSize+NeP.MFrame.buttonPadding)
		--NeP.MFrame.usedButtons[k]:SetPoint("TOPLEFT", NePFrame, pos, -(NePFrame.TF:GetHeight()))
	end
	-- Create buttons
	for k,v in pairs(NeP.MFrame.Buttons) do
		createButtons( v.key, v.icon, v.name, v.tooltip, v.func )
	end
	NePFrame:SetSize(#NeP.MFrame.Buttons*NeP.MFrame.buttonSize+(NeP.MFrame.buttonPadding*#NeP.MFrame.Buttons), NeP.MFrame.buttonSize+NePFrame.TF:GetHeight())
	NePFrame.TF:SetPoint('TOP', NePFrame, 0, 0)
end

-- Reset Toggles
Intf.ResetToggles = function()
	--hide toggles
	for k,v in pairs(NeP.MFrame.usedButtons) do
		NeP.MFrame.usedButtons[k]:Hide()
	end
	wipe(NeP.MFrame.Buttons)
	--Create defaults
	defaultToggles()
end

-- Wait until saved vars are loaded
function Config.CreateMainFrame()

	-- Read Saved Frame Position
	local POS_1 = Config.Read('NePFrame_POS_1', 'TOP')
	local POS_2 = Config.Read('NePFrame_POS_2', 0)
	local POS_3 = Config.Read('NePFrame_POS_3', 0)

	-- Update size
	local NeP_Size = fetchKey('NePSettings', 'tSize', 40)
	if NeP_Size < 25 then NeP_Size = 40 end
	NeP.MFrame.buttonSize = NeP_Size

	--parent frame 
	NePFrame = CreateFrame("Frame", "NePFrame", UIParent)
	NePFrame:SetPoint(POS_1, POS_2, POS_3)
	NePFrame:SetMovable(true)
	NePFrame:EnableMouse(true)
	NePFrame:RegisterForDrag('LeftButton')
	NePFrame:SetScript('OnDragStart', NePFrame.StartMoving)
	NePFrame:SetScript('OnDragStop', function(self)
		local from, _, to, x, y = self:GetPoint()
		self:StopMovingOrSizing()
		Config.Write('NePFrame_POS_1', from)
		Config.Write('NePFrame_POS_2', x)
		Config.Write('NePFrame_POS_3', y)
	end)
	NePFrame:SetFrameLevel(0)
	NePFrame:SetFrameStrata('HIGH')
	NePFrame:SetClampedToScreen(true)

	-- Tittle
	NePFrame.TF = CreateFrame("Frame", nil, NePFrame)
	NePFrame.TF:SetFrameLevel(1)
	NePFrame.TF.TT = NePFrame.TF:CreateFontString(nil, "OVERLAY")
	NePFrame.TF.TT:SetPoint('RIGHT', NePFrame.TF, -4, 0)
	NePFrame.TF.TT:SetFont('Fonts\\FRIZQT__.TTF', 17)
	NePFrame.TF.TT:SetText(Tittle)
	NePFrame.TF.TT:SetTextColor(1,1,1,1)
	if ElvSkin then
		NePFrame.TF:CreateBackdrop('Default')
		NePFrame.TF:SetSize(NePFrame.TF.TT:GetStringWidth()+33, NePFrame.TF.TT:GetStringHeight())
	else
		NePFrame.TF:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		NePFrame.TF:SetBackdropColor(0,0,0,1);
		NePFrame.TF:SetSize(NePFrame.TF.TT:GetStringWidth()+33, NePFrame.TF.TT:GetStringHeight()+4)
	end
	NePFrame.TF:SetPoint('TOP', NePFrame, 0, 0)
	NePFrame:SetSize(#NeP.MFrame.Buttons*NeP.MFrame.buttonSize, NeP.MFrame.buttonSize+NePFrame.TF.TT:GetStringHeight())

	local function STDR_initialize(self)
		local info = UIDropDownMenu_CreateInfo()
		-- Routines
		info.isTitle = 1
		info.notCheckable = 1
		info.text = 'Combat Routines:'
		UIDropDownMenu_AddButton(info)
		LoadCrs(info)
		-- Settings
		info.isTitle = 1
		info.notCheckable = 1
		info.text = 'Settings:'
		UIDropDownMenu_AddButton(info)
		local settingsTable = NeP.MFrame.Settings or { ['Cant find any Setting...'] = '' }
		for k,v in pairs(settingsTable) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v.name
			info.value = v.name
			info.func = v.func
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
		-- Plugins
		info.isTitle = 1
		info.notCheckable = 1
		info.text = 'Plugins:'
		UIDropDownMenu_AddButton(info)
		local pluginsTable = NeP.MFrame.Plugins or { ['Cant find any Plugin...'] = '' }
		for k,v in pairs(pluginsTable) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v.name
			info.value = v.name
			info.func = v.func
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end

	end
	local function STDR_onClick(self, button)
		local ST_Dropdown = CreateFrame("Frame", "ST_Dropdown", self, "UIDropDownMenuTemplate");
		UIDropDownMenu_Initialize(ST_Dropdown, STDR_initialize, "MENU");
		ToggleDropDownMenu(1, nil, ST_Dropdown, self, 0, 0);
	end
	local ST_DB = CreateFrame("Button", nil, NePFrame.TF)
	ST_DB:SetPoint("LEFT", NePFrame.TF, 0, 0)
	ST_DB:SetFrameLevel(2)
	ST_DB:SetText(Logo)
	ST_DB:SetNormalFontObject("GameFontNormal")
	ST_DB:SetScript("OnClick", func)
	if ElvSkin then
		local texture = ST_DB:CreateTexture()
		texture:SetTexture(0, 0, 0, 0.75)
		texture:SetAllPoints() 
		ST_DB:SetSize(25, NePFrame.TF.TT:GetStringHeight())
	else
		ST_DB:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		ST_DB:SetBackdropColor(0,0,0,1);
		ST_DB:SetSize(25, NePFrame.TF.TT:GetStringHeight()+4)
	end
	local htex = ST_DB:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	ST_DB:SetNormalTexture(ntex) 
	ST_DB:SetHighlightTexture(htex)
	ST_DB:SetPushedTexture(htex)
	ST_DB:RegisterForClicks('anyUp')
	ST_DB:RegisterForDrag('LeftButton', 'RightButton')
	ST_DB:SetScript('OnClick', STDR_onClick)
	ST_DB:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine('|cffffffff'..TA('mainframe', 'Settings')..'|r')
		GameTooltip:Show()
	end)
	ST_DB:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

	-- Create Defaults
	defaultSettings()
	defaultToggles()

end