--
-- Utility functions for manipulating fluid containers
--
local FluidMeta = assert(yatm_fluids.FluidMeta)
local FluidStack = assert(yatm_fluids.FluidStack)
local itemstack_copy = assert(foundation.com.itemstack_copy)

--- @namespace yatm_fluids.FluidContainers
local FluidContainers = {}

--- @type FluidReplacement: {
---   name: String,
---   threshold: Integer,
--- }

---
--- `name` used by static to denote whch fluid by name the container has
--- `volume` is used by static to determine how much fluid is actually present.
--- `capacity` is used by dynamic and static to tell how much fluid the container could hold.
---   In the case of static, if volume is 0, this is used by filling logic.
--- `bandwidth` is the fluid flow rate from and to the container, it is a per-second value
--- `key` is used by dynamic to denote the meta basename used to store the fluid.
---
--- For member functions, see FluidMeta for reference, as the functions on the FluidContainer
--- follow a similar structure, outside of the first argument being the fluid container itself
--- @type FluidContainerDefinition: {
---   type: "dynamic" | "static",
---   fluid_name: String,
---   volume: Integer,
---   capacity: Integer,
---   bandwidth: Integer,
---   key: String,
---
---   fluid_table: { [fluid_name: String]: (new_item_name: String | FluidReplacement[]) },
---
---   is_empty: (self, ItemStack) => Boolean,
---   get_fluid_stack: (self, ItemStack) => FluidStack | nil,
---   set_fluid_stack: (self, ItemStack, FluidStack, commit: Boolean) => (Integer, Integer),
---   decrease_fluid: (self, ItemStack, FluidStack, commit: Boolean) => (Integer, Integer),
---   increase_fluid: (self, ItemStack, FluidStack, commit: Boolean) => (Integer, Integer),
---   drain_fluid: (self, ItemStack, FluidStack, commit: Boolean) => (Integer, Integer),
---   fill_fluid: (self, ItemStack, FluidStack, commit: Boolean) => (Integer, Integer),
--- }

local FLUID_CONTAINER_TYPES = {
  dynamic = true,
  static = true,
}

--- Determines if the given item_stack is a valid fluid container.
---
--- @spec is_fluid_container(item_stack: ItemStack): Boolean
function FluidContainers.is_fluid_container(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def and def.fluid_container then
      return FLUID_CONTAINER_TYPES[def.fluid_container.type] or false
    end
  end

  return false
end

--- Determines if the fluid container is empty, or considered empty.
---
--- @spec is_empty(item_stack: ItemStack): Boolean
function FluidContainers.is_empty(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local meta = item_stack:get_meta()
      local fluid_container = def.fluid_container

      if fluid_container then
        if fluid_container.is_empty == true then
          return true
        elseif type(fluid_container.is_empty) == "function" then
          return fluid_container:is_empty(item_stack)
        elseif fluid_container.type == "dynamic" then
          return FluidMeta.is_empty(
            meta,
            fluid_container.key
          )
        elseif fluid_container.type == "static" then
          return fluid_container.volume == nil or fluid_container.volume == 0
        end
      end
    end
  end

  return true
end

--- @spec get_fluid_stack(item_stack: ItemStack): FluidStack | nil
function FluidContainers.get_fluid_stack(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.get_fluid_stack) == "function" then
          return fluid_container:get_fluid_stack(item_stack)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.get_fluid_stack(
            meta,
            fluid_container.key
          )
        else
          return FluidStack.new(
            fluid_container.fluid_name,
            fluid_container.volume
          )
        end
      end
    end
  end

  return nil
end

--- Attempts to set a new fluid stack on the given container.
--- If the container defines a set_fluid function that will be used first.
--- If the container is dynamic it will use FluidMeta.set_fluid/4 instead.
--- Otherwise a static container will use its fluid_table to lookup matching fluid names, the
--- amount is determined by the capacity by default, or can be override by a capacity in the
--- fluid_table's value.
---
--- @mutative item_stack
--- @spec set_fluid_stack(
---   item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (FluidStack | nil, FluidStack)
function FluidContainers.set_fluid_stack(item_stack, fluid_stack, commit)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.set_fluid_stack) == "function" then
          return fluid_container:set_fluid_stack(item_stack, fluid_stack, commit)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.set_fluid_stack(
            meta,
            fluid_container.key,
            fluid_stack,
            commit
          )
        elseif fluid_container.type == "static" then
          if fluid_container.fluid_table then
            local name = ""
            local amount = 0
            if fluid_stack and fluid_stack.amount > 0 then
              name = fluid_stack.name or ""
              amount = fluid_stack.amount
            end
            local entry = fluid_container.fluid_table[name]
            local t = type(entry)
            local target_item = item_stack
            if not commit then
              target_item = itemstack_copy(item_stack)
            end
            local new_name

            if t == "string" then
              -- capacity
              new_name = entry
            elseif t == "table" then
              local replacement
              for _, item in ipairs(entry) do
                if item.threshold <= amount then
                  replacement = item
                else
                  break
                end
              end

              if replacement then
                new_name = replacement.name
              end
            end

            if new_name then
              target_item:set_name(new_name)
              local fs = FluidContainers.get_fluid_stack(target_item)
              return fs, fs
            end
          end
        end
      end
    end
  end

  return nil, fluid_stack
end

--- @spec decrease_fluid(
---   item_stack: ItemStack,
---   drain_stack: FluidStack,
---   commit: Boolean
--- ): (drained_stack: FluidStack | nil, requested_drain: FluidStack)
function FluidContainers.decrease_fluid(item_stack, drain_stack, commit)
  if item_stack then
    local def = item_stack:get_definition()

    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.decrease_fluid) == "function" then
          return fluid_container:decrease_fluid(item_stack, drain_stack, commit)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.decrease_fluid(
            meta,
            fluid_container.key,
            drain_stack,
            fluid_container.capacity,
            commit
          )
        elseif fluid_container.type == "static" then
          local existing = FluidContainers.get_fluid_stack(item_stack)
          local new_stack = existing - drain_stack
          local a, b = FluidContainers.set_fluid_stack(item_stack, new_stack, commit)
          local diff = existing - a
          return diff, b
        end
      end
    end
  end

  return nil, fluid_stack
end

--- @spec increase_fluid(
---   item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (FluidStack | nil, FluidStack)
function FluidContainers.increase_fluid(item_stack, fluid_stack, commit)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.increase_fluid) == "function" then
          return fluid_container:increase_fluid(item_stack, fluid_stack, commit)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.increase_fluid(
            meta,
            fluid_container.key,
            fluid_stack,
            fluid_container.capacity,
            commit
          )
        elseif fluid_container.type == "static" then
          local existing = FluidContainers.get_fluid_stack(item_stack)
          local new_stack = existing + fluid_stack
          local a, b = FluidContainers.set_fluid_stack(item_stack, new_stack, commit)
          local diff = a - existing
          return diff, b
        end
      end
    end
  end

  return nil, fluid_stack
end

--- @spec drain_fluid(
---   item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (FluidStack | nil, FluidStack)
function FluidContainers.drain_fluid(item_stack, fluid_stack, commit)
  if item_stack then
    local def = item_stack:get_definition()

    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.drain_fluid) == "function" then
          return fluid_container:drain_fluid(item_stack, fluid_stack, commit)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.drain_fluid(
            meta,
            fluid_container.key,
            fluid_stack,
            fluid_container.bandwidth or fluid_container.capacity,
            fluid_container.capacity,
            commit
          )
        elseif fluid_container.type == "static" then
          return FluidContainers.decrease_fluid(item_stack, fluid_stack, commit)
        end
      end
    end
  end

  return nil, fluid_stack
end

--- @spec fill_fluid(
---   item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (FluidStack | nil, FluidStack)
function FluidContainers.fill_fluid(item_stack, fluid_stack, commit)
  if item_stack then
    local def = item_stack:get_definition()

    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.fill_fluid) == "function" then
          return fluid_container:fill_fluid(item_stack, fluid_stack, commit)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.fill_fluid(
            meta,
            fluid_container.key,
            fluid_stack,
            fluid_container.bandwidth or fluid_container.capacity,
            fluid_container.capacity,
            commit
          )
        elseif fluid_container.type == "static" then
          return FluidContainers.increase_fluid(item_stack, fluid_stack, commit)
        end
      end
    end
  end

  return nil, fluid_stack
end

--- @spec inspect(item_stack: ItemStack): String | nil
function FluidContainers.inspect(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.inspect) == "function" then
          return fluid_container:inspect(item_stack)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.inspect(meta, fluid_container.key)
        elseif fluid_container.type == "static" then
          local fluid_stack = FluidContainers.get_fluid_stack(item_stack)
          return FluidStack.to_string(fluid_stack)
        end
      end
    end
  end

  return nil
end

--- @spec to_infotext(item_stack: ItemStack): String | nil
function FluidContainers.to_infotext(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      local fluid_container = def.fluid_container

      if fluid_container then
        if type(fluid_container.inspect) == "function" then
          return fluid_container:inspect(item_stack)
        elseif fluid_container.type == "dynamic" then
          local meta = item_stack:get_meta()
          return FluidMeta.to_infotext(
            meta,
            fluid_container.key,
            fluid_container.capacity
          )
        elseif fluid_container.type == "static" then
          local fluid_stack = FluidContainers.get_fluid_stack(item_stack)
          return FluidStack.pretty_format(
            fluid_stack,
            fluid_container.capacity or fluid_container.volume
          )
        end
      end
    end
  end

  return nil
end

yatm_fluids.FluidContainers = FluidContainers
