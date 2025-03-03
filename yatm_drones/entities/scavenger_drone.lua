local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Groups = assert(foundation.com.Groups)
local Vector3 = assert(foundation.com.Vector3)
local Directions = assert(foundation.com.Directions)
local Energy = assert(yatm.energy)
local invbat = assert(yatm.energy.inventory_batteries)
local InventorySerializer = assert(yatm.items.InventorySerializer)
local fspec = assert(foundation.com.formspec.api)

local g_inventory_id = 0
local view_range = (minetest.get_mapgen_setting('active_object_send_range_blocks') or 3) * 3

local function create_inventory(self)
  g_inventory_id = g_inventory_id + 1
  local inventory_name = "yatm_drones:drone_inventory_" .. g_inventory_id

  local inv =
    minetest.create_detached_inventory(inventory_name, {
      allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        if to_list == "upgrades" then
          return 1
        elseif to_list == "batteries" then
          return 1
        end
        return count
      end,

      allow_put = function(inv, listname, index, stack, player)
        local item = stack:get_definition()
        if listname == "upgrades" then
          if Groups.has_group(item, "drone_upgrade") then
            return 1
          end
        elseif listname == "batteries" then
          if Groups.has_group(item, "battery") then
            return 1
          end
        elseif listname == "main" then
          return stack:get_count()
        end
        return 0
      end,

      allow_take = function(inv, listname, index, stack, player)
        if listname == "upgrades" then
          return 1
        elseif listname == "batteries" then
          return 1
        end
        return stack:get_count()
      end,

      on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        --
      end,

      on_put = function(inv, listname, index, stack, player)
        if listname == "upgrades" then
          print("Upgrade placed ", stack:get_name())
          self:refresh_upgrades()
        end
      end,

      on_take = function(inv, listname, index, stack, player)
        --
      end,
    })

  inv:set_size("main", 4*4)
  inv:set_size("upgrades", 6)
  inv:set_size("batteries", 4)

  self.inventory_name = "yatm_drones:drone_inventory_" .. g_inventory_id
  return inv
end

local function restore_inventory(self, dump)
  local inv = self:get_inventory()

  for list_name, dumped_list in pairs(dump.data) do
    local list = inv:get_list(list_name)
    assert(list, "expected list to exist name=" .. list_name)
    list = InventorySerializer.load_list(dumped_list, list)
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
    result[list_name] = InventorySerializer.dump_list(list)
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

local function try_teleport_or_move(self, tpos, dist)
  if dist < self.teleport_range then
    -- trigger teleport
    local new_pos = Vector3.copy(tpos)
    new_pos.y = new_pos.y + 1
    self.object:set_pos(new_pos)
  else
    mobkit.goto_next_waypoint(self, tpos)
  end
end

local function hq_pickup_item(self)
  if mobkit.is_queue_empty_low(self) and self.isonground then
    local item_entity = get_nearby_entity_item(self)
    if item_entity then
      local item_stack = ItemStack(item_entity:get_luaentity().itemstring)
      local inv = self:get_inventory()

      if inv:room_for_item("main", item_stack) then
        local pos = mobkit.get_stand_pos(self)
        local tpos = item_entity:get_pos()
        local voodoo_range = self.voodoo_range
        local dist = vector.distance(pos,tpos)

        if voodoo_range and voodoo_range > 0 then
          if dist < voodoo_range then
            -- TODO: the drone should take some time before it can pick up the item
            -- using voodoo, also play some visual and audio effects when it uses voodoo
            -- versus regular vacuum
            -- it should also consumer quite a bit of energy
            inv:add_item("main", item_stack)
            item_entity:remove()
            return true
          else
            try_teleport_or_move(self, tpos, dist)
          end
        else
          local vacuum_range = self.vacuum_range

          if dist > vacuum_range then
            try_teleport_or_move(self, tpos, dist)
          else
            inv:add_item("main", item_stack)
            item_entity:remove()
            return true
          end
        end
      else
        mobkit.remember(self, "need_dropoff", true)
        return true
      end
    else
      return true
    end
  end
end

local function hq_find_dropoff_station(self, prty, search_radius)
  local func = function(self)
    if mobkit.is_queue_empty_low(self) and self.isonground then
      local pos = mobkit.get_stand_pos(self)

      local closest_dropoff = mobkit.recall(self, "closest_dropoff")

      local closest_dropoff_timeout = (mobkit.recall(self, "closest_dropoff_timeout") or 0) - self.dtime

      if closest_dropoff then
        if closest_dropoff_timeout <= 0 then
          closest_dropoff = nil
        else
          local node = minetest.get_node(closest_dropoff)

          if not Groups.item_has_group(node.name, "scavenger_dropoff_station") then
            closest_dropoff = nil
          end
        end
      end

      if not closest_dropoff then
        local pos1 = vector.subtract(pos, search_radius)
        local pos2 = vector.add(pos, search_radius)
        local nodes = minetest.find_nodes_in_area(pos1, pos2, "group:scavenger_dropoff_station")

        for _, node_pos in ipairs(nodes) do
          if closest_dropoff then
            if vector.distance(closest_dropoff, pos) > vector.distance(node_pos, pos) then
              closest_dropoff = node_pos
            end
          else
            closest_dropoff = node_pos
          end
        end

        if closest_dropoff then
          closest_dropoff_timeout = 15
        end
      end

      if closest_dropoff then
        mobkit.remember(self, "closest_dropoff", closest_dropoff)
        mobkit.remember(self, "closest_dropoff_timeout", closest_dropoff_timeout)
        local dist = vector.distance(closest_dropoff, pos)
        if dist < 0.5 then
          -- try dropping off items
          mobkit.forget(self, "need_dropoff")
          mobkit.remember(self, "dropping_off", true)
          return true
        else
          try_teleport_or_move(self, closest_dropoff, dist)
        end
      else
        mobkit.forget(self, "closest_dropoff")
        mobkit.forget(self, "closest_dropoff_timeout")
        return true
      end
    end
  end

  mobkit.queue_high(self, func, prty)
end

local function hq_find_docking_station(self, prty, search_radius, can_move)
  local func = function(self)
    if mobkit.is_queue_empty_low(self) and self.isonground then
      local pos = mobkit.get_stand_pos(self)

      local closest_dock = mobkit.recall(self, "closest_dock")

      if closest_dock then
        local node = minetest.get_node(closest_dock)

        if not Groups.item_has_group(node.name, "scavenger_docking_station") then
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
          if can_move then
            try_teleport_or_move(self, closest_dock, dist)
          else
            return true
          end
        end
      else
        mobkit.forget(self, "closest_dock")
        return true
      end
    end
  end
  mobkit.queue_high(self, func, prty)
end

local function hq_return_to_docking_station(self, prty)
end

-- How much energy does a drone consume per second while active
local ENERGY_PER_SECOND = 20

local function drone_logic(self)
  --mobkit.remember(self, "elapsed", (mobkit.recall(self, "elapsed") or 0) + self.elapsed)

  do
    -- TODO: should also check light levels
    local solar_charge_rate = self.solar_charge_rate or 0.0

    if solar_charge_rate > 0 then
      local tod = minetest.get_timeofday()

      if tod < 0.25 or tod >= 0.80 then
        -- night
      else
        -- day
        self.energy.receive_energy(self, solar_charge_rate * ENERGY_PER_SECOND * self.dtime)
      end
    end
  end

  if not mobkit.recall(self, "charging") then
    -- It not charging, lose energy like normal
    local energy_rate = self.energy_rate or 1.0
    self.energy.consume_energy(self, energy_rate * ENERGY_PER_SECOND * self.dtime)
  end

  if mobkit.timer(self, 1) then
    if mobkit.recall(self, "charging") then
      -- Do charging stuff, by picking the closest docking station
      local closest_dock = mobkit.recall(self, "closest_dock")
      if closest_dock then
        local node = minetest.get_node(closest_dock)

        if Groups.item_has_group(node.name, "scavenger_docking_station") then
          local nodedef = minetest.registered_nodes[node.name]
          nodedef.yatm_network.charge_drone(closest_dock, node, self)
          self:change_state("charging")
          self:change_action_text("Charging")

          if mobkit.recall(self, "available_energy") >= self.energy.get_capacity(self) then
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
          if mobkit.recall(self, "dropping_off") then
            self:change_state("dropoff")
            -- found a dropoff station, need to dropoff items now.
            mobkit.clear_queue_high(self)

            mobkit.forget(self, "idle_time")

            local inv = self:get_inventory()

            if inv:is_empty("main") then
              mobkit.forget(self, "dropping_off")
            else
              local closest_dropoff = mobkit.recall(self, "closest_dropoff")
              if closest_dropoff then
                local node = minetest.get_node(closest_dropoff)

                if Groups.item_has_group(node.name, "scavenger_dropoff_station") then
                  local main_list = inv:get_list("main")

                  local new_list = {}
                  local remaining

                  for i, item in ipairs(main_list) do
                    if item:is_empty() then
                      new_list[i] = item
                    else
                      remaining = yatm.items.ItemDevice.insert_item(
                        closest_dropoff,
                        Directions.D_NONE,
                        item,
                        true
                      )
                      if remaining then
                        new_list[i] = foundation.com.itemstack_copy(remaining)
                      else
                        new_list[i] = item
                      end
                    end
                  end

                  inv:set_list("main", new_list)
                else
                  mobkit.forget(self, "closest_dropoff")
                  mobkit.forget(self, "dropping_off")
                end
              else
                mobkit.forget(self, "closest_dropoff")
                mobkit.forget(self, "dropping_off")
              end
            end
          elseif mobkit.recall(self, "need_dropoff") then
            -- Need to find a dropoff station
            mobkit.clear_queue_high(self)
            local search_radius = 64
            hq_find_dropoff_station(self, 20, search_radius)
            self:change_action_text("dropping off items")
            self:change_state("dropoff")
          else
            local item_entity = get_nearby_entity_item(self)
            if item_entity then
              mobkit.clear_queue_high(self)
              mobkit.queue_high(self, hq_pickup_item, 20)
              mobkit.forget(self, "idle_time")
              self:change_action_text("picking up an item")
              self:change_state("on")
            else
              mobkit.clear_queue_high(self)
              mobkit.hq_roam(self, 10)
              local idle_time = mobkit.recall(self, "idle_time") or 0
              idle_time = idle_time + self.dtime
              mobkit.remember(self, "idle_time", idle_time)
              self:change_action_text("Idling " .. math.floor(idle_time))
              self:change_state("idle")
              if idle_time >= 15 then
                -- if idling for more than 15 seconds, and the inventory isn't empty.
                local inv = self:get_inventory()

                if not inv:is_empty("main") then
                  mobkit.remember(self, "need_dropoff", true)
                end
              end
            end
          end
        else
          -- find a docking station ASAP
          mobkit.clear_queue_high(self)
          local search_radius = 64
          hq_find_docking_station(self, 50, search_radius, true)
          self:change_action_text("docking")
          mobkit.forget(self, "idle_time")
          self:change_state("on")
        end
      else
        mobkit.forget(self, "action")
        self:change_state("off")

        local search_radius = 0.5 -- can't move, so it needs to look at any immediate nodes
        mobkit.clear_queue_high(self)
        hq_find_docking_station(self, 50, search_radius, false)
      end
    end
  end
end

--- @private.spec render_formspec(PlayerRef, assigns: Any): String
local function render_formspec(user, assigns)
  local entity = assigns.entity
  local cio = fspec.calc_inventory_offset

  local formspec

  local tabs = {
    "Inventory",
    "Info"
  }

  local tabheader = fspec.tabheader(0, 0, nil, nil, "drone_tab", tabs, assigns.tab)

  if assigns.tab == 1 then
    local list_name = "detached:"..entity.inventory_name

    formspec =
      yatm.formspec_render_split_inv_panel(user, 8, 5, { bg = "machine" }, function (slot, rect)
        if slot == "header" then
          return tabheader
        elseif slot == "main_body" then
          return ""
            .. fspec.label(rect.x, rect.y + 0.25, "Inventory")
            .. fspec.list(list_name, "main", rect.x, rect.y + 0.5, 4, 4)
            .. fspec.label(rect.x + cio(5), rect.y + 0.25, "Upgrades")
            .. fspec.list(list_name, "upgrades", rect.x + cio(5), rect.y + 0.5, 3, 2)
            .. fspec.label(rect.x + cio(5), rect.y + 3, "Batteries")
            .. fspec.list(list_name, "batteries", rect.x + cio(5), rect.y + 3.25, 2, 2)
        elseif slot == "footer" then
          return ""
            .. fspec.list_ring("detached:" .. entity.inventory_name, "main")
            .. fspec.list_ring("current_player", "main")
            .. fspec.list_ring("detached:" .. entity.inventory_name, "upgrades")
            .. fspec.list_ring("current_player", "main")
            .. fspec.list_ring("detached:" .. entity.inventory_name, "batteries")
            .. fspec.list_ring("current_player", "main")
        end

        return ""
      end)
  else
    formspec =
      yatm.formspec_render_split_inv_panel(user, 8, 5, { bg = "machine" }, function (slot, rect)
        if slot == "header" then
          return tabheader
        elseif slot == "main_body" then
          return fspec.label(rect.x, rect.y, "Jump Height") ..
                   fspec.label(rect.x, rect.y + 0.5, entity.jump_height) ..
                 fspec.label(rect.x, rect.y + 1, "Vacuum Range") ..
                   fspec.label(rect.x, rect.y + 1.5, entity.vacuum_range) ..
                 fspec.label(rect.x, rect.y + 2, "Voodoo Range") ..
                   fspec.label(rect.x, rect.y + 2.5, entity.voodoo_range) ..
                 fspec.label(rect.x, rect.y + 3, "View Range") ..
                   fspec.label(rect.x, rect.y + 3.5, entity.view_range) ..
                 fspec.label(rect.x + cio(4), rect.y, "Solar Charge Rate") ..
                   fspec.label(rect.x + cio(4), rect.y + 0.5, entity.solar_charge_rate) ..
                 fspec.label(rect.x + cio(4), rect.y + 1, "Teleport Range") ..
                   fspec.label(rect.x + cio(4), rect.y + 1.5, entity.teleport_range) ..
                 fspec.label(rect.x + cio(4), rect.y + 2, "Max HP") ..
                   fspec.label(rect.x + cio(4), rect.y + 2.5, entity.max_hp) ..
                 fspec.label(rect.x + cio(4), rect.y + 3, "Max Speed") ..
                   fspec.label(rect.x + cio(4), rect.y + 3.5, entity.max_speed)
        elseif slot == "footer" then
          return ""
        end

        return ""
      end)
  end

  return formspec
end

local function get_scavenger_drone_on_receive_fields(user, form_name, fields, assigns)
  if fields.drone_tab then
    assigns.tab = math.max(1, math.min(2, tonumber(fields.drone_tab)))
    return true, render_formspec(user, assigns)
  end
  return true
end

minetest.register_entity("yatm_drones:scavenger_drone", {
  initial_properties = {
    physical = true,
    collide_with_objects = true,
    visual = "mesh",
    visual_size = {x = 10, y = 10},
    collisionbox = ng(2, 0, 2, 12, 6, 12),
    mesh = "scavenger_drone.b3d",
    textures = {"yatm_scavenger_drone.off.png"},
    static_save = true,
    --
    stepheight = 0.3,
  },

  groups = {
    nameable = 1,
  },

  weight = 100,
  springiness = 0,
  buoyancy = 1,
  max_hp = 1,
  max_speed = 5,
  solar_charge_rate = 0.0, -- during the daytime, the rate of energy recovery
  jump_height = 0.5, -- it really shouldn't be jumping
  vacuum_range = 1.0,
  energy_rate = 1.0,
  teleport_range = 0,
  voodoo_range = 0,
  view_range = view_range,

  timeout = 0,

  get_inventory = get_inventory,

  change_state = function (self, new_state)
    if self.state ~= new_state then
      self.state = new_state

      self.object:set_properties({
        textures = {"yatm_scavenger_drone." .. new_state .. ".png"}
      })
    end
  end,

  set_owner_name = function (self, name)
    mobkit.remember(self, "owner_name", name)
  end,

  refresh_infotext = function (self)
    local available_energy = mobkit.recall(self, "available_energy") or 0
    local capacity = self.energy.get_capacity(self)

    local infotext =
      "Owner: " .. (mobkit.recall(self, "owner_name") or "N/A") .. "\n" ..
      "Energy: " .. Energy.format_string(available_energy, capacity) .. "\n" ..
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

  refresh_upgrades = function (self)
    local max_speed = 5
    local jump_height = 0.5
    local vacuum_range = 1.0
    local energy_rate = 1.0
    local solar_charge_rate = 0.0
    local teleport_range = 0
    local voodoo_range = 0

    local inv = self:get_inventory()

    local size = inv:get_size("upgrades")

    for i = 1,size do
      local stack = inv:get_stack("upgrades", i)

      if not stack:is_empty() then
        local item = stack:get_definition()

        if Groups.has_group(item, "speed_upgrade") then
          max_speed = max_speed + 1
        elseif Groups.has_group(item, "jump_upgrade") then
          jump_height = jump_height + 0.5
        elseif Groups.has_group(item, "vacuum_upgrade") then
          vacuum_range = vacuum_range + 2.0
        elseif Groups.has_group(item, "efficiency_upgrade") then
          energy_rate = energy_rate - 0.25
        elseif Groups.has_group(item, "solar_charge_upgrade") then
          solar_charge_rate = solar_charge_rate + 0.25
        elseif Groups.has_group(item, "teleportation_upgrade") then
          teleport_range = teleport_range + 32
        elseif Groups.has_group(item, "voodoo_upgrade") then
          voodoo_range = voodoo_range + 8
        end
      end
    end

    self.max_speed = max_speed
    self.jump_height = jump_height
    self.vacuum_range = vacuum_range
    self.energy_rate = energy_rate
    self.solar_charge_rate = solar_charge_rate
    self.teleport_range = teleport_range
    self.voodoo_range = voodoo_range

    self.object:set_properties({
      max_speed = max_speed,
      jump_height = jump_height,
      vacuum_range = vacuum_range,
      energy_rate = energy_rate,
      solar_charge_rate = solar_charge_rate,
      teleport_range = teleport_range,
      voodoo_range = voodoo_range,
    })
  end,

  energy = {
    get_capacity = function (self)
      local inv = self:get_inventory()
      return invbat.calc_capacity(inv, "batteries")
    end,

    receive_energy = function (self, amount)
      local inv = self:get_inventory()
      local new_energy, used = invbat.receive_energy(inv, "batteries", amount)
      mobkit.remember(self, "available_energy", new_energy)
      self:refresh_infotext()
      return used
    end,

    consume_energy = function (self, amount)
      local inv = self:get_inventory()
      local new_energy, used = invbat.consume_energy(inv, "batteries", amount)
      mobkit.remember(self, "available_energy", new_energy)
      self:refresh_infotext()
      return used
    end,
  },

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

    self:refresh_upgrades()
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

  on_rightclick = function (self, user)
    local assigns = {
      tab = 1,
      entity = self
    }

    nokore.formspec_bindings:show_formspec(
      user:get_player_name(),
      "yatm_drones:scavenger_drone",
      render_formspec(user, assigns),
      {
        state = assigns,
        on_receive_fields = get_scavenger_drone_on_receive_fields,
      }
    )
  end,

  on_punch = function (self, puncher)
    if mobkit.is_alive(self) then
      mobkit.hq_die(self)
    end
  end,

  on_death = function (self, killer)

  end,
})
