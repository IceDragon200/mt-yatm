yatm.noteblock = yatm.noteblock or {}

-- This is for no other purpose but reference
local ROOT_NOTE = "F" -- all samples start from F and end on E

local INS = {
  -- Melodic
  bass = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  flute = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  guitar = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  melodicdrum = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  piano = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },
  pulse25p = {
    type = "melodic",
    auto_populate = true,
    start = "F3",
    stop = "E6",
    samples = {}, -- will be populated later
  },

  -- Percussive
  hihatclosed = {
    type = "percussive",
    auto_populate = true,
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  kickdrum = {
    type = "percussive",
    auto_populate = true,
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  rimshot = {
    type = "percussive",
    auto_populate = true,
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },
  snaredrum = {
    type = "percussive",
    auto_populate = true,
    start = "F3",
    stop = "F3",
    samples = {}, -- will be populated later
  },

  -- SFX / Vocal Clips
  voc = {
    type = "vocal",
    auto_populate = false,
    start = "F3",
    stop = "E6",
    samples = {
      --[0] = "yatm_noteblock_voc_placeholder",
      "yatm_noteblock_voc_placeholder", -- 1
      "yatm_noteblock_voc_placeholder", -- 2
      "yatm_noteblock_voc_placeholder", -- 3
      "yatm_noteblock_voc_placeholder", -- 4
      "yatm_noteblock_voc_placeholder", -- 5
      "yatm_noteblock_voc_placeholder", -- 6
      "yatm_noteblock_voc_placeholder", -- 7
      "yatm_noteblock_voc_placeholder", -- 8
      "yatm_noteblock_voc_placeholder", -- 9
      --
      "yatm_noteblock_voc_zero",        -- 10
      "yatm_noteblock_voc_one",         -- 11
      "yatm_noteblock_voc_two",         -- 12
      "yatm_noteblock_voc_three",       -- 13
      "yatm_noteblock_voc_four",        -- 14
      "yatm_noteblock_voc_five",        -- 15
      "yatm_noteblock_voc_six",         -- 16
      "yatm_noteblock_voc_seven",       -- 17
      "yatm_noteblock_voc_eight",       -- 18
      "yatm_noteblock_voc_nine",        -- 19
      "yatm_noteblock_voc_ten",         -- 20
      "yatm_noteblock_voc_eleven",      -- 21
      "yatm_noteblock_voc_twelve",      -- 22
      "yatm_noteblock_voc_thirteen",    -- 23
      "yatm_noteblock_voc_fourteen",    -- 24
      "yatm_noteblock_voc_fifteen",     -- 25
      "yatm_noteblock_voc_sixteen",     -- 26
      "yatm_noteblock_voc_seventeen",   -- 27
      "yatm_noteblock_voc_eighteen",    -- 28
      "yatm_noteblock_voc_nineteen",    -- 29
      "yatm_noteblock_voc_twenty",      -- 30
      "yatm_noteblock_voc_thirty",      -- 31
      "yatm_noteblock_voc_forty",       -- 32
      "yatm_noteblock_voc_fifty",       -- 33
      "yatm_noteblock_voc_sixty",       -- 34
      "yatm_noteblock_voc_seventy",     -- 35
      "yatm_noteblock_voc_eighty",      -- 36
      "yatm_noteblock_voc_ninety",      -- 37
      "yatm_noteblock_voc_hundred",     -- 38
      "yatm_noteblock_voc_thousand",    -- 39
      "yatm_noteblock_voc_million",     -- 40
      "yatm_noteblock_voc_billion",     -- 41
      "yatm_noteblock_voc_trillion",    -- 42
      "yatm_noteblock_voc_quantillion", -- 43
      "yatm_noteblock_voc_quintillion", -- 44
      "yatm_noteblock_voc_sextillion",  -- 45
      "yatm_noteblock_voc_septillion",  -- 46
      "yatm_noteblock_voc_octillion",   -- 47
      "yatm_noteblock_voc_nonillion",   -- 48
      "yatm_noteblock_voc_decillion",   -- 49
      --
      "yatm_noteblock_voc_welcome",     -- 51
      "yatm_noteblock_voc_t-minus",     -- 52
      "yatm_noteblock_voc_icbm",        -- 53
      "yatm_noteblock_voc_prepping",    -- 54
      "yatm_noteblock_voc_ready",       -- 55
      "yatm_noteblock_voc_launching",   -- 56
      "yatm_noteblock_voc_launched",    -- 57
      "yatm_noteblock_voc_hostile",     -- 58
      "yatm_noteblock_voc_player",      -- 59
    },
  },
}

for key, entry in pairs(INS) do
  if entry.auto_populate then
    if entry.type == "percussive" then
      entry.samples[1] = "yatm_noteblock_" .. key --.. ".ogg"
    elseif entry.type == "melodic" then
      for i = 1,36 do
        entry.samples[i] = "yatm_noteblock_" .. key .. "_n" .. i --.. ".ogg"
      end
    end
  else
    --
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

function yatm.noteblock.play_note(pos, node, key, velo)
  local new_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  local tone_node_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
  local tone_node = minetest.get_node(tone_node_pos)

  --print("noteblock_play_audio", minetest.pos_to_string(tone_node_pos), tone_node.name, dump(yatm_core.groups.get_item_groups(tone_node.name)))

  if yatm_core.groups.item_has_group(tone_node.name, "plastic_block") then
    play_instrument(pos, "voc", key, velo)

  elseif yatm_core.groups.item_has_group(tone_node.name, "wood") then
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
