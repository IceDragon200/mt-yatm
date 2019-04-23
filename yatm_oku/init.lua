--[[
OKU - Octet Kompute Unit

Is an 8-bit computer for YATM, it offers mimimal control over some YATM features.

The machine is programmed in actual assembly, and emulated in lua.
]]
yatm_oku = rawget(_G, "yatm_oku") or {}
yatm_oku.modpath = minetest.get_modpath(minetest.get_current_modname())

local insec = minetest.request_insecure_environment()
if insec then
  local ffi = insec.require("ffi")
  yatm_oku.ffi = ffi
end


dofile(yatm_oku.modpath .. "/oku.lua")

dofile(yatm_oku.modpath .. "/tests.lua")

yatm_oku.ffi = nil
