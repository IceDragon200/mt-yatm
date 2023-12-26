local random_string32 = assert(foundation.com.random_string32)

--- @namespace yatm_data_network.utils
yatm_data_network.utils = yatm_data_network.utils or {}

--- Generates a pseodo 4 segment, colon seperated ID. Each segment is a base32 encoded value.
--- Don't even try to decode it, it's actually just a random string...
---
--- @spec generate_network_id(): String
function yatm_data_network.utils.generate_network_id()
  return random_string32(2) .. ":" ..
         random_string32(2) .. ":" ..
         random_string32(2) .. ":" ..
         random_string32(2)
end
