--
-- Wood Sawmill
--
-- Cuts up given wood blocks when right clicked on
-- It's pretty much instant, so have fun!
--
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

end

minetest.register_node("yatm_woodcraft:sawmill", {
  basename = "yatm_woodcraft:sawmill",

  description = "Sawmill",

  groups = {
    cracky = 1,
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

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = sawmill_on_construct,

  on_rightclick = sawmill_on_rightclick,
})
