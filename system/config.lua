NeP.Config = {}
local Config = NeP.Config
local data = {}

function Config.Load(tbl)
  --debug.print('Config Data Loaded', 'Config')
  if tbl == nil then
    NePData = {}
    data = NePData
  else
    data = tbl
  end
end

function Config.Read(key, ...)
  --debug.print('Reading Config Key: ' .. key, 'Config')
  key = tostring(key)
  local length = select('#', ...)
  local default
  if length > 0 then
    default = select(length, ...)
  end

  if length <= 1 then
    if data[key] ~= nil then
      return data[key]
    elseif default ~= nil then
      data[key] = default
      return data[key]
    else
      return nil
    end
  end

  local _key = data[key]
  if not _key then
    data[key] = {}
    _key = data[key]
  end
  local __key
  for i = 1, length - 2 do
    __key = tostring(select(i, ...))
    if _key[__key] then
      _key = _key[__key]
    else
      _key[__key] = {}
      _key = _key[__key]
    end
  end
  __key = tostring(select(length - 1, ...))

  if _key[__key] then
    return _key[__key]
  elseif default ~= nil then
    _key[__key] = default
    return default
  end

  return nil
end

function Config.Write(key, ...)
 -- debug.print('Writing Config Key: ' .. key, 'Config')
  key = tostring(key)
  local length = select('#', ...)
  local value = select(length, ...)

  if length == 1 then
    data[key] = value
    return
  end

  local _key = data[key]
  if not _key then
    data[key] = {}
    _key = data[key]
  end
  local __key
  for i = 1, length - 2 do
    __key = tostring(select(i, ...))
    if _key[__key] then
      _key = _key[__key]
    else
      _key[__key] = {}
      _key = _key[__key]
    end
  end

  __key = tostring(select(length - 1, ...))
  _key[__key] = value
end

function Config.Toggle(key)
  --debug.print('Toggling Config Key: ' .. key, 'Config')
  key = tostring(key)
  data[key] = not data[key]
  return data[key]
end