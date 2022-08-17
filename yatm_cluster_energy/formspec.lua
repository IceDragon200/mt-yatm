local fspec = assert(foundation.com.formspec.api)
local Color = assert(foundation.com.Color)
local Energy = assert(yatm_cluster_energy.energy)
local get_meta_energy = assert(Energy.get_meta_energy)

local formspec = {}

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
--   capacity: Number
-- ): String
function formspec.render_energy_gauge(x, y, w, h, amount, capacity)
  local gauge_h = h * amount / capacity

  local color = DEFAULT_ENERGY_COLOR.color

  local blend_color = Color.blend_hard_light(
    Color.from_colorstring(color),
    Color.new(199, 199, 199, 255)
  )

  local texture_name = "yatm_item_border_energy.png^[multiply:" .. Color.to_string24(blend_color)

  return fspec.box(x, y, w, h, "#292729") ..
    fspec.box(x, y + h - gauge_h, w, gauge_h, color) ..
    fspec.tooltip_area(x, y, w, h, "Energy " .. amount .. " / " .. capacity) ..
    fspec.image(x, y, w, h, texture_name, 16)
end

-- @spec render_meta_energy_gauge(
--   x: Number,
--   y: Number,
--   w: Number,
--   h: Number,
--   meta: MetaRef,
--   key: String,
--   capacity: Number
-- ): String
function formspec.render_meta_energy_gauge(x, y, w, h, meta, key, capacity)
  assert(type(key) == "string")
  assert(type(capacity) == "number", "expected capacity to be number")
  return formspec.render_energy_gauge(x, y, w, h, get_meta_energy(meta, key), capacity)
end

yatm_cluster_energy.formspec = formspec
