local Groups = assert(foundation.com.Groups)

local RollingRegistry = foundation.com.Class:extends("RollingRegistry")
local ic = RollingRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)
end

function ic:find_roller_recipe(item_stack)
  local itemdef = item_stack:get_definition()
  if Groups.has_group(itemdef, "ingot") then
    -- ingot recipe
    if item_stack:get_count() >= 2 then
      local result = ItemStack({
        name = "yatm_core:plate_" .. assert(itemdef.material_name),
        count = 1,
      })
      assert(result:is_known())
      return {
        required_count = 2,
        duration = 0.25, -- 1/4 second to form a plate
        result = result,
      }
    end
  end
  return nil, "no matching recipe"
end

yatm_machines_api.RollingRegistry = RollingRegistry
