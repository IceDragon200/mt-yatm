minetest.register_entity("yatm_drones:scavenger_drone", {
  initial_properties = {
    visual = "visual",
    mesh = "",
  },

  on_activate = function (self, staticdata, dtime_s)
  end,

  on_rightclick = function (self, clicker)
  end,

  get_staticdata = function (self)
    return ""
  end,
})
