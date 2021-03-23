--
-- Helper math/arithemtic/logic functions for use by the various data nodes
--
-- This operates on little-endian encoded byte vectors
local data_math = {}

-- Retrieves the value at the specific index
--
-- @spec elem(String | Table, Integer) :: Integer | nil
local function elem(object, index)
  if type(object) == "string" then
    return string.byte(object, index)
  elseif type(object) == "table" then
    return object[index]
  else
    error("unexpected object")
  end
end

function data_math.new_number(leading, config, padding)
  assert(type(config) == "table", "expected config table")
  local result = leading or ""
  padding = padding or "\x00"
  while config.byte_size > #result do
    result = result .. padding
  end
  return result
end

function data_math.new_vector(value, size)
  local result = {}
  local i = 0

  if value == nil then
    for i = 1,size do
      result[i] = 0
    end
  else
    for i = 1,size do
      result[i] = elem(value, i) or 0
    end
  end

  return result
end

function data_math.perform_borrow(accumulator, i, config)
  --accumulator[i] = accumulator[i] + 1
  local j = i
  while accumulator[j] <= 0 and j <= config.byte_size do
    j = j + 1
  end
  while j > i do
    accumulator[j] = accumulator[j] - 1
    accumulator[j - 1] = accumulator[j - 1] + 256
    j = j - 1
  end
end

function data_math.identity(left, right, config)
  assert(type(config) == "table")

  for i = 1,config.byte_size do
    local lb = elem(left, i) or 0
    local rb = elem(right, i) or 0

    if lb > 0 then
      return data_math.new_number(left, config)
    elseif rb > 0 then
      return data_math.new_number(right, config)
    end
  end
  -- if neither, just return the left-hand
  return data_math.new_number(left, config)
end

function data_math.add(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(nil, config.byte_size)
  local carry = data_math.new_vector(nil, config.byte_size)

  for i = 1,config.byte_size do
    local lb = elem(left, i) or 0
    local rb = elem(right, i) or 0

    accumulator[i] = accumulator[i] + lb + rb + carry[i]

    carry[i] = 0
    if accumulator[i] > 255 then
      carry[i + 1] = math.floor(accumulator[i] / 256)
    end
    accumulator[i] = accumulator[i] % 256
  end

  local result = {}
  for i = 1,config.byte_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.subtract(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.byte_size)

  for i = 1,config.byte_size do
    local byte = elem(right, i) or 0
    accumulator[i] = accumulator[i] - byte
    if accumulator[i] < 0 then
      data_math.perform_borrow(accumulator, i, config)
    end
  end

  local result = {}
  for i = 1,config.byte_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.multiply(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(nil, config.byte_size)
  local carry = 0

  for i = 1,config.byte_size do
    local lb = elem(left, i) or 0
    carry = 0
    for j = 1,config.byte_size do
      local acc_index = ((i - 1) + j) % config.byte_size

      local rb = elem(right, j) or 0

      local value = lb * rb
      value = (accumulator[acc_index] or 0) + value + carry
      carry = math.floor(value / 256)
      value = value % 256
      accumulator[acc_index] = value
    end
  end

  local result = {}
  for i = 1,config.byte_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.divide(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.byte_size)
  local carry = data_math.new_vector(nil, config.byte_size)

  for i = 1,config.byte_size do
    local byte = elem(right, i) or 0

    if byte == 0 then
      -- division by zero immediately maxes out every value in the accumulator
      accumulator[i] = 255
    else
      if accumulator[i] < byte then
        data_math.perform_borrow(accumulator, i, config)
      end
      local res = math.floor(accumulator[i] / byte)
      --local mod = accumulator[i] % byte
      accumulator[i] = res
      carry[i] = 0
      if accumulator[i] > 255 then
        carry[i + 1] = math.floor(accumulator[i] / 256)
      end
      accumulator[i] = accumulator[i] % 256
    end
  end

  local result = {}
  for i = 1,config.byte_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.modulo(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.byte_size)

  local result = {}
  for i = 1,config.byte_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.max(left, right, config)
  assert(type(config) == "table")
  for i = 1,config.byte_size do
    local lb = elem(left, 1 + config.byte_size - i) or 0
    local rb = elem(right, 1 + config.byte_size - i) or 0

    if rb > lb then
      return data_math.new_number(right, config)
    elseif lb > rb then
      return data_math.new_number(left, config)
    end
  end

  return data_math.new_number(left, config)
end

function data_math.min(left, right, config)
  assert(type(config) == "table")
  for i = 1,config.byte_size do
    local lb = elem(left, 1 + config.byte_size - i) or 0
    local rb = elem(right, 1 + config.byte_size - i) or 0

    if rb < lb then
      return data_math.new_number(right, config)
    elseif lb < rb then
      return data_math.new_number(left, config)
    end
  end

  return data_math.new_number(left, config)
end

function data_math.identity_vector(left, right, config)
  assert(type(config) == "table")
  local identity = data_math.new_vector(nil, config.vector_size)

  for i = 1,config.vector_size do
    local lb = elem(left, i)
    local rb = elem(right, i)
    if lb and lb > 0 then
      identity[i] = lb
    elseif rb and rb > 0 then
      identity[i] = rb
    else
      identity[i] = 0
    end
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(identity[i])
  end

  return table.concat(result)
end

function data_math.add_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    accumulator[i] = (accumulator[i] + byte) % 256
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.subtract_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    accumulator[i] = (accumulator[i] - byte) % 256
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.multiply_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    accumulator[i] = (accumulator[i] * byte) % 256
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.divide_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    if byte == 0 then
      accumulator[i] = 255 -- simulate some infinite condition without crashing
    else
      accumulator[i] = math.floor(accumulator[i] / byte) % 256
    end
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.modulo_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    if byte == 0 then
      accumulator[i] = 255 -- simulate some infinite condition without crashing
    else
      accumulator[i] = math.floor(accumulator[i] % byte) % 256
    end
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.max_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    if byte > accumulator[i] then
      accumulator[i] = byte
    end
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

function data_math.min_vector(left, right, config)
  assert(type(config) == "table")
  local accumulator = data_math.new_vector(left, config.vector_size)

  for i = 1,config.vector_size do
    local byte = elem(right, i) or 0

    if byte < accumulator[i] then
      accumulator[i] = byte
    end
  end

  local result = {}
  for i = 1,config.vector_size do
    result[i] = string.char(accumulator[i])
  end

  return table.concat(result)
end

yatm_data_logic.data_math = data_math
