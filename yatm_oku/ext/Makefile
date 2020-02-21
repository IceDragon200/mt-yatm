INCLUDE_DIRS=-I./include/ -I.

.PHONY : default_target
default_target: all

%.o: %.c
	gcc $(INCLUDE_DIRS) -fPIC -Wall -Werror -O3 -c $< -o $@

%.so: %.o
	gcc $(INCLUDE_DIRS) -fPIC -shared -Wall -Werror -lc $< -o $@

test_oku_6502: test_oku_6502.o oku_6502.o
	gcc $(INCLUDE_DIRS) -Wall -Werror -lc oku_6502.o test_oku_6502.o -o $@

.PHONY : all
all: oku_6502.so oku_sm6502.so oku_65816.so oku_8086.so oku_riscv_rv32i.so

clean:
	rm -v *.so
