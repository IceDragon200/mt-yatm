local fspec = assert(foundation.com.formspec.api)
local FluidStack = assert(yatm_fluids.FluidStack)
local fluid_registry = assert(yatm_fluids.fluid_registry)
local Color = assert(foundation.com.Color)

local formspec = yatm.formspec

local DEFAULT_FLUID_COLOR = {
  last_set_by = "yatm_fluids",
  color = "#FFFFFF",
}

--
-- Sets the default color used by render_fluid_tank
--
-- @spec set_default_fluid_color(Color): void
function formspec.set_default_fluid_color(color)
  DEFAULT_FLUID_COLOR = {
    last_set_by = minetest.get_current_modname(),
    color = assert(color),
  }
end

-- @spec render_fluid_tank(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   fluid_name: String,
--   amount: Number,
--   is_horz: Boolean
-- ): String
function formspec.render_fluid_tank(x, y, w, h, fluid_name, amount, max, is_horz)
  local fluid = fluid_registry.get_fluid(fluid_name)

  local fluid_color = DEFAULT_FLUID_COLOR.color

  if fluid and fluid.color then
    fluid_color = fluid.color
  end

  return formspec.render_gauge{
    x = x,
    y = y,
    w = w,
    h = h,
    gauge_color = fluid_color,
    border = "yatm_item_border_liquid.png",
    amount = amount,
    max = max,
    is_horz = is_horz,
    tooltip = fluid_name .. " " .. amount .. " / " .. max,
  }
end

--
--
--
-- @spec render_fluid_stack(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   fluid_stack: FluidStack,
--   max: Number,
--   is_horz: Boolean
-- )
function formspec.render_fluid_stack(x, y, w, h, fluid_stack, max, is_horz)
  local fluid_name = ""
  local fluid_amount = 0

  if fluid_stack then
    fluid_name = fluid_stack.name
    fluid_amount = fluid_stack.amount
  end

  return formspec.render_fluid_tank(
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

yatm_fluids.formspec = formspec
