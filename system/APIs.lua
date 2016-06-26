NeP.APIs = {}

local APIs = NeP.APIs

APIs['UnitBuff'] = function(target, spell, owner)
    local buff, count, caster, expires, spellID
    if tonumber(spell) then
	    local i = 0; local go = true
	    while i <= 40 and go do
	        i = i + 1
	        buff,_,_,count,_,_,expires,caster,_,_,spellID = _G['UnitBuff'](target, i)
	        if not owner then
	        	if spellID == tonumber(spell) and caster == "player" then go = false end
	        elseif owner == "any" then
	        	if spellID == tonumber(spell) then go = false end
	        end
	    end
    else
    	buff,_,_,count,_,_,expires,caster = _G['UnitBuff'](target, spell)
    end
    return buff, count, expires, caster
end

APIs['UnitDebuff'] = function(target, spell, owner)
    local debuff, count, caster, expires, spellID
    if tonumber(spell) then
	    local i = 0; local go = true
	    while i <= 40 and go do
	        i = i + 1
	        debuff,_,_,count,_,_,expires,caster,_,_,spellID,_,_,_,power = _G['UnitDebuff'](target, i)
	        if not owner then
	        	if spellID == tonumber(spell) and caster == "player" then go = false end
	        elseif owner == "any" then
	       		if spellID == tonumber(spell) then go = false end
	        end
	    end
    else
    	debuff,_,_,count,_,_,expires,caster = _G['UnitDebuff'](target, spell)
    end
    return debuff, count, expires, caster, power
end