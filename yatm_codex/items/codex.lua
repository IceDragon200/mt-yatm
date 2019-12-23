minetest.register_tool("yatm_codex:codex", {
  description = "CODEX",

  groups = {
    codex = 1,
  },

  inventory_image = "yatm_codex.png",

  on_use = function (itemstack, user, pointed_thing)
    -- open default codex knowledge base
  end,

  on_place = function (itemstack, user, pointed_thing)
    -- when pointing at something, pull up the associated codex entry for that item
    local pos = pointed_thing.under

    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local codex_entry
    if nodedef then
      codex_entry = nodedef.codex_entry
    end

    if codex_entry then
      --
    else
      minetest.chat_send_player(user:get_player_name(), "No CODEX entry available")
    end
  end,
})
