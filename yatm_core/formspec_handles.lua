local bindings = {}

function yatm_core.bind_on_player_receive_fields(clicker, name, assigns, callback)
  assert(clicker, "expected a clicker")
  assert(callback, "expected a callback")

  print("Binding on_player_receive_fields", name, callback)
  local key = clicker:get_player_name()
  if not bindings[key] then
    bindings[key] = {}
  end

  bindings[key][name] = {
    assigns = assigns,
    callback = callback,
  }
end

function yatm_core.unbind_on_player_receive_fields(player_name, name)
  print("Unbinding on_player_receive_fields", name)
  if bindings[player_name] then
    bindings[player_name][name] = nil

    if yatm_core.is_table_empty(bindings[player_name]) then
      bindings[player_name] = nil
    end
  end
end

function yatm_core.refresh_player_formspec(player, formname, formspec_builder)
  local key = player:get_player_name()
  if bindings[key] then
    if bindings[key][formname] then
      local entry = bindings[key][formname]
      local formspec = formspec_builder(player, entry.assigns)
      minetest.show_formspec(key, formname, formspec)
    end
  end
end

minetest.register_on_player_receive_fields(function (player, formname, fields)
  local key = player:get_player_name()
  local player_bindings = bindings[key]
  if not player_bindings then
    -- no bindings present, skipping
    return false
  end

  local binding = player_bindings[formname]
  if not binding then
    -- we aren't interested in this form
    return false
  end

  local status, new_formspec = binding.callback(player, formname, fields, binding.assigns)
  if fields["quit"] then
    yatm_core.unbind_on_player_receive_fields(key, formname)
  else
    if status and new_formspec then
      minetest.show_formspec(key, formname, new_formspec)
    end
    return status
  end
end)
