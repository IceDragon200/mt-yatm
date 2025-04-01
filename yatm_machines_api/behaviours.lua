--[[

  Device / Machine Behaviours.

  Behaviours define specific actions or features of a machine, such as auto-ejecting.

]]
local Directions = assert(foundation.com.Directions)

local ItemExchange = assert(yatm.items.ItemExchange)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local FluidStack = assert(yatm.fluids.FluidStack)

yatm.devices.behaviours = yatm.devices.behaviours or {}
local m = yatm.devices.behaviours

--- @namespace yatm.NodeBehaviours.helpers
m.helpers = {}

--- Decodes the direction flags from a 8-bit value, where each flag is 1 bit and the higher
--- 2 are unused.
--- The remainder of the code is returned as the last value.
---
--- @spec decode_directions_code8(code: Integer):
---   (n: Integer, e: Integer, s: Integer, w: Integer, d: Integer, u: Integer, code: Integer)
function m.helpers.decode_directions_code8(code)
  local north = code % 2
  code = math.floor(code / 2)
  local east = code % 2
  code = math.floor(code / 2)
  local south = code % 2
  code = math.floor(code / 2)
  local west = code % 2
  code = math.floor(code / 2)
  local down = code % 2
  code = math.floor(code / 2)
  local up = code % 2
  code = math.floor(code / 2)
  return north, east, south, west, down, up, code
end

local decode_directions_code8 = assert(m.helpers.decode_directions_code8)

--
-- Fluid Auto Eject
-- The fluid auto eject behaviour allows the parent node to move its output fluids to an adjacent
-- node without the need for a fluid transport (extractor/inserter).
--
--- @namespace yatm.NodeBehaviours.fluid_auto_eject
m.fluid_auto_eject = {
  id = "faej",
  STATE_NONE = 0,
  STATE_OUTPUT = 1,
}

--- Initialize the auto eject details for the specified node
---
--- @spec init(pos: Vector3, node: NodeRef): void
function m.fluid_auto_eject.init(pos, node)
  local meta = core.get_meta(pos)
  -- i(tem) a(uto) ej(ect)
  local iaej = tonumber(meta:get("faej_code") or 0)
  meta:set_int("faej_code", old)
end

--- @spec exec(pos: Vector3, node: NodeRef, meta: MetaRef): void
function m.fluid_auto_eject.exec(pos, node, meta)
  local faej_code = meta:get_int("faej_code")
  local n, e, s, w, d, u = decode_directions_code8(faej_code)

  n = Directions.D_NORTH * n
  e = Directions.D_EAST * e
  s = Directions.D_SOUTH * s
  w = Directions.D_WEST * w
  d = Directions.D_DOWN * d
  u = Directions.D_UP * u

  --- how many items to transfer each work step
  local wildcard = FluidStack.new_wildcard(1)

  if n > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      n,
      wildcard,
      true
    )
  end

  if e > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      e,
      wildcard,
      true
    )
  end

  if s > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      s,
      wildcard,
      true
    )
  end

  if w > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      w,
      wildcard,
      true
    )
  end

  if d > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      d,
      wildcard,
      true
    )
  end

  if u > 0 then
    FluidExchange.transfer_from_tank_to_adjacent_tank(
      pos,
      u,
      wildcard,
      true
    )
  end
end

--- Auto Eject for machines.
---
--- @spec work(WorkContext): Number
function m.fluid_auto_eject.work(ctx)
  m.fluid_auto_eject.exec(ctx.pos, ctx.node, ctx.meta)
  return 0
end

--
-- Item Auto Eject
-- The item auto eject behaviour allows the parent node to move its output items to an adjacent
-- node without the need for an item transport (extractor/inserter).
--
--- @namespace yatm.NodeBehaviours.item_auto_eject
m.item_auto_eject = {
  id = "iaej",
  STATE_NONE = 0,
  STATE_OUTPUT = 1,
}

--- Initialize the auto eject details for the specified node
---
--- @spec init(pos: Vector3, node: NodeRef): void
function m.item_auto_eject.init(pos, node)
  local meta = core.get_meta(pos)
  -- i(tem) a(uto) ej(ect)
  local iaej = tonumber(meta:get("iaej_code") or 0)
  meta:set_int("iaej_code", old)
end

--- @spec exec(pos: Vector3, node: NodeRef, meta: MetaRef): void
function m.item_auto_eject.exec(pos, node, meta)
  local iaej_code = meta:get_int("iaej_code")
  local n, e, s, w, d, u = decode_directions_code8(iaej_code)

  n = Directions.D_NORTH * n
  e = Directions.D_EAST * e
  s = Directions.D_SOUTH * s
  w = Directions.D_WEST * w
  d = Directions.D_DOWN * d
  u = Directions.D_UP * u

  --- how many items to transfer each work step
  local count = 1

  if n > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      n,
      count,
      true
    )
  end

  if e > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      e,
      count,
      true
    )
  end

  if s > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      s,
      count,
      true
    )
  end

  if w > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      w,
      count,
      true
    )
  end

  if d > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      d,
      count,
      true
    )
  end

  if u > 0 then
    ItemExchange.transfer_from_device_to_adjacent_device(
      pos,
      u,
      count,
      true
    )
  end
end

--- Auto Eject for machines.
---
--- @spec work(WorkContext): Number
function m.item_auto_eject.work(ctx)
  m.item_auto_eject.exec(ctx.pos, ctx.node, ctx.meta)
  return 0
end
