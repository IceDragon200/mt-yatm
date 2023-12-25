local Luna = assert(foundation.com.Luna)

local Clusters = assert(yatm.Clusters)
local DataNetwork = assert(yatm_data_network.DataNetwork)

local case = Luna:new("yatm_data_network.DataNetwork")

case:describe("#initialize/1", function (dsc)
  dsc:test("can initialize a data network", function (t)
    local world = foundation.com.headless.World:new()

    local clusters = Clusters:new{
      world = world
    }

    local dn = DataNetwork:new{
      world = world,
      clusters = clusters,
    }

    dn:terminate()
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
