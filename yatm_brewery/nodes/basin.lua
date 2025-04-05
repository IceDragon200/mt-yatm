--
-- Basins act as a item storage and fluid storage node, it is meant to interact with
-- a press or mixer node directly above it, actually any number of specialized
-- nodes can be placed above it to affect the recipe
--
local mod = assert(yatm_brewery)

local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)

local TANK_CAPACITY = 2000
local INPUT_TANK_NAME = "input_tank"
local OUTPUT_TANK_NAME = "output_tank"

local function get_fluid_tank_name(_self, pos, dir)
  local node = core.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_DOWN then
    return OUTPUT_TANK_NAME, TANK_CAPACITY
  elseif new_dir == Directions.D_UP or
         new_dir == Directions.D_EAST or
         new_dir == Directions.D_WEST or
         new_dir == Directions.D_NORTH or
         new_dir == Directions.D_SOUTH then
    return INPUT_TANK_NAME, TANK_CAPACITY
  end
  return nil, nil
end
local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)

local item_interface = ItemInterface.new_simple("main")

local function maybe_migrate_inventory(pos)
  local meta = core.get_meta(pos)

  local ver = meta:get_int("version")
  if ver < 1 do
    local inv = meta:get_inventory()
    local list = inv:get_list("main")
    inv:set_size("input", 4)
    inv:set_list("input", list)

    inv:set_size("processing", 4)
    inv:set_size("output", 2)
    ver = 1
    meta:set_int("version", ver)
  end
end

--- @private.spec get_formspec(Vector3, player: PlayerRef): String
local function get_formspec(pos, player)
  local spos = Vector3.to_string(pos)
  local node_inv_name = "nodemeta:" .. spos
  local meta = core.get_meta(pos)

  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  local formspec = yatm.formspec_render_split_inv_panel(player, 8, 4, { bg = "wood" }, function (loc, rect)
    if loc == "main_body" then
      local input_fluid_stack = FluidMeta.get_fluid_stack(meta, INPUT_TANK_NAME)
      local output_fluid_stack = FluidMeta.get_fluid_stack(meta, OUTPUT_TANK_NAME)
      -- If Ii  P  Oi Of
      return ""
        .. yatm_fspec.render_fluid_stack(
          rect.x + cio(0),
          rect.y,
          1,
          rect.h,
          input_fluid_stack,
          TANK_CAPACITY
        )
        .. fspec.list(node_inv_name, "input", rect.x + cio(1), rect.y, 1, 4)
        .. fspec.list(node_inv_name, "processing", rect.x + cio(3), rect.y, 1, 4)
        .. fspec.list(node_inv_name, "output", rect.x + cio(5), rect.y + cio(2), 1, 2)
        .. yatm_fspec.render_fluid_stack(
          rect.x + cio(6),
          rect.y,
          1,
          rect.h,
          output_fluid_stack,
          TANK_CAPACITY
        )
    elseif loc == "footer" then
      return fspec.list_ring()
    end
    return ""
  end)

  return formspec
end

--- @private.spec on_construct(pos: Vector3): void
local function on_construct(pos)
  maybe_migrate_inventory(pos)
end

--- @private.spec on_destruct(pos: Vector3): void
local function on_destruct(pos)
end

--- @private.spec on_rightclick(
---   pos: Vector3,
---   node: NodeRef,
---   clicker: PlayerRef,
---   item_stack: ItemStack,
---   pointed_thing: PointedThing
--- ): void
local function on_rightclick(pos, node, clicker, item_stack, pointed_thing)
  maybe_migrate_inventory(pos)

  local id = core.pos_to_string(pos)
  local options = {
    state = {
      pos = pos,
      id = id,
    },
  }

  nokore.formspec_bindings:show_formspec(
    player:get_player_name(),
    mod:make_name("wood_basin"),
    get_formspec(pos, player),
    options
  )
end

local node_box = {
  type = "fixed",
  fixed = {
    -- legs
    ng(0, 0, 0, 2, 2, 2),
    ng(14,0, 0, 2, 2, 2),
    ng(0, 0,14, 2, 2, 2),
    ng(14,0,14, 2, 2, 2),
    --
    ng(0, 2, 0,16, 1,16), -- base plate
    --
    ng(0, 3, 0,16,13, 1), -- north side
    ng(0, 3,15,16,13, 1), -- south side
    ng(0, 3, 1, 1,13,14), -- west side
    ng(15,3, 1, 1,13,14), -- east side
  },
}

mod:register_node("wood_basin", {
  description = mod.S("Wood Basin"),

  groups = {
    choppy = nokore.dig_class("wme"),
    --
    basin = 1,
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "none",
  paramtype2 = "facedir",
  tiles = {
    "yatm_basin_wood_top.png",
    "yatm_basin_wood_bottom.png",
    "yatm_basin_wood_side.png",
    "yatm_basin_wood_side.png",
    "yatm_basin_wood_side.png",
    "yatm_basin_wood_side.png",
  },

  on_construct = on_construct,
  on_destruct = on_destruct,
  on_rightclick = on_rightclick,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
})
