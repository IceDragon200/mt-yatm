--
--
--
local CraftingSystem = yatm_core.Class:extends("YATM.DSCS.CraftingSystem")
local ic = CraftingSystem.instance_class

function ic:initialize()
  self.m_root_dir = yatm_core.path_join(minetest.get_worldpath(), "/yatm/dscs")
  minetest.mkdir(self.m_root_dir)
end

function ic:persist_network_inventory_state(network)
  network:reduce_group_members("dscs_inventory_controller", 0, function (pos, node, acc)
    local basename = string.format("inv-controller-%04x-%04x-%04x.bin", pos.x, pos.y, pos.z)
    local filename = yatm_core.path_join(self.m_root_dir, basename)
    minetest.safe_file_write(filename)
    return true, acc + 1
  end)
end

function ic:update_network(network, dtime, counter, trace_context)
  print("Updating Network", network.id)
  network:reduce_group_members("dscs_inventory_controller", 0, function (pos, node, acc)
    print(dump(pos), dump(node))
    return true, acc + 1
  end)

  network:reduce_group_members("dscs_compute_module", 0, function (pos, node, acc)
    print(dump(pos), dump(node))
    return true, acc + 1
  end)
end

yatm_dscs.crafting_system = CraftingSystem:new()
