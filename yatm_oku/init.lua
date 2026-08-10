--
-- OKU - Octet Kompute Unit
--
-- Is a 8/16/32-bit computer for YATM, it offers some control over some YATM
-- features using the data network.
--
-- The machine is programmed in actual assembly, and emulated in lua or a native extension if
-- available.
--
local mod = foundation.new_module("yatm_oku", "0.6.0")

local insec = core.request_insecure_environment()
if insec then
  mod.ffi = insec.require("ffi")
end

mod.bit = assert(foundation.com.bit)

if not mod.ffi then
  yatm.warn("yatm_oku works better with FFI, you can add yatm_oku to your trusted mods list if you use LuaJIT, or leave it untrusted to fallback to pure lua implementation of some modules.")
end

mod:require("oku.lua")
mod:require("lib/elf.lua")
mod:require("computers.lua")

if yatm_oku.Computers then
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
  core.log("warning", "oku failed to initialize properly: computers are unavailable")
end

if core.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

if core.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end
