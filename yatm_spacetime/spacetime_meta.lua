local is_blank = assert(foundation.com.is_blank)
local MetaSchema = assert(foundation.com.MetaSchema)

local TeleporterAddressSchema = MetaSchema:new("teleporter_address", "", {
  address = { type = "string" },
})

-- @namespace yatm_spacetime.SpacetimeMeta
local SpacetimeMeta = {}
SpacetimeMeta.schema = TeleporterAddressSchema:compile("spaddr")

-- @spec get_address(MetaRef): String
function SpacetimeMeta.get_address(src)
  return SpacetimeMeta.schema:get_address(src)
end

-- @spec set_address(MetaRef, String): void
function SpacetimeMeta.set_address(dest, address)
  SpacetimeMeta.schema:set_address(dest, address)
end

-- @spec patch_address(MetaRef, String): String
function SpacetimeMeta.patch_address(dest, new_address)
  local old_address = SpacetimeMeta.get_address(dest)
  if is_blank(old_address) then
    new_address = new_address or yatm_spacetime.generate_address()
    SpacetimeMeta.set_address(dest, new_address)
  else
    new_address = old_address
  end
  return new_address
end

-- @spec copy_address(src: MetaRef, dest: MetaRef): String
function SpacetimeMeta.copy_address(src, dest)
  local address = SpacetimeMeta.get_address(src)
  SpacetimeMeta.set_address(dest, address)
  return address
end

-- @spec to_infotext(MetaRef): String
function SpacetimeMeta.to_infotext(meta)
  local address = SpacetimeMeta.get_address(meta)
  if is_blank(address) then
    return "NIL"
  else
    return address
  end
end

yatm_spacetime.SpacetimeMeta = SpacetimeMeta
