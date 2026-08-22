#include <stdint.h>

#define VERSION_MAJOR 0
#define VERSION_MINOR 1
#define VERSION_TEENY 0

#define OK_CODE 0
#define INVALID_CODE 1
#define SEGFAULT_CODE -1
#define HALT_CODE 4
#define HANG_CODE 5
#define STARTUP_CODE 7

extern int oku_65816_step()
{
  return OK_CODE;
}
