local Luna = assert(foundation.com.Luna)

local Clusters = assert(yatm.Clusters)
local utils = assert(yatm_data_network.utils)

local case = Luna:new("yatm_data_network.utils")

case:describe("generate_network_id/0", function (dsc)
  dsc:test("can generate a network id", function (t)
    t:assert(utils.generate_network_id())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
