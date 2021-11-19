-- @namespace yatm_armoury
local Groups = assert(foundation.com.Groups)
local sounds = assert(yatm.sounds)

local function play_sound(def)
  return sounds:play(def.name, def.params)
end

--
-- Determines if the given stack is a form of ammunition
--
-- @spec is_stack_cartridge(ItemStack): boolean
function yatm_armoury.is_stack_cartridge(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return Groups.has_group(def, "cartridge")
    end
  end
  return false
end

--
-- Determines if the given stack is a form of magazine
--
-- @spec is_stack_magazine(ItemStack): boolean
function yatm_armoury.is_stack_magazine(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return Groups.has_group(def, "magazine")
    end
  end
  return false
end

-- @spec is_stack_firearm(ItemStack): Boolean
function yatm_armoury.is_stack_firearm(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return Groups.has_group(def, "firearm")
    end
  end
  return false
end

-- @spec get_item_stack_calibre(ItemStack): String
function yatm_armoury.get_item_stack_calibre(item_stack)
  local itemdef = item_stack:get_definition()
  if yatm_armoury.is_stack_firearm(item_stack) then
    return itemdef.firearm.calibre
  elseif yatm_armoury.is_stack_firearm(item_stack) then
    return itemdef.magazine.calibre
  elseif yatm_armoury.is_stack_cartridge(item_stack) then
    return itemdef.cartridge.calibre
  end
  return nil
end

function yatm_armoury.is_same_calibre_item_stacks(a, b)
  local a_calibre = yatm_armoury.get_item_stack_calibre(a)
  local b_calibre = yatm_armoury.get_item_stack_calibre(b)

  if a_calibre and b_calibre then
    return a_calibre == b_calibre
  else
    return false
  end
end

function yatm_armoury.is_magazine_empty(magazine_stack)
  local magazine_meta = magazine_stack:get_meta()
  return (magazine_meta:get_int("bullet_count") or 0) == 0
end

function yatm_armoury.is_magazine_full(magazine_stack)
  local magazine_itemdef = magazine_stack:get_definition()
  local magazine_meta = magazine_stack:get_meta()
  return (magazine_meta:get_int("bullet_count") or 0) >= magazine_itemdef.magazine_size
end

function yatm_armoury.get_magazine_size(magazine_stack)
  local magazine_itemdef = magazine_stack:get_definition()

  return magazine_itemdef.magazine.size
end

function yatm_armoury.get_magazine_cartridge_count(magazine_stack)
  local meta = magazine_stack:get_meta()
  return meta:get_int("cartridge_count")
end

function yatm_armoury.get_firearm_magazine_size(firearm_stack)
  local meta = firearm_stack:get_meta()
  return meta:get_int("magazine_size")
end

function yatm_armoury.get_firearm_cartridge_count(firearm_stack)
  local meta = magazine_stack:get_meta()
  return meta:get_int("cartridge_count")
end

function yatm_armoury.get_firearm_cartridge_at(firearm_stack, index)
  local meta = magazine_stack:get_meta()
  return string.sub(meta:get_string("cartridge_string"), index, index)
end

--
-- Places the given cartridge/bullet/ammunition into a magazine
--
-- @spec add_cartridges_to_magazine(cartridge_stack: ItemStack, magazine_stack: ItemStack):
--   (leftover_bullets: ItemStack, new_magazine: ItemStack)
function yatm_armoury.add_cartridges_to_magazine(cartridge_stack, magazine_stack)
  -- need a cartridge and magazine respectvely
  if yatm_armoury.is_stack_cartridge(cartridge_stack) and yatm_armoury.is_stack_magazine(magazine_stack) then
    -- need to be the same calibre
    if yatm_armoury.is_same_calibre_item_stacks(magazine_stack, cartridge_stack) then
      -- and the magazine needs to have space
      if not yatm_armoury.is_magazine_full(magazine_stack) then
        local cartridge_itemdef = cartridge_stack:get_definition()
        local magazine_itemdef = magazine_stack:get_definition()

        local magazine_meta = magazine_stack:get_meta()

        -- these are how many cartridges are currently in the magazine
        local cartridge_count = magazine_meta:get_int("cartridge_count")
        -- this is a string representing the cartridge order
        local cartridge_string = magazine_meta:get_string("cartridge_string")
        -- this is the maximum size allowed for the magazine
        local magazine_size = magazine_itemdef.magazine_size

        local remaining_space = magazine_size - cartridge_count
        if remaining_space > 0 then
          local cartridges_to_take = math.min(cartridge_stack:get_count(), remaining_space)

          if cartridges_to_take > 0 then
            cartridge_stack:take_item(cartridges_to_take)

            for i = 1,cartridges_to_take do
              -- the ammo_code is a single char that will be placed into the cartridge_string
              -- notice it's prefixed to the string, this is because all magazines are FIFO
              cartridge_string = cartridge_itemdef.ammo_code .. cartridge_string
            end
            magazine_meta:set_int("cartridge_count", cartridge_count + cartridges_to_take)
            magazine_meta:set_string("cartridge_string", bullet_string)
          end
        end
      end
    end
  end
  return cartridge_stack, magazine_stack
end

function yatm_armoury.calculate_magazine_wear(magazine_stack)
  local size = yatm_armoury.get_magazine_size(magazine_stack)
  local count = yatm_armoury.get_magazine_cartridge_count(magazine_stack)

  local wear = 0
  if size > 0 then
    wear = math.floor(count * 0xFFFE / size)
  end
  return wear
end

function yatm_armoury.refresh_magazine_wear(magazine_stack)
  local wear = yatm_armoury.calculate_magazine_wear(magazine_stack)
  magazine_stack:set_wear(wear)
  return magazine_stack
end

function yatm_armoury.calculate_firearm_wear(firearm_stack)
  local meta = firearm_stack:get_meta()

  local size = yatm_armoury.get_firearm_magazine_size(firearm_stack)
  local count = yatm_armoury.get_firearm_cartridge_count(firearm_stack)

  local wear = 0
  if size > 0 then
    wear = math.floor(count * 0xFFFE / size)
  end
  return wear
end

function yatm_armoury.refresh_firearm_wear(firearm_stack)
  local wear = yatm_armoury.calculate_firearm_wear(firearm_stack)

  firearm_stack:set_wear(wear)
  return firearm_stack
end

function yatm_armoury.install_magazine(magazine_stack, firearm_stack)
  local firearm_itemdef = firearm_stack:get_definition()

  if yatm_armoury.is_stack_firearm(firearm_stack) then
    if firearm_itemdef.firearm.feed_system then
      -- if the firearm has a feed system defined, then it's assumed to already
      -- have a magazine installed, it has to be removed first.
      return false, firearm_stack
    end

    local magazine_itemdef = magazine_stack:get_definition()
    if yatm_armoury.is_stack_magazine(firearm_stack) then
      local name = firearm_itemdef.firearm.allowed_feed_systems[magazine_itemdef.magazine.type]
      if name then
        -- feed system is supported by the firearm

        local magazine_meta = magazine_stack:get_meta()
        -- create new firearm itemstack
        local new_firearm_stack = ItemStack({ name = name, count = 1 })
        local firearm_meta = new_firearm_stack:get_meta()
        -- store name of original magazine
        firearm_meta:set_string("magazine_name", magazine_stack:get_name())
        firearm_meta:set_int("magazine_size", yatm_armoury.get_magazine_size(magazine_stack))
        -- copy the cartridge_count -- how many cartridges are present in the magazine
        firearm_meta:set_int("cartridge_count", magazine_meta:get_int("cartridge_count"))
        -- copy the cartridge_string - this holds all the cartridge codes in their correct order
        firearm_meta:set_string("cartridge_string", magazine_meta:get_string("cartridge_string"))
        -- initialize the cartridge index - this represents what cartridge should be fired next
        firearm_meta:set_string("cartridge_index", 1)
        return true, new_firearm_stack
      end
    end
  end

  return false, firearm_stack
end

function yatm_armoury.uninstall_magazine(firearm_stack)
  local firearm_itemdef = firearm_stack:get_definition()

  if yatm_armoury.is_stack_firearm(firearm_stack) then
    if firearm_itemdef.firearm.feed_system then
      local firearm_meta = firearm_stack:get_meta()

      local magazine_name = firearm_meta:get_string("magazine_name")
      local cartridge_count = firearm_meta:get_int("cartridge_count")
      local cartridge_string = firearm_meta:get_string("cartridge_string")
      local cartridge_index = firearm_meta:get_string("cartridge_index")

      local new_cartridge_count = math.max(cartridge_count - cartridge_index - 1, 0)
      local new_cartridge_string = string.sub(cartridge_string, cartridge_index)

      local magazine_stack = ItemStack({ name = magazine_name, count = 1 })
      local magazine_meta = magazine_stack:get_meta()
      magazine_meta:set_string("cartridge_count", new_cartridge_count)
      magazine_meta:set_string("cartridge_string", new_cartridge_string)

      local name = firearm_itemdef.firearm.allowed_feed_systems["ul"]
      local new_firearm_stack = ItemStack({ name = name, count = 1 })

      return true, new_firearm_stack, magazine_stack
    end
  end

  return false, firearm_stack, nil
end

--
-- Handles all the ballistics for an item.
-- Depending on it's ballistics definition
--
function yatm_armoury.handle_ballistics(item_stack, player, pointed_thing)
  local itemdef = item_stack:get_definition()

  if itemdef.ballistics then
    if itemdef.ballistics.path == "linear" then
      local can_fire = true
      if type(itemdef.ballistics.can_fire) == "function" then
        can_fire = itemdef.ballistics:can_fire(item_stack, player, pointed_thing)
      end

      if can_fire then
        if itemdef.ballistics.pre_fire then
          item_stack = itemdef.ballistics:pre_fire(item_stack, player, pointed_thing)
        end
        item_stack = itemdef.ballistics:fire(item_stack, player, pointed_thing)
        if itemdef.ballistics.post_fire then
          item_stack = itemdef.ballistics:post_fire(item_stack, player, pointed_thing)
        end
      end
      return item_stack
    end
  end
  return item_stack
end

function yatm_armoury.on_use_firearm(item_stack, player, pointed_thing)
  local itemdef = item_stack:get_definition()

  play_sound(itemdef.ballistics.sounds.fire)

  yatm_armoury.handle_bullet_ballistics("S", item_stack, player, pointed_thing)
end

local function player_on_projectile_hit(player, hit_data)
  --
end

local function entity_on_projectile_hit(entity, hit_data)
  if entity:is_player() then
    player_on_projectile_hit(entity, hit_data)
  else
    local lua_entity = entity:get_luaentity()

    if lua_entity then
      if lua_entity.on_projectile_hit then
        lua_entity.on_projectile_hit(entity, hit_data)
      end
    end
  end
end

local function node_on_projectile_hit(pos, node, hit_data)
  local nodedef = minetest.registered_nodes[node.name]
  print("Projectile Hit", node.name, dump(pos))
  if nodedef.on_projectile_hit then
    nodedef.on_projectile_hit(pos, node, hit_data)
  else
    -- default to stopping on node hit
    hit_data.stop = true
  end
end

function yatm_armoury.handle_bullet_ballistics(ammunition_code, item_stack, player, _pointed_thing)
  local calibre = yatm_armoury.get_item_stack_calibre(item_stack)

  local ammunition_class = yatm_armoury:get_ammunition_class_by_code(ammunition_code)
  local calibre_class = yatm_armoury:get_calibre_class(calibre)

  local look_dir = player:get_look_dir()
  local effective_range = vector.multiply(look_dir, calibre_class.range)
  local origin_min = vector.add(look_dir, { x = 0, y = 1, z = 0 })
  local origin_pos = vector.add(player:get_pos(), origin_min)
  local target_pos = vector.add(origin_pos, effective_range)
  local include_objects = true
  local include_liquids = false
  local raycast = minetest.raycast(origin_pos,
                                   target_pos,
                                   include_objects,
                                   include_liquids)

  local hit_data = {
    kind = "bullet",
    shooter = player,
    origin = origin_pos,
    target = target_pos,
    pointed_thing = pointed_thing,
    stop = false,
    data = {
      ammunition = ammunition_class,
    }
  }

  for pointed_thing in raycast do
    print("Pointed At", pointed_thing.type, dump(pointed_thing))

    if pointed_thing.type == "object" then
      entity_on_projectile_hit(pointed_thing.ref, hit_data)
    elseif pointed_thing.type == "node" then
      local pos = pointed_thing.under
      local node = minetest.get_node_or_nil(pos)

      if node then
        node_on_projectile_hit(pos, node, hit_data)
      end
    end

    if hit_data.stop then
      break
    end
  end

  return item_stack
end

function yatm_armoury.pop_cartridge(item_stack)
  local meta = item_stack:get_meta()

  local cartridge_index = meta:get_int("cartridge_index")
  local ammunition_code = yatm_armoury.get_firearm_cartridge_at(item_stack, cartridge_index)

  if ammunition_code and ammunition_code ~= "" then
    meta:set_int("cartridge_index", cartridge_index + 1)
  end

  return ammunition_code, item_stack
end

function yatm_armoury.firearm_action(item_stack, player, pointed_thing)
  local code, item_stack = yatm_armoury.pop_cartridge(item_stack)

  if code then
    return yatm_armoury.handle_bullet_ballistics(code, item_stack, player, pointed_thing)
  else
    return item_stack
  end
end
