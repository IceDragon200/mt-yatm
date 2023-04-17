local mod = assert(yatm_fluids)

local FluidRegistry = assert(yatm.fluids.fluid_registry)

mod:register_tool("empty_bucket", {
  description = mod.S("Empty Bucket"),

  groups = {
    bucket = 1,
    empty_bucket = 1,
  },

  liquids_pointable = true,

  inventory_image = "yatm_bucket_empty.png",

  on_use = function (item_stack, user, pointed_thing)
    if pointed_thing.type == "object" then
      pointed_thing.ref:punch(
        user,
        1.0,
        { full_punch_interval=1.0 },
        nil
      )

      return user:get_wielded_item()
    elseif pointed_thing.type ~= "node" then
      -- skip
      return nil
    end

    local node = minetest.get_node_or_nil(pointed_thing.under)
    local bucket = FluidRegistry.fluid_item_to_bucket(node.name)
    local fluid = FluidRegistry.fluid_item_to_fluid(node.name)

    if bucket then
      if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
        minetest.record_protection_violation(pos, name)
        return nil
      end

      local bucket_count = item_stack:get_count()
      local bucket_stack = ItemStack(bucket.name)
      local return_stack = bucket_stack

      if bucket_count > 1 then
        local inv = user:get_inventory()

        if inv:room_for_item("main", bucket_stack) then
          inv:add_item("main", bucket_stack)
        else
          local pos = user:get_pos()
          pos.y = math.floor(pos.y + 0.5)
          minetest.add_item(pos, bucket_stack)
        end

        return_stack = item_stack
      end

      -- force_renew requires a source neighbour
      local source_neighbor = false
      if bucket.force_renew then
        source_neighbor =
          minetest.find_node_near(pointed_thing.under, 1, bucket.source)
      end

      if not (source_neighbor and bucket.force_renew) then
        minetest.add_node(pointed_thing.under, {
          name = "air"
        })
      end

      return return_stack
    else
      -- non-liquid nodes will have their on_punch triggered
      local node_def = minetest.registered_nodes[node.name]
      if node_def then
        node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
      end
      return user:get_wielded_item()
    end
  end,
})
