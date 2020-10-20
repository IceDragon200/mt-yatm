local is_table_empty = assert(foundation.com.is_table_empty)

local bindings = {}

function yatm_core.show_bound_formspec(player_name, formname, formspec, options)
  assert(type(player_name), "expected a player name")
  assert(type(formname), "expected a formname")
  assert(type(assigns) == "table", "expected options to be a table")

  yatm_core.bind_on_player_receive_fields(player_name, formname, options)
  minetest.show_formspec(player_name, formname, formspec)
end

function yatm_core.bind_on_player_receive_fields(player_name, formname, options)
  assert(type(player_name), "expected a player name")
  assert(type(formname), "expected a formname")
  assert(type(assigns) == "table", "expected options to be a table")

  if not bindings[player_name] then
    bindings[player_name] = {}
  end

  local form = {
    state = options.state,
    on_receive_fields = options.on_receive_fields,
    on_quit = options.on_quit,
  }
  bindings[player_name][formname] = form

  return form
end

function yatm_core.unbind_on_player_receive_fields(player_name, formname)
  if bindings[player_name] then
    bindings[player_name][formname] = nil

    if is_table_empty(bindings[player_name]) then
      bindings[player_name] = nil
    end
  end
end

function yatm_core.refresh_player_formspec(player, formname, formspec_builder)
  local player_name = player:get_player_name()
  if bindings[player_name] then
    if bindings[player_name][formname] then
      local form = bindings[player_name][formname]
      local formspec = formspec_builder(player, form.state)
      minetest.show_formspec(player_name, formname, formspec)
    end
  end
end

function yatm_core.on_player_receive_fields(player, formname, fields)
  local player_name = player:get_player_name()
  local player_bindings = bindings[player_name]
  if not player_bindings then
    -- no bindings present, skipping
    return false
  end

  local form = player_bindings[formname]
  if not form then
    -- we aren't interested in this form
    return false
  end

  local keep_bubbling, new_formspec = form.on_receive_fields(player, formname, fields, form.state)
  if fields["quit"] then
    if form.on_quit then
      form.on_quit(player, formname, form.state)
    end
    yatm_core.unbind_on_player_receive_fields(player_name, formname)
  else
    if new_formspec then
      minetest.show_formspec(player_name, formname, new_formspec)
    end
  end
  return keep_bubbling
end

minetest.register_on_player_receive_fields(function (player, formname, fields)
  return yatm_core.on_player_receive_fields(player, formname, fields)
end)
