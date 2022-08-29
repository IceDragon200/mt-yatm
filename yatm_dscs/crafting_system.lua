--
--
--
local path_join = assert(foundation.com.path_join)
local Groups = assert(foundation.com.Groups)
local metaref_int_list_to_table = assert(foundation.com.metaref_int_list_to_table)
local metaref_int_list_push = assert(foundation.com.metaref_int_list_push)
local metaref_int_list_lazy_clear = assert(foundation.com.metaref_int_list_lazy_clear)

local get_inventory_controller_def = assert(yatm.dscs.get_inventory_controller_def)

-- @namespace yatm_dscs

local function try_register_to_inventory_controller(pos, node, child_id)
  local inv_con, err = get_inventory_controller_def(pos, node)
  if not inv_con then
    return false, err
  end

  local meta = minetest.get_meta(pos)

  -- grab the child count
  local count =
    metaref_int_list_push(
      meta,
      inv_con.child_key_prefix,
      inv_con.max_children,
      child_id
    )

  if not count then
    return false, "no space for more children"
  end

  return true
end

local function handle_dscs_storage_module(_clusters, cluster, dtime, node_entry)
  local assigns = node_entry.assigns

  assigns.dscs_storage_dtime = (assigns.dscs_storage_dtime or 0) + dtime
  if assigns.dscs_storage_dtime > 5 then
    assigns.dscs_storage_dtime = assigns.dscs_storage_dtime - 5

    local nodedef = minetest.registered_nodes[node_entry.node.name]
    local meta = minetest.get_meta(node_entry.pos)

    local has_controller = meta:get_int("has_inv_controller")
    local controller_id = meta:get_int("inv_controller_id")

    local has_valid_controller = has_controller

    if has_controller > 0 then
      local controller_node_entry = cluster:get_node_by_id(controller_id)

      if controller_node_entry then
        if Groups.has_group(controller_node_entry, "dscs_inventory_controller") then
          has_valid_controller = 1
        else
          has_valid_controller = 0
        end
      else
        has_valid_controller = 0
      end
    end

    if has_valid_controller == 0 then
      -- there is no valid controller at the moment, start looking for a new one

      local registered
      local err

      -- find a new controller
      controller_id =
        cluster:reduce_nodes_of_group("dscs_inventory_controller", nil, function (invc_node_entry, acc)
          registered, err =
            try_register_to_inventory_controller(
              invc_node_entry.pos,
              invc_node_entry.node,
              node_entry.id
            )

          if registered then
            return false, invc_node_entry.id
          else
            return true, acc
          end
        end)

      if controller_id then
        has_valid_controller = 1
      else
        has_valid_controller = 0
        controller_id = 0
      end
    end

    meta:set_int("has_inv_controller", has_valid_controller)
    meta:set_int("inv_controller_id", controller_id)
  end
end

local function handle_dscs_inventory_controller(_clusters, cluster, dtime, node_entry)
  local assigns = node_entry.assigns

  assigns.dscs_ivc_dtime = (assigns.dscs_ivc_dtime or 0) + dtime
  if assigns.dscs_ivc_dtime > 5 then
    local meta = minetest.get_meta(node_entry.pos)

    local inv_con, err = get_inventory_controller_def(node_entry.pos, node_entry.node)
    if not inv_con then
      return
    end

    local prefix = inv_con.child_key_prefix
    local max = inv_con.max_children

    local count, list = metaref_int_list_to_table(meta, prefix, max)

    metaref_int_list_lazy_clear(meta, prefix, max)

    if count > 0 then
      local seen = {}

      for i = 1,count do
        local item = list[i]

        if not seen[item] then
          seen[item] = true
          metaref_int_list_push(meta, prefix, max, item)
        end
      end
    end
  end
end

-- @class CraftingSystem
local CraftingSystem = foundation.com.Class:extends("YATM.DSCS.CraftingSystem")
local ic = CraftingSystem.instance_class

-- @spec #initialize(): void
function ic:initialize()
  self.m_root_dir = path_join(minetest.get_worldpath(), "/yatm/dscs")
  minetest.mkdir(self.m_root_dir)
end

-- @spec #persist_network_inventory_state(Cluster): void
function ic:persist_network_inventory_state(cluster)
  cluster:reduce_group_members("dscs_inventory_controller", 0, function (pos, node, acc)
    local basename = string.format("inv-controller-%08x.bin", minetest.hash_node_position(pos))
    local filename = path_join(self.m_root_dir, basename)
    minetest.safe_file_write(filename)
    return true, acc + 1
  end)
end

-- @spec #update(Clusters, Cluster, dtime: Float): void
function ic:update(cls, cluster, dtime)
  --print("Updating Cluster", network.id)
  cluster:reduce_nodes_of_group("dscs_storage_module", 0, function (node_entry, acc)
    handle_dscs_storage_module(cls, cluster, dtime, node_entry)

    return true, acc + 1
  end)

  cluster:reduce_nodes_of_group("dscs_assembler_module", 0, function (node_entry, acc)
    --print(dump(pos), dump(node))
    return true, acc + 1
  end)

  cluster:reduce_nodes_of_group("dscs_inventory_controller", 0, function (node_entry, acc)
    handle_dscs_inventory_controller(cls, cluster, dtime, node_entry)

    return true, acc + 1
  end)

  cluster:reduce_nodes_of_group("dscs_compute_module", 0, function (node_entry, acc)
    --print(dump(pos), dump(node))
    return true, acc + 1
  end)

  cluster:reduce_nodes_of_group("dscs_server", 0, function (node_entry, acc)
    --print(dump(pos), dump(node))
    return true, acc + 1
  end)
end

yatm_dscs.CraftingSystem = CraftingSystem

-- @const crafting_system: CraftingSystem
yatm_dscs.crafting_system = CraftingSystem:new()
