NeP.library = {
	libs = { }
}

NeP.library.register = function(name, lib)
	if NeP.library.libs[name] then
		NeP.Core.Debug('library', "Cannot overwrite library:" .. name)
		return false
	end
	NeP.library.libs[name] = lib
end

NeP.library.fetch = function(name)
	return NeP.library.libs[name]
end

NeP.library.parse = function(event, evaluation, target)
	if target == nil then target = "target" end
	local call = string.sub(evaluation, 2)
	local func
	-- this will work most of the time... I hope :)
	if string.sub(evaluation, -1) == ')' then
		-- the user calls the function for us
		func = loadstring('local target = "'..target..'";return NeP.library.libs.' .. call .. '')
	else
		-- we need to call the function
		func = loadstring('local target = "'..target..'";return NeP.library.libs.' .. call .. '(target)')
	end
	local eval = func and func(target, event) or false
	return eval
end