local mod = assert(yatm_armoury_c4)
local random_addr16 = assert(foundation.com.random_addr16)

--- @namespace yatm_armoury_c4

local RADIO_NETWORK_ADDR_KEY = "radio_network_addr"

--- @mutative meta
--- @spec init_meta_radio_network_addr(meta: MetaRef): void
function mod.init_meta_radio_network_addr(meta)
  if not meta:get(RADIO_NETWORK_ADDR_KEY) then
    meta:set_string(RADIO_NETWORK_ADDR_KEY, random_addr16(16, 4, ":"))
  end
end

--- @mutative item_stack
--- @spec init_item_stack_radio_network_addr(item_stack: ItemStack): ItemStack
function mod.init_item_stack_radio_network_addr(item_stack)
  local meta = item_stack:get_meta()
  mod.init_meta_radio_network_addr(meta)
  return item_stack
end

--- @mutative meta
--- @spec copy_meta_radio_network_addr(origin: MetaRef, dest: MetaRef): void
function mod.copy_meta_radio_network_addr(origin, dest)
  dest:set_string(RADIO_NETWORK_ADDR_KEY, origin:get(RADIO_NETWORK_ADDR_KEY))
end

--- @mutative dest
--- @spec copy_item_stack_radio_network_addr(origin: MetaRef, dest: MetaRef): void
function mod.copy_item_stack_radio_network_addr(origin, dest)
  mod.copy_meta_radio_network_addr(origin:get_meta(), dest:get_meta())
end

--- @spec get_meta_radio_network_addr(meta): String
function mod.get_meta_radio_network_addr(meta)
  return meta:get(RADIO_NETWORK_ADDR_KEY)
end

--- @spec get_item_stack_radio_network_addr(item_stack: ItemStack): String
function mod.get_item_stack_radio_network_addr(item_stack)
  local meta = item_stack:get_meta()
  return mod.get_meta_radio_network_addr(meta)
end
