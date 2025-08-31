local mod = assert(yatm_fluids)

local FluidContainers = assert(yatm.fluids.FluidContainers)
local FluidRegistry = assert(yatm.fluids.fluid_registry)
local itemstack_copy = assert(foundation.com.itemstack_copy)

mod:register_tool("empty_bucket", {
  description = mod.S("Empty Bucket"),

  groups = {
    bucket = 1,
    empty_bucket = 1,
  },

  liquids_pointable = true,

  inventory_image = "yatm_bucket_empty.png",

  fluid_container = {
    type = "static",
    volume = 0,
    capacity = FluidRegistry.BUCKET_VOLUME,

    set_fluid_stack = function (self, item_stack, fluid_stack, commit)
      if fluid_stack then
        if fluid_stack.amount >= FluidRegistry.BUCKET_VOLUME then
          local bucket = FluidRegistry.fluid_name_to_bucket(fluid_stack.name)
          if bucket then
            local target_item = item_stack
            if not commit then
              target_item = itemstack_copy(target_item)
            end
            target_item:set_name(bucket.name)
            local new_fs = FluidContainers.get_fluid_stack(target_item)
            return new_fs, new_fs
          end
        end
      end

      return nil, fluid_stack
    end,
  },

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

    local node = core.get_node_or_nil(pointed_thing.under)
    local bucket = FluidRegistry.fluid_item_to_bucket(node.name)
    local fluid = FluidRegistry.fluid_item_to_fluid(node.name)

    if bucket then
      if core.is_protected(pointed_thing.under, user:get_player_name()) then
        core.record_protection_violation(pos, name)
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
          core.add_item(pos, bucket_stack)
        end

        return_stack = item_stack
      end

      -- force_renew requires a source neighbour
      local source_neighbor = false
      if bucket.force_renew then
        source_neighbor =
          core.find_node_near(pointed_thing.under, 1, bucket.source)
      end

      if not (source_neighbor and bucket.force_renew) then
        core.add_node(pointed_thing.under, {
          name = "air"
        })
      end

      return return_stack
    else
      -- non-liquid nodes will have their on_punch triggered
      local node_def = core.registered_nodes[node.name]
      if node_def then
        node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
      end
      return user:get_wielded_item()
    end
  end,
})
