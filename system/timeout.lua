NeP.timeOut = {}
local timeout = NeP.timeOut
local timeouts = {}

function timeout.set(name, timeout, callback)
	timeouts[name] = {
		callback = callback,
		timeout = timeout,
		start = GetTime()
	}
end

function timeout.check(name)
	if timeouts[name] ~= nil then
		return (GetTime() - timeouts[name].start)
	end
	return false
end

C_Timer.NewTicker(0.1, (function()
	for name, struct in pairs(timeouts) do
		if GetTime() >= (struct.start + struct.timeout) then
			if struct.callback then
				struct.callback()
			end
			timeouts[name] = nil
		end
	end
end), nil)