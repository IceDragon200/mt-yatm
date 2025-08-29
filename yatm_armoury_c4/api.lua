local mod = assert(yatm_armoury_c4)
local random_addr16 = assert(foundation.com.random_addr16)

--- @namespace yatm_armoury_c4

--- @mutative item_stack
--- @spec init_radio_network_addr(item_stack: ItemStack): ItemStack
function mod.init_radio_network_addr(item_stack)
  local meta = item_stack:get_meta()
  local rad = meta:get("radio_network_addr")
  if not rad then
    rad = random_addr16(16, 4, ":")
    meta:set_string("radio_network_addr", rad)
  end
  return item_stack
end
