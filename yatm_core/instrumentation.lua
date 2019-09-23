--[[

  A limited implementation of OpenTrace for instrumenting parts of YATM's code

]]
yatm_core.trace = {}

local g_span_id = 0

function yatm_core.trace.new(name)
  g_span_id = g_span_id + 1
  return {
    id = g_span_id,
    name = name,
    spans = {},
    s = minetest.get_us_time(),
    e = nil,
    d = nil,
  }
end

function yatm_core.trace.clear(instance)
  instance.spans = {}
end

function yatm_core.trace.span_start(instance, name)
  local span = yatm_core.trace.new(name)
  table.insert(instance.spans, span)
  return span
end

function yatm_core.trace.span_end(span)
  span.e = minetest.get_us_time()
  span.d = span.e - span.s
end

function yatm_core.trace.span(instance, name, work)
  local span = yatm_core.trace.span_start(instance, name)
  work()
  yatm_core.trace.span_end(span)
end

function yatm_core.trace.inspect(instance, prefix)
  assert(instance)
  prefix = prefix or ''
  print(prefix .. instance.id .. ": " .. instance.name .. " (" .. (instance.d or '_') .. " usec)")
  local subprefix = prefix .. "  "
  for _, span in ipairs(instance.spans) do
    yatm_core.trace.inspect(span, subprefix)
  end
end
