--[[

  The public API exposed by the yatm_core

]]
yatm.Luna = assert(yatm_core.Luna)

function yatm.register_stateful_node(basename, base, states)
  for name, changes in pairs(states) do
    local nodedef = yatm_core.table_merge(base, changes)
    nodedef.basename = nodedef.basename or basename
    minetest.register_node(basename .. "_" .. name, nodedef)
  end
end

function yatm.register_stateful_tool(basename, base, states)
  for name, changes in pairs(states) do
    local tooldef = yatm_core.table_merge(base, changes)
    tooldef.basename = tooldef.basename or basename
    minetest.register_tool(basename .. "_" .. name, tooldef)
  end
end

function yatm.register_stateful_craftitem(basename, base, states)
  for name, changes in pairs(states) do
    local craftitemdef = yatm_core.table_merge(base, changes)
    craftitemdef.basename = craftitemdef.basename or basename
    minetest.register_craftitem(basename .. "_" .. name, craftitemdef)
  end
end

yatm.bg = {}

yatm.bg.base =
  [[
  no_prepend[]
  bgcolor[#080808BB;true]
  listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
  ]]

local auto_clip = "true"
local bg9  = "background9[0,0;1,1;"

yatm.bg.default = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.9s.png;" .. auto_clip .. ";32]"
yatm.bg.computer = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.computer.9s.png;" .. auto_clip .. ";32]"
yatm.bg.data = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg.codex = yatm.bg.base .. bg9 .. "yatm_gui_formbg_codex.9s.png;" .. auto_clip .. ";32]"
yatm.bg.display = yatm.bg.base .. bg9 .. "yatm_gui_formbg_display.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg.machine = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.9s.png;" .. auto_clip .. ";32]"
yatm.bg.machine_heated = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.heated.9s.png;" .. auto_clip .. ";32]"
yatm.bg.machine_cooled = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.cooled.9s.png;" .. auto_clip .. ";32]"
yatm.bg.machine_radioactive = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.radioactive.9s.png;" .. auto_clip .. ";32]"
yatm.bg.machine_chemical = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.chemical.9s.png;" .. auto_clip .. ";32]"
yatm.bg.module = yatm.bg.base .. bg9 .. "yatm_gui_formbg_module.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg.other = yatm.bg.base .. bg9 .. "yatm_gui_formbg_other.9s.png;" .. auto_clip .. ";32]"
yatm.bg.wood = yatm.bg.base .. bg9 .. "yatm_gui_formbg_wood.9s.png;" .. auto_clip .. ";32]"
