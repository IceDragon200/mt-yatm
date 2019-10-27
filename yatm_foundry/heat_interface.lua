local HeatInterface = {}

function default_allow_receive_heat(self, pos, dir, heat_amount)
  return true
end

function default_simple_receive_heat(self, pos, dir, heat_amount, commit)
  if self:allow_receive_heat(pos, dir, heat_amount) then
    local meta = minetest.get_meta(pos)
    local heat_field_name = self.field_name
    local heat_capacity = self.heat_capacity
    local current_heat = meta:get_float(heat_field_name) or 0

    local new_heat = math.min(current_heat + heat_amount, heat_capacity)

    if commit then
      meta:set_float(heat_field_name, new_heat)
      self:on_heat_changed(pos, dir, current_heat, new_heat)
    end

    -- due to some rounding errors
    return math.min(new_heat - current_heat, heat_amount), nil
  else
    return 0, "receive heat not allowed"
  end
end

function default_on_heat_changed(self, pos, dir, old_heat, new_heat)
  --
end

function HeatInterface.new_simple(field_name, heat_capacity)
  local heat_interface = {
    field_name = field_name,
    heat_capacity = heat_capacity,
    allow_receive_heat = default_allow_receive_heat,
    receive_heat = default_simple_receive_heat,
    on_heat_changed = default_on_heat_changed,
  }
  return heat_interface
end

yatm_foundry.HeatInterface = HeatInterface
