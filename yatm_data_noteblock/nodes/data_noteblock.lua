local data_network = assert(yatm.data_network)

-- This is for no other purpose but reference
local ROOT_NOTE = "F" -- all samples start from F and end on E

local INS = {
  -- Melodic
  bass = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  flute = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  guitar = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  melodicdrum = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  piano = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  pulse25p = {
    type = "melodic",
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },

  -- Percussive
  hihatclosed = {
    type = "percussive",
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  kickdrum = {
    type = "percussive",
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  rimshot = {
    type = "percussive",
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  snaredrum = {
    type = "percussive",
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  }
}

for key, entry in pairs(INS) do
  if entry.type == "percussive" then
    entry.samples[1] = "yatm_noteblock_" .. key --.. ".ogg"
  elseif entry.type == "melodic" then
    for i = 1,36 do
      entry.samples[i] = "yatm_noteblock_" .. key .. "_n" .. i --.. ".ogg"
    end
  end
  entry.count = #entry.samples
end

local function play_instrument(pos, name, key, velo)
  --minetest.log("action", "playing instrument sound name=" .. name .. " key=" .. key .. " velocity=" .. velo)
  velo = velo or 127
  local ins = INS[name]
  local filename = ins.samples[1 + (key - 1) % ins.count]

  minetest.sound_play({ name = filename, pitch = 1.0 }, {
    pos = pos,
    gain = velo / 127,
    max_hear_distance = 64,
  })
end

local function noteblock_play_audio(pos, key, velo)
  local tone_node_pos = vector.add(pos, yatm_core.V3_DOWN)
  local tone_node = minetest.get_node(tone_node_pos)

  --print("noteblock_play_audio", minetest.pos_to_string(tone_node_pos), tone_node.name, dump(yatm_core.groups.get_item_groups(tone_node.name)))

  if yatm_core.groups.item_has_group(tone_node.name, "wood") then
    play_instrument(pos, "bass", key, velo)

  elseif yatm_core.groups.item_has_group(tone_node.name, "sand") or
         yatm_core.groups.item_has_group(tone_node.name, "gravel") then
    play_instrument(pos, "snaredrum", key, velo)

  elseif tone_node.name == "default:glass" or
         yatm_core.groups.item_has_group(tone_node.name, "glass") then
    play_instrument(pos, "hihatclosed", key, velo)

  elseif yatm_core.groups.item_has_group(tone_node.name, "wool") then
    play_instrument(pos, "guitar", key, velo)

  elseif tone_node.name == "default:clay" or
         yatm_core.groups.item_has_group(tone_node.name, "clay") then
    play_instrument(pos, "flute", key, velo)

  elseif yatm_core.groups.item_has_group(tone_node.name, "carbon_steel") then
    play_instrument(pos, "melodicdrum", key, velo)

  elseif tone_node.name == "default:stone" or
         tone_node.name == "default:cobble" or
         tone_node.name == "default:desert_stone" or
         tone_node.name == "default:desert_cobble" or
         yatm_core.groups.item_has_group(tone_node.name, "stone") then
    play_instrument(pos, "kickdrum", key, velo)

  elseif tone_node.name == "default:diamondblock" or
         yatm_core.groups.item_has_group(tone_node.name, "quartz") then
    play_instrument(pos, "pulse25p", key, velo)

  else
    play_instrument(pos, "piano", key, velo)
  end
end

-- Just like a mesecon noteblock, except triggered by data events
minetest.register_node("yatm_data_noteblock:data_noteblock", {
  description = "Data Note Block",

  codex_entry_id = "yatm_data_noteblock:data_noteblock",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 5, 16):fast_node_box(),
      yatm_core.Cuboid:new(2, 5, 2, 12,10, 12):fast_node_box(),
      yatm_core.Cuboid:new( 0,14, 0, 16, 2, 2):fast_node_box(),
      yatm_core.Cuboid:new( 0,14,14, 16, 2, 2):fast_node_box(),
      yatm_core.Cuboid:new( 0,14, 0,  2, 2, 16):fast_node_box(),
      yatm_core.Cuboid:new(14,14, 0,  2, 2, 16):fast_node_box(),
    },
  },

  tiles = {
    "yatm_data_noteblock_top.png",
    "yatm_data_noteblock_bottom.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("damper", 0)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, local_port, value)
      --print("receive_pdu", minetest.pos_to_string(pos), node.name, dir, local_port, dump(value))
      local meta = minetest.get_meta(pos)
      local payload = yatm_core.string_hex_unescape(value)
      local key = string.byte(payload, 1)
      key = key + meta:get_int("offset")
      local damper = meta:get_int("damper")
      noteblock_play_audio(pos, key, math.max(0, 127 - damper))
    end,

    get_programmer_formspec = function (self, pos, clicker, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      local formspec =
        "size[8,9]" ..
        yatm.bg.module ..
        "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]" ..
          yatm_data_logic.get_io_port_formspec(pos, meta, "i")

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "field[0.25,1;8,1;offset;Note Offset;" .. meta:get_int("offset") .. "]" ..
          "field[0.25,2;8,1;damper;Damper;" .. meta:get_int("damper") .. "]"
      end

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = false

      if fields["tab"] then
        local tab = tonumber(fields["tab"])
        if tab ~= assigns.tab then
          assigns.tab = tab
          needs_refresh = true
        end
      end

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "i")

      if not yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      if fields["offset"] then
        local offset = math.floor(tonumber(fields["offset"]))
        meta:set_int("offset", offset)
      end

      if fields["damper"] then
        local damper = math.floor(tonumber(fields["damper"]))
        meta:set_int("damper", damper)
      end

      if needs_refresh then
        local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
        return true, formspec
      else
        return true
      end
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
