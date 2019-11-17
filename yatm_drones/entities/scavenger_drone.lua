local g_inventory_id = 0
local view_range = (minetest.get_mapgen_setting('active_object_send_range_blocks') or 3) * 3

local function create_inventory(self)
  g_inventory_id = g_inventory_id + 1
  local inventory_name = "yatm_drones:drone_inventory_" .. g_inventory_id

  local inv =
    minetest.create_detached_inventory(inventory_name, {
      allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        return count
      end,

      allow_put = function(inv, listname, index, stack, player)
        return stack:get_count()
      end,

      allow_take = function(inv, listname, index, stack, player)
        return stack:get_count()
      end,

      on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        --
      end,

      on_put = function(inv, listname, index, stack, player)
        --
      end,

      on_take = function(inv, listname, index, stack, player)
        --
      end,
    })

  inv:set_size("main", 4*4)
  inv:set_size("upgrades", 4)
  inv:set_size("batteries", 2) -- backup batteries that is

  self.inventory_name = "yatm_drones:drone_inventory_" .. g_inventory_id
  return inv
end

local function restore_inventory(self, dump)
  local inv = self:get_inventory()

  for list_name, dumped_list in pairs(dump.data) do
    local list = inv:get_list(list_name)
    assert(list, "expected list to exist name=" .. list_name)
    list = yatm_item_storage.InventorySerializer.deserialize(dumped_list, list)
    inv:set_list(list_name, list)
  end
end

local function get_inventory(self)
  return minetest.get_inventory({
    type = "detached",
    name = self.inventory_name,
  })
end

local function dump_inventory(self)
  local inv = self:get_inventory()

  local lists = inv:get_lists()

  local result = {}

  for list_name, list in pairs(lists) do
    result[list_name] = yatm_item_storage.InventorySerializer.serialize(list)
  end

  return { version = 1, data = result }
end

local function get_nearby_entity_item(self)
  for _,obj in ipairs(self.nearby_objects) do
    local ent = obj:get_luaentity()
    if ent then
      if ent.name == "__builtin:item" then
        return obj
      end
    end
  end
  return nil
end

local function drone_hq_pickup_item(self, prty)
  local func = function(self)
    if mobkit.is_queue_empty_low(self) and self.isonground then
      local item_entity = get_nearby_entity_item(self)
      if item_entity then
        local item_stack = ItemStack(item_entity:get_luaentity().itemstring)
        local inv = self:get_inventory()

        if inv:room_for_item("main", item_stack) then
          local pos = mobkit.get_stand_pos(self)
          local tpos = mobkit.get_stand_pos(item_entity)
          if vector.distance(pos,tpos) > 1 then
            mobkit.goto_next_waypoint(self, tpos)
          else
            inv:add_item("main", item_stack)
            item_entity:remove()
            return true
          end
        else
          return true
        end
      else
        return true
      end
    end
  end
  mobkit.queue_high(self,func,prty)
end

local function hq_find_docking_station(self, prty, search_radius)
  local func = function(self)
    if mobkit.is_queue_empty_low(self) and self.isonground then
      local pos = mobkit.get_stand_pos(self)

      local closest_dock = mobkit.recall(self, "closest_dock")

      if closest_dock then
        local node = minetest.get_node(closest_dock)

        if not yatm_core.groups.item_has_group(node.name, "scavenger_docking_station") then
          closest_dock = nil
        end
      end

      if not closest_dock then
        local pos1 = vector.subtract(pos, search_radius)
        local pos2 = vector.add(pos, search_radius)
        local nodes = minetest.find_nodes_in_area(pos1, pos2, "group:scavenger_docking_station")

        for _, node_pos in ipairs(nodes) do
          if closest_dock then
            if vector.distance(closest_dock, pos) > vector.distance(node_pos, pos) then
              closest_dock = node_pos
            end
          else
            closest_dock = node_pos
          end
        end
      end

      if closest_dock then
        mobkit.remember(self, "closest_dock", closest_dock)
        local dist = vector.distance(closest_dock, pos)
        if dist < 0.5 then
          -- try charging
          mobkit.remember(self, "charging", true)
          return true
        else
          mobkit.goto_next_waypoint(self, closest_dock)
        end
      else
        mobkit.forget(self, "closest_dock")
        return true
      end
    end
  end
  mobkit.queue_high(self,func,prty)
end

local function hq_return_to_docking_station(self, prty)
end

local function drone_logic(self)
  if not mobkit.recall(self, "charging") then
    self:consume_energy(20 * self.dtime) -- loses energy
  end
  if mobkit.timer(self, 1) then
    if mobkit.recall(self, "charging") then
      local closest_dock = mobkit.recall(self, "closest_dock")
      if closest_dock then
        local node = minetest.get_node(closest_dock)

        if yatm_core.groups.item_has_group(node.name, "scavenger_docking_station") then
          local nodedef = minetest.registered_nodes[node.name]
          nodedef.yatm_network.charge_drone(closest_dock, node, self)

          if mobkit.recall(self, "available_energy") >= 6000 then
            mobkit.forget(self, "charging")
          end
        else
          mobkit.forget(self, "charging")
          mobkit.forget(self, "closest_dock")
        end
      else
        mobkit.forget(self, "charging")
        mobkit.forget(self, "closest_dock")
      end
    end

    if not mobkit.recall(self, "charging") then
      local available_energy = mobkit.recall(self, "available_energy") or 0
      if available_energy > 0 then
        if available_energy > 1000 then
          local item_entity = get_nearby_entity_item(self)
          if item_entity then
            mobkit.clear_queue_high(self)
            drone_hq_pickup_item(self, 20)
            mobkit.forget(self, "idle_time")
            self:change_action_text("picking up an item")
          else
            mobkit.clear_queue_high(self)
            mobkit.hq_roam(self, 10)
            local idle_time = mobkit.recall(self, "idle_time") or 0
            idle_time = idle_time + self.dtime
            mobkit.remember(self, "idle_time", idle_time)
            self:change_action_text("idling")
          end
        else
          -- find a docking station ASAP
          mobkit.clear_queue_high(self)
          local search_radius = 32
          hq_find_docking_station(self, 50, search_radius)
          self:change_action_text("docking")
          mobkit.forget(self, "idle_time")
        end

        if self.state ~= "on" then
          self.state = "on"

          self.object:set_properties({
            textures = {"yatm_scavenger_drone.on.png"}
          })
        end
      else
        mobkit.forget(self, "action")
        if self.state ~= "off" then
          self.state = "off"

          self.object:set_properties({
            textures = {"yatm_scavenger_drone.off.png"}
          })
        end

        local search_radius = 0.5 -- can't move, so it needs to look at any immediate nodes
        hq_find_docking_station(self, 50, search_radius)
      end
    end
  end
end

local function get_scavenger_drone_formspec(self)
  local formspec =
    "size[8,9]" ..
    "label[0,0;Inventory]" ..
    "list[detached:" .. self.inventory_name .. ";main;0,0.5;4,4;]" ..
    "label[4,0;Upgrades]" ..
    "list[detached:" .. self.inventory_name .. ";upgrades;4,0.5;4,1;]" ..
    "label[4,2;Batteries]" ..
    "list[detached:" .. self.inventory_name .. ";batteries;4,2.5;2,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. self.inventory_name .. ";main]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. self.inventory_name .. ";upgrades]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. self.inventory_name .. ";batteries]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(2,4.85)

  return formspec
end

minetest.register_entity("yatm_drones:scavenger_drone", {
  --initial_properties = {
    physical = true,
    collide_with_objects = true,
    visual = "mesh",
    visual_size = {x = 10, y = 10},
    collisionbox = yatm_core.Cuboid:new(2, 0, 2, 12, 6, 12):fast_node_box(),
    mesh = "scavenger_drone.b3d",
    textures = {"yatm_scavenger_drone.off.png"},
  --},

  weight = 100,
  stepheight = 0.1,
  springiness = 0,
  buoyancy = 1,
  max_hp = 1,
  max_speed = 5,
  jump_height = 0.25, -- it really shouldn't be jumping
  view_range = view_range,
  static_save = true,

  timeout = 0,

  get_inventory = get_inventory,

  set_owner_name = function (self, name)
    mobkit.remember(self, "owner_name", name)
  end,

  refresh_infotext = function (self)
    local available_energy = mobkit.recall(self, "available_energy") or 0
    local infotext =
      "Owner: " .. (mobkit.recall(self, "owner_name") or "N/A") .. "\n" ..
      "Energy: " .. math.floor(available_energy) .. "\n" ..
      (mobkit.recall(self, "action") or "")

    self.object:set_properties({
      infotext = infotext
    })
  end,

  change_action_text = function (self, text)
    if mobkit.recall(self, "action") ~= text then
      mobkit.remember(self, "action", text)
      self:refresh_infotext()
    end
  end,

  receive_energy = function (self, amount)
    local available_energy = mobkit.recall(self, "available_energy") or 0

    local new_energy = math.min(available_energy + amount, 6000)
    mobkit.remember(self, "available_energy", new_energy)

    self:refresh_infotext()

    return new_energy - available_energy
  end,

  consume_energy = function (self, amount)
    local available_energy = mobkit.recall(self, "available_energy") or 0

    local new_energy = math.max(available_energy - amount, 0)
    mobkit.remember(self, "available_energy", new_energy)

    self:refresh_infotext()

    return available_energy - new_energy
  end,

  on_step = assert(mobkit.stepfunc),

  on_activate = function (self, staticdata, dtime_s)
    -- load the data first, and then recover the inventory from it
    mobkit.actfunc(self, staticdata, dtime_s)

    create_inventory(self)

    if self.memory["inventory"] then
      restore_inventory(self, self.memory["inventory"])
    end

    -- blow up the inventory
    self.memory["inventory"] = nil
  end,

  get_staticdata = function (self)
    if not self.memory then
      self.memory = {}
    end

    self.memory["inventory"] = dump_inventory(self)
    -- then store it
    return mobkit.statfunc(self)
  end,

  logic = drone_logic,

  on_rightclick = function (self, clicker)
    minetest.show_formspec(
      clicker:get_player_name(),
      "yatm_drones:scavenger_drone",
      get_scavenger_drone_formspec(self)
    )
  end,

  on_punch = function (self, puncher)
    if mobkit.is_alive(self) then
      mobkit.hq_die(self)
    end
  end
})
