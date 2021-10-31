local fspec = assert(foundation.com.formspec.api)

local jukebox_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
    {-0.375, 0.4375, 0.0625, -0.0625, 0.5, 0.375},
    {0.0625, 0.375, 0.0625, 0.375, 0.5, 0.375},
  }
}

local function get_jukebox_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "default" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "input_disc", rect.x, rect.y, 1, 1)
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "input_disc") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

yatm.register_stateful_node("yatm_decor:jukebox", {
  basename = "yatm_decor:jukebox",

  description = "Jukebox",

  groups = {cracky = 1},

  paramtype = "none",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = jukebox_node_box,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_decor:jukebox",
      get_jukebox_formspec(pos, user)
    )
  end,
}, {
  off = {
    tiles = {
      "yatm_jukebox_top.off.png",
      "yatm_jukebox_bottom.png",
      "yatm_jukebox_east.off.png",
      "yatm_jukebox_west.off.png",
      "yatm_jukebox_back.off.png",
      "yatm_jukebox_front.off.png"
    },
    use_texture_alpha = "opaque",
  },
  on = {
    groups = {cracky = 1, not_in_creative_inventory = 1},

    tiles = {
      "yatm_jukebox_top.on.png",
      "yatm_jukebox_bottom.png",
      "yatm_jukebox_east.on.png",
      "yatm_jukebox_west.on.png",
      "yatm_jukebox_back.on.png",
      "yatm_jukebox_front.on.png"
    },
    use_texture_alpha = "opaque",
  }
})
