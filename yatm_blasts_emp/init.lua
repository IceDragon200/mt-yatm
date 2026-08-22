--[[

  YATM Blasts (EMP)

  Implementation of the EMP explosion

  EMP explosions will raycast their way to a target and can be deflected.

]]
local mod = foundation.new_module("yatm_blasts_emp", "0.2.0")

local Groups = assert(foundation.com.Groups)
local get_node_or_nil = assert(tetra.get_node_or_nil)

local function handle_emp_target_node_at(assigns, pos, explosion)
  local target_node = get_node_or_nil(pos)

  if target_node then
    local raycast = core.raycast(explosion.pos, pos, false, false)
    local blocked = false
    for _, pointed_thing in raycast do
      if pointed_thing.type == "node" then
        local int_pos = vector.floor(pointed_thing.intersection_point)

        local node = get_node_or_nil(int_pos)
        if not node then
          -- can't continue for some reason
          blocked = true
          break
        end
        local nodedef = core.registered_nodes[node.name]

        if Groups.has_group(nodedef, "em_insulator") then
          -- if it's an insulator, drop the ray
          -- the target node cannot be affected since something is blocking the path
          blocked = true
          break
        end
      end
    end

    if blocked then
      --
    else
      local target_nodedef = core.registered_nodes[target_node.name]
      target_nodedef.on_emp_blast(pos, target_node, {
        pos = explosion.pos,
        strength = assigns.strength
      })
    end
  end
end

local function init(self, assigns, system, explosion, params)
  --
  assigns.range = params.range or 3
  assigns.strength = params.strength or 1
end

local function update(self, assigns, system, explosion, delta)
  --
  local minpos = vector.subtract(explosion.pos, assigns.range)
  local maxpos = vector.add(explosion.pos, assigns.range)
  local emp_targets = core.find_nodes_in_area_under_air(minpos, maxpos, {"group:emp_target"})

  for _, pos in ipairs(emp_targets) do
    handle_emp_target_node_at(assigns, pos, explosion)
  end

  explosion.expired = true
end

local function on_expired(self, assigns, system, explosion)
  --
end

yatm.blasts.system:register_explosion_type("yatm:emp", {
  description = "YATM EMP Explosion",

  init = init,

  update = update,

  on_expired = on_expired,
})
