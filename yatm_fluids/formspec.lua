local fspec = assert(foundation.com.formspec.api)
local FluidStack = assert(yatm_fluids.FluidStack)
local fluid_registry = assert(yatm_fluids.fluid_registry)

local formspec = {}

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
--   amount: Number
-- ): String
function formspec.render_fluid_tank(x, y, w, h, fluid_name, amount, max)
  local fluid = fluid_registry.get_fluid(fluid_name)

  local fluid_h = h * amount / max

  local fluid_color = DEFAULT_FLUID_COLOR.color

  if fluid and fluid.color then
    fluid_color = fluid.color
  end

  return fspec.box(x, y, w, h, "#292729") ..
    fspec.box(x, y, w, fluid_h, fluid_color) ..
    fspec.tooltip_area(x, y, w, h, fluid_name .. " " .. amount .. " / " .. max)
end

-- @spec render_fluid_stack(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   fluid_stack: FluidStack
-- )
function formspec.render_fluid_stack(x, y, w, h, fluid_stack, max)
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
    max
  )
end

yatm_fluids.formspec = formspec
