local bindings = {}

function yatm_core.bind_on_player_receive_fields(name, assigns, callback)
  print("Binding on_player_receive_fields", name, callback)
  bindings[name] = {
    assigns = assigns,
    callback = callback,
  }
end

function yatm_core.unbind_on_player_receive_fields(name)
  print("Unbinding on_player_receive_fields", name)
  bindings[name] = nil
end

minetest.register_on_player_receive_fields(function (player, form_name, fields)
  local binding = bindings[form_name]
  if not binding then
    -- we aren't interested in this form
    return false
  end

  if fields["quit"] then
    yatm_core.unbind_on_player_receive_fields(form_name)
  end

  return binding.callback(player, form_name, fields, binding.assigns)
end)
