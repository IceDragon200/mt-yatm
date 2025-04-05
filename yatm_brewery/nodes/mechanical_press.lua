--
-- Mechanical Presses work with basins to complete PressingRecipes
-- This is normally used to change items into some kind of fluid or other
-- items that will be stored in the basin
--
-- The press is operated by right clicking on it with an empty hand (for now)
local mod = assert(yatm_brewery)

local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local Vector3 = assert(foundation.com.Vector3)

local plunger_entity_name = mod:make_name("mechanical_press_plunger_ent")
local mechanical_press_node = mod:make_name("mechanical_press")

local function find_plunger_entity(pos)
  local plunger_id = core.hash_node_position(pos)
  local lua_entity
  for _, object in core.objects_inside_radius(pos, 2.0) do
    if object and not object:is_player() then
      lua_entity = object:get_luaentity()
      if lua_entity then
        if lua_entity.name == plunger_entity_name and lua_entity.plunger_id == plunger_id then
          return object
        end
      end
    end
  end
  return nil
end

local function add_plunger_entity(pos)
  local plunger_id = core.hash_node_position(pos)

  core.add_entity(pos, plunger_entity_name, minetest.write_json({
    plunger_pos = pos,
    plunger_id = plunger_id,
  }))
end

local function remove_plunger_entity(pos)
  local object = find_plunger_entity(pos)
  if object then
    object:remove()
  end
end

local function refresh_plunger_entity(pos)
  local object = find_plunger_entity(pos)
  if object then
    object:get_luaentity():refresh()
    return
  end
  add_plunger_entity(pos)
end

local function on_load(pos, node)
  refresh_plunger_entity(pos)
end

local function on_construct(pos)
  local meta = core.get_meta(pos)
  meta:set_float("plunger_pos", 0.0)
  refresh_plunger_entity(pos)
end

local function on_destruct(pos)
  remove_plunger_entity(pos)
end

local function after_rotate_node(pos)
  refresh_plunger_entity(pos)
end

--- @private.spec on_timer(Vector3, dtime: Float): Boolean
local function on_timer(pos, dtime)
end

local node_box = {
  type = "fixed",
  fixed = {
    -- legs
    ng(0, 0, 0, 16, 13, 16),
  },
}

mod:register_node("mechanical_press", {
  description = mod.S("Mechanical Press"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    machine = 1,
    mechcanical_press = 1,
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "none",
  paramtype2 = "facedir",
  tiles = {
    "yatm_mechanical_press_base_top.png",
    "yatm_mechanical_press_base_bottom.png",
    "yatm_mechanical_press_base_side.png",
    "yatm_mechanical_press_base_side.png",
    "yatm_mechanical_press_base_side.png",
    "yatm_mechanical_press_base_side.png",
  },

  on_construct = on_construct,
  on_destruct = on_destruct,
  on_timer = on_timer,
  after_rotate_node = after_rotate_node,
})

local node_box = {
  type = "fixed",
  fixed = {
    ng(6, 0, 6, 4, 13, 4),
    ng(1, 13, 1, 14, 3, 14),
  },
}

--- Node just for the plunger entity
mod:register_node("mechanical_press_plunger", {
  description = mod.S("Mechanical Press Plunger"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    machine = 1,
    mechcanical_press_plunger = 1,
    not_in_creative_inventory = 1,
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
  tiles = {
    "yatm_mechanical_press_plunger_top.png",
    "yatm_mechanical_press_plunger_bottom.png",
    "yatm_mechanical_press_plunger_side.png",
    "yatm_mechanical_press_plunger_side.png",
    "yatm_mechanical_press_plunger_side.png",
    "yatm_mechanical_press_plunger_side.png",
  },
})

core.register_entity(plunger_entity_name, {
  initial_properties = {
    glow = core.LIGHT_MAX,
    hp_max = 1,
    visual = "node",
    node = { name = mod:make_name("mechanical_press_plunger"), param1 = 0, param2 = 0 },
    visual_size = {x = 1.0, y = 1.0, z = 1.0},
    collisionbox = {0,0,0,0,0,0},
    use_texture_alpha = true,
    physical = false,
    collide_with_objects = false,
    pointable = false,
    static_save = false,
  },

  on_step = function (self, delta)
    local node = core.get_node_or_nil(self.plunger_pos)
    if node then
      if node.name ~= mechanical_press_node then
        self.object:remove()
      end
    else
      self.object:remove()
      return
    end

    local meta = core.get_meta(self.plunger_pos)

    --- retrieve the plunger's intended position from the parent press
    --- this is its 1D position as in how far from the main body it should be extended
    local progress = meta:get_float("plunger_pos")
    --- determine what the plunger's UP direction currently is based on the parent node's rotation
    local dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
    --- retrieve the vector
    local vec = Directions.DIR6_TO_VEC3[dir]

    --- retrieve its current position, we will be using this vector as our destination
    local pos = self.object:get_pos()
    --- first set the plunger's relative position, we use 16 as the node is divided into 16 subvoxels
    Vector3.multiply(pos, vec, 13 * progress / 16)
    --- then add the parent's absolute position which will give us the final position
    Vector3.add(pos, pos, self.plunger_pos)
    --- replace the current position with our calculated one
    self.object:set_pos(pos)
  end,

  on_activate = function(self, static_data)
    local data = minetest.parse_json(static_data)

    self.plunger_id = data.plunger_id
    self.plunger_pos = data.plunger_pos

    if not self.plunger_id then
      self.object:remove()
    else
      self:refresh()
    end
  end,

  get_staticdata = function (self)
    local data = {
      plunger_id = self.plunger_id,
      plunger_pos = self.plunger_pos,
    }
    return minetest.write_json(data)
  end,

  refresh = function (self)
    local node = core.get_node(self.plunger_pos)
    self.object:set_properties({
      node = {
        name = mod:make_name("mechanical_press_plunger"),
        param1 = core.LIGHT_MAX,
        param2 = node.param2,
      },
    })
  end,
})

core.register_lbm({
  label = "Mechanical Press Plunger Spawn",

  nodenames = {mod:make_name("mechanical_press")},

  name = mod:make_name("mechanical_press_plunger_spawn"),

  run_at_every_load = true,

  action = function (pos, node)
    on_load(pos, node)
  end,
})
