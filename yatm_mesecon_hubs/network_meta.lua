local MetaSchema = assert(foundation.com.MetaSchema)
local random_string16 = assert(foundation.com.random_string16)
local is_blank = assert(foundation.com.is_blank)

local NetworkMeta = {}

local hub_address_schema = MetaSchema:new("yatm_mesecon_hubs.hub_address", "", {
  hub_address = { type = "string" },
})

NetworkMeta.hub_address_schema = hub_address_schema:compile("mesehub")

function NetworkMeta.generate_hub_address()
  local result = {}
  for i = 1,4 do
    table.insert(result, random_string16(4))
  end
  return table.concat(result, ":")
end

function NetworkMeta.get_hub_address(meta)
  return NetworkMeta.hub_address_schema:get_hub_address(meta)
end

function NetworkMeta.set_hub_address(meta, address)
  assert(meta, "expected a meta")
  assert(address, "expected an address")
  NetworkMeta.hub_address_schema:set_hub_address(meta, address)
  return meta
end

function NetworkMeta.copy_hub_address(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local addr = NetworkMeta.get_hub_address(src_meta)
  NetworkMeta.hub_address_schema:set_hub_address(dest_meta, addr)
  return dest_meta
end

function NetworkMeta.patch_hub_address(meta, new_address)
  local addr = NetworkMeta.get_hub_address(meta)
  if is_blank(addr) then
    new_address = new_address or NetworkMeta.generate_hub_address()
    return NetworkMeta.set_hub_address(meta, new_address)
  else
    return meta
  end
end

yatm_mesecon_hubs.NetworkMeta = NetworkMeta
