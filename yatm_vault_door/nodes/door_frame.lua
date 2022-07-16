local mod = yatm_vault_door

-- Toggle Slides fill move their entire door frame as far as possible in their direction
-- They are called 'toggle' slides since they are triggered by activating the door segments directly
-- Toggle steps move their door segments one step in their specified direction
yatm.register_stateful_node(mod:make_name("vault_frame_toggle_slide_left"), {

}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_slide_right"), {

}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_step_left"), {

}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})

yatm.register_stateful_node(mod:make_name("vault_frame_toggle_step_right"), {

}, {
  -- while in its open state, the door segments will usually be in its closed state
  open = {
  },
  close = {
  },
})
