--
-- Token Buffer is a utility class for parsing tokens
-- That is, list-like tables with the first element being the name of the token
local table_copy = assert(foundation.com.table_copy)
local list_slice = assert(foundation.com.list_slice)

local function tokens_match(token, matcher)
  return token[1] == matcher
end

local function match_tokens(tokens, start, stop, token_matchers)
  local i = 1
  local len = #tokens

  local matched = false
  local j = start
  while j <= len and i <= stop do
    if tokens[j] then
      local token = tokens[j]
      local matcher_token = token_matchers[i]

      if tokens_match(token, matcher_token) then
        matched = true
      else
        return false
      end
    else
      return false
    end
    i = i + 1
    j = j + 1
  end

  return matched
end

local TokenBuffer = foundation.com.Class:extends("TokenBuffer")
local ic = TokenBuffer.instance_class

local function _check_readable(self)
  assert(self.m_mode == 'r' or self.m_mode == 'rw')
end

local function _check_writable(self)
  assert(self.m_mode == 'w' or self.m_mode == 'rw' or self.m_mode == 'a')
end

function ic:initialize(tokens, mode)
  self.m_mode = mode
  self.m_data = tokens or {}
  self:open(mode)
end

function ic:seek(cursor)
  self.m_cursor = cursor
  return self
end

function ic:isEOB()
  return self.m_cursor > #self.m_data
end

function ic:to_list()
  return table_copy(self.m_data)
end

function ic:open(mode)
  self.m_cursor = 1
  self.m_mode = mode or "r"
  -- append
  if self.m_mode == "a" then
    self.m_cursor = 1 + #self.m_data
  end
  return self
end

function ic:walk(distance)
  _check_readable(self)
  self.m_cursor = self.m_cursor + distance
  return self
end

function ic:push(token)
  _check_writable(self)
  self.m_data[self.m_cursor] = token
  self.m_cursor = self.m_cursor + 1
  return self
end

function ic:push_token(token_name, data)
  return self:push({token_name, data})
end

function ic:skip(token_name)
  _check_readable(self)
  if not self:isEOB() then
    local token = self.m_data[self.m_cursor]
    if tokens_match(token, token_name) then
      self.m_cursor = self.m_cursor + 1
      return true
    end
  end
  return false
end

function ic:peek(count)
  return list_slice(self.m_data, self.m_cursor, count)
end

-- @doc Returns a list of the matched tokens, or nil if no match
--
-- @spec :scan(...tokens :: [String]) :: [Token] | nil
function ic:scan(...)
  _check_readable(self)
  local token_matchers = {...}
  local token_matchers_len = #token_matchers

  local i = 1
  local len = #self.m_data

  local tokens = {}

  local j = self.m_cursor
  while j <= len and i <= token_matchers_len do
    if self.m_data[j] then
      local token = self.m_data[j]
      local matcher_token = token_matchers[i]

      if tokens_match(token, matcher_token) then
        table.insert(tokens, token)
      else
        return nil
      end
    else
      return nil
    end
    i = i + 1
    j = j + 1
  end
  self.m_cursor = j
  return tokens
end

function ic:scan_one(token_name)
  local tokens = self:scan(token_name)
  if tokens then
    return tokens[1]
  end
  return nil
end

function ic:scan_until(token_name)
  _check_readable(self)
  local i = 1
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      table.insert(tokens, self.m_data[j])
      if tokens_match(self.m_data[j], token_name) then
        break
      end
    else
      break
    end
    j = j + 1
  end
  self.m_cursor = j

  return tokens
end

function ic:scan_upto(token_name)
  _check_readable(self)
  local len = #self.m_data
  local tokens = {}

  local j = self.m_cursor
  while j <= len do
    if self.m_data[j] then
      if tokens_match(self.m_data[j], token_name) then
        break
      else
        table.insert(tokens, self.m_data[j])
      end
    else
      break
    end
    j = j + 1
  end
  self.m_cursor = j

  return tokens
end

-- @doc Checks if all the given token names match the curre
--
-- @spec :match_tokens(...tokens :: [String]) :: boolean
function ic:match_tokens(...)
  _check_readable(self)
  local token_matchers = {...}
  local token_matchers_len = #token_matchers
  return match_tokens(self.m_data, self.m_cursor, token_matchers_len, token_matchers)
end

yatm_oku.TokenBuffer = TokenBuffer
yatm_oku.match_tokens = match_tokens
