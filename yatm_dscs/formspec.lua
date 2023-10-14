local hash_node_position = assert(minetest.hash_node_position)
local fspec = assert(foundation.com.formspec.api)
local metaref_string_list_to_table = assert(foundation.com.metaref_string_list_to_table)

local string_to_pos = assert(minetest.string_to_pos)

local get_inventory_controller_def = assert(yatm.dscs.get_inventory_controller_def)

--- @namepsace yatm.dscs.formspec
local my_fspec = {}

--- @spec #render_inventory_controller_at({
---   pos: Vector3,
---   node: NodeRef,
---   x: Number,
---   y: Number,
---   w: Number,
---   h: Number
--- }): String
function my_fspec.render_inventory_controller_at(options)
  local pos = assert(options.pos)
  local node = assert(options.node)
  local x = assert(options.x)
  local y = assert(options.y)
  local w = options.w or 1
  local h = options.h or 1

  local node_id = hash_node_position(pos)
  local ivc_node_entry = yatm.dscs.get_inventory_controller_node_entry_by_id(node_id)

  if ivc_node_entry then
    return fspec.item_image(x, y, w, h, ivc_node_entry.node.name) ..
      fspec.tooltip_area(x, y, w, h, minetest.pos_to_string(ivc_node_entry.pos))
  end

  return ""
end

--- @spec render_inventory_controller_children_at({
---   pos: Vector3,
---   node: NodeRef,
---   x: Number,
---   y: Number,
---   cols: Integer,
---   rows: Integer,
--- }): String
function my_fspec.render_inventory_controller_children_at(options)
  local pos = options.pos
  local node = options.node
  local x = options.x
  local y = options.y
  local cols = options.cols
  local rows = options.rows

  local node_id = hash_node_position(pos)

  local cluster = yatm.cluster.devices:get_node_cluster_by_id(node_id)

  local formspec = ""

  if not cluster then
    return formspec
  end

  local node_entry = cluster:get_node_by_id(node_id)

  if not node_entry then
    return formspec
  end

  local meta = minetest.get_meta(pos)

  local inv_con = get_inventory_controller_def(pos, node)

  if not inv_con then
    return formspec
  end

  local count, list =
    metaref_string_list_to_table(
      meta,
      inv_con.child_key_prefix,
      inv_con.max_children
    )

  if not list then
    return formspec
  end

  local cio = fspec.calc_inventory_offset

  for row = 1,rows do
    for col = 1,cols do
      local i = 1 + (row - 1) * cols + (col - 1)
      if i <= count then
        local dx = x + cio(col - 1)
        local dy = y + cio(row - 1)

        local child_pos = string_to_pos(list[i] or "")

        if child_pos then
          local child_node_entry = cluster:get_node(child_pos)

          if child_node_entry then
            formspec =
              formspec ..
              fspec.item_image(dx, dy, 1, 1, child_node_entry.node.name) ..
              fspec.tooltip_area(
                dx,
                dy,
                1,
                1,
                child_node_entry.node.name .. " " .. minetest.pos_to_string(child_node_entry.pos)
              )
          else
            formspec =
              formspec ..
              fspec.label(dx, dy, "Missing Child " .. list[i])
          end
        end
      end
    end
  end

  return formspec
end

yatm.dscs.formspec = my_fspec
