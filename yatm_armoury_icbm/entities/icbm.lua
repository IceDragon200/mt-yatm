local g_inventory_id = 0

local function create_inventory(self)
  g_inventory_id = g_inventory_id + 1
  local inventory_name = "yatm_armoury_icbm:icbm_inventory_" .. g_inventory_id

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

  inv:set_size("main", 16)

  self.inventory_name = "yatm_armoury_icbm:icbm_inventory_" .. g_inventory_id
  return inv
end

local function restore_inventory(self, dump)
  local inv = self:get_inventory()

  for list_name, dumped_list in pairs(dump.data) do
    local list = inv:get_list(list_name)
    assert(list, "expected list to exist name=" .. list_name)
    list = yatm_item_storage.InventorySerializer.deserialize_list(dumped_list, list)
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

local function get_formspec(self, user, assigns)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine")

  if self.has_inventory and self.inventory_name then
    formspec =
      formspec ..
      "label[0,0;Inventory]" ..
      "list[detached:" .. self.inventory_name .. ";main;0,0.5;8,2;]" ..
      "listring[detached:" .. self.inventory_name .. ";main]" ..
      "listring[current_player;main]"
  end

  formspec =
    formspec ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    default.get_hotbar_bg(0,4.85)

  formspec =
    formspec ..
    "button[0,3;4,1;disarm;Disarm]"

  return formspec
end

local function receive_fields(user, form_name, fields, assigns)
  if fields["disarm"] then
    assigns.entity.object:remove()
    return true, ""
  end

  return true
end

minetest.register_entity("yatm_armoury_icbm:icbm", {
  physical = true,
  collide_with_objects = true,
  --glow = 1,
  visual = "mesh",
  visual_size = {x = 10, y = 10},
  collisionbox = yatm_core.Cuboid:new(2, -4, 2, 12, 68, 12):fast_node_box(),
  selectionbox = yatm_core.Cuboid:new(1, -4, 1, 14, 68, 14):fast_node_box(),
  mesh = "yatm_icbm.obj",
  textures = {"yatm_icbm_empty_warhead.png"},

  initial_properties = {
    warhead_type = "empty",
    stage = "docked",
    has_inventory = false,
  },

  on_activate = function (self, staticdata, dtime_s)
    if staticdata ~= "" then
      local data = minetest.parse_json(staticdata)

      self.warhead_type = data.warhead_type
      self.origin_pos = data.origin_pos
      self.origin_dir = data.origin_dir
      self.target_pos = data.target_pos
      self.exit_pos = data.exit_pos
      self.stage = data.stage or "docked"

      if data.has_inventory then
        self.has_inventory = true
        restore_inventory(self, data.inventory)
      end
    end
  end,

  on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    -- prevent the destruction of the ICBM by hand
  end,

  on_rightclick = function (self, user)
    --
    if self.stage == "idle" or self.stage == "docked" then
      local assigns = { entity = self }
      local formspec = get_formspec(self, user, assigns)
      local formspec_name = "yatm_armoury_icbm:icbm"

      yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                              assigns,
                                              receive_fields)

      minetest.show_formspec(
        user:get_player_name(),
        "yatm_drones:scavenger_drone",
        formspec
      )
    end
  end,

  on_step = function (self, dtime)
    --
    if self.stage == "docked" then
      -- the icbm is currently docked

    elseif self.stage == "leaving_silo" then
      -- the icbm is currently trying to leave the silo
      -- depending on the exit direction of the silo, the icbm may need to clear up to 6 nodes before it enters cruise flight
      local velocity = yatm.vector3.new(0, 0, 0)
      yatm.vector3.add(velocity, self.origin_dir * dtime * 4)

      if vector.distance(self.exit_pos, self.object:get_pos()) <= 1 then
        -- icbm has arrived at exit location, it will now transition into the cruise state
        self.stage = "ascent"
      else
        self.object:set_velocity(velocity)
      end

    elseif self.stage == "ascent" then
      -- for now go straight up!
      -- TODO: should perform a curved ascent
      if vector.distance(self.cruise_pos, self.object:get_pos()) <= 1 then
        self.stage = "cruise"
      else
        local velocity = yatm.vector3.new(0, 0, 0)
        yatm.vector3.add(velocity, vector.direction(self.cruise_pos, self.object:get_pos()) * dtime * 8)
        self.object:set_velocity(velocity)
      end

    elseif self.stage == "cruise" then
      -- icbm is on its way to the target
      -- note that they always fly in a straight line to the target, and will detonate if they collide with something in this state.
      if vector.distance(self.target_cruise_pos, self.object:get_pos()) <= 1 then
        self.stage = "descent"
      else
        local velocity = yatm.vector3.new(0, 0, 0)
        yatm.vector3.add(velocity, vector.direction(self.target_cruise_pos, self.object:get_pos()) * dtime * 16)
        self.object:set_velocity(velocity)
      end

    elseif self.stage == "descent" then
      -- icbm has reached target x, z position and will not descent to y position
      -- depending on the warhead type, it may or may not enter the detonate state
      if vector.distance(self.target_pos, self.object:get_pos()) <= 1 then
        -- determine if it should detonate
        if self.warhead_type == "capsule" then
          self.stage = "idle"
        else
          self.stage = "detonate"
        end
      else
        local velocity = yatm.vector3.new(0, 0, 0)
        -- descent is twice as fast as cruise
        yatm.vector3.add(velocity, vector.direction(self.target_pos, self.object:get_pos()) * dtime * 32)
        self.object:set_velocity(velocity)
      end

    elseif self.stage == "detonate" then
      -- TODO: perform warhead detonation logic
      if self.warhead_type == "nuclear" then
        --
      elseif self.warhead_type == "incendiary" then
        --
      elseif self.warhead_type == "chemical" then
        --
      elseif self.warhead_type == "explosive" then
        --
      elseif self.warhead_type == "high_explosive" then
        --
      else
        -- an unrecognized warhead possibly!?
        minetest.log("error", "unexpected warhead " .. dump(self.warhead_type))
      end
      self.object:remove()

    elseif self.stage == "idle" then
      -- only used by duds or capsule types

    end
  end,

  get_staticdata = function (self)
    local data = {
      stage = self.stage,
      warhead_type = self.warhead_type,
      origin_pos = self.origin_pos,
      origin_dir = self.origin_dir,
      guide_length = self.guide_length or 0, -- what was the length of the guide rail/rings
      exit_pos = self.exit_pos,
      cruise_pos = self.cruise_pos,
      target_cruise_pos = self.target_cruise_pos,
      target_pos = self.target_pos,
      has_inventory = false,
    }

    if self.has_inventory then
      data.has_inventory = true
      data.inventory = dump_inventory(self)
    end

    return minetest.write_json(data)
  end,

  arm_icbm = function (self, params)
    self.target_pos = params.target_pos
    self.origin_pos = params.origin_pos
    self.origin_dir = params.origin_dir
    self.guide_length = params.guide_length

    self.warhead_type = params.warhead_type

    -- what position is considered the 'exit' position, where it can transition into the next stage?
    local exit_pos = yatm.vector3.new(0, 0, 0)
    yatm.vector3.add(exit_pos, self.origin_dir) -- first we add the origin's direction
    yatm.vector3.mul(exit_pos, guide_length + 6) -- next multiply that direction by the guide length + 6 (4 is the estimated length of the missle, plus 2 for additional clearance)
    yatm.vector3.add(exit_pos, self.origin_pos) -- finally add the origin position (i.e. the silo position) to obtain the exit position

    self.exit_pos = exit_pos

    self.cruise_pos = vector.new(self.exit_pos)
    self.cruise_pos.y = self.target_pos.y + 16

    self.target_cruise_pos = vector.new(self.target_pos)
    self.target_cruise_pos.y = self.cruise_pos.y
  end,

  launch_icbm = function (self)
    self.stage = "leaving_silo"
  end,
})
