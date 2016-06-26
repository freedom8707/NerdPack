NeP.DSL = {
	Conditions = {}
}

local DSL = NeP.DSL

local comparator_table = { }
local parse_table = { }

local conditionizers = {
	['modifier'] = true,
	['!modifier'] = true
}

local conditionizers_single = {
	['toggle'] = true,
	['!toggle'] = true
}

local tableComparator = {
	['>='] 	= function(value, compare_value) return value >= compare_value 	end,
	['<='] 	= function(value, compare_value) return value <= compare_value 	end,
	['>'] 	= function(value, compare_value) return value >  compare_value 	end,
	['<'] 	= function(value, compare_value) return value <  compare_value 	end,
	['='] 	= function(value, compare_value) return value == compare_value 	end,
	['=='] 	= function(value, compare_value) return value == compare_value 	end,
	['!='] 	= function(value, compare_value) return value ~= compare_value 	end,
	['!'] 	= function(value, compare_value) return value ~= compare_value 	end
}

local getConditionalSpell = function(dsl, spell)
	-- check if we are passing a spell with the conditional
	if string.match(dsl, '(.+)%((.+)%)') then
		return string.match(dsl, '(.+)%((.+)%)')
	else
		return dsl, spell
	end
end

local comparator = function(condition, target, condition_spell)

	if not condition then return false end

	local modify_not = false

	if target and type(target) == "string" then
		if string.sub(target, 1, 1) == '!' then
			target = string.sub(target, 2)
			modify_not = true
		end
	end

	if string.sub(condition, 1, 1) == '!' then
		condition = string.sub(condition, 2)
		modify_not = true
	end

	local arg1, arg2, arg3 = strsplit(' ', condition, 3)
	if arg1 then table.insert(comparator_table, arg1) end
	if arg2 then table.insert(comparator_table, arg2) end
	if arg3 then table.insert(comparator_table, arg3) end

	local evaluation = false
	if #comparator_table == 3 then

		local compare_value = tonumber(comparator_table[3])
		local condition_call = DSL.get(comparator_table[1])(target, condition_spell, compare_value)
		local call_type = type(condition_call)

		if call_type ~= "number" then
			if tonumber(condition_call) then
				call_type = "number"
				condition_call = tonumber(condition_call)
			end
		end

		if call_type == "number" then
			local value = condition_call
			
			if compare_value == nil then
				evaluation = comparator_table[3] == condition_call
			else
				local tempComp = comparator_table[2]
				if tableComparator[tempComp] ~= nil then
					evaluation = tableComparator[tempComp](value, compare_value)
				else
					evaluation = false
				end
			end
		else
			evaluation = condition_call
		end

	else
		evaluation = DSL.get(condition)(target, condition_spell)
	end
	if modify_not then
		return not evaluation
	end
	return evaluation
end

local conditionize = function(target, condition)
	if conditionizers[target] then
		return target..'.'..condition
	elseif conditionizers_single[target] then
		return target
	else
		return condition
	end
end

-- FIXME: Does not work for nested OR's
local function Nested(table, spell)
	local tempTable = {[1] = ''}
	for k,v in ipairs(table) do
		if v == 'or' then
			tempTable[#tempTable+1] = ''
		else
			if tempTable[#tempTable] ~= false then
				tempTable[#tempTable] = DSL.parse(v, spell) or false
			end
		end
	end
	for i=1, #tempTable do
		if tempTable[i] ~= false then return true end
	end
	return false
end

local parsez = function(dsl, spell)

	local unitId, arg2, arg3 = strsplit('.', dsl, 3)

	-- Fake Units (Tank/Lowest)
	if NeP.Engine.FakeUnits[unitId] then
		unitId = NeP.Engine.FakeUnits[unitId]()
	end

	if unitId then table.insert(parse_table, unitId) end
	if arg2 then table.insert(parse_table, arg2) end
	if arg3 then table.insert(parse_table, arg3) end

	local size = #parse_table
	if size == 1 then
		local condition, spell = string.match(dsl, '(.+)%((.+)%)')
		return comparator(condition, spell, spell)
	elseif size == 2 then
		local target = parse_table[1]
		local condition, condition_spell = getConditionalSpell(parse_table[2], spell)
		condition = conditionize(target, condition)
		if conditionizers_single[target] then
			return comparator(condition, parse_table[2], condition_spell)
		end
		return comparator(condition, target, condition_spell)
	elseif size == 3 then
		local target = parse_table[1]
		local condition, condition_spell, subcondition = getConditionalSpell(parse_table[2], spell)
		condition = conditionize(target, condition)
		return comparator(condition..'.'..parse_table[3], target, condition_spell)
	end

	return DSL.get(dsl)('target', spell)
end

local typesTable = {
	['function'] = function(dsl, spell) return dsl() 					end,
	['table']	 = function(dsl, spell) return Nested(dsl, spell)		end,
	['string']	 = function(dsl, spell) return parsez(dsl, spell)		end,
	['lib']		 = function(dsl, spell) return NeP.library.parse(false, dsl, 'target')	end,
	['nil']		 = function(dsl, spell) return true						end,
	['boolean']	 = function(dsl, spell) return dsl						end,
}

DSL.parse = function(dsl, spell)
	wipe(comparator_table)
	wipe(parse_table)
	local dslType = type(dsl)
	if dslType == 'string' then
		-- Lib
		if string.sub(dsl, 1, 1) == '@' then dslType = 'lib' end
	end
	return typesTable[dslType](dsl, spell)
end

DSL.get = function(condition)
	if DSL.Conditions[condition] then
		return DSL.Conditions[condition]
	else
		return (function() return false end)
	end
end

DSL.RegisterConditon = function(name, eval)
	DSL.Conditions[name] = eval
end