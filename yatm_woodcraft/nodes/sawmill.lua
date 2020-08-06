--
-- Wood Sawmill
--
-- Cuts up given wood blocks when right clicked on
-- It's pretty much instant, so have fun!
--
local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)

local ItemDevice = assert(yatm.items.ItemDevice)
local sawing_registry = assert(yatm.sawing.sawing_registry)

local function sawmill_on_construct(pos)
  -- Originally I was going to do a inventory + formspec version
  -- But then I thought "wouldn't it be fun to just rightclick with the material?"
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  -- Sawdust.
  inv:set_size("residue_items", 1)
end

local function sawmill_on_rightclick(pos, node, clicker, itemstack, _pointed_thing)
  local recipe = sawing_registry:find_sawing_recipe(itemstack)

  if recipe then
    local player_inv = clicker:get_inventory()
    if player_inv then
      -- TODO: play a saw sound here

      -- should I do anything with this?
      itemstack:take_item(recipe.input_item_stack:get_count())

      for _, output_item in ipairs(recipe.output_item_stacks) do
        if player_inv:room_for_item("main", output_item) then
          player_inv:add_item("main", output_item)
        else
          minetest.add_item(clicker:get_pos(), output_item)
        end
      end

      local meta = minetest.get_meta(pos)

      local sawdust_rate = meta:get_float("sawdust_rate") or 0.0
      sawdust_rate = sawdust_rate + recipe.sawdust_rate

      while sawdust_rate > 1 do
        sawdust_rate = sawdust_rate - 1

        local sawdust = ItemStack("yatm_woodcraft:sawdust 1")
        local placed = false

        for dir6, vec3 in pairs(Directions.DIR6_TO_VEC3) do
          local bin_pos = vector.add(pos, vec3)
          local bin_node = minetest.get_node(bin_pos)

          if Groups.item_has_group(bin_node.name, "dust_bin") then
            local remaining = ItemDevice.insert_item(bin_pos, Directions.invert_dir(dir6), sawdust, true)

            if remaining and remaining:is_empty() then
              placed = true
              break
            end
          end
        end

        if not placed then
          minetest.add_item(clicker:get_pos(), sawdust)
        end
      end

      meta:set_float("sawdust_rate", sawdust_rate)
    end
  end
end

minetest.register_node("yatm_woodcraft:sawmill", {
  basename = "yatm_woodcraft:sawmill",

  description = "Sawmill",

  codex_entry_id = "yatm_woodcraft:sawmill",

  groups = {
    cracky = 1,
    item_interface_out = 1,
  },

  tiles = {
    {
      name = "yatm_wood_sawmill_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      },
    },
    "yatm_wood_sawmill_bottom.on.png",
    "yatm_wood_sawmill_side.on.png",
    "yatm_wood_sawmill_side.on.png",
    {
      name = "yatm_wood_sawmill_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      },
    },
    {
      name = "yatm_wood_sawmill_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      },
    },
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = sawmill_on_construct,

  on_rightclick = sawmill_on_rightclick,
})
