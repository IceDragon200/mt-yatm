local fspec = assert(foundation.com.formspec.api)
local FluidStack = assert(yatm_fluids.FluidStack)
local fluid_registry = assert(yatm_fluids.fluid_registry)
local Color = assert(foundation.com.Color)

--- @namespace yatm.formspec
local mod = yatm.formspec

local DEFAULT_FLUID_COLOR = {
  last_set_by = "yatm_fluids",
  color = "#FFFFFF",
}

---
--- Sets the default color used by render_fluid_tank
---
--- @spec set_default_fluid_color(Color): void
function mod.set_default_fluid_color(color)
  DEFAULT_FLUID_COLOR = {
    last_set_by = minetest.get_current_modname(),
    color = assert(color),
  }
end

--- @spec render_fluid_tank(
---   x: Number,
---   y: Number,
---   w: Number,
---   h: Number,
---   fluid_name: String,
---   amount: Number,
---   is_horz: Boolean
--- ): String
function mod.render_fluid_tank(x, y, w, h, fluid_name, amount, max, is_horz)
  local fluid

  if fluid_name then
    fluid = fluid_registry.get_fluid(fluid_name)
  end

  local fluid_color = DEFAULT_FLUID_COLOR.color
  local tooltip = (fluid_name or "") .. " " .. amount .. " / " .. max

  if fluid and fluid.color then
    fluid_color = fluid.color
  end

  return mod.render_gauge{
    x = x,
    y = y,
    w = w,
    h = h,
    gauge_color = fluid_color,
    border_name = "yatm_item_border_liquid.png",
    amount = amount,
    max = max,
    is_horz = is_horz,
    tooltip = tooltip,
  }
end

---
---
---
--- @spec render_fluid_stack(
---   x: Number,
---   y: Number,
---   w: Number,
---   h: Number,
---   fluid_stack: FluidStack,
---   max: Number,
---   is_horz: Boolean
--- ): String
function mod.render_fluid_stack(x, y, w, h, fluid_stack, max, is_horz)
  local fluid_name = ""
  local fluid_amount = 0

  if fluid_stack then
    fluid_name = fluid_stack.name
    fluid_amount = fluid_stack.amount
  end

  return mod.render_fluid_tank(
    x,
    y,
    w,
    h,
    fluid_name,
    fluid_amount,
    max,
    is_horz
  )
end

--- @spec render_fluid_inventory(
---   fluid_inventory: FluidInventory,
---   list_name: String,
---   is_horz: Boolean,
---   x: Number,
---   y: Number,
---   cw: Number | nil,
---   ch: Number | nil,
---   cols: Number,
---   rows: Number,
---   start_index?: Number
--- ): String
function mod.render_fluid_inventory(inv, list_name, is_horz, x, y, cw, ch, cols, rows, start_index)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  cw = cw or cis(1)
  ch = ch or cw

  start_index = start_index or 0

  local blob = ""

  local inv_size = inv:get_size(list_name)
  local stack_size = inv:get_max_stack_size(list_name)
  local cx
  local cy
  local fluid_stack

  local max_size = math.min(cols * rows, inv_size)
  if max_size > 0 then
    local rel_i
    for i = start_index,max_size-1 do
      rel_i = i - start_index
      fluid_stack = inv:get_fluid_stack(list_name, i+1)
      cx = x + cio(rel_i % cols)
      cy = y + cio(math.floor(rel_i / cols))

      blob =
        blob
        .. mod.render_fluid_stack(cx, cy, cw, ch, fluid_stack, stack_size, is_horz)
    end
  end

  return blob
end

--- @namespace yatm_fluids

--- @const formspec = yatm.formspec
yatm_fluids.formspec = mod
