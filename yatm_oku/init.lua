--
-- OKU - Octet Kompute Unit
--
-- Is a 32-bit computer for YATM, it offers some control over some YATM
-- features using the data network.
--
-- The machine is programmed in actual assembly, and emulated in lua.
--
local mod = foundation.new_module("yatm_oku", "0.3.0")

local insec = minetest.request_insecure_environment()
if insec then
  mod.ffi = insec.require("ffi")
end

mod.bit = assert(foundation.com.bit)

if not mod.ffi then
  yatm.error("yatm_oku requires LuaJIT's FFI, please add yatm_oku to your trusted mods list if you use LuaJIT, or disable yatm_oku otherwise.")
end

mod:require("oku.lua")
mod:require("lib/elf.lua")
mod:require("computers.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("hooks.lua")

mod:require("tests.lua")

mod.ffi = nil
mod.bit = nil
