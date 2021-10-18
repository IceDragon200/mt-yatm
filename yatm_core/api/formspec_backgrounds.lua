--
-- All of YATM's standard formspec backgrounds
--
yatm.bg = {}
yatm.bg9 = {}

yatm.bg.base =
  "no_prepend[]" ..
  "bgcolor[#080808BB;true]" ..
  "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

local auto_clip = "true"

local bg = "background[0,0;1,1;"

yatm.bg.default = yatm.bg.base .. bg .. "yatm_gui_formbg_default.png;" .. auto_clip .. "]"
yatm.bg.computer = yatm.bg.base .. bg .. "yatm_gui_formbg_default.computer.png;" .. auto_clip .. "]"
yatm.bg.data = yatm.bg.base .. bg .. "yatm_gui_formbg_default.data.png;" .. auto_clip .. "]"
yatm.bg.codex = yatm.bg.base .. bg .. "yatm_gui_formbg_codex.png;" .. auto_clip .. "]"
yatm.bg.display = yatm.bg.base .. bg .. "yatm_gui_formbg_display.data.png;" .. auto_clip .. "]"
yatm.bg.machine = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.png;" .. auto_clip .. "]"
yatm.bg.machine_heated = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.heated.png;" .. auto_clip .. "]"
yatm.bg.machine_cooled = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.cooled.png;" .. auto_clip .. "]"
yatm.bg.machine_radioactive = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.radioactive.png;" .. auto_clip .. "]"
yatm.bg.machine_chemical = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.chemical.png;" .. auto_clip .. "]"
yatm.bg.module = yatm.bg.base .. bg .. "yatm_gui_formbg_module.data.png;" .. auto_clip .. "]"
yatm.bg.other = yatm.bg.base .. bg .. "yatm_gui_formbg_other.png;" .. auto_clip .. "]"
yatm.bg.wood = yatm.bg.base .. bg .. "yatm_gui_formbg_wood.png;" .. auto_clip .. "]"
yatm.bg.cardboard = yatm.bg.base .. bg .. "yatm_gui_formbg_cardboard.png;" .. auto_clip .. "]"
yatm.bg.dscs = yatm.bg.base .. bg .. "yatm_gui_formbg_dscs.png;" .. auto_clip .. "]"

local bg9  = "background9[0,0;1,1;"

yatm.bg9.default = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.computer = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.computer.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.data = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.codex = yatm.bg.base .. bg9 .. "yatm_gui_formbg_codex.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.display = yatm.bg.base .. bg9 .. "yatm_gui_formbg_display.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_heated = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.heated.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_cooled = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.cooled.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_radioactive = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.radioactive.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_chemical = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.chemical.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.module = yatm.bg.base .. bg9 .. "yatm_gui_formbg_module.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.other = yatm.bg.base .. bg9 .. "yatm_gui_formbg_other.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.wood = yatm.bg.base .. bg9 .. "yatm_gui_formbg_wood.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.cardboard = yatm.bg.base .. bg9 .. "yatm_gui_formbg_cardboard.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.dscs = yatm.bg.base .. bg9 .. "yatm_gui_formbg_dscs.9s.png;" .. auto_clip .. ";32]"

-- @spec formspec_bg_for_player(player_name: String, background_name: String): String
function yatm.formspec_bg_for_player(player_name, background_name)
  assert(type(player_name) == "string", "expected player_name as string")

  local info = minetest.get_player_information(player_name)

  if info.formspec_version then
    if info.formspec_version >= 2 then
      return yatm.bg9[background_name]
    end
  end

  return yatm.bg[background_name]
end