yatm_oku:require("lib/oku/memory_base.lua")
yatm_oku:require("lib/oku/ffi/memory.lua")
yatm_oku:require("lib/oku/ffi/aligned_memory.lua")
yatm_oku:require("lib/oku/lua/memory.lua")

yatm_oku.OKU.Memory = yatm_oku.OKU.FFIMemory or yatm_oku.OKU.LuaMemory
