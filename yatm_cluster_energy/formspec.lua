local fspec = assert(foundation.com.formspec.api)
local Color = assert(foundation.com.Color)
local Energy = assert(yatm_cluster_energy.energy)
local get_meta_energy = assert(Energy.get_meta_energy)

local formspec = yatm.formspec

local DEFAULT_ENERGY_COLOR = {
  last_set_by = "yatm_cluster_energy",
  color = "#29b785",
}

--
-- Sets the default color used by render_energy_gauge
--
-- @spec set_default_energy_color(Color): void
function formspec.set_default_energy_color(color)
  DEFAULT_ENERGY_COLOR = {
    last_set_by = minetest.get_current_modname(),
    color = assert(color),
  }
end

-- @spec render_energy_gauge({
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   amount: Number,
--   capacity: Number,
--   is_horz: Boolean
-- }): String
function formspec.render_energy_gauge(options)
  local x = options.x
  local y = options.y
  local w = options.w
  local h = options.h
  local amount = assert(options.amount)
  local max = assert(options.max)
  local is_horz = options.is_horz

  local gauge_h = h * amount / max

  local color = DEFAULT_ENERGY_COLOR.color

  return formspec.render_gauge{
    x = x,
    y = y,
    w = w,
    h = h,
    gauge_color = color,
    border_name = "yatm_item_border_energy.png",
    amount = amount,
    max = max,
    is_horz = is_horz,
    tooltip = "Energy " .. amount .. " / " .. max,
  }
end

-- @spec render_meta_energy_gauge(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   meta: MetaRef,
--   key: String,
--   capacity: Number,
--   is_horz: Boolean
-- ): String
function formspec.render_meta_energy_gauge(x, y, w, h, meta, key, max, is_horz)
  assert(type(key) == "string")
  assert(type(max) == "number", "expected max to be number")
  return formspec.render_energy_gauge{
    x = x,
    y = y,
    w = w,
    h = h,
    amount = get_meta_energy(meta, key),
    max = max,
    is_horz = is_horz
  }
end
