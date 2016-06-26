NeP.Listener.locals = {
	moving = false,
	movingTime = 0,
	combat = false,
	combatTime = 0
}

NeP.Listener.register("ADDON_LOADED", function(...)

	local addon = ...

	if string.lower(addon) ~= string.lower(NeP.Info.Name) then return end

	-- load all our config data
	NeP.Config.Load(NePData)

end)

NeP.Listener.register("PLAYER_LOGIN", function(...)
	-- Execute Inits
	NeP.Config.CreateMainFrame()
	NeP.Config.CreateSettingsFrame()
	NeP.Core.updateSpec()
	NeP.Listener.register("PLAYER_SPECIALIZATION_CHANGED", function(unitID)
		if unitID == 'player' then
			NeP.Core.updateSpec()
		end
	end)
end)

NeP.Listener.register("PLAYER_ENTERING_WORLD", function(...)
	-- Wipe OM to avoid Crashing
	wipe(NeP.TempOM.unitEnemie)
	wipe(NeP.TempOM.unitFriend)
	wipe(NeP.TempOM.GameObjects)
	wipe(NeP.OM.unitEnemie)
	wipe(NeP.OM.unitFriend)
	wipe(NeP.OM.GameObjects)
end)

NeP.Listener.register("UNIT_SPELLCAST_SUCCEEDED", function(...)
	local unitID, spell, rank, lineID, spellID = ...
	if unitID == "player" then
		local name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spell)
		NeP.ActionLog.insert('Spell Cast Succeed', name, icon)
	end
end)

NeP.Listener.register("PLAYER_STARTED_MOVING", function(...)
	NeP.Listener.locals.moving = true
	NeP.Listener.locals.movingTime = GetTime()
end)

NeP.Listener.register("PLAYER_STOPPED_MOVING", function(...)
	NeP.Listener.locals.moving = false
	NeP.Listener.locals.movingTime = GetTime()
end)

NeP.Listener.register("PLAYER_REGEN_DISABLED", function(...)
	NeP.Listener.locals.combat = true
	NeP.Listener.locals.combatTime = GetTime()
end)