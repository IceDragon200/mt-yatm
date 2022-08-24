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

-- @spec render_energy_gauge(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   amount: Number,
--   capacity: Number,
--   is_horz: Boolean
-- ): String
function formspec.render_energy_gauge(x, y, w, h, amount, capacity, is_horz)
  local gauge_h = h * amount / capacity

  local color = DEFAULT_ENERGY_COLOR.color

  return formspec.render_gauge{
    x = x,
    y = y,
    w = w,
    h = h,
    gauge_color = color,
    border = "yatm_item_border_energy.png",
    amount = amount,
    max = capacity,
    is_horz = is_horz,
    tooltip = "Energy " .. amount .. " / " .. capacity,
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
function formspec.render_meta_energy_gauge(x, y, w, h, meta, key, capacity, is_horz)
  assert(type(key) == "string")
  assert(type(capacity) == "number", "expected capacity to be number")
  return formspec.render_energy_gauge(
    x,
    y,
    w,
    h,
    get_meta_energy(meta, key),
    capacity,
    is_horz
  )
end
