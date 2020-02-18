local ffi = assert(yatm.ffi)

local yatm_core_utils
pcall(function ()
  yatm_core_utils = ffi.load(yatm_core.modpath .. "/ext/yatm_core_utils.so")
end)

if not yatm_core_utils then
  minetest.log("warning", "yatm_core_utils shared object is not available, skipping implementation")
  minetest.log("warning", "\n\nWARN: Some functions will be slightly slower, should be fine for the most part.\n\n")
  return
end

ffi.cdef([[
struct yatm_core_encode_cursor
{
  uint32_t input_size;
  uint32_t input_index;
  uint32_t buffer_size;
  uint32_t buffer_index;
  uint8_t end_of_input; // when 0, the input still has bytes to go
  uint8_t end_of_buffer; // when 0, the buffer still has space for more data,
                         // otherwise the buffer should be flushed and the
                         // function called again with the cursor
  uint16_t held_size;    // How many bytes were held
  uint16_t held_cursor;
  char held[4];
};

extern void yatm_core_string_hex_decode(struct yatm_core_encode_cursor* cursor, char* input, char* buffer);
extern void yatm_core_string_hex_encode(struct yatm_core_encode_cursor* cursor, char* input, char* buffer, uint32_t spacer_size, char* spacer);
extern void yatm_core_string_hex_unescape(struct yatm_core_encode_cursor* cursor, char* input, char* buffer);
extern void yatm_core_string_hex_escape(struct yatm_core_encode_cursor* cursor, char* input, char* buffer, int mode);
]])

yatm.native_utils = yatm_core_utils

do
  local ffi = yatm.ffi
  local cursor = ffi.new("struct yatm_core_encode_cursor")
  cursor.buffer_size = 0x40000

  local input_buffer = ffi.new("char[" .. cursor.buffer_size .. "]")
  local buffer = ffi.new("char[" .. cursor.buffer_size .. "]")
  local native_utils = yatm.native_utils


  function yatm_core.ffi_encoder(str, callback)
    assert(str, "expected a string")
    assert(callback, "expected a callback")
    cursor.input_size = #str
    assert(cursor.input_size < 65535, "cannot encode input string")
    cursor.input_index = 0
    cursor.buffer_index = 0
    cursor.end_of_input = 0
    cursor.end_of_buffer = 0

    local result = {}
    local i = 1
    ffi.copy(input_buffer, str, cursor.input_size)
    while cursor.input_index < cursor.input_size and
          cursor.end_of_buffer == 0 do
      print("input_index=" .. cursor.input_index ..
            " input_size=" .. cursor.input_size ..
            " buffer_index=" .. cursor.buffer_index ..
            " buffer_size=" .. cursor.buffer_size)
      callback(cursor, input_buffer, buffer)

      result[i] = ffi.string(buffer, cursor.buffer_index)
      i = i + 1
      if cursor.end_of_buffer > 0 then
        cursor.buffer_index = 0
        cursor.end_of_buffer = 0
      else
        if cursor.end_of_input > 0 then
          break
        end
      end
    end

    return table.concat(result)
  end
end
