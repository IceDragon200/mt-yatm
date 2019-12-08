minetest.register_tool("yatm_codex:codex", {
  description = "CODEX",

  groups = {
    codex = 1,
  },

  inventory_image = "yatm_codex.png",

  on_use = function (itemstack, user, pointed_thing)
    -- when pointing at something, pull up the associated codex entry for that item
  end,

  on_place = function (itemstack, user, pointed_thing)
    -- open default codex knowledge base
  end,
})
