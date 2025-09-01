--
-- The Aging or fermenting barrel is a fluid barrel responsible for transforming fluids
-- into other fluids normally with a catalyst item.
-- Aging recipes tend to be fairly slow to process, but work on large quantities of fluids.
--
local mod = assert(yatm_brewery)

local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local list_concat = assert(foundation.com.list_concat)
local Directions = assert(foundation.com.Directions)
local aging_registry = assert(yatm.brewing.aging_registry)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local player_service = assert(nokore.player_service)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local get_meta = assert(tetra.get_meta)
local get_node = assert(tetra.get_node)
local get_node_or_nil = assert(tetra.get_node_or_nil)

local TIMER_INTERVAL = 1.0
local BARREL_CAPACITY = 1000
local BARREL_DRAIN_BANDWIDTH = BARREL_CAPACITY
local PRIMARY_TANK_NAME = "tank"
local STAGE_TANK_NAME = "stage_tank"
local OUTPUT_TANK_NAME = "output_tank"

local nodebox = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
    {-0.5, -0.5, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox2
    {-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox3
    {-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox4
    {0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
  }
}

--- Prepares all output items and fluids as well as consuming the ingredients
--- for the recipe.
local function stage_recipe_output(pos, meta, recipe)
  if not recipe then
    return true
  end

  local input = recipe.input
  local fluid_input = input.fluid
  local item_input = input.item
  local output = recipe.output
  local fluid_output = output.fluid
  local item_output = output.item

  local fluid_stack
  if fluid_output then
    fluid_stack = fluid_output:make_fluid_stack()
  end

  if fluid_stack then
    FluidMeta.set_fluid(meta, STAGE_TANK_NAME, fluid_stack, true)
  else
    FluidMeta.set_fluid(meta, STAGE_TANK_NAME, FluidStack.new_empty(), true)
  end
  fluid_stack = nil

  local item_stack
  if item_output then
    item_stack = item_output:make_item_stack()
  end

  local inv = meta:get_inventory()
  if item_stack then
    if inv:get_size("stage_item_slot") < 1 then
      inv:set_size("stage_item_slot", 1)
    end
    inv:set_stack("stage_item_slot", 1, item_stack)
  else
    inv:set_stack("stage_item_slot", 1, ItemStack())
  end
  item_stack = nil

  if fluid_input then
    fluid_stack = fluid_input:make_fluid_stack()
  end

  if fluid_stack then
    -- we are going to trust that FluidMeta will correctly decrement the amount
    FluidMeta.decrease_fluid(
      meta,
      STAGE_TANK_NAME,
      fluid_stack,
      BARREL_CAPACITY,
      true
    )
  end

  if item_input then
    item_stack = item_input:make_item_stack()
  end

  if item_stack then
    inv:remove_item("culture_slot", item_stack)
  end

  return true
end

local WORK_STATE_NEW = 0
local WORK_STATE_SETUP = 1
local WORK_STATE_RUN = 2
local WORK_STATE_STAGE = 3
local WORK_STATE_COMMIT = 4
local WORK_STATE_FINALIZE = 5

--- @private_spec on_timer(Vector3, dt: Float): Boolean
local function on_timer(pos, dt)
  local node = get_node_or_nil(pos)
  local nodedef = core.registered_nodes[node.name]
  local meta = get_meta(pos)
  local inv = meta:get_inventory()

  local work_state = meta:get_int("work_state")
  local should_repeat = false

  ::init:: do
    if work_state == WORK_STATE_NEW then
      goto state_new
    elseif work_state == WORK_STATE_SETUP then
      goto state_setup
    elseif work_state == WORK_STATE_RUN then
      goto state_run
    elseif work_state == WORK_STATE_STAGE then
      goto state_stage
    elseif work_state == WORK_STATE_COMMIT then
      goto state_commit
    elseif work_state == WORK_STATE_FINALIZE then
      goto state_finalize
    else
      work_state = WORK_STATE_NEW
      goto state_new
    end
  end

  ::state_new:: do
    local fluid_stack = FluidMeta.get_fluid_stack(meta, PRIMARY_TANK_NAME)
    local item_stack = inv:get_stack("culture_slot", 1)

    local input = {
      fluid = fluid_stack,
      item = item_stack
    }

    -- reset work time since the recipe would change
    meta:set_float("work_time", 0)
    local recipe = aging_registry:get_aging_recipe_by_inputs_indifferent(input)
    if recipe then
      meta:set_string("current_recipe_name", recipe.name)
      work_state = WORK_STATE_SETUP
      goto state_setup
    else
      goto exit_without_repeat
    end
  end

  ::state_setup:: do
    local current_recipe_name = meta:get("current_recipe_name")
    if current_recipe_name then
      local recipe = aging_registry:get_aging_recipe_by_name(current_recipe_name)
      meta:set_float("work_time", 0)
      meta:set_float("work_time_max", recipe.duration)
      work_state = WORK_STATE_RUN
      goto state_run
    else
      work_state = WORK_STATE_NEW
      goto state_new
    end
  end

  ::state_run:: do
    local work_time = meta:get_float("work_time")
    local work_time_max = meta:get_float("work_time_max")
    work_time = work_time + dt
    if work_time >= work_time_max then
      work_state = WORK_STATE_STAGE
      goto state_stage
    else
      meta:set_float("work_time", work_time)
      goto exit_with_repeat
    end
  end

  ::state_stage:: do
    local fluid_stack = FluidMeta.get_fluid_stack(meta, PRIMARY_TANK_NAME)
    local item_stack = inv:get_stack("culture_slot", 1)

    local input = {
      fluid = fluid_stack,
      item = item_stack
    }
    -- We are verifying that the recipe processed was indeed the same
    -- as the ingredients would result in.
    local recipe = aging_registry:get_aging_recipe_by_inputs_indifferent(input)

    if recipe then
      -- In case the recipe name changed, set the new one, since the inputs are
      -- about to be removed and we can no longer reverse lookup the recipe beyond
      -- this point
      meta:set_string("current_recipe_name", recipe.name)
      -- We have a valid recipe, yes the recipe could be different from
      -- what was processed, but we're already finished running, don't annoy
      -- the user any further by resetting their progress.
      if stage_recipe_output(pos, meta, recipe) then
        work_state = WORK_STATE_COMMIT
        goto state_commit
      else
        -- retry again later
        goto exit_with_repeat
      end
    else
      --- We do not have a valid recipe, abort and start over
      work_state = WORK_STATE_NEW
      goto state_new
    end
  end

  ::state_commit:: do
    -- it is time to replace the
    local need_retry = false
    local item_stack = inv:get_stack("stage_item_slot", 1)
    local leftover = inv:add_item("output_item_slot", item_stack)
    inv:set_stack("stage_item_slot", 1, leftover)
    if not leftover:is_empty() then
      need_retry = true
    end

    local fluid_stack = FluidMeta.get_fluid_stack(meta, STAGE_TANK_NAME)
    if fluid_stack then
      local transferred_fluid =
        FluidExchange.transfer_from_meta_to_meta(
          meta,
          {
            tank_name = STAGE_TANK_NAME,
            capacity = BARREL_CAPACITY,
            bandwidth = BARREL_CAPACITY,
          },
          fluid_stack,
          meta,
          {
            tank_name = OUTPUT_TANK_NAME,
            capacity = BARREL_CAPACITY,
            bandwidth = BARREL_CAPACITY,
          },
          true
        )

      if transferred_fluid.amount ~= fluid_stack.amount then
        -- retry again later
        need_retry = true
      end
    end

    if need_retry then
      -- retry again later
      goto exit_with_repeat
    else
      work_state = WORK_STATE_FINALIZE
      goto state_finalize
    end
  end

  ::state_finalize::
    work_state = WORK_STATE_NEW
    goto state_new

  ::exit_with_repeat::
    should_repeat = true
    goto flush

  ::exit_without_repeat::
    should_repeat = false
    goto flush

  ::flush:: do
    meta:set_int("work_state", work_state)
    nodedef.refresh_infotext(pos, node)
    local itci_stack = inv:get_stack("input_tank_container_in", 1)
    local itco_stack = inv:get_stack("input_tank_container_out", 1)
    local otci_stack = inv:get_stack("output_tank_container_in", 1)
    local otco_stack = inv:get_stack("output_tank_container_out", 1)

    local wildcard_fluid = FluidStack.new_wildcard(1000 * dt)
    if not itci_stack:is_empty() then
      FluidExchange.transfer_from_container_to_meta(
        itci_stack,
        wildcard_fluid,
        meta,
        {
          tank_name = PRIMARY_TANK_NAME,
          capacity = BARREL_CAPACITY,
          bandwidth = BARREL_CAPACITY,
        },
        true
      )
      inv:set_stack("input_tank_container_in", 1, itci_stack)
    end

    if not itco_stack:is_empty() then
      FluidExchange.transfer_from_meta_to_container(
        meta,
        {
          tank_name = PRIMARY_TANK_NAME,
          capacity = BARREL_CAPACITY,
          bandwidth = BARREL_CAPACITY,
        },
        wildcard_fluid,
        itco_stack,
        true
      )
      inv:set_stack("input_tank_container_out", 1, itco_stack)
    end

    if not otci_stack:is_empty() then
      FluidExchange.transfer_from_container_to_meta(
        otci_stack,
        wildcard_fluid,
        meta,
        {
          tank_name = OUTPUT_TANK_NAME,
          capacity = BARREL_CAPACITY,
          bandwidth = BARREL_CAPACITY,
        },
        true
      )
      inv:set_stack("output_tank_container_in", 1, otci_stack)
    end

    if not otco_stack:is_empty() then
      FluidExchange.transfer_from_meta_to_container(
        meta,
        {
          tank_name = OUTPUT_TANK_NAME,
          capacity = BARREL_CAPACITY,
          bandwidth = BARREL_CAPACITY,
        },
        wildcard_fluid,
        otco_stack,
        true
      )
      inv:set_stack("output_tank_container_out", 1, otco_stack)
    end
  end

  ::exit::
    return should_repeat
end

local function on_construct(pos)
  local meta = get_meta(pos)

  local inv = meta:get_inventory()
  -- accepts one culture or catalyst item
  inv:set_size("culture_slot", 1)
  -- this where the output goes before it gets placed into the actual output slot
  inv:set_size("stage_item_slot", 1)
  -- the actual output item slot
  inv:set_size("output_item_slot", 1)

  inv:set_size("input_tank_container_in", 1)
  inv:set_size("input_tank_container_out", 1)
  inv:set_size("output_tank_container_in", 1)
  inv:set_size("output_tank_container_out", 1)

  local node = get_node(pos)
  yatm.queue_refresh_infotext(pos, node)

  meta:set_int("version", 1)
end

local function on_destruct(pos)
  -- Barrel exit stage left
end

local function refresh_infotext(pos, node)
  local meta = get_meta(pos)
  local nodedef = core.registered_nodes[node.name]
  local fluid_stack = FluidTanks.get_fluid(pos, Directions.D_NONE)

  local infotext =
    nodedef.short_description .. "\n"

  if FluidStack.is_empty(fluid_stack) then
    infotext =
      infotext
      .. "Empty"
  else
    infotext =
      infotext
      .. fluid_stack.name
      .. " "
      .. fluid_stack.amount
      .. " / "
      .. nodedef.fluid_interface:get_capacity(pos, 0)
  end

  meta:set_string("infotext", infotext)
end

local fluid_interface = FluidInterface.new_simple(PRIMARY_TANK_NAME, BARREL_CAPACITY)
do
  function fluid_interface:on_fluid_changed(pos, dir, stack)
    local node = get_node(pos)
    local nodedef = core.registered_nodes[node.name]
    maybe_start_node_timer(pos, TIMER_INTERVAL)
  end
end

local item_interface = ItemInterface.new_simple("culture_slot")

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "culture_slot" or to_list == "culture_slot" then
    maybe_start_node_timer(pos, TIMER_INTERVAL)
  end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "input_tank_container_in" then

  elseif listname == "input_tank_container_out" then

  elseif listname == "output_tank_container_in" then

  elseif listname == "output_tank_container_out" then

  elseif listname == "culture_slot" then
    --
  end
  -- something changed, let's start the timer
  maybe_start_node_timer(pos, TIMER_INTERVAL)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "culture_slot" then
    maybe_start_node_timer(pos, TIMER_INTERVAL)
  end
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "wood" }, function (loc, rect)
    if loc == "main_body" then
      local input_fluid_stack = FluidMeta.get_fluid_stack(meta, PRIMARY_TANK_NAME)
      local output_fluid_stack = FluidMeta.get_fluid_stack(meta, OUTPUT_TANK_NAME)

      return ""
        .. fspec.list(
          node_inv_name,
          "input_tank_container_in",
          rect.x,
          rect.y,
          1,
          1
        )
        .. yatm_fspec.render_item_border(
          rect.x, rect.y, 1, 1,
          "yatm_item_border_bucket.up.png", yatm.config.insert_color
        )
        .. yatm_fspec.render_fluid_stack(
          rect.x,
          rect.y + cio(1),
          1,
          cis(2),
          input_fluid_stack,
          BARREL_CAPACITY
        )
        .. fspec.list(
          node_inv_name,
          "culture_slot",
          rect.x + cio(1),
          rect.y + cio(1),
          1,
          1
        )
        .. fspec.list(
          node_inv_name,
          "input_tank_container_out",
          rect.x,
          rect.y + cio(3),
          1,
          1
        )
        .. yatm_fspec.render_item_border(
          rect.x, rect.y + cio(3), 1, 1,
          "yatm_item_border_bucket.down.png", yatm.config.extract_color
        )
        -- Output
        .. fspec.list(
          node_inv_name,
          "output_tank_container_in",
          rect.x + cio(3),
          rect.y,
          1,
          1
        )
        .. yatm_fspec.render_item_border(
          rect.x + cio(3), rect.y, 1, 1,
          "yatm_item_border_bucket.up.png", yatm.config.insert_color
        )
        .. yatm_fspec.render_fluid_stack(
          rect.x + cio(3),
          rect.y + cio(1),
          1,
          cis(2),
          output_fluid_stack,
          BARREL_CAPACITY
        )
        .. fspec.list(
          node_inv_name,
          "output_item_slot",
          rect.x + cio(4),
          rect.y + cio(1),
          1,
          1
        )
        .. fspec.list(
          node_inv_name,
          "output_tank_container_out",
          rect.x + cio(3),
          rect.y + cio(3),
          1,
          1
        )
        .. yatm_fspec.render_item_border(
          rect.x + cio(3), rect.y + cio(3), 1, 1,
          "yatm_item_border_bucket.down.png", yatm.config.extract_color
        )
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_brewery:aging_barrel:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

-- Normally the side and lid of the barrel is dyed, this is mostly for identification.
-- By default only the white and default (i.e. no dye) variant is available.
for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  mod:register_node("aging_barrel_wood_" .. color_basename, {
    basename = mod:make_name("aging_barrel_wood"),
    base_description = mod.S("Aging Barrel (Wood)"),

    description = mod.S("Aging Barrel (Wood / " .. color_name .. ")"),
    short_description = mod.S("Aging Barrel (Wood / " .. color_name .. ")"),

    groups = {
      cracky = nokore.dig_class("wme"),
      --
      aging_barrel = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },

    sounds = yatm.node_sounds:build("wood"),

    tiles = {
      "yatm_barrel_wood_brewing_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = nodebox,

    dye_color = color_basename,

    on_rightclick = on_rightclick,

    on_construct = on_construct,
    on_destruct = on_destruct,
    on_timer = on_timer,

    fluid_interface = fluid_interface,
    item_interface = item_interface,

    on_metadata_inventory_move = on_metadata_inventory_move,
    on_metadata_inventory_put = on_metadata_inventory_put,
    on_metadata_inventory_take = on_metadata_inventory_take,

    refresh_infotext = refresh_infotext,
  })
end
