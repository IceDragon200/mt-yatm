--
-- All of YATM's standard formspec backgrounds
--
local fspec = assert(foundation.com.formspec.api)

-- @namespace yatm

yatm.bg_name = {}
yatm.bg9_name = {}

yatm.bg_base =
  "no_prepend[]" ..
  "bgcolor[#080808BB;true]" ..
  "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

yatm.bg_name.default = "yatm_gui_formbg_default.png"
yatm.bg_name.computer = "yatm_gui_formbg_default.computer.png"
yatm.bg_name.data = "yatm_gui_formbg_default.data.png"
yatm.bg_name.codex = "yatm_gui_formbg_codex.png"
yatm.bg_name.display = "yatm_gui_formbg_display.data.png"
yatm.bg_name.machine = "yatm_gui_formbg_machine.png"
yatm.bg_name.machine_heated = "yatm_gui_formbg_machine.heated.png"
yatm.bg_name.machine_cooled = "yatm_gui_formbg_machine.cooled.png"
yatm.bg_name.machine_radioactive = "yatm_gui_formbg_machine.radioactive.png"
yatm.bg_name.machine_chemical = "yatm_gui_formbg_machine.chemical.png"
yatm.bg_name.module = "yatm_gui_formbg_module.data.png"
yatm.bg_name.other = "yatm_gui_formbg_other.png"
yatm.bg_name.wood = "yatm_gui_formbg_wood.png"
yatm.bg_name.cardboard = "yatm_gui_formbg_cardboard.png"
yatm.bg_name.dscs = "yatm_gui_formbg_dscs.png"
yatm.bg_name.inventory = "yatm_gui_formbg_inventory.png"

yatm.bg9_name.default = "yatm_gui_formbg_default.9s.png"
yatm.bg9_name.computer = "yatm_gui_formbg_default.computer.9s.png"
yatm.bg9_name.data = "yatm_gui_formbg_default.data.9s.png"
yatm.bg9_name.codex = "yatm_gui_formbg_codex.9s.png"
yatm.bg9_name.display = "yatm_gui_formbg_display.data.9s.png"
yatm.bg9_name.machine = "yatm_gui_formbg_machine.9s.png"
yatm.bg9_name.machine_heated = "yatm_gui_formbg_machine.heated.9s.png"
yatm.bg9_name.machine_cooled = "yatm_gui_formbg_machine.cooled.9s.png"
yatm.bg9_name.machine_radioactive = "yatm_gui_formbg_machine.radioactive.9s.png"
yatm.bg9_name.machine_chemical = "yatm_gui_formbg_machine.chemical.9s.png"
yatm.bg9_name.module = "yatm_gui_formbg_module.data.9s.png"
yatm.bg9_name.other = "yatm_gui_formbg_other.9s.png"
yatm.bg9_name.wood = "yatm_gui_formbg_wood.9s.png"
yatm.bg9_name.cardboard = "yatm_gui_formbg_cardboard.9s.png"
yatm.bg9_name.dscs = "yatm_gui_formbg_dscs.9s.png"
yatm.bg9_name.inventory = "yatm_gui_formbg_inventory.9s.png"

-- @spec formspec_bg_for_player(player_name: String, background_id: String, x?: Number, y?: Number, w?: Number, h?: Number, auto_clip: Boolean): String
function yatm.formspec_bg_for_player(player_name, background_id, x, y, w, h, auto_clip)
  assert(type(player_name) == "string", "expected player_name as string")

  x = x or 0
  y = y or 0
  w = w or 1
  h = h or 1

  if auto_clip == nil then
    auto_clip = false
  end

  local info = minetest.get_player_information(player_name)
  local texture_name

  if info.formspec_version then
    if info.formspec_version >= 2 then
      texture_name = yatm.bg9_name[background_id]
      return fspec.background9(x, y, w, h, texture_name, auto_clip, 32)
    end
  end

  texture_name = yatm.bg_name[background_id]
  return fspec.background(x, y, w, h, texture_name, auto_clip)
end
