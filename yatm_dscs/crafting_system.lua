--
--
--
local path_join = assert(foundation.com.path_join)
local CraftingSystem = foundation.com.Class:extends("YATM.DSCS.CraftingSystem")
local ic = CraftingSystem.instance_class

function ic:initialize()
  self.m_root_dir = path_join(minetest.get_worldpath(), "/yatm/dscs")
  minetest.mkdir(self.m_root_dir)
end

function ic:persist_network_inventory_state(network)
  network:reduce_group_members("dscs_inventory_controller", 0, function (pos, node, acc)
    local basename = string.format("inv-controller-%08x.bin", minetest.hash_node_position(pos))
    local filename = path_join(self.m_root_dir, basename)
    minetest.safe_file_write(filename)
    return true, acc + 1
  end)
end

function ic:update(cls, cluster, dtime)
  --print("Updating Cluster", network.id)
  cluster:reduce_nodes_of_group("dscs_inventory_controller", 0, function (node_entry, acc)
    --print(dump(pos), dump(node))
    return true, acc + 1
  end)

  cluster:reduce_nodes_of_group("dscs_compute_module", 0, function (node_entry, acc)
    --print(dump(pos), dump(node))
    return true, acc + 1
  end)
end

yatm_dscs.crafting_system = CraftingSystem:new()
