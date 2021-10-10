local ffi = yatm_oku.ffi

local Registers = {}

if ffi then
  function Registers:new()
    return ffi.new("struct yatm_oku_registers32")
  end
else
  function Registers:new()
    return {
      _native = false,
    }
  end
end

yatm_oku.OKU.Registers = Registers

