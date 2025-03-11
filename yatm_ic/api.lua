local fspec = assert(foundation.com.formspec.api)

--- @namepace yatm_ic
local mod = assert(yatm_ic)

local function maybe_append(a, b)
  if b then
    return "(" .. a .. "^" .. b .. ")"
  end
  return a
end

local function switch_off_l46t8(params)
  local switch_off = "yatm_ic_switch.off.png"
  local switch_term4 = maybe_append("yatm_ic_switch.term.4.png", params.a)
  local switch_term6 = maybe_append("yatm_ic_switch.term.6.png", params.b)
  local switch_term8 = maybe_append("yatm_ic_switch.term.8.off.png", params.x)
  return switch_off .. "^" .. switch_term4 .. "^" .. switch_term6 .. "^" .. switch_term8
end

local function switch_on_l46t8(params)
  local switch_on = "yatm_ic_switch.on.png"
  local switch_term4 = maybe_append("yatm_ic_switch.term.4.png", params.a)
  local switch_term6 = maybe_append("yatm_ic_switch.term.6.png", params.b)
  local switch_term8 = maybe_append("yatm_ic_switch.term.8.on.png", params.x)
  return switch_on .. "^" .. switch_term4 .. "^" .. switch_term6 .. "^" .. switch_term8
end

local function gate_base_x8y2t6(gate_base, params)
  return "yatm_ic_border.png"
    .. "^" .. maybe_append("yatm_ic_gate.term.8.png", params.x)
    .. "^" .. maybe_append("yatm_ic_gate.term.2.png", params.y)
    .. "^" .. maybe_append(gate_base, params.t)
end

local term4 = "yatm_ic_term.png^yatm_ic_4.png"
local term2 = maybe_append(term4, "[transformR270")
local term6 = maybe_append(term4, "[transformFX")
local term8 = maybe_append(term4, "[transformR90")

--- @const TEXTURES: Table
mod.TEXTURES = {
  l24 = "yatm_ic_4-8.corner.png^[transformFY",
  l26 = "yatm_ic_4-8.corner.png^[transformR180",
  l28 = "yatm_ic_4-6.png^[transformR90",
  l48 = "yatm_ic_4-8.corner.png",
  l68 = "yatm_ic_4-8.corner.png^[transformFX",
  l46 = "yatm_ic_4-6.png",
  l246 = "yatm_ic_4-6.png^(yatm_ic_4.png^[transformR270)",
  l248 = "(yatm_ic_4-6.png^[transformR90)^yatm_ic_4.png",
  l2468 = "yatm_ic_4-6.png^(yatm_ic_4-6.png^[transformR90)",
  l268 = "(yatm_ic_4-6.png^[transformR90)^(yatm_ic_4.png^[transformFX)",
  l468 = "yatm_ic_4-6.png^(yatm_ic_4.png^[transformR90)",
  l46b28 = function (params)
    local ab_base = maybe_append("yatm_ic_4-6.png", params.ab)
    local xy_base = maybe_append("(yatm_ic_4-6.bridge.png^[transformR90)", params.xy)
    return ab_base .. "^" .. xy_base
  end,
  b46l28 = function (params)
    local ab_base = maybe_append("yatm_ic_4-6.bridge.png", params.ab)
    local xy_base = maybe_append("(yatm_ic_4-6.png^[transformR90)", params.xy)
    return ab_base .. "^" .. xy_base
  end,

  switch_off_l28t4 = function (...)
    return "(" .. switch_off_l46t8(...) .. "^[transformR270)"
  end,
  switch_off_l28t6 = function (...)
    return "(" .. switch_off_l46t8(...) .. "^[transformR90)"
  end,
  switch_off_l46t2 = function (...)
    return "(" .. switch_off_l46t8(...) .. "^[transformR180)"
  end,
  switch_off_l46t8 = switch_off_l46t8,

  switch_on_l28t4 = function (...)
    return "(" .. switch_on_l46t8(...) .. "^[transformR270)"
  end,
  switch_on_l28t6 = function (...)
    return "(" .. switch_on_l46t8(...) .. "^[transformR90)"
  end,
  switch_on_l46t2 = function (...)
    return "(" .. switch_on_l46t8(...) .. "^[transformR180)"
  end,
  switch_on_l46t8 = switch_on_l46t8,

  t2 = term2,
  t4 = term4,
  t6 = term6,
  t8 = term8,

  gate_not_x2t8 = "yatm_ic_gate.not.png^[transformR270",
  gate_not_x4t6 = "yatm_ic_gate.not.png",
  gate_not_x6t4 = "yatm_ic_gate.not.png^[transformFX",
  gate_not_x8t2 = "yatm_ic_gate.not.png^[transformR90",
}

for _,gate in ipairs({"and", "nand", "not", "or", "xor", "xnor"}) do
  local gate_func = function (...)
    return gate_base_x8y2t6("yatm_ic_gate." .. gate .. ".png", ...)
  end

  mod.TEXTURES["gate_" .. gate .. "_x2y8t4"] = function (...)
    return maybe_append(gate_func(...), "[transformR180")
  end
  mod.TEXTURES["gate_" .. gate .. "_x2y8t6"] = function (...)
    return maybe_append(gate_func(...), "[transformFY")
  end
  mod.TEXTURES["gate_" .. gate .. "_x4y6t2"] = function (...)
    return maybe_append(gate_func(...), "[transformFYR90")
  end
  mod.TEXTURES["gate_" .. gate .. "_x4y6t8"] = function (...)
    return maybe_append(gate_func(...), "[transformR270")
  end
  mod.TEXTURES["gate_" .. gate .. "_x6y4t2"] = function (...)
    return maybe_append(gate_func(...), "[transformR90")
  end
  mod.TEXTURES["gate_" .. gate .. "_x6y4t8"] = function (...)
    return maybe_append(gate_func(...), "[transformFXR90")
  end
  mod.TEXTURES["gate_" .. gate .. "_x8y2t4"] = function (...)
    return maybe_append(gate_func(...), "[transformFX")
  end
  mod.TEXTURES["gate_" .. gate .. "_x8y2t6"] = gate_func
end

--- @namespace yatm_ic.formspec
mod.formspec = mod.formspec or {}

--- @type MapData: {
--- }

--- @type LogicMap: {
---   w: Integer,
---   h: Integer,
---   data: MapData,
--- }

--- @spec render_logic_editor_map(
---   name: String,
---   x: Float,
---   y: Float,
---   w: Float,
---   h: Float,
---   map: LogicMap,
---   state: Table
--- ): String
function mod.formspec.render_logic_editor_map(name, x, y, w, h, map, state)
  local cidx
  local c
  local e
  local n

  local formspec = ""

  local cw = w / map.w
  local ch = h / map.h

  local texture_name

  for cy = 0,map.h-1 do
    for cx = 0,map.w-1 do
      cidx = 1 + cx + cy * map.w
      c = map.data[cidx]
      n = name .. "_c" .. cidx
      if c then
        e = mod.TEXTURES[c]

        if type(e) == "function" then
          texture_name = e(state[cidx])
        else
          texture_name = e
        end

        formspec =
          formspec
          .. fspec.image_button(
            x + cx * cw,
            y + cy * ch,
            cw,
            ch,
            texture_name,
            n
          )
      else
        formspec =
          formspec
          .. fspec.button(
            x + cx * cw,
            y + cy * ch,
            cw,
            ch,
            n,
            ""
          )
      end
    end
  end

  return formspec
end

function mod.formspec.render_logic_editor_controls(name, x, y, w, h, map, state)
  return ""
end

--- @spec render_logic_editor(
---   name: String,
---   x: Float,
---   y: Float,
---   w: Float,
---   h: Float,
---   map: LogicMap,
---   state: Table
--- ): String
function mod.formspec.render_logic_editor(name, x, y, w, h, map, state)

  local formspec = ""
    .. mod.formspec.render_logic_editor_map(name, x, y, w, h, map, state)
    .. mod.formspec.render_logic_editor_controls(name, x, y, w, h, map, state)

  return formspec
end
