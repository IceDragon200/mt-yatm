/**
 * Below are some utilities for yatm_core written in C to speed up execution
 */
#include <stdint.h>
#include <assert.h>

#define ESCAPE_MODE_NON_ASCII 0
#define ESCAPE_MODE_ALL 1

#define MAX_HELD_SIZE 256

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
  uint16_t held_cursor;  //
  char held[MAX_HELD_SIZE];         // Any additional bytes that were held over from the previous buffer (i.e. incomplete encodings)
};

static inline char byte_to_hexchar(char byte)
{
  if (byte >= 0 && byte <= 9)
  {
    /* 0-9 */
    return 48 + byte;
  }
  else if (byte >= 10 && byte <= 15)
  {
    /* A-F */
    return 65 + byte - 10;
  }
  else
  {
    return '0';
  }
}

static inline char hexchar_to_byte(char hexchar)
{
  if (hexchar >= 65 && hexchar <= 70)
  {
    /* A-F */
    return 10 + hexchar - 65;
  }
  else if (hexchar >= 97 && hexchar <= 102)
  {
    /* a-f */
    return 10 + hexchar - 97;
  }
  else if (hexchar >= 48 && hexchar <= 57)
  {
    /* 0-9 */
    return hexchar - 48;
  }
  return 0;
}

static inline char hexchars_to_byte(char hi, char lo)
{
  return (hexchar_to_byte(hi) << 4) + hexchar_to_byte(lo);
}

static inline int write_to_buffer(struct yatm_core_encode_cursor* cursor, char* buffer, char value)
{
  if (cursor->buffer_index >= cursor->buffer_size)
  {
    cursor->end_of_buffer = 1;
    return 0;
  }

  buffer[cursor->buffer_index] = value;
  cursor->buffer_index += 1;
  return 1;
}

static inline void hold_byte(struct yatm_core_encode_cursor* cursor, char byte)
{
  assert(cursor->held_size <= MAX_HELD_SIZE);
  cursor->held[cursor->held_size] = byte;
  cursor->held_size += 1;
  cursor->held_cursor = (cursor->held_cursor + 1) % MAX_HELD_SIZE;
}

static inline int write_to_buffer_or_hold(struct yatm_core_encode_cursor* cursor, char* buffer, char byte)
{
  if (write_to_buffer(cursor, buffer, byte))
  {
    return 1;
  }
  hold_byte(cursor, byte);
  return 0;
}

static inline int resolve_held_bytes(struct yatm_core_encode_cursor* cursor, char* buffer)
{
  while (cursor->held_size)
  {
    if (write_to_buffer(cursor, buffer, cursor->held[cursor->held_cursor]))
    {
      cursor->held_size -= 1;
      cursor->held_cursor = (cursor->held_cursor + 1) % MAX_HELD_SIZE;
    }
    else
    {
      return 0;
    }
  }
  return 1;
}

extern void yatm_core_string_hex_decode(struct yatm_core_encode_cursor* cursor, char* input, char* buffer)
{
  assert(input);
  assert(buffer);
  if (cursor->input_index >= cursor->input_size)
  {
    cursor->end_of_input = 1;
    return;
  }

  resolve_held_bytes(cursor, buffer);

  while (cursor->input_index < cursor->input_size)
  {
    char hinibble = input[cursor->input_index];
    cursor->input_index += 1;
    if (cursor->input_index < cursor->input_size)
    {
      char lonibble = input[cursor->input_index];
      cursor->input_index += 1;

      char value = hexchars_to_byte(hinibble, lonibble);
      if (write_to_buffer_or_hold(cursor, buffer, value))
      {
        // no problems
      }
      else
      {
        break;
      }
    }
    else
    {
      cursor->end_of_input = 1;
      char value = hexchars_to_byte(hinibble, 0);
      if (write_to_buffer_or_hold(cursor, buffer, value))
      {
        // no problems
      }
      else
      {
        break;
      }
    }
  }
}

extern void yatm_core_string_hex_encode(struct yatm_core_encode_cursor* cursor, char* input, char* buffer, uint32_t spacer_size, char* spacer)
{
  assert(input);
  assert(buffer);
  if (cursor->input_index >= cursor->input_size)
  {
    cursor->end_of_input = 1;
    return;
  }

  resolve_held_bytes(cursor, buffer);

  while (cursor->input_index < cursor->input_size)
  {
    char byte = input[cursor->input_index];
    cursor->input_index += 1;

    char lonibble = byte & 0xF;
    char hinibble = (byte >> 4) & 0xF;

    char lochar = byte_to_hexchar(lonibble);
    char hichar = byte_to_hexchar(hinibble);

    write_to_buffer_or_hold(cursor, buffer, hichar);
    write_to_buffer_or_hold(cursor, buffer, lochar);
    if (cursor->input_index < cursor->input_size)
    {
      for (uint32_t i = 0; i < spacer_size; i += 1)
      {
        write_to_buffer_or_hold(cursor, buffer, spacer[i]);
      }
    }
    if (cursor->end_of_buffer)
    {
      break;
    }
  }
}

extern void yatm_core_string_hex_unescape(struct yatm_core_encode_cursor* cursor, char* input, char* buffer)
{
  assert(input);
  assert(buffer);
  if (cursor->input_index >= cursor->input_size)
  {
    cursor->end_of_input = 1;
    return;
  }

  resolve_held_bytes(cursor, buffer);

  while (cursor->input_index < cursor->input_size)
  {
    char byte = input[cursor->input_index];
    cursor->input_index += 1;

    /* 92 \ */
    if (byte == 92)
    {
      if (cursor->input_index < cursor->input_size)
      {
        char byte2 = input[cursor->input_index];
        cursor->input_index += 1;
        /* 120 x */
        if (byte2 == 120)
        {
          if ((cursor->input_index + 1) < cursor->input_size)
          {
            char hinibble = input[cursor->input_index];
            cursor->input_index += 1;

            char lonibble = input[cursor->input_index];
            cursor->input_index += 1;

            char value = hexchars_to_byte(hinibble, lonibble);

            if (write_to_buffer_or_hold(cursor, buffer, value))
            {
              // no problem
            }
            else
            {
              break;
            }
          }
          else
          {
            write_to_buffer_or_hold(cursor, buffer, byte);
            while (cursor->input_index < cursor->input_size)
            {
              write_to_buffer_or_hold(cursor, buffer, input[cursor->input_index]);
              cursor->input_index += 1;
            }
          }
        }
        /* 92 \ */
        else if (byte2 == 92)
        {
          if (write_to_buffer_or_hold(cursor, buffer, '\\'))
          {
            // no problem
          }
          else
          {
            break;
          }
        }
        else
        {
          if (write_to_buffer_or_hold(cursor, buffer, byte2))
          {
            // no problem
          }
          else
          {
            break;
          }
        }
      }
      else
      {
        write_to_buffer_or_hold(cursor, buffer, byte);
        cursor->end_of_input = 1;
      }
    }
    else
    {
      if (write_to_buffer_or_hold(cursor, buffer, byte))
      {
        // no problem
      }
      else
      {
        break;
      }
    }
  }
}

extern void yatm_core_string_hex_escape(struct yatm_core_encode_cursor* cursor, char* input, char* buffer, int mode)
{
  assert(input);
  assert(buffer);
  if (cursor->input_index >= cursor->input_size)
  {
    cursor->end_of_input = 1;
    return;
  }

  resolve_held_bytes(cursor, buffer);

  while (cursor->input_index < cursor->input_size)
  {
    char byte = input[cursor->input_index];
    cursor->input_index += 1;

    /* 92 \ */
    if (mode == ESCAPE_MODE_NON_ASCII && byte == 92)
    {
      write_to_buffer_or_hold(cursor, buffer, '\\');
      write_to_buffer_or_hold(cursor, buffer, '\\');
    }
    else if (mode == ESCAPE_MODE_NON_ASCII &&
             byte >= 32 && byte < 127 && byte != 92)
    {
      write_to_buffer_or_hold(cursor, buffer, byte);
    }
    else
    {
      char lonibble = byte & 0xF;
      char hinibble = (byte >> 4) & 0xF;

      char lochar = byte_to_hexchar(lonibble);
      char hichar = byte_to_hexchar(hinibble);

      write_to_buffer_or_hold(cursor, buffer, '\\');
      write_to_buffer_or_hold(cursor, buffer, 'x');
      write_to_buffer_or_hold(cursor, buffer, hichar);
      if (write_to_buffer_or_hold(cursor, buffer, lochar))
      {
        // no problem
      }
      else
      {
        break;
      }
    }
  }
}
