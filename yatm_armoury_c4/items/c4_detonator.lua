local mod = yatm_armoury_c4

mod:register_tool("c4_detonator", {
  description = "C4 Detonator",

  groups = {
    c4_detonator = 1,
  },

  inventory_image = "yatm_c4_detonator.png",

  on_place = function (itemstack, _user, _pointed_thing)
    -- TODO: place any remote detonatable c4s from inventory on place
    return itemstack
  end,

  on_use = function (itemstack, _user, _pointed_thing)
    -- TODO: detonate all nearby remote c4s under the same address
    return nil
  end,
})
