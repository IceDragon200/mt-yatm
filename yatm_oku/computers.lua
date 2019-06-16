--
--
--
local OKU = assert(yatm_oku.OKU)

local Computers = yatm_core.Class:extends()
local ic = assert(Computers.instance_class)

function ic:initialize()
  self.m_computers = {}
end

function ic:register_computer(pos, node, options)
  local hash = minetest.hash_node_position(pos)
  self.m_computers[hash] = {
    id = hash,
    pos = pos,
    node = node,
    options = options,

    oku = OKU:new(options)
  }
end

yatm_oku.Computers = Computers
yatm_oku.computers = Computers:new()
