yatm_fluid_pipe_valves.valve_mesecon_rules = {
  {x =  0, y =  0, z = -1},
  {x =  1, y =  0, z =  0},
  {x = -1, y =  0, z =  0},
  {x =  0, y =  0, z =  1},
  {x =  1, y =  1, z =  0},
  {x =  1, y = -1, z =  0},
  {x = -1, y =  1, z =  0},
  {x = -1, y = -1, z =  0},
  {x =  0, y =  1, z =  1},
  {x =  0, y = -1, z =  1},
  {x =  0, y =  1, z = -1},
  {x =  0, y = -1, z = -1},
}

local fsize = (8 / 16.0) / 2
local size = (6 / 16.0) / 2

yatm_fluid_pipe_valves.valve_nodebox = {
  type = "connected",
  fixed          = {-fsize, -fsize, -fsize, fsize,  fsize, fsize},
  connect_top    = {-size, -size, -size, size,  0.5,  size}, -- y+
  connect_bottom = {-size, -0.5,  -size, size,  size, size}, -- y-
  connect_front  = {-size, -size, -0.5,  size,  size, size}, -- z-
  connect_back   = {-size, -size,  size, size,  size, 0.5 }, -- z+
  connect_left   = {-0.5,  -size, -size, size,  size, size}, -- x-
  connect_right  = {-size, -size, -size, 0.5,   size, size}, -- x+
}
