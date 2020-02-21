#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "oku_6502_common.h"

#define MEMSIZE 0xFFFF
int main(int argc, char** argv)
{
  char memory[MEMSIZE];
  struct oku_6502_chip chip;

  memset(memory, 0, MEMSIZE);
  memory[0x200] = 0xA9;
  memory[0x201] = 0x00;
  memory[0xFFFC] = 0x00;
  memory[0xFFFD] = 0x02;

  oku_6502_chip_init(&chip);
  int status;
  for (int i = 0; i < 9; i++)
  {
    status = oku_6502_chip_step(&chip, MEMSIZE, memory);
    printf("%d\n", status);
  }

  assert(chip.pc == 512);

  status = oku_6502_chip_step(&chip, MEMSIZE, memory);
  printf("%d\n", status);

  assert(chip.pc == 514);
  assert(chip.a == 0);

  return 0;
}
