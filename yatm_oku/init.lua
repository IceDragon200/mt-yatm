--[[
OKU - Octet Kompute Unit

Is a 32-bit computer for YATM, it offers some control over some YATM
features using the data network.

The machine is programmed in actual assembly, and emulated in lua.
]]
yatm_oku = rawget(_G, "yatm_oku") or {}
yatm_oku.modpath = minetest.get_modpath(minetest.get_current_modname())

local insec = minetest.request_insecure_environment()
if insec then
  yatm_oku.ffi = insec.require("ffi")
end

-- YATM now has it's own builtin bit module!
yatm_oku.bit = assert(yatm.bit)

if not yatm_oku.ffi then
  yatm.error("yatm_oku requires LuaJIT's FFI, please add yatm_oku to your trusted mods list if you use LuaJIT, or disable yatm_oku otherwise.")
end

if yatm_oku.ffi and yatm_oku.bit then
  dofile(yatm_oku.modpath .. "/oku.lua")
  dofile(yatm_oku.modpath .. "/lib/elf.lua")
  dofile(yatm_oku.modpath .. "/computers.lua")

  dofile(yatm_oku.modpath .. "/api.lua")

  dofile(yatm_oku.modpath .. "/nodes.lua")
  dofile(yatm_oku.modpath .. "/items.lua")

  dofile(yatm_oku.modpath .. "/hooks.lua")

  dofile(yatm_oku.modpath .. "/tests.lua")
end

yatm_oku.ffi = nil
yatm_oku.bit = nil
