local Vector3 = assert(foundation.com.Vector3)
local is_blank = assert(foundation.com.is_blank)
local string_split = assert(foundation.com.string_split)
local table_merge = assert(foundation.com.table_merge)
local Directions = assert(foundation.com.Directions)
local fspec = assert(foundation.com.formspec.api)

yatm.shelves = {}

yatm.shelves.PRESET_SCALES = {
  ["1x1x1"] = 0.25,
  ["1x2x1"] = 0.20,
  ["2x2x1"] = 0.20,
  ["3x2x1"] = 0.15,
  ["4x2x1"] = 0.125,
}

local function parse_shelf_item_static_data(static_data)
  if is_blank(static_data) then
    return nil
  end
  local data = string_split(static_data, "data:")
  if is_blank(data[2]) then
    return nil
  end
  local attrs = string_split(data[2], "|")
  if #attrs == 3 then
    local shelf_pos = attrs[1]
    local scale = tonumber(attrs[2])
    local item_name = attrs[3]

    return {
      shelf_pos = shelf_pos,
      scale = scale,
      item_name = item_name
    }
  end
  return nil
end

local function get_shelf_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos

  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local rows = nodedef.shelf_configuration.layers * nodedef.shelf_configuration.rows
  local cols = nodedef.shelf_configuration.cols

  local bg
  if nodedef.material_basename == "wood" then
    bg = "wood"
  else
    bg = "default"
  end

  return yatm.formspec_render_split_inv_panel(user, cols, rows, { bg = bg }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "main", rect.x, rect.y, cols, rows)
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "main") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

function yatm.shelves.clear_entities(pos)
  local shelf_pos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  for _, object in ipairs(minetest.get_objects_inside_radius(pos, 0.75)) do
    if not object:is_player() then
      local lua_entity = object:get_luaentity()
      if lua_entity then
        local data = parse_shelf_item_static_data(lua_entity:get_staticdata())
        if data and data.shelf_pos == shelf_pos then
          object:remove()
        end
      end
    end
  end
end

function yatm.shelves.shelf_on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local shelf_configuration = assert(nodedef.shelf_configuration)

  local size = shelf_configuration.cols * shelf_configuration.rows * shelf_configuration.layers

  local inv = meta:get_inventory()
  inv:set_size("main", size)
end

function yatm.shelves.shelf_on_destruct(pos)
  yatm.shelves.clear_entities(pos)
end

function yatm.shelves.shelf_after_destruct(pos, old_node)
  --
end

function yatm.shelves.shelf_on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  if inv:is_empty("main") then
    yatm.shelves.clear_entities(pos)
    return minetest.node_dig(pos, node, digger)
  end
  return false
end

function yatm.shelves.shelf_on_blast(pos, intensity)
  yatm.shelves.clear_entities(pos)
end

function yatm.shelves.shelf_refresh(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local shelf_configuration = assert(nodedef.shelf_configuration)

  yatm.shelves.clear_entities(pos)
  -- Add the new entities
  local shelf_pos = pos.x .. "," .. pos.y .. "," .. pos.z

  local inv = meta:get_inventory()
  local list = inv:get_list("main")

  local dir = minetest.facedir_to_dir(node.param2)
  local item_yaw = minetest.dir_to_yaw(dir)

  local depth_displacement = 0.25
  local horizontal_displacement = 0.25
  local vertical_displacement = 0.25

  local layer_area = shelf_configuration.rows * shelf_configuration.cols

  local available_area = 14 / 16 -- 1px borders normally

  local offset = 1 - available_area

  local yd = available_area / shelf_configuration.rows
  local xd = available_area / shelf_configuration.cols
  local zd = available_area / shelf_configuration.layers

  -- 0.20 works great for 2x2

  -- Sadly I can't seem to figure out the golden ratio so for now I'll just fix the scales
  local scale_preset = shelf_configuration.cols .. "x" ..
                       shelf_configuration.rows .. "x" ..
                       shelf_configuration.layers
  --local scale = (math.min(math.min(xd, yd), 0.5) - offset) * 0.9
  local scale = assert(yatm.shelves.PRESET_SCALES[scale_preset], "expected " .. scale_preset .. "to exist")

  -- it starts in the middle, so we need to 0 it to start from the bottom left
  -- this can be done by shifting everything over by a quarter
  -- except the z, which needs to be pushed forward
  -- the item also needs to be recentered
  local item_base_pos = {
    x = -0.5 + offset / 2,
    y = -0.5 + offset / 2,
    z =  0.25,
  }

  item_base_pos.x = item_base_pos.x + xd / 2
  item_base_pos.y = item_base_pos.y + yd / 2

  for i, item_stack in ipairs(list) do
    if not item_stack:is_empty() then
      -- because lua starts it's index at 1, this needs to be adjusted to a 0 for calculations
      local o = i - 1

      -- items are organized in the following order:
      --   layer (z)
      --   row (y)
      --   col (x)
      -- This is similar to how a image would be drawn, col in row in layer
      local layer = math.floor(o / layer_area)
      local row = math.floor(o / shelf_configuration.cols) % shelf_configuration.rows
      row = shelf_configuration.rows - row - 1 -- invert the rows
      local col = o % shelf_configuration.cols

      local offpos =
        Directions.rotate_position_by_facedir({
          x = item_base_pos.x + xd * col,
          y = item_base_pos.y + yd * row,
          z = item_base_pos.z + zd * layer,
        }, 0 --[[ Default to NORTH ]], node.param2)

      local obj_pos = vector.add(pos, offpos)

      local static_data = "data:" .. shelf_pos .. "|" .. scale .. "|" .. item_stack:get_name()

      local entity = minetest.add_entity(obj_pos, "yatm_item_shelves:shelf_item", static_data)
      entity:set_yaw(item_yaw)
    end
  end
end

function yatm.shelves.shelf_on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  yatm.shelves.shelf_refresh(pos)
end

function yatm.shelves.shelf_on_metadata_inventory_put(pos, listname, index, stack, player)
  yatm.shelves.shelf_refresh(pos)
end

function yatm.shelves.shelf_on_metadata_inventory_take(pos, listname, index, stack, player)
  yatm.shelves.shelf_refresh(pos)
end

function yatm.shelves.shelf_on_rightclick(pos, node, user)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_item_shelves:shelf",
    get_shelf_formspec(pos, user)
  )
end

function yatm.shelves.register_shelf(name, def)
  local groups = def.groups or {}
  def.groups = nil

  minetest.register_node(name, table_merge({
    groups = table_merge({
      item_shelf = 1,
    }, groups),

    paramtype = "light",
    paramtype2 = "facedir",

    on_construct = yatm.shelves.shelf_on_construct,
    on_destruct = yatm.shelves.shelf_on_destruct,
    after_destruct = yatm.shelves.shelf_after_destruct,
    on_dig = yatm.shelves.shelf_on_dig,
    on_blast = yatm.shelves.shelf_on_blast,

    on_metadata_inventory_move = yatm.shelves.shelf_on_metadata_inventory_move,
    on_metadata_inventory_put = yatm.shelves.shelf_on_metadata_inventory_put,
    on_metadata_inventory_take = yatm.shelves.shelf_on_metadata_inventory_take,

    action_hints = {
      secondary = "inventory",
    },

    on_rightclick = yatm.shelves.shelf_on_rightclick,
  }, def))
end

minetest.register_entity("yatm_item_shelves:shelf_item", {
  initial_properties = {
    hp_max = 1,
    visual = "wielditem",
    visual_size = {x = 0.20, y = 0.20},
    collisionbox = {0,0,0, 0,0,0},
    --use_texture_alpha = "clip",
    use_texture_alpha = true,
    physical = false,
    collide_with_objects = false,
    pointable = false,
    static_save = false, -- delete the entity on block unload, the shelf will refresh it on load
  },

  on_step = function (self, delta)
    --
  end,

  on_activate = function(self, static_data)
    local data = parse_shelf_item_static_data(static_data)
    if not data then
      minetest.log("error", "shelf entity static data was invalid, removing it")
      self.object:remove()
      return
    end

    self.shelf_pos = data.shelf_pos
    self.scale = data.scale
    self.item_name = data.item_name

    local pos_and_index = string_split(data.shelf_pos, ",")

    local x = tonumber(pos_and_index[1])
    local y = tonumber(pos_and_index[2])
    local z = tonumber(pos_and_index[3])

    local node_pos = { x = x, y = y, z = z }
    local node = minetest.get_node(node_pos)
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef and nodedef.groups.item_shelf then
      local properties = {
        visual_size = { x = self.scale, y = self.scale, z = self.scale },
        shelf_pos = self.shelf_pos,
        wield_item = self.item_name,
        itemstring = self.item_name,
      }
      self.object:set_properties(properties)
    else
      -- Invalid item shelf entity, removing
      minetest.log("error", "entity is invalid, removing pos=" .. minetest.pos_to_string(node_pos) .. " name=" .. node.name)
      self.object:remove()
    end
  end,

  get_staticdata = function (self)
    if self.shelf_pos and self.scale and self.item_name then
      return "data:" .. self.shelf_pos .. "|" .. self.scale .. "|" .. self.item_name
    else
      return ""
    end
  end,
})

local LoadingSystem = foundation.com.Class:extends("shelves.LoadingSystem")
local ic = LoadingSystem.instance_class

function ic:initialize()
  self.queue_max_size = 0xFFFF
  self.loading_queue = {}
  self.start_index = 0
  self.end_index = 0
  self.size = 0
  self.wait = 0
end

function ic:next_item()
  if self.size > 0 then
    self.size = self.size - 1
    local item = self.loading_queue[self.start_index]
    self.loading_queue[self.start_index] = nil
    self.start_index = (self.start_index + 1) % self.queue_max_size
    return item
  else
    return nil
  end
end

function ic:push_item(item)
  minetest.log("info", "pushing item " .. dump(item))
  self.size = self.size + 1
  self.loading_queue[self.end_index] = item
  self.end_index = (self.end_index + 1) % self.queue_max_size
  return self
end

function ic:update(delta)
  if self.wait > 0 then
    self.wait = self.wait - delta
    return
  end
  local seen_items = 0
  while seen_items < 8 do
    local item = self:next_item()
    if item then
      yatm.shelves.shelf_refresh(item)
      seen_items = seen_items + 1
    else
      break
    end
  end
  if seen_items > 0 then
    self.wait = 0.25
    minetest.log("info", "refreshed" ..
                          " start=" .. self.start_index ..
                          " end=" .. self.end_index ..
                          " count=" .. seen_items .. " shelves this round")
  end
end

local loading_system = LoadingSystem:new()

nokore_proxy.register_globalstep(
  "yatm_item_shelves.update/1",
  loading_system:method("update")
)

minetest.register_lbm({
  label = "Refresh Shelf Contents",

  nodenames = {"group:item_shelf"},

  name = "yatm_item_shelves:refresh_shelf_contents",

  run_at_every_load = true,

  action = function (pos, _node)
    minetest.log("info", "reloading shelf contents pos=" .. Vector3.to_string(pos))
    loading_system:push_item(pos)
  end,
})
