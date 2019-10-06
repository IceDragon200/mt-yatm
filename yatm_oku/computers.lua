--
--
--
local OKU = assert(yatm_oku.OKU)

local Computers = yatm_core.Class:extends()
local ic = assert(Computers.instance_class)

function ic:initialize()
  self.m_computers = {}
end

--
-- Should be called by the minetest startup to do stuff.
--
function ic:setup()
  --
end

function ic:terminate()
  -- Persist all active computer states
end

function ic:update()
end

--
-- Creates a brand spanking new instance of a computer
--
-- Options:
--   See OKU:new() for details
function ic:create_computer(pos, node, options)
  local hash = minetest.hash_node_position(pos)
  self.m_computers[hash] = {
    id = hash,
    pos = pos,
    node = node,
    options = options,

    oku = OKU:new(options)
  }
end

--
-- Retrieve a computer entry.
--
-- For the love of god, don't do anything funky with it!
function ic:get_computer(pos, node)
  local hash = minetest.hash_node_position(pos)

  return self.m_computers[hash]
end

--
-- Destroys a computer instance, this will also remove any state files.
--
function ic:destroy_computer(pos, node)
  print("Destroying Computer", minetest.pos_to_string(pos), node.name)
  local hash = minetest.hash_node_position(pos)
  self.m_computers[hash] = nil
end

--
-- Registers a computer (possibly creating a new instance).
-- This should be used for nodes that are being reloaded.
--
function ic:register_computer(pos, node, options)

end

yatm_oku.Computers = Computers
yatm_oku.computers = Computers:new()
