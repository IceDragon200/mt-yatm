--- @namespace yatm.codex
local mod = assert(yatm_codex)

local fspec = assert(foundation.com.formspec.api)

--- Formspec for Codex from on_secondary_use (i.e. no target).
--- This formspec shows the codex's primary menu on knowledge the player already acquired.
---
--- @spec render_wiki_formspec(entity: PlayerRef, state: Table): String
function yatm.codex.render_wiki_formspec(entity, state)
  local cis = assert(fspec.calc_inventory_size)

  local cols = math.max(yatm.get_player_hotbar_size(entity), 10)
  local rows = 10

  local fw = cis(cols)
  local fh = cis(rows)

  local formspec =
    fspec.formspec_version(6)
    .. fspec.size(fw, fh)
    .. yatm.formspec_bg_for_player(
      entity:get_player_name(),
      "codex",
      0, 0,
      fw, fh
    )

  return formspec
end

---
---
--- @spec render_codex_entry_formspec(entity: PlayerRef, state: Table): String
function yatm.codex.render_codex_entry_formspec(entity, state)
  local cis = assert(fspec.calc_inventory_size)

  local cols = math.max(yatm.get_player_hotbar_size(entity), 10)
  local rows = 10

  local fw = cis(cols)
  local fh = cis(rows)

  local formspec =
    fspec.formspec_version(6)
    .. fspec.size(fw, fh)
    .. yatm.formspec_bg_for_player(
      entity:get_player_name(),
      "codex",
      0, 0,
      fw, fh
    )

  local page = assert(state.codex_entry.pages[state.page_id])

  if page.heading_item then
    local item_name
    local heading_type = type(page.heading_item)
    if heading_type == "table" then
      if page.heading_item.context then
        item_name = state.context.item_name
      end

      if not item_name then
        item_name = page.heading_item.default
      end
    elseif heading_type == "string" then
      item_name = page.heading_item
    else
      item_name = "air"
    end

    formspec =
      formspec
      .. fspec.item_image(0.25, 0.25, 2, 2, "yatm_core:grid_block")
      .. fspec.item_image(0.25, 0.25, 2, 2, item_name)
  end

  if page.heading and page.heading ~= "" then
    local x = 0.25

    if page.heading_item then
      x = x + 2
    end

    formspec =
      formspec ..
      fspec.label(x, 0.5, page.heading)
  end

  local y = 2.5

  local dy = y
  if page.lines then
    for i, line in ipairs(page.lines) do
      dy = y + (i - 1) * 1.0
      formspec =
        formspec
        .. fspec.hypertext(0.25, dy, fw, 1.2, "line"..i, line)
    end
  end

  if page.demos then
    y = dy
    for i, demo_name in ipairs(page.demos) do
      dy = y + (i) * 0.2
      formspec =
        formspec
        .. fspec.button(0.25, dy, fw - 0.50, 1, "demo", demo_name)
    end
  end

  if state.page_count > 1 then
    if state.page_id > 1 then
      formspec =
        formspec
        .. fspec.button(0.25, fh - 1.25, 2, 1, "prev_page", "<")
    end

    if state.page_id < state.page_count then
      formspec =
        formspec
        .. fspec.button(w - 2.25, fh - 1.25, 2, 1, "next_page", ">")
    end
  end

  return formspec
end
