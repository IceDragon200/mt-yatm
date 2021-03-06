--
-- A programmers table is the node equivalent of the programming tool.
-- However its main purpose is to program items, not other nodes.
-- So it's not really an equivalent, it has a totally different function...
--
if not yatm_machines then
  return
end

local Groups = assert(foundation.com.Groups)
local string_hex_encode = assert(foundation.com.string_hex_encode)
local random_string62 = assert(foundation.com.random_string62)
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)

local function get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  assigns.tab = assigns.tab or 1

  local formspec =
    "size[12,11]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    "tabheader[0,0;tab;Writer,6502 Assembler;" .. assigns.tab .. "]" ..
    "label[0,0;Programmer's Table]" ..
    ""

  if assigns.tab == 1 then
    -- Writer Tab
    formspec =
      formspec ..
      "button[0,0.5;3,1;random;Random]" ..
      "field[3.5,0.75;5.5,1;prog_data;Data;" .. minetest.formspec_escape(meta:get_string("prog_data")) .. "]" ..
      "button[9,0.5;3,1;commit;Commit]" ..
      "label[0,1.25;Input Items]" ..
      "list[nodemeta:" .. spos .. ";input_items;0,2;4,4;]" ..
      "box[3.875,1.875;4.125,4.125;#45d5d8]" ..
      "label[4,1.25;Processing Items]" ..
      "list[nodemeta:" .. spos .. ";processing_items;4,2;4,4;]" ..
      "label[8,1.25;Output Items]" ..
      "list[nodemeta:" .. spos .. ";output_items;8,2;4,4;]" ..
      "list[current_player;main;2,6.85;8,1;]" ..
      "list[current_player;main;2,8.08;8,3;8]" ..
      "listring[nodemeta:" .. spos .. ";input_items]" ..
      "listring[current_player;main]" ..
      "listring[nodemeta:" .. spos .. ";output_items]" ..
      "listring[current_player;main]"
  elseif assigns.tab == 2 then
    -- 6502 Assembler
    formspec =
      formspec ..
      "textarea[0.25,1;6,5;source;Source;" .. minetest.formspec_escape(meta:get_string("assembly_source")) .. "]" ..
      "textarea[6.25,1;6,5;;Binary (Hex Dump);" .. minetest.formspec_escape(meta:get_string("assembly_binary")) .. "]" ..
      "textarea[0.25,6;9,2;;Error;" .. minetest.formspec_escape(meta:get_string("assembly_error")) .. "]" ..
      "button[9,6;3,1;assemble;Assemble]" ..
      "list[current_player;main;2,6.85;8,1;]" ..
      "list[current_player;main;2,8.08;8,3;8]"
  end

  return formspec
end

local function handle_receive_fields(user, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local needs_refresh = false

  if fields["tab"] then
    local tab = tonumber(fields["tab"])
    if tab ~= assigns.tab then
      assigns.tab = tab
      needs_refresh = true
    end
  end

  if fields["prog_data"] then
    meta:set_string("prog_data", fields["prog_data"])
  end

  if fields["random"] then
    meta:set_string("prog_data", yatm_security.gen_prvkey())
    needs_refresh = true
  end

  if fields["source"] then
    meta:set_string("assembly_source", fields["source"])
  end

  if fields["assemble"] then
    local inv = meta:get_inventory()
    local source = meta:get_string("assembly_source")
    local pos = assigns.pos

    local node = minetest.get_node_or_nil(pos)
    local meta = minetest.get_meta(pos)

    if node then
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef.basename == "yatm_security:programmers_table" then
        -- it's still a programmer's table, whew.
        local okay, blob, context, rest = yatm_oku.OKU.isa.MOS6502.Assembler.assemble_safe(source)

        if okay then
          minetest.log("action", "Assembly completed")
          sounds:play("compile_success", { pos = pos, max_hear_distance = 32 })
          local blob_hex = string_hex_encode(blob)
          meta:set_string("assembly_binary", blob_hex)
          meta:set_string("assembly_error", "")
        else
          minetest.log("action", "Assembly failed ", blob)
          sounds:play("action_error", { pos = pos, max_hear_distance = 32 })
          meta:set_string("assembly_binary", "")
          meta:set_string("assembly_error", blob)
        end

        needs_refresh = true
      end
    end
  end

  if fields["commit"] then
    if meta:get_float("processing_time") > 0 then
      sounds:play("action_error", { to_player = user:get_player_name(), max_hear_distance = 32 })
    else
      local inv = meta:get_inventory()

      if inv:is_empty("processing_items") then
        local input_items = inv:get_list("input_items")
        local count = 0
        for _, item in ipairs(input_items) do
          if not item:is_empty() then
            count = count + 1
          end
        end

        meta:set_float("processing_time", 3)
        meta:set_int("processing_count", count)
        meta:set_string("processing_prog_data", meta:get_string("prog_data"))

        inv:set_list("processing_items", input_items)
        inv:set_list("input_items", {})
      end
    end
  end

  if needs_refresh then
    return true, get_formspec(assigns.pos, user, assigns)
  else
    return true
  end
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_security:programmers_table",

  description = "Programmer's Table",

  codex_entry_id = "yatm_security:programmers_table",

  drop = "yatm_security:programmers_table_off",

  groups = {
    cracky = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
    yatm_data_device = 1,
  },

  tiles = {
    "yatm_programmers_table_top.off.png",
    "yatm_programmers_table_bottom.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
  },

  yatm_network = {
    kind = "machine",

    groups = {
      machine_worker = 1,
      energy_consumer = 1,
    },

    default_state = "off",
    states = {
      off = "yatm_security:programmers_table_off",
      on = "yatm_security:programmers_table_on",
      error = "yatm_security:programmers_table_error",
      conflict = "yatm_security:programmers_table_error",
    },

    energy = {
      capacity = 16000,
      startup_threshold = 2000,
      network_charge_bandwidth = 200,
      passive_lost = 0,
    },

    work = function (pos, node, available_energy, work_rate, dtime, ot)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      local processing_count = meta:get_int("processing_count")

      local org_proc_time = meta:get_float("processing_time")
      if not inv:is_empty("processing_items") then
        local proc_time = org_proc_time
        if proc_time > 0 then
          proc_time = math.max(proc_time - dtime, 0)
          meta:set_float("processing_time", proc_time)
        end

        if proc_time <= 0 then
          if inv:is_empty("output_items") then
            local output_items = {}
            local prog_data = meta:get_string("processing_prog_data")
            for i, item in pairs(inv:get_list("processing_items")) do
              if item:is_empty() then
                output_items[i] = item
              else
                local itemdef = item:get_definition()
                if itemdef.on_programmed then
                  output_items[i] = itemdef.on_programmed(item, prog_data)
                else
                  minetest.log("warning", item:get_name() .. " does not support on_programmed callback")
                  output_items[i] = item
                end
              end
            end

            inv:set_list("output_items", output_items)
            inv:set_list("processing_items", {})

            sounds:play("action_completed", { pos = pos, max_hear_distance = 32 })
          end
        end

        -- 100 units per item per second
        return 100 * processing_count * (org_proc_time - proc_time)
      elseif org_proc_time > 0 then
        sounds:play("long_error", { pos = pos, max_hear_distance = 32 })
        meta:set_float("processing_time", 0)
      end

      return 0
    end,
  },

  data_network_device = {
    type = "device",
  },

  data_interface = {
    on_load = function (self, pos, node)
      --
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)

    meta:set_string("prog_data", random_string62(16))

    local inv = meta:get_inventory()

    -- It can program up to 16 devices at once
    inv:set_size("input_items", 16)
    inv:set_size("processing_items", 16)
    inv:set_size("output_items", 16)

    cluster_devices:schedule_add_node(pos, node)
    cluster_energy:schedule_add_node(pos, node)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
    cluster_energy:schedule_remove_node(pos, node)
    data_network:remove_node(pos, node)
  end,

  on_dig = function (pos, node, digger)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:is_empty("input_items") and
       inv:is_empty("processing_items") and
       inv:is_empty("output_items") then
      return minetest.node_dig(pos, node, digger)
    end

    return false
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)

    local infotext =
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      cluster_energy:get_node_infotext(pos) .. " (" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. ")" .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,

  on_rightclick = function (pos, node, user, item_stack, pointed_thing)
    local formspec_name = "yatm_security:programmers_table:" .. minetest.pos_to_string(pos)
    local assigns = { pos = pos, node = node }
    local formspec = get_formspec(pos, user, assigns)

    yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
      state = assigns,
      on_receive_fields = receive_fields
    })
  end,

  allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    if from_list == "processing_items" or to_list == "processing_items" then
      return 0
    end

    if from_list == "output_items" then
      if to_list ~= "output_items" then
        return count
      end
    end

    if to_list == "input_items" then
      return 1
    elseif to_list == "output_items" then
      return 0
    end
    return 0
  end,

  allow_metadata_inventory_put = function(pos, listname, index, stack, player)
    if listname == "input_items" then
      if Groups.item_has_group(stack:get_name(), "table_programmable") then
        return 1
      end
    end
    return 0
  end,

  allow_metadata_inventory_take = function(pos, listname, index, stack, player)
    if listname == "output_items" then
      return stack:get_count()
    elseif listname == "input_items" then
      return stack:get_count()
    end
    return 0
  end,
}, {
  error = {
    tiles = {
      "yatm_programmers_table_top.error.png",
      "yatm_programmers_table_bottom.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_programmers_table_top.on.png",
      "yatm_programmers_table_bottom.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
    },
  },
})
