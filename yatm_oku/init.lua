--
-- OKU - Octet Kompute Unit
--
-- Is a 8/16/32-bit computer for YATM, it offers some control over some YATM
-- features using the data network.
--
-- The machine is programmed in actual assembly, and emulated in lua or a native extension if
-- available.
--
local mod = foundation.new_module("yatm_oku", "0.5.0")

local insec = minetest.request_insecure_environment()
if insec then
  mod.ffi = insec.require("ffi")
end

mod.bit = assert(foundation.com.bit)

if not mod.ffi then
  yatm.warn("yatm_oku works better with FFI, please add yatm_oku to your trusted mods list if you use LuaJIT, or leave it untrusted to fallback to pure lua implementation of some modules.")
end

mod:require("oku.lua")
mod:require("lib/elf.lua")
mod:require("computers.lua")

if yatm_oku.computers then
  mod:require("api.lua")

  mod:require("nodes.lua")
  mod:require("items.lua")

  mod:require("hooks.lua")

  if foundation.com.Luna then
    mod:require("tests.lua")
  end

  mod.ffi = nil
  mod.bit = nil
else
  minetest.log("warning", "oku failed to initialize properly")
end
