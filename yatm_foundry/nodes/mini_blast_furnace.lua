local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local table_merge = assert(foundation.com.table_merge)
local cluster_thermal = assert(yatm.cluster.thermal)

local function mini_blast_furnace_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local heat = meta:get_float("heat")

  local infotext =
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. math.floor(heat)

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  item_interface_in = 1,
  item_interface_out = 1,
  heatable_device = 1,
  heat_interface_in = 1,
  yatm_cluster_thermal = 1,
}

yatm.register_stateful_node("yatm_foundry:mini_blast_furnace", {
  basename = "yatm_foundry:mini_blast_furnace",

  description = "Mini Blast Furnace",

  codex_entry_id = "yatm_foundry:mini_blast_furnace",

  groups = groups,

  drop = "yatm_foundry:mini_blast_furnace_off",

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("stone"),

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  on_timer = function (pos, elapsed)
    return true
  end,

  refresh_infotext = mini_blast_furnace_refresh_infotext,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
        local new_name
        if math.floor(heat) > 0 then
          new_name = "yatm_foundry:mini_blast_furnace_on"
        else
          new_name = "yatm_foundry:mini_blast_furnace_off"
        end
        if new_name ~= node.name then
          node.name = new_name
          minetest.swap_node(pos, node)
        end

        maybe_start_node_timer(pos, 1.0)

        yatm.queue_refresh_infotext(pos, node)
      end
    end,
  },
}, {
  off = {
    tiles = {
      "yatm_mini_blast_furnace_top.off.png",
      "yatm_mini_blast_furnace_bottom.off.png",
      "yatm_mini_blast_furnace_side.off.png",
      "yatm_mini_blast_furnace_side.off.png^[transformFX",
      "yatm_mini_blast_furnace_back.off.png",
      "yatm_mini_blast_furnace_front.off.png"
    },
  },
  on = {
    groups = table_merge(groups, {not_in_creative_inventory = 1}),
    tiles = {
      "yatm_mini_blast_furnace_top.on.png",
      "yatm_mini_blast_furnace_bottom.on.png",
      "yatm_mini_blast_furnace_side.on.png",
      "yatm_mini_blast_furnace_side.on.png^[transformFX",
      "yatm_mini_blast_furnace_back.on.png",
      "yatm_mini_blast_furnace_front.on.png"
    },
  }
})
