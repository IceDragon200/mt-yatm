--[[

  YATM Blasts (FROST)

  Implementation of the FROST explosion

  FROST explosions only target nodes that are below air, instantly freezing them given enough strength.
]]
foundation.new_module("yatm_blasts_frost", "0.2.0")

local Groups = assert(foundation.com.Groups)

local function handle_freezable_node_at(self, pos)
  local freezable_node = minetest.get_node_or_nil(pos)
  if freezable_node then
    local freezable_nodedef = minetest.registered_nodes[freezable_node.name]

    if Groups.has_group(freezable_nodedef, "freezable") then
      if freezable_nodedef then
        if freezable_nodedef.on_freeze then
          freezable_nodedef.on_freeze(p, freezable_node, self.strength)
        elseif freezable_nodedef.freezes_to then
          local freezes_to = freezable_nodedef.freezes_to

          if type(freezes_to) == "string" then
            minetest.set_node(p, { name = freezes_to })
          elseif type(freezes_to) == "table" then
            minetest.set_node(p, { name = freezes_to.name,
                                   param1 = freezes_to.param1,
                                 param2 = freezes_to.param2 })
          end
        end
      end
    elseif Groups.has_group(freezable_nodedef, "water") then
      local new_node = { name = "default:ice" }
      minetest.set_node(pos, new_node)
    end
  end
end

local FREEZABLE_GROUPS = {
  "group:water",
  "group:freezable"
}

yatm.blasts.system:register_explosion_type("yatm:frost", {
  description = "YATM FROST Explosion",

  init = function (self, system, explosion, params)
    --
    self.range = params.range or 3
    self.strength = params.strength or 1
  end,

  update = function (self, system, explosion, delta)
    local minpos = vector.subtract(explosion.pos, self.range)
    local maxpos = vector.add(explosion.pos, self.range)
    local freezables = minetest.find_nodes_in_area_under_air(minpos, maxpos, FREEZABLE_GROUPS)

    for _, pos in ipairs(freezables) do
      handle_freezable_node_at(self, pos)
    end

    --[[
    -- TODO
    minvel = vector.new(0, 1, 0)
    maxvel = vector.new(0, 1, 0)

    minetest.add_particlespawner({
      amount = self.strength * 6,
      minpos = minpos,
      maxpos = maxpos,
      minvel = minvel,
      maxvel = maxvel,
    })
    ]]
    -- instantly expire it
    explosion.expired = true
  end,

  on_expired = function (self, system, explosion)
    --
  end,
})
