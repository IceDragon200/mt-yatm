local mesecon_hub_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox1
    {-0.25, -0.5, -0.5, 0.25, -0.375, 0.5}, -- NodeBox2
    {-0.5, -0.5, -0.25, 0.5, -0.375, 0.25}, -- NodeBox3
  }
}

local INTERVALS = {
  [0] = 1/1,
  [1] = 1/2,
  [2] = 1/4,
  [3] = 1/8,
  [4] = 1/16,
}

local INTERVALS_NAME = {
  [0] = "1/1",
  [1] = "1/2",
  [2] = "1/4",
  [3] = "1/8",
  [4] = "1/16",
}

local DIR_TO_CODE = {
  [yatm_core.D_NORTH] = "n",
  [yatm_core.D_SOUTH] = "s",
  [yatm_core.D_EAST] = "e",
  [yatm_core.D_WEST] = "w",
}

local TILE_DIR_ORDER = {
  yatm_core.D_EAST,
  yatm_core.D_WEST,
  yatm_core.D_NORTH,
  yatm_core.D_SOUTH,
}

local drop = "yatm_mesecon_sequencer:sequencer_i0_d" .. yatm_core.D_NORTH

local function trigger_receptor_off(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  mesecon.receptor_off(pos, nodedef.mesecons.receptor.rules(node))
end

local function trigger_receptor_on(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  mesecon.receptor_on(pos, nodedef.mesecons.receptor.rules(node))
end

for interval,duration in pairs(INTERVALS) do
  for _, dir in ipairs(TILE_DIR_ORDER) do
    local name = "yatm_mesecon_sequencer:sequencer_i" .. interval .. "_d" .. dir
    local prev_seq_name = "yatm_mesecon_sequencer:sequencer_i" .. interval .. "_d" .. yatm_core.DIR4_ACW_ROTATION[dir]
    local next_seq_name = "yatm_mesecon_sequencer:sequencer_i" .. interval .. "_d" .. yatm_core.DIR4_CW_ROTATION[dir]
    local next_interval_name = "yatm_mesecon_sequencer:sequencer_i" .. ((interval + 1) % 5) .. "_d" .. dir

    local receptor_rules = function (node)
      return {
        vector.new(yatm_core.DIR6_TO_VEC3[dir]),
      }
    end

    local effector_rules = {}
    for _, effector_dir in ipairs(TILE_DIR_ORDER) do
      if effector_dir ~= dir then
        effector_rules[effector_dir] = vector.new(yatm_core.DIR6_TO_VEC3[effector_dir])
      end
    end

    local effector_rules = function (node)
      return effector_rules
    end

    local groups = {
      cracky = 1,
    }

    if name ~= drop then
      groups.not_in_creative_inventory = 1
    end

    local tiles = {
      "yatm_mesecon_sequencer_top." .. interval .. "." .. DIR_TO_CODE[dir] .. ".png",
      "yatm_mesecon_sequencer_bottom.png",
    }

    for _, sdir in ipairs(TILE_DIR_ORDER) do
      if sdir == dir then
        table.insert(tiles, "yatm_mesecon_sequencer_side.on.png")
      else
        table.insert(tiles, "yatm_mesecon_sequencer_side.off.png")
      end
    end

    minetest.register_node(name, {
      basename = "yatm_mesecon_sequencer:sequencer",
      base_description = "Sequencer",

      description = "Sequencer [" .. DIR_TO_CODE[dir] .. "] [" .. INTERVALS_NAME[interval] .. "s]",

      groups = groups,

      drop = drop,

      tiles = tiles,
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = mesecon_hub_node_box,

      on_construct = function (pos)
        minetest.get_node_timer(pos):start(duration)
      end,

      on_timer = function (pos, elapsed)
        local meta = minetest.get_meta(pos)
        local direction = meta:get_int("direction")

        local node = minetest.get_node_or_nil(pos)
        if node then
          trigger_receptor_off(pos, node)

          if direction < 0 then
            -- anti-clockwise
            node.name = prev_seq_name
          else
            -- clockwise
            node.name = next_seq_name
          end
          minetest.swap_node(pos, node)

          trigger_receptor_on(pos, node)
        end
        return true
      end,

      on_punch = function (pos, node, puncher, pointed_thing)
        node.name = next_interval_name
        minetest.swap_node(pos, node)

        local nodedef = minetest.registered_nodes[node.name]
        minetest.get_node_timer(pos):start(nodedef.sequencer.interval_duration)
      end,

      on_rightclick = function (pos, node, puncher, pointed_thing)
        local meta = minetest.get_meta(pos)
        local direction = meta:get_int("direction")
        if direction == 0 then
          meta:set_int("direction", 1)
        elseif direction == 1 then
          meta:set_int("direction", -1)
        elseif direction == -1 then
          meta:set_int("direction", 1)
        end
      end,

      after_place_node = function (pos, placer, item_stack, pointed_thing)
        yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
      end,

      sequencer = {
        interval = interval,
        interval_duration = duration,
        dir = dir,
      },

      mesecons = {
        effector = {
          rules = effector_rules,
        },
        receptor = {
          state = mesecon.state.on,
          rules = receptor_rules,
        },
      },
    })
  end
end
