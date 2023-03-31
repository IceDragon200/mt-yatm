local mod = yatm_vault_door
local Directions = assert(foundation.com.Directions)

-- Door frames make up a vault door outer section, they are full node that move
-- door segments along a specified direction, either fully on activation or by a single node at a
-- time.


-- Toggle Slides will move their entire door frame as far as possible in their direction
-- They are called 'toggle' slides since they are triggered by activating the door segments directly
-- Toggle steps move their door segments one step in their specified direction,
-- they only change their state once all the segments can no longer move in their specified direction.

-- The maximum number of nodes a slide door will attempt to 'step' on activation
local MAX_STEP = 64

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_slide_left"), {
  description = mod.S("Vault Frame Toggle [Slide-Left]"),

  groups = {
    vault_door_frame = 1,
  },

  paramtype2 = "facedir",

  is_ground_content = false,

  vault_door = {
    direction = Directions.D_WEST,
    max_step = MAX_STEP,
  },
}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_slide_right"), {
  description = mod.S("Vault Frame Toggle [Slide-Right]"),

  groups = {
    vault_door_frame = 1,
  },

  paramtype2 = "facedir",

  is_ground_content = false,

  vault_door = {
    direction = Directions.D_EAST,
    max_step = MAX_STEP,
  },
}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_step_left"), {
  description = mod.S("Vault Frame Toggle [Step-Left]"),

  groups = {
    vault_door_frame = 1,
  },

  paramtype2 = "facedir",

  is_ground_content = false,

  vault_door = {
    direction = Directions.D_WEST,
    max_step = 1,
  },
}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_step_right"), {
  description = mod.S("Vault Frame Toggle [Step-Right]"),

  groups = {
    vault_door_frame = 1,
  },

  paramtype2 = "facedir",

  is_ground_content = false,

  vault_door = {
    direction = Directions.D_EAST,
    max_step = 1,
  },
}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})
